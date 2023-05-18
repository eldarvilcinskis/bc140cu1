page 5602 "Fixed Asset Statistics"
{
    Caption = 'Fixed Asset Statistics';
    DataCaptionExpression = Caption;
    Editable = false;
    LinksAllowed = false;
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "FA Depreciation Book";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Acquisition Date";"Acquisition Date")
                {
                    ApplicationArea = FixedAssets;
                    Caption = 'Acquisition Date';
                    ToolTip = 'Specifies the FA posting date of the first posted acquisition cost.';
                }
                field("G/L Acquisition Date";"G/L Acquisition Date")
                {
                    ApplicationArea = FixedAssets;
                    Caption = 'G/L Acquisition Date';
                    ToolTip = 'Specifies the G/L posting date of the first posted acquisition cost.';
                }
                field(Disposed;Disposed)
                {
                    ApplicationArea = FixedAssets;
                    Caption = 'Disposed Of';
                    ToolTip = 'Specifies whether the fixed asset has been disposed of.';
                }
                field("Disposal Date";"Disposal Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the FA posting date of the first posted disposal amount.';
                    Visible = DisposalDateVisible;
                }
                field("Proceeds on Disposal";"Proceeds on Disposal")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total proceeds on disposal for the fixed asset.';
                    Visible = ProceedsOnDisposalVisible;
                }
                field("Gain/Loss";"Gain/Loss")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total gain (credit) or loss (debit) for the fixed asset.';
                    Visible = GainLossVisible;
                }
                field(DisposalValue;BookValueAfterDisposal)
                {
                    ApplicationArea = All;
                    AutoFormatType = 1;
                    Caption = 'Book Value after Disposal';
                    Editable = false;
                    ToolTip = 'Specifies the total LCY amount of entries posted with the Book Value on Disposal posting type. Entries of this kind are created when you post disposal of a fixed asset to a depreciation book where the Gross method has been selected in the Disposal Calculation Method field.';
                    Visible = DisposalValueVisible;

                    trigger OnDrillDown()
                    begin
                        ShowBookValueAfterDisposal;
                    end;
                }
                fixed(Control1903895301)
                {
                    ShowCaption = false;
                    group("Last FA Posting Date")
                    {
                        Caption = 'Last FA Posting Date';
                        field("Last Acquisition Cost Date";"Last Acquisition Cost Date")
                        {
                            ApplicationArea = FixedAssets;
                            Caption = 'Acquisition Cost';
                            ToolTip = 'Specifies the total percentage of acquisition cost that can be allocated when acquisition cost is posted.';
                        }
                        field("Last Depreciation Date";"Last Depreciation Date")
                        {
                            ApplicationArea = FixedAssets;
                            Caption = 'Depreciation';
                            ToolTip = 'Specifies the FA posting date of the last posted depreciation.';
                        }
                        field("Last Write-Down Date";"Last Write-Down Date")
                        {
                            ApplicationArea = FixedAssets;
                            Caption = 'Write-Down';
                            ToolTip = 'Specifies the FA posting date of the last posted write-down.';
                        }
                        field("Last Appreciation Date";"Last Appreciation Date")
                        {
                            ApplicationArea = FixedAssets;
                            Caption = 'Appreciation';
                            ToolTip = 'Specifies the sum that applies to appreciations.';
                        }
                        field("Last Custom 1 Date";"Last Custom 1 Date")
                        {
                            ApplicationArea = FixedAssets;
                            Caption = 'Custom 1';
                            ToolTip = 'Specifies the FA posting date of the last posted custom 1 entry.';
                        }
                        field("Last Salvage Value Date";"Last Salvage Value Date")
                        {
                            ApplicationArea = FixedAssets;
                            Caption = 'Salvage Value';
                            ToolTip = 'Specifies if related salvage value entries are included in the batch job .';
                        }
                        field("Last Custom 2 Date";"Last Custom 2 Date")
                        {
                            ApplicationArea = FixedAssets;
                            Caption = 'Custom 2';
                            ToolTip = 'Specifies the FA posting date of the last posted custom 2 entry.';
                        }
                    }
                    group(Amount)
                    {
                        Caption = 'Amount';
                        field("Acquisition Cost";"Acquisition Cost")
                        {
                            ApplicationArea = FixedAssets;
                            ToolTip = 'Specifies the total acquisition cost for the fixed asset.';
                        }
                        field(Depreciation;Depreciation)
                        {
                            ApplicationArea = FixedAssets;
                            ToolTip = 'Specifies the total depreciation for the fixed asset.';
                        }
                        field("Write-Down";"Write-Down")
                        {
                            ApplicationArea = FixedAssets;
                            ToolTip = 'Specifies the total LCY amount of write-down entries for the fixed asset.';
                        }
                        field(Appreciation;Appreciation)
                        {
                            ApplicationArea = FixedAssets;
                            ToolTip = 'Specifies the total appreciation for the fixed asset.';
                        }
                        field("Custom 1";"Custom 1")
                        {
                            ApplicationArea = FixedAssets;
                            ToolTip = 'Specifies the total LCY amount for custom 1 entries for the fixed asset.';
                        }
                        field("Salvage Value";"Salvage Value")
                        {
                            ApplicationArea = FixedAssets;
                            ToolTip = 'Specifies the estimated residual value of a fixed asset when it can no longer be used.';
                        }
                        field("Custom 2";"Custom 2")
                        {
                            ApplicationArea = FixedAssets;
                            ToolTip = 'Specifies the total LCY amount for custom 2 entries for the fixed asset.';
                        }
                    }
                }
                fixed(Control2)
                {
                    ShowCaption = false;
                    group(Control3)
                    {
                        ShowCaption = false;
                        field("Book Value";"Book Value")
                        {
                            ApplicationArea = FixedAssets;
                            ToolTip = 'Specifies the book value for the fixed asset.';
                        }
                        field("Depreciable Basis";"Depreciable Basis")
                        {
                            ApplicationArea = FixedAssets;
                            ToolTip = 'Specifies the depreciable basis amount for the fixed asset.';
                        }
                        field(Maintenance;Maintenance)
                        {
                            ApplicationArea = FixedAssets;
                            ToolTip = 'Specifies the total maintenance cost for the fixed asset.';
                        }
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Disposed := "Disposal Date" > 0D;
        DisposalValueVisible := Disposed;
        ProceedsOnDisposalVisible := Disposed;
        GainLossVisible := Disposed;
        DisposalDateVisible := Disposed;
        CalcBookValue;
    end;

    trigger OnInit()
    begin
        DisposalDateVisible := true;
        GainLossVisible := true;
        ProceedsOnDisposalVisible := true;
        DisposalValueVisible := true;
    end;

    var
        Disposed: Boolean;
        BookValueAfterDisposal: Decimal;
        [InDataSet]
        DisposalValueVisible: Boolean;
        [InDataSet]
        ProceedsOnDisposalVisible: Boolean;
        [InDataSet]
        GainLossVisible: Boolean;
        [InDataSet]
        DisposalDateVisible: Boolean;
}

