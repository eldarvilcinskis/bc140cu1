page 5234 "HR Confidential Comment Sheet"
{
    AutoSplitKey = true;
    Caption = 'Confidential Comment Sheet';
    DataCaptionExpression = Caption(Rec);
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "HR Confidential Comment Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Date;Date)
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies the date when the comment was created.';
                }
                field(Comment;Comment)
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies the comment itself.';
                }
                field("Code";Code)
                {
                    ApplicationArea = BasicHR;
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
        Employee: Record Employee;
        ConfidentialInfo: Record "Confidential Information";

    local procedure Caption(HRCommentLine: Record "HR Confidential Comment Line"): Text[110]
    begin
        if ConfidentialInfo.Get(HRCommentLine."No.",HRCommentLine.Code,HRCommentLine."Table Line No.") and
           Employee.Get(HRCommentLine."No.")
        then
          exit(HRCommentLine."No." + ' ' + Employee.FullName + ' ' +
            ConfidentialInfo."Confidential Code");
        exit(Text000);
    end;
}

