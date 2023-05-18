table 5636 "Insurance Register"
{
    Caption = 'Insurance Register';
    LookupPageID = "Insurance Registers";

    fields
    {
        field(1;"No.";Integer)
        {
            Caption = 'No.';
        }
        field(2;"From Entry No.";Integer)
        {
            Caption = 'From Entry No.';
            TableRelation = "Ins. Coverage Ledger Entry";
        }
        field(3;"To Entry No.";Integer)
        {
            Caption = 'To Entry No.';
            TableRelation = "Ins. Coverage Ledger Entry";
        }
        field(4;"Creation Date";Date)
        {
            Caption = 'Creation Date';
        }
        field(5;"Source Code";Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(6;"User ID";Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("User ID");
            end;
        }
        field(7;"Journal Batch Name";Code[10])
        {
            Caption = 'Journal Batch Name';
        }
        field(9;"Creation Time";Time)
        {
            Caption = 'Creation Time';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;"Creation Date")
        {
        }
        key(Key3;"Source Code","Journal Batch Name","Creation Date")
        {
        }
    }

    fieldgroups
    {
    }
}

