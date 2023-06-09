table 1802 "Assisted Company Setup Status"
{
    Caption = 'Assisted Company Setup Status';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Company Name";Text[30])
        {
            Caption = 'Company Name';
            TableRelation = Company;
        }
        field(2;Enabled;Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            begin
                OnEnabled("Company Name",Enabled);
            end;
        }
        field(3;"Package Imported";Boolean)
        {
            Caption = 'Package Imported';
        }
        field(4;"Import Failed";Boolean)
        {
            Caption = 'Import Failed';
        }
        field(5;"Company Setup Session ID";Integer)
        {
            Caption = 'Company Setup Session ID';
        }
        field(6;"Task ID";Guid)
        {
            Caption = 'Task ID';
        }
        field(7;"Server Instance ID";Integer)
        {
            Caption = 'Server Instance ID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Company Name")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure GetCompanySetupStatus(Name: Text[30]) SetupStatus: Integer
    begin
        if "Company Name" <> Name then
          if not Get(Name) then
            exit(0);
        OnGetCompanySetupStatus("Company Name",SetupStatus);
    end;

    [Scope('Personalization')]
    procedure DrillDownSetupStatus(Name: Text[30])
    begin
        if Get(Name) then
          OnSetupStatusDrillDown("Company Name");
    end;

    [Scope('Personalization')]
    procedure SetEnabled(CompanyName: Text[30];Enable: Boolean;ResetState: Boolean)
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
    begin
        if not AssistedCompanySetupStatus.Get(CompanyName) then begin
          AssistedCompanySetupStatus.Init;
          AssistedCompanySetupStatus.Validate("Company Name",CompanyName);
          AssistedCompanySetupStatus.Validate(Enabled,Enable);
          AssistedCompanySetupStatus.Insert;
        end else begin
          AssistedCompanySetupStatus.Validate(Enabled,Enable);
          if ResetState then begin
            AssistedCompanySetupStatus."Package Imported" := false;
            AssistedCompanySetupStatus."Import Failed" := false;
          end;
          AssistedCompanySetupStatus.Modify;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnEnabled(SetupCompanyName: Text[30];AssistedSetupEnabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetCompanySetupStatus(Name: Text[30];var SetupStatus: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupStatusDrillDown(Name: Text[30])
    begin
    end;

    [Scope('Personalization')]
    procedure CopySaaSCompanySetupStatus(CompanyNameFrom: Text[30];CompanyNameTo: Text[30])
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        PermissionManager: Codeunit "Permission Manager";
        RefSetupStatus: Option " ",Completed,"In Progress",Error,"Missing Permission";
    begin
        if not PermissionManager.SoftwareAsAService then
          exit;

        if AssistedCompanySetupStatus.GetCompanySetupStatus(CompanyNameFrom) = RefSetupStatus::Completed then begin
          AssistedCompanySetupStatus.Init;
          AssistedCompanySetupStatus."Company Name" := CompanyNameTo;
          if AssistedCompanySetupStatus.Insert then;
        end;
    end;
}

