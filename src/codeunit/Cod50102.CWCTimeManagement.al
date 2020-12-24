codeunit 50102 "CWC Time Management"
{
    procedure TestConnection(): Boolean
    var
        CWCRequest: Record "CWC Request" temporary;
        CWCSetup: Record "CWC Setup";
        EmptyRecId: RecordId;
        AutorizationType: Enum "Authorization Type";
    begin
        Clear(ProcessingError);
        EventLogMgt.SetEvent(CWCAPIMgt.GetEventId(), EventType::"List", EmptyRecId);
        CWCSetup.Get();
        if not ProcessingError then begin
            CWCRequest.URL := CopyStr(StrSubstNo('%1%2', CWCSetup."Base URL", CWCSetup."Hour Import Endpoint"), 1, 250);
            CWCRequest.RestMethod := CWCRequest.RestMethod::get;
            CWCRequest.Accept := 'application/json';
            CWCRequest.UserName := CWCSetup.Username;
            CWCRequest.Password := CWCSetup.Password;
            EventLogMgt.NewEventLog(LogType::Log, RequestCreatedLogTxt, '');
            if CWCAPIMgt.SendRequest(CWCRequest, AutorizationType::BasicUserPassword) then begin
                ProcessJson(CWCRequest.GetResponseContentAsText());
                EventLogMgt.NewEventLogWithContent(LogType::Log, ResponseReceivedLogTxt, '', CWCRequest.GetResponseContentAsText());
            end
            else begin
                EventLogMgt.NewEventLogWithContent(LogType::Error, SendRequestFailedLogTxt, StrSubstNo('%1 - %2', CWCRequest.StatusCode, CWCRequest.Reason), CWCRequest.GetResponseContentAsText());
                ProcessingError := true;
            end;
        end;
        if ProcessingError then begin
            EventLogMgt.ErrorNotify(StrSubstNo(ErrorNotifyTxt, EventLogMgt.GetEventText()), EventId);
            exit(false);
        end
        else
            exit(true);
    end;

    procedure GetHours(pStartDate: Date;
    pEndDate: Date;
    AutorizationType: Enum "Authorization Type"): Boolean
    var
        CWCRequest: Record "CWC Request" temporary;
        CWCSetup: Record "CWC Setup";
        EmptyRecId: RecordId;
        CWCProjectMgt: Codeunit "CWC Project Management";
        CurrentToken: Text[100];
        DurationInt: Integer;
        BaseURL: Text[250];
        EndPoint: Text[100];
        ResponseTxt: Text;
    begin
        Clear(ProcessingError);
        EventLogMgt.SetEvent(CWCAPIMgt.GetEventId(), EventType::"List", EmptyRecId);
        CWCSetup.Get();
        if not ProcessingError then begin
            BaseURL := CWCSetup."Base URL";
            if not BaseURL.EndsWith('/') then BaseURL += '/';
            EndPoint := CWCSetup."Hour Import Endpoint";
            if not EndPoint.EndsWith('/') then EndPoint += '/';
            if EndPoint.StartsWith('/') then EndPoint := CopyStr(EndPoint, 2);
            //https://sharevaluetest.clockwise.info/api/v2/report/flat/hours/start/2020-04-01/end/2020-04-07?fields=defaultfields
            CWCRequest.URL := CopyStr(StrSubstNo('%1%2start/%3/end/%4?fields=defaultfields,projectfields,employeefields,hourstatusfields', BaseURL, EndPoint, Format(pStartDate, 0, '<Year4>-<Month,2>-<Day,2>'), Format(pEndDate, 0, '<Year4>-<Month,2>-<Day,2>')), 1, 250);
            CWCRequest.RestMethod := CWCRequest.RestMethod::get;
            CWCRequest.Accept := 'application/json';
            CWCRequest.UserName := CWCSetup.Username;
            CWCRequest.Password := CWCSetup.Password;
            if AutorizationType = AutorizationType::Token then begin
                ClearLastError();
                if CWCProjectMgt.CheckToken(CurrentToken, DurationInt) then begin
                    //Update Setup if get new token
                    if DurationInt <> 0 then begin
                        CWCSetup."Receipt Token" := CurrentToken;
                        CWCSetup."Token Executed" := CreateDateTime(Today, Time);
                        CWCSetup."Token Expired" := CWCSetup."Token Executed" + DurationInt;
                        CWCSetup.Modify();
                        Commit();
                        CWCSetup.Get();
                    end;
                end
                else
                    Error(GetLastErrorText);
            end;
            CWCRequest.Token := CWCSetup."Receipt Token";
            EventLogMgt.NewEventLog(LogType::Log, RequestCreatedLogTxt, '');
            if CWCAPIMgt.SendRequest(CWCRequest, AutorizationType::Token) then begin
                ResponseTxt := CWCRequest.GetResponseContentAsText();
                ProcessJson(ResponseTxt);
                EventLogMgt.NewEventLogWithContent(LogType::Log, ResponseReceivedLogTxt, '', ResponseTxt);
            end
            else begin
                EventLogMgt.NewEventLogWithContent(LogType::Error, SendRequestFailedLogTxt, StrSubstNo('%1 - %2', CWCRequest.StatusCode, CWCRequest.Reason), CWCRequest.GetResponseContentAsText());
                ProcessingError := true;
            end;
        end;
        if ProcessingError then begin
            EventLogMgt.ErrorNotify(StrSubstNo(ErrorNotifyTxt, EventLogMgt.GetEventText()), EventId);
            exit(false);
        end
        else
            exit(true);
    end;

    procedure PullIntoJobJournal(var pJobJnlLine: record "Job Journal Line")
    begin
        pJobJnlLine.TestField("Journal Template Name");
        pJobJnlLine.TestField("Journal Batch Name");
        TransferIntoJobJnlLine := true;
        JobJnlLine := pJobJnlLine;
    end;

    procedure ProcessJson(JsonText: Text) succes: Boolean
    var
        CWCTimeRegistration: Record "CWC Time Registration";
        CWCHelperFunctions: Codeunit "CWC Helper Functions";
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        i: Integer;
        JsonHourObject: JsonObject;
        id: Integer;
        JobJnlLineNo: Integer;
        JnlLine: Record "Job Journal Line";
        salary_number: Integer;
        Resource: Record Resource;
        project_id_path: Text;
        project_id: Integer;
        project_id_list: List of [Text];
        TableEvent: record "Web Service Log";
        JobTask: Record "Job Task";
        RecReff: RecordRef;
        JobJnlBatch: Record "Job Journal Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ProcessJson_Text001: Label 'Invalid Response';
        ProcessJson_Text002: Label 'Could not find a token with key %1';
        ProcessJson_Text003: Label 'project_id 0 is invalid';
        ProcessJson_Text04: Label 'There is no Job Task with project id = %1';
    begin
        if TransferIntoJobJnlLine then begin
            JnlLine.SetRange("Journal Template Name", JobJnlLine."Journal Template Name");
            JnlLine.SetRange("Journal Batch Name", JobJnlLine."Journal Batch Name");
            if JnlLine.FindLast() then begin
                if JnlLine."No." = '' then
                    JnlLine.Delete(false);
                    JobJnlLineNo := JnlLine."Line No." - 10000;
                end else
                    JobJnlLineNo := JnlLine."Line No.";
        end;
        if not JsonArray.ReadFrom(JsonText) then Error(ProcessJson_Text001);
        Resource.SetCurrentKey("salary_number - Clockwise");
        TableEvent.SetCurrentKey("Table No.", "Record ID", "Response ID");
        for i := 0 to JsonArray.Count() - 1 do begin
            JsonArray.Get(i, JsonToken);
            JsonHourObject := JsonToken.AsObject();
            if not JsonHourObject.Get('id', JsonToken) then error(ProcessJson_Text002, JsonToken);

            if CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'hourstatus') = 'approved' then begin

                //<<Check Resource
                Resource.SetRange("No.", CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'salary_number'));
                Resource.findfirst; //error if not find
                                    //>>
                                    //<<Check Project
                project_id_path := CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'project_id_path');
                if strpos(project_id_path, ',') <> 0 then begin
                    project_id_list := project_id_path.Split(',');
                    Evaluate(project_id, project_id_list.Get(project_id_list.Count));
                end
                else
                    Evaluate(project_id, project_id_path);
                if project_id = 0 then error(ProcessJson_Text003);
                TableEvent.SetRange("Table No.", Database::"Job Task");
                TableEvent.SetRange("Response ID", project_id);
                if not TableEvent.FindFirst() then Error(ProcessJson_Text04, project_id);
                RecReff.Get(TableEvent."Record ID");
                RecReff.SetTable(JobTask);
                //>>
                Evaluate(id, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'id'));
                CWCTimeRegistration.SetCurrentKey(id);
                CWCTimeRegistration.SetRange(id, id);
                if not CWCTimeRegistration.FindFirst() then begin
                    //Register Hour
                    CWCTimeRegistration.Init();
                    CWCTimeRegistration."Entry No." := 0;
                    Evaluate(CWCTimeRegistration.ID, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'id'), 9);
                    Evaluate(CWCTimeRegistration.Date, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'date'), 9);
                    Evaluate(CWCTimeRegistration.day, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'day'), 9);
                    Evaluate(CWCTimeRegistration.weeknumber, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'weeknumber'), 9);
                    Evaluate(CWCTimeRegistration.hours, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'hours'), 9);
                    Evaluate(CWCTimeRegistration.resource_id, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'resource_id'), 9);
                    Evaluate(CWCTimeRegistration.remark, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'remark'), 9);
                    Evaluate(CWCTimeRegistration.resource_status, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'resource_status'), 9);
                    Evaluate(CWCTimeRegistration.resource_parent_id, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'resource_parent_id'), 9);
                    Evaluate(CWCTimeRegistration.employee_id, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'employee_id'), 9);
                    Evaluate(CWCTimeRegistration.employee_name, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'employee_name'), 9);
                    //Evaluate(CWCTimeRegistration.salary_number, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'salary_number'), 9);
                    Evaluate(CWCTimeRegistration.department_id_path, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'department_id_path'), 9);
                    Evaluate(CWCTimeRegistration.department_name_path, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'department_name_path'), 9);
                    Evaluate(CWCTimeRegistration.department_code_path, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'department_code_path'), 9);
                    Evaluate(CWCTimeRegistration.customer_id_path, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'customer_id_path'), 9);
                    Evaluate(CWCTimeRegistration.customer_name_path, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'customer_name_path'), 9);
                    Evaluate(CWCTimeRegistration.customer_code_path, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'customer_code_path'), 9);
                    Evaluate(CWCTimeRegistration.project_id_path, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'project_id_path'), 9);
                    Evaluate(CWCTimeRegistration.project_name_path, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'project_name_path'), 9);
                    Evaluate(CWCTimeRegistration.project_code_path, CWCHelperFunctions.GetJsonValueAsText(JsonHourObject, 'project_code_path'), 9);
                    CWCTimeRegistration.Insert(true);

                    //Process into Jpb Journal
                    if TransferIntoJobJnlLine then begin
                        JobJnlLineNo += 10000;
                        JnlLine.Init();
                        JnlLine.Validate("Journal Template Name", JobJnlLine."Journal Template Name");
                        JnlLine.Validate("Journal Batch Name", JobJnlLine."Journal Batch Name");
                        JnlLine."Line No." := JobJnlLineNo;
                        JnlLine.Insert(true);
                        JobJnlBatch.Get(JnlLine."Journal Template Name", JnlLine."Journal Batch Name");
                        //if JobJnlBatch."No. Series" <> '' then begin
                            clear(NoSeriesMgt);
                            //JnlLine."Document No." := NoSeriesMgt.GetNextNo(JobJnlBatch."No. Series", JnlLine."Posting Date", true);
                            JnlLine."Document No." := NoSeriesMgt.GetNextNo('PRJDB-ALG', Today(), true);
                        //end;
                        JnlLine.Validate("Line Type", JnlLine."Line Type"::Billable);
                        JnlLine.Validate("Posting Date", CWCTimeRegistration.date);
                        //JnlLine."Document No." := 'CHANGE';
                        JnlLine.Validate("Job No.", JobTask."Job No.");
                        JnlLine.Validate("Job Task No.", JobTask."Job Task No.");
                        JnlLine.Validate(Type, JnlLine.Type::Resource);
                        JnlLine.Validate("No.", Resource."No.");
                        //JnlLine.Description := CWCTimeRegistration.remark;
                        JnlLine.Validate(Quantity, CWCTimeRegistration.hours); //LAGI : how to unsure this hours is approved ?
                        JnlLine.Modify(true);
                    end;
                end;
            end;
            /*
                        "id": 82,
                        "date": "2013-01-01",
                        "day": "Tue",
                        "weeknumber": 1,
                        "hours": 8,
                        "units": null,
                        "resource_id": 213,
                        "remark": null,
                        "export_ch1_id": 54,
                        "export_ch2_id": 0,
                        "travel_costs": 0,
                        "expenses": 0,
                        "travel_km": 0,
                        "comute_km": 0,
                        "resource_status": "closed",
                        "resource_parent_id": 28,
                        "employee_id": 16,
                        "employee_name": "Rob Jansen",
                        "salary_number": "52",
                        "employee_function": "developer",
                        "employee_email": "r.jansen@sharevalue.nl",
                        "reference_number": null,
                        "unbillable": 0,
                        "internal": 0,
                        "absent": 0,
                        "project_type_inherited": "Begrensd project",
                        "invoice_number": null,
                        "invoice_id": 0,
                        "hourstatus_modified_by": "Beheerder ",
                        "hourstatus_modified_at": "2013-02-06 13:05:48",
                        "hourstatus": "approved",
                        "hourly_sales_rate": null,
                        "hourly_sales_rate_name": null,
                        "hourly_sales_rate_id": 0,
                        "km_sales_rate": null,
                        "km_sales_rate_name": null,
                        "km_sales_rate_id": 0,
                        "unit_sales_rate": null,
                        "unit_sales_rate_name": null,
                        "unit_sales_rate_id": 0,
                        "department_id_path": "7,376,383",
                        "department_name_path": "Direct mdw \/ Premium \/ P uit dienst",
                        "department_code_path": " \/  \/ ",
                        "customer_id_path": "16",
                        "customer_name_path": "ShareValue intern",
                        "customer_code_path": "19",
                        "project_id_path": "28",
                        "project_name_path": "2013 Feestdagen",
                        "project_code_path": ""
                    */
            //
        end;
    end;

    var
        TransferIntoJobJnlLine: Boolean;
        JobJnlLine: Record "Job Journal Line";
        CWCAPIMgt: Codeunit "CWC API Management";
        EventLogMgt: Codeunit EventLogMgt_bbs;
        EventId: Guid;
        EventType: Enum EventType_bbs;
        LogType: Enum LogType_bbs;
        ProcessingError: Boolean;
        RequestCreatedLogTxt: Label 'Created Webshop Request';
        ResponseReceivedLogTxt: Label 'Received Webshop Response';
        SendRequestFailedLogTxt: Label 'Sending Webshop Request Failed';
        ErrorNotifyTxt: Label 'An error occured during event: %1', Comment = '%1 Event Description';
}
