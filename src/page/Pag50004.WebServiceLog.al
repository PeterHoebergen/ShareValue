page 50004 "Web Service Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Web Service Log";
    ModifyAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater("Log List")
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Entry Date"; "Entry Date")
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("Record ID"; format("Record ID"))
                {
                    ApplicationArea = All;
                }
                field("OnEvent Type"; "OnEvent Type")
                {
                    ApplicationArea = All;
                }
                field(Endpoint; Endpoint)
                {
                    ApplicationArea = All;
                }
                field("Integration Status"; "Integration Status")
                {
                    ApplicationArea = All;
                }
                field("Request Action"; "Request Action")
                {
                    ApplicationArea = All;
                }
                field("Request Date"; "Request Date")
                {
                    ApplicationArea = All;
                }
                field("Response ID"; "Response ID")
                {
                    ApplicationArea = All;
                }
                field("Error Text"; "Error Text")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {
        }
    }
    actions
    {
        area(Processing)
        {
            action("Send")
            {
                ApplicationArea = All;
                Image = SendTo;

                trigger OnAction();
                var
                    TableEvent_Text001: Label 'Record sent already';
                    CWCProjectMgt: Codeunit "CWC Project Management";
                begin
                    if "Integration Status" = "Integration Status"::Sent then Error(TableEvent_Text001);
                    CWCProjectMgt.MakeRequest(Rec);
                end;
            }
            action("Show Request JSon")
            {
                ApplicationArea = All;
                Image = SendApprovalRequest;

                trigger OnAction()
                var
                    InS: InStream;
                    FileName: Text[250];
                    Show_Request_JSon_Text001: Label 'There is no data in blob of field %1';
                begin
                    CalcFields("JSon Request");
                    if not "JSon Request".HasValue then Error(Show_Request_JSon_Text001, FieldCaption("JSon Request"));
                    "JSon Request".CreateInStream(InS);
                    FileName := 'JSON_Equation.txt';
                    DownloadFromStream(InS, '', '', '', FileName);
                end;
            }
            action("Show Response JSon")
            {
                ApplicationArea = All;
                Image = Receipt;

                trigger OnAction()
                var
                    InS: InStream;
                    FileName: Text[250];
                    Show_Response_JSon_Text001: Label 'There is no data in blob of field %1';
                begin
                    CalcFields("JSon Response");
                    if not "JSon Response".HasValue then Error(Show_Response_JSon_Text001, FieldCaption("JSon Response"));
                    "JSon Response".CreateInStream(InS);
                    FileName := 'JSON_Equation.txt';
                    DownloadFromStream(InS, '', '', '', FileName);
                end;
            }
            action("Show Job Task By Response ID")
            {
                ApplicationArea = All;
                Image = Task;

                trigger OnAction()
                var
                    ProjectMgt: Codeunit "CWC Project Management";
                    JobTask: Record "Job Task";
                begin
                    TestField("Table No.", Database::"Job Task");
                    TestField("Response ID");
                    ProjectMgt.GetJobTaskFromResponseID("Response ID", JobTask);
                    Message('%1 = %2\%3 = %4\%5 = %6', JobTask.FieldCaption("Job No."), JobTask."Job No.", JobTask.FieldCaption("Job Task No."), JobTask."Job Task No.", JobTask.FieldCaption(Description), JobTask.Description);
                end;
            }
            action("Change Error to Pending")
            {
                ApplicationArea = All;
                Image = ChangeStatus;

                trigger OnAction()
                var
                    EventTable: Record "Web Service Log";
                    n: Integer;
                    ChangeErrortoPending_Text001: Label '%1 records updated';
                    ChangeErrortoPending_Text002: Label 'System will update %1 from %2 into %3, continue?';
                begin
                    CurrPage.SetSelectionFilter(EventTable);
                    if EventTable.FindSet() then begin
                        if not Confirm(ChangeErrortoPending_Text002, false, EventTable.FieldCaption("Integration Status"), format(EventTable."Integration Status"::Error), format(EventTable."Integration Status"::Pending)) then exit;
                        repeat
                            if EventTable."Integration Status" = EventTable."Integration Status"::Error then begin
                                EventTable."Integration Status" := EventTable."Integration Status"::Pending;
                                EventTable.Modify();
                                n += 1;
                            end;
                        until EventTable.Next() = 0;
                    end;
                    Message(ChangeErrortoPending_Text001, n);
                end;
            }
            action("Update Response ID")
            {
                ApplicationArea = All;
                Image = UpdateDescription;

                trigger OnAction()
                var
                    Rpt: Report ToolsUpdateJobTaskResponseID;
                begin
                    Clear(Rpt);
                    Rpt.SetProcessRecord(Rec);
                    Rpt.Run();
                end;
            }
        }
    }
}
