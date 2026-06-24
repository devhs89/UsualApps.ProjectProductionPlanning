namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Planning;
using Microsoft.Inventory.Requisition;
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
                    var
                        TempReqLine: Record "Requisition Line" temporary;
                        TempUnplannedDemand: Record "Unplanned Demand" temporary;
                        GetUnplannedDemand: Codeunit "Get Unplanned Demand";
                        OrderPlanPage: Page "Order Planning";
                    begin
                        TempUnplannedDemand.FilterGroup(187);
                        TempUnplannedDemand.SetCurrentKey("Demand Type", "Demand Order No.", PlanningOriginUAS);
                        TempUnplannedDemand.SetRange("Demand Type", "Demand Order Source Type"::"Job Demand");
                        TempUnplannedDemand.SetRange("Demand Order No.", Rec."No.");
                        TempUnplannedDemand.SetRange(PlanningOriginUAS, "Planning Line Origin Type"::JobPlanningLinesUAS);
                        TempUnplannedDemand.FilterGroup(0);
                        GetUnplannedDemand.Run(TempUnplannedDemand);
                        Message(TempUnplannedDemand.Count.ToText());
                        TempReqLine.TransferFromUnplannedDemand(TempUnplannedDemand);
                        Message(TempReqLine.Count.ToText());
                        OrderPlanPage.SetDemandOrderSourceType("Demand Order Source Type"::"Job Demand");
                        OrderPlanPage.SetRecord(TempReqLine);
                        OrderPlanPage.SetTableView(TempReqLine);
                        OrderPlanPage.Run();
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

// If requesting support, please provide the following details to help troubleshooting:

// Error message: 
// An error occurred and the transaction is stopped. Contact your administrator or partner for further assistance.

// The following AL methods are limited during write transactions because one or more tables will be locked: Form.RunModal, Codeunit.Run, Report.RunModal, XmlPort.RunModal.

// Form.RunModal is not allowed in write transactions.

// Codeunit.Run is allowed in write transactions only if the return value is not used. For example, 'OK := Codeunit.Run()' is not allowed.

// Report.RunModal is allowed in write transactions only if 'RequestForm = false'. For example, 'Report.RunModal(...,false)' is allowed.

// XmlPort.RunModal is allowed in write transactions only if 'RequestForm = false'. For example, 'XmlPort.RunModal(...,false)' is allowed.

// Use the commit method to save the changes before this call, or structure the code differently.

// Contact your application developer for further assistance.

// Internal session ID: 
// 417d9097-0144-4829-a3a4-6cb9da9e08ed

// Application Insights session ID: 
// b79577be-5e6f-4356-b1b6-aa3f619c57c9

// Client activity id: 
// d46d8c54-8f50-4681-8569-9adcfff528a2

// Time stamp on error: 
// 2026-04-30T03:45:05.2806150Z

// User telemetry id: 
// 0886d593-affa-4d69-be5d-c8625871314a

// AL call stack: 
// ProjectCardPlusPlanningUAS(PageExtension 71826210)."ProductionPlanningUAS - OnAction"(Trigger) line 16 - App by UsualApps Inc. version 1.0.0.0

