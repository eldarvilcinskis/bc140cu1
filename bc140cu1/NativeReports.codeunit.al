codeunit 2822 "Native - Reports"
{

    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure PostedSalesInvoiceReportId(): Integer
    var
        TempReportSelections: Record "Report Selections" temporary;
    begin
        exit(TempReportSelections.Usage::"S.Invoice");
    end;

    [Scope('Personalization')]
    procedure DraftSalesInvoiceReportId(): Integer
    var
        TempReportSelections: Record "Report Selections" temporary;
    begin
        exit(TempReportSelections.Usage::"S.Invoice Draft");
    end;

    [Scope('Personalization')]
    procedure SalesQuoteReportId(): Integer
    var
        TempReportSelections: Record "Report Selections" temporary;
    begin
        exit(TempReportSelections.Usage::"S.Quote");
    end;

    [Scope('Personalization')]
    procedure SalesCreditMemoReportId(): Integer
    var
        TempReportSelections: Record "Report Selections" temporary;
    begin
        exit(TempReportSelections.Usage::"S.Cr.Memo");
    end;

    [Scope('Personalization')]
    procedure PurchaseInvoiceReportId(): Integer
    var
        TempReportSelections: Record "Report Selections" temporary;
    begin
        exit(TempReportSelections.Usage::"P.Invoice");
    end;
}

