codeunit 4030 "Client Type Management"
{

    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure GetCurrentClientType() CurrClientType: ClientType
    begin
        // Use the GetCurrentClientType wrapper method when you want to test a flow on a different type of client.
        // Example:
        // IF ClientTypeManagement.GetCurrentClientType IN [CLIENTTYPE::xxx, CLIENTTYPE::yyy] THEN
        CurrClientType := CurrentClientType;
        OnAfterGetCurrentClientType(CurrClientType);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetCurrentClientType(var CurrClientType: ClientType)
    begin
        // Subscribe to this event from tests if you need to verify a different flow.
        // Do not use this event in a production environment.
        // This feature is for testing and is subject to a different SLA than production features.
    end;
}

