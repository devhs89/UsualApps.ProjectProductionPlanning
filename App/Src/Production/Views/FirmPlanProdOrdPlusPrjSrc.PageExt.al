namespace UsualApps.ProjectProductionPlanning;
using Microsoft.Manufacturing.Document;

pageextension 71826211 FirmPlanProdOrdPlusPrjSrcUAS extends "Firm Planned Prod. Order"
{
    actions
    {
        modify("Re&fresh Production Order")
        {
            trigger OnBeforeAction()
            var
                Helper: Codeunit ProjectProdPlanningHelperUAS;
            begin
                Helper.ProjectProdPlanningHelper__StopRefreshProjectSourceProductionOrder(Rec);
            end;
        }
    }
}
