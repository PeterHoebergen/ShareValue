table 50003 "CWC Time Registration"
{
  Caption = 'Clockwise Time Registration';

  fields
  {
    field(1;"Entry No.";Integer)
    {
      DataClassification = CustomerContent;
      AutoIncrement = true;
    }
    field(10;id;Integer)
    {
      DataClassification = ToBeClassified;
    }
    field(20;date;Date)
    {
      DataClassification = ToBeClassified;
    }
    field(30;day;Text[20])
    {
      DataClassification = ToBeClassified;
    }
    field(40;weeknumber;Integer)
    {
      DataClassification = ToBeClassified;
    }
    field(50;hours;Decimal)
    {
      DataClassification = ToBeClassified;
    }
    field(60;resource_id;Integer)
    {
      DataClassification = ToBeClassified;
    }
    field(70;remark;text[100])
    {
      DataClassification = ToBeClassified;
    }
    field(80;resource_status;text[20])
    {
      DataClassification = ToBeClassified;
    }
    field(90;resource_parent_id;Integer)
    {
      DataClassification = ToBeClassified;
    }
    field(100;employee_id;Integer)
    {
      DataClassification = ToBeClassified;
    }
    field(110;employee_name;text[50])
    {
      DataClassification = ToBeClassified;
    }
    field(111;salary_number;Integer)
    {
      DataClassification = ToBeClassified;
    }
    field(120;department_id_path;text[100])
    {
      DataClassification = ToBeClassified;
    }
    field(130;department_name_path;text[100])
    {
      DataClassification = ToBeClassified;
    }
    field(140;department_code_path;text[100])
    {
      DataClassification = ToBeClassified;
    }
    field(150;customer_id_path;text[100])
    {
      DataClassification = ToBeClassified;
    }
    field(160;customer_name_path;text[100])
    {
      DataClassification = ToBeClassified;
    }
    field(170;customer_code_path;Text[100])
    {
      DataClassification = ToBeClassified;
    }
    field(180;project_id_path;text[100])
    {
      DataClassification = ToBeClassified;
    }
    field(190;project_name_path;text[100])
    {
      DataClassification = ToBeClassified;
    }
    field(200;project_code_path;Text[100])
    {
      DataClassification = ToBeClassified;
    }
  }
  keys
  {
    key(PK;"Entry No.")
    {
    }
    key(key2;id)
    {
    }
  }
}
