namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Projects.Project.Planning;
using Microsoft.Inventory.Requisition;
using Microsoft.Sales.Document;

page 71826210 ProjectPlanningExtdUAS
{
    Caption = 'Project Planning';
    SourceTable = "Job Planning Line";
    SourceTableTemporary = true;
    DataCaptionFields = "Job No.";
    ApplicationArea = Planning;
    // SourceTable = "Sales Planning Line";
    PageType = List;

    layout
    {
        area(Content)
        {
            field("Job No."; Rec."Job No.")
            {
                ToolTip = 'Specifies the project number.';
            }
            field("Job Task No."; Rec."Job Task No.")
            {
                ToolTip = 'Specifies the project task number.';
            }
            field("Line No."; Rec."Line No.")
            {
                ToolTip = 'Specifies the project line number.';
            }
            field("Job Contract Entry No."; Rec."Job Contract Entry No.")
            {
                ToolTip = 'Specifies the project contract entry number.';
            }
            field("Item No."; Rec."No.")
            {
                ToolTip = 'Specifies the item number.';
            }
            field("Variant Code"; Rec."Variant Code")
            {
                ToolTip = 'Specifies the item variant code.';
            }
            field("Item Description"; Rec.Description)
            {
                ToolTip = 'Specifies the item description.';
            }
            field("item Description 2"; Rec."Description 2")
            {
                ToolTip = 'Specifies the second description of the item.';
            }
            field("Promised Delivery Date"; Rec."Promised Delivery Date")
            {
                ToolTip = 'Specifies the date when the item is promised to be delivered.';
            }
            field("Planned Delivery Date"; Rec."Planned Delivery Date")
            {
                ToolTip = 'Specifies the date when the item is planned to be delivered.';
            }
            field(Status; Rec.Status)
            {
                ToolTip = 'Specifies the status of the project planning line.';
            }
        }
    }

    var
        OP: Page "Order Planning";
}