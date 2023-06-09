table 9008 "User Login"
{
    Caption = 'User Login';
    Permissions = TableData "User Login"=rimd;
    ReplicateData = false;

    fields
    {
        field(1;"User SID";Guid)
        {
            Caption = 'User SID';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(2;"First Login Date";Date)
        {
            Caption = 'First Login Date';
        }
        field(3;"Penultimate Login Date";DateTime)
        {
            Caption = 'Penultimate Login Date';
            DataClassification = CustomerContent;
        }
        field(4;"Last Login Date";DateTime)
        {
            Caption = 'Last Login Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1;"User SID")
        {
        }
        key(Key2;"Last Login Date")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure GetLastLoginDateTime(): DateTime
    begin
        if Get(UserSecurityId) then
          exit("Penultimate Login Date");
        exit(0DT);
    end;

    [Scope('Personalization')]
    procedure UpdateLastLoginInfo()
    begin
        if Get(UserSecurityId) then begin
          "Penultimate Login Date" := "Last Login Date";
          "Last Login Date" := CurrentDateTime;
          Modify(true);
        end else begin
          "User SID" := UserSecurityId;
          "Penultimate Login Date" := 0DT;
          "Last Login Date" := CurrentDateTime;
          Insert(true);
        end
    end;

    [Scope('Personalization')]
    procedure UserLoggedInAtOrAfter(GivenDateTime: DateTime): Boolean
    begin
        if not Get(UserSecurityId) then
          exit(false);
        exit("Last Login Date" >= GivenDateTime);
    end;
}

