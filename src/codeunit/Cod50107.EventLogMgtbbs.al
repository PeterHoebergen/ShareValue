codeunit 50107 "EventLogMgt_bbs"
{
    trigger OnRun()
    begin
    end;

    procedure ApplyRetentionPeriod(Period: DateFormula): Boolean
    var
        EventLog: Record EventLog_bbs;
        FromDT: DateTime;
    begin
        if Format(Period) <> '' then begin
            FromDT := CreateDateTime(CalcDate(StrSubstNo('<-%1>', Period), WorkDate()), 000000T);
            EventLog.SetRange(EventDT, 0DT, FromDT);
            EventLog.DeleteAll();
        end;
    end;

    procedure SetEvent(EventID: Guid;
    EventType: Enum EventType_bbs;
    RecId: RecordId)
    var
    begin
        CurrEventID := EventID;
        CurrEventType := EventType;
        CurrRecordId := RecId;
    end;

    procedure NewEventStep(var EventLog: Record EventLog_bbs)
    var
    begin
        EventLog.Init();
        EventLog.Validate(EventID, CurrEventID);
        EventLog.Validate(EventStep, GetNextEventStep(CurrEventID));
        EventLog.Validate(EventDT, CurrentDateTime());
        EventLog.Validate(EventType, CurrEventType);
        EventLog.Validate(ObjectID, CurrRecordId.TableNo());
        EventLog.Validate(ObjectKey, GetKeyString(CurrRecordId));
        EventLog.Insert();
        EventLog.Validate(EventText, SetEventText(EventLog));
        EventLog.Modify();
    end;

    procedure NewEventLog(NewLogType: Enum LogType_bbs;
    NewLogText: Text[250];
    NewLogErrorText: Text[250]): Boolean
    var
        EventLog: Record EventLog_bbs;
        EventLogSetup: Record EventLogSetup_bbs;
    begin
        EventLogSetup.GET();
        if not EventLogSetup."Enable Event Logging" then exit;
        NewEventStep(EventLog);
        EventLog.Validate(LogType, NewLogType);
        EventLog.Validate(LogText, NewLogText);
        EventLog.Validate(LogErrorText, NewLogErrorText);
        EventLog.Modify();
        ApplyRetentionPeriod(EventLogSetup."Retention Period");
    end;

    procedure NewEventLogWithContent(NewLogType: Enum LogType_bbs;
    NewLogText: Text[250];
    NewLogErrorText: Text[250];
    NewLogContent: Text): Boolean
    var
        EventLog: Record EventLog_bbs;
        EventLogSetup: Record EventLogSetup_bbs;
        EventOS: OutStream;
    begin
        EventLogSetup.GET();
        if not EventLogSetup."Enable Event Logging" then exit;
        NewEventStep(EventLog);
        EventLog.Validate(LogType, NewLogType);
        EventLog.Validate(LogText, NewLogText);
        EventLog.Validate(LogErrorText, NewLogErrorText);
        EventLog.Modify();
        if StrLen(NewLogContent) > 0 then begin
            EventLog.HasContent := true;
            EventLog.LogContent.CreateOutStream(EventOS);
            EventOS.WriteText(NewLogContent);
            EventLog.Modify();
        end;
        ApplyRetentionPeriod(EventLogSetup."Retention Period");
    end;

    procedure GetNextEventStep(NewEventID: Guid) Step: Integer
    var
        EventLog: Record EventLog_bbs;
    begin
        Step := 1;
        EventLog.SetRange(EventID, NewEventID);
        if EventLog.FindLast() then Step := EventLog.EventStep + 1;
    end;

    procedure GetKeyString(NewRecordId: RecordId) KeyString: Text
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        KeyRef: KeyRef;
        i: Integer;
        FieldCaption: Text;
        FieldValue: Text;
    begin
        if not RecRef.Get(NewRecordId) then exit('');
        KeyRef := RecRef.KeyIndex(1);
        for i := 1 to KeyRef.FieldCount() do begin
            FldRef := KeyRef.FieldIndex(i);
            FieldCaption := FldRef.Caption();
            FieldValue := Format(FldRef.Value());
            if KeyString = '' then
                KeyString := StrSubstNo('%1:%2', FieldCaption, FieldValue)
            else
                KeyString := StrSubstNo('%1; %2:%3', KeyString, FieldCaption, FieldValue);
        end;
        KeyString := CopyStr(KeyString, 1, 100);
    end;

    procedure SetEventText(EventLog: Record EventLog_bbs): Text
    var
        RecRef: RecordRef;
    begin
        if EventLog.ObjectID = 0 then exit('');
        RecRef.Open(EventLog.ObjectID);
        CurrEventText := StrSubstNo('%1 %2 (%3)', Format(EventLog.EventType), RecRef.Caption(), EventLog.ObjectKey);
        exit(CurrEventText);
    end;

    procedure GetEventText(): Text
    begin
        exit(CurrEventText);
    end;

    procedure ErrorNotify(NotificationMessage: Text;
    EventID: Text);
    var
        MyNotification: Notification;
        MsgLogInformationTxt: Label 'See log for more information.'; //TextConst ENU='See log for more information.',NLD='Bekijk log voor meer informatie.';
    begin
        MyNotification.MESSAGE := NotificationMessage;
        MyNotification.SCOPE := NOTIFICATIONSCOPE::LocalScope;
        MyNotification.SETDATA('ID', FORMAT(EventID));
        MyNotification.ADDACTION(MsgLogInformationTxt, CODEUNIT::EventLogMgt_bbs, 'OpenLog');
        MyNotification.SEND();
    end;

    procedure OpenLog(MyNotification: Notification);
    var
        EventLog: Record EventLog_bbs;
        MsgNoLogTxt: Label 'No log present.'; //TextConst ENU='No log present.',NLD='Geen log aanwezig.';
    begin
        EventLog.SetRange(EventID, MyNotification.GetData('ID'));
        if EventLog.FindSet() then
            Page.Run(Page::EventLogList_bbs, EventLog)
        else
            Error(MsgNoLogTxt);
    end;

    procedure OpenPage(MyNotification: Notification);
    var
        RecordID: RecordID;
        RecRef: RecordRef;
        TableID: Integer;
        VarRecRef: Variant;
    begin
        //CONCEPT
        EVALUATE(TableID, MyNotification.GETDATA('TABLEID'));
        EVALUATE(RecordID, MyNotification.GETDATA('RECORDID'));
        RecRef.CLOSE();
        CLEAR(RecRef);
        RecRef.OPEN(TableID, false, COMPANYNAME());
        RecRef.GET(RecordID);
        VarRecRef := RecRef;
        PAGE.RUNMODAL(VarRecRef);
    end;

    var
        CurrRecordId: RecordId;
        CurrEventID: Guid;
        CurrEventType: Enum EventType_bbs;
        CurrEventText: Text;
}
