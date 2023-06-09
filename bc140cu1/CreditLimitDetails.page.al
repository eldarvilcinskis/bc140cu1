page 1871 "Credit Limit Details"
{
    Caption = 'Details';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            field("No."; "No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
            }
            field(Name; Name)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the customer''s name.';
            }
            field("Balance (LCY)"; "Balance (LCY)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the payment amount that the customer owes for completed sales. This value is also known as the customer''s balance.';

                trigger OnDrillDown()
                begin
                    OpenCustomerLedgerEntries(false);
                end;
            }
            field(OutstandingAmtLCY; OrderAmountTotalLCY)
            {
                ApplicationArea = Basic, Suite;
                AutoFormatType = 1;
                Caption = 'Outstanding Amt. (LCY)';
                Editable = false;
                ToolTip = 'Specifies the amount on sales to the customer that remains to be shipped. The amount is calculated as Amount x Outstanding Quantity / Quantity.';
            }
            field(ShippedRetRcdNotIndLCY; ShippedRetRcdNotIndLCY)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Shipped/Ret. Rcd. Not Invd. (LCY)';
                Editable = false;
                ToolTip = 'Specifies the amount on sales returns from the customer that are not yet refunded';
            }
            field(OrderAmountThisOrderLCY; OrderAmountThisOrderLCY)
            {
                ApplicationArea = Basic, Suite;
                AutoFormatType = 1;
                Caption = 'Current Amount (LCY)';
                Editable = false;
                ToolTip = 'Specifies the total amount the whole sales document.';
            }
            field(TotalAmountLCY; CustCreditAmountLCY)
            {
                ApplicationArea = Basic, Suite;
                AutoFormatType = 1;
                Caption = 'Total Amount (LCY)';
                Editable = false;
                ToolTip = 'Specifies the sum of the amounts in all of the preceding fields in the window.';
            }
            field("Credit Limit (LCY)"; "Credit Limit (LCY)")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the maximum amount you allow the customer to exceed the payment balance before warnings are issued.';
            }
            field(OverdueBalance; CalcOverdueBalance)
            {
                ApplicationArea = Basic, Suite;
                CaptionClass = Format(StrSubstNo(OverdueAmountsTxt, Format(GetRangeMax("Date Filter"))));
                Editable = false;
                ToolTip = 'Specifies payments from the customer that are overdue per today''s date.';

                trigger OnDrillDown()
                var
                    DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
                    CustLedgEntry: Record "Cust. Ledger Entry";
                begin
                    DtldCustLedgEntry.SetFilter("Customer No.", "No.");
                    CopyFilter("Global Dimension 1 Filter", DtldCustLedgEntry."Initial Entry Global Dim. 1");
                    CopyFilter("Global Dimension 2 Filter", DtldCustLedgEntry."Initial Entry Global Dim. 2");
                    CopyFilter("Currency Filter", DtldCustLedgEntry."Currency Code");
                    CustLedgEntry.DrillDownOnOverdueEntries(DtldCustLedgEntry);
                end;
            }
            field(GetInvoicedPrepmtAmountLCY; GetInvoicedPrepmtAmountLCY)
            {
                ApplicationArea = Prepayments;
                Caption = 'Invoiced Prepayment Amount (LCY)';
                Editable = false;
                ToolTip = 'Specifies your sales income from the customer based on invoiced prepayments.';
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if GetFilter("Date Filter") = '' then
            SetFilter("Date Filter", '..%1', WorkDate);
        CalcFields("Balance (LCY)", "Shipped Not Invoiced (LCY)", "Serv Shipped Not Invoiced(LCY)");
    end;

    var
        OrderAmountTotalLCY: Decimal;
        ShippedRetRcdNotIndLCY: Decimal;
        OrderAmountThisOrderLCY: Decimal;
        CustCreditAmountLCY: Decimal;
        OverdueAmountsTxt: Label 'Overdue Amounts (LCY) as of %1', Comment = '%1=Date on which the amounts arebeing calculated.';

    [Scope('Personalization')]
    procedure PopulateDataOnNotification(var CreditLimitNotification: Notification)
    begin
        CreditLimitNotification.SetData(FieldName("No."), Format("No."));
        CreditLimitNotification.SetData('OrderAmountTotalLCY', Format(OrderAmountTotalLCY));
        CreditLimitNotification.SetData('ShippedRetRcdNotIndLCY', Format(ShippedRetRcdNotIndLCY));
        CreditLimitNotification.SetData('OrderAmountThisOrderLCY', Format(OrderAmountThisOrderLCY));
        CreditLimitNotification.SetData('CustCreditAmountLCY', Format(CustCreditAmountLCY));
    end;

    [Scope('Personalization')]
    procedure InitializeFromNotificationVar(CreditLimitNotification: Notification)
    var
        Customer: Record Customer;
    begin
        Get(CreditLimitNotification.GetData(Customer.FieldName("No.")));
        SetRange("No.", "No.");

        if GetFilter("Date Filter") = '' then
            SetFilter("Date Filter", '..%1', WorkDate);
        CalcFields("Balance (LCY)", "Shipped Not Invoiced (LCY)", "Serv Shipped Not Invoiced(LCY)");

        Evaluate(OrderAmountTotalLCY, CreditLimitNotification.GetData('OrderAmountTotalLCY'));
        Evaluate(ShippedRetRcdNotIndLCY, CreditLimitNotification.GetData('ShippedRetRcdNotIndLCY'));
        Evaluate(OrderAmountThisOrderLCY, CreditLimitNotification.GetData('OrderAmountThisOrderLCY'));
        Evaluate(CustCreditAmountLCY, CreditLimitNotification.GetData('CustCreditAmountLCY'));
    end;

    [Scope('Personalization')]
    procedure SetCustomerNumber(Value: Code[20])
    begin
        Get(Value);
    end;

    [Scope('Personalization')]
    procedure SetOrderAmountTotalLCY(Value: Decimal)
    begin
        OrderAmountTotalLCY := Value;
    end;

    [Scope('Personalization')]
    procedure SetShippedRetRcdNotIndLCY(Value: Decimal)
    begin
        ShippedRetRcdNotIndLCY := Value;
    end;

    [Scope('Personalization')]
    procedure SetOrderAmountThisOrderLCY(Value: Decimal)
    begin
        OrderAmountThisOrderLCY := Value;
    end;

    [Scope('Personalization')]
    procedure SetCustCreditAmountLCY(Value: Decimal)
    begin
        CustCreditAmountLCY := Value;
    end;
}

