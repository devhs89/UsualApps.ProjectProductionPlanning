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
        // Transfer the source requisition lines to a temporary record for processing.
        this.ProjectProdOrdersMgmt__TransferSourceReqLinesToLocalReqLines(Rec, TempReqLine);
        if not TempReqLine.FindSet() then Error(NoDemandLinesLabelTxt);

        // Set the production order choice based on the requisition line's "Create Prod. Order" field.
        ProdOrderChoice := Enum::"Production Order Status"::"Firm Planned";

        this.OnAfterSetMfgCarrryOutActionFromProdOrderParameters(TempReqLine, ProdOrderChoice);

        repeat
            ProdOrder := ProdProjSrc.ProjectProdOrdersMgmt__ProductionHeaderExists(TempReqLine, ProdOrderChoice);
            if ProdOrder.IsEmpty() then begin
                // If the production order does not exist, create a new production order header for the requisition line.
                if ProdProjSrc.ProdOrderPlusProjSrcUAS__CreateProjectProductionOrderHeader(TempReqLine, ProdOrder, ProdOrderChoice) then begin
                    // If the production order was created successfully, add it to the list of created production orders.
                    if (Text.StrPos(CreatedProdOrders.ToText(), ProdOrder."No.") = 0) then CreatedProdOrders.AppendLine(ProdOrder."No.");
                    // Create the production order line for the requisition line and the newly created production order.
                    if ProdProjSrc.ProjectProdOrdersMgmt__CreateProductionOrderLine(TempReqLine, ProdOrder) then
                        this.ProjectProdOrdersMgmt__DeletePersistentReqLines(TempReqLine);
                end;
            end else
                // If the production order already exists, modify it and create the production order line for the requisition line.
                if ProdProjSrc.ProjectProdOrdersMgmt__CreateProductionOrderLine(TempReqLine, ProdOrder) then begin
                    // If the production order was modified successfully, add it to the list of modified production orders.
                    if (Text.StrPos(CreatedProdOrders.ToText(), ProdOrder."No.") = 0) and (Text.StrPos(ModifiedProdOrders.ToText(), ProdOrder."No.") = 0) then
                        ModifiedProdOrders.AppendLine(ProdOrder."No.");
                    // Delete the persistent requisition line after successfully creating the production order line.
                    this.ProjectProdOrdersMgmt__DeletePersistentReqLines(TempReqLine);
                end;
        until TempReqLine.Next() = 0;

        // Display a message summarizing the created and modified production orders, if any.
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
        Helper.ProjectProdPlanningHelper__CopyProdOrderReqLinesOver(Rec, ReqLine, 0, 0, true);
        if ReqLine.FindSet() then
            repeat
                ReqLine."Planning Line Origin" := ReqLine."Planning Line Origin"::ProjectPlanningUAS;
                ReqLine.Modify()
            until ReqLine.Next() = 0;
        ReqLine.SetRange("Planning Line Origin", ReqLine."Planning Line Origin"::ProjectPlanningUAS);
        ReqLine.SetFilter("No.", '<>''''');
        ReqLine.SetFilter(Quantity, '<>0');
        Helper.ProjectProdPlanningHelper__CopyRequisuitionFilters(ReqLine, ReqLine, 0, 187);
    end;

    /// <summary>
    /// Deletes persistent requisition lines associated with the provided requisition line record.
    /// </summary>
    /// <param name="ReqLine">The requisition line record containing the persistent requisition lines to delete.</param>
    local procedure ProjectProdOrdersMgmt__DeletePersistentReqLines(var ReqLine: Record "Requisition Line")
    var
        PersistReqLine: Record "Requisition Line";
    begin
        Clear(PersistReqLine);
        PersistReqLine.Copy(ReqLine);
        PersistReqLine.SetCurrentKey("User ID", "Demand Type", "Worksheet Template Name", "Journal Batch Name", "Line No.", "Demand Order No.", Type, "No.");
        PersistReqLine.SetRecFilter();
        if PersistReqLine.FindFirst() then PersistReqLine.Delete(true);
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
