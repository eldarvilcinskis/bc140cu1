codeunit 1325 "Cancel PstdPurchInv (Yes/No)"
{
    Permissions = TableData "Purch. Inv. Header" = rm,
                  TableData "Purch. Cr. Memo Hdr." = rm;
    TableNo = "Purch. Inv. Header";

    trigger OnRun()
    begin
        CancelInvoice(Rec);
    end;

    var
        CancelPostedInvoiceQst: Label 'The posted purchase invoice will be canceled, and a purchase credit memo will be created and posted, which reverses the posted purchase invoice.\ \Do you want to continue?';
        OpenPostedCreditMemoQst: Label 'A credit memo was successfully created. Do you want to open the posted credit memo?';

    [Scope('Personalization')]
    procedure CancelInvoice(var PurchInvHeader: Record "Purch. Inv. Header"): Boolean
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        CancelledDocument: Record "Cancelled Document";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
    begin
        CorrectPostedPurchInvoice.TestCorrectInvoiceIsAllowed(PurchInvHeader, true);
        if Confirm(CancelPostedInvoiceQst) then
            if CorrectPostedPurchInvoice.CancelPostedInvoice(PurchInvHeader) then
                if Confirm(OpenPostedCreditMemoQst) then begin
                    CancelledDocument.FindPurchCancelledInvoice(PurchInvHeader."No.");
                    PurchCrMemoHdr.Get(CancelledDocument."Cancelled By Doc. No.");
                    PAGE.Run(PAGE::"Posted Purchase Credit Memo", PurchCrMemoHdr);
                    exit(true);
                end;

        exit(false);
    end;
}

