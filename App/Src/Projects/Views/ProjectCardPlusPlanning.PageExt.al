namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Planning;
using Microsoft.Inventory.Requisition;
using Microsoft.Projects.Project.Job;
using Microsoft.Manufacturing.Document;

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
                    ReqTemplName: Record "Req. Wksh. Template";
                    WhkshName: Record "Requisition Wksh. Name";
                    GetUnplannedDemand: Codeunit "Get Unplanned Demand";
                    ProjProdMgmt: Codeunit ProjectProdOrdersMgmt;
                    Helper: Codeunit ProjectProdPlanningHelper;
                    PlanningPage: Page ProjectProdPlanningUAS;
                begin
                    Helper.ProjectProdPlanningHelper__SetJobPlanningCustomFilterGroup(TempUnplanDemand, Rec);
                    GetUnplannedDemand.Run(TempUnplanDemand);

                    Clear(TempReqLine);
                    Helper.ProjectProdPlanningHelper__TransferUnplannedDemandToRequisitionLine(TempReqLine, TempUnplanDemand);

                    Helper.ProjectProdPlanningHelper__SetReqLineFiltersToProdOrder(TempReqLine);

                    PlanningPage.LookupMode(true);
                    PlanningPage.CopyRecords(TempReqLine);
                    if PlanningPage.RunModal() <> Action::LookupOK then exit;

                    ProjProdMgmt.ProjectProdOrdersMgmt__SetProductionOrderStatus(Enum::"Production Order Status"::"Firm Planned");

                    ReqTemplName.SetFilter(Type, '%1|%2', "Req. Worksheet Template Type"::"Req.", "Req. Worksheet Template Type"::Planning);
                    if not ReqTemplName.FindFirst() then begin
                        Clear(ReqTemplName);
                        if ReqTemplName.FindFirst() then;
                    end;
                    ProjProdMgmt.ProjectProdOrdersMgmt__SetProductionTemplateName(ReqTemplName.Name);

                    if WhkshName.FindFirst() then;
                    ProjProdMgmt.ProjectProdOrdersMgmt__SetProductionWorksheetName(WhkshName.Name);

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
