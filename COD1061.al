codeunit 1061 "QBO Sync Proxy"
{

    trigger OnRun()
    begin
    end;

    var
        AuthUrl: Text;

    [IntegrationEvent(false, false)]
    [Scope('Internal')]
    procedure GetQBOSyncSettings(var Title: Text;var Description: Text;var Enabled: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Internal')]
    procedure OnGetQBOAuthURL()
    begin
    end;

    [IntegrationEvent(false, false)]
    [Scope('Internal')]
    procedure SetQBOSyncEnabled(Enabled: Boolean)
    begin
    end;

    [Scope('Internal')]
    procedure GetQBOAuthURL(): Text
    begin
        exit(AuthUrl);
    end;

    [Scope('Internal')]
    procedure SetQBOAuthURL(Value: Text)
    begin
        AuthUrl := Value;
    end;
}

