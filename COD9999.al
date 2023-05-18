codeunit 9999 "Upgrade Tag Mgt"
{
    // Format of the upgrade tag is:
    // [CompanyPrefix]-[TFSID]-[Description]-[YYYYMMDD]
    // 
    // Example:
    // MS-29901-UpdateGLEntriesIntegrationRecordIDs-20161206

    Permissions = TableData "Upgrade Tags"=rimd;

    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure HasUpgradeTag(Tag: Code[250]): Boolean
    var
        UpgradeTags: Record "Upgrade Tags";
    begin
        exit(UpgradeTags.Get(Tag,CompanyName));
    end;

    [Scope('Personalization')]
    procedure SetUpgradeTag(NewTag: Code[250])
    begin
        SetUpgradeTagForCompany(NewTag,CompanyName);
    end;

    [Scope('Personalization')]
    procedure RegisterUpgradeTag(NewUpgradeTag: Text[250];var TempUpgradeTags: Record "Upgrade Tags" temporary)
    begin
        Clear(TempUpgradeTags);
        TempUpgradeTags.Tag := NewUpgradeTag;
        TempUpgradeTags.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 2, 'OnCompanyInitialize', '', false, false)]
    local procedure EnsureUpgradeTagsAreRegisteredForNewCompany()
    var
        TempPerCompanyUpgradeTags: Record "Upgrade Tags" temporary;
        TempPerDatabaseUpgradeTags: Record "Upgrade Tags" temporary;
    begin
        OnGetPerDatabaseUpgradeTags(TempPerDatabaseUpgradeTags);
        EnsurePerDatabaseUpgradeTagsExist(TempPerDatabaseUpgradeTags);

        OnGetPerCompanyUpgradeTags(TempPerCompanyUpgradeTags);
        EnsurePerCompanyUpgradeTagsExist(TempPerCompanyUpgradeTags);
    end;

    local procedure EnsurePerCompanyUpgradeTagsExist(var TempUpgradeTags: Record "Upgrade Tags" temporary)
    begin
        if not TempUpgradeTags.FindFirst then
          exit;

        repeat
          if not HasUpgradeTag(TempUpgradeTags.Tag) then
            SetUpgradeTag(TempUpgradeTags.Tag);
        until TempUpgradeTags.Next = 0;
    end;

    local procedure EnsurePerDatabaseUpgradeTagsExist(var TempUpgradeTags: Record "Upgrade Tags" temporary)
    var
        UpgradeTags: Record "Upgrade Tags";
    begin
        if not TempUpgradeTags.FindFirst then
          exit;

        repeat
          if not UpgradeTags.Get(TempUpgradeTags.Tag,'') then
            SetUpgradeTagForCompany(TempUpgradeTags.Tag,'');
        until TempUpgradeTags.Next = 0;
    end;

    local procedure SetUpgradeTagForCompany(NewTag: Code[250];CompanyName: Text[30])
    var
        UpgradeTags: Record "Upgrade Tags";
    begin
        UpgradeTags.Validate(Tag,NewTag);
        UpgradeTags.Validate("Tag Timestamp",CurrentDateTime);
        UpgradeTags.Validate(Company,CompanyName);
        UpgradeTags.Insert(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetPerCompanyUpgradeTags(var TempUpgradeTags: Record "Upgrade Tags" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetPerDatabaseUpgradeTags(var TempUpgradeTags: Record "Upgrade Tags" temporary)
    begin
    end;
}

