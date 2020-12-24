table 50005 "Web Service Log"
{
  DataClassification = ToBeClassified;

  fields
  {
    field(1;"Entry No.";Integer)
    {
      DataClassification = ToBeClassified;
      Caption = 'Entry No.';
      AutoIncrement = true;
    }
    field(5;"Entry Date";Date)
    {
      DataClassification = ToBeClassified;
    }
    field(10;"Table No.";Integer)
    {
      DataClassification = ToBeClassified;
      Caption = 'Table No.';
    }
    field(11;"Record ID";RecordId)
    {
      DataClassification = ToBeClassified;
      Caption = 'Record ID';
    }
    field(20;"OnEvent Type";Enum "Table Event Type")
    {
      DataClassification = ToBeClassified;
      Caption = 'OnEvent Type';
    }
    field(30;"Integration Status";Enum "Table Event Integration Status")
    {
      DataClassification = ToBeClassified;
      Caption = 'Integration Status';
    }
    field(40;"Endpoint";Enum "Endpoint Type")
    {
      DataClassification = ToBeClassified;
      Caption = 'Endpoint';
    }
    field(49;"Request Action";Enum "Request Action")
    {
      DataClassification = ToBeClassified;
      Caption = 'Request Action';
    }
    field(50;"JSon Request";Blob)
    {
      DataClassification = ToBeClassified;
      Caption = 'JSon Request';
    }
    field(51;"JSon Response";Blob)
    {
      DataClassification = ToBeClassified;
      Caption = 'JSon Response';
    }
    field(52;"Response ID";Integer)
    {
      DataClassification = ToBeClassified;
      Caption = 'Response ID';
    }
    field(53;"Request Date";Date)
    {
      DataClassification = ToBeClassified;
    }
    field(60;"Error Text";Text[250])
    {
      DataClassification = ToBeClassified;
      Caption = 'Error Text';
    }
  }
  keys
  {
    key(PK;"Entry No.")
    {
      Clustered = true;
    }
    key(key2;"Record ID", "OnEvent Type", "Integration Status")
    {
    }
    key(key3;"Table No.", "Record ID", "Response ID")
    {
    }
    key(key4;"Table No.", Endpoint, "Response ID")
    {
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
