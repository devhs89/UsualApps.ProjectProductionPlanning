namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;
using Microsoft.Projects.Project.Job;

page 71826210 ProjectProdPlanningUAS
{
    ApplicationArea = Planning;
    Caption = 'Project Planning';
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Requisition Line";
    SourceTableTemporary = true;
    UsageCategory = None;

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

    var
        Job: Record Job;

    internal procedure SetUnplannedDemandLines(JobNo: Code[20])
    begin
        if not this.Job.Get(JobNo) then Error('Job %1 not found.', JobNo);
        this.CalculatePlan(this.Job."No.");
        CurrPage.Update(false);
    end;

    internal procedure GetTemporaryRequisitionLine(var ReqLine: Record "Requisition Line")
    var
        Helper: Codeunit ProjectProdPlanningHelperUAS;
    begin
        Clear(ReqLine);
        Rec.Reset();
        Helper.SetDefaultReqLineFilters(Rec, 0, this.Job."No.", true);
        if Rec.FindSet() then ReqLine.Copy(Rec, true);
    end;

    local procedure CalculatePlan(JobNo: Code[20])
    var
        ReqLine: Record "Requisition Line";
        OrderPlanningMgt: Codeunit "Order Planning Mgt.";
        DemandOrderFilter: Enum "Demand Order Source Type";
    begin
        Rec.Reset();
        Rec.DeleteAll();

        DemandOrderFilter := DemandOrderFilter::"Job Demand";

        Clear(OrderPlanningMgt);
        OrderPlanningMgt.SetDemandType(DemandOrderFilter);
        OrderPlanningMgt.GetOrdersToPlan(ReqLine);

        this.SetTemporaryRequisitionLine(JobNo);
    end;

    local procedure SetTemporaryRequisitionLine(JobNo: Code[20])
    var
        ReqLine: Record "Requisition Line";
        Helper: Codeunit ProjectProdPlanningHelperUAS;
    begin
        Rec.DeleteAll();
        ReqLine.Reset();
        Helper.SetDefaultReqLineFilters(ReqLine, 0, JobNo, false);

        if ReqLine.FindSet() then
            repeat
                Rec := ReqLine;
                Rec.Insert();
            until ReqLine.Next() = 0;

        Rec.Reset();
        Helper.SetDefaultReqLineFilters(Rec, 0, JobNo, false);
        Helper.SetDefaultReqLineFilters(Rec, 187, JobNo, false);
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
