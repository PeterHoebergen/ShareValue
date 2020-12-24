codeunit 50101 "CWC API Management"
{
    procedure SendRequest(var Parameters: Record "CWC Request";
    AuthorizationType: Enum "Authorization Type"): Boolean
    var
        TempBlob: Record TempBlob temporary;
        Client: HttpClient;
        Headers: HttpHeaders;
        ContentHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Content: HttpContent;
        AuthText: text;
    begin
        RequestMessage.Method := Format(Parameters.RestMethod);
        RequestMessage.SetRequestUri(Parameters.URL);
        RequestMessage.GetHeaders(Headers);
        if Parameters.Accept <> '' then Headers.Add('Accept', Parameters.Accept);
        case AuthorizationType of
            AuthorizationType::BasicUserPassword:
                if Parameters.UserName <> '' then begin
                    AuthText := StrSubstNo('%1:%2', Parameters.UserName, Parameters.Password);
                    TempBlob.WriteAsText(AuthText, TextEncoding::Windows);
                    Headers.Add('Authorization', StrSubstNo('Basic %1', TempBlob.ToBase64String()));
                end;
            AuthorizationType::Token:
                Headers.Add('Authorization', StrSubstNo('Bearer %1', Parameters.Token));
        end;
        if Parameters.ETag <> '' then Headers.Add('If-Match', Parameters.ETag);
        if Parameters.HasRequestContent() then begin
            Parameters.GetRequestContent(Content);
            Content.GetHeaders(ContentHeaders);
            ContentHeaders.Remove('Content-Type');
            ContentHeaders.Add('Content-Type', 'application/json');
            RequestMessage.Content := Content;
        end;
        Client.Send(RequestMessage, ResponseMessage);
        Parameters.Succes := ResponseMessage.IsSuccessStatusCode();
        Parameters.StatusCode := ResponseMessage.HttpStatusCode();
        Parameters.Reason := CopyStr(ResponseMessage.ReasonPhrase(), 1, 100);
        Headers := ResponseMessage.Headers();
        Parameters.SetResponseHeaders(Headers);
        Content := ResponseMessage.Content();
        Parameters.SetResponseContent(Content);
        EXIT(ResponseMessage.IsSuccessStatusCode());
    end;

    procedure GetEventId(): Guid
    begin
        Exit(CreateGuid());
    end;
}
