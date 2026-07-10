namespace UsualApps.ProjectProductionPlanning;

using Microsoft.Inventory.Requisition;
using Microsoft.Projects.Project.Planning;

codeunit 71826211 ProjectProdPlanningHelperUAS
{
    internal procedure SetDefaultReqLineFilters(var ReqLine: Record "Requisition Line"; FilterGroup: Integer; DemandNo: Code[20])
    begin
        ReqLine.FilterGroup(FilterGroup);
        ReqLine.SetRange("User ID", UserId);
        ReqLine.SetRange("Worksheet Template Name", '');
        ReqLine.SetRange("Demand Type", Database::"Job Planning Line");
        ReqLine.SetRange("Demand Order No.", DemandNo);
        ReqLine.SetRange("Replenishment System", ReqLine."Replenishment System"::"Prod. Order");
        ReqLine.Setfilter("Line No.", '<>0');
        ReqLine.FilterGroup(0);
    end;

    internal procedure InitializeManufacturingUserTemplate(var MfgTemp: Record "Manufacturing User Template"; Username: Code[50])
    begin
        MfgTemp.Init();
        MfgTemp."User ID" := Username;
        MfgTemp."Make Orders" := MfgTemp."Make Orders"::"The Active Order";
        MfgTemp."Create Production Order" := MfgTemp."Create Production Order"::"Firm Planned";
        Clear(MfgTemp."Create Purchase Order");
        Clear(MfgTemp."Create Transfer Order");
        Clear(MfgTemp."Create Assembly Order");
        Clear(MfgTemp."Prod. Req. Wksh. Template");
        Clear(MfgTemp."Prod. Wksh. Name");
        Clear(MfgTemp."Purchase Req. Wksh. Template");
        Clear(MfgTemp."Purchase Wksh. Name");
        Clear(MfgTemp."Transfer Req. Wksh. Template");
        Clear(MfgTemp."Transfer Wksh. Name");
    end;
}
