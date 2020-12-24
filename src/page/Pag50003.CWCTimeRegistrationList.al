page 50003 "CWC Time Registration List"
{
  PageType = List;
  ApplicationArea = All;
  UsageCategory = Tasks;
  SourceTable = "CWC Time Registration";
  InsertAllowed = false;
  ModifyAllowed = false;

  layout
  {
    area(Content)
    {
      repeater(GroupName)
      {
        field("Entry No.";"Entry No.")
        {
          ToolTip = ' ';
          ApplicationArea = All;
        }
        field(ID;ID)
        {
          ToolTip = ' ';
          ApplicationArea = All;
        }
        field(Date;Date)
        {
          ToolTip = ' ';
          ApplicationArea = All;
        }
        field(day;day)
        {
          ToolTip = ' ';
          ApplicationArea = All;
        }
        field(weeknumber;weeknumber)
        {
          ApplicationArea = All;
        }
        field(hours;hours)
        {
          ApplicationArea = All;
        }
        field(resource_id;resource_id)
        {
          ApplicationArea = All;
        }
        field(remark;remark)
        {
          ApplicationArea = All;
        }
        field(resource_status;resource_status)
        {
          ApplicationArea = All;
        }
        field(resource_parent_id;resource_parent_id)
        {
          ApplicationArea = All;
        }
        field(employee_id;employee_id)
        {
          ApplicationArea = All;
        }
        field(employee_name;employee_name)
        {
          ApplicationArea = All;
        }
        field(department_id_path;department_id_path)
        {
          ApplicationArea = All;
        }
        field(department_name_path;department_name_path)
        {
          ApplicationArea = All;
        }
        field(department_code_path;department_code_path)
        {
          ApplicationArea = All;
        }
        field(customer_id_path;customer_id_path)
        {
          ApplicationArea = All;
        }
        field(customer_name_path;customer_name_path)
        {
          ApplicationArea = All;
        }
        field(customer_code_path;customer_code_path)
        {
          ApplicationArea = All;
        }
        field(project_id_path;project_id_path)
        {
          ApplicationArea = All;
        }
        field(project_name_path;project_name_path)
        {
          ApplicationArea = All;
        }
        field(project_code_path;project_code_path)
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
      action("Import Hours")
      {
        ToolTip = ' ';
        ApplicationArea = All;
        Image = Import;

        trigger OnAction()var CWCTimeMgt: Codeunit "CWC Time Management";
        AutorizationType: Enum "Authorization Type";
        begin
          CWCTimeMgt.GetHours(today, today, AutorizationType::Token);
        end;
      }
    }
  }
}
