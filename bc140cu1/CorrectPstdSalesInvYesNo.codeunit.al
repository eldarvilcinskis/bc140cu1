codeunit 1322 "Correct PstdSalesInv (Yes/No)"
{
    Permissions = TableData "Sales Invoice Header" = rm,
                  TableData "Sales Cr.Memo Header" = rm;
    TableNo = "Sales Invoice Header";

    trigger OnRun()
    begin
        CorrectInvoice(Rec);
    end;

    var
        CorrectPostedInvoiceQst: Label 'The posted sales invoice will be canceled, and a new version of the sales invoice will be created so that you can make the correction.\ \Do you want to continue?';

    [Scope('Internal')]
    procedure CorrectInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        SalesHeader: Record "Sales Header";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
    begin
        CorrectPostedSalesInvoice.TestCorrectInvoiceIsAllowed(SalesInvoiceHeader, false);
        if Confirm(CorrectPostedInvoiceQst) then begin
            CorrectPostedSalesInvoice.CancelPostedInvoiceStartNewInvoice(SalesInvoiceHeader, SalesHeader);
            PAGE.Run(PAGE::"Sales Invoice", SalesHeader);
            exit(true);
        end;

        exit(false);
    end;
}

