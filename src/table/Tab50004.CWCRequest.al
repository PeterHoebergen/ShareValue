table 50004 "CWC Request"
{
    Caption = 'Clockwise connector Request';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(2; RestMethod; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = get,post,delete,patch,put;
        }
        field(3; URL; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(4; Accept; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(5; ETag; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(6; UserName; text[50])
        {
            DataClassification = CustomerContent;
        }
        field(7; Password; text[50])
        {
            DataClassification = CustomerContent;
        }
        field(8; Token; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(100; Request; Blob)
        {
            DataClassification = CustomerContent;
        }
        field(101; Response; Blob)
        {
            DataClassification = CustomerContent;
        }
        field(102; Succes; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(103; StatusCode; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(104; Reason; Text[100])
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    var
        ResponseHeaders: HttpHeaders;

    procedure SetRequestContent(var value: HttpContent)
    var
        InStr: InStream;
        OutStr: OutStream;
    begin
        Request.CreateInStream(InStr);
        value.ReadAs(InStr);
        Request.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
    end;

    procedure HasRequestContent(): Boolean
    begin
        exit(Request.HasValue());
    end;

    procedure GetRequestContent(var value: HttpContent)
    var
        InStr: InStream;
    begin
        Request.CreateInStream(InStr);
        value.Clear();
        value.WriteFrom(InStr);
    end;

    procedure GetRequestContentAsText() ReturnValue: text
    var
        InStr: InStream;
        Line: text;
    begin
        if not HasRequestContent() then exit;
        Request.CreateInStream(InStr);
        InStr.ReadText(ReturnValue);
        while not InStr.EOS() do begin
            InStr.ReadText(Line);
            ReturnValue += Line;
        end;
    end;

    procedure SetResponseContent(var value: HttpContent)
    var
        InStr: InStream;
        OutStr: OutStream;
    begin
        Response.CreateInStream(InStr);
        value.ReadAs(InStr);
        Response.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
    end;

    procedure HasResponseContent(): Boolean
    begin
        exit(Response.HasValue());
    end;

    procedure GetResponseContent(var value: HttpContent)
    var
        InStr: InStream;
    begin
        Response.CreateInStream(InStr);
        value.Clear();
        value.WriteFrom(InStr);
    end;

    procedure GetResponseContentAsText() ReturnValue: text
    var
        InStr: InStream;
        Line: text;
    begin
        if not HasResponseContent() then exit;
        Response.CreateInStream(InStr);
        InStr.ReadText(ReturnValue);
        while not InStr.EOS() do begin
            InStr.ReadText(Line);
            ReturnValue += Line;
        end;
    end;

    procedure SetResponseHeaders(var value: HttpHeaders)
    begin
        ResponseHeaders := value;
    end;

    procedure GetResponseHeaders(var value: HttpHeaders)
    begin
        value := ResponseHeaders;
    end;
}
