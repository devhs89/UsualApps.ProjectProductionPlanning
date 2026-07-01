namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Planning;
using Microsoft.Inventory.Requisition;
using Microsoft.Projects.Project.Job;

codeunit 71826211 ProjectProdPlanningHelper
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
        if UnplanDemand.FindSet() then;
        repeat
            ReqLine.TransferFromUnplannedDemand(UnplanDemand);
            ReqLine.SetSupplyQty(UnplanDemand."Quantity (Base)", UnplanDemand."Needed Qty. (Base)");
            ReqLine.SetSupplyDates(UnplanDemand."Demand Date");
            if not ReqLine.Insert() then Error('Failed to insert Requisition Line for Item %1', UnplanDemand."Item No.");
        until UnplanDemand.Next() = 0;
        Commit();
    end;

    /// <summary>
    /// Sets the filters on the requisition line record to filter for production order replenishment system.
    /// </summary>
    /// <param name="ReqLine">The requisition line record to set the filters on.</param>
    internal procedure ProjectProdPlanningHelper__SetReqLineFiltersToProdOrder(var ReqLine: Record "Requisition Line")
    begin
        ReqLine.Reset();
        ReqLine.SetRange("Worksheet Template Name", '');
        ReqLine.SetRange("User ID", UserId);
        ReqLine.SetRange("Replenishment System", Enum::"Replenishment System"::"Prod. Order");
    end;
}