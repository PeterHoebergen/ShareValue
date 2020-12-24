table 50000 "EventLogSetup_bbs"
{
  DataClassification = CustomerContent;

  fields
  {
    field(1;"Primary Key";Code[10])
    {
      DataClassification = CustomerContent;
    }
    field(2;"Enable Event Logging";Boolean)
    {
      DataClassification = CustomerContent;
    }
    field(3;"Retention Period";DateFormula)
    {
      DataClassification = CustomerContent;
    }
  }
  keys
  {
    key(PK;"Primary Key")
    {
      Clustered = true;
    }
  }
}
