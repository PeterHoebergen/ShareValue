codeunit 50100 "CWC Helper Functions"
{
    procedure GetJsonValueAsText(var JSonObject: JsonObject; Property: Text) Value: Text
    var
        JsonValue: JsonValue;
    begin
        if not GetJsonValue(JSonObject, Property, JsonValue)
          then
            exit;

        if JsonValue.IsNull() then
            exit;

        Value := JsonValue.AsText();
    end;

    procedure GetJsonValue(var JSonObject: JsonObject; Property: Text; var JsonValue: JsonValue): Boolean
    var
        JsonToken: JsonToken;
    begin
        if not JSonObject.Get(Property, JsonToken) then
            exit(false);

        JsonValue := JsonToken.AsValue();
        exit(true);
    end;
}
