table 53 "Batch Processing Parameter Map"
{
    Caption = 'Batch Processing Parameter Map';
    ObsoleteReason = 'Moved to table Batch Processing Session Map';
    ObsoleteState = Pending;

    fields
    {
        field(1;"Record ID";RecordID)
        {
            Caption = 'Record ID';
            DataClassification = SystemMetadata;
        }
        field(2;"Batch ID";Guid)
        {
            Caption = 'Batch ID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Record ID")
        {
        }
    }

    fieldgroups
    {
    }
}

