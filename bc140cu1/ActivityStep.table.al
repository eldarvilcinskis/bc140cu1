table 5082 "Activity Step"
{
    Caption = 'Activity Step';

    fields
    {
        field(1;"Activity Code";Code[10])
        {
            Caption = 'Activity Code';
            NotBlank = true;
            TableRelation = Activity;
        }
        field(2;"Step No.";Integer)
        {
            Caption = 'Step No.';
        }
        field(3;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Meeting,Phone Call';
            OptionMembers = " ",Meeting,"Phone Call";
        }
        field(4;Description;Text[100])
        {
            Caption = 'Description';
        }
        field(5;Priority;Option)
        {
            Caption = 'Priority';
            OptionCaption = 'Low,Normal,High';
            OptionMembers = Low,Normal,High;
        }
        field(6;"Date Formula";DateFormula)
        {
            Caption = 'Date Formula';
        }
    }

    keys
    {
        key(Key1;"Activity Code","Step No.")
        {
        }
        key(Key2;"Activity Code",Type)
        {
        }
    }

    fieldgroups
    {
    }
}

