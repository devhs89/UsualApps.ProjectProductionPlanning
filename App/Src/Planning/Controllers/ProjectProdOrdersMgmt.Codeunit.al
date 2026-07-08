namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Foundation.Navigate;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.Document;

codeunit 71826212 ProjectProdOrdersMgmtUAS
{
    TableNo = "Requisition Line";

    trigger OnRun()
    var
        TempReqLine: Record "Requisition Line" temporary;
        TempDocumentEntry: Record "Document Entry" temporary;
        PersistReqLine: Record "Requisition Line";
        ProdOrderChoice: Enum "Planning Create Prod. Order";
        ProdWkshTempl: Code[10];
        ProdWkshName: Code[10];
        CreatedProdOrders: TextBuilder;
    begin
        this.ProjectProdOrdersMgmt__TransferSourceReqLinesToLocalReqLines(Rec, TempReqLine, false);
        if TempReqLine."Planning Line Origin" <> TempReqLine."Planning Line Origin"::ProjectPlanningUAS then exit;

        Clear(ProdWkshTempl);
        Clear(ProdWkshName);
        Clear(TempDocumentEntry);
        ProdOrderChoice := Enum::"Production Order Status"::"Firm Planned";
        this.OnAfterSetMfgCarrryOutActionFromProdOrderParameters(TempReqLine, ProdOrderChoice, ProdWkshTempl, ProdWkshName);

        Clear(PersistReqLine);
        PersistReqLine.SetCurrentKey("User ID", "Demand Type", "Worksheet Template Name", "Journal Batch Name", "Line No.", Type, "No.");

        repeat
            if this.ProjectProdOrdersMgmt__CreateProductionOrder(TempReqLine, ProdOrderChoice, TempDocumentEntry) then
                PersistReqLine.Copy(TempReqLine);
            PersistReqLine.SetRecFilter();
            if PersistReqLine.Count() > 0 then PersistReqLine.Delete(true);
        until TempReqLine.Next() = 0;

        Clear(CreatedProdOrders);
        repeat
            CreatedProdOrders.AppendLine(TempDocumentEntry."Document No.");
        until TempDocumentEntry.Next() = 0;

        Message('%1 production order(s) created:\%2', TempDocumentEntry.Count(), CreatedProdOrders);
    end;

    /// <summary>
    /// Copy the requisition lines from one record to another.
    /// </summary>
    /// <param name="Rec">The external requisition line record to copy from.</param>
    /// <param name="ReqLine">The requisition line record containing the records to copy.</param>
    /// <param name="ShareTable">Indicates whether to share the temporary table.</param>
    local procedure ProjectProdOrdersMgmt__TransferSourceReqLinesToLocalReqLines(var Rec: Record "Requisition Line"; var ReqLine: Record "Requisition Line"; ShareTable: Boolean)
    var
        Helper: Codeunit ProjectProdPlanningHelperUAS;
    begin
        Clear(ReqLine);
        Helper.ProjectProdPlanningHelper__CopyRequisuitionFilters(Rec, ReqLine, 187, 0);
        Helper.ProjectProdPlanningHelper__CopyRequisuitionFilters(Rec, ReqLine, 187, 187);
        Helper.ProjectProdPlanningHelper__CopyProdOrderReqLinesOver(Rec, ReqLine, 0, ShareTable);
        ReqLine.SetFilter("No.", '<>''''');
        ReqLine.SetFilter(Quantity, '<>0');
        if ReqLine.FindSet() then
            repeat
                ReqLine."Planning Line Origin" := ReqLine."Planning Line Origin"::ProjectPlanningUAS;
            until ReqLine.Next() = 0
        else
            Error('No requisition lines found to create production orders.');
    end;

    local procedure ProjectProdOrdersMgmt__CreateProductionOrder(RequisitionLine: Record "Requisition Line"; ProdOrderChoice: Enum "Planning Create Prod. Order"; var TempDocumentEntry: Record "Document Entry"): Boolean
    var
        ExistignProd: Record "Production Order";
        MfgAction: Codeunit "Mfg. Carry Out Action";
    begin
        ExistignProd.SetCurrentKey(Status, "Source Type", "Source No.");
        ExistignProd.SetRange(Status, "Production Order Status"::"Firm Planned");
        ExistignProd.SetRange("Source Type", "Prod. Order Source Type"::ProjectHeaderUAS);
        ExistignProd.SetRange("Source No.", RequisitionLine."Demand Order No.");
        if ExistignProd.Count > 0 then exit(true);
        Clear(TempDocumentEntry);
        MfgAction.InsertProductionOrder(RequisitionLine, ProdOrderChoice, TempDocumentEntry);
        
    end;

    local procedure ProjectProdOrdersMgmt__CreateProductionOrderLine(RequisitionLine: Record "Requisition Line"; ProductionOrder: Record "Production Order"): Boolean
    var
        Item: Record Item;
        MfgAction: Codeunit "Mfg. Carry Out Action";
    begin
        MfgAction.InsertProdOrderLine(RequisitionLine, ProductionOrder, Item);
    end;

    /// <summary>
    /// Event raised after the parameters for the Mfg. Carry Out Action from Prod Order are set.
    /// </summary>
    /// <param name="ReqLine">The requisition line record.</param>
    /// <param name="ProdOrderChoice">The production order choice enum value.</param>
    /// <param name="ProdWkshTempl">The production worksheet template code.</param>
    /// <param name="ProdWkshName">The production worksheet name code.</param>
    [IntegrationEvent(false, false)]
    local procedure OnAfterSetMfgCarrryOutActionFromProdOrderParameters(var ReqLine: Record "Requisition Line"; ProdOrderChoice: Enum "Planning Create Prod. Order"; ProdWkshTempl: Code[10]; ProdWkshName: Code[10])
    begin
    end;
}