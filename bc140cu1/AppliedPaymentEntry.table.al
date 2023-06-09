table 1294 "Applied Payment Entry"
{
    Caption = 'Applied Payment Entry';
    LookupPageID = "Payment Application";

    fields
    {
        field(1;"Bank Account No.";Code[20])
        {
            Caption = 'Bank Account No.';
            TableRelation = "Bank Account";
        }
        field(2;"Statement No.";Code[20])
        {
            Caption = 'Statement No.';
            TableRelation = "Bank Acc. Reconciliation"."Statement No." WHERE ("Bank Account No."=FIELD("Bank Account No."),
                                                                              "Statement Type"=FIELD("Statement Type"));
        }
        field(3;"Statement Line No.";Integer)
        {
            Caption = 'Statement Line No.';
        }
        field(20;"Statement Type";Option)
        {
            Caption = 'Statement Type';
            OptionCaption = 'Bank Reconciliation,Payment Application';
            OptionMembers = "Bank Reconciliation","Payment Application";
        }
        field(21;"Account Type";Option)
        {
            Caption = 'Account Type';
            OptionCaption = 'G/L Account,Customer,Vendor,Bank Account,Fixed Asset,IC Partner';
            OptionMembers = "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset","IC Partner";

            trigger OnValidate()
            begin
                Validate("Account No.",'');
            end;
        }
        field(22;"Account No.";Code[20])
        {
            Caption = 'Account No.';
            TableRelation = IF ("Account Type"=CONST("G/L Account")) "G/L Account" WHERE ("Account Type"=CONST(Posting),
                                                                                          Blocked=CONST(false))
                                                                                          ELSE IF ("Account Type"=CONST(Customer)) Customer
                                                                                          ELSE IF ("Account Type"=CONST(Vendor)) Vendor
                                                                                          ELSE IF ("Account Type"=CONST("Bank Account")) "Bank Account"
                                                                                          ELSE IF ("Account Type"=CONST("Fixed Asset")) "Fixed Asset"
                                                                                          ELSE IF ("Account Type"=CONST("IC Partner")) "IC Partner";

            trigger OnValidate()
            begin
                if "Account No." = '' then
                  CheckApplnIsSameAcc;

                GetAccInfo;
                Validate("Applies-to Entry No.",0);
            end;
        }
        field(23;"Applies-to Entry No.";Integer)
        {
            Caption = 'Applies-to Entry No.';
            TableRelation = IF ("Account Type"=CONST("G/L Account")) "G/L Entry"
                            ELSE IF ("Account Type"=CONST(Customer)) "Cust. Ledger Entry" WHERE (Open=CONST(true))
                            ELSE IF ("Account Type"=CONST(Vendor)) "Vendor Ledger Entry" WHERE (Open=CONST(true))
                            ELSE IF ("Account Type"=CONST("Bank Account")) "Bank Account Ledger Entry" WHERE (Open=CONST(true));

            trigger OnLookup()
            var
                CustLedgEntry: Record "Cust. Ledger Entry";
                VendLedgEntry: Record "Vendor Ledger Entry";
                BankAccLedgEntry: Record "Bank Account Ledger Entry";
                GLEntry: Record "G/L Entry";
            begin
                case "Account Type" of
                  "Account Type"::"G/L Account":
                    begin
                      GLEntry.SetRange("G/L Account No.","Account No.");
                      if PAGE.RunModal(0,GLEntry) = ACTION::LookupOK then
                        Validate("Applies-to Entry No.",GLEntry."Entry No.");
                    end;
                  "Account Type"::Customer:
                    begin
                      CustLedgEntry.SetRange(Open,true);
                      CustLedgEntry.SetRange("Customer No.","Account No.");
                      if PAGE.RunModal(0,CustLedgEntry) = ACTION::LookupOK then
                        Validate("Applies-to Entry No.",CustLedgEntry."Entry No.");
                    end;
                  "Account Type"::Vendor:
                    begin
                      VendLedgEntry.SetRange(Open,true);
                      VendLedgEntry.SetRange("Vendor No.","Account No.");
                      if PAGE.RunModal(0,VendLedgEntry) = ACTION::LookupOK then
                        Validate("Applies-to Entry No.",VendLedgEntry."Entry No.");
                    end;
                  "Account Type"::"Bank Account":
                    begin
                      BankAccLedgEntry.SetRange(Open,true);
                      BankAccLedgEntry.SetRange("Bank Account No.","Account No.");
                      if PAGE.RunModal(0,BankAccLedgEntry) = ACTION::LookupOK then
                        Validate("Applies-to Entry No.",BankAccLedgEntry."Entry No.");
                    end;
                end;
            end;

            trigger OnValidate()
            begin
                if "Applies-to Entry No." = 0 then begin
                  Validate("Applied Amount",0);
                  exit;
                end;

                CheckCurrencyCombination;
                GetLedgEntryInfo;
                UpdatePaymentDiscount(SuggestDiscToApply(false));
                Validate("Applied Amount",SuggestAmtToApply);
            end;
        }
        field(24;"Applied Amount";Decimal)
        {
            Caption = 'Applied Amount';

            trigger OnValidate()
            begin
                if "Applies-to Entry No." <> 0 then
                  TestField("Applied Amount");
                CheckEntryAmt;
                UpdatePaymentDiscount(SuggestDiscToApply(true));
                if "Applied Pmt. Discount" <> 0 then
                  "Applied Amount" := SuggestAmtToApply;

                UpdateParentBankAccReconLine(false);
            end;
        }
        field(29;"Applied Pmt. Discount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            Caption = 'Applied Pmt. Discount';
        }
        field(30;Quality;Integer)
        {
            Caption = 'Quality';
        }
        field(31;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(32;"Document Type";Option)
        {
            Caption = 'Document Type';
            OptionCaption = ' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund';
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;
        }
        field(33;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(34;Description;Text[100])
        {
            Caption = 'Description';
        }
        field(35;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(36;"Due Date";Date)
        {
            Caption = 'Due Date';
        }
        field(37;"External Document No.";Code[35])
        {
            Caption = 'External Document No.';
        }
        field(50;"Match Confidence";Option)
        {
            Caption = 'Match Confidence';
            Editable = false;
            InitValue = "None";
            OptionCaption = 'None,Low,Medium,High,High - Text-to-Account Mapping,Manual,Accepted';
            OptionMembers = "None",Low,Medium,High,"High - Text-to-Account Mapping",Manual,Accepted;
        }
    }

    keys
    {
        key(Key1;"Statement Type","Bank Account No.","Statement No.","Statement Line No.","Account Type","Account No.","Applies-to Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        "Applied Amount" := 0;
        "Applied Pmt. Discount" := 0;
        UpdateParentBankAccReconLine(true);
        ClearCustVendEntryApplicationData;
    end;

    trigger OnInsert()
    begin
        if "Applies-to Entry No." <> 0 then
          TestField("Applied Amount");

        CheckApplnIsSameAcc;
    end;

    trigger OnModify()
    begin
        TestField("Applied Amount");
        CheckApplnIsSameAcc;
    end;

    var
        CurrencyMismatchErr: Label 'Currency codes on bank account %1 and ledger entry %2 do not match.';
        AmtCannotExceedErr: Label 'The Amount to Apply cannot exceed %1. This is because the Remaining Amount on the entry is %2 and the amount assigned to other statement lines is %3.';
        CannotApplyStmtLineErr: Label 'You cannot apply to %1 %2 because the statement line already contains an application to %3 %4.', Comment='%1 = Account Type, %2 = Account No., %3 = Account Type, %4 = Account No.';

    local procedure CheckApplnIsSameAcc()
    var
        ExistingAppliedPmtEntry: Record "Applied Payment Entry";
        BankAccReconLine: Record "Bank Acc. Reconciliation Line";
    begin
        if "Account No." = '' then
          exit;
        BankAccReconLine.Get("Statement Type","Bank Account No.","Statement No.","Statement Line No.");
        ExistingAppliedPmtEntry.FilterAppliedPmtEntry(BankAccReconLine);
        if ExistingAppliedPmtEntry.FindFirst then
          CheckCurrentMatchesExistingAppln(ExistingAppliedPmtEntry);
        if ExistingAppliedPmtEntry.FindLast then
          CheckCurrentMatchesExistingAppln(ExistingAppliedPmtEntry);
    end;

    local procedure CheckCurrentMatchesExistingAppln(ExistingAppliedPmtEntry: Record "Applied Payment Entry")
    begin
        if ("Account Type" = ExistingAppliedPmtEntry."Account Type") and
           ("Account No." = ExistingAppliedPmtEntry."Account No.")
        then
          exit;

        Error(
          CannotApplyStmtLineErr,
          "Account Type","Account No.",
          ExistingAppliedPmtEntry."Account Type",
          ExistingAppliedPmtEntry."Account No.");
    end;

    local procedure CheckEntryAmt()
    var
        BankAccReconLine: Record "Bank Acc. Reconciliation Line";
        AmtAvailableToApply: Decimal;
    begin
        if "Applied Amount" = 0 then
          exit;

        BankAccReconLine.Get("Statement Type","Bank Account No.","Statement No.","Statement Line No.");
        // Amount should not exceed Remaining Amount
        AmtAvailableToApply := GetRemAmt - GetAmtAppliedToOtherStmtLines;
        if "Applies-to Entry No." <> 0 then
          if "Applied Amount" > 0 then begin
            if not ("Applied Amount" in [0..AmtAvailableToApply]) then
              Error(AmtCannotExceedErr,AmtAvailableToApply,GetRemAmt,GetAmtAppliedToOtherStmtLines);
          end else
            if not ("Applied Amount" in [AmtAvailableToApply..0]) then
              Error(AmtCannotExceedErr,AmtAvailableToApply,GetRemAmt,GetAmtAppliedToOtherStmtLines);
    end;

    local procedure UpdateParentBankAccReconLine(IsDelete: Boolean)
    var
        BankAccReconLine: Record "Bank Acc. Reconciliation Line";
        NewAppliedAmt: Decimal;
    begin
        BankAccReconLine.Get("Statement Type","Bank Account No.","Statement No.","Statement Line No.");

        NewAppliedAmt := GetTotalAppliedAmountInclPmtDisc(IsDelete);

        BankAccReconLine."Applied Entries" := GetNoOfAppliedEntries(IsDelete);

        if IsDelete then begin
          if NewAppliedAmt = 0 then begin
            BankAccReconLine.Validate("Applied Amount",0);
            BankAccReconLine.Validate("Account No.",'')
          end
        end else
          if BankAccReconLine."Applied Amount" = 0 then begin
            BankAccReconLine.Validate("Account Type","Account Type");
            BankAccReconLine.Validate("Account No.","Account No.");
          end else
            CheckApplnIsSameAcc;

        BankAccReconLine.Validate("Applied Amount",NewAppliedAmt);
        BankAccReconLine.Modify;
    end;

    local procedure CheckCurrencyCombination()
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendorLedgEntry: Record "Vendor Ledger Entry";
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
    begin
        if IsBankLCY then
          exit;

        if "Applies-to Entry No." = 0 then
          exit;

        case "Account Type" of
          "Account Type"::Customer:
            begin
              CustLedgEntry.Get("Applies-to Entry No.");
              if not CurrencyMatches("Bank Account No.",CustLedgEntry."Currency Code",GetLCYCode) then
                Error(CurrencyMismatchErr,"Bank Account No.","Applies-to Entry No.");
            end;
          "Account Type"::Vendor:
            begin
              VendorLedgEntry.Get("Applies-to Entry No.");
              if not CurrencyMatches("Bank Account No.",VendorLedgEntry."Currency Code",GetLCYCode) then
                Error(CurrencyMismatchErr,"Bank Account No.","Applies-to Entry No.");
            end;
          "Account Type"::"Bank Account":
            begin
              BankAccLedgEntry.Get("Applies-to Entry No.");
              if not CurrencyMatches("Bank Account No.",BankAccLedgEntry."Currency Code",GetLCYCode) then
                Error(CurrencyMismatchErr,"Bank Account No.","Applies-to Entry No.");
            end;
        end;
    end;

    local procedure CurrencyMatches(BankAccNo: Code[20];LedgEntryCurrCode: Code[10];LCYCode: Code[10]): Boolean
    var
        BankAcc: Record "Bank Account";
        BankAccCurrCode: Code[10];
    begin
        BankAcc.Get(BankAccNo);
        BankAccCurrCode := BankAcc."Currency Code";
        if BankAccCurrCode = '' then
          BankAccCurrCode := LCYCode;
        if LedgEntryCurrCode = '' then
          LedgEntryCurrCode := LCYCode;
        exit(LedgEntryCurrCode = BankAccCurrCode);
    end;

    local procedure IsBankLCY(): Boolean
    var
        BankAcc: Record "Bank Account";
    begin
        BankAcc.Get("Bank Account No.");
        exit(BankAcc.IsInLocalCurrency);
    end;

    local procedure GetLCYCode(): Code[10]
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get;
        exit(GLSetup.GetCurrencyCode(''));
    end;

    [Scope('Personalization')]
    procedure SuggestAmtToApply(): Decimal
    var
        RemAmtToApply: Decimal;
        LineRemAmtToApply: Decimal;
    begin
        RemAmtToApply := GetRemAmt - GetAmtAppliedToOtherStmtLines;
        LineRemAmtToApply := GetStmtLineRemAmtToApply + "Applied Pmt. Discount";

        if "Account Type" = "Account Type"::Customer then
          if (LineRemAmtToApply >= 0) and ("Document Type" = "Document Type"::"Credit Memo") then
            exit(RemAmtToApply);
        if "Account Type" = "Account Type"::Vendor then
          if (LineRemAmtToApply <= 0) and ("Document Type" = "Document Type"::"Credit Memo") then
            exit(RemAmtToApply);

        exit(
          AbsMin(
            RemAmtToApply,
            LineRemAmtToApply));
    end;

    [Scope('Personalization')]
    procedure SuggestDiscToApply(UseAppliedAmt: Boolean): Decimal
    var
        PmtDiscDueDate: Date;
        PmtDiscToleranceDate: Date;
        RemPmtDiscPossible: Decimal;
    begin
        if InclPmtDisc(UseAppliedAmt) then begin
          GetDiscInfo(PmtDiscDueDate,PmtDiscToleranceDate,RemPmtDiscPossible);
          exit(RemPmtDiscPossible + GetAcceptedPmtTolerance);
        end;
        exit(GetAcceptedPmtTolerance);
    end;

    [Scope('Personalization')]
    procedure GetDiscInfo(var PmtDiscDueDate: Date;var PmtDiscToleranceDate: Date;var RemPmtDiscPossible: Decimal)
    begin
        PmtDiscDueDate := 0D;
        RemPmtDiscPossible := 0;

        if "Account No." = '' then
          exit;
        if "Applies-to Entry No." = 0 then
          exit;

        case "Account Type" of
          "Account Type"::Customer:
            GetCustLedgEntryDiscInfo(PmtDiscDueDate,PmtDiscToleranceDate,RemPmtDiscPossible);
          "Account Type"::Vendor:
            GetVendLedgEntryDiscInfo(PmtDiscDueDate,PmtDiscToleranceDate,RemPmtDiscPossible);
        end;
    end;

    local procedure GetCustLedgEntryDiscInfo(var PmtDiscDueDate: Date;var PmtDiscToleranceDate: Date;var RemPmtDiscPossible: Decimal)
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgEntry.Get("Applies-to Entry No.");
        PmtDiscDueDate := CustLedgEntry."Pmt. Discount Date";
        PmtDiscToleranceDate := CustLedgEntry."Pmt. Disc. Tolerance Date";
        if IsBankLCY and (CustLedgEntry."Currency Code" <> '') then
          RemPmtDiscPossible :=
            Round(CustLedgEntry."Remaining Pmt. Disc. Possible" / CustLedgEntry."Adjusted Currency Factor")
        else
          RemPmtDiscPossible := CustLedgEntry."Remaining Pmt. Disc. Possible";
    end;

    local procedure GetVendLedgEntryDiscInfo(var PmtDiscDueDate: Date;var PmtDiscToleranceDate: Date;var RemPmtDiscPossible: Decimal)
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgEntry.Get("Applies-to Entry No.");
        PmtDiscDueDate := VendLedgEntry."Pmt. Discount Date";
        PmtDiscToleranceDate := VendLedgEntry."Pmt. Disc. Tolerance Date";
        VendLedgEntry.CalcFields("Amount (LCY)",Amount);
        if IsBankLCY and (VendLedgEntry."Currency Code" <> '') then
          RemPmtDiscPossible :=
            Round(VendLedgEntry."Remaining Pmt. Disc. Possible" / VendLedgEntry."Adjusted Currency Factor")
        else
          RemPmtDiscPossible := VendLedgEntry."Remaining Pmt. Disc. Possible";
    end;

    [Scope('Personalization')]
    procedure GetRemAmt(): Decimal
    begin
        if "Account No." = '' then
          exit(0);
        if "Applies-to Entry No." = 0 then
          exit(GetStmtLineRemAmtToApply);

        case "Account Type" of
          "Account Type"::Customer:
            exit(GetCustLedgEntryRemAmt);
          "Account Type"::Vendor:
            exit(GetVendLedgEntryRemAmt);
          "Account Type"::"Bank Account":
            exit(GetBankAccLedgEntryRemAmt);
        end;
    end;

    local procedure GetAcceptedPmtTolerance(): Decimal
    begin
        if ("Account No." = '') or ("Applies-to Entry No." = 0) then
          exit(0);
        case "Account Type" of
          "Account Type"::Customer:
            exit(GetCustLedgEntryPmtTolAmt);
          "Account Type"::Vendor:
            exit(GetVendLedgEntryPmtTolAmt);
        end;
    end;

    local procedure GetCustLedgEntryRemAmt(): Decimal
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgEntry.Get("Applies-to Entry No.");
        if IsBankLCY and (CustLedgEntry."Currency Code" <> '') then begin
          CustLedgEntry.CalcFields("Remaining Amt. (LCY)");
          exit(CustLedgEntry."Remaining Amt. (LCY)");
        end;
        CustLedgEntry.CalcFields("Remaining Amount");
        exit(CustLedgEntry."Remaining Amount");
    end;

    local procedure GetVendLedgEntryRemAmt(): Decimal
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgEntry.Get("Applies-to Entry No.");
        if IsBankLCY and (VendLedgEntry."Currency Code" <> '') then begin
          VendLedgEntry.CalcFields("Remaining Amt. (LCY)");
          exit(VendLedgEntry."Remaining Amt. (LCY)");
        end;
        VendLedgEntry.CalcFields("Remaining Amount");
        exit(VendLedgEntry."Remaining Amount");
    end;

    local procedure GetBankAccLedgEntryRemAmt(): Decimal
    var
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
    begin
        BankAccLedgEntry.Get("Applies-to Entry No.");
        if IsBankLCY then
          exit(
            Round(
              BankAccLedgEntry."Remaining Amount" *
              BankAccLedgEntry."Amount (LCY)" / BankAccLedgEntry.Amount));
        exit(BankAccLedgEntry."Remaining Amount");
    end;

    local procedure GetCustLedgEntryPmtTolAmt(): Decimal
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgEntry.Get("Applies-to Entry No.");
        exit(CustLedgEntry."Accepted Payment Tolerance");
    end;

    local procedure GetVendLedgEntryPmtTolAmt(): Decimal
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgEntry.Get("Applies-to Entry No.");
        exit(VendLedgEntry."Accepted Payment Tolerance");
    end;

    [Scope('Personalization')]
    procedure GetStmtLineRemAmtToApply(): Decimal
    var
        BankAccReconLine: Record "Bank Acc. Reconciliation Line";
    begin
        BankAccReconLine.Get("Statement Type","Bank Account No.","Statement No.","Statement Line No.");

        if BankAccReconLine.Difference = 0 then
          exit(0);

        exit(BankAccReconLine.Difference + GetOldAppliedAmtInclDisc);
    end;

    local procedure GetOldAppliedAmtInclDisc(): Decimal
    var
        OldAppliedPmtEntry: Record "Applied Payment Entry";
    begin
        OldAppliedPmtEntry := Rec;
        if not OldAppliedPmtEntry.Find then
          exit(0);
        exit(OldAppliedPmtEntry."Applied Amount" - OldAppliedPmtEntry."Applied Pmt. Discount");
    end;

    local procedure IsAcceptedPmtDiscTolerance(): Boolean
    begin
        if ("Account No." = '') or ("Applies-to Entry No." = 0) then
          exit(false);
        case "Account Type" of
          "Account Type"::Customer:
            exit(IsCustLedgEntryPmtDiscTol);
          "Account Type"::Vendor:
            exit(IsVendLedgEntryPmtDiscTol);
        end;
    end;

    local procedure IsCustLedgEntryPmtDiscTol(): Boolean
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgEntry.Get("Applies-to Entry No.");
        exit(CustLedgEntry."Accepted Pmt. Disc. Tolerance");
    end;

    local procedure IsVendLedgEntryPmtDiscTol(): Boolean
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgEntry.Get("Applies-to Entry No.");
        exit(VendLedgEntry."Accepted Pmt. Disc. Tolerance");
    end;

    local procedure AbsMin(Amt1: Decimal;Amt2: Decimal): Decimal
    begin
        if Abs(Amt1) < Abs(Amt2) then
          exit(Amt1);
        exit(Amt2)
    end;

    local procedure GetAccInfo()
    begin
        if "Account No." = '' then
          exit;

        case "Account Type" of
          "Account Type"::Customer:
            GetCustInfo;
          "Account Type"::Vendor:
            GetVendInfo;
          "Account Type"::"Bank Account":
            GetBankAccInfo;
          "Account Type"::"G/L Account":
            GetGLAccInfo;
        end;
    end;

    local procedure GetCustInfo()
    var
        Cust: Record Customer;
    begin
        Cust.Get("Account No.");
        Description := Cust.Name;
    end;

    local procedure GetVendInfo()
    var
        Vend: Record Vendor;
    begin
        Vend.Get("Account No.");
        Description := Vend.Name;
    end;

    local procedure GetBankAccInfo()
    var
        BankAcc: Record "Bank Account";
    begin
        BankAcc.Get("Account No.");
        Description := BankAcc.Name;
        "Currency Code" := BankAcc."Currency Code";
    end;

    local procedure GetGLAccInfo()
    var
        GLAcc: Record "G/L Account";
    begin
        GLAcc.Get("Account No.");
        Description := GLAcc.Name;
    end;

    [Scope('Personalization')]
    procedure GetLedgEntryInfo()
    begin
        if "Applies-to Entry No." = 0 then
          exit;

        case "Account Type" of
          "Account Type"::Customer:
            GetCustLedgEntryInfo;
          "Account Type"::Vendor:
            GetVendLedgEntryInfo;
          "Account Type"::"Bank Account":
            GetBankAccLedgEntryInfo;
        end;
    end;

    local procedure GetCustLedgEntryInfo()
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgEntry.Get("Applies-to Entry No.");
        Description := CustLedgEntry.Description;
        "Posting Date" := CustLedgEntry."Posting Date";
        "Due Date" := CustLedgEntry."Due Date";
        "Document Type" := CustLedgEntry."Document Type";
        "Document No." := CustLedgEntry."Document No.";
        "External Document No." := CustLedgEntry."External Document No.";
        "Currency Code" := CustLedgEntry."Currency Code";
    end;

    local procedure GetVendLedgEntryInfo()
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgEntry.Get("Applies-to Entry No.");
        Description := VendLedgEntry.Description;
        "Posting Date" := VendLedgEntry."Posting Date";
        "Due Date" := VendLedgEntry."Due Date";
        "Document Type" := VendLedgEntry."Document Type";
        "Document No." := VendLedgEntry."Document No.";
        "External Document No." := VendLedgEntry."External Document No.";
        "Currency Code" := VendLedgEntry."Currency Code";
    end;

    local procedure GetBankAccLedgEntryInfo()
    var
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
    begin
        BankAccLedgEntry.Get("Applies-to Entry No.");
        Description := BankAccLedgEntry.Description;
        "Posting Date" := BankAccLedgEntry."Posting Date";
        "Due Date" := 0D;
        "Document Type" := BankAccLedgEntry."Document Type";
        "Document No." := BankAccLedgEntry."Document No.";
        "External Document No." := BankAccLedgEntry."External Document No.";
        "Currency Code" := BankAccLedgEntry."Currency Code";
    end;

    [Scope('Personalization')]
    procedure GetAmtAppliedToOtherStmtLines(): Decimal
    var
        AppliedPmtEntry: Record "Applied Payment Entry";
    begin
        if "Applies-to Entry No." = 0 then
          exit(0);

        AppliedPmtEntry := Rec;
        AppliedPmtEntry.FilterEntryAppliedToOtherStmtLines;
        AppliedPmtEntry.CalcSums("Applied Amount");
        exit(AppliedPmtEntry."Applied Amount");
    end;

    [Scope('Personalization')]
    procedure FilterEntryAppliedToOtherStmtLines()
    begin
        Reset;
        SetRange("Statement Type","Statement Type");
        SetRange("Bank Account No.","Bank Account No.");
        SetRange("Statement No.","Statement No.");
        SetFilter("Statement Line No.",'<>%1',"Statement Line No.");
        SetRange("Account Type","Account Type");
        SetRange("Account No.","Account No.");
        SetRange("Applies-to Entry No.","Applies-to Entry No.");
    end;

    [Scope('Personalization')]
    procedure FilterAppliedPmtEntry(BankAccReconLine: Record "Bank Acc. Reconciliation Line")
    begin
        Reset;
        SetRange("Statement Type",BankAccReconLine."Statement Type");
        SetRange("Bank Account No.",BankAccReconLine."Bank Account No.");
        SetRange("Statement No.",BankAccReconLine."Statement No.");
        SetRange("Statement Line No.",BankAccReconLine."Statement Line No.");
    end;

    [Scope('Personalization')]
    procedure AppliedPmtEntryLinesExist(BankAccReconLine: Record "Bank Acc. Reconciliation Line"): Boolean
    begin
        FilterAppliedPmtEntry(BankAccReconLine);
        exit(FindSet);
    end;

    [Scope('Personalization')]
    procedure TransferFromBankAccReconLine(BankAccReconLine: Record "Bank Acc. Reconciliation Line")
    begin
        "Statement Type" := BankAccReconLine."Statement Type";
        "Bank Account No." := BankAccReconLine."Bank Account No.";
        "Statement No." := BankAccReconLine."Statement No.";
        "Statement Line No." := BankAccReconLine."Statement Line No.";
    end;

    [Scope('Personalization')]
    procedure ApplyFromBankStmtMatchingBuf(BankAccReconLine: Record "Bank Acc. Reconciliation Line";BankStmtMatchingBuffer: Record "Bank Statement Matching Buffer";TextMapperAmount: Decimal;EntryNo: Integer)
    var
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
    begin
        Init;
        TransferFromBankAccReconLine(BankAccReconLine);
        Validate("Account Type",BankStmtMatchingBuffer."Account Type");
        Validate("Account No.",BankStmtMatchingBuffer."Account No.");
        if (EntryNo < 0) and (not BankStmtMatchingBuffer."One to Many Match") then begin // text mapper
          Validate("Applies-to Entry No.",0);
          Validate("Applied Amount",TextMapperAmount);
        end else
          Validate("Applies-to Entry No.",EntryNo);
        Validate(Quality,BankStmtMatchingBuffer.Quality);
        Validate("Match Confidence",BankPmtApplRule.GetMatchConfidence(BankStmtMatchingBuffer.Quality));
        Insert(true);
    end;

    local procedure InclPmtDisc(UseAppliedAmt: Boolean): Boolean
    var
        BankAccReconLine: Record "Bank Acc. Reconciliation Line";
        PaymentToleranceManagement: Codeunit "Payment Tolerance Management";
        UsePmtDisc: Boolean;
        AmtApplied: Decimal;
        PmtDiscDueDate: Date;
        PmtDiscToleranceDate: Date;
        RemPmtDiscPossible: Decimal;
    begin
        GetDiscInfo(PmtDiscDueDate,PmtDiscToleranceDate,RemPmtDiscPossible);
        if not ("Document Type" in ["Document Type"::"Credit Memo","Document Type"::Invoice]) then
          exit(false);
        BankAccReconLine.Get("Statement Type","Bank Account No.","Statement No.","Statement Line No.");
        if (BankAccReconLine."Account Type" = 0) or (BankAccReconLine."Account No." = '') then begin
          BankAccReconLine."Account Type" := "Account Type";
          BankAccReconLine."Account No." := "Account No.";
        end;
        UsePmtDisc := (BankAccReconLine."Transaction Date" <= PmtDiscDueDate) and (RemPmtDiscPossible <> 0);
        if UseAppliedAmt then
          PaymentToleranceManagement.PmtTolPmtReconJnl(BankAccReconLine);
        if (not UsePmtDisc) and (not IsAcceptedPmtDiscTolerance) then
          exit(false);

        if UseAppliedAmt then
          AmtApplied := "Applied Amount" + GetAmtAppliedToOtherStmtLines
        else
          AmtApplied := BankAccReconLine.Difference + GetOldAppliedAmtInclDisc + GetAmtAppliedToOtherStmtLines;

        exit(Abs(AmtApplied) >= Abs(GetRemAmt - RemPmtDiscPossible - GetAcceptedPmtTolerance));
    end;

    [Scope('Personalization')]
    procedure GetTotalAppliedAmountInclPmtDisc(IsDelete: Boolean): Decimal
    var
        AppliedPaymentEntry: Record "Applied Payment Entry";
        TotalAmountIncludingPmtDisc: Decimal;
    begin
        AppliedPaymentEntry.SetRange("Statement Type","Statement Type");
        AppliedPaymentEntry.SetRange("Statement No.","Statement No.");
        AppliedPaymentEntry.SetRange("Statement Line No.","Statement Line No.");
        AppliedPaymentEntry.SetRange("Bank Account No.","Bank Account No.");
        AppliedPaymentEntry.SetRange("Account Type","Account Type");
        AppliedPaymentEntry.SetRange("Account No.","Account No.");
        AppliedPaymentEntry.SetFilter("Applies-to Entry No.",'<>%1',"Applies-to Entry No.");

        if IsDelete then
          TotalAmountIncludingPmtDisc := 0
        else
          TotalAmountIncludingPmtDisc := "Applied Amount" - "Applied Pmt. Discount";

        if AppliedPaymentEntry.FindSet then
          repeat
            TotalAmountIncludingPmtDisc += AppliedPaymentEntry."Applied Amount";
            TotalAmountIncludingPmtDisc -= AppliedPaymentEntry."Applied Pmt. Discount";
          until AppliedPaymentEntry.Next = 0;

        exit(TotalAmountIncludingPmtDisc);
    end;

    local procedure GetNoOfAppliedEntries(IsDelete: Boolean): Decimal
    var
        AppliedPaymentEntry: Record "Applied Payment Entry";
    begin
        AppliedPaymentEntry.SetRange("Statement Type","Statement Type");
        AppliedPaymentEntry.SetRange("Statement No.","Statement No.");
        AppliedPaymentEntry.SetRange("Statement Line No.","Statement Line No.");
        AppliedPaymentEntry.SetRange("Bank Account No.","Bank Account No.");
        AppliedPaymentEntry.SetRange("Account Type","Account Type");
        AppliedPaymentEntry.SetRange("Account No.","Account No.");
        AppliedPaymentEntry.SetFilter("Applies-to Entry No.",'<>%1',"Applies-to Entry No.");

        if IsDelete then
          exit(AppliedPaymentEntry.Count);

        exit(AppliedPaymentEntry.Count + 1);
    end;

    [Scope('Personalization')]
    procedure UpdatePaymentDiscount(PaymentDiscountAmount: Decimal)
    var
        AppliedPaymentEntry: Record "Applied Payment Entry";
    begin
        // Payment discount must go to last entry only because of posting
        AppliedPaymentEntry.SetRange("Statement Type","Statement Type");
        AppliedPaymentEntry.SetRange("Bank Account No.","Bank Account No.");
        AppliedPaymentEntry.SetRange("Statement No.","Statement No.");
        AppliedPaymentEntry.SetRange("Account Type","Account Type");
        AppliedPaymentEntry.SetRange("Applies-to Entry No.","Applies-to Entry No.");
        AppliedPaymentEntry.SetFilter("Applied Pmt. Discount",'<>0');

        if AppliedPaymentEntry.FindFirst then
          AppliedPaymentEntry.RemovePaymentDiscount;

        if PaymentDiscountAmount = 0 then
          exit;

        AppliedPaymentEntry.SetRange("Applied Pmt. Discount");

        if AppliedPaymentEntry.FindLast then
          if "Statement Line No." < AppliedPaymentEntry."Statement Line No." then begin
            AppliedPaymentEntry.SetPaymentDiscount(PaymentDiscountAmount,true);
            exit;
          end;

        SetPaymentDiscount(PaymentDiscountAmount,false);
    end;

    [Scope('Personalization')]
    procedure SetPaymentDiscount(PaymentDiscountAmount: Decimal;DifferentLineThanCurrent: Boolean)
    begin
        Validate("Applied Pmt. Discount",PaymentDiscountAmount);

        if DifferentLineThanCurrent then begin
          "Applied Amount" += "Applied Pmt. Discount";
          Modify(true);
        end;
    end;

    [Scope('Personalization')]
    procedure RemovePaymentDiscount()
    begin
        "Applied Amount" := "Applied Amount" - "Applied Pmt. Discount";
        "Applied Pmt. Discount" := 0;
        Modify(true);
    end;

    local procedure ClearCustVendEntryApplicationData()
    begin
        if "Applies-to Entry No." = 0 then
          exit;

        case "Account Type" of
          "Account Type"::Customer:
            ClearCustApplicationData("Applies-to Entry No.");
          "Account Type"::Vendor:
            ClearVendApplicationData("Applies-to Entry No.");
        end;
    end;

    local procedure ClearCustApplicationData(EntryNo: Integer)
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgEntry.Get(EntryNo);
        CustLedgEntry."Accepted Pmt. Disc. Tolerance" := false;
        CustLedgEntry."Accepted Payment Tolerance" := 0;
        CustLedgEntry."Amount to Apply" := 0;
        CustLedgEntry."Applies-to ID" := '';
        CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit",CustLedgEntry);
    end;

    local procedure ClearVendApplicationData(EntryNo: Integer)
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgEntry.Get(EntryNo);
        VendLedgEntry."Accepted Pmt. Disc. Tolerance" := false;
        VendLedgEntry."Accepted Payment Tolerance" := 0;
        VendLedgEntry."Amount to Apply" := 0;
        VendLedgEntry."Applies-to ID" := '';
        CODEUNIT.Run(CODEUNIT::"Vend. Entry-Edit",VendLedgEntry);
    end;

    [Scope('Personalization')]
    procedure CalcAmountToApply(PostingDate: Date) AmountToApply: Decimal
    var
        BankAccount: Record "Bank Account";
        CurrExchRate: Record "Currency Exchange Rate";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        RemainingAmount: Decimal;
    begin
        BankAccount.Get("Bank Account No.");
        if BankAccount.IsInLocalCurrency then begin
          AmountToApply :=
            CurrExchRate.ExchangeAmount("Applied Amount",'',"Currency Code",PostingDate);
          case "Account Type" of
            "Account Type"::Customer:
              begin
                CustLedgerEntry.Get("Applies-to Entry No.");
                CustLedgerEntry.CalcFields("Remaining Amount");
                RemainingAmount := CustLedgerEntry."Remaining Amount";
              end;
            "Account Type"::Vendor:
              begin
                VendorLedgerEntry.Get("Applies-to Entry No.");
                VendorLedgerEntry.CalcFields("Remaining Amount");
                RemainingAmount := VendorLedgerEntry."Remaining Amount";
              end;
          end;
          if Abs(AmountToApply) > Abs(RemainingAmount) then
            AmountToApply := RemainingAmount;
        end else
          exit("Applied Amount");
        exit(AmountToApply);
    end;
}

