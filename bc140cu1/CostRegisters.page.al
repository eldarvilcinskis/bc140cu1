page 1104 "Cost Registers"
{
    ApplicationArea = CostAccounting;
    Caption = 'Cost Registers';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Cost Register";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control9)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = CostAccounting;
                    Editable = false;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Source; Source)
                {
                    ApplicationArea = CostAccounting;
                    Editable = false;
                    ToolTip = 'Specifies the source for the cost register.';
                }
                field(Level; Level)
                {
                    ApplicationArea = CostAccounting;
                    ToolTip = 'Specifies by which level the cost allocation posting is done. For example, this makes sure that costs are allocated at level 1 from the ADM cost center to the WORKSHOP and PROD cost centers, before they are allocated at level 2 from the PROD cost center to the FURNITURE, CHAIRS, and PAINT cost objects.';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = CostAccounting;
                    ToolTip = 'Specifies the entry''s posting date.';
                }
                field("From Cost Entry No."; "From Cost Entry No.")
                {
                    ApplicationArea = CostAccounting;
                    Editable = false;
                    ToolTip = 'Specifies the first cost entry number in the cost register.';
                }
                field("To Cost Entry No."; "To Cost Entry No.")
                {
                    ApplicationArea = CostAccounting;
                    Editable = false;
                    ToolTip = 'Specifies the number of the start of the range that applies to the cost registered.';
                }
                field("No. of Entries"; "No. of Entries")
                {
                    ApplicationArea = CostAccounting;
                    Editable = false;
                    ToolTip = 'Specifies the number of entries in the cost register.';
                }
                field("From G/L Entry No."; "From G/L Entry No.")
                {
                    ApplicationArea = CostAccounting;
                    Editable = false;
                    ToolTip = 'Specifies the first general ledger entry number when the cost posting is transferred from the general ledger.';
                }
                field("To G/L Entry No."; "To G/L Entry No.")
                {
                    ApplicationArea = CostAccounting;
                    Editable = false;
                    ToolTip = 'Specifies the number of the end of the range that applies to the cost registered.';
                }
                field("Debit Amount"; "Debit Amount")
                {
                    ApplicationArea = CostAccounting;
                    Editable = false;
                    ToolTip = 'Specifies the total of the ledger entries that represent debits.';
                }
                field("Credit Amount"; "Credit Amount")
                {
                    ApplicationArea = CostAccounting;
                    ToolTip = 'Specifies the total of the ledger entries that represent credits.';
                }
                field(Closed; Closed)
                {
                    ApplicationArea = CostAccounting;
                    ToolTip = 'Specifies whether or not the cost has been closed.';
                }
                field("Processed Date"; "Processed Date")
                {
                    ApplicationArea = CostAccounting;
                    ToolTip = 'Specifies when the cost register was last updated.';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = CostAccounting;
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
                }
                field("Journal Batch Name"; "Journal Batch Name")
                {
                    ApplicationArea = CostAccounting;
                    ToolTip = 'Specifies the name of the journal batch, a personalized journal layout, that the entries were posted from.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Entry")
            {
                Caption = '&Entry';
                Image = Entry;
                action("&Cost Entries")
                {
                    ApplicationArea = CostAccounting;
                    Caption = '&Cost Entries';
                    Image = CostEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunPageOnRec = true;
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View cost entries, which can come from sources such as automatic transfer of general ledger entries to cost entries, manual posting for pure cost entries, internal charges, and manual allocations, and automatic allocation postings for actual costs.';

                    trigger OnAction()
                    var
                        CostEntry: Record "Cost Entry";
                    begin
                        CostEntry.SetRange("Entry No.", "From Cost Entry No.", "To Cost Entry No.");
                        PAGE.Run(PAGE::"Cost Entries", CostEntry);
                    end;
                }
                action("&Allocated Cost Entries")
                {
                    ApplicationArea = CostAccounting;
                    Caption = '&Allocated Cost Entries';
                    Image = GLRegisters;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Cost Entries";
                    RunPageLink = "Allocated with Journal No." = FIELD("No.");
                    RunPageView = SORTING("Allocated with Journal No.");
                    ToolTip = 'Specifies the cost allocation entries.';
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("&Delete Cost Entries")
                {
                    ApplicationArea = CostAccounting;
                    Caption = '&Delete Cost Entries';
                    Image = Delete;
                    RunObject = Report "Delete Cost Entries";
                    RunPageOnRec = true;
                    ToolTip = 'Delete posted cost entries and reverses allocations, for example to simulate allocations by using different allocation ratios, to reverse cost allocations to include late entries in a combined entry as part of the same posting process, or to cancel cost entries from the cost register.';
                }
                action("&Delete Old Cost Entries")
                {
                    ApplicationArea = CostAccounting;
                    Caption = '&Delete Old Cost Entries';
                    Image = Delete;
                    RunObject = Report "Delete Old Cost Entries";
                    ToolTip = 'Delete all cost entries up to and including the date that you enter in the report.';
                }
            }
        }
    }
}

