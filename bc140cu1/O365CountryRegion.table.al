table 2152 "O365 Country/Region"
{
    Caption = 'O365 Country/Region';
    ReplicateData = false;

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(2;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(3;"VAT Scheme";Text[30])
        {
            Caption = 'VAT Scheme';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick;"Code",Name,"VAT Scheme")
        {
        }
    }
}

