page 5891 "Phys. Inventory Comment Sheet"
{
    AutoSplitKey = true;
    Caption = 'Phys. Inventory Comment Sheet';
    DataCaptionFields = "Document Type","Order No.","Recording No.";
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Phys. Invt. Comment Line";

    layout
    {
        area(content)
        {
            repeater(Control40)
            {
                ShowCaption = false;
                field(Date;Date)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the date when the comment was created.';
                }
                field(Comment;Comment)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the comment itself.';
                }
                field("Code";Code)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies a code for the comment.';
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1905767507;Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
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
}

