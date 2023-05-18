table 8451 "Intrastat Checklist Setup"
{
    Caption = 'Intrastat Checklist Setup';

    fields
    {
        field(1;"Field No.";Integer)
        {
            Caption = 'Field No.';

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
                Field.Get(DATABASE::"Intrastat Jnl. Line","Field No.");
                "Field Name" := Field.FieldName;
            end;
        }
        field(2;"Field Name";Text[30])
        {
            Caption = 'Field Name';
        }
    }

    keys
    {
        key(Key1;"Field No.")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure LookupFieldName()
    var
        "Field": Record "Field";
        FieldList: Page "Field List";
    begin
        Clear(FieldList);
        Field.SetRange(TableNo,DATABASE::"Intrastat Jnl. Line");
        Field.SetFilter("No.",'<>1&<>2&<>3');
        Field.SetRange(Class,Field.Class::Normal);
        Field.SetRange(ObsoleteState,Field.ObsoleteState::No);
        FieldList.SetTableView(Field);
        FieldList.LookupMode := true;
        if FieldList.RunModal = ACTION::LookupOK then begin
          FieldList.GetRecord(Field);
          Validate("Field No.",Field."No.");
        end;
    end;
}

