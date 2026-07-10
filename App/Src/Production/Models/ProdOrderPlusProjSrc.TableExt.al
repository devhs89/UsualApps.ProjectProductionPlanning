namespace UsualApps.ProjectProductionPlanning;
using Microsoft.Manufacturing.Document;
using Microsoft.Projects.Project.Job;

tableextension 71826211 ProdOrderPlusProjSrcUAS extends "Production Order"
{
    fields
    {
        modify("Source No.")
        {
            TableRelation = Job."No." where(Status = const(Open));
        }
    }
}