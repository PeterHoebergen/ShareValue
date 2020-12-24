table 50006 "Invoice Period"
{
  DataClassification = ToBeClassified;
  Caption = 'Invoice Period';
  LookupPageId = "Invoice Period";
  DrillDownPageId = "Invoice Period";

  fields
  {
    field(1;Code;Code[20])
    {
      DataClassification = ToBeClassified;
      Caption = 'Code';
    }
    field(10;Description;Text[50])
    {
      DataClassification = ToBeClassified;
      Caption = 'Description';
    }
  }
  keys
  {
    key(PK;Code)
    {
      Clustered = true;
    }
  }
  var myInt: Integer;
  trigger OnInsert()begin
  end;
  trigger OnModify()begin
  end;
  trigger OnDelete()begin
  end;
  trigger OnRename()begin
  end;
}
