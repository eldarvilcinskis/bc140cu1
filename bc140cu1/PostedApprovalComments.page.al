page 661 "Posted Approval Comments"
{
    Caption = 'Posted Approval Comments';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Posted Approval Comment Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Entry No.";"Entry No.")
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                    Visible = false;
                }
                field("User ID";"User ID")
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies the ID of the user who created this approval comment.';
                    Visible = false;
                }
                field(Comment;Comment)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the comment. You can enter a maximum of 250 characters, both numbers and letters.';
                }
                field("Document No.";"Document No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the document number of the quote, order, invoice, credit memo, return order, or blanket order that the comment applies to.';
                }
                field("Date and Time";"Date and Time")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the date and time that the comment was made.';
                }
                field(PostedRecordID;PostedRecordID)
                {
                    ApplicationArea = Suite;
                    Caption = 'Approved';
                    ToolTip = 'Specifies that the approval request has been approved.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        PostedRecordID := Format("Posted Record ID",0,1);
    end;

    trigger OnAfterGetRecord()
    begin
        PostedRecordID := Format("Posted Record ID",0,1);
    end;

    var
        PostedRecordID: Text;
}

