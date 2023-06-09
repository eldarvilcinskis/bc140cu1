codeunit 9003 "Team Member Action Manager"
{

    trigger OnRun()
    begin
    end;

    var
        TeamMemberErr: Label 'You are logged in as a Team Member role, so you cannot complete this task.';

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeSalesHeaderInsert(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    begin
        CheckTeamMemberPermissionOnSalesHeaderTable(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforeSalesDocPost(var Sender: Codeunit "Sales-Post"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
        // Team member is not allowed to invoice a sales document.
        if IsCurrentUserAssignedTeamMemberPlan and SalesHeader.Invoice then
            Error(TeamMemberErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure OnBeforePurchaseDocPost(var Sender: Codeunit "Purch.-Post"; var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; CommitIsSupressed: Boolean)
    begin
        // Team member is not allowed to invoice a purchase document.
        if IsCurrentUserAssignedTeamMemberPlan and PurchaseHeader.Invoice then
            Error(TeamMemberErr);
    end;

    local procedure CheckTeamMemberPermissionOnSalesHeaderTable(var SalesHeader: Record "Sales Header")
    begin
        if IsCurrentUserAssignedTeamMemberPlan and (SalesHeader."Document Type" <> SalesHeader."Document Type"::Quote) then
            Error(TeamMemberErr);
    end;

    [EventSubscriber(ObjectType::Table, 38, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforePurchaseHeaderInsert(var Rec: Record "Purchase Header"; RunTrigger: Boolean)
    begin
        CheckTeamMemberPermissionOnPurchaseHeaderTable(Rec);
    end;

    local procedure CheckTeamMemberPermissionOnPurchaseHeaderTable(var PurchaseHeader: Record "Purchase Header")
    begin
        if IsCurrentUserAssignedTeamMemberPlan and (PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Quote) then
            Error(TeamMemberErr);
    end;

    local procedure IsCurrentUserAssignedTeamMemberPlan(): Boolean
    var
        UserPlan: Record "User Plan";
        Plan: Record Plan;
    begin
        UserPlan.SetRange("User Security ID", UserSecurityId);
        UserPlan.SetFilter("Plan ID", '%1|%2', Plan.GetTeamMemberPlanId, Plan.GetTeamMemberISVPlanId);
        exit(not UserPlan.IsEmpty);
    end;
}

