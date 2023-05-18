table 7604 "Where Used Base Calendar"
{
    Caption = 'Where Used Base Calendar';

    fields
    {
        field(1;"Source Type";Option)
        {
            Caption = 'Source Type';
            Editable = false;
            OptionCaption = 'Company,Customer,Vendor,Location,Shipping Agent,Service';
            OptionMembers = Company,Customer,Vendor,Location,"Shipping Agent",Service;
        }
        field(2;"Source Code";Code[20])
        {
            Caption = 'Source Code';
            Editable = false;
        }
        field(3;"Additional Source Code";Code[20])
        {
            Caption = 'Additional Source Code';
            Editable = false;
        }
        field(4;"Base Calendar Code";Code[10])
        {
            Caption = 'Base Calendar Code';
            TableRelation = "Base Calendar";
        }
        field(5;"Source Name";Text[50])
        {
            Caption = 'Source Name';
            Editable = false;
        }
        field(6;"Customized Changes Exist";Boolean)
        {
            Caption = 'Customized Changes Exist';
            Editable = false;
        }
    }

    keys
    {
        key(Key1;"Base Calendar Code","Source Type","Source Code","Source Name")
        {
        }
    }

    fieldgroups
    {
    }
}

