table 78 "Printer Selection"
{
    Caption = 'Printer Selection';
    DataPerCompany = false;
    LookupPageID = "Printer Selections";

    fields
    {
        field(1;"User ID";Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("User ID");
            end;

            trigger OnValidate()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.ValidateUserID("User ID");
            end;
        }
        field(2;"Report ID";Integer)
        {
            Caption = 'Report ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Report));
        }
        field(3;"Printer Name";Text[250])
        {
            Caption = 'Printer Name';
            TableRelation = Printer;
        }
        field(4;"Report Caption";Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Report),
                                                                           "Object ID"=FIELD("Report ID")));
            Caption = 'Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"User ID","Report ID")
        {
        }
    }

    fieldgroups
    {
    }
}

