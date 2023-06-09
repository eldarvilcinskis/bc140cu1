page 442 "Reminder Comment Sheet"
{
    AutoSplitKey = true;
    Caption = 'Comment Sheet';
    DataCaptionExpression = Caption(Rec);
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Reminder Comment Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Date;Date)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the date the comment was created.';
                }
                field(Comment;Comment)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the comment itself.';
                }
                field("Code";Code)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a code for the comment.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine;
    end;

    var
        Text000: Label 'untitled';
        Text001: Label 'Reminder';

    local procedure Caption(ReminderCommentLine: Record "Reminder Comment Line"): Text[110]
    begin
        if ReminderCommentLine."No." = '' then
          exit(Text000);
        exit(Text001 + ' ' + ReminderCommentLine."No." + ' ');
    end;
}

