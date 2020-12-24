pageextension 50004 "JobCard_Ext" extends "Job Card"
{
  layout
  {
    // Add changes to page layout here
    addafter("Bill-to Name")
    {
      field("Payment Terms Code";"Payment Terms Code")
      {
        ApplicationArea = All;
      }
      field("Invoice Period";"Invoice Period")
      {
        ApplicationArea = All;
      }
    }
  }
  actions
  {
  }
  var myInt: Integer;
}
