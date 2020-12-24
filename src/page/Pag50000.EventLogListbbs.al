page 50000 "EventLogList_bbs"
{
  ApplicationArea = All;
  UsageCategory = Administration;
  AutoSplitKey = true;
  DelayedInsert = true;
  Editable = false;
  MultipleNewLines = true;
  PageType = List;
  SourceTable = EventLog_bbs;
  SourceTableView = sorting(EventDT)order(descending);

  layout
  {
    area(content)
    {
      repeater(Group)
      {
        field(EventID;EventID)
        {
          ApplicationArea = All;
        }
        field(EventStep;EventStep)
        {
          ApplicationArea = All;
        }
        field(EventDT;EventDT)
        {
          ApplicationArea = All;
        }
        field(EventType;EventType)
        {
          ApplicationArea = All;
        }
        field(ObjectID;ObjectID)
        {
          ApplicationArea = All;
        }
        field(ObjectKey;ObjectKey)
        {
          ApplicationArea = All;
        }
        field(EventText;EventText)
        {
          ApplicationArea = All;
        }
        field(LogType;LogType)
        {
          ApplicationArea = All;
        }
        field(LogText;LogText)
        {
          ApplicationArea = All;
        }
        field(LogErrorText;LogErrorText)
        {
          ApplicationArea = All;
        }
        field(HasContent;HasContent)
        {
          ApplicationArea = All;
        }
      }
    }
  }
  actions
  {
    area(Processing)
    {
      action(ViewContent)
      {
        Caption = 'View Content';
        ApplicationArea = All;
        Image = View;

        trigger OnAction()var ContentTxt: Text;
        ContentInStr: InStream;
        begin
          if LogContent.HasValue()then begin
            CalcFields(LogContent);
            LogContent.CreateInStream(ContentInStr);
            ContentInStr.ReadText(ContentTxt);
            Message(ContentTxt);
          end
          else
            Message('No content available');
        end;
      }
    }
  }
}
