codeunit 93 "Purch.-Quote to Order (Yes/No)"
{
    TableNo = "Purchase Header";

    trigger OnRun()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        IsHandled: Boolean;
    begin
        TestField("Document Type","Document Type"::Quote);
        if not ConfirmManagement.ConfirmProcess(Text000,true) then
          exit;

        IsHandled := false;
        OnBeforePurchQuoteToOrder(Rec,IsHandled);
        if IsHandled then
          exit;

        PurchQuoteToOrder.Run(Rec);
        PurchQuoteToOrder.GetPurchOrderHeader(PurchOrderHeader);

        Message(Text001,"No.",PurchOrderHeader."No.");
    end;

    var
        Text000: Label 'Do you want to convert the quote to an order?';
        Text001: Label 'Quote number %1 has been converted to order number %2.';
        PurchOrderHeader: Record "Purchase Header";
        PurchQuoteToOrder: Codeunit "Purch.-Quote to Order";

    [IntegrationEvent(false, false)]
    local procedure OnBeforePurchQuoteToOrder(var PurchaseHeader: Record "Purchase Header";var IsHandled: Boolean)
    begin
    end;
}

