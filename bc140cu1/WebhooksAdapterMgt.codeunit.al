codeunit 2201 "Webhooks Adapter Mgt."
{
    Permissions = TableData "Webhook Subscription" = rimd;

    trigger OnRun()
    begin
    end;

    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
        AzureADAuthFlow: Codeunit "Azure AD Auth Flow";
        WebhooksAdapterUriTxt: Label 'webhooksadapteruri', Comment = '{locked}';
        KeyvaultAccessFailedErr: Label 'Can''t share data right now. The problem is on our end. Please try again later.';
        WebhooksAdapterClientIdTxt: Label 'webhooksadapterclientid', Comment = '{locked}';
        WebhooksAdapterClientSecretTxt: Label 'webhooksadapterclientsecret', Comment = '{locked}';
        WebhooksAdapterResourceUriTxt: Label 'webhooksadapterresourceuri', Comment = '{locked}';
        WebhooksAdapterAuthorityTxt: Label 'webhooksadapterauthority', Comment = '{locked}';

    [Scope('Internal')]
    procedure GetAccessToken(ThrowErrors: Boolean) Token: Text
    var
        AzureADMgt: Codeunit "Azure AD Mgt.";
        WebhooksAdapterClientId: Text;
        WebhooksAdapterClientSecret: Text;
        WebhooksAdapterResourceUri: Text;
        WebhooksAdapterAuthority: Text;
    begin
        if not AzureKeyVaultManagement.GetAzureKeyVaultSecret(WebhooksAdapterClientId, WebhooksAdapterClientIdTxt) or
           not AzureKeyVaultManagement.GetAzureKeyVaultSecret(WebhooksAdapterClientSecret, WebhooksAdapterClientSecretTxt) or
           not AzureKeyVaultManagement.GetAzureKeyVaultSecret(WebhooksAdapterResourceUri, WebhooksAdapterResourceUriTxt) or
           not AzureKeyVaultManagement.GetAzureKeyVaultSecret(WebhooksAdapterAuthority, WebhooksAdapterAuthorityTxt) or
           (WebhooksAdapterClientId = '') or
           (WebhooksAdapterClientSecret = '') or
           (WebhooksAdapterResourceUri = '') or
           (WebhooksAdapterAuthority = '')
        then begin
            if ThrowErrors then
                Error(KeyvaultAccessFailedErr);
            Token := '';
            exit;
        end;

        AzureADAuthFlow.Initialize(AzureADMgt.GetRedirectUrl);
        Token :=
          AzureADAuthFlow.AcquireApplicationToken(
            WebhooksAdapterClientId, WebhooksAdapterClientSecret, WebhooksAdapterAuthority, WebhooksAdapterResourceUri);
    end;

    [Scope('Internal')]
    procedure GetWebhooksAdapterUri(ThrowError: Boolean): Text
    var
        WebhooksAdapterUri: Text;
    begin
        if not AzureKeyVaultManagement.GetAzureKeyVaultSecret(WebhooksAdapterUri, WebhooksAdapterUriTxt) then
            if ThrowError then
                Error(KeyvaultAccessFailedErr);
        exit(WebhooksAdapterUri);
    end;

    [Scope('Personalization')]
    procedure FindWebhookSubscription(var WebhookSubscription: Record "Webhook Subscription"; SubscriptionUri: Text[250]): Boolean
    var
        WebhookManagement: Codeunit "Webhook Management";
        EndpointUri: DotNet Uri;
    begin
        EndpointUri := EndpointUri.Uri(SubscriptionUri);
        exit(WebhookManagement.FindWebhookSubscriptionMatchingEndPoint(WebhookSubscription, EndpointUri, 0, 0));
    end;

    [Scope('Personalization')]
    procedure DeleteWebhookSubscription(SubscriptionUri: Text[250])
    var
        WebhookSubscription: Record "Webhook Subscription";
    begin
        if FindWebhookSubscription(WebhookSubscription, SubscriptionUri) then
            WebhookSubscription.Delete(true);
    end;

    [Scope('Personalization')]
    procedure SetAzureKeyVaultManagement(NewAzureKeyVaultManagement: Codeunit "Azure Key Vault Management")
    begin
        AzureKeyVaultManagement := NewAzureKeyVaultManagement;
    end;
}

