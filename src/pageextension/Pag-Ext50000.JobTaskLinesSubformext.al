pageextension 50000 "Job Task Lines Subform ext" extends "Job Task Lines Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter("Job Task Type")
        {
            field("Clockwise Integration"; Rec.ClockwiseIntegration())
            {
                ApplicationArea = All;
                Caption = 'Clockwise Integration';
            }
            field("External Document No."; "External Document No.")
            {
                ApplicationArea = All;
            }
            field("Gen. Prod. Posting Group";"Gen. Prod. Posting Group")
            {
                ApplicationArea = All;
            }
            field("Hours per Week";"Hours per Week")
            {
                ApplicationArea = All;
            }
            field("Schedule (Total Hours)";"Schedule (Total Hours)")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        // Add changes to page actions here
        addafter("F&unctions")
        {
            group("Log")
            {
                action("Event Log")
                {
                    ApplicationArea = All;
                    Image = Log;

                    trigger OnAction()
                    var
                        myRec: Record "Job Task";
                        TableEvent: Record "Web Service Log";
                        ListPage: Page "Web Service Log";
                        RecRef: RecordRef;
                        EventLog_Text001_Lbl: Label 'There are no records';
                    begin
                        myRec := Rec;
                        RecRef.GetTable(myRec);
                        RecRef.SetRecFilter();
                        TableEvent.FilterGroup(2);
                        TableEvent.SetCurrentKey("Record ID");
                        TableEvent.SetRange("Record ID", RecRef.RecordId());
                        if TableEvent.FindSet() then begin
                            TableEvent.FilterGroup(0);
                            Clear(ListPage);
                            ListPage.SetTableView(TableEvent);
                            ListPage.Run();
                        end
                        else
                            message(EventLog_Text001_Lbl);
                    end;
                }
                action("Event Log - All")
                {
                    ApplicationArea = All;
                    Image = Log;

                    trigger OnAction()
                    var
                        ListPage: Page "Web Service Log";
                    begin
                        Clear(ListPage);
                        ListPage.Run();
                    end;
                }
                action("Show Customer Clockwise no.")
                {
                    ApplicationArea = All;
                    Image = ViewDetails;

                    trigger OnAction()
                    var
                        CWeventsubs: Codeunit "ClockWise Event Subscription";
                    begin
                        message('Clockwise Customer No = %1', CWeventsubs.GetClockwiseCustomerNo(Rec));
                    end;
                }
            }
        }
    }
}
