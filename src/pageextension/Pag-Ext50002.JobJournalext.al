pageextension 50002 "Job Journal ext" extends "Job Journal"
{
  layout
  {
  }
  actions
  {
    // Add changes to page actions here
    addafter(CalcRemainingUsage)
    {
      action("Get Hour From Clockwise")
      {
        ApplicationArea = All;
        Caption = 'Get Hour From Clockwise';
        Image = CopyServiceHours;
        Promoted = true;
        PromotedCategory = Process;

        trigger OnAction()var Rpt: Report "CWC Import Hours";
        begin
          Clear(Rpt);
          Rpt.SetParameters(Rec);
          Rpt.Run();
        end;
      }
    }
  }
}
