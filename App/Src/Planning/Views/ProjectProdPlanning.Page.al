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
    UsageCategory = None;
    DataCaptionExpression = this.SetDataCaption();

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
                field("Order Date"; Rec."Order Date")
                {
                    ToolTip = 'Specifies the date when the order was placed.';
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

    internal procedure SetJob(JobRecord: Record Job)
    begin
        if not this.Job.Get(JobRecord."No.") then Error('Job %1 not found.', JobRecord."No.");
    end;

    internal procedure SetUnplannedDemandLines(var ReqLine: Record "Requisition Line")
    begin
        if not this.IsJobSet() then Error('Job is not set. Please contact your administrator.');
        this.CalculatePlan(ReqLine, this.Job."No.");
        CurrPage.Update(false);
    end;

    internal procedure GetRequisitionLines(var ReqLine: Record "Requisition Line")
    var
        Helper: Codeunit ProjectProdPlanningHelperUAS;
    begin
        Clear(ReqLine);
        Rec.Reset();
        Helper.SetDefaultReqLineFilters(Rec, 0, this.Job."No.");
        if Rec.FindSet() then ReqLine.Copy(Rec);
    end;

    local procedure IsJobSet(): Boolean
    begin
        exit(not this.Job.IsEmpty());
    end;

    local procedure SetDataCaption(): Text
    begin
        exit(this.Job."No." + ' ∙ ' + this.Job.Description);
    end;

    local procedure CalculatePlan(var ReqLine: Record "Requisition Line"; JobNo: Code[20])
    var
        OrderPlanningMgt: Codeunit "Order Planning Mgt.";
        Helper: Codeunit ProjectProdPlanningHelperUAS;
    begin
        Clear(ReqLine);
        Clear(OrderPlanningMgt);
        OrderPlanningMgt.PlanSpecificJob(ReqLine, Rec."No.");

        ReqLine.Reset();
        Helper.SetDefaultReqLineFilters(ReqLine, 0, JobNo);
        Helper.SetDefaultReqLineFilters(ReqLine, 187, JobNo);
        Rec.Copy(ReqLine);
        Rec.FindSet();
    end;

    /// <summary>
    /// Toggles the reserve checkbox on the requisition line records to the specified value.
    /// </summary>
    local procedure ToggleReservation()
    begin
        if Rec.FindSet(true) then
            repeat
                Rec.Validate("Reserve", (not Rec.Reserve));
                Rec.Modify();
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
                Rec.Modify();
            until Rec.Next() = 0;
    end;
}
