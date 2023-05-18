codeunit 9998 "Upgrade Tags"
{

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 9999, 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var TempUpgradeTags: Record "Upgrade Tags" temporary)
    var
        UpgradeTagMgt: Codeunit "Upgrade Tag Mgt";
    begin
        UpgradeTagMgt.RegisterUpgradeTag(GetTimeRegistrationUpgradeTag,TempUpgradeTags);
        UpgradeTagMgt.RegisterUpgradeTag(GetSalesInvoiceEntityAggregateUpgradeTag,TempUpgradeTags);
        UpgradeTagMgt.RegisterUpgradeTag(GetPurchInvEntityAggregateUpgradeTag,TempUpgradeTags);
        UpgradeTagMgt.RegisterUpgradeTag(GetSalesOrderEntityBufferUpgradeTag,TempUpgradeTags);
        UpgradeTagMgt.RegisterUpgradeTag(GetSalesQuoteEntityBufferUpgradeTag,TempUpgradeTags);
        UpgradeTagMgt.RegisterUpgradeTag(GetSalesCrMemoEntityBufferUpgradeTag,TempUpgradeTags);
        UpgradeTagMgt.RegisterUpgradeTag(GetCleanupDataExchUpgradeTag,TempUpgradeTags);
        UpgradeTagMgt.RegisterUpgradeTag(GetDefaultDimensionAPIUpgradeTag,TempUpgradeTags);
        UpgradeTagMgt.RegisterUpgradeTag(GetBalAccountNoOnJournalAPIUpgradeTag,TempUpgradeTags);
        UpgradeTagMgt.RegisterUpgradeTag(GetItemCategoryOnItemAPIUpgradeTag,TempUpgradeTags);
        UpgradeTagMgt.RegisterUpgradeTag(GetInvoicingSetJobQueueEntriesOnHoldTag,TempUpgradeTags);
        UpgradeTagMgt.RegisterUpgradeTag(GetMoveCurrencyISOCodeTag,TempUpgradeTags);
        UpgradeTagMgt.RegisterUpgradeTag(GetVATRepSetupPeriodRemCalcUpgradeTag,TempUpgradeTags);
    end;

    [EventSubscriber(ObjectType::Codeunit, 9999, 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseTags(var TempUpgradeTags: Record "Upgrade Tags" temporary)
    var
        UpgradeTagMgt: Codeunit "Upgrade Tag Mgt";
    begin
        UpgradeTagMgt.RegisterUpgradeTag(GetNewISVPlansUpgradeTag,TempUpgradeTags);
        UpgradeTagMgt.RegisterUpgradeTag(GetWorkflowWebhookWebServicesUpgradeTag,TempUpgradeTags);
        UpgradeTagMgt.RegisterUpgradeTag(GetExcelTemplateWebServicesUpgradeTag,TempUpgradeTags);
    end;

    [Scope('Personalization')]
    procedure GetTimeRegistrationUpgradeTag(): Code[250]
    begin
        exit('284963-TimeRegistrationAPI-ReadOnly-20181010');
    end;

    [Scope('Personalization')]
    procedure GetSalesInvoiceEntityAggregateUpgradeTag(): Code[250]
    begin
        exit('298839-SalesInvoiceAddingMultipleAddresses-20190213');
    end;

    [Scope('Personalization')]
    procedure GetPurchInvEntityAggregateUpgradeTag(): Code[250]
    begin
        exit('294917-PurchInvoiceAddingMultipleAddresses-20190213');
    end;

    [Scope('Personalization')]
    procedure GetSalesOrderEntityBufferUpgradeTag(): Code[250]
    begin
        exit('298839-SalesOrderAddingMultipleAddresses-20190213');
    end;

    [Scope('Personalization')]
    procedure GetSalesQuoteEntityBufferUpgradeTag(): Code[250]
    begin
        exit('298839-SalesQuoteAddingMultipleAddresses-20190213');
    end;

    [Scope('Personalization')]
    procedure GetSalesCrMemoEntityBufferUpgradeTag(): Code[250]
    begin
        exit('298839-SalesCrMemoAddingMultipleAddresses-20190213');
    end;

    [Scope('Personalization')]
    procedure GetNewISVPlansUpgradeTag(): Code[250]
    begin
        exit('MS-287563-NewISVPlansAdded-20181105');
    end;

    [Scope('Personalization')]
    procedure GetWorkflowWebhookWebServicesUpgradeTag(): Code[250]
    begin
        exit('MS-281716-WorkflowWebhookWebServices-20180907');
    end;

    [Scope('Personalization')]
    procedure GetExcelTemplateWebServicesUpgradeTag(): Code[250]
    begin
        exit('MS-281716-ExcelTemplateWebServices-20180907');
    end;

    [Scope('Personalization')]
    procedure GetCleanupDataExchUpgradeTag(): Code[250]
    begin
        exit('MS-CleanupDataExchUpgrade-20180821');
    end;

    [Scope('Personalization')]
    procedure GetDefaultDimensionAPIUpgradeTag(): Code[250]
    begin
        exit('MS-275427-DefaultDimensionAPI-20180719');
    end;

    [Scope('Personalization')]
    procedure GetBalAccountNoOnJournalAPIUpgradeTag(): Code[250]
    begin
        exit('MS-275328-BalAccountNoOnJournalAPI-20180823');
    end;

    [Scope('Personalization')]
    procedure GetItemCategoryOnItemAPIUpgradeTag(): Code[250]
    begin
        exit('MS-279686-ItemCategoryOnItemAPI-20180903');
    end;

    [Scope('Personalization')]
    procedure GetInvoicingSetJobQueueEntriesOnHoldTag(): Code[250]
    begin
        exit('MS-294186-InvoicingSetJobQueueEntriesOnHold-20190301');
    end;

    [Scope('Personalization')]
    procedure GetMoveCurrencyISOCodeTag(): Code[250]
    begin
        exit('MS-267101-MoveCurrencyISOCode-20190209');
    end;

    [Scope('Personalization')]
    procedure GetVATRepSetupPeriodRemCalcUpgradeTag(): Code[250]
    begin
        exit('MS-306583-VATReportSetup-20190402');
    end;
}

