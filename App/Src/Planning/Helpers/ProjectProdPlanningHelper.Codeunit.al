namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Planning;
using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.Document;
using Microsoft.Projects.Project.Planning;

codeunit 71826210 ProjectProdPlanningHelperUAS
{
    /// <summary>
    /// Set default filters for the Requisition Line table based on the specified FilterGroup and DemandNo.
    /// </summary>
    /// <param name="ReqLine">The Requisition Line record to set filters on.</param>
    /// <param name="FilterGroup"> The filter group to apply to the Requisition Line record.</param>
    /// <param name="DemandNo"> The demand order number to filter the Requisition Line records by.</param>
    internal procedure ProjectProdPlanningHelper__SetDefaultReqLineFilters(var ReqLine: Record "Requisition Line"; FilterGroup: Integer; DemandNo: Code[20])
    begin
        ReqLine.FilterGroup(FilterGroup);
        ReqLine.SetRange("User ID", UserId);
        ReqLine.SetRange("Worksheet Template Name", '');
        ReqLine.SetRange("Demand Type", Database::"Job Planning Line");
        ReqLine.SetRange("Demand Order No.", DemandNo);
        ReqLine.SetRange("Replenishment System", ReqLine."Replenishment System"::"Prod. Order");
        ReqLine.Setfilter("Line No.", '<>0');
        ReqLine.FilterGroup(0);
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
    end;

    /// <summary>
    /// Stops the refresh of a project source production order if it is sourced from a project header. Raises an error if the production order is sourced from a project header and cannot be refreshed.
    /// </summary>
    /// <param name="ProdOrder">The production order record to check for project source and refresh status.</param>
    internal procedure ProjectProdPlanningHelper__StopRefreshProjectSourceProductionOrder(var ProdOrder: Record "Production Order")
    var
        Evts: Codeunit ProjSourceProdOrderEventsUAS;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        Evts.OnProjectSourceProdOrderOnBeforeStopRefresh(ProdOrder, IsHandled);

        if IsHandled then exit;
        if ProdOrder."Source Type" = ProdOrder."Source Type"::ProjectHeaderUAS then
            Error('Project sourced firm planned production orders can not be refreshed. PLease delete and recreate production order from project card.');
    end;
}
