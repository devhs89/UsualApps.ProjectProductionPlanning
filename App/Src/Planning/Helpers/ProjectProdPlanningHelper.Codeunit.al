namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Planning;
using Microsoft.Inventory.Requisition;
using Microsoft.Projects.Project.Job;

codeunit 71826211 ProjectProdPlanningHelperUAS
{
    /// <summary>
    /// Sets the default filter group on the unplanned demand record to filter for job planning lines based on the specified job record.
    /// </summary>
    /// <param name="UnplanDemand">The unplanned demand record to set the filter on.</param>
    /// <param name="Job"> The job planning line record to use for filtering.</param>
    /// <param name="FilterGroup"> The filter group to use for setting the filters.</param>
    internal procedure ProjectProdPlanningHelper__SetDefaultJobPlanningFilterGroup(var UnplanDemand: Record "Unplanned Demand"; Job: Record Job; FilterGroup: Integer)
    begin
        UnplanDemand.FilterGroup(FilterGroup);
        UnplanDemand.SetCurrentKey("Demand Type", "Demand Order No.");
        UnplanDemand.SetRange("Demand Type", "Demand Order Source Type"::"Job Demand".AsInteger());
        UnplanDemand.SetRange("Demand Order No.", Job."No.");
        UnplanDemand.FilterGroup(0);
    end;

    /// <summary>
    /// Gets the demand type from the specified unplanned demand record and filter group.
    /// </summary>
    /// <param name="Variant"> The variant containing the unplanned demand record to retrieve the demand type from.</param>
    /// <param name="FilterGroup"> The filter group to use for retrieving the demand type.</param>
    /// <returns> The demand type as a text value.</returns>
    internal procedure ProjectProdPlanningHelper__GetDemandTypeFromFilterGroup(Variant: Variant; FilterGroup: Integer) DemandType: Text
    var
        UnplannedDemand: Record "Unplanned Demand";
        ReqLine: Record "Requisition Line";
        RecRef: RecordRef;
    begin
        if not Variant.IsRecord() then Error('Invalid record variant provided for validation.');
        RecRef.GetTable(Variant);
        case RecRef.Number of
            Database::"Unplanned Demand":
                begin
                    RecRef.SetTable(UnplannedDemand);
                    UnplannedDemand.FilterGroup(FilterGroup);
                    DemandType := UnplannedDemand.GetFilter("Demand Type");
                end;
            Database::"Requisition Line":
                begin
                    RecRef.SetTable(ReqLine);
                    ReqLine.FilterGroup(FilterGroup);
                    DemandType := ReqLine.GetFilter("Demand Type");
                end;
        end;
        exit(DemandType);
    end;

    /// <summary>
    /// Gets the demand order number from the specified unplanned demand record and filter group.
    /// </summary>
    /// <param name="Variant">The variant containing the unplanned demand record to retrieve the demand order number from.</param>
    /// <param name="FilterGroup">The filter group to use for retrieving the demand order number.</param>
    /// <returns>The demand order number as a code value.</returns>
    internal procedure ProjectProdPlanningHelper__GetDemandNoFromFilterGroup(Variant: Variant; FilterGroup: Integer) DemandNo: Code[20]
    var
        UnplannedDemand: Record "Unplanned Demand";
        ReqLine: Record "Requisition Line";
        RecRef: RecordRef;
    begin
        if not Variant.IsRecord() then Error('Invalid record variant provided for validation.');
        RecRef.GetTable(Variant);
        case RecRef.Number of
            Database::"Unplanned Demand":
                begin
                    RecRef.SetTable(UnplannedDemand);
                    UnplannedDemand.FilterGroup(FilterGroup);
                    if Evaluate(DemandNo, UnplannedDemand.GetFilter("Demand Order No.")) then;
                end;
            Database::"Requisition Line":
                begin
                    RecRef.SetTable(ReqLine);
                    ReqLine.FilterGroup(FilterGroup);
                    if Evaluate(DemandNo, ReqLine.GetFilter("Demand Order No.")) then;
                end;
        end;
        exit(DemandNo);
    end;

    /// <summary>
    /// Validates that the unplanned demand record originated from a job planning line based on the specified filter group.
    /// </summary>
    /// <param name="Variant">The variant containing the unplanned demand record to validate.</param>
    /// <param name="FilterGroup"> The filter group to use for validation.</param>
    /// <returns> True if the demand originated from a job planning line; otherwise, false.</returns>
    internal procedure ProjectProdPlanningHelper__ValidateDemandOriginatedFromJobPlanningLine(Variant: Variant; FilterGroup: Integer): Boolean
    var
        UnplannedDemand: Record "Unplanned Demand";
        ReqLine: Record "Requisition Line";
        Job: Record Job;
        RecRef: RecordRef;
        IsJobDemandType: Boolean;
        DemandNoFilter: Code[20];
    begin
        if not Variant.IsRecord() then Error('Invalid record variant provided for validation.');
        RecRef.GetTable(Variant);
        case RecRef.Number of
            Database::"Unplanned Demand":
                begin
                    RecRef.SetTable(UnplannedDemand);
                    IsJobDemandType := this.ProjectProdPlanningHelper__GetDemandTypeFromFilterGroup(UnplannedDemand, FilterGroup) = Format(Enum::"Unplanned Demand Type"::Job);
                    DemandNoFilter := this.ProjectProdPlanningHelper__GetDemandNoFromFilterGroup(UnplannedDemand, FilterGroup);
                end;
            Database::"Requisition Line":
                begin
                    RecRef.SetTable(ReqLine);
                    IsJobDemandType := this.ProjectProdPlanningHelper__GetDemandTypeFromFilterGroup(ReqLine, FilterGroup) = Format(Enum::"Unplanned Demand Type"::Job);
                    DemandNoFilter := this.ProjectProdPlanningHelper__GetDemandNoFromFilterGroup(ReqLine, FilterGroup);
                end;
        end;
        Clear(Job);
        Job.SetCurrentKey("No.");
        Job.SetRange("No.", DemandNoFilter);
        exit(IsJobDemandType and (Job.Count() > 0));
    end;

    /// <summary>
    /// Validates that the requisition line record originated from a job planning line based on the specified filter group.
    /// </summary>
    /// <param name="ReqLine">The requisition line record to validate.</param>
    /// <param name="FilterGroup"> The filter group to use for validation.</param>
    /// <returns> True if the demand originated from a job planning line; otherwise, false.</returns>
    internal procedure ProjectProdPlanningHelper__ValidateDemandOriginatedFromJobPlanningLine(var ReqLine: Record "Requisition Line"; FilterGroup: Integer): Boolean
    var
        Job: Record Job;
        IsJobDemandType: Boolean;
        DemandNoFilter: Code[20];
    begin
        IsJobDemandType := this.ProjectProdPlanningHelper__GetDemandTypeFromFilterGroup(ReqLine, FilterGroup) = Format(Enum::"Unplanned Demand Type"::Job);
        DemandNoFilter := this.ProjectProdPlanningHelper__GetDemandNoFromFilterGroup(ReqLine, FilterGroup);
        Job.SetCurrentKey("No.");
        Job.SetRange("No.", DemandNoFilter);
        exit(IsJobDemandType and (Job.Count() > 0));
    end;

    /// <summary>
    /// Sets the default filters on the requisition line record to filter for order planning lines based on the specified filter group.
    /// </summary>
    /// <param name="ReqLine">The requisition line record to set the filters on.</param>
    /// <param name="FilterGroup">The filter group to use for setting the filters.</param>
    internal procedure ProjectProdPlanningHelper__SetDefaultReqLineFilterGroup(var ReqLine: Record "Requisition Line"; FilterGroup: Integer; DemandType: Integer; DemandNo: Code[20])
    var
        CurrFilterGroup: Integer;
    begin
        CurrFilterGroup := ReqLine.FilterGroup();
        ReqLine.FilterGroup(FilterGroup);
        ReqLine.SetRange("Worksheet Template Name", '');
        ReqLine.SetRange("Journal Batch Name", ReqLine.GetJnlBatchNameForOrderPlanning());
        ReqLine.SetRange("User ID", UserId);
        ReqLine.SetRange("Planning Line Origin", "Planning Line Origin Type"::"Order Planning");
        ReqLine.SetRange("Replenishment System", ReqLine."Replenishment System"::"Prod. Order");
        ReqLine.SetRange("Demand Type", DemandType);
        ReqLine.SetRange("Demand Order No.", DemandNo);
        ReqLine.FilterGroup(CurrFilterGroup);
    end;

    /// <summary>
    /// Transfers the unplanned demand records to the requisition line records, setting the supply quantity and dates accordingly.
    /// </summary>
    /// <param name="UnplanDemand">The unplanned demand record to transfer from.</param>
    /// <param name="TempReqLine">The requisition line record to transfer the unplanned demand to.</param>
    internal procedure ProjectProdPlanningHelper__TransferUnplannedDemandToRequisitionLine(var UnplanDemand: Record "Unplanned Demand"; var TempReqLine: Record "Requisition Line"; FilterGroup: Integer)
    var
        DemandType: Enum "Unplanned Demand Type";
        DemandNo: Code[20];
    begin
        if not this.ProjectProdPlanningHelper__ValidateDemandOriginatedFromJobPlanningLine(UnplanDemand, FilterGroup) then Error('Demand did not originate from a Job Planning Line.');
        DemandType := this.ProjectProdPlanningHelper__GetDemandTypeFromFilterGroup(UnplanDemand, FilterGroup) = Format(DemandType::Job) ? DemandType::Job : DemandType::" ";
        DemandNo := this.ProjectProdPlanningHelper__GetDemandNoFromFilterGroup(UnplanDemand, FilterGroup);

        UnplanDemand.Reset();
        UnplanDemand.SetCurrentKey("Demand Type", "Demand Order No.", "Item No.");
        UnplanDemand.SetRange("Demand Type", UnplanDemand."Demand Type"::Job);
        UnplanDemand.SetRange("Demand Order No.", DemandNo);
        UnplanDemand.SetFilter("Item No.", '<>''''');
        if UnplanDemand.FindSet(false) then begin
            Clear(TempReqLine);
            repeat
                TempReqLine.TransferFromUnplannedDemand(UnplanDemand);
                TempReqLine.SetSupplyQty(UnplanDemand."Quantity (Base)", UnplanDemand."Needed Qty. (Base)");
                TempReqLine.SetSupplyDates(UnplanDemand."Demand Date");
                TempReqLine."Planning Line Origin" := TempReqLine."Planning Line Origin"::"Order Planning";
                if not TempReqLine.Insert(false) then Error('Failed to insert Requisition Line %1 for Item %2', TempReqLine."Line No.", TempReqLine."No.") else Commit();
            until UnplanDemand.Next() = 0;
        end;
    end;
}
