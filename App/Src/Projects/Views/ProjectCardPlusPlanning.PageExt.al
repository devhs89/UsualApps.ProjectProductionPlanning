namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Planning;
using Microsoft.Inventory.Requisition;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Planning;

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
                    TempUnplanDemand: Record "Unplanned Demand" temporary;
                    TempReqLine: Record "Requisition Line" temporary;
                    GetUnplannedDemand: Codeunit "Get Unplanned Demand";
                    ProjProdMgmt: Codeunit ProjectProdOrdersMgmtUAS;
                    Helper: Codeunit ProjectProdPlanningHelperUAS;
                    PlanningPage: Page ProjectProdPlanningUAS;
                begin
                    Clear(TempUnplanDemand);
                    Helper.ProjectProdPlanningHelper__SetDefaultUnplannedDemandFilterGroup(TempUnplanDemand, Rec."No.", 187);
                    GetUnplannedDemand.Run(TempUnplanDemand);

                    TempUnplanDemand.Reset();
                    Helper.ProjectProdPlanningHelper__SetDefaultUnplannedDemandFilterGroup(TempUnplanDemand, Rec."No.", 187);

                    Clear(TempReqLine);
                    Helper.ProjectProdPlanningHelper__TransferUnplannedDemandToRequisitionLine(TempUnplanDemand, TempReqLine, 187);


                    PlanningPage.LookupMode(true);
                    PlanningPage.TransferExternalReqLinesToSourceReqLines(TempReqLine, true);
                    if PlanningPage.RunModal() <> Action::LookupOK then exit;

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
