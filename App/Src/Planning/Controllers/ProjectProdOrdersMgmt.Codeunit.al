namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Foundation.Navigate;
using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.Document;

codeunit 71826212 ProjectProdOrdersMgmt
{
    TableNo = "Requisition Line";

    trigger OnRun()
    var
        TempReqLine: Record "Requisition Line" temporary;
        CerryAction: Codeunit "Carry Out Action";
        MfgAction: Codeunit "Mfg. Carry Out Action";
    begin
        TempReqLine.Copy(Rec, true);
        if TempReqLine.FindSet() then;
        repeat
            if MfgAction.CarryOutActionsFromProdOrder(TempReqLine, this.ProdOrderChoice, this.ProdWkshTempl, this.ProdWkshName, this.TempDocumentEntry, CerryAction) then Message('Success');
        until TempReqLine.Next() = 0;
    end;

    var
        TempDocumentEntry: Record "Document Entry" temporary;
        ProdOrderChoice: Enum "Planning Create Prod. Order";
        ProdWkshTempl: Code[10];
        ProdWkshName: Code[10];

    internal procedure ProjectProdOrdersMgmt__SetProductionOrderStatus(ProdStatus: Enum "Production Order Status")
    begin
        this.ProdOrderChoice := ProdStatus
    end;

    internal procedure ProjectProdOrdersMgmt__SetProductionTemplateName(TemplateName: Code[10])
    begin
        this.ProdWkshTempl := TemplateName;
    end;

    internal procedure ProjectProdOrdersMgmt__SetProductionWorksheetName(WorksheetName: Code[10])
    begin
        this.ProdWkshName := WorksheetName;
    end;
}