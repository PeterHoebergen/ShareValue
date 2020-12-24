report 50001 "ToolsUpdateJobTaskResponseID"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group("Project Id")
                {
                    field("Old Project ID"; OldProjectID)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("New Project ID"; NewProjectID)
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    var
        _TableEvent: record "Web Service Log";
        _Count: Integer;
    begin
        if NewProjectID <= 0 then Error('New Project ID must not be zero');
        _TableEvent.SetCurrentKey("Table No.", "Record ID", "Response ID");
        _TableEvent.SetRange("Table No.", Database::"Job Task");
        _TableEvent.SetRange("Record ID", TableEvent."Record ID");
        if _TableEvent.FindSet(true, true) then
            repeat
                _TableEvent."Response ID" := NewProjectID;
                _TableEvent.Modify();
                _Count += 1;
            until _TableEvent.Next() = 0;
        Message('%1 records updated', _Count);
    end;

    var
        TableEvent: record "Web Service Log";
        OldProjectID: Integer;
        NewProjectID: Integer;

    procedure SetProcessRecord(pRec: Record "Web Service Log")
    begin
        TableEvent := pRec;
        TableEvent.TestField("Table No.", Database::"Job Task");
        OldProjectID := TableEvent."Response ID";
    end;
}
