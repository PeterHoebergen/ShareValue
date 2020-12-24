codeunit 50103 "CWC Project Management"
{
    trigger OnRun()
    begin
    end;

    var
        CWCSetup: Record "CWC Setup";

    [TryFunction]
    procedure CheckToken(var pToken: Text[100];
    var pDurationItg: Integer)
    var
        TableEventTemp: Record "Web Service Log" temporary;
        ok: Boolean;
        OutS: OutStream;
        InS: InStream;
        ResponseMessage: HttpResponseMessage;
        Content: HttpContent;
        JSonObj: JsonObject;
        JSonTk: JsonToken;
        Contenttxt: Text;
    begin
        ClearLastError();
        CWCSetup.Get();
        pToken := CWCSetup."Receipt Token";
        pDurationItg := 0;
        ok := (pToken = '') OR ((CreateDateTime(Today, time) + (10 * 60 * 1000)) >= CWCSetup."Token Expired"); //10 minutes from now
        if ok then begin
            CWCSetup.TestField(Username);
            CWCSetup.TestField(Password);
            CWCSetup.TestField("Refresh Token");
            TableEventTemp.Init();
            TableEventTemp.Endpoint := TableEventTemp.Endpoint::token;
            TableEventTemp."Integration Status" := TableEventTemp."Integration Status"::Pending;
            TableEventTemp."Request Action" := TableEventTemp."Request Action"::POST;
            TableEventTemp."OnEvent Type" := TableEventTemp."OnEvent Type"::Request;
            //WRITE json request
            TableEventTemp."JSon Request".CreateOutStream(OutS);
            Clear(JSonObj);
            JSonObj.Add('grant_type', 'refresh_token');
            JSonObj.Add('client_id', CWCSetup.Username);
            JSonObj.Add('client_secret', CWCSetup.Password);
            JSonObj.Add('refresh_token', CWCSetup."Refresh Token");
            JSonObj.WriteTo(OutS);
            //TableEvent.Insert();
            if TryMakeRequest(TableEventTemp, ResponseMessage) then begin
                Clear(JSonObj);
                Content.Clear();
                Content := ResponseMessage.Content();
                Content.ReadAs(InS);
                JSonObj.ReadFrom(InS);
                clear(JSonTk);
                JSonObj.SelectToken('access_token', JSonTk);
                pToken := JSonTk.AsValue().AsText();
                clear(JSonTk);
                JSonObj.SelectToken('expires_in', JSonTk);
                pDurationItg := 1000 * JSonTk.AsValue().AsInteger();
            end
            else begin
                Error(GetLastErrorText);
            end;
        end;
    end;

    procedure MakeRequest(var pTableEvent: Record "Web Service Log")
    var
        ResponseMessage: HttpResponseMessage;
        InS: InStream;
        OutS: OutStream;
        ok: Boolean;
        Content: HttpContent;
        CurrentToken: Text[100];
        DurationInt: Integer;
    begin
        ClearLastError();
        if CheckToken(CurrentToken, DurationInt) then begin
            //Update Setup if get new token
            if DurationInt <> 0 then begin
                CWCSetup."Receipt Token" := CurrentToken;
                CWCSetup."Token Executed" := CreateDateTime(Today, Time);
                CWCSetup."Token Expired" := CWCSetup."Token Executed" + DurationInt;
                CWCSetup.Modify();
                Commit();
            end;
            ClearLastError();
            if TryMakeRequest(pTableEvent, ResponseMessage) then begin
                clear(pTableEvent."JSon Response");
                Content.Clear();
                Content := ResponseMessage.Content();
                Content.ReadAs(InS);
                pTableEvent."JSon Response".CreateOutStream(OutS);
                CopyStream(OutS, InS);
                pTableEvent."Integration Status" := pTableEvent."Integration Status"::Sent;
                pTableEvent."Error Text" := '';
                pTableEvent."Response ID" := GetRequestIDFromResponseMsg(pTableEvent);
                pTableEvent."Request Date" := Today;
                pTableEvent.Modify();
            end
            else begin
                pTableEvent."Integration Status" := pTableEvent."Integration Status"::Error;
                pTableEvent."Error Text" := Copystr(GetLastErrorText, 1, 250);
                pTableEvent."Request Date" := Today;
                pTableEvent.Modify();
            end;
        end
        else begin
            pTableEvent."Integration Status" := pTableEvent."Integration Status"::Error;
            pTableEvent."Error Text" := Copystr(GetLastErrorText, 1, 250);
            pTableEvent."Request Date" := Today;
            pTableEvent.Modify();
        end;
    end;

    [TryFunction]
    local procedure TryMakeRequest(var pTableEvent: Record "Web Service Log";
    var ResponseMessage: HttpResponseMessage)
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        ContentHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        Content: HttpContent;
        Setup: Record "CWC Setup";
        InS: InStream;
        ok: Boolean;
        Contenttxt: Text;
    begin
        CWCSetup.Get();
        CWCSetup.TestField("Receipt Token");
        RequestMessage.Method := format(pTableEvent."Request Action");
        RequestMessage.SetRequestUri(GetURLEndPoint(pTableEvent));
        RequestMessage.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json');
        if (pTableEvent.Endpoint <> pTableEvent.Endpoint::token) and (pTableEvent.Endpoint <> pTableEvent.Endpoint::" ") then begin
            Headers.Add('Authorization', StrSubstNo('Bearer %1', CWCSetup."Receipt Token"));
            pTableEvent.CalcFields("JSon Request");
        end;
        if pTableEvent."JSon Request".HasValue then begin
            pTableEvent."JSon Request".CreateInStream(InS);
            Content.Clear();
            Content.WriteFrom(InS);
            Content.GetHeaders(ContentHeaders);
            ContentHeaders.Remove('Content-Type');
            ContentHeaders.Add('Content-Type', 'application/json');
            RequestMessage.Content := Content;
        end;
        Client.Send(RequestMessage, ResponseMessage);
        ok := ResponseMessage.IsSuccessStatusCode();
        if not ok then Error('%1: %2', ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase());
    end;

    local procedure GetURLEndPoint(pTableEvent: Record "Web Service Log"): Text[100]
    var
        Url: Text[250];
    begin
        CWCSetup.TestField("Base URL");
        Url := CWCSetup."Base URL";
        if not Url.EndsWith('/') then Url += '/';
        Case pTableEvent.Endpoint of
            pTableEvent.Endpoint::token:
                begin
                    Url += 'token';
                end;
            pTableEvent.Endpoint::project:
                begin
                    CWCSetup.TestField("Project Endpoint");
                    Url += CWCSetup."Project Endpoint"
                end;
        end;
        case pTableEvent."Request Action" of
            pTableEvent."Request Action"::GET, pTableEvent."Request Action"::PATCH, pTableEvent."Request Action"::DELETE:
                begin
                    pTableEvent.Testfield("Response ID");
                    Url += '/' + format(pTableEvent."Response ID");
                end;
        end;
        exit(Url);
    end;

    local procedure GetRequestIDFromResponseMsg(var pTableEvent: Record "Web Service Log"): Integer
    var
        rtv: Integer;
        InS: InStream;
        JSonObj: JsonObject;
        JSonTk: JsonToken;
    begin
        rtv := 0;
        Case pTableEvent.Endpoint of
            pTableEvent.Endpoint::project:
                begin
                    pTableEvent.CalcFields("JSon Response");
                    if pTableEvent."JSon Response".HasValue then begin
                        pTableEvent."JSon Response".CreateInStream(InS);
                        JSonObj.ReadFrom(InS);
                        if JSonObj.SelectToken('id', JSonTk) then begin
                            rtv := JSonTk.AsValue().AsInteger();
                        end;
                    end;
                end;
        end;
        exit(rtv);
    end;

    procedure GetRequestIDFromJobTask(pJobTask: record "Job Task"): Integer
    var
        TableEvent: Record "Web Service Log";
        RecRef: RecordRef;
        myRec: Record "Job Task";
    begin
        myRec := pJobTask;
        RecRef.GetTable(myRec);
        RecRef.SetRecFilter();
        TableEvent.SetCurrentKey("Table No.", "Record ID", "Response ID");
        TableEvent.SetRange("Table No.", Database::"Job Task");
        TableEvent.SetRange("Record ID", RecRef.RecordId);
        TableEvent.SetFilter("Response ID", '<>%1', 0);
        if TableEvent.FindFirst() then exit(TableEvent."Response ID");
        exit(0);
    end;

    procedure GetJobTaskFromResponseID(pResponseID: Integer;
    var pJobTask: Record "Job Task")
    var
        TableEvent: Record "Web Service Log";
        RecRef: RecordRef;
        JobTask: Record "Job Task";
    begin
        TableEvent.SetRange("Table No.", Database::"Job Task");
        TableEvent.SetRange(Endpoint, TableEvent.Endpoint::project);
        TableEvent.SetRange("Response ID", pResponseID);
        if TableEvent.FindFirst() then begin
            RecRef := TableEvent."Record ID".GetRecord();
            RecRef.SetTable(JobTask);
            pJobTask.Get(JobTask."Job No.", JobTask."Job Task No.");
        end
        else
            pJobTask.Init();
    end;
}
