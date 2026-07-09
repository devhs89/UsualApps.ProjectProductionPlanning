namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.Document;

codeunit 71826212 ProjectProdOrdersMgmtUAS
{
    TableNo = "Requisition Line";

    trigger OnRun()
    var
        TempReqLine: Record "Requisition Line" temporary;
        ProdOrder: Record "Production Order";
        ProdProjSrc: Codeunit ProdOrderPlusProjSrcUAS;
        ProdOrderChoice: Enum "Planning Create Prod. Order";
        CreatedProdOrders: TextBuilder;
        ModifiedProdOrders: TextBuilder;
    begin
        TempReqLine := this.ProjectProdOrdersMgmt__TransferSourceReqLinesToLocalReqLines(Rec);
        if TempReqLine.FindSet() then;

        ProdOrderChoice := Enum::"Production Order Status"::"Firm Planned";
        this.OnAfterSetMfgCarrryOutActionFromProdOrderParameters(TempReqLine, ProdOrderChoice);

        repeat
            ProdOrder := ProdProjSrc.ProjectProdOrdersMgmt__ProductionHeaderExists(TempReqLine, ProdOrderChoice);
            if ProdOrder.IsEmpty() then begin
                if ProdProjSrc.ProdOrderPlusProjSrcUAS__CreateProjectProductionOrderHeader(TempReqLine, ProdOrder, ProdOrderChoice) then
                    CreatedProdOrders.AppendLine(ProdOrder."No.");
            end else begin
                ProdProjSrc.ProjectProdOrdersMgmt__CreateProductionOrderLine(TempReqLine, ProdOrder);
                ModifiedProdOrders.AppendLine(ProdOrder."No.")
            end;
        until TempReqLine.Next() = 0;

        Message('Production Order(s) created:\%1' + '\' + 'Production Orders modified:\%2', CreatedProdOrders, ModifiedProdOrders);
    end;

    /// <summary>
    /// Copy the requisition lines from one record to another.
    /// </summary>
    /// <param name="Rec">The external requisition line record to copy from.</param>
    /// <param name="ReqLine">The requisition line record containing the records to copy.</param>
    /// <param name="ShareTable">Indicates whether to share the temporary table.</param>
    local procedure ProjectProdOrdersMgmt__TransferSourceReqLinesToLocalReqLines(var Rec: Record "Requisition Line") ReqLine: Record "Requisition Line"
    var
        Helper: Codeunit ProjectProdPlanningHelperUAS;
    begin
        Clear(ReqLine);
        Helper.ProjectProdPlanningHelper__CopyRequisuitionFilters(Rec, ReqLine, 187, 0);
        Helper.ProjectProdPlanningHelper__CopyRequisuitionFilters(Rec, ReqLine, 187, 187);
        Helper.ProjectProdPlanningHelper__CopyProdOrderReqLinesOver(Rec, ReqLine, 0, false);
        repeat
            ReqLine."Planning Line Origin" := ReqLine."Planning Line Origin"::ProjectPlanningUAS;
        until ReqLine.Next() = 0
    end;

    /// <summary>
    /// Event raised after the parameters for the Mfg. Carry Out Action from Prod Order are set.
    /// </summary>
    /// <param name="ReqLine">The requisition line record.</param>
    /// <param name="ProdOrderChoice">The production order choice enum value.</param>
    /// <param name="ProdWkshTempl">The production worksheet template code.</param>
    /// <param name="ProdWkshName">The production worksheet name code.</param>
    [IntegrationEvent(false, false)]
    local procedure OnAfterSetMfgCarrryOutActionFromProdOrderParameters(var ReqLine: Record "Requisition Line"; ProdOrderChoice: Enum "Planning Create Prod. Order")
    begin
    end;
}
