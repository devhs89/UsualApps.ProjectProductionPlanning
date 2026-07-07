namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Requisition;
using Microsoft.Projects.Project.Planning;

page 71826210 ProjectProdPlanningUAS
{
    Caption = 'Create Project Production Orders';
    SourceTable = "Requisition Line";
    SourceTableTemporary = true;
    ApplicationArea = Planning;
    PageType = Worksheet;
    InsertAllowed = false;
    PromotedActionCategories = 'New,Process,Report,Home,Others';

    layout
    {
        area(Content)
        {
            repeater(Main)
            {
                field("Due Date"; Rec."Due Date")
                {
                    ToolTip = 'Specifies the date when the order is due.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the status of the demand.';
                    Visible = false;
                }
                field("Demand Date"; Rec."Demand Date")
                {
                    ToolTip = 'Specifies the date when the demand order line is required.';
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
                    Visible = false;
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
                    Visible = false;
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
                    Visible = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the unit of measure code.';
                }
                field("Unit Of Measure Code (Demand)"; Rec."Unit Of Measure Code (Demand)")
                {
                    ToolTip = 'Specifies the unit of measure code for the demand quantity.';
                    Visible = false;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ToolTip = 'Specifies the date when the order was placed.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ToggleReservationUAS)
            {
                Caption = 'Toggle Reservation';
                ToolTip = 'Toggles the reserve checkbox on the requisition line records.';
                Image = LineReserve;
                Promoted = true;
                PromotedCategory = Category5;
                trigger OnAction()
                begin
                    this.ToggleReservation();
                end;
            }
            action(ToggleSupplyQuantitiesUAS)
            {
                Caption = 'Toggle Supply Quantities';
                ToolTip = 'Toggles the quantity of the requisition line records between the needed quantity and zero.';
                Image = AutofillQtyToHandle;
                Promoted = true;
                PromotedCategory = Category5;
                trigger OnAction()
                begin
                    this.ToggleRequisitionLineQuantity();
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.Delete(false);
        CurrPage.Update(false);
        exit(false);
    end;

    /// <summary>
    /// Copies the records from the requisition line table to the page's source table.
    /// </summary>
    /// <param name="ReqLine">The requisition line record containing the records to copy.</param>
    /// <param name="ShareTempTable">Indicates whether to share the temporary table.</param>
    internal procedure SetReqLinesOnTemporarySource(var ReqLine: Record "Requisition Line"; ShareTempTable: Boolean)
    var
        Helper: Codeunit ProjectProdPlanningHelperUAS;
    begin
        ReqLine.Reset();
        if not ReqLine.FindSet() then Error('No records found to display on the page.');
        repeat
            if ReqLine."Replenishment System" <> ReqLine."Replenishment System"::"Prod. Order" then continue;
            Rec.TransferFields(ReqLine);
            if Rec.Insert(false) then;
        until ReqLine.Next() = 0;
        Rec.Reset();
        Helper.ProjectProdPlanningHelper__SetDefaultReqLineFilterGroup(Rec, 0, Database::"Job Planning Line", Rec."Demand Order No.");
        Helper.ProjectProdPlanningHelper__SetDefaultReqLineFilterGroup(Rec, 187, Database::"Job Planning Line", Rec."Demand Order No.");
    end;

    /// <summary>
    /// Toggles the reserve checkbox on the requisition line records to the specified value.
    /// </summary>
    local procedure ToggleReservation()
    begin
        if Rec.FindSet(true) then
            repeat
                Rec.Validate("Reserve", (not Rec.Reserve));
                if Rec.Modify(true) then;
            until Rec.Next() = 0;
    end;

    /// <summary>
    /// Toggles the quantity of the requisition line records between the needed quantity and zero.
    /// </summary>
    local procedure ToggleRequisitionLineQuantity()
    begin
        if Rec.FindSet(true) then
            repeat
                Rec.Validate(Quantity, (Rec.Quantity = 0 ? Rec."Needed Quantity" : 0));
                if Rec.Modify(true) then;
            until Rec.Next() = 0;
    end;
}
