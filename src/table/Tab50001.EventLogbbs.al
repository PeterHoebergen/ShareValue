table 50001 "EventLog_bbs"
{
  fields
  {
    field(1;EventID;Guid)
    {
      DataClassification = CustomerContent;
    }
    field(2;EventStep;Integer)
    {
      DataClassification = CustomerContent;
    }
    field(3;EventDT;DateTime)
    {
      DataClassification = CustomerContent;
    }
    field(4;EventType;Enum EventType_bbs)
    {
      DataClassification = CustomerContent;
    }
    field(5;ObjectID;Integer)
    {
      DataClassification = CustomerContent;
    }
    field(6;ObjectKey;Text[100])
    {
      DataClassification = CustomerContent;
    }
    field(7;EventText;Text[250])
    {
      DataClassification = CustomerContent;
    }
    field(8;LogType;Enum LogType_bbs)
    {
      DataClassification = CustomerContent;
    }
    field(9;LogText;Text[250])
    {
      DataClassification = CustomerContent;
    }
    field(10;LogErrorText;Text[250])
    {
      DataClassification = CustomerContent;
    }
    field(11;LogContent;Blob)
    {
      DataClassification = CustomerContent;
    }
    field(12;HasContent;Boolean)
    {
      DataClassification = CustomerContent;
    }
  }
  keys
  {
    key(PK;EventID, EventStep)
    {
    }
    key(Date;EventDT)
    {
    }
  }
  fieldgroups
  {
  }
}
