table 9004 Plan
{
    Caption = 'Subscription Plan';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Plan ID";Guid)
        {
            Caption = 'Plan ID';
        }
        field(2;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(3;"Role Center ID";Integer)
        {
            Caption = 'Role Center ID';
        }
    }

    keys
    {
        key(Key1;"Plan ID")
        {
        }
        key(Key2;Name)
        {
        }
    }

    fieldgroups
    {
    }

    var
        BasicPlanGUIDTxt: Label '{7e8e26a8-91a4-4590-961d-d12b61c16a43}', Locked=true;
        TeamMemberPlanGUIDTxt: Label '{d9a6391b-8970-4976-bd94-5f205007c8d8}', Locked=true;
        EssentialPlanGUIDTxt: Label '{920656a2-7dd8-4c83-97b6-a356414dbd36}', Locked=true;
        PremiumPlanGUIDTxt: Label '{8e9002c0-a1d8-4465-b952-817d2948e6e2}', Locked=true;
        InvoicingPlanGUIDTxt: Label '{39b5c996-467e-4e60-bd62-46066f572726}', Locked=true;
        ViralSignupPlanGUIDTxt: Label '{3F2AFEED-6FB5-4BF9-998F-F2912133AEAD}', Locked=true;
        ExternalAccountantPlanGUIDTxt: Label '{170991d7-b98e-41c5-83d4-db2052e1795f}', Locked=true;
        DelegatedAdminGUIDTxt: Label '{00000000-0000-0000-0000-000000000007}', Locked=true;
        InternalAdminGUIDTxt: Label '{62e90394-69f5-4237-9190-012177145e10}', Locked=true;
        TeamMemberISVPlanGUIDTxt: Label '{fd1441b8-116b-4fa7-836e-d7956700e0fa}', Locked=true;
        EssentialISVPlanGUIDTxt: Label '{8bb56cea-3f11-4647-854a-212e2b05306a}', Locked=true;
        PremiumISVPlanGUIDTxt: Label '{4c52d56d-5121-425a-91a5-dd0de136ca17}', Locked=true;

    [Scope('Personalization')]
    procedure GetBasicPlanId(): Guid
    begin
        exit(BasicPlanGUIDTxt);
    end;

    [Scope('Personalization')]
    procedure GetTeamMemberPlanId(): Guid
    begin
        exit(TeamMemberPlanGUIDTxt);
    end;

    [Scope('Personalization')]
    procedure GetEssentialPlanId(): Guid
    begin
        exit(EssentialPlanGUIDTxt);
    end;

    [Scope('Personalization')]
    procedure GetPremiumPlanId(): Guid
    begin
        exit(PremiumPlanGUIDTxt);
    end;

    [Scope('Personalization')]
    procedure GetInvoicingPlanId(): Guid
    begin
        exit(InvoicingPlanGUIDTxt);
    end;

    [Scope('Personalization')]
    procedure GetViralSignupPlanId(): Guid
    begin
        exit(ViralSignupPlanGUIDTxt);
    end;

    [Scope('Personalization')]
    procedure GetExternalAccountantPlanId(): Guid
    begin
        exit(ExternalAccountantPlanGUIDTxt);
    end;

    [Scope('Personalization')]
    procedure GetDelegatedAdminPlanId(): Guid
    begin
        exit(DelegatedAdminGUIDTxt);
    end;

    [Scope('Personalization')]
    procedure GetInternalAdminPlanId(): Guid
    begin
        exit(InternalAdminGUIDTxt);
    end;

    [Scope('Personalization')]
    procedure GetTeamMemberISVPlanId(): Guid
    begin
        exit(TeamMemberISVPlanGUIDTxt);
    end;

    [Scope('Personalization')]
    procedure GetEssentialISVPlanId(): Guid
    begin
        exit(EssentialISVPlanGUIDTxt);
    end;

    [Scope('Personalization')]
    procedure GetPremiumISVPlanId(): Guid
    begin
        exit(PremiumISVPlanGUIDTxt);
    end;
}

