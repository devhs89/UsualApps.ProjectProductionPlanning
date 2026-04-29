namespace UsualApps.ProjectProductionPlanning;
using Microsoft.Projects.Project.Job;

pageextension 71826210 ProjectCardPlusPlanningUAS extends "Job Card"
{
    actions
    {
        addlast(processing)
        {
            group(PlanGroupUAS)
            {
                Caption = 'Planning';
                Description = 'Planning actions for project.';
                action(ProductionPlanningUAS)
                {
                    Caption = 'Production Planning';
                    ToolTip = 'Plan for production demand.';
                    Image = Production;
                    ApplicationArea = Jobs;
                    trigger OnAction()
                    begin
                        Message('');
                    end;
                }
                action(PurchasePlanningUAS)
                {
                    Caption = 'Purchase Planning';
                    ToolTip = 'Plan for purchase demand.';
                    Image = Purchase;
                    ApplicationArea = Jobs;
                    trigger OnAction()
                    var
                        PurchaseDocFromJob: Codeunit "Purchase Doc. From Job";
                    begin
                        PurchaseDocFromJob.CreatePurchaseOrder(Rec);
                    end;
                }
            }
        }
    }
}