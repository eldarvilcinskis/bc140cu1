codeunit 82 "Sales-Post + Print"
{
    TableNo = "Sales Header";

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Copy(Rec);
        Code(SalesHeader);
        Rec := SalesHeader;
    end;

    var
        ShipInvoiceQst: Label '&Ship,&Invoice,Ship &and Invoice';
        PostAndPrintQst: Label 'Do you want to post and print the %1?', Comment = '%1 = Document Type';
        PostAndEmailQst: Label 'Do you want to post and email the %1?', Comment = '%1 = Document Type';
        ReceiveInvoiceQst: Label '&Receive,&Invoice,Receive &and Invoice';
        SendReportAsEmail: Boolean;

    [Scope('Internal')]
    procedure PostAndEmail(var ParmSalesHeader: Record "Sales Header")
    var
        SalesHeader: Record "Sales Header";
    begin
        SendReportAsEmail := true;
        SalesHeader.Copy(ParmSalesHeader);
        Code(SalesHeader);
        ParmSalesHeader := SalesHeader;
    end;

    local procedure "Code"(var SalesHeader: Record "Sales Header")
    var
        SalesSetup: Record "Sales & Receivables Setup";
        SalesPostViaJobQueue: Codeunit "Sales Post via Job Queue";
        HideDialog: Boolean;
        IsHandled: Boolean;
        DefaultOption: Integer;
    begin
        HideDialog := false;
        IsHandled := false;
        DefaultOption := 3;
        OnBeforeConfirmPost(SalesHeader, HideDialog, IsHandled, SendReportAsEmail, DefaultOption);
        if IsHandled then
            exit;

        if not HideDialog then
            if not ConfirmPost(SalesHeader, DefaultOption) then
                exit;

        OnAfterConfirmPost(SalesHeader);

        SalesSetup.Get;
        if SalesSetup."Post & Print with Job Queue" and not SendReportAsEmail then
            SalesPostViaJobQueue.EnqueueSalesDoc(SalesHeader)
        else begin
            CODEUNIT.Run(CODEUNIT::"Sales-Post", SalesHeader);
            GetReport(SalesHeader);
        end;

        OnAfterPost(SalesHeader);
        Commit;
    end;

    [Scope('Personalization')]
    procedure GetReport(var SalesHeader: Record "Sales Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetReport(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        with SalesHeader do
            case "Document Type" of
                "Document Type"::Order:
                    begin
                        if Ship then
                            PrintShip(SalesHeader);
                        if Invoice then
                            PrintInvoice(SalesHeader);
                    end;
                "Document Type"::Invoice:
                    PrintInvoice(SalesHeader);
                "Document Type"::"Return Order":
                    begin
                        if Receive then
                            PrintReceive(SalesHeader);
                        if Invoice then
                            PrintCrMemo(SalesHeader);
                    end;
                "Document Type"::"Credit Memo":
                    PrintCrMemo(SalesHeader);
            end;
    end;

    local procedure ConfirmPost(var SalesHeader: Record "Sales Header"; DefaultOption: Integer): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
        Selection: Integer;
    begin
        if DefaultOption > 3 then
            DefaultOption := 3;
        if DefaultOption <= 0 then
            DefaultOption := 1;

        with SalesHeader do begin
            case "Document Type" of
                "Document Type"::Order:
                    begin
                        Selection := StrMenu(ShipInvoiceQst, DefaultOption);
                        if Selection = 0 then
                            exit(false);
                        Ship := Selection in [1, 3];
                        Invoice := Selection in [2, 3];
                    end;
                "Document Type"::"Return Order":
                    begin
                        Selection := StrMenu(ReceiveInvoiceQst, DefaultOption);
                        if Selection = 0 then
                            exit(false);
                        Receive := Selection in [1, 3];
                        Invoice := Selection in [2, 3];
                    end
                else
                    if not ConfirmManagement.ConfirmProcess(
                         StrSubstNo(ConfirmationMessage, "Document Type"), true)
                    then
                        exit(false);
            end;
            "Print Posted Documents" := true;
        end;
        exit(true);
    end;

    local procedure ConfirmationMessage(): Text
    begin
        if SendReportAsEmail then
            exit(PostAndEmailQst);
        exit(PostAndPrintQst);
    end;

    local procedure PrintReceive(SalesHeader: Record "Sales Header")
    var
        ReturnRcptHeader: Record "Return Receipt Header";
    begin
        ReturnRcptHeader."No." := SalesHeader."Last Return Receipt No.";
        if ReturnRcptHeader.Find then;
        ReturnRcptHeader.SetRecFilter;

        if SendReportAsEmail then
            ReturnRcptHeader.EmailRecords(true)
        else
            ReturnRcptHeader.PrintRecords(false);
    end;

    local procedure PrintInvoice(SalesHeader: Record "Sales Header")
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if SalesHeader."Last Posting No." = '' then
            SalesInvHeader."No." := SalesHeader."No."
        else
            SalesInvHeader."No." := SalesHeader."Last Posting No.";
        SalesInvHeader.Find;
        SalesInvHeader.SetRecFilter;

        if SendReportAsEmail then
            SalesInvHeader.EmailRecords(true)
        else
            SalesInvHeader.PrintRecords(false);
    end;

    local procedure PrintShip(SalesHeader: Record "Sales Header")
    var
        SalesShptHeader: Record "Sales Shipment Header";
    begin
        SalesShptHeader."No." := SalesHeader."Last Shipping No.";
        if SalesShptHeader.Find then;
        SalesShptHeader.SetRecFilter;

        if SendReportAsEmail then
            SalesShptHeader.EmailRecords(true)
        else
            SalesShptHeader.PrintRecords(false);
    end;

    local procedure PrintCrMemo(SalesHeader: Record "Sales Header")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if SalesHeader."Last Posting No." = '' then
            SalesCrMemoHeader."No." := SalesHeader."No."
        else
            SalesCrMemoHeader."No." := SalesHeader."Last Posting No.";
        SalesCrMemoHeader.Find;
        SalesCrMemoHeader.SetRecFilter;

        if SendReportAsEmail then
            SalesCrMemoHeader.EmailRecords(true)
        else
            SalesCrMemoHeader.PrintRecords(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPost(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterConfirmPost(SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmPost(var SalesHeader: Record "Sales Header"; var HideDialog: Boolean; var IsHandled: Boolean; var SendReportAsEmail: Boolean; var DefaultOption: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetReport(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;
}

