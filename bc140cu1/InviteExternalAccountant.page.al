page 9033 "Invite External Accountant"
{
    Caption = 'Invite External Accountant';
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
            group(Control10)
            {
                ShowCaption = false;
                Visible = FirstStepVisible;
                group("Welcome to assisted setup for inviting an external accountant.")
                {
                    Caption = 'Welcome to assisted setup for inviting an external accountant.';
                    Visible = FirstStepVisible;
                    group(Control12)
                    {
                        InstructionalText = 'This guide will help you invite an external accountant to login to your company.';
                        ShowCaption = false;
                        Visible = FirstStepVisible;
                        group(Control24)
                        {
                            Caption = 'This Invite External Accountant feature allows your organization to share its data with an external party either through the use of a separate portal or through the external party''s access to your organization''s online services account. Microsoft has no control over the third-party''s use of your data. You are responsible for ensuring that you have separate agreements in place with any such external user governing such external user''s access to and use of your data.';
                            Visible = FirstStepVisible;
                            group("By clicking 'I Accept', you consent to share your organization's data with external parties you designate.")
                            {
                                Caption = 'By clicking ''I Accept'', you consent to share your organization''s data with external parties you designate.';
                                Visible = FirstStepVisible;
                                field(DataPrivacy;DataPrivacyAccepted)
                                {
                                    ApplicationArea = Basic,Suite;
                                    Caption = 'I Accept';
                                    ToolTip = 'Specifies your consent to share your organization''s data with external parties you designate.';

                                    trigger OnValidate()
                                    begin
                                        NextActionEnabled := true;
                                    end;
                                }
                                group(Control7)
                                {
                                    InstructionalText = 'Choose Next to get started.';
                                    ShowCaption = false;
                                    Visible = FirstStepVisible;
                                }
                            }
                        }
                    }
                }
            }
            group(Control13)
            {
                ShowCaption = false;
                Visible = DefineInformationStepVisible;
                group(Control20)
                {
                    InstructionalText = 'Please enter the email address of the accountant.';
                    ShowCaption = false;
                    Visible = DefineInformationStepVisible;
                    field(NewUserEmailAddress;NewUserEmailAddress)
                    {
                        ApplicationArea = Basic,Suite;
                        ShowCaption = false;
                        ShowMandatory = true;
                    }
                }
                group(Control25)
                {
                    InstructionalText = 'Please enter the first name.';
                    ShowCaption = false;
                    Visible = DefineInformationStepVisible;
                    field(NewFirstName;NewFirstName)
                    {
                        ApplicationArea = Basic,Suite;
                        ShowCaption = false;
                        ShowMandatory = true;

                        trigger OnValidate()
                        begin
                            DefineInitialEmailBody;
                        end;
                    }
                }
                group(Control15)
                {
                    InstructionalText = 'Please enter the last name.';
                    ShowCaption = false;
                    Visible = DefineInformationStepVisible;
                    field(NewLastName;NewLastName)
                    {
                        ApplicationArea = Basic,Suite;
                        ShowCaption = false;
                        ShowMandatory = true;
                    }
                }
                group("Welcome Email")
                {
                    Caption = 'Welcome Email';
                    Visible = DefineInformationStepVisible;
                    field(NewUserWelcomeEmail;NewUserWelcomeEmail)
                    {
                        ApplicationArea = Basic,Suite;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                }
            }
            group(Control17)
            {
                ShowCaption = false;
                Visible = CloseActionVisible;
                field(InvitationResult;InvitationResult)
                {
                    ApplicationArea = Basic,Suite;
                    Editable = false;
                    Enabled = false;
                    ShowCaption = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field(InviteProgress;InviteProgress)
                {
                    ApplicationArea = Basic,Suite;
                    Editable = false;
                    Enabled = false;
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                var
                    ErrorMessage: Text;
                begin
                    if Step = Step::DefineInformation then begin
                      if (NewUserEmailAddress <> '') and (NewFirstName <> '') and (NewLastName <> '') and (NewUserWelcomeEmail <> '') then begin
                        if InviteExternalAccountant.InvokeEmailAddressIsAADAccount(NewUserEmailAddress,ErrorMessage) then begin
                          Invite;
                          OnInvitationEnd(WasInvitationSuccessful,InvitationResult,InviteProgress);
                          NextStep(false);
                        end else
                          Error(ErrorMessage);
                      end else
                        Error(NotAllFieldsEnteredErrorErr);
                    end else
                      NextStep(false);
                end;
            }
            action(ActionClose)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Close';
                Enabled = true;
                Image = NextRecord;
                InFooterBar = true;
                Visible = CloseActionVisible;

                trigger OnAction()
                begin
                    CurrPage.Close;
                end;
            }
        }
    }

    trigger OnInit()
    begin
        DefineInitialEmailBody;
    end;

    trigger OnOpenPage()
    var
        PermissionManager: Codeunit "Permission Manager";
        InviteExternalAccountant: Codeunit "Invite External Accountant";
        NavUserAccountHelper: DotNet NavUserAccountHelper;
        ProgressWindow: Dialog;
        ErrorMessage: Text;
    begin
        OnInvitationStart;
        if not PermissionManager.SoftwareAsAService then
          Error(SaaSOnlyErrorErr);

        ProgressWindow.Open(WizardOpenValidationMsg);

        if not InviteExternalAccountant.VerifySMTPIsEnabledAndSetup then
          Error(SMTPMustBeSetupErrorErr);

        if not InviteExternalAccountant.InvokeIsExternalAccountantLicenseAvailable(ErrorMessage) then begin
          OnInvitationNoExternalAccountantLicenseFail;
          Error(NoExternalAccountantLicenseAvailableErr);
        end;

        if not InviteExternalAccountant.InvokeIsUserAdministrator then begin
          OnInvitationNoAADPermissionsFail;
          Error(NoAADPermissionsErr);
        end;

        if not (NavUserAccountHelper.IsSessionAdminSession or NavUserAccountHelper.IsUserSuperInAllCompanies) then begin
          OnInvitationNoUserTablePermissionsFail;
          Error(NoUserTableWritePermissionErr);
        end;

        ProgressWindow.Close;
        Step := Step::Start;
        EnableControls;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::OK then
          if not UserInvited then
            if not Confirm(SetupNotCompletedQst,false) then
              Error('');
    end;

    var
        InviteExternalAccountant: Codeunit "Invite External Accountant";
        AzureADMgt: Codeunit "Azure AD Mgt.";
        Step: Option Start,DefineInformation,Finish;
        FirstStepVisible: Boolean;
        DefineInformationStepVisible: Boolean;
        BackActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        SetupNotCompletedQst: Label 'The user was not yet invited. Are you sure that you want to exit?';
        DataPrivacyAccepted: Boolean;
        CloseActionVisible: Boolean;
        NewUserEmailAddress: Text;
        NewFirstName: Text;
        NewLastName: Text;
        NewUserWelcomeEmail: Text;
        UserInvited: Boolean;
        EmailGreetingTxt: Label 'Hello ';
        EmailBodyTxt: Label 'Please accept this invitation to get access to my %1.', Comment='%1 - product name';
        EmailClosingTxt: Label 'Best Regards,';
        SaaSOnlyErrorErr: Label 'This functionality is not intended for on premises.';
        InviteProgress: Text;
        InvitationErrorTxt: Label 'Inviting external accountant failed while doing the %1.  %2', Comment='%1=part of the invite process, e.g. invite, profile update, license assignment.  %2 =the error message.';
        InviteTxt: Label 'invite';
        ProfileUpdateTxt: Label 'profile update';
        LicenseAssignmentTxt: Label 'license assignment';
        EmailTxt: Label 'email';
        InvitationSuccessTxt: Label '%1 %2 was successfully invited!', Comment='%1=first name.  %2 =last name.';
        NoExternalAccountantLicenseAvailableErr: Label 'No External Accountant license available. Contact your administrator.';
        NoAADPermissionsErr: Label 'You do not have permission to invite the user. You must either be a global administrator or a user administrator in Azure AD. Please contact your administrator.';
        WizardOpenValidationMsg: Label 'Verifying permissions and license availability.';
        InviteProgressWindowMsg: Label 'Inviting external accountant.  This process could take a little while.';
        EmailSubjectTxt: Label 'You have been invited to %1', Comment='%1 - product name';
        OpenTheFollowingLinkTxt: Label 'Open the following link to verify that you can log in.';
        ToAddMyCompanyTxt: Label 'To add my company to your Accountant Hub, click <a href="%1">here</a>.', Comment='%1=Link for creating a client in the Accountant Hub.';
        EmailNotUsingAccountantPortalTxt: Label 'Not using the Accountant Hub?  Click <a href="https://dynamics.microsoft.com/en-us/business-central/accountants">here</a> to learn more.', Comment='{Do not translate html portion.}';
        InvitationResult: Text;
        FailureTxt: Label 'Failure';
        SuccessTxt: Label 'Success';
        EmailErrorTxt: Label 'Error occurred while sending email.';
        NotAllFieldsEnteredErrorErr: Label 'To continue, enter all required fields.';
        WasInvitationSuccessful: Boolean;
        SMTPMustBeSetupErrorErr: Label 'SMTP must be configured prior to inviting external accountant. Contact your administrator.';
        NoUserTableWritePermissionErr: Label 'This step adds a user to your company, and only your administrator can do that. Please contact your administrator.';
        AccountantHubPRODTxt: Label 'https://accountants.dynamics.com', Locked=true;
        AccountantHubPPETxt: Label 'https://accountants.dynamics-tie.com', Locked=true;
        UrlPageModeFilterTxt: Label '/?page=21&mode=Edit&filter=Customer.''Client Link'' IS ''''''%1'''''' AND Customer.Name IS ''''''%2''''''', Comment='%1=Link to client.  %2 =client name.  {Locked}';

    local procedure EnableControls()
    begin
        ResetControls;

        case Step of
          Step::Start:
            ShowStartStep;
          Step::DefineInformation:
            ShowDefineInformationStep;
          Step::Finish:
            ShowFinishStep;
        end;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
          Step := Step - 1
        else
          Step := Step + 1;

        EnableControls;
    end;

    local procedure ShowStartStep()
    begin
        FirstStepVisible := true;

        BackActionEnabled := false;
    end;

    local procedure ShowDefineInformationStep()
    begin
        DefineInformationStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        NextActionEnabled := false;
        CloseActionVisible := true;
    end;

    local procedure Invite()
    var
        SMTPMail: Codeunit "SMTP Mail";
        MailManagement: Codeunit "Mail Management";
        GuestGraphUser: DotNet UserInfo;
        Graph: DotNet GraphQuery;
        ProgressWindow: Dialog;
        InvitedUserId: Guid;
        InviteRedeemUrl: Text;
        ErrorMessage: Text;
    begin
        UserInvited := true;
        ProgressWindow.Open(InviteProgressWindowMsg);

        if not InviteExternalAccountant.InvokeInvitationsRequest(NewFirstName + NewLastName,
             NewUserEmailAddress,GetWebClientUrl,InvitedUserId,InviteRedeemUrl,ErrorMessage)
        then begin
          InvitationResult := FailureTxt;
          InviteProgress := StrSubstNo(InvitationErrorTxt,InviteTxt,ErrorMessage);
          ProgressWindow.Close;
          exit;
        end;
        Graph := Graph.GraphQuery;

        if not InviteExternalAccountant.TryGetGuestGraphUser(InvitedUserId,GuestGraphUser) then begin
          InvitationResult := FailureTxt;
          InviteProgress := StrSubstNo(InvitationErrorTxt,InviteTxt,ErrorMessage);
          ProgressWindow.Close;
          exit;
        end;

        if not InviteExternalAccountant.InvokeUserProfileUpdateRequest(GuestGraphUser,
             Graph.GetTenantDetail().CountryLetterCode,ErrorMessage)
        then begin
          InvitationResult := FailureTxt;
          InviteProgress := StrSubstNo(InvitationErrorTxt,ProfileUpdateTxt,ErrorMessage);
          ProgressWindow.Close;
          exit;
        end;

        if not InviteExternalAccountant.InvokeUserAssignLicenseRequest(GuestGraphUser,ErrorMessage) then begin
          InvitationResult := FailureTxt;
          InviteProgress := StrSubstNo(InvitationErrorTxt,LicenseAssignmentTxt,ErrorMessage);
          ProgressWindow.Close;
          exit;
        end;

        SMTPMail.CreateMessage('',MailManagement.GetSenderEmailAddress,NewUserEmailAddress,
          StrSubstNo(EmailSubjectTxt,PRODUCTNAME.Marketing),DefineFullEmailBody(NewUserWelcomeEmail),true);
        if not SMTPMail.TrySend then begin
          InvitationResult := FailureTxt;
          InviteProgress := StrSubstNo(InvitationErrorTxt,EmailTxt,EmailErrorTxt);
          ProgressWindow.Close;
          exit;
        end;

        ProgressWindow.Close;

        InvitationResult := SuccessTxt;
        WasInvitationSuccessful := true;
        InviteProgress := StrSubstNo(InvitationSuccessTxt,NewFirstName,NewLastName);
        CurrPage.Update(false);
        InviteExternalAccountant.UpdateAssistedSetup;
        InviteExternalAccountant.CreateNewUser(InvitedUserId);
    end;

    local procedure ResetControls()
    begin
        FirstStepVisible := false;
        DefineInformationStepVisible := false;
        NextActionEnabled := false;

        BackActionEnabled := true;

        if DataPrivacyAccepted then
          NextActionEnabled := true;

        CloseActionVisible := false;
    end;

    local procedure DefineInitialEmailBody()
    var
        User: Record User;
        Company: Record Company;
        EmailGreeting: Text;
        EmailBody: Text;
        EmailClosing: Text;
    begin
        User.Get(UserSecurityId);
        Company.Get(CompanyName);
        EmailGreeting := EmailGreetingTxt + NewFirstName + ',' + NewLineForTextControl;
        EmailBody := StrSubstNo(EmailBodyTxt,PRODUCTNAME.Marketing) + NewLineForTextControl + NewLineForTextControl;
        EmailClosing := EmailClosingTxt + NewLineForTextControl + User."User Name" + NewLineForTextControl + Company."Display Name";
        NewUserWelcomeEmail := EmailGreeting + EmailBody + EmailClosing;
        CurrPage.Update;
    end;

    local procedure DefineFullEmailBody(InitialEmailMessage: Text): Text
    var
        EmailBody: Text;
    begin
        EmailBody := ReplaceNewLinesWithHtmlLineBreak(InitialEmailMessage);
        EmailBody := EmailBody + LineBreakForEmail + LineBreakForEmail;
        EmailBody := EmailBody + OpenTheFollowingLinkTxt + LineBreakForEmail;
        EmailBody := EmailBody + GetWebClientUrl + LineBreakForEmail;
        EmailBody := EmailBody + LineBreakForEmail + LineBreakForEmail;
        EmailBody := EmailBody + StrSubstNo(ToAddMyCompanyTxt,GetCreateClientUrl) + LineBreakForEmail;
        EmailBody := EmailBody + LineBreakForEmail + LineBreakForEmail;
        EmailBody := EmailBody + EmailNotUsingAccountantPortalTxt + LineBreakForEmail;
        exit(EmailBody)
    end;

    local procedure NewLineForTextControl() Newline: Text
    begin
        Newline[1] := 13;
        Newline[2] := 10;
    end;

    local procedure LineBreakForEmail(): Text
    begin
        exit('</br>');
    end;

    local procedure ReplaceNewLinesWithHtmlLineBreak(InputText: Text): Text
    var
        String: DotNet String;
        TextToReplace: Text;
    begin
        String := InputText;
        TextToReplace[1] := 10;
        exit(String.Replace(TextToReplace,LineBreakForEmail));
    end;

    local procedure GetWebClientUrl(): Text
    var
        Graph: DotNet GraphQuery;
        ClientUrl: Text;
        TenantDomainName: Text;
        TenantObjectId: Text;
    begin
        if InviteExternalAccountant.IsPPE then
          ClientUrl := 'https://businesscentral.dynamics-tie.com/'
        else
          ClientUrl := 'https://businesscentral.dynamics.com/';

        TenantDomainName := AzureADMgt.GetInitialTenantDomainName;
        Graph := Graph.GraphQuery;
        TenantObjectId := Graph.GetTenantDetail.ObjectId;

        if StrLen(TenantDomainName) > 0 then
          ClientUrl := ClientUrl + TenantDomainName
        else
          ClientUrl := ClientUrl + TenantObjectId;

        ClientUrl := ClientUrl + '?redirectedfromsignup=1';

        exit(ClientUrl);
    end;

    local procedure GetAccountantHubUrl(): Text
    var
        AccountantHubUrl: Text;
    begin
        if InviteExternalAccountant.IsPPE then
          AccountantHubUrl := AccountantHubPPETxt
        else
          AccountantHubUrl := AccountantHubPRODTxt;

        exit(AccountantHubUrl);
    end;

    local procedure GetCreateClientUrl(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        Graph: DotNet GraphQuery;
        CreateClientUrl: Text;
        WebClientUrl: Text;
        TenantDisplayName: Text;
    begin
        Graph := Graph.GraphQuery;
        TenantDisplayName := Graph.GetTenantDetail.DisplayName;
        WebClientUrl := GetWebClientUrl;

        CreateClientUrl := GetAccountantHubUrl +
          StrSubstNo(UrlPageModeFilterTxt,TypeHelper.UrlEncode(WebClientUrl),TypeHelper.UrlEncode(TenantDisplayName));

        exit(CreateClientUrl);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInvitationStart()
    begin
        // This event is called the invitation process is started.
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInvitationNoExternalAccountantLicenseFail()
    begin
        // This event is called when the invitation process can not proceed due to a lack of external accountant licenses.
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInvitationNoAADPermissionsFail()
    begin
        // This event is called when the invitation process can not proceed due to a lack of user AAD permissions.
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInvitationEnd(WasInvitationSuccessful: Boolean;Result: Text;Progress: Text)
    begin
        // This event is called when the invitation process is finished.
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInvitationNoUserTablePermissionsFail()
    begin
        // This event is called when the invitation process can not proceed because session is not admin or user is not super in all companies.
    end;
}

