namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Planning;
using Microsoft.Inventory.Requisition;
using Microsoft.Projects.Project.Job;
using Microsoft.Inventory.Item;

pageextension 71826210 ProjectCardPlusPlanningUAS extends "Job Card"
{
    actions
    {
        addfirst("F&unctions")
        {
            action(ProductionPlanningUAS)
            {
                Caption = 'Create Production Orders';
                ToolTip = 'Create one or more new production orders required by this project, deducting any quantity that is already available.';
                Image = Production;
                ApplicationArea = Jobs;
                trigger OnAction()
                var
                    TempReqLine: Record "Requisition Line" temporary;
                    TempUnplanDemand: Record "Unplanned Demand" temporary;
                    GetUnplannedDemand: Codeunit "Get Unplanned Demand";
                    ProjProdMgmt: Codeunit ProjectProdOrdersMgmtUAS;
                    Helper: Codeunit ProjectProdPlanningHelperUAS;
                    PlanningPage: Page ProjectProdPlanningUAS;
                begin
                    Helper.ProjectProdPlanningHelper__SetJobPlanningCustomFilterGroup(TempUnplanDemand, Rec);
                    GetUnplannedDemand.Run(TempUnplanDemand);

                    Clear(TempReqLine);
                    Helper.ProjectProdPlanningHelper__TransferUnplannedDemandToRequisitionLine(TempReqLine, TempUnplanDemand);

                    Helper.ProjectProdPlanningHelper__SetReqLineFiltersToProdOrder(TempReqLine);

                    PlanningPage.LookupMode(true);
                    PlanningPage.SetReqLinesOnTemporarySource(TempReqLine, true);
                    if PlanningPage.RunModal() <> Action::LookupOK then exit;

                    Helper.ProjectProdPlanningHelper__SetReqLineFiltersFromUnplannedDemand(TempReqLine, TempUnplanDemand, 187);
                    ProjProdMgmt.Run(TempReqLine);
                end;
            }
        }

        addlast(Category_Process)
        {
            actionref(ProductionPlanningUAS_Promoted; ProductionPlanningUAS) { }
            actionref(PurchasePlanningUAS_Promoted; CreatePurchaseOrder) { }
        }
    }
}
