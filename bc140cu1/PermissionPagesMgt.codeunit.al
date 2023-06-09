codeunit 9001 "Permission Pages Mgt."
{

    trigger OnRun()
    begin
    end;

    var
        NoOfRecords: Integer;
        NoOfColumns: Integer;
        OffSet: Integer;
        CannotManagePermissionsErr: Label 'Only users with the SUPER or the SECURITY permission set can create or edit permission sets.';
        MSPermSetChangedTxt: Label 'Original System permission set changed';
        MSPermSetChangedDescTxt: Label 'Show a notification if one or more original System permission sets that you have copied to create your own set changes.';
        MSPermSetChangedMsg: Label 'One or more System permission sets that you have copied to create your own have changed. //You may want to review the changed permission set in case the changes are relevant for your user-defined permission sets.';
        MSPermSetChangedShowDetailsTxt: Label 'Show more';
        MSPermSetChangedNeverShowAgainTxt: Label 'Don''t show again';
        CannotEditPermissionSetMsg: Label 'Permission sets of type System and Extension cannot be changed. Only permission sets of type User-Defined can be changed.';
        CannotEditPermissionSetDescTxt: Label 'Show a notification to inform users that permission sets of type System and Extension cannot be changed.';
        CannotEditPermissionSetTxt: Label 'Permission sets of type System and Extension cannot be changed.';

    [Scope('Personalization')]
    procedure Init(NewNoOfRecords: Integer; NewNoOfColumns: Integer)
    begin
        OffSet := 0;
        NoOfRecords := NewNoOfRecords;
        NoOfColumns := NewNoOfColumns;
    end;

    [Scope('Personalization')]
    procedure GetOffset(): Integer
    begin
        exit(OffSet);
    end;

    [Scope('Personalization')]
    procedure AllColumnsLeft()
    begin
        OffSet -= NoOfColumns;
        if OffSet < 0 then
            OffSet := 0;
    end;

    [Scope('Personalization')]
    procedure ColumnLeft()
    begin
        if OffSet > 0 then
            OffSet -= 1;
    end;

    [Scope('Personalization')]
    procedure ColumnRight()
    begin
        if OffSet < NoOfRecords - NoOfColumns then
            OffSet += 1;
    end;

    [Scope('Personalization')]
    procedure AllColumnsRight()
    begin
        OffSet += NoOfColumns;
        if OffSet > NoOfRecords - NoOfColumns then
            OffSet := NoOfRecords - NoOfColumns;
        if OffSet < 0 then
            OffSet := 0;
    end;

    [Scope('Personalization')]
    procedure IsInColumnsRange(i: Integer): Boolean
    begin
        exit((i > OffSet) and (i <= OffSet + NoOfColumns));
    end;

    [Scope('Personalization')]
    procedure IsPastColumnRange(i: Integer): Boolean
    begin
        exit(i >= OffSet + NoOfColumns);
    end;

    [Scope('Personalization')]
    procedure ShowPermissions(AggregatePermissionSetScope: Option; AppId: Guid; PermissionSetId: Code[20]; RunAsModal: Boolean)
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
        Permission: Record Permission;
        TenantPermission: Record "Tenant Permission";
        PermissionManager: Codeunit "Permission Manager";
        Permissions: Page Permissions;
        TenantPermissions: Page "Tenant Permissions";
    begin
        case AggregatePermissionSetScope of
            AggregatePermissionSet.Scope::System:
                begin
                    Permission.SetRange("Role ID", PermissionSetId);
                    Permissions.SetRecord(Permission);
                    Permissions.SetTableView(Permission);
                    Permissions.Editable := false;
                    if RunAsModal then
                        Permissions.RunModal
                    else
                        Permissions.Run;
                end;
            AggregatePermissionSet.Scope::Tenant:
                begin
                    TenantPermission.SetRange("App ID", AppId);
                    TenantPermission.SetRange("Role ID", PermissionSetId);
                    TenantPermissions.SetRecord(TenantPermission);
                    TenantPermissions.SetTableView(TenantPermission);

                    if IsPermissionsInGivenScopeAndAppIdEditable(AggregatePermissionSetScope, AppId) and
                       PermissionManager.CanManageUsersOnTenant(UserSecurityId)
                    then
                        TenantPermissions.SetControlsAsEditable
                    else
                        TenantPermissions.SetControlsAsReadOnly;

                    if RunAsModal then
                        TenantPermissions.RunModal
                    else
                        TenantPermissions.Run;
                end;
        end;
    end;

    [Scope('Personalization')]
    procedure IsPermissionSetEditable(AggregatePermissionSet: Record "Aggregate Permission Set"): Boolean
    begin
        exit(IsPermissionsInGivenScopeAndAppIdEditable(AggregatePermissionSet.Scope, AggregatePermissionSet."App ID"));
    end;

    local procedure IsPermissionsInGivenScopeAndAppIdEditable(AggregatePermissionSetScope: Option; AppId: Guid): Boolean
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
    begin
        exit((AggregatePermissionSetScope = AggregatePermissionSet.Scope::Tenant) and IsNullGuid(AppId));
    end;

    [Scope('Personalization')]
    procedure CheckAndRaiseNotificationIfAppDBPermissionSetsChanged()
    var
        PermissionSetLink: Record "Permission Set Link";
        PermissionManager: Codeunit "Permission Manager";
        Notification: Notification;
    begin
        if not PermissionManager.CanManageUsersOnTenant(UserSecurityId) then
            exit;

        if not AppDbPermissionChangedNotificationEnabled then
            exit;

        if not PermissionSetLink.SourceHashHasChanged then
            exit;

        Notification.Id(GetAppDbPermissionSetChangedNotificationId);
        Notification.Message(MSPermSetChangedMsg);
        Notification.Scope(NOTIFICATIONSCOPE::LocalScope);
        Notification.AddAction(MSPermSetChangedShowDetailsTxt, CODEUNIT::"Permission Pages Mgt.",
          'AppDbPermissionSetChangedShowDetails');
        Notification.AddAction(MSPermSetChangedNeverShowAgainTxt, CODEUNIT::"Permission Pages Mgt.",
          'AppDbPermissionSetChangedDisableNotification');
        Notification.Send;
    end;

    [Scope('Personalization')]
    procedure IsTenantPermissionSetEditable(TenantPermissionSet: Record "Tenant Permission Set"): Boolean
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
    begin
        if AggregatePermissionSet.Get(AggregatePermissionSet.Scope::Tenant, TenantPermissionSet."App ID", TenantPermissionSet."Role ID")
        then
            exit(IsPermissionSetEditable(AggregatePermissionSet));
    end;

    [Scope('Personalization')]
    procedure ShowSecurityFilterForPermission(var OutputSecurityFilter: Text; Permission: Record Permission): Boolean
    begin
        Permission.CalcFields("Object Name");

        exit(ShowSecurityFilters(OutputSecurityFilter,
            Permission."Object ID", Permission."Object Name", Format(Permission."Security Filter"),
            false));
    end;

    [Scope('Personalization')]
    procedure ShowSecurityFilterForTenantPermission(var OutputSecurityFilter: Text; TenantPermission: Record "Tenant Permission"; UserCanEditSecurityFilters: Boolean): Boolean
    begin
        TenantPermission.CalcFields("Object Name");

        exit(ShowSecurityFilters(OutputSecurityFilter,
            TenantPermission."Object ID", TenantPermission."Object Name", Format(TenantPermission."Security Filter"),
            UserCanEditSecurityFilters));
    end;

    local procedure ShowSecurityFilters(var OutputSecurityFilter: Text; InputObjectID: Integer; InputObjectName: Text; InputSecurityFilter: Text; UserCanEditSecurityFilters: Boolean): Boolean
    var
        TableFilter: Record "Table Filter";
        TableFilterPage: Page "Table Filter";
    begin
        TableFilter.FilterGroup(2);
        TableFilter.SetRange("Table Number", InputObjectID);
        TableFilter.FilterGroup(0);

        TableFilterPage.SetTableView(TableFilter);
        TableFilterPage.SetSourceTable(InputSecurityFilter, InputObjectID, InputObjectName);
        TableFilterPage.Editable := UserCanEditSecurityFilters;

        if ACTION::OK = TableFilterPage.RunModal then begin
            OutputSecurityFilter := TableFilterPage.CreateTextTableFilter(false);
            exit(true);
        end;
    end;

    [Scope('Personalization')]
    procedure AppDbPermissionSetChangedShowDetails(Notification: Notification)
    var
        PermissionSetLink: Record "Permission Set Link";
    begin
        PermissionSetLink.MarkWithChangedSource;
        PAGE.RunModal(PAGE::"Changed Permission Set List", PermissionSetLink);
        PermissionSetLink.UpdateSourceHashesOnAllLinks;
    end;

    [Scope('Personalization')]
    procedure AppDbPermissionSetChangedDisableNotification(Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.Disable(GetAppDbPermissionSetChangedNotificationId);
    end;

    [EventSubscriber(ObjectType::Page, 1518, 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(GetAppDbPermissionSetChangedNotificationId,
          MSPermSetChangedTxt,
          MSPermSetChangedDescTxt,
          true);

        MyNotifications.InsertDefault(GetCannotEditPermissionSetsNotificationId,
          CannotEditPermissionSetTxt,
          CannotEditPermissionSetDescTxt,
          true);
    end;

    local procedure GetAppDbPermissionSetChangedNotificationId(): Guid
    begin
        exit('2712AD06-C48B-4C20-830E-347A60C9AE00');
    end;

    [Scope('Personalization')]
    procedure AppDbPermissionChangedNotificationEnabled(): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        exit(MyNotifications.IsEnabled(GetAppDbPermissionSetChangedNotificationId));
    end;

    [Scope('Personalization')]
    procedure DisallowEditingPermissionSetsForNonAdminUsers()
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        if not PermissionManager.CanManageUsersOnTenant(UserSecurityId) then
            Error(CannotManagePermissionsErr);
    end;

    [Scope('Personalization')]
    procedure RaiseNotificationThatSecurityFilterNotEditableForSystemAndExtension()
    var
        Notification: Notification;
    begin
        if not CannotEditPermissionSetsNotificationEnabled then
            exit;

        Notification.Id(GetCannotEditPermissionSetsNotificationId);
        Notification.Message(CannotEditPermissionSetMsg);
        Notification.Scope(NOTIFICATIONSCOPE::LocalScope);
        Notification.AddAction(MSPermSetChangedNeverShowAgainTxt, CODEUNIT::"Permission Pages Mgt.",
          'CannotEditPermissionSetsDisableNotification');
        Notification.Send;
    end;

    [Scope('Personalization')]
    procedure CannotEditPermissionSetsNotificationEnabled(): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        exit(MyNotifications.IsEnabled(GetCannotEditPermissionSetsNotificationId));
    end;

    local procedure GetCannotEditPermissionSetsNotificationId(): Guid
    begin
        exit('687c66c9-404d-4480-9209-f46f0e34404e');
    end;

    [Scope('Personalization')]
    procedure CannotEditPermissionSetsDisableNotification(Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.Disable(GetCannotEditPermissionSetsNotificationId);
    end;
}

