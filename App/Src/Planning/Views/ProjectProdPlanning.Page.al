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
                field(DemandTaskNo; this.DemandTaskNo)
                {
                    Caption = 'Demand Task No.';
                    ToolTip = 'Specifies the job task number.';
                }
                field(DemandLineNo; this.DemandLineNo)
                {
                    Caption = 'Demand Line No.';
                    ToolTip = 'Specifies the job planning line number.';
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
        area(Creation)
        {
            action(DeleteLine)
            {
                Caption = 'Delete Line';
                ToolTip = 'Deletes the selected line from the list.';
                Image = DeleteRow;
                trigger OnAction()
                begin
                    this.DeleteRecord(Rec);
                end;
            }
        }
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
                var
                    Helper: Codeunit ProjectProdPlanningHelperUAS;
                begin
                    Helper.ProjectProdPlanningHelper__ToggleReserveCheckbox(Rec);
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
                var
                    Helper: Codeunit ProjectProdPlanningHelperUAS;
                begin
                    Helper.ProjectProdPlanningHelper__ToggleRequisitionLineQuantity(Rec);
                end;
            }
        }
    }

    var
        DemandTaskNo: Code[20];
        DemandLineNo: Integer;

    trigger OnAfterGetRecord()
    begin
        this.SetJobDetails();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        this.SetJobDetails();
    end;

    /// <summary>
    /// Sets the job task number and job planning line number for the current record based on the demand order number and demand line number.
    /// </summary>
    internal procedure SetJobDetails()
    var
        JobPlanLine: Record "Job Planning Line";
    begin
        JobPlanLine.SetCurrentKey("Job No.", "Job Contract Entry No.");
        JobPlanLine.SetRange("Job No.", Rec."Demand Order No.");
        JobPlanLine.SetRange("Job Contract Entry No.", Rec."Demand Line No.");
        if not JobPlanLine.FindFirst() then exit;
        this.DemandTaskNo := JobPlanLine."Job Task No.";
        this.DemandLineNo := JobPlanLine."Line No.";
    end;

    /// <summary>
    /// Copies the records from the requisition line table to the page's source table.
    /// </summary>
    /// <param name="ReqLine">The requisition line record containing the records to copy.</param>
    /// <param name="ShareTempTable">Indicates whether to share the temporary table.</param>
    internal procedure SetReqLinesOnTemporarySource(var ReqLine: Record "Requisition Line"; ShareTempTable: Boolean)
    begin
        Clear(Rec);
        Rec.Copy(ReqLine, ShareTempTable);
    end;

    local procedure DeleteRecord(CurrReqLine: Record "Requisition Line")
    var
        ReqLine: Record "Requisition Line";
    begin
        Clear(ReqLine);
        ReqLine.Copy(CurrReqLine);
        ReqLine.SetCurrentKey("User ID", "Demand Type", "Worksheet Template Name", "Journal Batch Name", "Line No.", Type, "No.");
        ReqLine.SetRecFilter();
        if ReqLine.Count() > 0 then ReqLine.Delete(true) else Clear(CurrReqLine);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.Delete(false);
        CurrPage.Update(false);
        exit(false);
    end;
}
