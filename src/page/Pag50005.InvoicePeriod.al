page 50005 "Invoice Period"
{
  PageType = List;
  ApplicationArea = All;
  UsageCategory = Lists;
  SourceTable = "Invoice Period";

  layout
  {
    area(Content)
    {
      repeater(GroupName)
      {
        field(Code;Code)
        {
          ApplicationArea = All;
        }
        field(Description;Description)
        {
          ApplicationArea = All;
        }
      }
    }
  /*
        area(Factboxes)
        {

        }
        */
  }
/*
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
    */
}
