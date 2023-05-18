page 1292 "Payment Application"
{
    Caption = 'Payment Application';
    DelayedInsert = true;
    DeleteAllowed = false;
    PageType = Worksheet;
    PromotedActionCategories = 'New,Process,Report,Show';
    SourceTable = "Payment Application Proposal";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Sorting Order")
                      ORDER(Ascending);

    layout
    {
        area(content)
        {
            group(PaymentInformation)
            {
                Caption = 'Payment Information';
                field(PaymentStatus;Status)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Payment Status';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the application status of the payment, including information about the match confidence of payments that are applied automatically.';
                }
                field(TransactionDate;BankAccReconLine."Transaction Date")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Transaction Date';
                    Editable = false;
                    ToolTip = 'Specifies the date when the payment was recorded in the bank account.';
                }
                field(TransactionAmount;BankAccReconLine."Statement Amount")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Transaction Amount';
                    Editable = false;
                    ToolTip = 'Specifies the payment amount that was recorded on the electronic bank account.';
                }
                field(BankAccReconLineDescription;BankAccReconLine."Transaction Text")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Transaction Text';
                    Editable = false;
                    ToolTip = 'Specifies the text that was entered on the payment when the payment was made to the electronic bank account.';
                }
            }
            group("Open Entries")
            {
                Caption = 'Open Entries';
                repeater(Control28)
                {
                    Caption = 'Open Entries';
                    field(AppliedAmount;"Applied Amt. Incl. Discount")
                    {
                        ApplicationArea = Basic,Suite;
                        BlankZero = true;
                        Caption = 'Applied Amount';
                        Style = Strong;
                        StyleExpr = TRUE;
                        ToolTip = 'Specifies the payment amount, excluding the value in the Applied Pmt. Discount field, that is applied to the open entry.';

                        trigger OnValidate()
                        begin
                            UpdateAfterChangingApplication;
                        end;
                    }
                    field(Applied;Applied)
                    {
                        ApplicationArea = Basic,Suite;
                        ToolTip = 'Specifies that the payment specified on the header of the Payment Application window is applied to the open entry.';

                        trigger OnValidate()
                        begin
                            UpdateAfterChangingApplication;
                        end;
                    }
                    field(RemainingAmountAfterPosting;GetRemainingAmountAfterPostingValue)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Remaining Amount After Posting';
                        ToolTip = 'Specifies the amount that remains to be paid for the open entry after you have posted the payment in the Payment Reconciliation Journal window.';
                    }
                    field("Applies-to Entry No.";"Applies-to Entry No.")
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        ToolTip = 'Specifies the number of the customer or vendor ledger entry that the payment will be applied to when you post the payment reconciliation journal line.';

                        trigger OnDrillDown()
                        begin
                            AppliesToEntryNoDrillDown;
                        end;
                    }
                    field("Due Date";"Due Date")
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        ToolTip = 'Specifies the due date of the open entry.';
                    }
                    field("Document Type";"Document Type")
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        ToolTip = 'Specifies the type of document that is related to the open entry.';
                    }
                    field("Document No.";"Document No.")
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        ToolTip = 'Specifies the number of the document that is related to the open entry.';
                    }
                    field("External Document No.";"External Document No.")
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                    }
                    field(Description;Description)
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        ToolTip = 'Specifies the description of the open entry.';
                    }
                    field("Remaining Amount";"Remaining Amount")
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        Enabled = false;
                        ToolTip = 'Specifies the amount that remains to be paid for the open entry.';
                        Visible = false;
                    }
                    field("Remaining Amt. Incl. Discount";"Remaining Amt. Incl. Discount")
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        Enabled = false;
                        ToolTip = 'Specifies the amount that remains to be paid for the open entry, minus any granted payment discount.';
                    }
                    field("Pmt. Disc. Due Date";"Pmt. Disc. Due Date")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Pmt. Discount Date';
                        ToolTip = 'Specifies the date on which the remaining amount on the open entry must be paid to grant a discount.';

                        trigger OnValidate()
                        begin
                            UpdateAfterChangingApplication;
                        end;
                    }
                    field("Pmt. Disc. Tolerance Date";"Pmt. Disc. Tolerance Date")
                    {
                        ApplicationArea = Basic,Suite;
                        ToolTip = 'Specifies the latest date the amount in the entry must be paid in order for payment discount tolerance to be granted.';
                        Visible = false;
                    }
                    field("Remaining Pmt. Disc. Possible";"Remaining Pmt. Disc. Possible")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Remaining Pmt. Discount Possible';
                        ToolTip = 'Specifies how much discount you can grant for the payment if you apply it to the open entry.';

                        trigger OnValidate()
                        begin
                            UpdateAfterChangingApplication;
                        end;
                    }
                    field(AccountName;GetAccountName)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Account Name';
                        Editable = false;
                        ToolTip = 'Specifies the name of the account that the payment is applied to in the Payment Reconciliation Journal window.';

                        trigger OnDrillDown()
                        begin
                            AccountNameDrillDown;
                        end;
                    }
                    field("Account Type";"Account Type")
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = LineEditable;
                        ToolTip = 'Specifies the type of account that the payment application will be posted to when you post the payment reconciliation journal.';
                    }
                    field("Account No.";"Account No.")
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = LineEditable;
                        ToolTip = 'Specifies the account number the payment application will be posted to when you post the payment reconciliation journal.';

                        trigger OnValidate()
                        begin
                            CurrPage.SaveRecord;
                        end;
                    }
                    field("Posting Date";"Posting Date")
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        ToolTip = 'Specifies the posting date of the open entry.';
                        Visible = false;
                    }
                    field("Match Confidence";"Match Confidence")
                    {
                        ApplicationArea = Basic,Suite;
                        ToolTip = 'Specifies the quality of the match between the payment and the open entry for payment application purposes.';
                    }
                    field("Currency Code";"Currency Code")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Entry Currency Code';
                        ToolTip = 'Specifies the currency code of the open entry.';
                        Visible = false;
                    }
                }
            }
            group(Control5)
            {
                ShowCaption = false;
                field(TotalAppliedAmount;BankAccReconLine."Applied Amount")
                {
                    ApplicationArea = Basic,Suite;
                    AutoFormatType = 1;
                    Caption = 'Applied Amount';
                    DecimalPlaces = 0:5;
                    Editable = false;
                    ToolTip = 'Specifies the sum of the values in the Applied Amount field on lines in the Payment Application window.';
                }
                field(TotalRemainingAmount;BankAccReconLine."Statement Amount" - BankAccReconLine."Applied Amount")
                {
                    ApplicationArea = Basic,Suite;
                    AutoFormatType = 1;
                    Caption = 'Difference';
                    DecimalPlaces = 0:5;
                    Editable = false;
                    StyleExpr = RemAmtToApplyStyleExpr;
                    ToolTip = 'Specifies how much of the payment amount remains to be applied to open entries in the Payment Application window.';
                }
            }
        }
        area(factboxes)
        {
            part(Control2;"Payment-to-Entry Match")
            {
                ApplicationArea = Basic,Suite;
                SubPageLink = "Bank Account No."=FIELD("Bank Account No."),
                              "Statement No."=FIELD("Statement No."),
                              "Statement Line No."=FIELD("Statement Line No."),
                              "Statement Type"=FIELD("Statement Type"),
                              "Account Type"=FIELD("Account Type"),
                              "Account No."=FIELD("Account No."),
                              "Applies-to Entry No."=FIELD("Applies-to Entry No."),
                              "Match Confidence"=FIELD("Match Confidence"),
                              Quality=FIELD(Quality);
            }
            part(Control1;"Additional Match Details")
            {
                ApplicationArea = Basic,Suite;
                SubPageLink = "Bank Account No."=FIELD("Bank Account No."),
                              "Statement No."=FIELD("Statement No."),
                              "Statement Line No."=FIELD("Statement Line No."),
                              "Statement Type"=FIELD("Statement Type");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Details)
            {
                Caption = 'Details';
                action(ShowBankTransactionDetails)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Bank Transaction Details';
                    Image = ExternalDocument;
                    ToolTip = 'View the bank statement details for the selected line. The details include the values that exist in an imported bank statement file.';

                    trigger OnAction()
                    var
                        DataExchField: Record "Data Exch. Field";
                    begin
                        DataExchField.SetRange("Data Exch. No.",BankAccReconLine."Data Exch. Entry No.");
                        DataExchField.SetRange("Line No.",BankAccReconLine."Data Exch. Line No.");
                        PAGE.Run(PAGE::"Bank Statement Line Details",DataExchField);
                    end;
                }
            }
        }
        area(processing)
        {
            group(Review)
            {
                Caption = 'Review';
                action(Accept)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Accept Applications';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Accept a payment application after reviewing it or manually applying it to entries. This closes the payment application and sets the Match Confidence to Accepted.';

                    trigger OnAction()
                    begin
                        if BankAccReconLine.Difference * BankAccReconLine."Applied Amount" > 0 then
                          if BankAccReconLine."Account Type" = BankAccReconLine."Account Type"::"Bank Account" then
                            Error(ExcessiveAmountErr,BankAccReconLine.Difference);

                        BankAccReconLine.AcceptApplication;
                        CurrPage.Close;
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Remove Applications';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Remove a payment application from an entry. This unapplies the payment.';

                    trigger OnAction()
                    begin
                        if Confirm(RemoveApplicationsQst) then
                          RemoveApplications;
                    end;
                }
            }
            group(Show)
            {
                Caption = 'Show';
                action(AllOpenEntries)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'All Open Entries';
                    Image = ViewDetails;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Show all open entries that the payment can be applied to.';

                    trigger OnAction()
                    begin
                        SetRange(Applied);
                        SetRange("Account Type");
                        SetRange("Account No.");
                        SetRange(Type,Type::"Bank Account Ledger Entry",Type::"Check Ledger Entry");

                        if FindFirst then;
                    end;
                }
                action(RelatedPartyOpenEntries)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Related-Party Open Entries';
                    Image = ViewDocumentLine;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Show only open entries that are specifically for the related party in the Account No. field. This limits the list to those open entries that are most likely to relate to the payment.';

                    trigger OnAction()
                    begin
                        SetRange(Applied);

                        BankAccReconLine.Get(
                          BankAccReconLine."Statement Type",BankAccReconLine."Bank Account No.",
                          BankAccReconLine."Statement No.",BankAccReconLine."Statement Line No.");

                        if BankAccReconLine."Account No." <> '' then begin
                          SetRange("Account No.",BankAccReconLine."Account No.");
                          SetRange("Account Type",BankAccReconLine."Account Type");
                        end;
                        SetRange(Type,Type::"Bank Account Ledger Entry",Type::"Check Ledger Entry");

                        if FindFirst then;
                    end;
                }
                action(AppliedEntries)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Applied Entries';
                    Image = ViewRegisteredOrder;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'View the ledger entries that have been applied to this record.';

                    trigger OnAction()
                    begin
                        SetRange(Applied,true);
                        SetRange("Account Type");
                        SetRange("Account No.");
                        SetRange(Type,Type::"Bank Account Ledger Entry",Type::"Check Ledger Entry");

                        if FindFirst then;
                    end;
                }
                action(AllOpenBankTransactions)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'All Open Bank Transactions';
                    Image = ViewPostedOrder;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'View all open bank entries that the payment can be applied to.';

                    trigger OnAction()
                    begin
                        SetRange(Applied);
                        SetRange("Account Type","Account Type"::"Bank Account");
                        SetRange("Account No.");
                        SetRange(Type,Type::"Bank Account Ledger Entry");

                        if FindFirst then;
                    end;
                }
                action(AllOpenPayments)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'All Open Payments';
                    Image = ViewCheck;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Show all open checks that the payment can be applied to.';

                    trigger OnAction()
                    begin
                        SetRange(Applied);
                        SetRange("Account Type","Account Type"::"Bank Account");
                        SetRange("Account No.");
                        SetRange(Type,Type::"Check Ledger Entry");
                        if FindFirst then;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateTotals;
        LineEditable := "Applies-to Entry No." = 0;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        TransferFromBankAccReconLine(BankAccReconLine);
    end;

    trigger OnOpenPage()
    begin
        CODEUNIT.Run(CODEUNIT::"Get Bank Stmt. Line Candidates",Rec);
        SetCurrentKey("Sorting Order","Stmt To Rem. Amount Difference");
        Ascending(true);

        if FindFirst then;
    end;

    var
        BankAccReconLine: Record "Bank Acc. Reconciliation Line";
        RemAmtToApplyStyleExpr: Text;
        RemoveApplicationsQst: Label 'Are you sure you want to remove all applications?';
        Status: Text;
        AppliedManuallyStatusTxt: Label 'Applied Manually';
        NoApplicationStatusTxt: Label 'Not Applied';
        AppliedAutomaticallyStatusTxt: Label 'Applied Automatically - Match Confidence: %1';
        AcceptedStatusTxt: Label 'Accepted';
        LineEditable: Boolean;
        ExcessiveAmountErr: Label 'The remaining amount to apply is %1.', Comment='%1 is the amount that is not applied (there is filed on the page named Remaining Amount To Apply)';

    [Scope('Personalization')]
    procedure SetBankAccReconcLine(NewBankAccReconLine: Record "Bank Acc. Reconciliation Line")
    begin
        BankAccReconLine := NewBankAccReconLine;
        TransferFromBankAccReconLine(NewBankAccReconLine);

        OnSetBankAccReconcLine(BankAccReconLine);
    end;

    local procedure UpdateTotals()
    begin
        BankAccReconLine.Get(
          BankAccReconLine."Statement Type",BankAccReconLine."Bank Account No.",
          BankAccReconLine."Statement No.",BankAccReconLine."Statement Line No.");

        BankAccReconLine.CalcFields("Match Confidence");
        case BankAccReconLine."Match Confidence" of
          BankAccReconLine."Match Confidence"::None:
            Status := NoApplicationStatusTxt;
          BankAccReconLine."Match Confidence"::Accepted:
            Status := AcceptedStatusTxt;
          BankAccReconLine."Match Confidence"::Manual:
            Status := AppliedManuallyStatusTxt;
          else
            Status := StrSubstNo(AppliedAutomaticallyStatusTxt,BankAccReconLine."Match Confidence");
        end;

        UpdateRemAmtToApplyStyle;
    end;

    local procedure UpdateRemAmtToApplyStyle()
    begin
        if BankAccReconLine."Statement Amount" = BankAccReconLine."Applied Amount" then
          RemAmtToApplyStyleExpr := 'Favorable'
        else
          RemAmtToApplyStyleExpr := 'Unfavorable';
    end;

    local procedure UpdateAfterChangingApplication()
    var
        MatchBankPayments: Codeunit "Match Bank Payments";
    begin
        BankAccReconLine.SetManualApplication;
        UpdateToSystemMatchConfidence;
        UpdateTotals;
        MatchBankPayments.UpdateType(BankAccReconLine);
    end;

    local procedure UpdateToSystemMatchConfidence()
    var
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
    begin
        if ("Match Confidence" = "Match Confidence"::Accepted) or ("Match Confidence" = "Match Confidence"::Manual) then
          "Match Confidence" := BankPmtApplRule.GetMatchConfidence(Quality);
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnSetBankAccReconcLine(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    begin
    end;
}

