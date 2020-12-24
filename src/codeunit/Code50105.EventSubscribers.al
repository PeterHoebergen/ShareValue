codeunit 50105 "Event Subscribers"
{
    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnAfterAssignResourceValues', '', true, true)]
        local procedure ChangeGenProdPostingGroupOnAfterAssignResourceValues(Resource: Record Resource;var JobJournalLine: Record "Job Journal Line")
        var
            JobTask : Record "Job Task";
        begin
            if JobTask.Get(JobJournalLine."Job No.",JobJournalLine."Job Task No.") then
                if JobTask."Gen. Prod. Posting Group" <> '' then
                    JobJournalLine."Gen. Prod. Posting Group" := JobTask."Gen. Prod. Posting Group";
        end;

    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnAfterValidateEvent', 'No.', true, true)]
        local procedure ChangeGenProdPostingGroupOnAfterValidateJobPlanningLineNo(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line")
        var
            JobTask : Record "Job Task";
        begin
            if Rec.Type <> Rec.Type::Resource then
                exit;

            if JobTask.Get(Rec."Job No.",Rec."Job Task No.") then
                if JobTask."Gen. Prod. Posting Group" <> '' then
                    Rec."Gen. Prod. Posting Group" := JobTask."Gen. Prod. Posting Group";
        end;
}