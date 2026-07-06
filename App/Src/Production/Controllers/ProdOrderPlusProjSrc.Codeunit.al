namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.Document;
using Microsoft.Projects.Project.Job;

codeunit 71826213 ProdOrderPlusProjSrcUAS
{
    // Event raised after the production order is initiated with the requisition line.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Mfg. Carry Out Action", OnInsertProdOrderWithReqLine, '', false, false)]
    local procedure MfgCarryOutAction_OnInsertProdOrderWithReqLine(var ProductionOrder: Record "Production Order"; var RequisitionLine: Record "Requisition Line")
    var
        Job: Record Job;
        Helper: Codeunit ProjectProdPlanningHelperUAS;
        DemandNo: Code[20];
    begin
        if Helper.ProjectProdPlanningHelper__ValidateDemandOriginatedFromJobPlanningLine(RequisitionLine, 187) then exit;
        DemandNo := Helper.ProjectProdPlanningHelper__GetDemandNoFromFilterGroup(RequisitionLine, 187);

        if not Job.Get(DemandNo) then Error('The job number %1 does not exist.', DemandNo);
        this.ProdOrderPlusProjSrcUAS__InsertProjectProdOrderWithReqLine(ProductionOrder, RequisitionLine, Job);
    end;

    /// <summary>
    /// Inserts a production order with the requisition line and job information.
    /// </summary>
    /// <param name="Prod">The production order record to insert.</param>
    /// <param name="ReqLine">The requisition line record associated with the production order.</param>
    /// <param name="Job">The job record associated with the production order.</param>
    local procedure ProdOrderPlusProjSrcUAS__InsertProjectProdOrderWithReqLine(var Prod: Record "Production Order"; var ReqLine: Record "Requisition Line"; Job: Record Job)
    begin
        Prod."Source Type" := Prod."Source Type"::ProjectHeaderUAS;
        Prod."Source No." := Job."No.";
        Prod.Validate(Description, Job.Description);
        Prod."Description 2" := Job."Description 2";
        Clear(Prod."Variant Code");
        Prod."Creation Date" := Today;
        Prod."Last Date Modified" := Today;
        Clear(Prod."Inventory Posting Group");
        Clear(Prod."Gen. Prod. Posting Group");
        Prod."Due Date" := ReqLine."Due Date";
        Prod."Starting Time" := ReqLine."Starting Time";
        Prod."Starting Date" := ReqLine."Starting Date";
        Prod."Ending Time" := ReqLine."Ending Time";
        Prod."Ending Date" := ReqLine."Ending Date";
        Prod."Location Code" := Job."Location Code";
        Prod."Bin Code" := Job."Bin Code";
        Prod."Low-Level Code" := ReqLine."Low-Level Code";
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