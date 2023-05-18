codeunit 6723 "Server Config. Setting Handler"
{

    trigger OnRun()
    begin
    end;

    var
        ALConfigSettings: DotNet ALConfigSettings;

    local procedure InitializeConfigSettings()
    begin
        ALConfigSettings := ALConfigSettings.Instance;
    end;

    [Scope('Personalization')]
    procedure GetEnableSaaSExtensionInstallSetting(): Boolean
    var
        EnableSaaSExtensionInstall: Boolean;
    begin
        InitializeConfigSettings;
        EnableSaaSExtensionInstall := ALConfigSettings.EnableSaasExtensionInstallConfigSetting;
        exit(EnableSaaSExtensionInstall);
    end;

    [Scope('Personalization')]
    procedure GetIsSaasExcelAddinEnabled(): Boolean
    var
        SaasExcelAddinEnabled: Boolean;
    begin
        InitializeConfigSettings;
        SaasExcelAddinEnabled := ALConfigSettings.IsSaasExcelAddinEnabled;
        exit(SaasExcelAddinEnabled);
    end;

    [Scope('Personalization')]
    procedure GetApiServicesEnabled() ApiEnabled: Boolean
    begin
        InitializeConfigSettings;
        ApiEnabled := ALConfigSettings.ApiServicesEnabled;
        exit(ApiEnabled);
    end;

    [Scope('Personalization')]
    procedure GetApiSubscriptionsEnabled(): Boolean
    var
        ApiSubscriptionsEnabled: Boolean;
    begin
        InitializeConfigSettings;
        ApiSubscriptionsEnabled := ALConfigSettings.ApiSubscriptionsEnabled;
        exit(ApiSubscriptionsEnabled);
    end;

    [Scope('Personalization')]
    procedure GetApiSubscriptionSendingNotificationTimeout(): Integer
    var
        Timeout: Integer;
    begin
        InitializeConfigSettings;
        Timeout := ALConfigSettings.ApiSubscriptionSendingNotificationTimeout;
        exit(Timeout);
    end;

    [Scope('Personalization')]
    procedure GetApiSubscriptionMaxNumberOfNotifications(): Integer
    var
        MaxNoOfNotifications: Integer;
    begin
        InitializeConfigSettings;
        MaxNoOfNotifications := ALConfigSettings.ApiSubscriptionMaxNumberOfNotifications;
        exit(MaxNoOfNotifications);
    end;

    [Scope('Personalization')]
    procedure GetApiSubscriptionDelayTime(): Integer
    var
        DelayTime: Integer;
    begin
        InitializeConfigSettings;
        DelayTime := ALConfigSettings.ApiSubscriptionDelayTime;
        exit(DelayTime);
    end;
}

