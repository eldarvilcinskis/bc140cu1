page 2503 "Extension Installation"
{
    Caption = 'Extension Installation';
    PageType = Card;
    SourceTable = "NAV App";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
        }
    }

    actions
    {
        area(processing)
        {
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        CurrPage.Close;
    end;

    trigger OnOpenPage()
    var
        MarketplaceExtnDeployment: Page "Marketplace Extn. Deployment";
    begin
        GetDetailsFromFilters;
        ExtensionAppId := ID;
        TelemetryUrl := responseUrl;

        MarketplaceExtnDeployment.SetAppIDAndTelemetryUrl(ExtensionAppId, TelemetryUrl);
        MarketplaceExtnDeployment.Run;
    end;

    var
        ExtensionAppId: Text;
        TelemetryUrl: Text;

    local procedure GetDetailsFromFilters()
    var
        RecRef: RecordRef;
        i: Integer;
    begin
        RecRef.GetTable(Rec);
        for i := 1 to RecRef.FieldCount do
            ParseFilter(RecRef.FieldIndex(i));
        RecRef.SetTable(Rec);
    end;

    local procedure ParseFilter(FieldRef: FieldRef)
    var
        FilterPrefixDotNet_Regex: Codeunit DotNet_Regex;
        SingleQuoteDotNet_Regex: Codeunit DotNet_Regex;
        EscapedEqualityDotNet_Regex: Codeunit DotNet_Regex;
        "Filter": Text;
    begin
        FilterPrefixDotNet_Regex.Regex('^@\*([^\\]+)\*$');
        SingleQuoteDotNet_Regex.Regex('^''([^\\]+)''$');
        EscapedEqualityDotNet_Regex.Regex('~');
        Filter := FieldRef.GetFilter;
        Filter := FilterPrefixDotNet_Regex.Replace(Filter, '$1');
        Filter := SingleQuoteDotNet_Regex.Replace(Filter, '$1');
        Filter := EscapedEqualityDotNet_Regex.Replace(Filter, '=');

        if Filter <> '' then
            FieldRef.Value(Filter);
    end;
}

