page 373 "Bank Account Posting Groups"
{
    ApplicationArea = Basic,Suite;
    Caption = 'Bank Account Posting Groups';
    PageType = List;
    SourceTable = "Bank Account Posting Group";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the code for the G/L account that bank transactions, such as bank payment reconciliations, are posted to when the bank account card contains this code.';
                }
                field("G/L Bank Account No.";"G/L Bank Account No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account to which bank account entries in this posting group are posted.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

