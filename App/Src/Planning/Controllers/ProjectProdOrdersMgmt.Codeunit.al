namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Foundation.Navigate;
using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.Document;

codeunit 71826212 ProjectProdOrdersMgmtUAS
{
    TableNo = "Requisition Line";

    trigger OnRun()
    var
        ReqLine: Record "Requisition Line";
        TempDocumentEntry: Record "Document Entry" temporary;
        CerryAction: Codeunit "Carry Out Action";
        MfgAction: Codeunit "Mfg. Carry Out Action";
        ProdOrderChoice: Enum "Planning Create Prod. Order";
        ProdWkshTempl: Code[10];
        ProdWkshName: Code[10];
    begin
        this.ProjectProdOrdersMgmt__GetRequisitionLines(ReqLine, Rec);
        ProdOrderChoice := Enum::"Production Order Status"::"Firm Planned";
        Clear(ProdWkshTempl);
        Clear(ProdWkshName);
        this.OnAfterSetMfgCarrryOutActionFromProdOrderParameters(ReqLine, ProdOrderChoice, ProdWkshTempl, ProdWkshName);

        repeat
            if MfgAction.CarryOutActionsFromProdOrder(ReqLine, ProdOrderChoice, ProdWkshTempl, ProdWkshName, TempDocumentEntry, CerryAction) then ReqLine.Delete(true);
        until ReqLine.Next() = 0;

        Message('%1 production order(s) created.', TempDocumentEntry.Count());
    end;

    /// <summary>
    /// Get the requisition lines from the passed table and copy them to local table.
    /// </summary>
    /// <param name="ReqLine">The requisition line record containing the records to copy.</param>
    /// <param name="ExtReqLine">The external requisition line record to copy from.</param>
    local procedure ProjectProdOrdersMgmt__GetRequisitionLines(var ReqLine: Record "Requisition Line"; var ExtReqLine: Record "Requisition Line")
    begin
        Clear(ReqLine);
        ReqLine.Copy(ExtReqLine, true);
        ReqLine.SetFilter(Quantity, '<>0');
        if ReqLine.FindSet() then;
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