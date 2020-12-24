tableextension 50002 "Job_Ext" extends Job
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Payment Terms Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";
        }
        modify("Bill-to Customer No.")
        {
            trigger OnAfterValidate()
            var
                Cust: Record Customer;
            begin
                if Cust.Get("Bill-to Customer No.") then begin
                    "Payment Terms Code" := Cust."Payment Terms Code";
                end;
            end;
        }
        field(50001; "Invoice Period"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Invoice Period';
            TableRelation = "Invoice Period";
        }
    }
    var
        myInt: Integer;
}
