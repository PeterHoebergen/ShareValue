page 50002 "CWC Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "CWC Setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                group("API")
                {
                    field("Base URL"; "Base URL")
                    {
                        ToolTip = ' ';
                        ApplicationArea = All;
                    }
                    field(Username; Username)
                    {
                        ToolTip = ' ';
                        ApplicationArea = All;
                    }
                    field(Password; Password)
                    {
                        ToolTip = ' ';
                        ApplicationArea = All;
                    }
                }
                group(Token)
                {
                    field("Refreshed Token"; "Refresh Token")
                    {
                        ToolTip = ' ';
                        ApplicationArea = All;
                    }
                    field("Receipt Token"; "Receipt Token")
                    {
                        ToolTip = ' ';
                        ApplicationArea = All;
                    }
                    field("Token Executed"; "Token Executed")
                    {
                        ToolTip = ' ';
                        ApplicationArea = All;
                    }
                    field("Token Expired"; "Token Expired")
                    {
                        ToolTip = ' ';
                        ApplicationArea = All;
                    }
                }
                group("End Point")
                {
                    field("Hour Import Endpoint"; "Hour Import Endpoint")
                    {
                        ToolTip = ' ';
                        ApplicationArea = All;
                    }
                    field("Project Endpoint"; "Project Endpoint")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            part(EventLog; EventLogSetup_bbs)
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Test Get Hours")
            {
                ToolTip = ' ';
                ApplicationArea = All;
                Image = LinkWeb;

                trigger OnAction()
                var
                    CWCTimeMgt: Codeunit "CWC Time Management";
                    AutorizationType: Enum "Authorization Type";
                begin
                    Message('Check for March 2020');
                    CWCTimeMgt.GetHours(DMY2Date(1, 3, 2020), DMY2Date(31, 3, 2020), AutorizationType::Token);
                    Message('Finished, Please Check event list');
                end;
            }
            action("Refresh Token")
            {
                ApplicationArea = All;
                Image = EncryptionKeys;

                trigger OnAction()
                var
                    CWCProjectMgt: Codeunit "CWC Project Management";
                    CurrentToken: Text[100];
                    DurationInt: Integer;
                    Refresh_Token_Text001: Label 'New token received';
                    Refresh_Token_Text002: Label 'current Token still valid';
                begin
                    IF CWCProjectMgt.CheckToken(CurrentToken, DurationInt) then begin
                        if DurationInt <> 0 then begin
                            "Receipt Token" := CurrentToken;
                            "Token Executed" := CreateDateTime(Today, Time);
                            "Token Expired" := "Token Executed" + DurationInt;
                            Modify();
                            Message(Refresh_Token_Text001);
                        end
                        else
                            Message(Refresh_Token_Text002);
                    end
                    else
                        Error(GetLastErrorText);
                end;
            }
        }
    }
    trigger OnInit();
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;

    var
        myInt: Integer;
}
