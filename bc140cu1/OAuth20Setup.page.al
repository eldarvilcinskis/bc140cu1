page 1140 "OAuth 2.0 Setup"
{
    Caption = 'OAuth 2.0 Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ShowFilter = false;
    SourceTable = "OAuth 2.0 Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description.';
                }
                field("Service URL"; "Service URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the service URL.';
                }
                field("Redirect URL"; "Redirect URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the redirect URL.';
                }
                field(Scope; Scope)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the scope.';
                }
            }
            group("Request URL Paths")
            {
                Caption = 'Request URL Paths';
                field("Authorization URL Path"; "Authorization URL Path")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the authorization URL path.';
                }
                field("Access Token URL Path"; "Access Token URL Path")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the access token URL path.';
                }
                field("Refresh Token URL Path"; "Refresh Token URL Path")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the refresh token URL path.';
                }
            }
            group("Request Authorization Code")
            {
                Caption = 'Request Authorization Code';
                Visible = RequestAuthorizationCodeInvoked OR (Status = Status::Disabled) OR (Status = Status::Error);
                field("Enter Authorization Code"; ReceivedAuthorizationCode)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Enter Authorization Code';
                    ToolTip = 'Specifies the received authorization code from the request authorization action.';

                    trigger OnValidate()
                    begin
                        ValidateAuthorizationCode;
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RequestAuthorizationCode)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Request Authorization Code';
                Image = EncryptionKeys;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Open the service authorization web page. Login credentials will be prompted. The authorization code must be copied into the Enter Authorization Code field.';

                trigger OnAction()
                begin
                    RequestAuthorizationCode;
                    RequestAuthorizationCodeInvoked := true;
                end;
            }
            action(RefreshAccessToken)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Refresh Access Token';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Refresh the access and refresh tokens.';

                trigger OnAction()
                var
                    MessageText: Text;
                begin
                    if not RefreshAccessToken(MessageText) then begin
                        Commit; // save new "Status" value
                        Error(MessageText);
                    end;

                    Message(MessageText);
                end;
            }
        }
        area(navigation)
        {
            action(EncryptionManagement)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Encryption Management';
                Image = EncryptionKeys;
                RunObject = Page "Data Encryption Management";
                RunPageMode = View;
                ToolTip = 'Enable or disable data encryption. Data encryption helps make sure that unauthorized users cannot read business data.';
                Visible = NOT IsSaas;
            }
            action(HttpLog)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Http Log';
                Image = Log;
                ToolTip = 'See the http request/response history log entries for the current OAuth endpoint setup.';

                trigger OnAction()
                var
                    ActivityLog: Record "Activity Log";
                begin
                    ActivityLog.ShowEntries(Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        IsSaas := PermissionManager.SoftwareAsAService;
    end;

    var
        ReceivedAuthorizationCode: Text;
        RequestAuthorizationCodeInvoked: Boolean;
        IsSaas: Boolean;

    local procedure ValidateAuthorizationCode()
    var
        MessageText: Text;
    begin
        if ReceivedAuthorizationCode = '' then
            exit;

        if not RequestAccessToken(MessageText, ReceivedAuthorizationCode) then
            Error(MessageText);

        ReceivedAuthorizationCode := '';
        RequestAuthorizationCodeInvoked := false;
        if MessageText <> '' then
            Message(MessageText);

        CurrPage.Update; // force OnAfterGetCurrRecord() to refresh notification
    end;
}

