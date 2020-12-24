report 50002 "RunPendingConsumeAPI"
{
  UsageCategory = Administration;
  ApplicationArea = All;
  ProcessingOnly = true;

  dataset
  {
  dataitem(TableEvent;"Web Service Log")
  {
  DataItemTableView = sorting("Record ID", "OnEvent Type", "Integration Status")where("Integration Status"=Const(Pending));

  trigger OnAfterGetRecord()var CWCProjectMgt: Codeunit "CWC Project Management";
  begin
    CWCProjectMgt.MakeRequest(TableEvent);
  end;
  }
  }
  var myInt: Integer;
}
