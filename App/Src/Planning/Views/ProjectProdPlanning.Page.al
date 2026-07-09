namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;

page 71826210 ProjectProdPlanningUAS
{
    Caption = 'Create Project Production Orders';
    SourceTable = "Requisition Line";
    SourceTableTemporary = true;
    ApplicationArea = Planning;
    PageType = Worksheet;
    InsertAllowed = false;
    Extensible = true;
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
            action(ViewItemCardUAS)
            {
                Caption = 'Item Card';
                ToolTip = 'Opens the item card for the selected item.';
                Image = Item;
                Promoted = true;
                PromotedCategory = Category4;
                RunObject = page "Item Card";
                RunPageLink = "No." = field("No.");
                RunPageView = sorting("No.");
                RunPageMode = View;
            }
            action(ViewProductionBomUAS)
            {
                Caption = 'Production BOM';
                ToolTip = 'Opens the production BOM for the selected item.';
                Image = BOM;
                Promoted = true;
                PromotedCategory = Category4;
                trigger OnAction()
                var
                    Item: Record Item;
                    Bom: Record "Production BOM Header";
                    BomPage: Page "Production BOM";
                begin
                    if not Item.Get(Rec."No.") then exit;
                    if Item."Production BOM No." = '' then exit;
                    Bom.SetRange("No.", Item."Production BOM No.");
                    if not Bom.FindFirst() then Message('No production BOM found for item %1.', Rec."No.");
                    BomPage.SetRecord(Bom);
                    BomPage.Editable(false);
                    BomPage.Run();
                end;
            }
            action(ViewRoutingUAS)
            {
                Caption = 'Routing';
                ToolTip = 'Opens the routing for the selected item.';
                Image = Route;
                Promoted = true;
                PromotedCategory = Category4;
                trigger OnAction()
                var
                    Item: Record Item;
                    Route: Record "Routing Header";
                    RoutePage: Page Routing;
                begin
                    if not Item.Get(Rec."No.") then exit;
                    if Item."Routing No." = '' then exit;
                    Route.SetRange("No.", Item."Routing No.");
                    if not Route.FindFirst() then Message('No routing found for item %1.', Rec."No.");
                    RoutePage.SetRecord(Route);
                    RoutePage.Editable(false);
                    RoutePage.Run();
                end;
            }
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

    trigger OnInit()
    begin
        if Rec.FindSet() then;
    end;

    trigger OnOpenPage()
    var
        NoRecNotify: Notification;
        LabelTxt: Label 'All items for the project are available.';
    begin
        if Rec.Count = 0 then begin
            NoRecNotify.Scope := NotificationScope::LocalScope;
            NoRecNotify.Message(LabelTxt);
            NoRecNotify.Send();
        end;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.Delete(false);
        CurrPage.Update(false);
        exit(false);
    end;

    /// <summary>
    /// Copy the requisition lines from one record to another.
    /// </summary>
    /// <param name="ReqLine">The requisition line record containing the records to copy.</param>
    /// <param name="ShareTable">Indicates whether to share the temporary table.</param>
    internal procedure TransferExternalReqLinesToSourceReqLines(var ReqLine: Record "Requisition Line"; ShareTable: Boolean)
    var
        Helper: Codeunit ProjectProdPlanningHelperUAS;
    begin
        Clear(Rec);
        Helper.ProjectProdPlanningHelper__CopyProdOrderReqLinesOver(ReqLine, Rec, 0, true);
        Rec.Reset();
        Helper.ProjectProdPlanningHelper__CopyRequisuitionFilters(ReqLine, Rec, 187, 0);
        Helper.ProjectProdPlanningHelper__CopyRequisuitionFilters(ReqLine, Rec, 187, 187);
        Rec.SetRange("Replenishment System", Rec."Replenishment System"::"Prod. Order");
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
