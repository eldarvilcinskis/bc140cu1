page 1705 "Deferral Schedule View Subform"
{
    Caption = 'Deferral Schedule Detail';
    PageType = ListPart;
    SourceTable = "Posted Deferral Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the posting date for the entry.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a description of the record.';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the line''s net amount.';
                }
            }
            group(Control8)
            {
                ShowCaption = false;
                group(Control7)
                {
                    ShowCaption = false;
                    field(TotalDeferral; TotalDeferral)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Total Amount to Defer';
                        Editable = false;
                        Enabled = false;
                        ToolTip = 'Specifies the total amount to defer.';
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateTotal;
    end;

    trigger OnAfterGetRecord()
    begin
        Changed := false;
    end;

    var
        TotalDeferral: Decimal;
        Changed: Boolean;

    local procedure UpdateTotal()
    begin
        CalcTotal(Rec, TotalDeferral);
    end;

    local procedure CalcTotal(var PostedDeferralLine: Record "Posted Deferral Line"; var TotalDeferral: Decimal)
    var
        PostedDeferralLineTemp: Record "Posted Deferral Line";
        ShowTotalDeferral: Boolean;
    begin
        PostedDeferralLineTemp.CopyFilters(PostedDeferralLine);
        ShowTotalDeferral := PostedDeferralLineTemp.CalcSums(Amount);
        if ShowTotalDeferral then
            TotalDeferral := PostedDeferralLineTemp.Amount;
    end;

    [Scope('Personalization')]
    procedure GetChanged(): Boolean
    begin
        exit(Changed);
    end;
}

