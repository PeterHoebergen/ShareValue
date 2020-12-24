page 50001 "EventLogSetup_bbs"
{
  PageType = CardPart;
  SourceTable = EventLogSetup_bbs;
  Caption = 'Event Log Setup';
  InsertAllowed = false;
  DeleteAllowed = false;
  UsageCategory = Administration;

  layout
  {
    area(content)
    {
      //group(EventLog)
      //{
      //    Caption = 'Event Log';
      field("Enable Event Logging";"Enable Event Logging")
      {
        ApplicationArea = All;
      }
      field("Retention Period";"Retention Period")
      {
        ApplicationArea = All;
      }
    //}
    }
  }
  trigger OnOpenPage()begin
    Reset();
    if not Get()then begin
      Init();
      Insert();
    end;
  end;
}
