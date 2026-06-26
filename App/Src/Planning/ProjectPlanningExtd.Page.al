namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Sales.Document;

page 71826210 ProjectPlanningExtdUAS
{
    Caption = 'Project Planning';
    SourceTable = PlanningProjectLineUAS;
    SourceTableTemporary = true;
    DataCaptionFields = ProjectNo;
    ApplicationArea = Planning;
    PageType = List;

    layout
    {
        area(Content)
        {
            field(ProjectNo; Rec.ProjectNo)
            {
                ToolTip = 'Specifies the project number.';
            }
            field(ProjectDescription; Rec.ProjectDescription)
            {
                ToolTip = 'Specifies the project description.';
            }
            field(ProjectContractEntryNo; Rec.ProjectContractEntryNo)
            {
                ToolTip = 'Specifies the project contract entry number.';
            }
            field(ProjectTaskNo; Rec.ProjectTaskNo)
            {
                ToolTip = 'Specifies the project task number.';
            }
            field(ProjectPlanningLineNo; Rec.ProjectPlanningLineNo)
            {
                ToolTip = 'Specifies the project planning line number.';
            }
            field(ItemNo; Rec.ItemNo)
            {
                ToolTip = 'Specifies the item number.';
            }
            field(VariantCode; Rec.VariantCode)
            {
                ToolTip = 'Specifies the variant code.';
            }
            field(Description; Rec.Description)
            {
                ToolTip = 'Specifies the item description.';
            }
            field(Description2; Rec.Description2)
            {
                ToolTip = 'Specifies the item description 2.';
            }
            field(PlannedDeliveryDate; Rec.PlannedDeliveryDate)
            {
                ToolTip = 'Specifies the planned delivery date.';
            }
            field(ExpectedDeliveryDate; Rec.ExpectedDeliveryDate)
            {
                ToolTip = 'Specifies the expected delivery date.';
            }
            field(QtyAvailable; Rec.QtyAvailable)
            {
                ToolTip = 'Specifies the quantity available.';
            }
            field(NextPlanningDate; Rec.NextPlanningDate)
            {
                ToolTip = 'Specifies the next planning date.';
            }
            field(PlanningStatus; Rec.PlanningStatus)
            {
                ToolTip = 'Specifies the planning status.';
            }
            field(NeedsReplanning; Rec.NeedsReplanning)
            {
                ToolTip = 'Specifies if the planning line needs replanning.';
            }
            field(PlannedQuantity; Rec.PlannedQuantity)
            {
                ToolTip = 'Specifies the planned quantity.';
            }
            field(LowLevelCode; Rec.LowLevelCode)
            {
                ToolTip = 'Specifies the low-level code.';
            }
        }
    }

    var
        _: Record "Sales Planning Line";
        __: Page "Sales Order Planning";
}