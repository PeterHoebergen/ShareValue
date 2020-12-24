report 50000 "CWC Import Hours"
{
    Caption = 'ClockWise - Import Hours';
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Filter)
                {
                    group("Job Journal Template and Batch")
                    {
                        ShowCaption = false;

                        field("Journal Template"; JobJnlLine."Journal Template Name")
                        {
                            Caption = 'Journal Template';
                            ToolTip = ' ';
                            ApplicationArea = All;

                            trigger OnAssistEdit()
                            var
                                JournalTemplates: Record "Job Journal Template";
                            begin
                                if Page.RunModal(0, JournalTemplates) = Action::LookupOK then begin
                                    JobJnlLine."Journal Template Name" := JournalTemplates.Name;
                                end;
                            end;
                        }
                        field("Journal Batch"; JobJnlLine."Journal Batch Name")
                        {
                            Caption = 'Journal Batch';
                            ToolTip = ' ';
                            ApplicationArea = All;

                            trigger OnAssistEdit()
                            var
                                JournalBatchOnAssistEdit_Text001: Label 'Please Specify Journal Template';
                                JournalBatchs: Record "Job Journal Batch";
                            begin
                                if JobJnlLine."Journal Template Name" = '' then begin
                                    Message(JournalBatchOnAssistEdit_Text001);
                                    exit;
                                end;
                                JournalBatchs.SetRange("Journal Template Name", JobJnlLine."Journal Template Name");
                                if Page.RunModal(0, JournalBatchs) = Action::LookupOK then begin
                                    JobJnlLine."Journal Batch Name" := JournalBatchs.Name;
                                end;
                            end;
                        }
                    }
                    field(Period; Period)
                    {
                        ToolTip = ' ';
                        ApplicationArea = All;
                        OptionCaption = 'Day,Week,Month,Year,Date Range';

                        trigger OnValidate()
                        begin
                            Clear(DayVisible);
                            Clear(WeekVisible);
                            Clear(MonthVisible);
                            Clear(YearVisible);
                            Clear(RangeVisible);
                            case Period of
                                Period::Day:
                                    DayVisible := true;
                                Period::Week:
                                    WeekVisible := true;
                                Period::Month:
                                    MonthVisible := true;
                                Period::Year:
                                    YearVisible := true;
                                Period::"Date Range":
                                    RangeVisible := true;
                            end;
                            CurrReport.RequestOptionsPage.Update(false);
                        end;
                    }
                    group(Date)
                    {
                        ShowCaption = false;
                        Visible = DayVisible;

                        field(DayDate; DayDate)
                        {
                            Caption = 'Date';
                            ToolTip = ' ';
                            ApplicationArea = All;
                        }
                    }
                    group(Week)
                    {
                        ShowCaption = false;
                        Visible = WeekVisible;

                        field(WeekNo; WeekNo)
                        {
                            Caption = 'Week';
                            ToolTip = ' ';
                            ApplicationArea = All;
                        }
                    }
                    group(Month)
                    {
                        ShowCaption = false;
                        Visible = MonthVisible;

                        field(MonthNo; MonthNo)
                        {
                            Caption = 'Month';
                            ToolTip = ' ';
                            ApplicationArea = All;
                        }
                    }
                    group(Year)
                    {
                        ShowCaption = false;
                        Visible = YearVisible or WeekVisible or MonthVisible;

                        field(YearNo; YearNo)
                        {
                            Caption = 'Year';
                            ToolTip = ' ';
                            ApplicationArea = All;
                        }
                    }
                    group(DateRange)
                    {
                        ShowCaption = false;
                        Visible = RangeVisible;

                        field(StartDate; StartDate)
                        {
                            Caption = 'Start Date';
                            ToolTip = ' ';
                            ApplicationArea = All;
                        }
                        field(EndDate; EndDate)
                        {
                            Caption = 'End Date';
                            ToolTip = ' ';
                            ApplicationArea = All;
                        }
                    }
                }
            }
        }
        trigger OnInit()
        begin
            DayVisible := true;
        end;

        trigger OnOpenPage()
        var
            JobJnlTemplate: Record "Job Journal Template";
        begin
            if JobJnlLine."Journal Template Name" = '' then begin
                JobJnlTemplate.Reset();
                JobJnlTemplate.SetRange("Page ID", PAGE::"Job Journal");
                JobJnlTemplate.SetRange(Recurring, false);
                if JobJnlTemplate.FindFirst() then JobJnlLine."Journal Template Name" := JobJnlTemplate.Name;
            end;
        end;

        trigger OnQueryClosePage(Closeaction: Action): Boolean
        var
            myInt: Integer;
        begin
            if Closeaction in [Action::OK, Action::LookupOK, Action::Yes] then begin
                JobJnlLine.TestField("Journal Template Name");
                JobJnlLine.TestField("Journal Batch Name");
            end;
        end;

        var
            DayVisible: Boolean;
            WeekVisible: Boolean;
            MonthVisible: Boolean;
            YearVisible: Boolean;
            RangeVisible: Boolean;
    }
    /*
      trigger OnInitReport()
      var
          SetDateRange_Text007: Label 'Invalid Job Journal Setting';

          JobJnlManagement: Codeunit JobJnlManagement;
          JnlSelected: Boolean;
      begin
          //Manage Job Journal : template and Batch
          IF not OpenFromBatch then begin
              JobJnlManagement.TemplateSelection(PAGE::"Job Journal", false, JobJnlLine, JnlSelected);
              if not JnlSelected then
                  Error(SetDateRange_Text007);
          end;
      end;
      */
    trigger OnPreReport()
    var
        SetDateRange_Text001: Label 'Please specify start date';
        SetDateRange_Text002: Label 'Please specify end date';
        SetDateRange_Text003: Label 'Please specify a date';
        SetDateRange_Text004: Label 'Please specify year and week no.';
        SetDateRange_Text005: Label 'Please specify year and month';
        SetDateRange_Text006: Label 'Please specify a year';
        TimeMgt: Codeunit "CWC Time Management";
        AuthorizationType: enum "Authorization Type";
    begin
        //Get Hours
        case Period of
            Period::"Date Range":
                begin
                    if StartDate = 0D then Error(SetDateRange_Text001);
                    if EndDate = 0D then Error(SetDateRange_Text002);
                end;
            Period::Day:
                begin
                    if DayDate = 0D then Error(SetDateRange_Text003);
                    StartDate := DayDate;
                    EndDate := DayDate;
                end;
            Period::Week:
                begin
                    if YearNo = 0 then Error(SetDateRange_Text004);
                    if WeekNo = 0 then Error(SetDateRange_Text004);
                    StartDate := DWY2Date(1, WeekNo, YearNo);
                    EndDate := DWY2Date(7, WeekNo, YearNo);
                end;
            period::Month:
                begin
                    if YearNo = 0 then Error(SetDateRange_Text005);
                    if MonthNo = 0 then Error(SetDateRange_Text005);
                    StartDate := DMY2Date(1, MonthNo, YearNo);
                    EndDate := CalcDate('<CM>', StartDate);
                end;
            Period::Year:
                begin
                    if YearNo = 0 then Error(SetDateRange_Text006);
                    StartDate := DMY2Date(1, 1, YearNo);
                    EndDate := DMY2Date(31, 12, YearNo);
                end;
            else
                Error('Under Development');
        end;
        TimeMgt.PullIntoJobJournal(JobJnlLine);
        TimeMgt.GetHours(StartDate, EndDate, AuthorizationType::Token);
    end;

    trigger OnPostReport()
    var
        JobJnlPage: Page "Job Journal";
        JnlLine: Record "Job Journal Line";
    begin
        JnlLine.SetRange("Journal Template Name", JobJnlLine."Journal Template Name");
        JnlLine.SetRange("Journal Batch Name", JobJnlLine."Journal Batch Name");
        Clear(JobJnlPage);
        JobJnlPage.SetTableView(JnlLine);
        JobJnlPage.Run();
    end;

    procedure SetParameters(var pJobJnlLine: record "Job Journal Line")
    var
    begin
        JobJnlLine := pJobJnlLine;
    end;

    var
        JobJnlLine: record "Job Journal Line";
        myInt: Integer;
        Period: Option "Day","Week","Month","Year","Date Range";
        DayDate: Date;
        WeekNo: Integer;
        MonthNo: Integer;
        YearNo: Integer;
        StartDate: Date;
        EndDate: Date;
}
