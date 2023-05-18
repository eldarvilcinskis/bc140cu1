table 1140 "OAuth 2.0 Setup"
{
    Caption = 'OAuth 2.0 Setup';
    ReplicateData = false;

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(3;"Service URL";Text[250])
        {
            Caption = 'Service URL';

            trigger OnValidate()
            var
                WebRequestHelper: Codeunit "Web Request Helper";
            begin
                if "Service URL" <> '' then
                  WebRequestHelper.IsSecureHttpUrl("Service URL");
            end;
        }
        field(4;"Redirect URL";Text[250])
        {
            Caption = 'Redirect URL';
        }
        field(5;"Client ID";Guid)
        {
            Caption = 'Client ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6;"Client Secret";Guid)
        {
            Caption = 'Client Secret';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7;"Access Token";Guid)
        {
            Caption = 'Access Token';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(8;"Refresh Token";Guid)
        {
            Caption = 'Refresh Token';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(9;"Authorization URL Path";Text[250])
        {
            Caption = 'Authorization URL Path';

            trigger OnValidate()
            begin
                CheckAndAppendURLPath("Authorization URL Path");
            end;
        }
        field(10;"Access Token URL Path";Text[250])
        {
            Caption = 'Access Token URL Path';

            trigger OnValidate()
            begin
                CheckAndAppendURLPath("Access Token URL Path");
            end;
        }
        field(11;"Refresh Token URL Path";Text[250])
        {
            Caption = 'Refresh Token URL Path';

            trigger OnValidate()
            begin
                CheckAndAppendURLPath("Refresh Token URL Path");
            end;
        }
        field(12;Scope;Text[250])
        {
            Caption = 'Scope';
        }
        field(13;"Authorization Response Type";Text[250])
        {
            Caption = 'Authorization Response Type';
        }
        field(14;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = ' ,Enabled,Disabled,Connected,Error';
            OptionMembers = " ",Enabled,Disabled,Connected,Error;
        }
        field(15;"Token DataScope";Option)
        {
            Caption = 'Token DataScope';
            OptionCaption = 'Module,User,Company,UserAndCompany';
            OptionMembers = Module,User,Company,UserAndCompany;
        }
        field(16;"Activity Log ID";Integer)
        {
            Caption = 'Activity Log ID';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DeleteToken("Client ID");
        DeleteToken("Client Secret");
        DeleteToken("Access Token");
        DeleteToken("Refresh Token");
    end;

    var
        OAuth20Mgt: Codeunit "OAuth 2.0 Mgt.";

    local procedure CheckAndAppendURLPath(var value: Text)
    begin
        if value <> '' then
          if value[1] <> '/' then
            value := '/' + value;
    end;

    procedure SetToken(var TokenKey: Guid;TokenValue: Text)
    begin
        if IsNullGuid(TokenKey) then
          TokenKey := CreateGuid;

        ISOLATEDSTORAGE.Set(TokenKey,OAuth20Mgt.EncryptForOnPrem(TokenValue),GetTokenDataScope);
    end;

    procedure GetToken(TokenKey: Guid) TokenValue: Text
    begin
        TokenValue := '';
        if not HasToken(TokenKey) then
          exit;

        ISOLATEDSTORAGE.Get(TokenKey,GetTokenDataScope,TokenValue);
        exit(OAuth20Mgt.DecryptForOnPrem(TokenValue));
    end;

    procedure DeleteToken(TokenKey: Guid)
    begin
        if not HasToken(TokenKey) then
          exit;

        ISOLATEDSTORAGE.Delete(TokenKey,GetTokenDataScope);
    end;

    procedure HasToken(TokenKey: Guid): Boolean
    begin
        exit(not IsNullGuid(TokenKey) and ISOLATEDSTORAGE.Contains(TokenKey,GetTokenDataScope));
    end;

    [Scope('Personalization')]
    procedure GetTokenDataScope(): DataScope
    begin
        case "Token DataScope" of
          "Token DataScope"::Company:
            exit(DATASCOPE::Company);
          "Token DataScope"::UserAndCompany:
            exit(DATASCOPE::CompanyAndUser);
          "Token DataScope"::User:
            exit(DATASCOPE::User);
          "Token DataScope"::Module:
            exit(DATASCOPE::Module);
        end;
    end;

    [Scope('Personalization')]
    procedure RequestAuthorizationCode()
    var
        Processed: Boolean;
    begin
        OAuth20Mgt.CheckEncryption;

        OnBeforeRequestAuthoizationCode(Rec,Processed);
        if Processed then
          exit;

        OAuth20Mgt.RequestAuthorizationCode(Rec);
    end;

    [Scope('Personalization')]
    procedure RequestAccessToken(var MessageText: Text;AuthorizationCode: Text) Result: Boolean
    var
        Processed: Boolean;
    begin
        OnBeforeRequestAccessToken(Rec,AuthorizationCode,Result,MessageText,Processed);
        if not Processed then
          Result := OAuth20Mgt.RequestAndSaveAccessToken(Rec,MessageText,AuthorizationCode);

        OnAfterRequestAccessToken(Rec,Result,MessageText);
    end;

    [Scope('Personalization')]
    procedure RefreshAccessToken(var MessageText: Text) Result: Boolean
    var
        Processed: Boolean;
    begin
        OnBeforeRefreshAccessToken(Rec,Result,MessageText,Processed);
        if not Processed then
          Result := OAuth20Mgt.RefreshAndSaveAccessToken(Rec,MessageText);
    end;

    [Scope('Personalization')]
    procedure InvokeRequest(RequestJSON: Text;var ResponseJSON: Text;var HttpError: Text;RetryOnCredentialsFailure: Boolean) Result: Boolean
    var
        Processed: Boolean;
    begin
        OnBeforeInvokeRequest(Rec,RequestJSON,ResponseJSON,HttpError,Result,Processed,RetryOnCredentialsFailure);
        if not Processed then
          Result := OAuth20Mgt.InvokeRequestBasic(Rec,RequestJSON,ResponseJSON,HttpError,RetryOnCredentialsFailure);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRequestAccessToken(OAuth20Setup: Record "OAuth 2.0 Setup";Result: Boolean;var MessageText: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRequestAuthoizationCode(OAuth20Setup: Record "OAuth 2.0 Setup";var Processed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRefreshAccessToken(var OAuth20Setup: Record "OAuth 2.0 Setup";var Result: Boolean;var MessageText: Text;var Processed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRequestAccessToken(var OAuth20Setup: Record "OAuth 2.0 Setup";AuthorizationCode: Text;var Result: Boolean;var MessageText: Text;var Processed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInvokeRequest(var OAuth20Setup: Record "OAuth 2.0 Setup";RequestJSON: Text;var ResponseJSON: Text;var HttpError: Text;var Result: Boolean;var Processed: Boolean;RetryOnCredentialsFailure: Boolean)
    begin
    end;
}

