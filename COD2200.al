codeunit 2200 "Azure Key Vault Management"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        NavAzureKeyVaultClient: DotNet AzureKeyVaultClientHelper;
        AzureKeyVaultSecretProvider: DotNet IAzureKeyVaultSecretProvider;
        ApplicationSecretsTxt: Label 'ml-forecast,qbo-consumerkey,qbo-consumersecret,amcname,amcpassword,YodleeCobrandName,YodleeCobrandPassword,YodleeServiceUri,YodleeFastlinkUrl,ExchangeAuthMethod,NpsApiUrl,NpsCacheLifeTime,NpsTimeBetweenRequests,webhooksadapteruri,webhooksadapterclientid,webhooksadapterclientsecret,webhooksadapterresourceuri,webhooksadapterauthority,c2graphclientid,c2graphsecret,c2graphresource,c2graphauthority,xeroimportapp-key,xeroimportapp-secret,xero-allowed,qbo-businesscenter-consumerkey,qbo-businesscenter-consumersecret,walletpaymentrequesturl,qbo-datamigration-consumerkey,qbo-datamigration-consumersecret,govtalk-vendorid,MSWalletAADAppID,MSWalletAADAppKey,MSWalletAADIdentityService,MSWalletSignUpUrl,MSWalletMerchantAPI,MSWalletMerchantAPIResource,MailerResourceId,machinelearning,background-ml-enabled,extmgmt-marketplace-disable,opaycardoriginatorfornav,opaycardprivatekey,opaycardmerchantid,opaycarddisplayid,SmtpSetup,BusinessCentralTrialVisibleForInv', Locked=true;
        ApplicationSecrets2Txt: Label 'UKHMRC-MTDVAT-PROD-ClientID,UKHMRC-MTDVAT-PROD-ClientSecret,UKHMRC-MTDVAT-Sandbox-ClientID,UKHMRC-MTDVAT-Sandbox-ClientSecret', Locked=true;
        SecretNotFoundErr: Label '%1 is not an application secret.', Comment='%1 = Secret Name.';
        CachedSecretsDictionary: DotNet Dictionary_Of_T_U;
        AllowedSecretNames: Text;
        SecretNameCannotContainCommaErr: Label 'The secret name cannot contain comma.';

    [TryFunction]
    [Scope('Internal')]
    procedure GetAzureKeyVaultSecret(var Secret: Text;SecretName: Text)
    begin
        // Gets the secret as a Text from the key vault, given a SecretName.

        InitializeAllowedSecretNames;
        if not IsSecretNameAllowed(SecretName) then
          if not (StrPos(SecretName,'isv-') = 1) then
            Error(SecretNotFoundErr,SecretName);

        if KeyValuePairInBuffer(SecretName,Secret) then
          exit;

        NavAzureKeyVaultClient := NavAzureKeyVaultClient.AzureKeyVaultClientHelper;
        NavAzureKeyVaultClient.SetAzureKeyVaultProvider(AzureKeyVaultSecretProvider);
        Secret := NavAzureKeyVaultClient.GetAzureKeyVaultSecret(SecretName);

        StoreKeyValuePairInBuffer(SecretName,Secret);
    end;

    [Scope('Internal')]
    procedure SetAzureKeyVaultSecretProvider(NewAzureKeyVaultSecretProvider: DotNet IAzureKeyVaultSecretProvider)
    begin
        // Sets the secret provider to simulate the vault. Used for testing.

        ClearBufferAndDotNetKeyvaultObjects;
        AzureKeyVaultSecretProvider := NewAzureKeyVaultSecretProvider;
    end;

    [Scope('Internal')]
    procedure IsEnabled(): Boolean
    begin
        // Checks that the key vault is enabled and can retrieve keys

        NavAzureKeyVaultClient := NavAzureKeyVaultClient.AzureKeyVaultClientHelper;
        exit(NavAzureKeyVaultClient.Enable);
    end;

    local procedure KeyValuePairInBuffer("Key": Text;var Value: Text): Boolean
    var
        ValueFound: Boolean;
        ValueToReturn: Text;
    begin
        InitBuffer;

        ValueFound := CachedSecretsDictionary.TryGetValue(Key,ValueToReturn);
        Value := ValueToReturn;
        exit(ValueFound);
    end;

    local procedure StoreKeyValuePairInBuffer("Key": Text;Value: Text)
    begin
        InitBuffer;

        CachedSecretsDictionary.Add(Key,Value);
    end;

    local procedure ClearBufferAndDotNetKeyvaultObjects()
    begin
        Clear(NavAzureKeyVaultClient);
        Clear(AzureKeyVaultSecretProvider);

        InitBuffer;

        CachedSecretsDictionary.Clear;
    end;

    local procedure InitBuffer()
    begin
        if IsNull(CachedSecretsDictionary) then
          CachedSecretsDictionary := CachedSecretsDictionary.Dictionary;
    end;

    [Scope('Internal')]
    procedure AddAllowedSecretName(SecretName: Text)
    begin
        // Allows a secret name to be retrieved. Unless the secret being sought is added to the list,
        // it will not be fetched from the key vault

        InitializeAllowedSecretNames;
        if StrPos(SecretName,',') > 0 then
          Error(SecretNameCannotContainCommaErr);
        if not IsSecretNameAllowed(SecretName) then
          AllowedSecretNames := StrSubstNo('%1%2,',AllowedSecretNames,UpperCase(SecretName));
    end;

    local procedure IsSecretNameAllowed(SecretName: Text): Boolean
    begin
        exit(StrPos(AllowedSecretNames,StrSubstNo(',%1,',UpperCase(SecretName))) <> 0);
    end;

    local procedure InitializeAllowedSecretNames()
    begin
        // the first character should be a comma otherwise the check IsSecretNameAllowed
        // for the first secret shall return false
        if StrLen(AllowedSecretNames) = 0 then
          AllowedSecretNames := StrSubstNo(',%1,%2,',UpperCase(ApplicationSecretsTxt),UpperCase(ApplicationSecrets2Txt));
    end;
}

