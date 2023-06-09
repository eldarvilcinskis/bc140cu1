table 5074 "Delivery Sorter"
{
    Caption = 'Delivery Sorter';

    fields
    {
        field(1;"No.";Integer)
        {
            Caption = 'No.';
        }
        field(2;"Attachment No.";Integer)
        {
            Caption = 'Attachment No.';
            TableRelation = Attachment;
        }
        field(3;"Correspondence Type";Option)
        {
            Caption = 'Correspondence Type';
            OptionCaption = ' ,Hard Copy,Email,Fax';
            OptionMembers = " ","Hard Copy",Email,Fax;
        }
        field(4;Subject;Text[100])
        {
            Caption = 'Subject';
        }
        field(5;"Send Word Docs. as Attmt.";Boolean)
        {
            Caption = 'Send Word Docs. as Attmt.';
        }
        field(6;"Language Code";Code[10])
        {
            Caption = 'Language Code';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;"Attachment No.","Correspondence Type",Subject,"Send Word Docs. as Attmt.")
        {
        }
    }

    fieldgroups
    {
    }
}

