namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Requisition;
using Microsoft.Projects.Project.Job;

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
                    ReqLine: Record "Requisition Line";
                    ProdMdmt: Codeunit ProjectSourceProdOrderMgmtUAS;
                    ProjProdPage: Page ProjectProdPlanningUAS;
                begin
                    ProjProdPage.SetJob(Rec);
                    ProjProdPage.SetUnplannedDemandLines(ReqLine);
                    ProjProdPage.LookupMode(true);
                    if ProjProdPage.RunModal() <> Action::LookupOK then exit;

                    ProjProdPage.GetRequisitionLines(ReqLine);
                    ReqLine.SetFilter(Quantity, '<>0');
                    if not ReqLine.FindSet() then begin
                        Message('All production requirements for this project have already been planned. No production orders need to be created.');
                        exit;
                    end;

                    ProdMdmt.Run(ReqLine);
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
