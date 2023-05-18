codeunit 43 "LanguageManagement"
{

    trigger OnRun()
    begin
    end;

    var
        SavedGlobalLanguageID: Integer;

    [Scope('Personalization')]
    procedure SetGlobalLanguage()
    var
        TempLanguage: Record "Windows Language" temporary;
    begin
        GetApplicationLanguages(TempLanguage);

        with TempLanguage do begin
            SetCurrentKey(Name);
            if Get(GlobalLanguage) then;
            PAGE.Run(PAGE::"Application Languages", TempLanguage);
        end;
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure TrySetGlobalLanguage(LanguageID: Integer)
    begin
        GlobalLanguage(LanguageID);
    end;

    [Scope('Personalization')]
    procedure GetApplicationLanguages(var TempLanguage: Record "Windows Language" temporary)
    var
        Language: Record "Windows Language";
    begin
        with Language do begin
            GetLanguageFilters(Language);
            if FindSet then
                repeat
                    TempLanguage := Language;
                    TempLanguage.Insert;
                until Next = 0;
        end;
    end;

    [Scope('Personalization')]
    procedure ApplicationLanguage(): Integer
    begin
        exit(1033);
    end;

    [Scope('Personalization')]
    procedure ValidateApplicationLanguage(LanguageID: Integer)
    var
        TempLanguage: Record "Windows Language" temporary;
    begin
        GetApplicationLanguages(TempLanguage);

        with TempLanguage do begin
            SetRange("Language ID", LanguageID);
            FindFirst;
        end;
    end;

    [Scope('Personalization')]
    procedure ValidateWindowsLocale(LocaleID: Integer)
    var
        WindowsLanguage: Record "Windows Language";
    begin
        WindowsLanguage.SetRange("Language ID", LocaleID);
        WindowsLanguage.FindFirst;
    end;

    [Scope('Personalization')]
    procedure LookupApplicationLanguage(var LanguageID: Integer)
    var
        TempLanguage: Record "Windows Language" temporary;
    begin
        GetApplicationLanguages(TempLanguage);

        with TempLanguage do begin
            SetCurrentKey(Name);
            if Get(LanguageID) then;
            if PAGE.RunModal(PAGE::"Windows Languages", TempLanguage) = ACTION::LookupOK then
                LanguageID := "Language ID";
        end;
    end;

    [Scope('Personalization')]
    procedure LookupWindowsLocale(var LocaleID: Integer)
    var
        WindowsLanguage: Record "Windows Language";
    begin
        with WindowsLanguage do begin
            SetCurrentKey(Name);
            if PAGE.RunModal(PAGE::"Windows Languages", WindowsLanguage) = ACTION::LookupOK then
                LocaleID := "Language ID";
        end;
    end;

    [Scope('Personalization')]
    procedure SetGlobalLanguageByCode(LanguageCode: Code[10])
    var
        Language: Record Language;
    begin
        if LanguageCode = '' then
            exit;
        SavedGlobalLanguageID := GlobalLanguage;
        GlobalLanguage(Language.GetLanguageID(LanguageCode));
    end;

    [Scope('Personalization')]
    procedure RestoreGlobalLanguage()
    begin
        if SavedGlobalLanguageID <> 0 then begin
            GlobalLanguage(SavedGlobalLanguageID);
            SavedGlobalLanguageID := 0;
        end;
    end;

    local procedure GetLanguageFilters(var WindowsLanguage: Record "Windows Language")
    begin
        WindowsLanguage.SetRange("Localization Exist", true);
        WindowsLanguage.SetRange("Globally Enabled", true);
    end;

    [Scope('Personalization')]
    procedure GetWindowsLanguageNameFromLanguageCode(LanguageCode: Code[10]): Text
    var
        Language: Record Language;
    begin
        if LanguageCode = '' then
            exit('');

        Language.SetAutoCalcFields("Windows Language Name");
        if Language.Get(LanguageCode) then
            exit(Language."Windows Language Name");

        exit('');
    end;

    [Scope('Personalization')]
    procedure GetWindowsLanguageIDFromLanguageName(LanguageName: Text): Integer
    var
        WindowsLanguage: Record "Windows Language";
    begin
        if LanguageName = '' then
            exit(0);
        WindowsLanguage.SetRange("Localization Exist", true);
        WindowsLanguage.SetFilter(Name, '@*' + CopyStr(LanguageName, 1, MaxStrLen(WindowsLanguage.Name)) + '*');
        if not WindowsLanguage.FindFirst then
            exit(0);

        exit(WindowsLanguage."Language ID");
    end;

    [Scope('Personalization')]
    procedure GetLanguageCodeFromLanguageID(LanguageID: Integer): Code[10]
    var
        Language: Record Language;
    begin
        if LanguageID = 0 then
            exit('');
        Language.SetRange("Windows Language ID", LanguageID);
        if Language.FindFirst then
            exit(Language.Code);
        exit('');
    end;

    [Scope('Personalization')]
    procedure GetWindowsLanguageNameFromLanguageID(LanguageID: Integer): Text
    var
        WindowsLanguage: Record "Windows Language";
    begin
        if LanguageID = 0 then
            exit('');

        if WindowsLanguage.Get(LanguageID) then
            exit(WindowsLanguage.Name);

        exit('');
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000004, 'GetApplicationLanguage', '', false, false)]
    local procedure GetApplicationLanguage(var language: Integer)
    begin
        language := ApplicationLanguage;
    end;

    [Scope('Personalization')]
    procedure GetTranslatedFieldCaption(LanguageCode: Code[10]; TableID: Integer; FieldId: Integer) TranslatedText: Text
    var
        Language: Record Language;
        "Field": Record "Field";
        CurrentLanguageCode: Integer;
    begin
        CurrentLanguageCode := GlobalLanguage;
        if (LanguageCode <> '') and (Language.GetLanguageID(LanguageCode) <> CurrentLanguageCode) then begin
            GlobalLanguage(Language.GetLanguageID(LanguageCode));
            Field.Get(TableID, FieldId);
            TranslatedText := Field."Field Caption";
            GlobalLanguage(CurrentLanguageCode);
        end else begin
            Field.Get(TableID, FieldId);
            TranslatedText := Field."Field Caption";
        end;
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure TryGetCultureName(Culture: Integer; var CultureName: Text)
    var
        CultureInfo: DotNet CultureInfo;
    begin
        CultureInfo := CultureInfo.CultureInfo(Culture);
        CultureName := CultureInfo.Name;
    end;
}

