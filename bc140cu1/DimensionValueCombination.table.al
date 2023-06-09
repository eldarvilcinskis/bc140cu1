table 351 "Dimension Value Combination"
{
    Caption = 'Dimension Value Combination';

    fields
    {
        field(1;"Dimension 1 Code";Code[20])
        {
            Caption = 'Dimension 1 Code';
            NotBlank = true;
            TableRelation = Dimension.Code;
        }
        field(2;"Dimension 1 Value Code";Code[20])
        {
            Caption = 'Dimension 1 Value Code';
            NotBlank = true;
            TableRelation = "Dimension Value".Code WHERE ("Dimension Code"=FIELD("Dimension 1 Code"));
        }
        field(3;"Dimension 2 Code";Code[20])
        {
            Caption = 'Dimension 2 Code';
            NotBlank = true;
            TableRelation = Dimension.Code;
        }
        field(4;"Dimension 2 Value Code";Code[20])
        {
            Caption = 'Dimension 2 Value Code';
            NotBlank = true;
            TableRelation = "Dimension Value".Code WHERE ("Dimension Code"=FIELD("Dimension 2 Code"));
        }
    }

    keys
    {
        key(Key1;"Dimension 1 Code","Dimension 1 Value Code","Dimension 2 Code","Dimension 2 Value Code")
        {
        }
    }

    fieldgroups
    {
    }
}

