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
                    Helper: Codeunit ProjectProdPlanningHelperUAS;
                    ProjProdPage: Page ProjectProdPlanningUAS;
                begin
                    // Set up the requisition line filters to retrieve unplanned demand lines for the current project.
                    ProjProdPage.SetJob(Rec);
                    ProjProdPage.SetUnplannedDemandLines(ReqLine);
                    ProjProdPage.LookupMode(true);
                    if ProjProdPage.RunModal() <> Action::LookupOK then exit;

                    // Retrieve the requisition lines for the current project and set the default filters for processing.
                    ProjProdPage.GetRequisitionLines(ReqLine);
                    Helper.ProjectProdPlanningHelper__SetDefaultReqLineFilters(ReqLine, 187, Rec."No.");
                    Helper.ProjectProdPlanningHelper__SetDefaultReqLineFilters(ReqLine, 0, Rec."No.");
                    ReqLine.SetFilter(Quantity, '<>0');

                    if not ReqLine.FindSet() then begin
                        Message('All production requirements for this project have already been planned. No production orders need to be created.');
                        exit;
                    end;

                    // Call the codeunit to create production orders based on the filtered requisition lines.
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
