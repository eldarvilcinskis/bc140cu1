table 299 "Reminder Comment Line"
{
    Caption = 'Reminder Comment Line';
    DrillDownPageID = "Reminder Comment List";
    LookupPageID = "Reminder Comment List";

    fields
    {
        field(1;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Reminder,Issued Reminder';
            OptionMembers = Reminder,"Issued Reminder";
        }
        field(2;"No.";Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            TableRelation = IF (Type=CONST(Reminder)) "Reminder Header"
                            ELSE IF (Type=CONST("Issued Reminder")) "Issued Reminder Header";
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
        key(Key1;Type,"No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure SetUpNewLine()
    var
        ReminderCommentLine: Record "Reminder Comment Line";
    begin
        ReminderCommentLine.SetRange(Type,Type);
        ReminderCommentLine.SetRange("No.","No.");
        ReminderCommentLine.SetRange(Date,WorkDate);
        if not ReminderCommentLine.FindFirst then
          Date := WorkDate;

        OnAfterSetUpNewLine(Rec,ReminderCommentLine);
    end;

    [Scope('Personalization')]
    procedure CopyComments(FromType: Integer;ToType: Integer;FromNumber: Code[20];ToNumber: Code[20])
    var
        ReminderCommentLine: Record "Reminder Comment Line";
        ReminderCommentLine2: Record "Reminder Comment Line";
    begin
        ReminderCommentLine.SetRange(Type,FromType);
        ReminderCommentLine.SetRange("No.",FromNumber);
        if ReminderCommentLine.FindSet then
          repeat
            ReminderCommentLine2 := ReminderCommentLine;
            ReminderCommentLine2.Type := ToType;
            ReminderCommentLine2."No." := ToNumber;
            ReminderCommentLine2.Insert;
          until ReminderCommentLine.Next = 0;
    end;

    [Scope('Personalization')]
    procedure DeleteComments(DocType: Option;DocNo: Code[20])
    begin
        SetRange(Type,DocType);
        SetRange("No.",DocNo);
        if not IsEmpty then
          DeleteAll;
    end;

    [Scope('Personalization')]
    procedure ShowComments(DocType: Option;DocNo: Code[20];DocLineNo: Integer)
    var
        ReminderCommentSheet: Page "Reminder Comment Sheet";
    begin
        SetRange(Type,DocType);
        SetRange("No.",DocNo);
        SetRange("Line No.",DocLineNo);
        Clear(ReminderCommentSheet);
        ReminderCommentSheet.SetTableView(Rec);
        ReminderCommentSheet.RunModal;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetUpNewLine(var ReminderCommentLineRec: Record "Reminder Comment Line";var ReminderCommentLineFilter: Record "Reminder Comment Line")
    begin
    end;
}

