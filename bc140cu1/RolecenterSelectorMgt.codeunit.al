codeunit 1485 "Rolecenter Selector Mgt."
{

    trigger OnRun()
    begin
    end;

    var
        ActionContainerXmlElementLbl: Label 'ActionContainers', Locked = true;
        ActionContainerTypeAttrLbl: Label 'ActionContainerType', Locked = true;
        ActivityButtonsLbl: Label 'ActivityButtons', Locked = true;
        JsonNameElementLbl: Label 'name', Locked = true;
        TooltipAttrLbl: Label 'ToolTipML', Locked = true;
        CaptionAttrLbl: Label 'CaptionML', Locked = true;
        JsonRowElementLbl: Label 'rows', Locked = true;
        JsonTooltipLbl: Label 'tooltip', Locked = true;
        PromotedAttrLbl: Label 'Promoted', Locked = true;
        ActionCaptionTxt: Label 'Continue';
        ActionDescriptionTxt: Label 'Choose a Role Center that suits your business role, and then choose the Continue button. You can change the Role Center any time.';
        DropdownLbl: Label 'My Role Center';
        JsonHeaderLbl: Label 'HeaderLabel', Locked = true;
        JsonDropdownContentLbl: Label 'DropContent', Locked = true;
        JsonProfileNameLbl: Label 'Name', Locked = true;
        JsonProfileDescriptionLbl: Label 'Description', Locked = true;
        JsonRolecenterIdLbl: Label 'RolecenterId', Locked = true;
        JsonDefaultActionLbl: Label 'DefaultActionLabel', Locked = true;
        JsonDisclaimerTextLbl: Label 'DisclaimerText', Locked = true;
        JsonActionDescriptionLbl: Label 'ActionDescription', Locked = true;
        DisclaimerTxt: Label 'Note that this view merely shows you the breadth of functionality in the selected Role Center. What you will actually see depends on your company and personal UI settings.';
        DefaultLangaugeCodeTxt: Label 'ENU', Locked = true;
        LanguageCodeRegExPatternTxt: Label '[A-Z]{3}=', Locked = true;
        LanguageCodePatternTxt: Label '%1=', Locked = true;
        RoleCenterSelectorAddinTxt: Label 'Microsoft.Dynamics.Nav.Client.RoleCenterSelector', Locked = true;
        RoleCenterSelectorPublickKeyTxt: Label '31bf3856ad364e35', Locked = true;

    [Scope('Internal')]
    procedure BuildJsonFromPageMetadata(RolecenterId: Integer): Text
    var
        TempBlob: Record TempBlob;
        ObjectMetadata: Record "Object Metadata";
        JSONManagement: Codeunit "JSON Management";
        XMLDOMManagement: Codeunit "XML DOM Management";
        ReturnXmlDocument: DotNet XmlDocument;
        ReturnedXMLNodeList: DotNet XmlNodeList;
        ActivityButtonsXmlNode: DotNet XmlNode;
        BucketXmlNode: DotNet XmlNode;
        FeatureXmlNode: DotNet XmlNode;
        FeatureBucketsJArray: DotNet JArray;
        FeatureBucketJObject: DotNet JObject;
        FeatureJArray: DotNet JArray;
        FeatureJObject: DotNet JObject;
        Instream: InStream;
        Outstream: OutStream;
        Tooltip: Text;
        Caption: Text;
    begin
        JSONManagement.InitializeEmptyCollection;
        JSONManagement.GetJsonArray(FeatureBucketsJArray);

        if not ObjectMetadata.Get(ObjectMetadata."Object Type"::Page, RolecenterId) then
            exit(FeatureBucketsJArray.ToString);

        ObjectMetadata.CalcFields(Metadata);
        TempBlob.Blob.CreateOutStream(Outstream);
        ObjectMetadata.Metadata.CreateInStream(Instream);

        XMLDOMManagement.LoadXMLDocumentFromInStream(Instream, ReturnXmlDocument);
        ReturnedXMLNodeList := ReturnXmlDocument.GetElementsByTagName(ActionContainerXmlElementLbl);

        if not GetActivityButtonsActionContainerXmlNode(ActivityButtonsXmlNode, ReturnedXMLNodeList) then
            exit(FeatureBucketsJArray.ToString);

        foreach BucketXmlNode in ActivityButtonsXmlNode.ChildNodes do begin
            JSONManagement.InitializeEmptyObject;
            JSONManagement.GetJSONObject(FeatureBucketJObject);
            GetLanguageSpecificCaptionAndTooltip(BucketXmlNode, Caption, Tooltip);
            JSONManagement.AddJPropertyToJObject(FeatureBucketJObject, JsonNameElementLbl, Caption);
            JSONManagement.AddJPropertyToJObject(FeatureBucketJObject, JsonTooltipLbl, Tooltip);

            FeatureJArray := FeatureJArray.JArray;
            foreach FeatureXmlNode in BucketXmlNode.ChildNodes do
                if IsNodePromoted(FeatureXmlNode) then begin
                    FeatureJObject := FeatureJObject.JObject;
                    GetLanguageSpecificCaptionAndTooltip(FeatureXmlNode, Caption, Tooltip);
                    JSONManagement.AddJPropertyToJObject(FeatureJObject, JsonNameElementLbl, Caption);
                    JSONManagement.AddJPropertyToJObject(FeatureJObject, JsonTooltipLbl, Tooltip);
                    JSONManagement.AddJObjectToJArray(FeatureJArray, FeatureJObject);
                end;

            if FeatureJArray.Count > 0 then begin
                JSONManagement.AddJArrayToJObject(FeatureBucketJObject, JsonRowElementLbl, FeatureJArray);
                JSONManagement.AddJObjectToJArray(FeatureBucketsJArray, FeatureBucketJObject);
            end;
        end;

        exit(FeatureBucketsJArray.ToString);
    end;

    [Scope('Personalization')]
    procedure BuildJsonFromPageActionTable(RolecenterId: Integer): Text
    var
        PageAction: Record "Page Action";
        BucketPageAction: Record "Page Action";
        FeaturePageAction: Record "Page Action";
        JSONManagement: Codeunit "JSON Management";
        FeatureBucketsJArray: DotNet JArray;
        FeatureBucketJObject: DotNet JObject;
        FeatureJArray: DotNet JArray;
        FeatureJObject: DotNet JObject;
    begin
        JSONManagement.InitializeEmptyCollection;
        JSONManagement.GetJsonArray(FeatureBucketsJArray);

        PageAction.SetRange("Page ID", RolecenterId);
        PageAction.SetRange("Action Type", PageAction."Action Type"::ActionContainer);
        PageAction.SetRange("Action Subtype", PageAction."Action Subtype"::ActivityButtons);
        if not PageAction.FindFirst then
            exit(FeatureBucketsJArray.ToString);

        BucketPageAction.SetRange("Page ID", RolecenterId);
        BucketPageAction.SetRange("Parent Action ID", PageAction."Action ID");
        BucketPageAction.SetRange("Action Type", BucketPageAction."Action Type"::ActionGroup);
        BucketPageAction.SetRange(Indentation, 1);
        if BucketPageAction.FindSet then
            repeat
                JSONManagement.InitializeEmptyObject;
                JSONManagement.GetJSONObject(FeatureBucketJObject);
                JSONManagement.AddJPropertyToJObject(FeatureBucketJObject, JsonNameElementLbl, BucketPageAction.Caption);
                JSONManagement.AddJPropertyToJObject(FeatureBucketJObject, JsonTooltipLbl,
                  BucketPageAction.ToolTip1 + BucketPageAction.ToolTip2 + BucketPageAction.ToolTip3 + BucketPageAction.ToolTip4);

                FeatureJArray := FeatureJArray.JArray;
                FeaturePageAction.SetRange("Page ID", RolecenterId);
                FeaturePageAction.SetRange("Parent Action ID", BucketPageAction."Action ID");
                FeaturePageAction.SetRange("Action Type", FeaturePageAction."Action Type"::Action);
                FeaturePageAction.SetRange(Indentation, 2);
                FeaturePageAction.SetRange(Promoted, true);

                if FeaturePageAction.FindSet then
                    repeat
                        FeatureJObject := FeatureJObject.JObject;
                        JSONManagement.AddJPropertyToJObject(FeatureJObject, JsonNameElementLbl, FeaturePageAction.Caption);
                        JSONManagement.AddJPropertyToJObject(FeatureJObject, JsonTooltipLbl,
                          FeaturePageAction.ToolTip1 + FeaturePageAction.ToolTip2 + FeaturePageAction.ToolTip3 + FeaturePageAction.ToolTip4);
                        JSONManagement.AddJObjectToJArray(FeatureJArray, FeatureJObject);
                    until FeaturePageAction.Next = 0;

                if FeatureJArray.Count > 0 then begin
                    JSONManagement.AddJArrayToJObject(FeatureBucketJObject, JsonRowElementLbl, FeatureJArray);
                    JSONManagement.AddJObjectToJArray(FeatureBucketsJArray, FeatureBucketJObject);
                end;
            until BucketPageAction.Next = 0;

        exit(FeatureBucketsJArray.ToString);
    end;

    [Scope('Personalization')]
    procedure BuildPageDataJsonForRolecenterSelector(): Text
    var
        AllProfile: Record "All Profile";
        JSONManagement: Codeunit "JSON Management";
        PageDataJObject: DotNet JObject;
        ProfileJArray: DotNet JArray;
        ProfileJObject: DotNet JObject;
    begin
        JSONManagement.InitializeEmptyObject;
        JSONManagement.GetJSONObject(PageDataJObject);
        JSONManagement.AddJPropertyToJObject(PageDataJObject, JsonHeaderLbl, DropdownLbl);
        JSONManagement.AddJPropertyToJObject(PageDataJObject, JsonDefaultActionLbl, ActionCaptionTxt);
        JSONManagement.AddJPropertyToJObject(PageDataJObject, JsonDisclaimerTextLbl, DisclaimerTxt);
        JSONManagement.AddJPropertyToJObject(PageDataJObject, JsonActionDescriptionLbl, ActionDescriptionTxt);

        JSONManagement.InitializeEmptyCollection;
        JSONManagement.GetJsonArray(ProfileJArray);

        if FindSaaSProfiles(AllProfile) then
            repeat
                JSONManagement.InitializeEmptyObject;
                JSONManagement.GetJSONObject(ProfileJObject);
                JSONManagement.AddJPropertyToJObject(ProfileJObject, JsonProfileNameLbl, Format(AllProfile.RecordId));
                JSONManagement.AddJPropertyToJObject(ProfileJObject, JsonProfileDescriptionLbl, AllProfile.Description);
                JSONManagement.AddJPropertyToJObject(ProfileJObject, JsonRolecenterIdLbl, AllProfile."Role Center ID");
                JSONManagement.AddJObjectToJArray(ProfileJArray, ProfileJObject);
            until AllProfile.Next = 0;

        JSONManagement.AddJArrayToJObject(PageDataJObject, JsonDropdownContentLbl, ProfileJArray);

        exit(PageDataJObject.ToString);
    end;

    local procedure FindSaaSProfiles(var AllProfile: Record "All Profile"): Boolean
    var
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        ConfPersonalizationMgt.HideSandboxProfiles(AllProfile);
        exit(AllProfile.FindSet);
    end;

    local procedure IsRolecenterSelectorInstalled(): Boolean
    var
        Addin: Record "Add-in";
    begin
        Addin.SetRange("Add-in Name", RoleCenterSelectorAddinTxt);
        Addin.SetRange("Public Key Token", RoleCenterSelectorPublickKeyTxt);
        Addin.SetRange(Category, Addin.Category::"JavaScript Control Add-in");

        if Addin.FindFirst then
            if Addin.Resource.HasValue then
                exit(true);
    end;

    procedure IsRolecenterSelectorEnabled(UserName: Code[50]): Boolean
    begin
        if not IsRolecenterSelectorInstalled then
            exit(false);

        exit(GetShowStateFromUserPreference(UserName));
    end;

    local procedure GetActivityButtonsActionContainerXmlNode(var ActivityButtonsXmlNode: DotNet XmlNode; ActionContainerXmlNodeList: DotNet XmlNodeList): Boolean
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
    begin
        if IsNull(ActionContainerXmlNodeList) then
            exit(false);

        foreach ActivityButtonsXmlNode in ActionContainerXmlNodeList do
            if XMLDOMManagement.GetAttributeValue(ActivityButtonsXmlNode, ActionContainerTypeAttrLbl) = ActivityButtonsLbl then
                exit(true);

        exit(false);
    end;

    local procedure IsNodePromoted(FeatureXmlNode: DotNet XmlNode): Boolean
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
    begin
        exit(XMLDOMManagement.GetAttributeValue(FeatureXmlNode, PromotedAttrLbl) = '1');
    end;

    local procedure GetLanguageSpecificCaptionAndTooltip(XmlNode: DotNet XmlNode; var Caption: Text; var Tooltip: Text)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
    begin
        Caption := '';
        Tooltip := '';

        Caption := GetLanguageSpecificText(GlobalLanguage, XMLDOMManagement.GetAttributeValue(XmlNode, CaptionAttrLbl));
        Tooltip := GetLanguageSpecificText(GlobalLanguage, XMLDOMManagement.GetAttributeValue(XmlNode, TooltipAttrLbl));
        if Tooltip = '' then
            Tooltip := Caption;
    end;

    local procedure GetLanguageSpecificText(LanguageID: Integer; InputMLText: Text) ReturnText: Text
    var
        Language: Record Language;
        RegEx: DotNet Regex;
        RegExMatch: DotNet Match;
        RegExMatchs: DotNet MatchCollection;
        Dictionary: DotNet Dictionary_Of_T_U;
        PrevMatch: DotNet Match;
        HtmlUtility: DotNet HttpUtility;
        LanguageCode: Text;
    begin
        LanguageCode := DefaultLangaugeCodeTxt;

        Language.SetRange("Windows Language ID", LanguageID);
        if Language.FindFirst then
            LanguageCode := Language.Code;

        Dictionary := Dictionary.Dictionary;
        RegExMatchs := RegEx.Matches(InputMLText, StrSubstNo(LanguageCodeRegExPatternTxt));

        foreach RegExMatch in RegExMatchs do begin
            if not IsNull(PrevMatch) then
                Dictionary.Add(
                  PrevMatch.Value,
                  CopyStr(InputMLText, PrevMatch.Index + PrevMatch.Length + 1, RegExMatch.Index - (PrevMatch.Index + PrevMatch.Length) - 1));
            PrevMatch := RegExMatch;
        end;

        if not IsNull(PrevMatch) then
            Dictionary.Add(
              PrevMatch.Value,
              CopyStr(InputMLText, PrevMatch.Index + PrevMatch.Length + 1, StrLen(InputMLText) - (PrevMatch.Index + PrevMatch.Length)));

        if not Dictionary.TryGetValue(StrSubstNo(LanguageCodePatternTxt, LanguageCode), ReturnText) then
            if LanguageCode <> DefaultLangaugeCodeTxt then
                if not Dictionary.TryGetValue(StrSubstNo(LanguageCodePatternTxt, DefaultLangaugeCodeTxt), ReturnText) then
                    exit;

        ReturnText := HtmlUtility.HtmlDecode(ReturnText);
        if StrPos(ReturnText, '"') <> 0 then
            ReturnText := CopyStr(ReturnText, 2, StrLen(ReturnText) - 2);
    end;

    [Scope('Personalization')]
    procedure GetShowStateFromUserPreference(UserName: Code[50]) RoleCenterSelectorIsEnabled: Boolean
    var
        UserPreference: Record "User Preference";
    begin
        if not UserPreference.Get(UserName, GetUserPreferenceCode) then
            exit(false);

        UserPreference.CalcFields("User Selection");

        if not Evaluate(RoleCenterSelectorIsEnabled, UserPreference.GetUserSelectionAsText) then
            exit(false);
    end;

    [Scope('Personalization')]
    procedure SetShowStateFromUserPreference(UserName: Code[50]; State: Boolean)
    var
        UserPreference: Record "User Preference";
    begin
        if UserPreference.Get(UserName, GetUserPreferenceCode) then begin
            UserPreference.SetUserSelection(State);
            UserPreference.Modify;
            exit;
        end;

        UserPreference.Init;
        UserPreference."User ID" := UserName;
        UserPreference."Instruction Code" := GetUserPreferenceCode;
        UserPreference.SetUserSelection(State);
        UserPreference.Insert;
    end;

    [Scope('Personalization')]
    procedure GetUserPreferenceCode(): Code[50]
    begin
        exit(UpperCase('RoleCenterOverviewShowState'));
    end;
}

