page 5238 "Detailed Empl. Ledger Entries"
{
    ApplicationArea = BasicHR;
    Caption = 'Detailed Employee Ledger Entries';
    DataCaptionFields = "Employee Ledger Entry No.","Employee No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Detailed Employee Ledger Entry";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Date";"Posting Date")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the posting date of the detailed employee ledger entry.';
                }
                field("Entry Type";"Entry Type")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the entry type of the detailed employee ledger entry.';
                }
                field("Document Type";"Document Type")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the document type of the detailed employee ledger entry.';
                }
                field("Document No.";"Document No.")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the document number of the transaction that created the entry.';
                }
                field("Employee No.";"Employee No.")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the number of the employee to which the entry is posted.';
                }
                field("Initial Entry Global Dim. 1";"Initial Entry Global Dim. 1")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the Global Dimension 1 code of the initial employee ledger entry.';
                    Visible = false;
                }
                field("Initial Entry Global Dim. 2";"Initial Entry Global Dim. 2")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the Global Dimension 2 code of the initial employee ledger entry.';
                    Visible = false;
                }
                field("Currency Code";"Currency Code")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the code for the currency if the amount is in a foreign currency.';
                }
                field(Amount;Amount)
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the amount of the detailed employee ledger entry.';
                }
                field("Amount (LCY)";"Amount (LCY)")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the amount of the entry in LCY.';
                }
                field("Debit Amount";"Debit Amount")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the total of the ledger entries that represent debits.';
                    Visible = false;
                }
                field("Debit Amount (LCY)";"Debit Amount (LCY)")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the total of the ledger entries that represent debits, expressed in LCY.';
                    Visible = false;
                }
                field("Credit Amount";"Credit Amount")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the total of the ledger entries that represent credits.';
                    Visible = false;
                }
                field("Credit Amount (LCY)";"Credit Amount (LCY)")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the total of the ledger entries that represent credits, expressed in the local currency.';
                    Visible = false;
                }
                field("User ID";"User ID")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
                    Visible = false;
                }
                field("Source Code";"Source Code")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the source code that specifies where the entry was created.';
                    Visible = false;
                }
                field("Reason Code";"Reason Code")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the reason code, a supplementary source code that enables you to trace the entry.';
                    Visible = false;
                }
                field(Unapplied;Unapplied)
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies whether the entry has been unapplied (undone) from the Unapply Employee Entries window by the entry number shown in the Unapplied by Entry No. field.';
                    Visible = false;
                }
                field("Unapplied by Entry No.";"Unapplied by Entry No.")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the number of the correcting entry, if the original entry has been unapplied (undone) from the Unapply Employee Entries window.';
                    Visible = false;
                }
                field("Employee Ledger Entry No.";"Employee Ledger Entry No.")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the entry number of the employee ledger entry that the detailed employee ledger entry line was created for.';
                    Visible = false;
                }
                field("Entry No.";"Entry No.")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the entry number of the detailed employee ledger entry.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Unapply Entries")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Unapply Entries';
                    Ellipsis = true;
                    Image = UnApply;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Unselect one or more ledger entries that you want to unapply this record.';

                    trigger OnAction()
                    var
                        EmplEntryApplyPostedEntries: Codeunit "EmplEntry-Apply Posted Entries";
                    begin
                        EmplEntryApplyPostedEntries.UnApplyDtldEmplLedgEntry(Rec);
                    end;
                }
            }
            action("&Navigate")
            {
                ApplicationArea = Basic,Suite;
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.';

                trigger OnAction()
                begin
                    Navigate.SetDoc("Posting Date","Document No.");
                    Navigate.Run;
                end;
            }
        }
    }

    var
        Navigate: Page Navigate;
}

