namespace UsualApps.ProjectProductionPlanning;
using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.Document;

codeunit 71826212 ProjSourceProdOrderEventsUAS
{
    [IntegrationEvent(false, false)]
    internal procedure OnProjectSourceProdOrderOnBeforeStopRefresh(var ProdOrder: Record "Production Order"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnProjectSourceProdOrderMgmtOnAfterSetProdOrderParameters(var ReqLine: Record "Requisition Line"; DemandNo: Code[20]; ProdOrderChoice: Enum "Planning Create Prod. Order")
    begin
    end;
}