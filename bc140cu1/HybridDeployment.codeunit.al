codeunit 6060 "Hybrid Deployment"
{
    Permissions = TableData "Hybrid Deployment Setup" = rimd,
                  TableData "Intelligent Cloud" = rimd,
                  TableData "Intelligent Cloud Status" = rimd,
                  TableData "Webhook Subscription" = rimd;

    trigger OnRun()
    begin
    end;

    var
        SourceProduct: Text;
        FailedToProcessRequestErr: Label 'The request could not be processed due to an unexpected error.';
        FailedCreatingIRErr: Label 'Failed to create your integration runtime.';
        FailedDisableReplicationErr: Label 'Failed to disable replication.';
        FailedEnableReplicationErr: Label 'Failed to enable your replication.\\Make sure your integration runtime is successfully connected and try again.';
        FailedGettingStatusErr: Label 'Failed to retrieve the replication run status.';
        FailedGettingIRKeyErr: Label 'Failed to get your integration runtime key. Please try again.';
        FailedGettingVersionInformationErr: Label 'Failed to get the version information. Please try again.';
        FailedPreparingTablesErr: Label 'Failed to prepare tables for replication. See the help document for more information.';
        FailedRegeneratingIRKeyErr: Label 'Failed to regenerate your integration runtime key. Please try again.';
        FailedRunReplicationErr: Label 'Failed to trigger replication. Please try again.';
        FailedRunUpgradeErr: Label 'Failed to trigger upgrade. Please try again.';
        FailedSetRepScheduleErr: Label 'Failed to set the replication schedule. Please try again.';
        CompletedTxt: Label 'Completed', Locked = true;
        FailedTxt: Label 'Failed', Locked = true;
        InvalidProductErr: Label 'The product specified in the request is invalid.';
        InvalidRunIdErr: Label 'The specified replication run could not be found.';
        InvalidTenantErr: Label 'The tenant specified in the request is invalid for the request.';
        InvalidIntegrationRuntimeNameErr: Label 'The integration runtime name specified is invalid.';
        NoIntegrationRuntimeErr: Label 'The tenant is not configured to use an integration runtime.';
        PrepareServersFailureErr: Label 'Failed to prepare the systems for replication.';
        ReplicationNotEnabledErr: Label 'Cannot perform the requested action because replication of data between on-premises and the cloud has not been set up. Please contact your administrator.';
        SelfHostedIRNotFoundErr: Label 'Could not find the self-hosted integration runtime. Please ensure the self-hosted integration runtime is running and connected.';
        ConnectionStringFailureErr: Label 'The connection string is invalid.';
        SqlTimeoutErr: Label 'The server timed out while attempting to connect to the specified SQL server.';
        TooManyReplicationRunsErr: Label 'Cannot start replication because a replication is currently in progress. Please try again at a later time.';
        NoAdfCapacityErr: Label 'The Intelligent Cloud is temporarily unable to process your request. Please try again at a later time.';

    procedure Initialize(SourceProductId: Text)
    begin
        SourceProduct := SourceProductId;
        OnInitialize(SourceProductId);
    end;

    procedure CreateIntegrationRuntime(var RuntimeName: Text; var PrimaryKey: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        InstanceId: Text;
        JsonOutput: Text;
    begin
        if not TryCreateIntegrationRuntime(InstanceId) then
            Error(FailedCreatingIRErr);

        RetryGetStatus(InstanceId, FailedCreatingIRErr, JsonOutput);

        JSONManagement.InitializeObject(JsonOutput);
        JSONManagement.GetStringPropertyValueByName('Name', RuntimeName);
        JSONManagement.GetStringPropertyValueByName('PrimaryKey', PrimaryKey);
    end;

    procedure DisableReplication()
    var
        InstanceId: Text;
        Output: Text;
    begin
        if not TryDisableReplication(InstanceId) then
            Error(FailedDisableReplicationErr);

        RetryGetStatus(InstanceId, FailedDisableReplicationErr, Output);

        EnableIntelligentCloud(false);
    end;

    procedure EnableReplication(OnPremConnectionString: Text; DatabaseConfiguration: Text; IntegrationRuntimeName: Text)
    var
        PermissionManager: Codeunit "Permission Manager";
        NotificationUrl: Text;
        SubscriptionId: Text[150];
        ClientState: Text[50];
        InstanceId: Text;
        Output: Text;
        ServiceNotificationUrl: Text;
        ServiceSubscriptionId: Text[150];
        ServiceClientState: Text[50];
    begin
        OnBeforeEnableReplication(
          SourceProduct, NotificationUrl, SubscriptionId, ClientState,
          ServiceNotificationUrl, ServiceSubscriptionId, ServiceClientState);

        if not TryEnableReplication(
             InstanceId, OnPremConnectionString, DatabaseConfiguration, IntegrationRuntimeName, NotificationUrl, ClientState,
             SubscriptionId, ServiceNotificationUrl, ServiceClientState, ServiceSubscriptionId)
        then
            Error(FailedEnableReplicationErr);

        RetryGetStatus(InstanceId, FailedEnableReplicationErr, Output);

        EnableIntelligentCloud(true);
        PermissionManager.ResetUsersToIntelligentCloudUserGroup;
    end;

    procedure GetIntegrationRuntimeKeys(var PrimaryKey: Text; var SecondaryKey: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        InstanceId: Text;
        JsonOutput: Text;
    begin
        if not TryGetIntegrationRuntimeKeys(InstanceId) then
            Error(FailedGettingIRKeyErr);

        RetryGetStatus(InstanceId, FailedGettingIRKeyErr, JsonOutput);

        JSONManagement.InitializeObject(JsonOutput);
        JSONManagement.GetStringPropertyValueByName('PrimaryKey', PrimaryKey);
        JSONManagement.GetStringPropertyValueByName('SecondaryKey', SecondaryKey);
    end;

    procedure GetReplicationRunStatus(RunId: Text; var Status: Text; var Errors: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        InstanceId: Text;
        JsonOutput: Text;
        TempError: Text;
        TempMessage: Text;
        i: Integer;
    begin
        if not TryGetReplicationRunStatus(InstanceId, RunId) then
            Error(FailedGettingStatusErr);

        RetryGetStatus(InstanceId, FailedGettingStatusErr, JsonOutput);

        JSONManagement.InitializeObject(JsonOutput);
        JSONManagement.GetStringPropertyValueByName('Status', Status);
        JSONManagement.GetStringPropertyValueByName('Errors', Errors);
        JSONManagement.InitializeObject(Errors);
        JSONManagement.GetArrayPropertyValueAsStringByName('$values', Errors);
        JSONManagement.InitializeCollection(Errors);

        Errors := '';
        for i := 0 to JSONManagement.GetCollectionCount - 1 do begin
            JSONManagement.GetObjectFromCollectionByIndex(TempError, i);

            // Check if the error contains an error code and fetch the message
            TempMessage := GetErrorMessage(TempError);
            if TempMessage = '' then
                TempMessage := TempError;

            Errors += TempMessage + '\';
        end;
        Errors := DelChr(Errors, '>', '\');
    end;

    procedure GetRequestStatus(RequestTrackingId: Text; var JsonOutput: Text) Status: Text
    begin
        OnGetRequestStatus(RequestTrackingId, JsonOutput, Status);
    end;

    procedure GetVersionInformation(var DeployedVersion: Text; var LatestVersion: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        InstanceId: Text;
        JsonOutput: Text;
    begin
        if not TryGetVersionInformation(InstanceId) then
            Error(FailedGettingVersionInformationErr);

        RetryGetStatus(InstanceId, FailedGettingVersionInformationErr, JsonOutput);

        JSONManagement.InitializeObject(JsonOutput);
        JSONManagement.GetStringPropertyValueByName('DeployedVersion', DeployedVersion);
        JSONManagement.GetStringPropertyValueByName('LatestVersion', LatestVersion);
    end;

    procedure PrepareTablesForReplication()
    begin
        if not TryPrepareTablesForReplication then
            Error(FailedPreparingTablesErr);
    end;

    procedure RegenerateIntegrationRuntimeKeys(var PrimaryKey: Text; var SecondaryKey: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        InstanceId: Text;
        JsonOutput: Text;
    begin
        if not TryRegenerateIntegrationRuntimeKeys(InstanceId) then
            Error(FailedRegeneratingIRKeyErr);

        RetryGetStatus(InstanceId, FailedRegeneratingIRKeyErr, JsonOutput);

        JSONManagement.InitializeObject(JsonOutput);
        JSONManagement.GetStringPropertyValueByName('PrimaryKey', PrimaryKey);
        JSONManagement.GetStringPropertyValueByName('SecondaryKey', SecondaryKey);
    end;

    procedure ResetCloudData()
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
    begin
        IntelligentCloudStatus.ModifyAll("Synced Version", 0);
        Commit;
    end;

    procedure RunReplication(var RunId: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        InstanceId: Text;
        JsonOutput: Text;
    begin
        if not TryRunReplication(InstanceId) then
            Error(FailedRunReplicationErr);

        RetryGetStatus(InstanceId, FailedRunReplicationErr, JsonOutput);

        JSONManagement.InitializeObject(JsonOutput);
        JSONManagement.GetStringPropertyValueByName('RunId', RunId);
    end;

    procedure RunUpgrade()
    var
        InstanceId: Text;
        JsonOutput: Text;
    begin
        if not TryRunUpgrade(InstanceId) then
            Error(FailedRunUpgradeErr);

        RetryGetStatus(InstanceId, FailedRunUpgradeErr, JsonOutput);
    end;

    procedure SetReplicationSchedule(ReplicationFrequency: Text; DaysToRun: Text; TimeToRun: Time; Activate: Boolean)
    var
        InstanceId: Text;
        Output: Text;
    begin
        if not TrySetReplicationSchedule(InstanceId, ReplicationFrequency, DaysToRun, TimeToRun, Activate) then
            Error(FailedSetRepScheduleErr);

        RetryGetStatus(InstanceId, FailedSetRepScheduleErr, Output);
    end;

    [EventSubscriber(ObjectType::Codeunit, 2, 'OnCompanyInitialize', '', false, false)]
    local procedure HandleCompanyInit()
    var
        HybridDeploymentSetup: Record "Hybrid Deployment Setup";
    begin
        if not HybridDeploymentSetup.IsEmpty then
            exit;

        HybridDeploymentSetup.Init;
        HybridDeploymentSetup.Insert;
    end;

    local procedure EnableIntelligentCloud(Enabled: Boolean)
    var
        IntelligentCloud: Record "Intelligent Cloud";
    begin
        if not IntelligentCloud.Get then begin
            IntelligentCloud.Init;
            IntelligentCloud.Enabled := Enabled;
            IntelligentCloud.Insert;
        end else begin
            IntelligentCloud.Enabled := Enabled;
            IntelligentCloud.Modify;
        end;
    end;

    local procedure RetryGetStatus(InstanceId: Text; GenericErrorMessage: Text; var JsonOutput: Text) Status: Text
    var
        Message: Text;
    begin
        if InstanceId = '' then
            exit;

        repeat
            Sleep(1000);
            Status := GetRequestStatus(InstanceId, JsonOutput);
        until ((Status = CompletedTxt) or (Status = FailedTxt));

        if Status = FailedTxt then begin
            Message := GetErrorMessage(JsonOutput);

            if Message <> '' then
                Error(Message);

            Error(GenericErrorMessage)
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateIntegrationRuntime(var InstanceId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDisableReplication(var InstanceId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEnableReplication(ProductId: Text; var NotificationUrl: Text; var SubscriptionId: Text[150]; var ClientState: Text[50]; var ServiceNotificationUrl: Text; var ServiceSubscriptionId: Text[150]; var ServiceClientState: Text[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnEnableReplication(OnPremiseConnectionString: Text; DatabaseType: Text; IntegrationRuntimeName: Text; NotificationUrl: Text; ClientState: Text; SubscriptionId: Text; ServiceNotificationUrl: Text; ServiceClientState: Text; ServiceSubscriptionId: Text; var InstanceId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetErrorMessage(ErrorCode: Text; var Message: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetIntegrationRuntimeKeys(var InstanceId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetReplicationRunStatus(var InstanceId: Text; RunId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetRequestStatus(InstanceId: Text; var JsonOutput: Text; var Status: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetVersionInformation(var InstanceId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitialize(SourceProductId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPrepareTablesForReplication()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegenerateIntegrationRuntimeKeys(var InstanceId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunReplication(var InstanceId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunUpgrade(var InstanceId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetReplicationSchedule(ReplicationFrequency: Text; DaysToRun: Text; TimeToRun: Time; Activate: Boolean; var InstanceId: Text)
    begin
    end;

    [TryFunction]
    local procedure TryCreateIntegrationRuntime(var InstanceId: Text)
    begin
        OnCreateIntegrationRuntime(InstanceId);
    end;

    [TryFunction]
    local procedure TryDisableReplication(var InstanceId: Text)
    begin
        OnDisableReplication(InstanceId);
    end;

    [TryFunction]
    local procedure TryEnableReplication(var InstanceId: Text; OnPremConnectionString: Text; DatabaseConfiguration: Text; IntegrationRuntimeName: Text; NotificationUrl: Text; ClientState: Text; SubscriptionId: Text; ServiceNotificationUrl: Text; ServiceClientState: Text; ServiceSubscriptionId: Text)
    begin
        OnEnableReplication(
          OnPremConnectionString, DatabaseConfiguration, IntegrationRuntimeName, NotificationUrl, ClientState, SubscriptionId,
          ServiceNotificationUrl, ServiceClientState, ServiceSubscriptionId, InstanceId);
        ValidateInstanceId(InstanceId);
    end;

    [TryFunction]
    local procedure TryGetIntegrationRuntimeKeys(var InstanceId: Text)
    begin
        OnGetIntegrationRuntimeKeys(InstanceId);
        ValidateInstanceId(InstanceId);
    end;

    [TryFunction]
    local procedure TryGetReplicationRunStatus(var InstanceId: Text; RunId: Text)
    begin
        OnGetReplicationRunStatus(InstanceId, RunId);
        ValidateInstanceId(InstanceId);
    end;

    [TryFunction]
    local procedure TryGetVersionInformation(var InstanceId: Text)
    begin
        OnGetVersionInformation(InstanceId);
        ValidateInstanceId(InstanceId);
    end;

    [TryFunction]
    local procedure TryPrepareTablesForReplication()
    begin
        OnPrepareTablesForReplication;
    end;

    [TryFunction]
    local procedure TryRegenerateIntegrationRuntimeKeys(var InstanceId: Text)
    begin
        OnRegenerateIntegrationRuntimeKeys(InstanceId);
        ValidateInstanceId(InstanceId);
    end;

    [TryFunction]
    local procedure TryRunReplication(var InstanceId: Text)
    begin
        OnRunReplication(InstanceId);
        ValidateInstanceId(InstanceId);
    end;

    [TryFunction]
    local procedure TryRunUpgrade(var InstanceId: Text)
    begin
        OnRunUpgrade(InstanceId);
        ValidateInstanceId(InstanceId);
    end;

    [TryFunction]
    local procedure TrySetReplicationSchedule(var InstanceId: Text; ReplicationFrequency: Text; DaysToRun: Text; TimeToRun: Time; Activate: Boolean)
    begin
        OnSetReplicationSchedule(ReplicationFrequency, DaysToRun, TimeToRun, Activate, InstanceId);
        ValidateInstanceId(InstanceId);
    end;

    [TryFunction]
    local procedure TryGetErrorCode(JsonOutput: Text; var ErrorCode: Text)
    var
        JSONManagement: Codeunit "JSON Management";
    begin
        JSONManagement.InitializeObject(JsonOutput);
        JSONManagement.GetStringPropertyValueByName('ErrorCode', ErrorCode);
    end;

    local procedure GetErrorMessage(JsonOutput: Text) Message: Text
    var
        ErrorCode: Text;
    begin
        if not TryGetErrorCode(JsonOutput, ErrorCode) or (ErrorCode = '') then
            exit;

        SendTraceTag('00006NE', 'IntelligentCloud', VERBOSITY::Warning,
          StrSubstNo('Error occurred in replication service: %1', ErrorCode), DATACLASSIFICATION::SystemMetadata);
        OnGetErrorMessage(ErrorCode, Message);

        if Message <> '' then
            exit;

        case ErrorCode of
            '52010':
                Message := InvalidProductErr;
            '52015':
                Message := InvalidRunIdErr;
            '52020':
                Message := InvalidTenantErr;
            '52030':
                Message := InvalidIntegrationRuntimeNameErr;
            '52040':
                Message := NoIntegrationRuntimeErr;
            '52050':
                Message := PrepareServersFailureErr;
            '52060':
                Message := ReplicationNotEnabledErr;
            '52071':
                Message := SelfHostedIRNotFoundErr;
            '52072':
                Message := ConnectionStringFailureErr;
            '52073':
                Message := SqlTimeoutErr;
            '52080':
                Message := TooManyReplicationRunsErr;
            '52090':
                Message := NoAdfCapacityErr;
        end;
    end;

    local procedure ValidateInstanceId(InstanceId: Text)
    begin
        if InstanceId = '' then begin
            SendTraceTag('00007HU', 'IntelligentCloud', VERBOSITY::Error, 'Received an empty response from the replication service.');
            Error(FailedToProcessRequestErr);
        end;
    end;
}

