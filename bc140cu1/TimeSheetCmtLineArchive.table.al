table 957 "Time Sheet Cmt. Line Archive"
{
    Caption = 'Time Sheet Cmt. Line Archive';

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
        }
        field(2;"Time Sheet Line No.";Integer)
        {
            Caption = 'Time Sheet Line No.';
        }
        field(3;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(4;Date;Date)
        {
            Caption = 'Date';
        }
        field(5;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(6;Comment;Text[80])
        {
            Caption = 'Comment';
        }
    }

    keys
    {
        key(Key1;"No.","Time Sheet Line No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

