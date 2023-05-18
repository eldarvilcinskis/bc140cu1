codeunit 9802 "Logon Management"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        LogonInProgress: Boolean;

    [Scope('Personalization')]
    procedure IsLogonInProgress(): Boolean
    begin
        exit(LogonInProgress);
    end;

    [Scope('Personalization')]
    procedure SetLogonInProgress(Value: Boolean)
    begin
        LogonInProgress := Value;
    end;
}

