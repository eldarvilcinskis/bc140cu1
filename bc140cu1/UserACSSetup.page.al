page 9811 "User ACS Setup"
{
    Caption = 'User ACS Setup';
    DataCaptionExpression = "Full Name";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = Card;
    SourceTable = User;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("User Name";"User Name")
                {
                    ApplicationArea = Basic,Suite;
                    Editable = false;
                    ToolTip = 'Specifies the user''s name. If the user is required to present credentials when starting the client, this is the name that the user must present.';
                }
                field(NameID;NameID)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'ACS Name ID';
                    Editable = false;
                    ToolTip = 'Specifies the name identifier provided by the ACS security token. You cannot enter a value in this field; it is populated automatically when the user logs on for the first time..';
                }
                field(AuthenticationID;AuthenticationID)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Authentication Key';
                    ToolTip = 'Specifies the authentication key that is generated after you choose Generate Auth Key in the User ACS Setup dialog box. After you configure your Azure deployment and your Business Central components for ACS, send this value and the User Name value to the user, and then direct the user to provide these values when they log on to a Business Central client.';

                    trigger OnValidate()
                    begin
                        if not (AuthenticationID = '') then begin
                          if not IdentityManagement.ValidateAuthKeyStrength(AuthenticationID) then
                            Error(WeakAuthKeyErr);
                        end;

                        IdentityManagement.SetAuthenticationKey("User Security ID",AuthenticationID);
                        ACSStatus := IdentityManagement.GetACSStatus("User Security ID");
                    end;
                }
                field(ACSStatus;ACSStatus)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'ACS Status';
                    Editable = false;
                    ToolTip = 'Specifies the current authentication status of the user.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Generate Auth Key")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Generate Auth Key';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Generate an authentication key for Access Control Service authentication.';

                trigger OnAction()
                var
                    Convert: DotNet Convert;
                    UTF8Encoding: DotNet UTF8Encoding;
                    CreatedGuid: Text;
                begin
                    CreatedGuid := CreateGuid;
                    UTF8Encoding := UTF8Encoding.UTF8Encoding;

                    AuthenticationID := Convert.ToBase64String(UTF8Encoding.GetBytes(CreatedGuid));

                    IdentityManagement.SetAuthenticationKey("User Security ID",AuthenticationID);

                    CurrPage.Update;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        NameID := IdentityManagement.GetNameIdentifier("User Security ID");
        ACSStatus := IdentityManagement.GetACSStatus("User Security ID");
        AuthenticationID := IdentityManagement.GetAuthenticationKey("User Security ID");
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IdentityManagement.SetAuthenticationKey("User Security ID",AuthenticationID);
    end;

    var
        IdentityManagement: Codeunit "Identity Management";
        [InDataSet]
        NameID: Text[250];
        [InDataSet]
        AuthenticationID: Text[80];
        ACSStatus: Option Disabled,Pending,Registered,Unknown;
        WeakAuthKeyErr: Label 'The authentication key you entered is too weak. It must be at least 8 characters long and contain both upper case and lower case letters and numbers. Choose the Generate Auth Key action to generate one for you.';
}

