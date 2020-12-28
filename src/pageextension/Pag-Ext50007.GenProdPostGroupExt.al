pageextension 50007 GenProdPostGroupExt extends "Gen. Product Posting Groups"
{
    layout
    {
        addafter("Auto Insert Default")
        {
            field("Exact Item Code"; "Exact Item Code")
            {
                ApplicationArea = All;
            }
        }
    }
}
