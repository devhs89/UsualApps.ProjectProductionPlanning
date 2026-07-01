namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Requisition;

page 71826210 ProjectProdPlanningUAS
{
    Caption = 'Create Project Production Orders';
    SourceTable = "Requisition Line";
    SourceTableTemporary = true;
    ApplicationArea = Planning;
    PageType = Worksheet;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Main)
            {
                field("Demand Date"; Rec."Demand Date")
                {
                    ToolTip = 'Specifies the date when the demand order line is required.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the status of the demand.';
                    Visible = false;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the item number.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the variant code.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the item description.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the location code.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ToolTip = 'Specifies the bin code.';
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ToolTip = 'Specifies the direct unit cost.';
                }
                field(Reserve; Rec.Reserve)
                {
                    ToolTip = 'Specifies the reserve status.';
                }
                field("Demand Quantity"; Rec."Demand Quantity")
                {
                    ToolTip = 'Specifies the demand quantity.';
                }
                field("Demand Qty. Available"; Rec."Demand Qty. Available")
                {
                    ToolTip = 'Specifies the available demand quantity.';
                }
                field("Needed Quantity"; Rec."Needed Quantity")
                {
                    ToolTip = 'Specifies the needed quantity.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the quantity to order';
                }
                field("Reserved Quantity"; Rec."Reserved Quantity")
                {
                    ToolTip = 'Specifies the reserved quantity.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the unit of measure code.';
                }
                field("Unit Of Measure Code (Demand)"; Rec."Unit Of Measure Code (Demand)")
                {
                    ToolTip = 'Specifies the unit of measure code for the demand quantity.';
                }
                field("Order Date"; Rec."Order Date")
                {
                    ToolTip = 'Specifies the date when the order was placed.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ToolTip = 'Specifies the date when the order is due.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(AutofillProdQuantitiesUAS)
            {
                Caption = 'Autofill Prod. Quantities';
                ToolTip = 'Autofills the production quantities for all demand lines.';
                Image = AutofillQtyToHandle;
                trigger OnAction()
                var
                    TempReqLine: Record "Requisition Line" temporary;
                begin
                    TempReqLine.Copy(Rec, true);
                    if TempReqLine.FindSet() then;
                    repeat
                        TempReqLine.Validate(Quantity, TempReqLine."Needed Quantity");
                        if TempReqLine.Modify(false) then;
                    until TempReqLine.Next() = 0;
                end;
            }

            action(DeleteProdQuantitiesUAS)
            {
                Caption = 'Delete Prod. Quantities';
                ToolTip = 'Autofills the production quantities for all demand lines.';
                Image = DeleteQtyToHandle;
                trigger OnAction()
                var
                    TempReqLine: Record "Requisition Line" temporary;
                begin
                    TempReqLine.Copy(Rec, true);
                    if TempReqLine.FindSet() then;
                    repeat
                        TempReqLine.Validate(Quantity, 0);
                        if TempReqLine.Modify(false) then;
                    until TempReqLine.Next() = 0;
                end;
            }
        }
    }

    /// <summary>
    /// Copies the records from the temporary requisition line table to the page's source table.
    /// </summary>
    /// <param name="TempReqLine">The temporary requisition line record containing the records to copy.</param>
    internal procedure CopyRecords(var TempReqLine: Record "Requisition Line" temporary)
    begin
        Rec.Copy(TempReqLine, true);
    end;
}
