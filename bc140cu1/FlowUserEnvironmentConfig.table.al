table 1545 "Flow User Environment Config"
{
    Caption = 'Flow User Environment Config';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"User Security ID";Guid)
        {
            Caption = 'User Security ID';
        }
        field(2;"Environment ID";Text[50])
        {
            Caption = 'Environment ID';
        }
        field(3;"Environment Display Name";Text[100])
        {
            Caption = 'Environment Display Name';
        }
    }

    keys
    {
        key(Key1;"User Security ID")
        {
        }
    }

    fieldgroups
    {
    }
}

