tableextension 50005 GenProdPostGroupExt extends "Gen. Product Posting Group"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Exact Item Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Exact Item Code';
        }
    }
    var
        myInt: Integer;
}