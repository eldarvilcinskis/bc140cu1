codeunit 2315 "O365 Setup Mgmt"
{

    trigger OnRun()
    begin
    end;

    var
        ClientTypeManagement: Codeunit "Client Type Management";
        IdentityManagement: Codeunit "Identity Management";
        O365GettingStartedMgt: Codeunit "O365 Getting Started Mgt.";
        EvaluationCompanyDoesNotExistsMsg: Label 'Sorry, but the evaluation company isn''t available right now so we can''t start Dynamics 365 Business Central. Please try again later.';
        InvToBusinessCentralCategoryLbl: Label 'AL Invoicing To Business Central', Locked = true;
        UserPersonalizationUpdatedTelemetryTxt: Label 'User Personalization company has been updated to evaluation company.', Locked = true;
        SessionSettingUpdatedTelemetryTxt: Label 'Session settings has been updated to evaluation company.', Locked = true;
        EvaluationCompanyNotSetTelemetryTxt: Label 'Evaluation company is not set up.', Locked = true;
        FixedClientEndpointBaseProdUrlTxt: Label 'https://businesscentral.dynamics.com/', Locked = true;
        FixedClientEndpointBaseTieUrlTxt: Label 'https://businesscentral.dynamics-tie.com/', Locked = true;
        InvToBusinessCentralTrialTelemetryTxt: Label 'User clicked the Try Business Central button from Invoicing.', Locked = true;
        BusinessCentralTrialVisibleInvNameTxt: Label 'BusinessCentralTrialVisibleForInv', Locked = true;
        TypeHelper: Codeunit "Type Helper";
        SupportContactEmailTxt: Label 'support@Office365.com', Locked = true;

    [Scope('Personalization')]
    procedure InvoicesExist(): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if SalesInvoiceHeader.FindFirst then
            exit(true);

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        if SalesHeader.FindFirst then
            exit(true);
    end;

    [Scope('Personalization')]
    procedure EstimatesExist(): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        if SalesHeader.FindFirst then
            exit(true);
    end;

    [Scope('Personalization')]
    procedure DocumentsExist(): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if SalesInvoiceHeader.FindFirst then
            exit(true);

        SalesHeader.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Quote);
        if SalesHeader.FindFirst then
            exit(true);
    end;

    [Scope('Personalization')]
    procedure ShowCreateTestInvoice(): Boolean
    begin
        exit(not DocumentsExist);
    end;

    [Scope('Personalization')]
    procedure WizardShouldBeOpenedForInvoicing(): Boolean
    var
        O365GettingStarted: Record "O365 Getting Started";
    begin
        if not GettingStartedSupportedForInvoicing then
            exit(false);

        if O365GettingStarted.Get(UserId, ClientTypeManagement.GetCurrentClientType) then
            exit(false);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure GettingStartedSupportedForInvoicing(): Boolean
    begin
        if not IdentityManagement.IsInvAppId then
            exit(false);

        if not (ClientTypeManagement.GetCurrentClientType = CLIENTTYPE::Web) then
            exit(false);

        exit(O365GettingStartedMgt.UserHasPermissionsToRunGettingStarted);
    end;

    procedure ChangeToEvaluationCompany()
    var
        UserPersonalization: Record "User Personalization";
        Company: Record Company;
        SessionSetting: SessionSettings;
    begin
        Company.SetRange("Evaluation Company", true);
        if Company.FindFirst then begin
            UserPersonalization.Get(UserSecurityId);
            UserPersonalization.Validate(Company, Company.Name);
            UserPersonalization.Modify(true);
            SendTraceTag('00007L4', InvToBusinessCentralCategoryLbl, VERBOSITY::Normal,
              UserPersonalizationUpdatedTelemetryTxt, DATACLASSIFICATION::SystemMetadata);
            // Update session settings
            SessionSetting.Init;
            SessionSetting.Company := Company.Name;
            SessionSetting.RequestSessionUpdate(true);
            SendTraceTag('00007L5', InvToBusinessCentralCategoryLbl, VERBOSITY::Normal,
              SessionSettingUpdatedTelemetryTxt, DATACLASSIFICATION::SystemMetadata);
        end else begin
            Message(EvaluationCompanyDoesNotExistsMsg);
            SendTraceTag('00007L6', InvToBusinessCentralCategoryLbl, VERBOSITY::Warning,
              EvaluationCompanyNotSetTelemetryTxt, DATACLASSIFICATION::SystemMetadata);
        end;
    end;

    procedure GotoBusinessCentralWithEvaluationCompany()
    var
        Company: Record Company;
        ClientUrl: Text;
        CompanyPart: Text;
    begin
        if IsPPE then
            ClientUrl := FixedClientEndpointBaseTieUrlTxt
        else
            ClientUrl := FixedClientEndpointBaseProdUrlTxt;

        Company.SetRange("Evaluation Company", true);
        if Company.FindFirst then begin
            SendTraceTag('00007L3', InvToBusinessCentralCategoryLbl, VERBOSITY::Normal,
              InvToBusinessCentralTrialTelemetryTxt, DATACLASSIFICATION::SystemMetadata);
            CompanyPart := StrSubstNo('?company=%1', TypeHelper.UriEscapeDataString(Company.Name));
            HyperLink(ClientUrl + CompanyPart);
        end else begin
            SendTraceTag('00007NJ', InvToBusinessCentralCategoryLbl, VERBOSITY::Warning,
              EvaluationCompanyNotSetTelemetryTxt, DATACLASSIFICATION::SystemMetadata);
            HyperLink(ClientUrl);
        end;
    end;

    local procedure IsPPE(): Boolean
    var
        EnvironmentMgt: Codeunit "Environment Mgt.";
    begin
        exit(EnvironmentMgt.IsPPE);
    end;

    procedure GetBusinessCentralTrialVisibility(): Boolean
    begin
        exit(GetBusinessCentralTrialVisibilityFromKeyVault and UserHasPermissionsForEvaluationCompany);
    end;

    procedure GetBusinessCentralTrialVisibilityFromKeyVault(): Boolean
    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
        BusinessCentralTrialVisibleInvSecret: Text;
        BusinessCentralTrialVisible: Boolean;
    begin
        if AzureKeyVaultManagement.GetAzureKeyVaultSecret(BusinessCentralTrialVisibleInvSecret, BusinessCentralTrialVisibleInvNameTxt) then
            if (BusinessCentralTrialVisibleInvSecret <> '') and Evaluate(BusinessCentralTrialVisible, BusinessCentralTrialVisibleInvSecret) then
                exit(BusinessCentralTrialVisible);

        exit(true); // Default is visible true
    end;

    procedure UserHasPermissionsForEvaluationCompany(): Boolean
    var
        DummySalesHeader: Record "Sales Header";
        Company: Record Company;
    begin
        Company.SetRange("Evaluation Company", true);
        if Company.FindFirst then begin
            if DummySalesHeader.ChangeCompany(Company.Name) then
                exit(DummySalesHeader.WritePermission);
        end;

        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 9165, 'OnBeforeGetSupportInformation', '', false, false)]
    local procedure PopulateSupportInformation(var SupportName: Text; var SupportEmail: Text; var SupportUrl: Text)
    var
        IdentityManagement: Codeunit "Identity Management";
    begin
        if not IdentityManagement.IsInvAppId then
            exit;

        SupportEmail := SupportContactEmailTxt;
    end;
}

