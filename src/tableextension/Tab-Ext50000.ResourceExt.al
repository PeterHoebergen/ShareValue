tableextension 50000 "Resource_Ext" extends Resource
{
  fields
  {
    // Add changes to table fields here
    field(50000;"salary_number - Clockwise";Integer)
    {
      DataClassification = ToBeClassified;
      Caption = 'ID Clockwise';
    }
  }
  keys
  {
    key(custom01;"salary_number - Clockwise")
    {
    }
  }
  var myInt: Integer;
}
