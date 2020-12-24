codeunit 50104 "Clockwise Event Subscription"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Create-Invoice", 'OnBeforeModifySalesHeader', '', false, false)]
    local procedure Cod_JobCreateInvoice_OnBeforeModifySalesHeader(var SalesHeader: Record "Sales Header";
    Job: Record Job)
    begin
        if job."Payment Terms Code" <> '' then begin
            if SalesHeader."Document Date" = 0D then SalesHeader.validate("Document Date", Today);
            SalesHeader.Validate("Payment Terms Code", Job."Payment Terms Code");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Create-Invoice", 'OnAfterCreateSalesLine', '', false, false)]
    local procedure Cod_JobCreateInvoice_OnAfterCreateSalesLine_subs(var SalesLine: Record "Sales Line";
    SalesHeader: Record "Sales Header";
    Job: Record Job;
    JobPlanningLine: Record "Job Planning Line")
    var
        JobTask: Record "Job Task";
        SH: Record "Sales Header";
    begin
        if JobTask.Get(JobPlanningLine."Job No.", JobPlanningLine."Job Task No.") then
            if JobTask."External Document No." <> '' then begin
                SH := SalesHeader;
                SH.Find();
                SH.validate("External Document No.", JobTask."External Document No.");
                SH.Modify();
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Task", 'OnAfterInsertEvent', '', false, false)]
    local procedure TblJobTask_OnAfterInsertEvent_subs(var Rec: Record "Job Task";
    RunTrigger: Boolean)
    var
        TableEvent: Record "Web Service Log";
        JSonText: Text;
        OutS: OutStream;
        RequestAction: Enum "Request Action";
    begin
        if JobTaskMeetInsertCriteria(Rec, JSonText, RequestAction) then begin
            TableEvent.Init();
            TableEvent."Entry No." := 0;
            TableEvent."Entry Date" := Today;
            TableEvent."Table No." := Database::"Job Task";
            TableEvent."Record ID" := Rec.RecordId;
            TableEvent."OnEvent Type" := TableEvent."OnEvent Type"::Insert;
            TableEvent."Integration Status" := TableEvent."Integration Status"::Pending;
            TableEvent.Endpoint := TableEvent.Endpoint::project;
            TableEvent."Request Action" := RequestAction;
            Clear(TableEvent."JSon Request");
            TableEvent."JSon Request".CreateOutStream(OutS);
            OutS.Write(JSonText);
            Clear(TableEvent."JSon Response");
            TableEvent."Response ID" := 0;
            TableEvent."Error Text" := '';
            TableEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Task", 'OnAfterDeleteEvent', '', false, false)]
    local procedure TblJobTask_OnAfterDeleteEvent_subs(var Rec: Record "Job Task";
    RunTrigger: Boolean)
    var
        TableEvent: Record "Web Service Log";
        TableEvent2: Record "Web Service Log";
        JSonText: Text;
        RequestAction: Enum "Request Action";
        ResponseID: Integer;
        InsertedEntryNo: Integer;
    begin
        ResponseID := 0;
        TableEvent2.Reset();
        TableEvent2.SetCurrentKey("Record ID", "OnEvent Type", "Integration Status");
        TableEvent2.SetRange("Record ID", rec.RecordId);
        TableEvent2.SetRange("Integration Status", TableEvent2."Integration Status"::Sent);
        TableEvent2.SetFilter("OnEvent Type", '%1|%2', TableEvent2."OnEvent Type"::Insert, TableEvent2."OnEvent Type"::Modify);
        TableEvent2.SetFilter("Response ID", '<>%1', 0);
        if TableEvent2.FindFirst() then ResponseID := TableEvent2."Response ID";
        if ResponseID = 0 then exit;
        if JobTaskMeetDeleteCriteria(Rec, JSonText, RequestAction, ResponseID) then begin
            TableEvent.Init();
            TableEvent."Entry No." := 0;
            TableEvent."Entry Date" := Today;
            TableEvent."Table No." := Database::"Job Task";
            TableEvent."Record ID" := Rec.RecordId;
            TableEvent."OnEvent Type" := TableEvent."OnEvent Type"::Delete;
            TableEvent."Integration Status" := TableEvent."Integration Status"::Pending;
            TableEvent.Endpoint := TableEvent.Endpoint::project;
            TableEvent."Request Action" := RequestAction;
            Clear(TableEvent."JSon Request");
            Clear(TableEvent."JSon Response");
            TableEvent."Response ID" := ResponseID;
            TableEvent."Error Text" := '';
            TableEvent.Insert(true);
            InsertedEntryNo := TableEvent."Entry No.";
        end;
        //Delete All related record that has status integration <> Sent
        TableEvent2.Reset();
        TableEvent2.SetCurrentKey("Record ID", "OnEvent Type", "Integration Status");
        TableEvent2.SetRange("Record ID", rec.RecordId);
        TableEvent2.SetFilter("Integration Status", '<>%1', TableEvent2."Integration Status"::Sent);
        if InsertedEntryNo <> 0 then TableEvent2.SetFilter("Entry No.", '<>%1', InsertedEntryNo);
        if TableEvent2.FindFirst() then TableEvent2.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Task", 'OnAfterModifyEvent', '', false, false)]
    local procedure TblJobTask_OnAfterModifyEvent_subs(var Rec: Record "Job Task";
    var xRec: Record "Job Task";
    RunTrigger: Boolean)
    var
        TableEvent: Record "Web Service Log";
        JSonText: Text;
        OutS: OutStream;
        RequestAction: Enum "Request Action";
        ResponseID: Integer;
    begin
        if JobTaskMeetModifyCriteria(Rec, xRec, JSonText, RequestAction, ResponseID) then begin
            TableEvent.Init();
            TableEvent."Entry No." := 0;
            TableEvent."Entry Date" := Today;
            TableEvent."Table No." := Database::"Job Task";
            TableEvent."Record ID" := Rec.RecordId;
            TableEvent."OnEvent Type" := TableEvent."OnEvent Type"::Modify;
            TableEvent."Integration Status" := TableEvent."Integration Status"::Pending;
            TableEvent.Endpoint := TableEvent.Endpoint::project;
            TableEvent."Request Action" := RequestAction;
            Clear(TableEvent."JSon Request");
            TableEvent."JSon Request".CreateOutStream(OutS);
            OutS.Write(JSonText);
            Clear(TableEvent."JSon Response");
            TableEvent."Response ID" := ResponseID;
            TableEvent."Error Text" := '';
            TableEvent.Insert(true);
        end;
    end;

    local procedure JobTaskMeetDeleteCriteria(var Rec: Record "Job Task";
    var pJSonText: Text;
    var pRequestAction: Enum "Request Action";
    ResponseID: Integer): Boolean
    var
        TableEvent: record "Web Service Log";
        ok: Boolean;
    begin
        //for deletion : it is not need verify ClockwiseCustNo 
        ok := (Rec."Job No." <> '') and (Rec."Job Task No." <> '') and (rec."Job Task Type" = Rec."Job Task Type"::Posting) and (Rec.Description <> '');
        pJSonText := '';
        pRequestAction := pRequestAction::DELETE;
        if ok then begin
            TableEvent.SetCurrentKey("Record ID", "OnEvent Type", "Integration Status");
            TableEvent.SetRange("Record ID", rec.RecordId);
            TableEvent.SetRange("OnEvent Type", TableEvent."OnEvent Type"::Delete);
            TableEvent.SetFilter("Integration Status", '<>%1', TableEvent."Integration Status"::Sent);
            if TableEvent.FindFirst() then begin
                if TableEvent."Integration Status" <> TableEvent."Integration Status"::Pending then begin
                    TableEvent."Integration Status" := TableEvent."Integration Status"::Pending;
                    TableEvent.Modify();
                end;
                ok := TableEvent."Response ID" = 0; //must has a response id
                if ok then
                    if ResponseID <> 0 then begin
                        TableEvent."Response ID" := ResponseID;
                        TableEvent.Modify();
                        ok := false;
                    end
                    else
                        TableEvent.Delete(); //delete if respnse id = 0, then system will create new log
            end;
        end;
        exit(ok);
    end;

    local procedure JobTaskMeetInsertCriteria(var Rec: Record "Job Task";
    var pJSonText: Text;
    var pRequestAction: Enum "Request Action"): Boolean
    var
        TableEvent: record "Web Service Log";
        Job: Record Job;
        ok: Boolean;
        JSon: JsonObject;
        OutS: OutStream;
        Txt: Text;
        ClockwiseCustNo: Code[20];
    begin
        Rec.CalcFields("Schedule (Total Hours)");
        Job.Get(Rec."Job No.");
        ClockwiseCustNo := GetClockwiseCustomerNo(Rec);
        ok := (ClockwiseCustNo <> '') and (Rec."Job No." <> '') and (Rec."Job Task No." <> '') and (rec."Job Task Type" = Rec."Job Task Type"::Posting) and (Rec.Description <> '');
        //Create New JSon
        Clear(JSon); //POST
        JSon.Add('parent', ClockwiseCustNo);
        JSon.Add('project_code', StrSubstNo('%1-%2', Rec."Job No.", Rec."Job Task No."));
        JSon.Add('name', Rec.Description);
        JSon.Add('reference_number', ClockwiseCustNo);
        JSon.Add('start_date', Job."Starting Date");
        JSon.Add('end_date', Job."Ending Date");
        JSon.Add('hours_budgetted', Rec."Schedule (Total Hours)");
        JSon.WriteTo(pJSonText);
        pRequestAction := pRequestAction::POST;
        //if ok then lookup same record with event = modify and check sent status , not sent then update else system will insert new log
        if ok then begin
            TableEvent.SetCurrentKey("Record ID", "OnEvent Type", "Integration Status");
            TableEvent.SetRange("Record ID", rec.RecordId);
            TableEvent.SetRange("OnEvent Type", TableEvent."OnEvent Type"::Insert);
            TableEvent.SetFilter("Integration Status", '<>%1', TableEvent."Integration Status"::Sent);
            if TableEvent.FindFirst() then begin
                TableEvent."Integration Status" := TableEvent."Integration Status"::Pending;
                clear(TableEvent."JSon Request");
                TableEvent."JSon Request".CreateOutStream(OutS);
                JSon.WriteTo(Txt);
                OutS.Write(Txt);
                clear(TableEvent."JSon Response");
                TableEvent.Modify();
                ok := false;
            end
            else begin
                TableEvent.SetRange("Integration Status", TableEvent."Integration Status"::Sent);
                TableEvent.SetFilter("Response ID", '<>%1', 0);
                ok := TableEvent.IsEmpty();
            end;
        end;
        exit(ok);
    end;

    local procedure JobTaskMeetModifyCriteria(var Rec: Record "Job Task";
    var xRec: Record "Job Task";
    var pJSonText: Text;
    var pRequestAction: Enum "Request Action";
    var pResponseID: Integer): Boolean
    var
        ok: Boolean;
        TableEvent: record "Web Service Log";
        Job: Record Job;
        JSon: JsonObject;
        OutS: OutStream;
        Txt: Text;
        ClockwiseCustNo: Code[20];
    begin
        Rec.CalcFields("Schedule (Total Hours)");
        Job.Get(Rec."Job No.");
        ClockwiseCustNo := GetClockwiseCustomerNo(Rec);
        ok := (ClockwiseCustNo <> '') and ((xRec."Job No." <> Rec."Job No.") or (xRec."Job Task No." <> Rec."Job Task No.") or (xrec."Job Task Type" = rec."Job Task Type") or (xRec.Description <> Rec.Description));
        //
        ok := (ClockwiseCustNo <> '');
        //
        pJSonText := '';
        pResponseID := 0;
        //if ok then lookup same record with event = modify and check sent status , not sent then update else system will insert new log
        if ok then begin
            TableEvent.SetCurrentKey("Record ID", "OnEvent Type", "Integration Status");
            TableEvent.SetRange("Record ID", rec.RecordId);
            TableEvent.Setfilter("OnEvent Type", '%1|%2', TableEvent."OnEvent Type"::Insert, TableEvent."OnEvent Type"::Modify);
            TableEvent.SetFilter("Integration Status", '<>%1', TableEvent."Integration Status"::Sent);
            if TableEvent.FindFirst() then begin
                //Create New JSon
                //if Response ID not Exist
                pResponseID := TableEvent."Response ID";
                if pResponseID = 0 then begin
                    Clear(JSon); //POST
                    JSon.Add('parent', ClockwiseCustNo);
                    JSon.Add('project_code', StrSubstNo('%1-%2', Rec."Job No.", Rec."Job Task No."));
                    JSon.Add('name', Rec.Description);
                    Json.Add('description', StrSubstNo('Uren per week:%1', Rec."Hours per Week"));
                    JSon.Add('reference_number', ClockwiseCustNo);
                    JSon.Add('start_date', Job."Starting Date");
                    JSon.Add('end_date', Job."Ending Date");
                    JSon.Add('hours_budgetted', Rec."Schedule (Total Hours)");
                    pRequestAction := pRequestAction::POST;
                end
                else begin
                    //if Response ID Exist
                    Clear(JSon); //PATCH
                    JSon.Add('parent', ClockwiseCustNo);
                    JSon.Add('name', Rec.Description);
                    Json.Add('description', StrSubstNo('Uren per week:%1', Rec."Hours per Week"));
                    JSon.Add('reference_number', ClockwiseCustNo);
                    JSon.Add('start_date', Job."Starting Date");
                    JSon.Add('end_date', Job."Ending Date");
                    JSon.Add('hours_budgetted', Rec."Schedule (Total Hours)");
                    pRequestAction := pRequestAction::PATCH;
                end;
                TableEvent."Integration Status" := TableEvent."Integration Status"::Pending;
                clear(TableEvent."JSon Request");
                TableEvent."JSon Request".CreateOutStream(OutS);
                JSon.WriteTo(Txt);
                OutS.Write(Txt);
                clear(TableEvent."JSon Response");
                TableEvent.Modify();
                ok := false;
            end
            else begin
                //Assume ID not Exist
                Clear(JSon); //POST
                JSon.Add('parent', ClockwiseCustNo);
                JSon.Add('project_code', StrSubstNo('%1-%2', Rec."Job No.", Rec."Job Task No."));
                JSon.Add('name', Rec.Description);
                Json.Add('description', StrSubstNo('Uren per week:%1', Rec."Hours per Week"));
                JSon.Add('reference_number', ClockwiseCustNo);
                JSon.Add('start_date', Job."Starting Date");
                JSon.Add('end_date', Job."Ending Date");
                JSon.Add('hours_budgetted', Rec."Schedule (Total Hours)");
                pRequestAction := pRequestAction::POST;
                TableEvent.SetRange("Integration Status", TableEvent."Integration Status"::Sent);
                if TableEvent.FindFirst() then begin
                    pResponseID := TableEvent."Response ID";
                    if pResponseID <> 0 then begin
                        Clear(JSon); //PATCH
                        JSon.Add('parent', ClockwiseCustNo);
                        JSon.Add('name', Rec.Description);
                        Json.Add('description', StrSubstNo('Uren per week:%1', Rec."Hours per Week"));
                        JSon.Add('reference_number', ClockwiseCustNo);
                        JSon.Add('start_date', Job."Starting Date");
                        JSon.Add('end_date', Job."Ending Date");
                        JSon.Add('hours_budgetted', Rec."Schedule (Total Hours)");
                        pRequestAction := pRequestAction::PATCH;
                    end;
                end;
                JSon.WriteTo(pJSonText);
            end;
        end;
        exit(ok);
    end;

    /// <summary> 
    /// Description for GetClockwiseCustomerNo.
    /// </summary>
    /// <param name="pJobTask">Parameter of type Record "Job Task".</param>
    /// <returns>Return variable "Code[20]".</returns>
    procedure GetClockwiseCustomerNo(pJobTask: Record "Job Task"): Code[20]
    var
        Job: Record Job;
        Cust: Record Customer;
    begin
        if Job.Get(pJobTask."Job No.") and Cust.Get(Job."Bill-to Customer No.") then begin
            exit(Cust."Customer No. - Clockwise");
        end;
        exit('');
    end;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnAfterValidateEvent', 'Starting Date', true, true)]
    local procedure UpdateClockwiseProjectsOnAfterModifyStartingDate(var xRec: Record Job;var Rec: Record Job)
    var
        JobTask : Record "Job Task";
    begin
        if xRec."Starting Date" <> Rec."Starting Date" then begin 
            JobTask.SetRange("Job No.",Rec."No.");
            if JobTask.FindSet() then
                repeat
                    JobTask.Modify(true);
                until JobTask.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnAfterValidateEvent', 'Ending Date', true, true)]
    local procedure UpdateClockwiseProjectsOnAfterModifyEndingDate(var xRec: Record Job;var Rec: Record Job)
    var
        JobTask : Record "Job Task";
    begin
        if xRec."Ending Date" <> Rec."Ending Date" then begin 
            JobTask.SetRange("Job No.",Rec."No.");
            if JobTask.FindSet() then
                repeat
                    JobTask.Modify(true);
                until JobTask.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnAfterDeleteEvent', '', true, true)]
    local procedure UpdateClockwiseProjectsOnAfterDeleteJobPlanningLine(var Rec: Record "Job Planning Line";RunTrigger: Boolean)
    var
        JobTask : record "Job Task";
    begin
        if not RunTrigger then
            exit;

        if JobTask.Get(Rec."Job No.", Rec."Job Task No.") then
            JobTask.Modify(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnAfterModifyEvent', '', true, true)]
    local procedure UpdateClockwiseProjectsOnAfterModifyJobPlanningLine(var xRec: Record "Job Planning Line";var Rec: Record "Job Planning Line";RunTrigger: Boolean)
    var
        JobTask : record "Job Task";
    begin
        if not RunTrigger then
            exit;

        if xRec.Quantity = Rec.Quantity then
            exit;

        if JobTask.Get(Rec."Job No.", Rec."Job Task No.") then
            JobTask.Modify(true);
    end;
}
