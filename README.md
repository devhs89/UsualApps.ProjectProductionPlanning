# Project Production Planning by UsualApps Inc.

Project Production Planning is a Microsoft Dynamics 365 Business Central AL extension that adds project-driven production planning. It lets users calculate production demand from project planning lines and create consolidated production orders directly from the Project Card.

## What It Does

- Adds a **Create Production Orders** action to the Project Card.
- Opens a project-specific **Project Planning** worksheet based on Business Central requisition lines.
- Plans demand from job planning lines where replenishment is handled by production orders.
- Lets users review item, production BOM, routing, reserve status, and supply quantities before creating production orders.
- Creates or updates a project-sourced production order for the selected project demand.
- Prevents refresh of production orders with source type **Project Header** while that functionality is not implemented. The app displays an error by default and publishes an event that subscribers can handle to suppress the error.

## User Flow

1. Open a Project Card.
2. Choose **Create Production Orders** from the process/functions actions.
3. Review the calculated Project Planning worksheet.
4. Optionally use:
   - **Item Card** to inspect the selected item.
   - **Production BOM** to inspect the item's production BOM.
   - **Routing** to inspect the item's routing.
   - **Toggle Reservation** to switch reservation on selected requisition lines.
   - **Toggle Supply Quantities** to switch selected line quantities between needed quantity and zero.
5. Click **OK** to create or update production orders.
6. The extension creates or updates the production order for project demand lines with non-zero quantities.

If all project production requirements have already been planned, the app shows a message and does not create additional production orders.

## Business Central Behavior

The extension uses standard Business Central planning and manufacturing records:

- Source demand comes from **Job Planning Line** demand.
- Planning output is stored in **Requisition Line** records filtered to the current user and project.
- Supply is limited to requisition lines with **Replenishment System = Prod. Order**.
- Created production orders use a custom production order source type named **Project Header**.
- New production orders default to **Firm Planned** status.
- Existing project-sourced production orders for the project are reused and receive additional production order lines.

Project-sourced firm planned and released production orders currently cannot be refreshed from the production order pages. When a production order has source type **Project Header**, the app stops the refresh action and displays an error because project-source refresh handling is not implemented yet. Delete and recreate the production order from the Project Card when the project planning demand changes, or subscribe to `OnProjectSourceProdOrderOnBeforeStopRefresh` and set `IsHandled` to suppress the default error.

## Main AL Objects

| Object | Type | Purpose |
| --- | --- | --- |
| `ProjectCardPlusPlanningUAS` | Page extension | Adds **Create Production Orders** to the Job Card. |
| `ProjectProdPlanningUAS` | Worksheet page | Displays calculated project production demand from requisition lines. |
| `ProjectSourceProdOrderMgmtUAS` | Codeunit | Creates production order headers and lines from selected project demand. |
| `ProjectProdPlanningHelperUAS` | Codeunit | Applies default requisition filters and blocks refresh of project-sourced production orders. |
| `ProjSourceProdOrderEventsUAS` | Codeunit | Exposes integration events for refresh handling and production order parameter customization. |
| `ProdOrderSrcTypePlusExtdUAS` | Enum extension | Adds `Project Header` to production order source types. |
| `ProdOrderPlusProjSrcUAS` | Table extension | Relates production order source number to open projects. |
| `FirmPlanProdOrdPlusPrjSrcUAS` | Page extension | Blocks refresh for project-sourced firm planned production orders. |
| `ReleasedProdOrdPlusPrjSrcUAS` | Page extension | Blocks refresh for project-sourced released production orders. |

## Extension Points

The app exposes these integration events:

- `OnProjectSourceProdOrderOnBeforeStopRefresh`
  - Published before the app displays the refresh-blocking error for a project-sourced production order. Subscribers can set `IsHandled` to stop the default error from being displayed and provide custom handling.
- `OnProjectSourceProdOrderMgmtOnAfterSetProdOrderParameters`
  - Allows custom code to adjust production order creation parameters after the project demand number and default production order choice are set.

## Requirements

- Microsoft Dynamics 365 Business Central application `27.0.0.0` or later.
- AL runtime `16.0`.
- Manufacturing setup with number series configured for planned and/or firm planned production orders.
- Items used on project planning lines must be producible through production orders.

## Development

The AL app is located under [`App`](App) folder.

Key project settings:

- Publisher: `UsualApps Inc.`
- App name: `Project Production Planning`
- Version: `1.0.0.0`
- Object range: `71826200..71826299`
- Mandatory suffix: `UAS`
- Namespace template: `UsualApps.$(parentfolder)`
- Features: `NoImplicitWith`, `TranslationFile`

The included VS Code launch configuration targets a Microsoft cloud sandbox named `Sandbox-UsualApps` and starts on page `89`.

## Repository Layout

```text
App/
  app.json
  AppSourceCop.json
  Assets/
  Src/
    Events/
    Planning/
    Production/
    Projects/
  Test/
  Translations/
```

## Packaging

Build and publish the extension with the AL tooling for Business Central. The repository includes downloaded platform and application packages in `App/.alpackages` and a packaged app artifact under `App/Test`.

## License

Copyright © 2026 UsualApps Inc. All rights reserved. This project is proprietary and is not licensed for copying, modification, distribution, sale, resale, commercialization, monetization, or other use without prior express written permission from UsualApps Inc. See [`LICENSE.md`](LICENSE.md) for the complete notice.
