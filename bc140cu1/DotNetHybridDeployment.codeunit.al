codeunit 3030 "DotNet_HybridDeployment"
{

    trigger OnRun()
    begin
    end;

    var
        DotNetALHybridDeployManagement: DotNet ALHybridDeployManagement;

    procedure Initialize()
    begin
        DotNetALHybridDeployManagement := DotNetALHybridDeployManagement.ALHybridDeployManagement;
    end;

    procedure GetALHybridDeployManagement(var DotNetALHybridDeployManagement2: DotNet ALHybridDeployManagement)
    begin
        DotNetALHybridDeployManagement2 := DotNetALHybridDeployManagement;
    end;

    procedure SetALHybridDeployManagement(DotNetALHybridDeployManagement2: DotNet ALHybridDeployManagement)
    begin
        DotNetALHybridDeployManagement := DotNetALHybridDeployManagement2;
    end;

    procedure CreateIntegrationRuntime(SourceProduct: Text) InstanceId: Text
    begin
        InstanceId := DotNetALHybridDeployManagement.CreateIntegrationRuntime(SourceProduct);
    end;

    procedure DisableReplication(SourceProduct: Text) InstanceId: Text
    begin
        InstanceId := DotNetALHybridDeployManagement.DisableReplication(SourceProduct);
    end;

    procedure EnableReplication(SourceProduct: Text; OnPremiseConnectionString: Text; DatabaseType: Text; IntegrationRuntimeName: Text; NotificationUrl: Text; ClientState: Text; SubscriptionId: Text; ServiceNotificationUrl: Text; ServiceClientState: Text; ServiceSubscriptionId: Text) InstanceId: Text
    begin
        InstanceId :=
          DotNetALHybridDeployManagement.EnableReplication(
            SourceProduct, OnPremiseConnectionString, DatabaseType, IntegrationRuntimeName, NotificationUrl, ClientState, SubscriptionId,
            ServiceNotificationUrl, ServiceClientState, ServiceSubscriptionId);
    end;

    procedure GetIntegrationRuntimeKey(SourceProduct: Text) InstanceId: Text
    begin
        InstanceId := DotNetALHybridDeployManagement.GetIntegrationRuntimeKey(SourceProduct);
    end;

    procedure GetReplicationRunStatus(SourceProduct: Text; RunId: Text) InstanceId: Text
    begin
        InstanceId := DotNetALHybridDeployManagement.GetReplicationRunStatus(SourceProduct, RunId);
    end;

    procedure GetRequestStatus(InstanceId: Text; var JsonOutput: Text) Status: Text
    var
        AlGetResponse: DotNet ALGetStatusResponse;
    begin
        AlGetResponse := DotNetALHybridDeployManagement.GetRequestStatus(InstanceId);
        JsonOutput := AlGetResponse.ResponseJson;
        Status := AlGetResponse.Status;
    end;

    procedure GetVersionInformation(SourceProduct: Text) InstanceId: Text
    begin
        InstanceId := DotNetALHybridDeployManagement.GetVersionInformation(SourceProduct);
    end;

    procedure PrepareTablesForReplication()
    begin
        DotNetALHybridDeployManagement.PrepareTablesForReplication;
    end;

    procedure RegenerateIntegrationRuntimeKey(SourceProduct: Text) InstanceId: Text
    begin
        InstanceId := DotNetALHybridDeployManagement.RegenerateIntegrationRuntimeKey(SourceProduct);
    end;

    procedure RunReplication(SourceProduct: Text) InstanceId: Text
    begin
        InstanceId := DotNetALHybridDeployManagement.RunReplication(SourceProduct);
    end;

    procedure RunUpgrade(SourceProduct: Text) InstanceId: Text
    begin
        InstanceId := DotNetALHybridDeployManagement.RunUpgrade(SourceProduct);
    end;

    procedure SetReplicationSchedule(SourceProduct: Text; ReplicationFrequency: Text; DaysToRun: Text; TimeToRun: Time; Activate: Boolean) InstanceId: Text
    begin
        InstanceId :=
          DotNetALHybridDeployManagement.SetReplicationSchedule(
            SourceProduct, ReplicationFrequency, DaysToRun, CreateDateTime(Today, TimeToRun), Activate);
    end;
}

