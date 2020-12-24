table 50002 "CWC Setup"
{
  Caption = 'Clockwise Connector Setup';

  fields
  {
    field(1;"Primary Key";Text[30])
    {
      DataClassification = CustomerContent;
      Caption = 'Primary Key';
    }
    field(10;"Base URL";Text[100])
    {
      DataClassification = CustomerContent;
      Caption = 'Base URL';
    }
    field(11;"Username";Text[50])
    {
      DataClassification = CustomerContent;
      caption = 'User name';
    }
    field(12;"Password";Text[50])
    {
      DataClassification = CustomerContent;
      Caption = 'Password';
    }
    field(20;"Hour Import Endpoint";Text[250])
    {
      DataClassification = CustomerContent;
      Caption = 'Hour Import Endpoint';
    }
    field(30;"Project Endpoint";text[50])
    {
      DataClassification = ToBeClassified;
      Caption = 'Project Endpoint';
    }
    field(39;"Refresh Token";Text[100])
    {
      DataClassification = ToBeClassified;
      Caption = 'Refresh Token';
    }
    field(40;"Receipt Token";Text[100])
    {
      DataClassification = ToBeClassified;
      Caption = 'Receipt Token';
    }
    field(41;"Token Executed";DateTime)
    {
      DataClassification = ToBeClassified;
      Caption = 'Token Executed';
    }
    field(42;"Token Expired";DateTime)
    {
      DataClassification = ToBeClassified;
      Caption = 'Token Expired';
    }
  }
  keys
  {
    key(PK;"Primary Key")
    {
    }
  }
}
