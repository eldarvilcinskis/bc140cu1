table 1449 "Headline RC Security Admin"
{
    Caption = 'Headline RC Security Admin';

    fields
    {
        field(1;"Key";Code[10])
        {
            Caption = 'Key';
            DataClassification = SystemMetadata;
        }
        field(2;"Workdate for computations";Date)
        {
            Caption = 'Workdate for computations';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Key")
        {
        }
    }

    fieldgroups
    {
    }
}

