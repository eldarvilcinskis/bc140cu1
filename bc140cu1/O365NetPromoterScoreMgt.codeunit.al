codeunit 2333 "O365 Net Promoter Score Mgt."
{

    trigger OnRun()
    begin
    end;

    var
        InvDisplayDataTxt: Label 'display/invoicing/?puid=%1', Locked = true;
        InvRenderDataTxt: Label 'render/invoicing/?culture=%1&puid=%2', Locked = true;
        NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
        ClientTypeManagement: Codeunit "Client Type Management";
        InvDeviceRenderDataTxt: Label 'render/invoicing/?culture=%1&puid=%2&client=%3', Locked = true;
        UniversalWindowsPlatformTxt: Label 'wp', Locked = true;
        NpsCategoryLbl: Label 'AL NPS Prompt', Locked = true;
        NPSPageTelemetryTxt: Label 'NPS prompt is displayed.', Locked = true;

    [Scope('Personalization')]
    procedure ShowNpsDialog(): Boolean
    var
        NetPromoterScoreSetup: Record "Net Promoter Score Setup";
    begin
        if not ShouldNpsBePromptedForInvoicing then
            exit(false);

        if NetPromoterScoreSetup.GetApiUrl = '' then
            exit(false);

        NetPromoterScoreMgt.DisableRequestSending;

        Commit;
        PAGE.RunModal(PAGE::"BC O365 Net Promoter Score");
        SendTraceTag('00006ZF', NpsCategoryLbl, VERBOSITY::Normal, NPSPageTelemetryTxt, DATACLASSIFICATION::SystemMetadata);
        exit(true);
    end;

    local procedure ShouldNpsBePromptedForInvoicing(): Boolean
    var
        NetPromoterScore: Record "Net Promoter Score";
        DisplayUrl: Text;
        RenderUrl: Text;
        Response: Text;
        Display: Boolean;
    begin
        if not NetPromoterScore.ShouldSendRequest then
            exit(false);

        if not NetPromoterScoreMgt.ShouldNpsRun then
            exit(false);

        DisplayUrl := GetInvDisplayUrl;
        if DisplayUrl = '' then
            exit(false);

        RenderUrl := GetInvRenderUrl;
        if RenderUrl = '' then
            exit(false);

        if not NetPromoterScoreMgt.ExecuteWebRequest(DisplayUrl, Response) then
            exit(false);

        if not NetPromoterScoreMgt.TryGetDisplayProperty(Response, Display) then
            exit(false);

        exit(Display);
    end;

    [Scope('Personalization')]
    procedure TestInvConnection(BaseUrl: Text; var Response: Text; var ErrorMessage: Text): Boolean
    var
        TestUrl: Text;
        Success: Boolean;
    begin
        TestUrl := GetInvTestUrl(BaseUrl);
        Success := NetPromoterScoreMgt.ExecuteWebRequest(TestUrl, Response);
        if not Success then
            ErrorMessage := GetLastErrorText;
        exit(Success);
    end;

    [Scope('Personalization')]
    procedure GetInvDisplayUrl(): Text
    var
        Data: Text;
        BaseUrl: Text;
        FullUrl: Text;
    begin
        Data := GetInvDisplayData;
        BaseUrl := GetApiUrl;
        FullUrl := NetPromoterScoreMgt.GetFullUrl(BaseUrl, Data);
        exit(FullUrl);
    end;

    [Scope('Personalization')]
    procedure GetInvRenderUrl(): Text
    var
        Data: Text;
        BaseUrl: Text;
        FullUrl: Text;
    begin
        Data := GetInvRenderData;
        BaseUrl := GetApiUrl;
        FullUrl := NetPromoterScoreMgt.GetFullUrl(BaseUrl, Data);
        exit(FullUrl);
    end;

    [Scope('Personalization')]
    procedure GetInvTestUrl(BaseUrl: Text): Text
    var
        Data: Text;
        FullUrl: Text;
    begin
        Data := GetInvTestData;
        FullUrl := NetPromoterScoreMgt.GetFullUrl(BaseUrl, Data);
        exit(FullUrl);
    end;

    local procedure GetApiUrl(): Text
    var
        NetPromoterScoreSetup: Record "Net Promoter Score Setup";
        Url: Text;
    begin
        Url := NetPromoterScoreSetup.GetApiUrl;
        exit(Url);
    end;

    local procedure GetInvTestData(): Text
    var
        Data: Text;
    begin
        Data := StrSubstNo(InvDisplayDataTxt, '');
        exit(Data);
    end;

    local procedure GetInvDisplayData(): Text
    var
        Puid: Text;
        Data: Text;
    begin
        Puid := NetPromoterScoreMgt.GetPuid;
        Data := StrSubstNo(InvDisplayDataTxt, Puid);
        exit(Data);
    end;

    local procedure GetInvRenderData(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        Culture: Text;
        Puid: Text;
        Data: Text;
    begin
        Culture := LowerCase(TypeHelper.LanguageIDToCultureName(GlobalLanguage));
        Puid := NetPromoterScoreMgt.GetPuid;
        if ClientTypeManagement.GetCurrentClientType in [CLIENTTYPE::Phone, CLIENTTYPE::Tablet] then
            Data := StrSubstNo(InvDeviceRenderDataTxt, Culture, Puid, UniversalWindowsPlatformTxt)
        else
            Data := StrSubstNo(InvRenderDataTxt, Culture, Puid);
        exit(Data);
    end;
}

