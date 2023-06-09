page 5329 "CRM Redirect"
{
    Caption = 'CRM Redirect';
    SourceTable = "CRM Redirect";

    layout
    {
        area(content)
        {
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        CRMInfo: Text;
        CRMID: Guid;
        CRMEntityTypeName: Text;
    begin
        CRMInfo := ExtractCRMInfoFromFilters;
        ExtractPartsFromCRMInfo(CRMInfo,CRMID,CRMEntityTypeName);

        // Open the page of the coupled NAV record, or if it is not coupled, offer to create
        if not CRMIntegrationManagement.OpenCoupledNavRecordPage(CRMID,CRMEntityTypeName) then
          // TODO: Give the user the option to couple to an existing NAV entity or create one from CRM
          // For now just do nothing
          ;

        CurrPage.Close;
    end;

    trigger OnOpenPage()
    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
    begin
        if not CRMIntegrationManagement.IsCRMIntegrationEnabled then
          Error(CRMIntegrationNotEnabledErr,CRMProductName.SHORT);
    end;

    var
        FilterRegexTok: Label '\A%1: @\*(.*)\*\z', Locked=true;
        CRMInfoRegexTok: Label 'CRMID:(\{[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\});CRMType:([a-z \/]*)\z', Locked=true;
        InvalidFilterErr: Label 'The URL contains an incorrectly formatted filter string and cannot be processed.';
        InvalidCRMIDErr: Label 'The %2 ID in the URL is not correctly formatted: %1.', Comment='%1 = Whatever was passed as CRM ID in the filter, but clearly not an actual CRM ID. %2 = CRM product name';
        CRMIntegrationNotEnabledErr: Label 'Integration with %1 is not enabled.', Comment='%1 = CRM product name';
        CRMProductName: Codeunit "CRM Product Name";

    [Scope('Personalization')]
    procedure ExtractCRMInfoFromFilters() CRMInfo: Text
    var
        RegexHelper: DotNet Regex;
        MatchHelper: DotNet Match;
        GroupCollectionHelper: DotNet GroupCollection;
        GroupHelper: DotNet Group;
        FilterText: Text;
    begin
        FilterText := GetFilters;
        RegexHelper := RegexHelper.Regex(StrSubstNo(FilterRegexTok,FieldCaption(Filter)));
        MatchHelper := RegexHelper.Match(FilterText);
        if not MatchHelper.Success then
          Error(InvalidFilterErr);
        GroupCollectionHelper := MatchHelper.Groups;
        GroupHelper := GroupCollectionHelper.Item(1);
        CRMInfo := GroupHelper.Value;
    end;

    [Scope('Personalization')]
    procedure ExtractPartsFromCRMInfo(CRMInfo: Text;var CRMID: Guid;var CRMEntityTypeName: Text)
    var
        RegexHelper: DotNet Regex;
        RegexOptionsHelper: DotNet RegexOptions;
        MatchHelper: DotNet Match;
        GroupCollectionHelper: DotNet GroupCollection;
        GroupHelper: DotNet Group;
    begin
        // Extract the CRM ID and CRM entity type name from the CRM info string
        RegexOptionsHelper := RegexOptionsHelper.IgnoreCase;
        RegexHelper := RegexHelper.Regex(CRMInfoRegexTok,RegexOptionsHelper);
        MatchHelper := RegexHelper.Match(CRMInfo);
        if not MatchHelper.Success then
          Error(InvalidFilterErr);
        GroupCollectionHelper := MatchHelper.Groups;
        GroupHelper := GroupCollectionHelper.Item(1);
        if not Evaluate(CRMID,GroupHelper.Value) then
          Error(InvalidCRMIDErr,CRMProductName.SHORT);
        GroupHelper := GroupCollectionHelper.Item(2);
        CRMEntityTypeName := GroupHelper.Value;
    end;
}

