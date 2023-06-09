codeunit 6100 "Data Migration Facade"
{

    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure StartMigration(MigrationType: Text[250]; Retry: Boolean)
    var
        DataMigrationMgt: Codeunit "Data Migration Mgt.";
    begin
        DataMigrationMgt.StartMigration(MigrationType, Retry);
    end;

    [EventSubscriber(ObjectType::Table, 1800, 'OnRegisterDataMigrator', '', false, false)]
    local procedure OnRegisterDataMigratorWizardSubscriber(var Sender: Record "Data Migrator Registration")
    begin
        OnRegisterDataMigrator(Sender);
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnRegisterDataMigrator(var DataMigratorRegistration: Record "Data Migrator Registration")
    begin
        // Event which makes all data migrators register themselves in this table.
    end;

    [EventSubscriber(ObjectType::Table, 1800, 'OnGetInstructions', '', false, false)]
    local procedure OnRegisterGetInstructionsWizardSubscriber(var Sender: Record "Data Migrator Registration"; var Instructions: Text; var Handled: Boolean)
    begin
        OnGetInstructions(Sender, Instructions, Handled);
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnGetInstructions(var DataMigratorRegistration: Record "Data Migrator Registration"; var Instructions: Text; var Handled: Boolean)
    begin
        // Event which makes all registered data migrators publish their instructions.
    end;

    [EventSubscriber(ObjectType::Table, 1800, 'OnDataImport', '', false, false)]
    local procedure OnDataImportWizardSubscriber(var Sender: Record "Data Migrator Registration"; var Handled: Boolean)
    begin
        OnDataImport(Sender, Handled);
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnDataImport(var DataMigratorRegistration: Record "Data Migrator Registration"; var Handled: Boolean)
    begin
        // Event which makes all registered data migrators import data.
    end;

    [EventSubscriber(ObjectType::Table, 1800, 'OnSelectDataToApply', '', false, false)]
    local procedure OnSelectDataToApplyWizardSubscriber(var Sender: Record "Data Migrator Registration"; var DataMigrationEntity: Record "Data Migration Entity"; var Handled: Boolean)
    begin
        OnSelectDataToApply(Sender, DataMigrationEntity, Handled);
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnSelectDataToApply(var DataMigratorRegistration: Record "Data Migrator Registration"; var DataMigrationEntity: Record "Data Migration Entity"; var Handled: Boolean)
    begin
        // Event which makes all registered data migrators populate the Data Migration Entities table, which allows the user to choose which imported data should be applied.
    end;

    [EventSubscriber(ObjectType::Table, 1800, 'OnApplySelectedData', '', false, false)]
    local procedure OnApplySelectedDataWizardSubscriber(var Sender: Record "Data Migrator Registration"; var DataMigrationEntity: Record "Data Migration Entity"; var Handled: Boolean)
    begin
        OnApplySelectedData(Sender, DataMigrationEntity, Handled);
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnApplySelectedData(var DataMigratorRegistration: Record "Data Migrator Registration"; var DataMigrationEntity: Record "Data Migration Entity"; var Handled: Boolean)
    begin
        // Event which makes all registered data migrators apply the data, which is selected in the Data Migration Entities table.
    end;

    [EventSubscriber(ObjectType::Table, 1800, 'OnShowThatsItMessage', '', false, false)]
    local procedure OnShowThatsItMessageWizardSubscriber(var Sender: Record "Data Migrator Registration"; var Message: Text)
    begin
        OnShowThatsItMessage(Sender, Message);
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnShowThatsItMessage(var DataMigratorRegistration: Record "Data Migrator Registration"; var Message: Text)
    begin
        // Event which shows specific data migrator text at the last page
    end;

    [EventSubscriber(ObjectType::Table, 1800, 'OnEnableTogglingDataMigrationOverviewPage', '', false, false)]
    local procedure OnEnableTogglingDataMigrationOverviewPageWizardSubscriber(var Sender: Record "Data Migrator Registration"; var EnableTogglingOverviewPage: Boolean)
    begin
        OnEnableTogglingDataMigrationOverviewPage(Sender, EnableTogglingOverviewPage);
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnEnableTogglingDataMigrationOverviewPage(var DataMigratorRegistration: Record "Data Migrator Registration"; var EnableTogglingOverviewPage: Boolean)
    begin
        // Event which determines if the option to launch the overview page will be shown to the user at the end.
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnFillStagingTables()
    begin
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnFindBatchForItemTransactions(MigrationType: Text[250]; var ItemJournalBatchName: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnFindBatchForCustomerTransactions(MigrationType: Text[250]; var GenJournalBatchName: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnFindBatchForVendorTransactions(MigrationType: Text[250]; var GenJournalBatchName: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnFindBatchForAccountTransactions(DataMigrationStatus: Record "Data Migration Status"; var GenJournalBatchName: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnGetMigrationHelpTopicUrl(MigrationType: Text; var Url: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnSelectRowFromDashboard(var DataMigrationStatus: Record "Data Migration Status")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnMigrationCompleted(DataMigrationStatus: Record "Data Migration Status")
    begin
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnInitDataMigrationError(MigrationType: Text[250]; var BulkFixErrorsButtonEnabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnBatchEditFromErrorView(MigrationType: Text[250]; DestinationTableId: Integer)
    begin
    end;
}

