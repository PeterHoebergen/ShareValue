pageextension 50005 "CustomerCard_Ext" extends "Customer Card"
{
  layout
  {
    // Add changes to page layout here
    addafter("No.")
    {
      field("Customer No. - Clockwise";"Customer No. - Clockwise")
      {
        ApplicationArea = All;
      }
    }
  }
  actions
  {
  }
  /*
    actions
    {
        // Add changes to page actions here
    }
    */
  var myInt: Integer;
}
