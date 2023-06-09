table 63 "Account Use Buffer"
{
    Caption = 'Account Use Buffer';
    ReplicateData = false;

    fields
    {
        field(1;"Account No.";Code[20])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
        }
        field(2;"No. of Use";Integer)
        {
            Caption = 'No. of Use';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Account No.")
        {
        }
        key(Key2;"No. of Use")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure UpdateBuffer(var RecRef: RecordRef;AccountFieldNo: Integer)
    var
        FieldRef: FieldRef;
        AccNo: Code[20];
    begin
        if RecRef.FindSet then
          repeat
            FieldRef := RecRef.Field(AccountFieldNo);
            AccNo := FieldRef.Value;
            if AccNo <> '' then
              if Get(AccNo) then begin
                "No. of Use" += 1;
                Modify;
              end else begin
                Init;
                "Account No." := AccNo;
                "No. of Use" += 1;
                Insert;
              end;
          until RecRef.Next = 0;
    end;
}

