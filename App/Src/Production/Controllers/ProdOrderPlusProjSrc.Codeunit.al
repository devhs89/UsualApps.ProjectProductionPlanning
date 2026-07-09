namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Setup;
using Microsoft.Projects.Project.Job;

codeunit 71826213 ProdOrderPlusProjSrcUAS
{
    /// <summary>
    /// Checks if a production order header exists for the given requisition line and production order choice.
    /// </summary>
    /// <param name="ReqLine">The requisition line record to check against.</param>
    /// <param name="ProdOrderChoice">The choice of production order status (Planned, Firm Planned, etc.).</param>
    /// <returns>The production order record if it exists; otherwise, an empty record.</returns>
    internal procedure ProjectProdOrdersMgmt__ProductionHeaderExists(var ReqLine: Record "Requisition Line"; ProdOrderChoice: Enum "Planning Create Prod. Order") ProdOrder: Record "Production Order"
    var
        ExistProd: Record "Production Order";
    begin
        ExistProd.SetCurrentKey(Status, "Source Type", "Source No.");

        case ProdOrderChoice of
            ProdOrderChoice::Planned:
                ExistProd.SetRange(Status, "Production Order Status"::Planned);
            ProdOrderChoice::"Firm Planned", ProdOrderChoice::"Firm Planned & Print":
                ExistProd.SetRange(Status, "Production Order Status"::"Firm Planned");
            else
                exit;
        end;
        ExistProd.SetRange("Source Type", "Prod. Order Source Type"::ProjectHeaderUAS);
        ExistProd.SetRange("Source No.", ReqLine."Demand Order No.");
        if ProdOrder.FindFirst() then;
        exit(ProdOrder)
    end;

    /// <summary>
    /// Inserts a new project production order header record based on the provided requisition line and production order choice.
    /// </summary>
    /// <param name="ReqLine">The requisition line record associated with the production order.</param>
    /// <param name="ProdOrder">The production order record to insert.</param>
    /// <param name="ProdOrderChoice">The choice of production order status (Planned, Firm Planned, etc.).</param>
    /// <returns>True if the production order header was successfully created; otherwise, false.</returns>
    internal procedure ProdOrderPlusProjSrcUAS__CreateProjectProductionOrderHeader(var ReqLine: Record "Requisition Line"; var ProdOrder: Record "Production Order"; ProdOrderChoice: Enum "Planning Create Prod. Order"): Boolean
    var
        ManufacturingSetup: Record "Manufacturing Setup";
        Job: Record Job;
    begin
        // Validate the requisition line and ensure that the associated job exists.
        if not Job.Get(ReqLine."Demand Order No.") then Error('Job %1 not found.', ReqLine."Demand Order No.");

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
        // Create the production order line for the requisition line and the newly created production order.
        this.ProjectProdOrdersMgmt__CreateProductionOrderLine(ReqLine, ProdOrder);
        exit(ProdOrder.Count() > 0);
    end;

    /// <summary>
    /// Creates a production order line for the specified requisition line and production order.
    /// </summary>
    /// <param name="ReqLine">The requisition line record for which the production order line is being created.</param>
    /// <param name="ProdOrder"> The production order record to which the line will be added.</param>
    internal procedure ProjectProdOrdersMgmt__CreateProductionOrderLine(var ReqLine: Record "Requisition Line"; var ProdOrder: Record "Production Order")
    var
        Item: Record Item;
        MfgAct: Codeunit "Mfg. Carry Out Action";
    begin
        if not Item.Get(ReqLine."No.") then Error('Item %1 not found.', ReqLine."No.");
        MfgAct.InsertProdOrderLine(ReqLine, ProdOrder, Item);
    end;
}