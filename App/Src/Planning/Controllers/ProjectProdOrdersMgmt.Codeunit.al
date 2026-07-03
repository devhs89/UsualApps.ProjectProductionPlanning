namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Foundation.Navigate;
using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.Document;

codeunit 71826212 ProjectProdOrdersMgmtUAS
{
    TableNo = "Requisition Line";

    trigger OnRun()
    var
        TempReqLine: Record "Requisition Line" temporary;
        TempDocumentEntry: Record "Document Entry" temporary;
        CerryAction: Codeunit "Carry Out Action";
        MfgAction: Codeunit "Mfg. Carry Out Action";
        ProdOrderChoice: Enum "Planning Create Prod. Order";
        ProdWkshTempl: Code[10];
        ProdWkshName: Code[10];
        PordOrderCreated: TextBuilder;
        Dex: Integer;
        Count: Integer;
    begin
        this.ProjectProdOrdersMgmt__GetRequisitionLines(TempReqLine, Rec);
        ProdOrderChoice := Enum::"Production Order Status"::"Firm Planned";
        Clear(ProdWkshTempl);
        Clear(ProdWkshName);
        this.OnAfterSetMfgCarrryOutActionFromProdOrderParameters(TempReqLine, ProdOrderChoice, ProdWkshTempl, ProdWkshName, TempDocumentEntry);

        Dex := 1;
        repeat
            Dex += 1;
            if MfgAction.CarryOutActionsFromProdOrder(TempReqLine, ProdOrderChoice, ProdWkshTempl, ProdWkshName, TempDocumentEntry, CerryAction) then begin
                PordOrderCreated.Append(TempDocumentEntry."Document No.");
                if Dex < TempReqLine.Count() then PordOrderCreated.Append(', ');
                Count += 1;
            end;
        until TempReqLine.Next() = 0;

        Message('%1 production order(s) created: %2', Count, PordOrderCreated);
    end;

    /// <summary>
    /// Get the requisition lines from the passed temporary table and copy them to local temporary table.
    /// </summary>
    /// <param name="TempReqLine">The temporary requisition line record containing the records to copy.</param>
    /// <param name="ExtReqLine">The external requisition line record to copy from.</param>
    local procedure ProjectProdOrdersMgmt__GetRequisitionLines(var
                                                                   TempReqLine: Record "Requisition Line";

var
ExtReqLine: Record "Requisition Line")
    begin
        Clear(TempReqLine);
        TempReqLine.Copy(ExtReqLine, true);
        TempReqLine.SetFilter(Quantity, '<>0');
        if TempReqLine.FindSet() then;
    end;

    /// <summary>
    /// Event raised after the parameters for the Mfg. Carry Out Action from Prod Order are set.
    /// </summary>
    /// <param name="ReqLine">The requisition line record.</param>
    /// <param name="ProdOrderChoice">The production order choice enum value.</param>
    /// <param name="ProdWkshTempl">The production worksheet template code.</param>
    /// <param name="ProdWkshName">The production worksheet name code.</param>
    /// <param name="DocumentEntry"> The document entry record.</param>
    [IntegrationEvent(false, false)]
    local procedure OnAfterSetMfgCarrryOutActionFromProdOrderParameters(var ReqLine: Record "Requisition Line"; ProdOrderChoice: Enum "Planning Create Prod. Order"; ProdWkshTempl: Code[10];
                                                                                                                                     ProdWkshName: Code[10]; var DocumentEntry: Record "Document Entry")
    begin
    end;
}