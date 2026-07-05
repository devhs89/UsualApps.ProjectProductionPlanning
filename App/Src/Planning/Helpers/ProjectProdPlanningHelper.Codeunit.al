namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Planning;
using Microsoft.Inventory.Requisition;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Planning;

codeunit 71826211 ProjectProdPlanningHelperUAS
{
    /// <summary>
    /// Sets the custom filter group on the unplanned demand record to filter for job planning line origin type.
    /// </summary>
    /// <param name="UnplanDemand">The unplanned demand record to set the filter on.</param>
    /// <param name="Job"> The job planning line record to use for filtering.</param>
    internal procedure ProjectProdPlanningHelper__SetJobPlanningCustomFilterGroup(var UnplanDemand: Record "Unplanned Demand"; Job: Record Job)
    var
        ReqLine2: Record "Requisition Line";
    begin
        this.ProjectProdPlanningHelper__SetReqLineFiltersToProdOrder(ReqLine2);
        if ReqLine2.Count() > 0 then ReqLine2.DeleteAll();

        UnplanDemand.FilterGroup(187);
        UnplanDemand.SetCurrentKey("Demand Type", "Demand Order No.", PlanningOriginUAS);
        UnplanDemand.SetRange("Demand Type", "Demand Order Source Type"::"Job Demand".AsInteger());
        UnplanDemand.SetRange("Demand Order No.", Job."No.");
        UnplanDemand.SetRange(PlanningOriginUAS, "Planning Line Origin Type"::JobPlanningLinesUAS);
        UnplanDemand.FilterGroup(0);
    end;

    /// <summary>
    /// Transfers the unplanned demand records to the requisition line records, setting the supply quantity and dates accordingly.
    /// </summary>
    /// <param name="ReqLine">The requisition line record to transfer the unplanned demand to.</param>
    /// <param name="UnplanDemand">The unplanned demand record to transfer from.</param>
    internal procedure ProjectProdPlanningHelper__TransferUnplannedDemandToRequisitionLine(var ReqLine: Record "Requisition Line"; var UnplanDemand: Record "Unplanned Demand")
    begin
        UnplanDemand.Reset();
        if UnplanDemand.FindSet(false) then
            repeat
                if UnplanDemand."Item No." = '' then continue;
                ReqLine.TransferFromUnplannedDemand(UnplanDemand);
                ReqLine.SetSupplyQty(UnplanDemand."Quantity (Base)", UnplanDemand."Needed Qty. (Base)");
                ReqLine.SetSupplyDates(UnplanDemand."Demand Date");
                ReqLine."Planning Line Origin" := ReqLine."Planning Line Origin"::JobPlanningLinesUAS;
                if not ReqLine.Insert(false) then Error('Failed to insert Requisition Line %1 for Item %2', ReqLine."Line No.", ReqLine."No.") else Commit();
            until UnplanDemand.Next() = 0;
    end;

    /// <summary>
    /// Sets the filters on the requisition line record to filter for production order replenishment system.
    /// </summary>
    /// <param name="ReqLine">The requisition line record to set the filters on.</param>
    internal procedure ProjectProdPlanningHelper__SetReqLineFiltersToProdOrder(var ReqLine: Record "Requisition Line")
    begin
        ReqLine.Reset();
        ReqLine.Init();
        ReqLine.GetJnlBatchNameForOrderPlanning();
        ReqLine.SetRange("User ID", UserId);
        ReqLine.SetRange("Planning Line Origin", "Planning Line Origin Type"::JobPlanningLinesUAS);
        ReqLine.SetRange("Replenishment System", ReqLine."Replenishment System"::"Prod. Order");
    end;

    /// <summary>
    /// Sets the filters on the requisition line record based on the unplanned demand record, using the specified filter group.
    /// </summary>
    /// <param name="ReqLine">The requisition line record to set the filters on.</param>
    /// <param name="UnplanDemand">The unplanned demand record to use for filtering.</param>
    /// <param name="FilterGrp">The filter group to use for setting the filters.</param>
    internal procedure ProjectProdPlanningHelper__SetReqLineFiltersFromUnplannedDemand(var ReqLine: Record "Requisition Line"; var UnplanDemand: Record "Unplanned Demand"; FilterGrp: Integer)
    var
        DemandNo: Code[20];
    begin
        if UnplanDemand.GetFilter(PlanningOriginUAS) <> Format(UnplanDemand.PlanningOriginUAS::JobPlanningLinesUAS) then Error('Demand did not originate from a Job Planning Line.');
        ReqLine.Reset();
        ReqLine.FilterGroup(FilterGrp);
        this.ProjectProdPlanningHelper__SetReqLineFiltersToProdOrder(ReqLine);

        if UnplanDemand.GetFilter("Demand Type") = Format(UnplanDemand."Demand Type"::Job) then
            ReqLine.SetRange("Demand Type", Database::"Job Planning Line");
        if Evaluate(DemandNo, UnplanDemand.GetFilter("Demand Order No.")) then
            ReqLine.SetRange("Demand Order No.", DemandNo);
        ReqLine.FilterGroup(0);
    end;

    /// <summary>
    /// Toggles the reserve checkbox on the requisition line records to the specified value.
    /// </summary>
    /// <param name="CurrReqLine">The requisition line record to toggle the reserve checkbox for.</param>
    /// <param name="Resv"> The value to set the reserve checkbox to.</param>
    internal procedure ProjectProdPlanningHelper__ToggleReserveCheckbox(var CurrReqLine: Record "Requisition Line")
    var
        TempReqLine: Record "Requisition Line" temporary;
    begin
        TempReqLine.Copy(CurrReqLine, true);
        if TempReqLine.FindSet(true) then;
        repeat
            TempReqLine."Planning Line Origin" := TempReqLine."Planning Line Origin"::"Order Planning";
            TempReqLine.Validate("Reserve", (not TempReqLine.Reserve));
            TempReqLine."Planning Line Origin" := TempReqLine."Planning Line Origin"::JobPlanningLinesUAS;
            if TempReqLine.Modify(false) then;
        until TempReqLine.Next() = 0;
    end;

    /// <summary>
    /// Toggles the quantity of the requisition line records between the needed quantity and zero.
    /// </summary>
    /// <param name="CurrReqLine">The requisition line record to toggle the quantity for.</param>
    /// <param name="ChangeQtyTo">The quantity to change the requisition line records to.</param>
    internal procedure ProjectProdPlanningHelper__ToggleRequisitionLineQuantity(var CurrReqLine: Record "Requisition Line")
    var
        TempReqLine: Record "Requisition Line" temporary;
    begin
        TempReqLine.Copy(CurrReqLine, true);
        if TempReqLine.FindSet(true) then;
        repeat
            TempReqLine.Validate(Quantity, (TempReqLine.Quantity = 0 ? TempReqLine."Needed Quantity" : 0));
            if TempReqLine.Modify(false) then;
        until TempReqLine.Next() = 0;
    end;
}
