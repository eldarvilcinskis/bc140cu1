page 1401 "Sales No. Series Setup"
{
    Caption = 'Sales No. Series Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SourceTable = "Sales & Receivables Setup";

    layout
    {
        area(content)
        {
            group(Numbering)
            {
                Caption = 'Numbering';
                InstructionalText = 'To fill the Document No. field automatically, you must set up a number series.';
                field("Quote Nos."; "Quote Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to sales quotes. To see the number series that have been set up in the No. Series table, click the field.';
                    Visible = QuoteNosVisible;
                }
                field("Blanket Order Nos."; "Blanket Order Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to blanket sales orders. To see the number series that have been set up in the No. Series table, click the field.';
                    Visible = BlanketOrderNosVisible;
                }
                field("Order Nos."; "Order Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to sales orders. To see the number series that have been set up in the No. Series table, click the field.';
                    Visible = OrderNosVisible;
                }
                field("Return Order Nos."; "Return Order Nos.")
                {
                    ApplicationArea = SalesReturnOrder;
                    ToolTip = 'Specifies the number series that is used to assign numbers to new sales return orders.';
                    Visible = ReturnOrderNosVisible;
                }
                field("Invoice Nos."; "Invoice Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to sales invoices. To see the number series that have been set up in the No. Series table, click the field.';
                    Visible = InvoiceNosVisible;
                }
                field("Credit Memo Nos."; "Credit Memo Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to sales credit memos. To see the number series that have been set up in the No. Series table, click the field.';
                    Visible = CrMemoNosVisible;
                }
                field("Reminder Nos."; "Reminder Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to reminders. To see the number series that have been set up in the No. Series table, click the field.';
                    Visible = ReminderNosVisible;
                }
                field("Fin. Chrg. Memo Nos."; "Fin. Chrg. Memo Nos.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to finance charge memos. To see the number series that have been set up in the No. Series table, click the field.';
                    Visible = FinChMemoNosVisible;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Setup)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Sales & Receivables Setup';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Sales & Receivables Setup";
                ToolTip = 'Define your general policies for sales invoicing and returns, such as when to show credit and stockout warnings and how to post sales discounts. Set up your number series for creating customers and different sales documents.';
            }
        }
    }

    var
        QuoteNosVisible: Boolean;
        BlanketOrderNosVisible: Boolean;
        OrderNosVisible: Boolean;
        ReturnOrderNosVisible: Boolean;
        InvoiceNosVisible: Boolean;
        CrMemoNosVisible: Boolean;
        ReminderNosVisible: Boolean;
        FinChMemoNosVisible: Boolean;

    [Scope('Personalization')]
    procedure SetFieldsVisibility(DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",Reminder,FinChMemo)
    begin
        QuoteNosVisible := (DocType = DocType::Quote);
        BlanketOrderNosVisible := (DocType = DocType::"Blanket Order");
        OrderNosVisible := (DocType = DocType::Order);
        ReturnOrderNosVisible := (DocType = DocType::"Return Order");
        InvoiceNosVisible := (DocType = DocType::Invoice);
        CrMemoNosVisible := (DocType = DocType::"Credit Memo");
        ReminderNosVisible := (DocType = DocType::Reminder);
        FinChMemoNosVisible := (DocType = DocType::FinChMemo);
    end;
}

