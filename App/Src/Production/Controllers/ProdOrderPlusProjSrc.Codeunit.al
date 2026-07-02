namespace UsualApps.ProjectProductionPlanning;
using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.Document;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Project.Job;
using Microsoft.Inventory.Planning;

codeunit 71826213 ProdOrderPlusProjSrcUAS
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Mfg. Carry Out Action", OnInsertProdOrderWithReqLine, '', false, false)]
    local procedure MfgCarryOutAction_OnInsertProdOrderWithReqLine(var ProductionOrder: Record "Production Order"; var RequisitionLine: Record "Requisition Line")
    var
        DemandLineOrigin: Enum "Planning Line Origin Type";
        DemandType: Integer;
        DemandNo: Code[20];
    begin
        RequisitionLine.FilterGroup(187);
        if not RequisitionLine.HasFilter() then exit;
        if not (RequisitionLine.GetFilter("Planning Line Origin") = Format(DemandLineOrigin::JobPlanningLinesUAS)) then exit;
        if not Evaluate(DemandType, RequisitionLine.GetFilter("Demand Type")) then exit;
        if not Evaluate(DemandNo, RequisitionLine.GetFilter("Demand Order No.")) then exit;
        RequisitionLine.FilterGroup(0);
    end;

    local procedure ProdOrderPlusProjSrcUAS__InsertProjectProdOrderWithReqLine(var Prod: Record "Production Order"; Job: Record Job)
    var
        Item: Record Item;
    begin
        Prod."Source Type" := Prod."Source Type"::ProjectHeaderUAS;
        Prod."Source No." := Job."No.";
        Prod.Validate(Description, Job.Description);
        Prod."Description 2" := Job."Description 2";
        Prod."Location Code" := Job."Location Code";
        Prod."Bin Code" := Job."Bin Code";
        Clear(Prod."Routing No.");
        Prod.Quantity := 1;
        Clear(Prod."Unit Cost");
        Clear(Prod."Cost Amount");
        Prod."Shortcut Dimension 1 Code" := Job."Global Dimension 1 Code";
        Prod."Shortcut Dimension 2 Code" := Job."Global Dimension 2 Code";
        Clear(Prod."Dimension Set ID");
        Prod.UpdateDatetime();
    end;
}