table 1275 "Doc. Exch. Service Setup"
{
    Caption = 'Doc. Exch. Service Setup';
    Permissions = TableData "Service Password"=rimd;

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(4;"Sign-up URL";Text[250])
        {
            Caption = 'Sign-up URL';
            ExtendedDatatype = URL;
        }
        field(5;"Service URL";Text[250])
        {
            Caption = 'Service URL';
            ExtendedDatatype = URL;

            trigger OnValidate()
            var
                WebRequestHelper: Codeunit "Web Request Helper";
            begin
                if "Service URL" <> '' then
                  WebRequestHelper.IsSecureHttpUrl("Service URL");
            end;
        }
        field(6;"Sign-in URL";Text[250])
        {
            Caption = 'Sign-in URL';
            ExtendedDatatype = URL;
        }
        field(7;"Consumer Key";Guid)
        {
            Caption = 'Consumer Key';
            TableRelation = "Service Password".Key;
        }
        field(8;"Consumer Secret";Guid)
        {
            Caption = 'Consumer Secret';
            Editable = false;
        }
        field(9;Token;Guid)
        {
            Caption = 'Token';
            Editable = false;
        }
        field(10;"Token Secret";Guid)
        {
            Caption = 'Token Secret';
            Editable = false;
        }
        field(11;"Doc. Exch. Tenant ID";Guid)
        {
            Caption = 'Doc. Exch. Tenant ID';
            DataClassification = OrganizationIdentifiableInformation;
            Editable = false;
        }
        field(12;"User Agent";Text[30])
        {
            Caption = 'User Agent';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
        }
        field(20;Enabled;Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            begin
                if Enabled then begin
                  CheckConnection;
                  ScheduleJobQueueEntries;
                  LogTelemetryWhenServiceEnabled;
                  if Confirm(JobQEntriesCreatedQst) then
                    ShowJobQueueEntry;
                end else begin
                  CancelJobQueueEntries;
                  LogTelemetryWhenServiceDisabled;
                end;
            end;
        }
        field(21;"Log Web Requests";Boolean)
        {
            Caption = 'Log Web Requests';
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DeletePassword("Consumer Secret");
        DeletePassword("Consumer Key");
        DeletePassword(Token);
        DeletePassword("Token Secret");
        DeletePassword("Doc. Exch. Tenant ID");
    end;

    trigger OnInsert()
    begin
        TestField("Primary Key",'');
        LogTelemetryWhenServiceCreated;
    end;

    var
        JobQEntriesCreatedQst: Label 'A job queue entry for exchanging documents has been created.\\Do you want to open the Job Queue Entries window?';
        DocExchServiceMgt: Codeunit "Doc. Exch. Service Mgt.";
        DocExchServiceCreatedTxt: Label 'The user started setting up document exchange service.', Locked=true;
        DocExchServiceEnabledTxt: Label 'The user enabled document exchange service.', Locked=true;
        DocExchServiceDisabledTxt: Label 'The user disabled document exchange service.', Locked=true;
        TelemetryCategoryTok: Label 'AL Document Exchange Service', Locked=true;

    [Scope('Personalization')]
    procedure SavePassword(var PasswordKey: Guid;PasswordText: Text)
    var
        ServicePassword: Record "Service Password";
    begin
        PasswordText := DelChr(PasswordText,'=',' ');

        if IsNullGuid(PasswordKey) or not ServicePassword.Get(PasswordKey) then begin
          ServicePassword.SavePassword(PasswordText);
          ServicePassword.Insert(true);
          PasswordKey := ServicePassword.Key;
          Modify;
        end else begin
          ServicePassword.SavePassword(PasswordText);
          ServicePassword.Modify;
        end;
        Commit;
    end;

    [Scope('Personalization')]
    procedure GetPassword(PasswordKey: Guid): Text
    var
        ServicePassword: Record "Service Password";
    begin
        ServicePassword.Get(PasswordKey);
        exit(ServicePassword.GetPassword);
    end;

    local procedure DeletePassword(PasswordKey: Guid)
    var
        ServicePassword: Record "Service Password";
    begin
        if ServicePassword.Get(PasswordKey) then
          ServicePassword.Delete;
    end;

    [Scope('Personalization')]
    procedure HasPassword(PasswordKey: Guid): Boolean
    var
        ServicePassword: Record "Service Password";
    begin
        if not ServicePassword.Get(PasswordKey) then
          exit(false);

        exit(ServicePassword.GetPassword <> '');
    end;

    [Scope('Personalization')]
    procedure SetURLsToDefault()
    begin
        DocExchServiceMgt.SetURLsToDefault(Rec);
    end;

    [Scope('Internal')]
    procedure CheckConnection()
    begin
        DocExchServiceMgt.CheckConnection;
    end;

    local procedure ScheduleJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
        DummyRecId: RecordID;
    begin
        JobQueueEntry.ScheduleRecurrentJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit,
          CODEUNIT::"Doc. Exch. Serv.- Doc. Status",DummyRecId);
        JobQueueEntry.ScheduleRecurrentJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit,
          CODEUNIT::"Doc. Exch. Serv. - Recv. Docs.",DummyRecId);
    end;

    local procedure CancelJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        CancelJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit,
          CODEUNIT::"Doc. Exch. Serv.- Doc. Status");
        CancelJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit,
          CODEUNIT::"Doc. Exch. Serv. - Recv. Docs.");
    end;

    local procedure CancelJobQueueEntry(ObjType: Option;ObjID: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if JobQueueEntry.FindJobQueueEntry(ObjType,ObjID) then
          JobQueueEntry.Cancel;
    end;

    [Scope('Personalization')]
    procedure ShowJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run",JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetFilter("Object ID to Run",'%1|%2',
          CODEUNIT::"Doc. Exch. Serv.- Doc. Status",
          CODEUNIT::"Doc. Exch. Serv. - Recv. Docs.");
        if JobQueueEntry.FindFirst then
          PAGE.Run(PAGE::"Job Queue Entries",JobQueueEntry);
    end;

    local procedure LogTelemetryWhenServiceEnabled()
    begin
        SendTraceTag('00008A9',TelemetryCategoryTok,VERBOSITY::Normal,DocExchServiceEnabledTxt,DATACLASSIFICATION::SystemMetadata);
        SendTraceTag('00008AA',TelemetryCategoryTok,VERBOSITY::Normal,"Service URL",DATACLASSIFICATION::SystemMetadata);
    end;

    local procedure LogTelemetryWhenServiceDisabled()
    begin
        SendTraceTag('00008AB',TelemetryCategoryTok,VERBOSITY::Normal,DocExchServiceDisabledTxt,DATACLASSIFICATION::SystemMetadata);
        SendTraceTag('00008AC',TelemetryCategoryTok,VERBOSITY::Normal,"Service URL",DATACLASSIFICATION::SystemMetadata);
    end;

    local procedure LogTelemetryWhenServiceCreated()
    begin
        SendTraceTag('00008AD',TelemetryCategoryTok,VERBOSITY::Normal,DocExchServiceCreatedTxt,DATACLASSIFICATION::SystemMetadata);
    end;
}

