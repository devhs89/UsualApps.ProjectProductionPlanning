namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Item;
using Microsoft.Projects.Project.Planning;

table 71826210 PlanningProjectLineUAS
{
    DataClassification = CustomerContent;
    DataCaptionFields = ProjectNo, ProjectTaskNo, ProjectPlanningLineNo;
    AllowInCustomizations = Never;

    fields
    {
        field(10; ProjectNo; Code[20])
        {
            Caption = 'Project No.';
            TableRelation = "Job Planning Line"."Job No." where(Status = filter('Order'));
        }
        field(11; ProjectContratEntryNo; Integer)
        {
            Caption = 'Proj. Contract Entry No.';
            TableRelation = "Job Planning Line"."Job Contract Entry No." where(Status = const(Order), "Job No." = field(ProjectNo));
        }
        field(12; ProjectTaskNo; Code[20])
        {
            Caption = 'Proj. Task No.';
            TableRelation = "Job Planning Line"."Job Task No." where(Status = filter('Order'), "Job No." = field(ProjectNo));
        }
        field(13; ProjectPlanningLineNo; Integer)
        {
            Caption = 'Proj. Planning Line No.';
            TableRelation = "Job Planning Line"."Line No." where(Status = const(Order), "Job No." = field(ProjectNo), "Job Task No." = field(ProjectTaskNo));
        }
        field(14; ItemNo; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                Item.Get(ItemNo);
                LowLevelCode := Item."Low-Level Code";
            end;
        }
        field(15; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(16; PlannedDeliveryDate; Date)
        {
            Caption = 'Planned Delivery Date';
        }
        field(17; QtyAvailable; Decimal)
        {
            Caption = 'Qty. Available';
            DecimalPlaces = 0 : 5;
        }
        field(18; NextPlanningDate; Date)
        {
            Caption = 'Next Planning Date';
        }
        field(19; ExpectedDeliveryDate; Date)
        {
            Caption = 'Expected Delivery Date';
        }
        field(20; PlanningStatus; Option)
        {
            Caption = 'Planning Status';
            OptionCaption = 'None,Simulated,Planned,Firm Planned,Released,Inventory';
            OptionMembers = "None",Simulated,Planned,"Firm Planned",Released,Inventory;
        }
        field(21; NeedsReplanning; Boolean)
        {
            Caption = 'Needs Replanning';
        }
        field(22; VariantCode; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field(ItemNo), Code = field(VariantCode));
        }
        field(23; PlannedQuantity; Decimal)
        {
            Caption = 'Planned Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(24; LowLevelCode; Integer)
        {
            Caption = 'Low-Level Code';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; ProjectNo, ProjectContratEntryNo)
        {
            Clustered = true;
        }
        key(Key2; LowLevelCode)
        {
        }
    }

    fieldgroups
    {
    }
}