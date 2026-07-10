namespace UsualApps.ProjectProductionPlanning;
using Microsoft.Manufacturing.Document;

pageextension 71826212 ReleasedProdOrdPlusPrjSrcUAS extends "Released Production Order"
{
    actions
    {
        modify(RefreshProductionOrder)
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
