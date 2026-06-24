namespace UsualApps.ProjectProductionPlanning;
using Microsoft.Assembly.Document;
using Microsoft.Inventory.Planning;
using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.Document;
using Microsoft.Projects.Project.Planning;
using Microsoft.Sales.Document;
using Microsoft.Service.Document;

codeunit 71826210 ProjectCardPlusPlanningUAS
{
    TableNo = "Job Planning Line";
    local procedure ProjectCardPlusPlanningUAS__IsUnplannedDemandOfJobPlanningLineOrigin(var UnplannedDemand: Record "Unplanned Demand"): Boolean
    var
        Result: Boolean;
    begin
        UnplannedDemand.FilterGroup(187);
        Result := (UnplannedDemand.GetFilter("Demand Type") = Format("Demand Order Source Type"::"Job Demand")) and (UnplannedDemand.GetFilter("Demand Order No.") <> '');
        UnplannedDemand.FilterGroup(0);
        exit(Result);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Unplanned Demand", OnBeforeGetUnplannedSalesLine, '', false, false)]
    local procedure GetUnplannedDemand_OnBeforeGetUnplannedSalesLine(var UnplannedDemand: Record "Unplanned Demand"; var SalesLine: Record "Sales Line")
    begin
        if not this.ProjectCardPlusPlanningUAS__IsUnplannedDemandOfJobPlanningLineOrigin(UnplannedDemand) then exit;
        SalesLine.SetRange("Document No.", '');
        SalesLine.SetRange("Line No.", 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Unplanned Demand", OnBeforeGetUnplannedJobPlanningLine, '', false, false)]
    local procedure GetUnplannedDemand_OnBeforeGetUnplannedJobPlanningLine(var UnplannedDemand: Record "Unplanned Demand"; var JobPlanningLine: Record "Job Planning Line")
    begin
        if not this.ProjectCardPlusPlanningUAS__IsUnplannedDemandOfJobPlanningLineOrigin(UnplannedDemand) then exit;
        UnplannedDemand.FilterGroup(187);
        JobPlanningLine.SetRange("Job No.", UnplannedDemand.GetFilter("Demand Order No."));
        UnplannedDemand.FilterGroup(0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Line-Planning", OnBeforeGetUnplannedProdOrderComp, '', false, false)]
    local procedure ProdOrderLinePlanning_OnBeforeGetUnplannedProdOrderComp(var UnplannedDemand: Record "Unplanned Demand"; var ProdOrderComponent: Record "Prod. Order Component")
    begin
        if not this.ProjectCardPlusPlanningUAS__IsUnplannedDemandOfJobPlanningLineOrigin(UnplannedDemand) then exit;
        ProdOrderComponent.SetRange("Prod. Order No.", '');
        ProdOrderComponent.SetRange("Line No.", 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly Line-Planning", OnBeforeGetUnplannedAsmLine, '', false, false)]
    local procedure AssemblyLinePlanning_OnBeforeGetUnplannedAsmLine(var UnplannedDemand: Record "Unplanned Demand"; var AssemblyLine: Record "Assembly Line")
    begin
        if not this.ProjectCardPlusPlanningUAS__IsUnplannedDemandOfJobPlanningLineOrigin(UnplannedDemand) then exit;
        AssemblyLine.SetRange("Document No.", '');
        AssemblyLine.SetRange("Line No.", 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Line-Planning", OnBeforeGetUnplannedServLine, '', false, false)]
    local procedure ServiceLinePlanning_OnBeforeGetUnplannedServLine(var UnplannedDemand: Record "Unplanned Demand"; var ServiceLine: Record "Service Line")
    begin
        if not this.ProjectCardPlusPlanningUAS__IsUnplannedDemandOfJobPlanningLineOrigin(UnplannedDemand) then exit;
        ServiceLine.SetRange("Document No.", '');
        ServiceLine.SetRange("Line No.", 0);
    end;
}
