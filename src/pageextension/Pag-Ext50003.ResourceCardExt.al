pageextension 50003 "ResourceCard_Ext" extends "Resource Card"
{
  layout
  {
    // Add changes to page layout here
    addafter(Name)
    {
      field("salary_number - Clockwise";"salary_number - Clockwise")
      {
        ApplicationArea = All;
        Visible = false;
      }
    }
  }
  actions
  {
  }
  var myInt: Integer;
}
