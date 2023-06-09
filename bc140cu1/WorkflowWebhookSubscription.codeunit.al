codeunit 1544 "Workflow Webhook Subscription"
{

    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure Approve(WorkflowStepInstanceId: Guid)
    var
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
    begin
        WorkflowWebhookManagement.ContinueByStepInstanceId(WorkflowStepInstanceId);
    end;

    [Scope('Personalization')]
    procedure Reject(WorkflowStepInstanceId: Guid)
    var
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
    begin
        WorkflowWebhookManagement.RejectByStepInstanceId(WorkflowStepInstanceId);
    end;
}

