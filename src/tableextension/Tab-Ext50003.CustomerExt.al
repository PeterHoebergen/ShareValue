tableextension 50003 "Customer_Ext" extends Customer
{
  fields
  {
    // Add changes to table fields here
    field(50000;"Customer No. - Clockwise";Code[20])
    {
      DataClassification = ToBeClassified;
      Caption = 'ID Clockwise';
    }
  }
  var myInt: Integer;
}
