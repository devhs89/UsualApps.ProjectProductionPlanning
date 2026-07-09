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
        MessageLabelTxt: TextBuilder;
        NoDemandLinesLabelTxt: Label 'No demand lines to process.';
        CreatedProdOrderLabelTxt: Label 'Production Order(s) created:\%1', Comment = '%1 = List of production order numbers created';
        ModifiedProdOrderLabelTxt: Label 'Production Orders modified:\%1', Comment = '%1 = List of production order numbers modified';
    begin
        this.ProjectProdOrdersMgmt__TransferSourceReqLinesToLocalReqLines(Rec, TempReqLine);
        if not TempReqLine.FindSet() then Error(NoDemandLinesLabelTxt);

        ProdOrderChoice := Enum::"Production Order Status"::"Firm Planned";
        this.OnAfterSetMfgCarrryOutActionFromProdOrderParameters(TempReqLine, ProdOrderChoice);

        repeat
            ProdOrder := ProdProjSrc.ProjectProdOrdersMgmt__ProductionHeaderExists(TempReqLine, ProdOrderChoice);
            if ProdOrder.IsEmpty() then begin
                if ProdProjSrc.ProdOrderPlusProjSrcUAS__CreateProjectProductionOrderHeader(TempReqLine, ProdOrder, ProdOrderChoice) then
                    if (Text.StrPos(CreatedProdOrders.ToText(), ProdOrder."No.") = 0) then CreatedProdOrders.AppendLine(ProdOrder."No.");
            end else begin
                ProdProjSrc.ProjectProdOrdersMgmt__CreateProductionOrderLine(TempReqLine, ProdOrder);
                if (Text.StrPos(CreatedProdOrders.ToText(), ProdOrder."No.") = 0) and (Text.StrPos(ModifiedProdOrders.ToText(), ProdOrder."No.") = 0) then
                    ModifiedProdOrders.AppendLine(ProdOrder."No.");
            end;
        until TempReqLine.Next() = 0;

        if CreatedProdOrders.Length() > 0 then MessageLabelTxt.AppendLine(StrSubstNo(CreatedProdOrderLabelTxt, CreatedProdOrders));
        if ModifiedProdOrders.Length() > 0 then MessageLabelTxt.AppendLine(StrSubstNo(ModifiedProdOrderLabelTxt, ModifiedProdOrders));
        Message(MessageLabelTxt.ToText());
    end;

    /// <summary>
    /// Copy the requisition lines from one record to another.
    /// </summary>
    /// <param name="Rec">The external requisition line record to copy from.</param>
    /// <param name="ReqLine">The requisition line record containing the records to copy.</param>
    /// <param name="ShareTable">Indicates whether to share the temporary table.</param>
    local procedure ProjectProdOrdersMgmt__TransferSourceReqLinesToLocalReqLines(var Rec: Record "Requisition Line"; var ReqLine: Record "Requisition Line")
    var
        Helper: Codeunit ProjectProdPlanningHelperUAS;
    begin
        Clear(ReqLine);
        Helper.ProjectProdPlanningHelper__CopyProdOrderReqLinesOver(Rec, ReqLine, 0, true);
        ReqLine.Reset();
        Helper.ProjectProdPlanningHelper__CopyRequisuitionFilters(Rec, ReqLine, 187, 0);
        Helper.ProjectProdPlanningHelper__CopyRequisuitionFilters(Rec, ReqLine, 187, 187);
        if ReqLine.FindSet() then
            repeat
                ReqLine."Planning Line Origin" := ReqLine."Planning Line Origin"::ProjectPlanningUAS;
                ReqLine.Modify()
            until ReqLine.Next() = 0;
        ReqLine.SetRange("Planning Line Origin", ReqLine."Planning Line Origin"::ProjectPlanningUAS);
        ReqLine.SetFilter("No.", '<>''''');
        ReqLine.SetFilter(Quantity, '<>0');
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
