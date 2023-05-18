codeunit 1291 "DotNet Exception Handler"
{

    trigger OnRun()
    begin
    end;

    var
        OuterException: DotNet Exception;

    procedure Catch(var Exception: DotNet Exception; Type: DotNet Type)
    begin
        Collect;
        if not CastToType(Exception, Type) then
            Rethrow;
    end;

    [Scope('Personalization')]
    procedure Collect()
    begin
        OuterException := GetLastErrorObject;
    end;

    local procedure IsCollected(): Boolean
    begin
        exit(not IsNull(OuterException));
    end;

    procedure TryCastToType(Type: DotNet Type): Boolean
    var
        Exception: DotNet FormatException;
    begin
        exit(CastToType(Exception, Type));
    end;

    procedure CastToType(var Exception: DotNet Exception; Type: DotNet Type): Boolean
    begin
        if not IsCollected then
            exit(false);

        Exception := OuterException.GetBaseException;
        if IsNull(Exception) then
            exit(false);

        if Type.Equals(Exception.GetType) then
            exit(true);

        exit(false);
    end;

    [Scope('Personalization')]
    procedure GetMessage(): Text
    var
        Exception: DotNet Exception;
    begin
        if not IsCollected then
            exit;

        Exception := OuterException.GetBaseException;
        if IsNull(Exception) then
            exit;

        exit(Exception.Message);
    end;

    [Scope('Personalization')]
    procedure Rethrow()
    var
        RootCauseMessage: Text;
    begin
        RootCauseMessage := GetMessage;

        if RootCauseMessage <> '' then
            Error(RootCauseMessage);

        if IsNull(OuterException.InnerException) then
            Error(OuterException.Message);

        Error(OuterException.InnerException.Message);
    end;
}

