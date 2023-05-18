codeunit 1311 "Activities Mgt."
{

    trigger OnRun()
    begin
        if IsCueDataStale then
            RefreshActivitiesCueData;
    end;

    var
        DefaultWorkDate: Date;
        RefreshFrequencyErr: Label 'Refresh intervals of less than 10 minutes are not supported.';

    [Scope('Personalization')]
    procedure CalcOverdueSalesInvoiceAmount(CalledFromWebService: Boolean) Amount: Decimal
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        SetFilterForCalcOverdueSalesInvoiceAmount(DetailedCustLedgEntry, CalledFromWebService);
        DetailedCustLedgEntry.CalcSums("Amount (LCY)");
        Amount := Abs(DetailedCustLedgEntry."Amount (LCY)");
    end;

    procedure SetFilterForCalcOverdueSalesInvoiceAmount(var DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; CalledFromWebService: Boolean)
    begin
        DetailedCustLedgEntry.SetRange("Initial Document Type", DetailedCustLedgEntry."Initial Document Type"::Invoice);
        if CalledFromWebService then
            DetailedCustLedgEntry.SetFilter("Initial Entry Due Date", '<%1', Today)
        else
            DetailedCustLedgEntry.SetFilter("Initial Entry Due Date", '<%1', GetDefaultWorkDate);
    end;

    [Scope('Personalization')]
    procedure DrillDownCalcOverdueSalesInvoiceAmount()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetFilter("Due Date", '<%1', GetDefaultWorkDate);
        CustLedgerEntry.SetFilter("Remaining Amt. (LCY)", '<>0');
        CustLedgerEntry.SetCurrentKey("Remaining Amt. (LCY)");
        CustLedgerEntry.Ascending := false;

        PAGE.Run(PAGE::"Customer Ledger Entries", CustLedgerEntry);
    end;

    [Scope('Personalization')]
    procedure CalcOverduePurchaseInvoiceAmount(CalledFromWebService: Boolean) Amount: Decimal
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        SetFilterForCalcOverduePurchaseInvoiceAmount(DetailedVendorLedgEntry, CalledFromWebService);
        DetailedVendorLedgEntry.CalcSums("Amount (LCY)");
        Amount := Abs(DetailedVendorLedgEntry."Amount (LCY)");
    end;

    procedure SetFilterForCalcOverduePurchaseInvoiceAmount(var DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; CalledFromWebService: Boolean)
    begin
        DetailedVendorLedgEntry.SetRange("Initial Document Type", DetailedVendorLedgEntry."Initial Document Type"::Invoice);
        if CalledFromWebService then
            DetailedVendorLedgEntry.SetFilter("Initial Entry Due Date", '<%1', Today)
        else
            DetailedVendorLedgEntry.SetFilter("Initial Entry Due Date", '<%1', GetDefaultWorkDate);
    end;

    [Scope('Personalization')]
    procedure DrillDownOverduePurchaseInvoiceAmount()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetFilter("Due Date", '<%1', WorkDate);
        VendorLedgerEntry.SetFilter("Remaining Amt. (LCY)", '<>0');
        VendorLedgerEntry.SetCurrentKey("Remaining Amt. (LCY)");
        VendorLedgerEntry.Ascending := true;

        PAGE.Run(PAGE::"Vendor Ledger Entries", VendorLedgerEntry);
    end;

    [Scope('Personalization')]
    procedure CalcSalesThisMonthAmount(CalledFromWebService: Boolean) Amount: Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        SetFilterForCalcSalesThisMonthAmount(CustLedgerEntry, CalledFromWebService);
        CustLedgerEntry.CalcSums("Sales (LCY)");
        Amount := CustLedgerEntry."Sales (LCY)";
    end;

    procedure SetFilterForCalcSalesThisMonthAmount(var CustLedgerEntry: Record "Cust. Ledger Entry"; CalledFromWebService: Boolean)
    begin
        CustLedgerEntry.SetFilter("Document Type", '%1|%2',
          CustLedgerEntry."Document Type"::Invoice, CustLedgerEntry."Document Type"::"Credit Memo");
        if CalledFromWebService then
            CustLedgerEntry.SetRange("Posting Date", CalcDate('<-CM>', Today), Today)
        else
            CustLedgerEntry.SetRange("Posting Date", CalcDate('<-CM>', GetDefaultWorkDate), GetDefaultWorkDate);
    end;

    [Scope('Personalization')]
    procedure DrillDownSalesThisMonth()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetFilter("Document Type", '%1|%2',
          CustLedgerEntry."Document Type"::Invoice, CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Posting Date", CalcDate('<-CM>', GetDefaultWorkDate), GetDefaultWorkDate);
        PAGE.Run(PAGE::"Customer Ledger Entries", CustLedgerEntry);
    end;

    [Scope('Personalization')]
    procedure CalcSalesYTD() Amount: Decimal
    var
        AccountingPeriod: Record "Accounting Period";
        [SecurityFiltering(SecurityFilter::Filtered)]
        CustLedgEntrySales: Query "Cust. Ledg. Entry Sales";
    begin
        CustLedgEntrySales.SetRange(Posting_Date, AccountingPeriod.GetFiscalYearStartDate(GetDefaultWorkDate), GetDefaultWorkDate);
        CustLedgEntrySales.Open;

        if CustLedgEntrySales.Read then
            Amount := CustLedgEntrySales.Sum_Sales_LCY;
    end;

    [Scope('Personalization')]
    procedure CalcTop10CustomerSalesYTD() Amount: Decimal
    var
        AccountingPeriod: Record "Accounting Period";
        Top10CustomerSales: Query "Top 10 Customer Sales";
    begin
        // Total Sales (LCY) by top 10 list of customers year-to-date.
        Top10CustomerSales.SetRange(Posting_Date, AccountingPeriod.GetFiscalYearStartDate(GetDefaultWorkDate), GetDefaultWorkDate);
        Top10CustomerSales.Open;

        while Top10CustomerSales.Read do
            Amount += Top10CustomerSales.Sum_Sales_LCY;
    end;

    [Scope('Personalization')]
    procedure CalcTop10CustomerSalesRatioYTD() Amount: Decimal
    var
        TotalSales: Decimal;
    begin
        // Ratio of Sales by top 10 list of customers year-to-date.
        TotalSales := CalcSalesYTD;
        if TotalSales <> 0 then
            Amount := CalcTop10CustomerSalesYTD / TotalSales;
    end;

    [Scope('Personalization')]
    procedure CalcAverageCollectionDays() AverageDays: Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SumCollectionDays: Integer;
        CountInvoices: Integer;
    begin
        GetPaidSalesInvoices(CustLedgerEntry);
        if CustLedgerEntry.FindSet then begin
            repeat
                SumCollectionDays += (CustLedgerEntry."Closed at Date" - CustLedgerEntry."Posting Date");
                CountInvoices += 1;
            until CustLedgerEntry.Next = 0;

            AverageDays := SumCollectionDays / CountInvoices;
        end
    end;

    local procedure GetPaidSalesInvoices(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange(Open, false);
        CustLedgerEntry.SetRange("Posting Date", CalcDate('<CM-3M>', GetDefaultWorkDate), GetDefaultWorkDate);
        CustLedgerEntry.SetRange("Closed at Date", CalcDate('<CM-3M>', GetDefaultWorkDate), GetDefaultWorkDate);
    end;

    [Scope('Personalization')]
    procedure CalcCashAccountsBalances() CashAccountBalance: Decimal
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetRange("Account Category", GLAccount."Account Category"::Assets);
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Account Subcategory Entry No.", 3);
        if GLAccount.FindSet then begin
            repeat
                GLAccount.CalcFields(Balance);
                CashAccountBalance += GLAccount.Balance;
            until GLAccount.Next = 0;
        end;
    end;

    [Scope('Personalization')]
    procedure DrillDownCalcCashAccountsBalances()
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetRange("Account Category", GLAccount."Account Category"::Assets);
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Account Subcategory Entry No.", 3);
        PAGE.Run(PAGE::"Chart of Accounts", GLAccount);
    end;

    local procedure RefreshActivitiesCueData()
    var
        ActivitiesCue: Record "Activities Cue";
    begin
        ActivitiesCue.LockTable;

        ActivitiesCue.Get;

        if not IsPassedCueDataStale(ActivitiesCue) then
            exit;

        ActivitiesCue.SetFilter("Due Date Filter", '>=%1', GetDefaultWorkDate);
        ActivitiesCue.SetFilter("Overdue Date Filter", '<%1', GetDefaultWorkDate);
        ActivitiesCue.SetFilter("Due Next Week Filter", '%1..%2', CalcDate('<1D>', GetDefaultWorkDate), CalcDate('<1W>', GetDefaultWorkDate));

        if ActivitiesCue.FieldActive("Overdue Sales Invoice Amount") then
            ActivitiesCue."Overdue Sales Invoice Amount" := CalcOverdueSalesInvoiceAmount(false);

        if ActivitiesCue.FieldActive("Overdue Purch. Invoice Amount") then
            ActivitiesCue."Overdue Purch. Invoice Amount" := CalcOverduePurchaseInvoiceAmount(false);

        if ActivitiesCue.FieldActive("Sales This Month") then
            ActivitiesCue."Sales This Month" := CalcSalesThisMonthAmount(false);

        if ActivitiesCue.FieldActive("Average Collection Days") then
            ActivitiesCue."Average Collection Days" := CalcAverageCollectionDays;

        ActivitiesCue."Last Date/Time Modified" := CurrentDateTime;
        ActivitiesCue.Modify;
        Commit;
    end;

    procedure IsCueDataStale(): Boolean
    var
        ActivitiesCue: Record "Activities Cue";
    begin
        if not ActivitiesCue.Get then
            exit(false);

        exit(IsPassedCueDataStale(ActivitiesCue));
    end;

    local procedure IsPassedCueDataStale(ActivitiesCue: Record "Activities Cue"): Boolean
    begin
        if ActivitiesCue."Last Date/Time Modified" = 0DT then
            exit(true);

        exit(CurrentDateTime - ActivitiesCue."Last Date/Time Modified" >= GetActivitiesCueRefreshInterval)
    end;

    local procedure GetDefaultWorkDate(): Date
    var
        LogInManagement: Codeunit LogInManagement;
    begin
        if DefaultWorkDate = 0D then
            DefaultWorkDate := LogInManagement.GetDefaultWorkDate;
        exit(DefaultWorkDate);
    end;

    local procedure GetActivitiesCueRefreshInterval() Interval: Duration
    var
        MinInterval: Duration;
    begin
        MinInterval := 10 * 60 * 1000; // 10 minutes
        Interval := 60 * 60 * 1000; // 1 hr
        OnGetRefreshInterval(Interval);
        if Interval < MinInterval then
            Error(RefreshFrequencyErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetRefreshInterval(var Interval: Duration)
    begin
    end;
}

