tableextension 50004 JobPlanningLineExt extends "Job Planning Line"
{
  fields
  {
    // Add changes to table fields here
    field(50000;"DateTime Exported to Exact";DateTime)
    {
      DataClassification = ToBeClassified;
      Caption = 'DateTime Exported to Exact';
    }
  }
  var myInt: Integer;
}