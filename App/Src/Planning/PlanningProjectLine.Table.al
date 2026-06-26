namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Item;
using Microsoft.Projects.Project.Job;
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
        field(11; ProjectDescription; Text[100])
        {
            Caption = 'Project Description';
            TableRelation = Job."Description" where(Status = filter('Order'), "No." = field(ProjectNo));
        }

        field(12; ProjectContractEntryNo; Integer)
        {
            Caption = 'Proj. Contract Entry No.';
            TableRelation = "Job Planning Line"."Job Contract Entry No." where(Status = const(Order), "Job No." = field(ProjectNo));
        }
        field(13; ProjectTaskNo; Code[20])
        {
            Caption = 'Proj. Task No.';
            TableRelation = "Job Planning Line"."Job Task No." where(Status = filter('Order'), "Job No." = field(ProjectNo));
        }
        field(14; ProjectPlanningLineNo; Integer)
        {
            Caption = 'Proj. Planning Line No.';
            TableRelation = "Job Planning Line"."Line No." where(Status = const(Order), "Job No." = field(ProjectNo), "Job Task No." = field(ProjectTaskNo));
        }
        field(15; ItemNo; Code[20])
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
        field(16; VariantCode; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field(ItemNo), Code = field(VariantCode));
        }
        field(17; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(18; Description2; Text[100])
        {
            Caption = 'Description 2';
        }
        field(19; PlannedDeliveryDate; Date)
        {
            Caption = 'Planned Delivery Date';
        }
        field(20; ExpectedDeliveryDate; Date)
        {
            Caption = 'Expected Delivery Date';
        }
        field(21; QtyAvailable; Decimal)
        {
            Caption = 'Qty. Available';
            DecimalPlaces = 0 : 5;
        }
        field(22; NextPlanningDate; Date)
        {
            Caption = 'Next Planning Date';
        }
        field(23; PlanningStatus; Option)
        {
            Caption = 'Planning Status';
            OptionCaption = 'None,Simulated,Planned,Firm Planned,Released,Inventory';
            OptionMembers = "None",Simulated,Planned,"Firm Planned",Released,Inventory;
        }
        field(24; NeedsReplanning; Boolean)
        {
            Caption = 'Needs Replanning';
        }
        field(25; PlannedQuantity; Decimal)
        {
            Caption = 'Planned Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(26; LowLevelCode; Integer)
        {
            Caption = 'Low-Level Code';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; ProjectNo, ProjectContractEntryNo)
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