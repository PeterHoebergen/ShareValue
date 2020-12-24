pageextension 50001 "Company Information CWC Ext" extends "Company Information"
{
  layout
  {
  }
  actions
  {
    addafter("Jobs Setup")
    {
      action("CWC Setup")
      {
        ApplicationArea = All;
        Caption = 'CWC Setup';
        Image = SwitchCompanies;
        Promoted = true;
        PromotedIsBig = true;
        RunObject = page "CWC Setup";
      }
    }
  }
}
