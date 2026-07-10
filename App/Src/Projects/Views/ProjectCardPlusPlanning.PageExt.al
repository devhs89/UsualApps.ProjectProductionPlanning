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
                    TempReqLine: Record "Requisition Line" temporary;
                    MfgTemp: Record "Manufacturing User Template";
                    MakeSupply: Codeunit "Make Supply Orders (Yes/No)";
                    Helper: Codeunit ProjectProdPlanningHelperUAS;
                    ProjProdPage: Page ProjectProdPlanningUAS;
                begin
                    ProjProdPage.SetUnplannedDemandLines(Rec."No.");
                    ProjProdPage.LookupMode(true);
                    if ProjProdPage.RunModal() <> Action::LookupOK then exit;

                    ProjProdPage.GetTemporaryRequisitionLine(TempReqLine);

                    Clear(MfgTemp);
                    if MfgTemp.Get(UserId) then begin
                        Helper.InitializeManufacturingUserTemplate(MfgTemp, CopyStr(UserId, 1, 50));
                        MfgTemp.Modify(true);
                    end else begin
                        Helper.InitializeManufacturingUserTemplate(MfgTemp, CopyStr(UserId, 1, 50));
                        MfgTemp.Insert(true);
                    end;

                    MakeSupply.SetManufUserTemplate(MfgTemp);
                    MakeSupply.SetBlockForm();
                    MakeSupply.Run(TempReqLine);
                    if MakeSupply.ActionMsgCarriedOut() then Message('Production orders have been created for the project.');
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
