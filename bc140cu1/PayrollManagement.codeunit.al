codeunit 1660 "Payroll Management"
{
    Permissions = TableData User = rimd;

    trigger OnRun()
    begin
    end;

    var
        PayrollServiceNotFoundErr: Label 'A payroll service could not be found.';
        PayrollServiceDisabledErr: Label 'Payroll service %1 is disabled.', Comment = '%1 Payroll Service Name';
        SelectPayrollServiceToUseTxt: Label 'Several payroll services are installed and enabled. Select a service you want to use.';
        SelectPayrollServiceToEnableTxt: Label 'Select a payroll service you want to enable and use.';
        EnablePayrollServicesQst: Label 'All payroll services are disabled. Do you want to enable a payroll service?';

    [Scope('Personalization')]
    procedure ShowPayrollForTestInNonSaas(): Boolean
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        if PermissionManager.SoftwareAsAService then
            exit(true);
        exit(false);
    end;

    [Scope('Personalization')]
    procedure ImportPayroll(var GenJournalLine: Record "Gen. Journal Line")
    var
        TempServiceConnection: Record "Service Connection" temporary;
    begin
        TempServiceConnection.DeleteAll;
        OnRegisterPayrollService(TempServiceConnection);

        if TempServiceConnection.IsEmpty then
            Error(PayrollServiceNotFoundErr);

        if not EnabledPayrollServiceExists(TempServiceConnection) then begin
            if Confirm(EnablePayrollServicesQst) then
                EnablePayrollService(TempServiceConnection)
            else
                exit;
        end;

        if EnabledPayrollServiceExists(TempServiceConnection) then
            if SelectPayrollService(TempServiceConnection, SelectPayrollServiceToUseTxt) then
                OnImportPayroll(TempServiceConnection, GenJournalLine);
    end;

    local procedure EnabledPayrollServiceExists(var TempServiceConnection: Record "Service Connection" temporary): Boolean
    begin
        TempServiceConnection.SetFilter(
          Status, StrSubstNo('%1|%2', TempServiceConnection.Status::Enabled, TempServiceConnection.Status::Connected));
        exit(TempServiceConnection.FindSet);
    end;

    local procedure EnablePayrollService(var TempServiceConnection: Record "Service Connection" temporary)
    var
        SelectedServiceRecordId: RecordID;
        SelectedServiceName: Text;
    begin
        TempServiceConnection.Reset;
        if SelectPayrollService(TempServiceConnection, SelectPayrollServiceToEnableTxt) then begin
            SelectedServiceRecordId := TempServiceConnection."Record ID";
            SelectedServiceName := TempServiceConnection.Name;
            SetupPayrollService(TempServiceConnection);
            TempServiceConnection.DeleteAll;
            OnRegisterPayrollService(TempServiceConnection);
            if not TempServiceConnection.IsEmpty then begin
                TempServiceConnection.SetRange("Record ID", SelectedServiceRecordId);
                if not EnabledPayrollServiceExists(TempServiceConnection) then
                    Error(PayrollServiceDisabledErr, SelectedServiceName);
            end else
                Error(PayrollServiceNotFoundErr);
        end;
    end;

    local procedure SelectPayrollService(var TempServiceConnection: Record "Service Connection" temporary; Instruction: Text): Boolean
    var
        ServiceList: Text;
        SelectedServiceIndex: Integer;
    begin
        if TempServiceConnection.Count < 2 then
            exit(TempServiceConnection.FindFirst);

        TempServiceConnection.SetCurrentKey(Name);
        TempServiceConnection.SetAscending(Name, true);
        TempServiceConnection.FindFirst;
        repeat
            if ServiceList = '' then
                ServiceList := ConvertStr(TempServiceConnection.Name, ',', ' ')
            else
                ServiceList := ServiceList + ',' + ConvertStr(TempServiceConnection.Name, ',', ' ');
        until TempServiceConnection.Next = 0;
        SelectedServiceIndex := StrMenu(ServiceList, 1, Instruction);

        if SelectedServiceIndex > 0 then begin
            TempServiceConnection.FindFirst;
            if SelectedServiceIndex > 1 then
                TempServiceConnection.Next(SelectedServiceIndex - 1);
        end;
        exit(SelectedServiceIndex > 0);
    end;

    local procedure SetupPayrollService(var TempServiceConnection: Record "Service Connection" temporary)
    var
        AssistedSetup: Record "Assisted Setup";
        RecordRef: RecordRef;
        RecordRefVariant: Variant;
    begin
        RecordRef.Get(TempServiceConnection."Record ID");
        if (TempServiceConnection.Status <> TempServiceConnection.Status::Enabled) and
           (TempServiceConnection.Status <> TempServiceConnection.Status::Connected) and
           (TempServiceConnection."Assisted Setup Page ID" <> 0) and
           AssistedSetup.Get(TempServiceConnection."Assisted Setup Page ID") and
           (AssistedSetup.Status = AssistedSetup.Status::"Not Completed") and
           AssistedSetup.Visible
        then
            AssistedSetup.Run
        else begin
            RecordRefVariant := RecordRef;
            PAGE.RunModal(TempServiceConnection."Page ID", RecordRefVariant);
        end;
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnRegisterPayrollService(var TempServiceConnection: Record "Service Connection" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnImportPayroll(var TempServiceConnection: Record "Service Connection" temporary; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
}

