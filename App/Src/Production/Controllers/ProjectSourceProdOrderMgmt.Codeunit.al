namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Setup;
using Microsoft.Projects.Project.Job;

codeunit 71826211 ProjectSourceProdOrderMgmtUAS
{
    TableNo = "Requisition Line";

    trigger OnRun()
    var
        ProdOrder: Record "Production Order";
        Job: Record Job;
        Helper: Codeunit ProjectProdPlanningHelperUAS;
        ProdOrderChoice: Enum "Planning Create Prod. Order";
        DemandNo: Code[20];
        CreatedProdOrders: TextBuilder;
        ModifiedProdOrders: TextBuilder;
        MessageLabelTxt: TextBuilder;
        NoDemandLinesLabelTxt: Label 'No demand lines to process.';
        CreatedProdOrderLabelTxt: Label 'Production Order(s) created:\%1', Comment = '%1 = List of production order numbers created';
        ModifiedProdOrderLabelTxt: Label 'Production Orders modified:\%1', Comment = '%1 = List of production order numbers modified';
    begin
        if not Rec.FindSet() then begin
            Message(NoDemandLinesLabelTxt);
            exit;
        end;

        // Retrieve the demand order number from the requisition line using the helper function.
        DemandNo := Helper.ProjectProdPlanningHelper__GetDemandNoFromFilterGroup(Rec, 187);

        // Validate the requisition line and ensure that the associated job exists.
        if not Job.Get(DemandNo) then Error('Job %1 not found.', DemandNo);

        Clear(ProdOrder);
        ProdOrderChoice := Enum::"Production Order Status"::"Firm Planned";

        this.OnProjectSourceProdOrderMgmtOnAfterSetProdOrderParameters(Rec, DemandNo, ProdOrderChoice);

        repeat
            if this.ProjectProdOrdersMgmt__ProductionHeaderExists(Rec, ProdOrderChoice, ProdOrder) then begin
                if this.ProjectSourceProdOrderMgmt__CreateProductionOrderLine(Rec, ProdOrder) then
                    if (Text.StrPos(CreatedProdOrders.ToText(), ProdOrder."No.") = 0) and (Text.StrPos(ModifiedProdOrders.ToText(), ProdOrder."No.") = 0) then
                        ModifiedProdOrders.AppendLine(ProdOrder."No.");
            end else
                if this.ProjectSourceProdOrderMgmt__CreateProjectProductionOrderHeader(Rec, ProdOrder, ProdOrderChoice, Job) then begin
                    this.ProjectSourceProdOrderMgmt__CreateProductionOrderLine(Rec, ProdOrder);
                    if (Text.StrPos(CreatedProdOrders.ToText(), ProdOrder."No.") = 0) then CreatedProdOrders.AppendLine(ProdOrder."No.");
                end;
        until Rec.Next() = 0;

        if CreatedProdOrders.Length() > 0 then MessageLabelTxt.AppendLine(StrSubstNo(CreatedProdOrderLabelTxt, CreatedProdOrders));
        if ModifiedProdOrders.Length() > 0 then MessageLabelTxt.AppendLine(StrSubstNo(ModifiedProdOrderLabelTxt, ModifiedProdOrders));
        Message(MessageLabelTxt.ToText());
    end;

    /// <summary>
    /// Checks if a production order header exists for the given requisition line and production order choice.
    /// </summary>
    /// <param name="ReqLine">The requisition line record to check for an existing production order header.</param>
    /// <param name="ProdOrderChoice">The choice of production order status (Planned, Firm Planned, etc.) to filter the search.</param>
    /// <param name="ProdOrder">The production order record to populate if an existing header is found.</param>
    internal procedure ProjectProdOrdersMgmt__ProductionHeaderExists(var ReqLine: Record "Requisition Line"; ProdOrderChoice: Enum "Planning Create Prod. Order"; var ProdOrder: Record "Production Order"): Boolean
    begin
        ProdOrder.SetCurrentKey(Status, "Source Type", "Source No.");

        case ProdOrderChoice of
            ProdOrderChoice::Planned:
                ProdOrder.SetRange(Status, "Production Order Status"::Planned);
            ProdOrderChoice::"Firm Planned", ProdOrderChoice::"Firm Planned & Print":
                ProdOrder.SetRange(Status, "Production Order Status"::"Firm Planned");
            else
                exit;
        end;
        ProdOrder.SetRange("Source Type", "Prod. Order Source Type"::ProjectHeaderUAS);
        ProdOrder.SetRange("Source No.", ReqLine."Demand Order No.");
        exit(ProdOrder.FindFirst());
    end;

    /// <summary>
    /// Inserts a new project production order header record based on the provided requisition line and production order choice.
    /// </summary>
    /// <param name="ReqLine">The requisition line record associated with the production order.</param>
    /// <param name="ProdOrder">The production order record to insert.</param>
    /// <param name="ProdOrderChoice">The choice of production order status (Planned, Firm Planned, etc.).</param>
    /// <returns>True if the production order header was successfully created; otherwise, false.</returns>
    internal procedure ProjectSourceProdOrderMgmt__CreateProjectProductionOrderHeader(var ReqLine: Record "Requisition Line"; var ProdOrder: Record "Production Order"; ProdOrderChoice: Enum "Planning Create Prod. Order"; Job: Record Job): Boolean
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        // Check if the manufacturing setup is configured correctly for the specified production order choice.
        if not ManufacturingSetup.Get() then Error('Manufacturing Setup not found.');
        case ProdOrderChoice of
            ProdOrderChoice::Planned:
                ManufacturingSetup.TestField("Planned Order Nos.");
            ProdOrderChoice::"Firm Planned",
            ProdOrderChoice::"Firm Planned & Print":
                ManufacturingSetup.TestField("Firm Planned Order Nos.");
            else
                Error('Invalid production order choice: %1', ProdOrderChoice);
        end;

        // Initialize the production order record and set the appropriate status based on the production order choice.
        Clear(ProdOrder);
        ProdOrder.Init();

        case ProdOrderChoice of
            ProdOrderChoice::Planned:
                ProdOrder.Status := "Production Order Status"::Planned;
            ProdOrderChoice::"Firm Planned", ProdOrderChoice::"Firm Planned & Print":
                ProdOrder.Status := "Production Order Status"::"Firm Planned";
            else
                Error('Invalid production order choice: %1', ProdOrderChoice);
        end;

        ProdOrder."No. Series" := ProdOrder.GetNoSeriesCode();
        if ProdOrder."No. Series" = ReqLine."No. Series" then ProdOrder."No." := ReqLine."Ref. Order No.";
        ProdOrder.Insert(true);
        ProdOrder."Source Type" := ProdOrder."Source Type"::ProjectHeaderUAS;
        ProdOrder."Source No." := Job."No.";
        ProdOrder.Validate(Description, Job.Description);
        ProdOrder."Description 2" := Job."Description 2";
        Clear(ProdOrder."Variant Code");
        ProdOrder."Creation Date" := Today;
        ProdOrder."Last Date Modified" := Today;
        Clear(ProdOrder."Inventory Posting Group");
        Clear(ProdOrder."Gen. Prod. Posting Group");
        ProdOrder."Due Date" := ReqLine."Due Date";
        ProdOrder."Starting Time" := ReqLine."Starting Time";
        ProdOrder."Starting Date" := ReqLine."Starting Date";
        ProdOrder."Ending Time" := ReqLine."Ending Time";
        ProdOrder."Ending Date" := ReqLine."Ending Date";
        ProdOrder."Location Code" := Job."Location Code";
        ProdOrder."Bin Code" := Job."Bin Code";
        ProdOrder."Low-Level Code" := ReqLine."Low-Level Code";
        Clear(ProdOrder."Routing No.");
        ProdOrder.Quantity := 1;
        Clear(ProdOrder."Unit Cost");
        Clear(ProdOrder."Cost Amount");
        ProdOrder."Shortcut Dimension 1 Code" := Job."Global Dimension 1 Code";
        ProdOrder."Shortcut Dimension 2 Code" := Job."Global Dimension 2 Code";
        Clear(ProdOrder."Dimension Set ID");
        ProdOrder.UpdateDatetime();
        ProdOrder.Modify();
        exit(ProdOrder.Count() > 0);
    end;

    /// <summary>
    /// Creates a production order line for the specified requisition line and production order.
    /// </summary>
    /// <param name="ReqLine">The requisition line record for which the production order line is being created.</param>
    /// <param name="ProdOrder"> The production order record to which the line will be added.</param>
    internal procedure ProjectSourceProdOrderMgmt__CreateProductionOrderLine(var ReqLine: Record "Requisition Line"; var ProdOrder: Record "Production Order"): Boolean
    var
        Item: Record Item;
        MfgAct: Codeunit "Mfg. Carry Out Action";
    begin
        if not Item.Get(ReqLine."No.") then Error('Item %1 not found.', ReqLine."No.");
        MfgAct.InsertProdOrderLine(ReqLine, ProdOrder, Item);
        exit(true);
    end;

    // Published Events
    [IntegrationEvent(false, false)]
    local procedure OnProjectSourceProdOrderMgmtOnAfterSetProdOrderParameters(var ReqLine: Record "Requisition Line"; DemandNo: Code[20]; ProdOrderChoice: Enum "Planning Create Prod. Order")
    begin
    end;
}
