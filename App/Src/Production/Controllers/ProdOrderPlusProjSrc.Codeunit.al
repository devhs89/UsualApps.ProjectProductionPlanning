namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Item;
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
    begin
        if RequisitionLine."Planning Line Origin" <> RequisitionLine."Planning Line Origin"::ProjectPlanningUAS then exit;
        if not Job.Get(RequisitionLine."Demand Order No.") then Error('The job number %1 does not exist.', RequisitionLine."Demand Order No.");
        this.ProdOrderPlusProjSrcUAS__InsertProjectProdOrderWithReqLine(ProductionOrder, RequisitionLine, Job);
    end;

    // Event raised after the production order is initiated with the requisition line to check if a production order already exists for the job.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Mfg. Carry Out Action", OnInsertProdOrderOnAfterFindTempProdOrder, '', false, false)]
    local procedure MfgCarryOutAction_OnInsertProdOrderOnAfterFindTempProdOrder(var ReqLine: Record "Requisition Line"; var ProdOrder: Record "Production Order"; var HeaderExists: Boolean; var Item: Record Item)
    var
        ExistignProd: Record "Production Order";
    begin
        if ReqLine."Planning Line Origin" <> ReqLine."Planning Line Origin"::ProjectPlanningUAS then exit;
        ExistignProd.SetCurrentKey(Status, "Source Type", "Source No.");
        ExistignProd.SetRange(Status, "Production Order Status"::"Firm Planned");
        ExistignProd.SetRange("Source Type", "Prod. Order Source Type"::ProjectHeaderUAS);
        ExistignProd.SetRange("Source No.", ReqLine."Demand Order No.");
        if ExistignProd.FindFirst() then begin
            ProdOrder.Copy(ExistignProd);
            HeaderExists := true;
        end;
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