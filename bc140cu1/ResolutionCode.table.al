table 5919 "Resolution Code"
{
    Caption = 'Resolution Code';
    DrillDownPageID = "Resolution Codes";
    LookupPageID = "Resolution Codes";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Description;Text[80])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
        key(Key2;Description)
        {
        }
    }

    fieldgroups
    {
    }
}

