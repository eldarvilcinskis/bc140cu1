page 1432 "Net Promoter Score Setup"
{
    Caption = 'Net Promoter Score Setup';
    Editable = false;
    PageType = Card;
    SourceTable = "Net Promoter Score Setup";

    layout
    {
        area(content)
        {
            field(PUID;Puid)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'PUID';
                ToolTip = 'Specifies PUID';
            }
            field("Actual Parameters";ActualParameters)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Actual Parameters';
                ToolTip = 'Specifies the actual NPS parameters.';
            }
            field("Actual API URL";ActualApiUrl)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Actual API URL';
                ToolTip = 'Specifies the actual API URL.';
            }
            field("Cached API URL";CachedApiUrl)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Cached API URL';
                Editable = false;
                ToolTip = 'Specifies the cached API URL.';
            }
            field("Cached Request Timeout";"Request Timeout")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Cached Request Timeout';
                ToolTip = 'Specifies the request timeout.';
            }
            field("Cache Expire Time";"Expire Time")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Cache Expire Time';
                ToolTip = 'Specifies the cache expiration time.';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Validate Actual URL")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Validate Actual URL';
                Enabled = IsActualUrlNotEmpty;
                Image = ValidateEmailLoggingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Validate the actual API URL.';

                trigger OnAction()
                begin
                    ValidateApiUrl(ActualApiUrl);
                end;
            }
            action("Validate Cached URL")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Validate Cached URL';
                Enabled = IsCachedUrlNotEmpty;
                Image = ValidateEmailLoggingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Validate the cached API URL.';

                trigger OnAction()
                begin
                    ValidateApiUrl(CachedApiUrl);
                end;
            }
            action("Test Actual URL")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Test Actual URL';
                Enabled = IsActualUrlNotEmpty;
                Image = Link;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Verify the actual API URL.';

                trigger OnAction()
                var
                    NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
                begin
                    TestApiUrl(NetPromoterScoreMgt.GetTestUrl(ActualApiUrl));
                end;
            }
            action("Test Cached URL")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Test Cached URL';
                Enabled = IsCachedUrlNotEmpty;
                Image = Link;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Verify the cached API URL.';

                trigger OnAction()
                var
                    NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
                begin
                    TestApiUrl(NetPromoterScoreMgt.GetTestUrl(CachedApiUrl));
                end;
            }
            action("Renew Cached URL")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Renew Cached URL';
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Renew the cached API URL.';

                trigger OnAction()
                begin
                    "Expire Time" := CurrentDateTime;
                    Modify;

                    GetCachedApiUrl;
                    if IsCachedUrlNotEmpty then
                      Message(SuccessfulSynchronizationMsg)
                    else
                      Message(FailedSynchronizationMsg);
                end;
            }
            action("Test Actual Inv URL")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Test Actual Inv URL';
                Enabled = IsActualUrlNotEmpty;
                Image = Link;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Verify the actual API URL.';

                trigger OnAction()
                var
                    O365NetPromoterScoreMgt: Codeunit "O365 Net Promoter Score Mgt.";
                begin
                    TestInvApiUrl(O365NetPromoterScoreMgt.GetInvTestUrl(ActualApiUrl));
                end;
            }
            action("Test Cached Inv URL")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Test Cached Inv URL';
                Enabled = IsCachedUrlNotEmpty;
                Image = Link;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Verify the cached API URL.';

                trigger OnAction()
                var
                    O365NetPromoterScoreMgt: Codeunit "O365 Net Promoter Score Mgt.";
                begin
                    TestInvApiUrl(O365NetPromoterScoreMgt.GetInvTestUrl(CachedApiUrl));
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        GetCachedApiUrl;
    end;

    trigger OnOpenPage()
    var
        NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
    begin
        GetActualParameters;
        GetActualApiUrl;
        Puid := NetPromoterScoreMgt.GetPuid;
    end;

    var
        CachedApiUrl: Text;
        TestSuccessfulMsg: Label 'The URL test was successful.\Request: %1\Response: %2.', Comment='%1 - request, %2 - response';
        TestFailedMsg: Label 'The URL test failed.\Request: %1\Error: %2.', Comment='%1 - request, %2 - error';
        ValidationMsg: Label 'The URL was validated.\URL: %1\Is URI: %2\Is HTTP: %3\Is HTTPS: %4.', Comment='%1 - URL, %2 - is URI, %3 - is HTTP, %4 - is HTTPS';
        SuccessfulSynchronizationMsg: Label 'The cached URL was successfuly synchronized with the actual URL.';
        FailedSynchronizationMsg: Label 'Cannot get the actual URL.';
        ActualApiUrl: Text;
        ActualParameters: Text;
        NpsApiUrlTxt: Label 'NpsApiUrl', Locked=true;
        NpsParametersTxt: Label 'NpsParameters', Locked=true;
        Puid: Text;
        IsCachedUrlNotEmpty: Boolean;
        IsActualUrlNotEmpty: Boolean;

    local procedure GetActualParameters()
    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
    begin
        if AzureKeyVaultManagement.IsEnabled then
          if not AzureKeyVaultManagement.GetAzureKeyVaultSecret(ActualParameters,NpsParametersTxt) then
            ActualParameters := '';
    end;

    local procedure GetActualApiUrl()
    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
    begin
        if AzureKeyVaultManagement.IsEnabled then
          if not AzureKeyVaultManagement.GetAzureKeyVaultSecret(ActualApiUrl,NpsApiUrlTxt) then
            ActualApiUrl := '';
        ActualApiUrl := DelChr(ActualApiUrl,'<>',' ');
        IsActualUrlNotEmpty := ActualApiUrl <> '';
    end;

    local procedure GetCachedApiUrl()
    begin
        CachedApiUrl := DelChr(GetApiUrl,'<>',' ');
        IsCachedUrlNotEmpty := CachedApiUrl <> '';
    end;

    local procedure TestApiUrl(Url: Text)
    var
        NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
        Response: Text;
        ErrorMessage: Text;
    begin
        if NetPromoterScoreMgt.TestConnection(Url,Response,ErrorMessage) then
          Message(TestSuccessfulMsg,Url,Response)
        else
          Message(TestFailedMsg,Url,ErrorMessage);
    end;

    local procedure ValidateApiUrl(Url: Text)
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        IsValidUri: Boolean;
        IsHttpUrl: Boolean;
        IsSecureHttpUrl: Boolean;
    begin
        IsValidUri := WebRequestHelper.IsValidUri(Url);
        IsHttpUrl := WebRequestHelper.IsHttpUrl(Url);
        IsSecureHttpUrl := WebRequestHelper.IsSecureHttpUrl(Url);
        Message(ValidationMsg,Url,IsValidUri,IsHttpUrl,IsSecureHttpUrl);
    end;

    local procedure TestInvApiUrl(Url: Text)
    var
        O365NetPromoterScoreMgt: Codeunit "O365 Net Promoter Score Mgt.";
        Response: Text;
        ErrorMessage: Text;
    begin
        if O365NetPromoterScoreMgt.TestInvConnection(Url,Response,ErrorMessage) then
          Message(TestSuccessfulMsg,Url,Response)
        else
          Message(TestFailedMsg,Url,ErrorMessage);
    end;
}

