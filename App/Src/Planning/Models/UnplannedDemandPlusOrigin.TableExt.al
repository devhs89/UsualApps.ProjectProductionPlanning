namespace UsualApps.ProjectProductionPlanning;
using Microsoft.Inventory.Planning;

tableextension 71826210 UnplannedDemandPlusOriginUAS extends "Unplanned Demand"
{
    AllowInCustomizations = Never;

    fields
    {
        field(71826210; PlanningOriginUAS; Enum "Planning Line Origin Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Planning Origin';
            ToolTip = 'Indicates the origin of the planning line that generated this unplanned demand.';
        }
    }
}