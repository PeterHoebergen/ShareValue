tableextension 50001 "JobTask_Ext" extends "Job Task"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "External Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'External Document No.';
        }
        field(50001;"Gen. Prod. Posting Group";Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(50002;"Hours per Week";Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Hours per Week';
        }
        field(50003; "Schedule (Total Hours)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum("Job Planning Line".Quantity WHERE("Job No." = FIELD("Job No."),
                                                                            "Job Task No." = FIELD("Job Task No."),
                                                                            "Job Task No." = FIELD(FILTER(Totaling)),
                                                                            "Schedule Line" = CONST(true),
                                                                            "Type" = CONST(resource),
                                                                            "Planning Date" = FIELD("Planning Date Filter")));
            Caption = 'Budget (Total Hours)';
            Editable = false;
            FieldClass = FlowField;
        }
    }


    /// <summary> 
    /// Description for ClockwiseIntegration.
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure ClockwiseIntegration(): Boolean
    var
        EventLog: Record "Web Service Log";
        RecRef: RecordRef;
        myRec: Record "Job Task";
    begin
        myRec := Rec;
        RecRef.GetTable(myRec);
        RecRef.SetRecFilter();
        EventLog.SetCurrentKey("Record ID", "OnEvent Type", "Integration Status");
        EventLog.SetRange("Record ID", RecRef.RecordId());
        EventLog.SetRange("Integration Status", EventLog."Integration Status"::Sent);
        exit(EventLog.FindFirst());
    end;
}
