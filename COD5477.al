codeunit 5477 "Sales Invoice Aggregator"
{
    Permissions = TableData "Sales Invoice Header"=rimd;

    trigger OnRun()
    begin
    end;

    var
        DocumentIDNotSpecifiedForLinesErr: Label 'You must specify a document id to get the lines.', Locked=true;
        DocumentDoesNotExistErr: Label 'No document with the specified ID exists.', Locked=true;
        MultipleDocumentsFoundForIdErr: Label 'Multiple documents have been found for the specified criteria.', Locked=true;
        CannotModifyPostedInvioceErr: Label 'The invoice has been posted and can no longer be modified.', Locked=true;
        CannotInsertALineThatAlreadyExistsErr: Label 'You cannot insert a line because a line already exists.', Locked=true;
        CannotModifyALineThatDoesntExistErr: Label 'You cannot modify a line that does not exist.', Locked=true;
        CannotInsertPostedInvoiceErr: Label 'Invoices created through the API must be in Draft state.', Locked=true;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        CanOnlySetUOMForTypeItemErr: Label 'Unit of Measure can be set only for lines with type Item.', Locked=true;
        SkipUpdateDiscounts: Boolean;
        InvoiceIdIsNotSpecifiedErr: Label 'Invoice ID is not specified.', Locked=true;
        IntegrationRecordDoesNotExistErr: Label 'No Integration Record with the specified ID exists.', Locked=true;
        EntityIsNotFoundErr: Label 'Sales Invoice Entity is not found.', Locked=true;
        AggregatorCategoryLbl: Label 'Sales Invoice Aggregator', Locked=true;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertSalesHeader(var Rec: Record "Sales Header";RunTrigger: Boolean)
    begin
        if not CheckValidRecord(Rec) or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        InsertOrModifyFromSalesHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifySalesHeader(var Rec: Record "Sales Header";var xRec: Record "Sales Header";RunTrigger: Boolean)
    begin
        if not CheckValidRecord(Rec) or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        InsertOrModifyFromSalesHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteSalesHeader(var Rec: Record "Sales Header";RunTrigger: Boolean)
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
    begin
        if not CheckValidRecord(Rec) or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        TransferIntegrationRecordID(Rec);

        if not SalesInvoiceEntityAggregate.Get(Rec."No.",false) then
          exit;

        SalesInvoiceEntityAggregate.Delete;
    end;

    [EventSubscriber(ObjectType::Codeunit, 56, 'OnAfterResetRecalculateInvoiceDisc', '', false, false)]
    local procedure OnAfterResetRecalculateInvoiceDisc(var SalesHeader: Record "Sales Header")
    begin
        if not CheckValidRecord(SalesHeader) or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        InsertOrModifyFromSalesHeader(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertSalesLine(var Rec: Record "Sales Line";RunTrigger: Boolean)
    begin
        if not CheckValidLineRecord(Rec) then
          exit;

        ModifyTotalsSalesLine(Rec,true);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifySalesLine(var Rec: Record "Sales Line";var xRec: Record "Sales Line";RunTrigger: Boolean)
    begin
        if not CheckValidLineRecord(Rec) then
          exit;

        ModifyTotalsSalesLine(Rec,Rec."Recalculate Invoice Disc.");
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteSalesLine(var Rec: Record "Sales Line";RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        if not CheckValidLineRecord(Rec) then
          exit;

        SalesLine.SetRange("Document No.",Rec."Document No.");
        SalesLine.SetRange("Document Type",Rec."Document Type");
        SalesLine.SetRange("Recalculate Invoice Disc.",true);

        if SalesLine.FindFirst then begin
          ModifyTotalsSalesLine(SalesLine,true);
          exit;
        end;

        SalesLine.SetRange("Recalculate Invoice Disc.");

        if not SalesLine.FindFirst then
          BlankTotals(Rec."Document No.",false);
    end;

    [EventSubscriber(ObjectType::Table, 112, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertSalesInvoiceHeader(var Rec: Record "Sales Invoice Header";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        InsertOrModifyFromSalesInvoiceHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 112, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifySalesInvoiceHeader(var Rec: Record "Sales Invoice Header";var xRec: Record "Sales Invoice Header";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        InsertOrModifyFromSalesInvoiceHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 112, 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterRenameSalesInvoiceHeader(var Rec: Record "Sales Invoice Header";var xRec: Record "Sales Invoice Header";RunTrigger: Boolean)
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
    begin
        if Rec.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        if not SalesInvoiceEntityAggregate.Get(xRec."No.",true) then
          exit;

        SalesInvoiceEntityAggregate.SetIsRenameAllowed(true);
        SalesInvoiceEntityAggregate.Rename(Rec."No.",true);
    end;

    [EventSubscriber(ObjectType::Table, 112, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteSalesInvoiceHeader(var Rec: Record "Sales Invoice Header";RunTrigger: Boolean)
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
    begin
        if Rec.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        if not SalesInvoiceEntityAggregate.Get(Rec."No.",true) then
          exit;

        SalesInvoiceEntityAggregate.Delete;
    end;

    [EventSubscriber(ObjectType::Codeunit, 60, 'OnAfterCalcSalesDiscount', '', false, false)]
    local procedure OnAfterCalculateSalesDiscountOnSalesHeader(var SalesHeader: Record "Sales Header")
    begin
        if not CheckValidRecord(SalesHeader) or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        InsertOrModifyFromSalesHeader(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, 21, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertCustomerLedgerEntry(var Rec: Record "Cust. Ledger Entry";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        SetStatusOptionFromCustLedgerEntry(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 21, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyCustomerLedgerEntry(var Rec: Record "Cust. Ledger Entry";var xRec: Record "Cust. Ledger Entry";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        SetStatusOptionFromCustLedgerEntry(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 21, 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterRenameCustomerLedgerEntry(var Rec: Record "Cust. Ledger Entry";var xRec: Record "Cust. Ledger Entry";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        SetStatusOptionFromCustLedgerEntry(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 21, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteCustomerLedgerEntry(var Rec: Record "Cust. Ledger Entry";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        SetStatusOptionFromCustLedgerEntry(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 1900, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertCancelledDocument(var Rec: Record "Cancelled Document";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        SetStatusOptionFromCancelledDocument(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 1900, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyCancelledDocument(var Rec: Record "Cancelled Document";var xRec: Record "Cancelled Document";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        SetStatusOptionFromCancelledDocument(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 1900, 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterRenameCancelledDocument(var Rec: Record "Cancelled Document";var xRec: Record "Cancelled Document";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        SetStatusOptionFromCancelledDocument(xRec);
        SetStatusOptionFromCancelledDocument(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 1900, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteCancelledDocument(var Rec: Record "Cancelled Document";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        SetStatusOptionFromCancelledDocument(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforeSalesInvHeaderInsert', '', false, false)]
    local procedure OnBeforeSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header";SalesHeader: Record "Sales Header";CommitIsSuppressed: Boolean)
    var
        IntegrationRecord: Record "Integration Record";
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        IsRenameAllowed: Boolean;
    begin
        if SalesInvHeader.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        if IsNullGuid(SalesHeader.Id) then begin
          SendTraceTag('00006TK',AggregatorCategoryLbl,VERBOSITY::Error,InvoiceIdIsNotSpecifiedErr,
            DATACLASSIFICATION::SystemMetadata);
          exit;
        end;

        if SalesInvHeader."Pre-Assigned No." <> SalesHeader."No." then
          exit;

        if SalesInvHeader.Id <> SalesHeader.Id then
          exit;

        if not SalesInvoiceEntityAggregate.Get(SalesHeader."No.",false) then begin
          SendTraceTag('00006TL',AggregatorCategoryLbl,VERBOSITY::Error,EntityIsNotFoundErr,
            DATACLASSIFICATION::SystemMetadata);
          exit;
        end;

        if SalesInvoiceEntityAggregate.Id <> SalesHeader.Id then
          exit;

        if not IntegrationRecord.Get(SalesHeader.Id) then begin
          SendTraceTag('00006TM',AggregatorCategoryLbl,VERBOSITY::Error,IntegrationRecordDoesNotExistErr,
            DATACLASSIFICATION::SystemMetadata);
          exit;
        end;

        // Posting will insert it again
        IntegrationRecord.Delete;

        IsRenameAllowed := SalesInvoiceEntityAggregate.GetIsRenameAllowed;
        SalesInvoiceEntityAggregate.SetIsRenameAllowed(true);
        SalesInvoiceEntityAggregate.Rename(SalesInvHeader."No.",true);
        SalesInvoiceEntityAggregate.SetIsRenameAllowed(IsRenameAllowed);
    end;

    [Scope('Personalization')]
    procedure PropagateOnInsert(var SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";var TempFieldBuffer: Record "Field Buffer" temporary)
    var
        SalesHeader: Record "Sales Header";
        TypeHelper: Codeunit "Type Helper";
        TargetRecordRef: RecordRef;
        DocTypeFieldRef: FieldRef;
    begin
        if SalesInvoiceEntityAggregate.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        if SalesInvoiceEntityAggregate.Posted then
          Error(CannotInsertPostedInvoiceErr);

        TargetRecordRef.Open(DATABASE::"Sales Header");

        DocTypeFieldRef := TargetRecordRef.Field(SalesHeader.FieldNo("Document Type"));
        DocTypeFieldRef.Value(SalesHeader."Document Type"::Invoice);

        TypeHelper.TransferFieldsWithValidate(TempFieldBuffer,SalesInvoiceEntityAggregate,TargetRecordRef);

        TargetRecordRef.SetTable(SalesHeader);
        SalesHeader.CopySellToAddressToBillToAddress;
        SalesHeader.SetDefaultPaymentServices;
        SalesHeader.Insert(true);

        SalesInvoiceEntityAggregate."No." := SalesHeader."No.";
        SalesInvoiceEntityAggregate.Find;
    end;

    [Scope('Personalization')]
    procedure PropagateOnModify(var SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";var TempFieldBuffer: Record "Field Buffer" temporary)
    var
        SalesHeader: Record "Sales Header";
        TypeHelper: Codeunit "Type Helper";
        TargetRecordRef: RecordRef;
        Exists: Boolean;
    begin
        if SalesInvoiceEntityAggregate.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        if SalesInvoiceEntityAggregate.Posted then
          Error(CannotModifyPostedInvioceErr);

        Exists := SalesHeader.Get(SalesHeader."Document Type"::Invoice,SalesInvoiceEntityAggregate."No.");
        if Exists then
          TargetRecordRef.GetTable(SalesHeader)
        else
          TargetRecordRef.Open(DATABASE::"Sales Header");

        TypeHelper.TransferFieldsWithValidate(TempFieldBuffer,SalesInvoiceEntityAggregate,TargetRecordRef);

        TargetRecordRef.SetTable(SalesHeader);
        SalesHeader.CopySellToAddressToBillToAddress;

        if Exists then
          SalesHeader.Modify(true)
        else begin
          SalesHeader.SetDefaultPaymentServices;
          SalesHeader.Insert(true);
        end;
    end;

    [Scope('Personalization')]
    procedure PropagateOnDelete(var SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if SalesInvoiceEntityAggregate.IsTemporary or (not GraphMgtGeneralTools.IsApiEnabled) then
          exit;

        if SalesInvoiceEntityAggregate.Posted then begin
          if not SalesInvoiceHeader.Get(SalesInvoiceEntityAggregate."No.") then begin
            GraphMgtGeneralTools.CleanAggregateWithoutParent(SalesInvoiceEntityAggregate);
            exit;
          end;

          if SalesInvoiceHeader."No. Printed" = 0 then
            SalesInvoiceHeader."No. Printed" := 1;
          SalesInvoiceHeader.Delete(true);
        end else begin
          if not SalesHeader.Get(SalesHeader."Document Type"::Invoice,SalesInvoiceEntityAggregate."No.") then begin
            GraphMgtGeneralTools.CleanAggregateWithoutParent(SalesInvoiceEntityAggregate);
            exit;
          end;

          SalesHeader.Delete(true);
        end;
    end;

    [Scope('Personalization')]
    procedure UpdateAggregateTableRecords()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
    begin
        SalesHeader.SetRange("Document Type",SalesHeader."Document Type"::Invoice);
        if SalesHeader.FindSet then
          repeat
            InsertOrModifyFromSalesHeader(SalesHeader);
          until SalesHeader.Next = 0;

        if SalesInvoiceHeader.FindSet then
          repeat
            InsertOrModifyFromSalesInvoiceHeader(SalesInvoiceHeader);
          until SalesInvoiceHeader.Next = 0;

        SalesInvoiceEntityAggregate.SetRange(Posted,false);
        if SalesInvoiceEntityAggregate.FindSet(true,false) then
          repeat
            if not SalesHeader.Get(SalesHeader."Document Type"::Invoice,SalesInvoiceEntityAggregate."No.") then
              SalesInvoiceEntityAggregate.Delete(true);
          until SalesInvoiceEntityAggregate.Next = 0;

        SalesInvoiceEntityAggregate.SetRange(Posted,true);
        if SalesInvoiceEntityAggregate.FindSet(true,false) then
          repeat
            if not SalesInvoiceHeader.Get(SalesInvoiceEntityAggregate."No.") then
              SalesInvoiceEntityAggregate.Delete(true);
          until SalesInvoiceEntityAggregate.Next = 0;
    end;

    local procedure InsertOrModifyFromSalesHeader(var SalesHeader: Record "Sales Header")
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        RecordExists: Boolean;
    begin
        SalesInvoiceEntityAggregate.LockTable;
        RecordExists := SalesInvoiceEntityAggregate.Get(SalesHeader."No.",false);

        SalesInvoiceEntityAggregate.TransferFields(SalesHeader,true);
        SalesInvoiceEntityAggregate.Posted := false;

        case SalesHeader.Status of
          SalesHeader.Status::"Pending Approval":
            SalesInvoiceEntityAggregate.Status := SalesInvoiceEntityAggregate.Status::"In Review";
          SalesHeader.Status::Released,SalesHeader.Status::"Pending Prepayment":
            SalesInvoiceEntityAggregate.Status := SalesInvoiceEntityAggregate.Status::Open;
          else
            SalesInvoiceEntityAggregate.Status := SalesInvoiceEntityAggregate.Status::Draft;
        end;

        AssignTotalsFromSalesHeader(SalesHeader,SalesInvoiceEntityAggregate);
        SalesInvoiceEntityAggregate.UpdateReferencedRecordIds;

        if RecordExists then
          SalesInvoiceEntityAggregate.Modify(true)
        else
          SalesInvoiceEntityAggregate.Insert(true);
    end;

    local procedure InsertOrModifyFromSalesInvoiceHeader(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        RecordExists: Boolean;
    begin
        SalesInvoiceEntityAggregate.LockTable;
        RecordExists := SalesInvoiceEntityAggregate.Get(SalesInvoiceHeader."No.",true);
        SalesInvoiceEntityAggregate.TransferFields(SalesInvoiceHeader,true);
        SalesInvoiceEntityAggregate.Posted := true;
        SetStatusOptionFromSalesInvoiceHeader(SalesInvoiceHeader,SalesInvoiceEntityAggregate);
        AssignTotalsFromSalesInvoiceHeader(SalesInvoiceHeader,SalesInvoiceEntityAggregate);
        SalesInvoiceEntityAggregate.UpdateReferencedRecordIds;

        if RecordExists then
          SalesInvoiceEntityAggregate.Modify(true)
        else
          SalesInvoiceEntityAggregate.Insert(true);
    end;

    local procedure SetStatusOptionFromSalesInvoiceHeader(var SalesInvoiceHeader: Record "Sales Invoice Header";var SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate")
    begin
        SalesInvoiceHeader.CalcFields(Cancelled,Closed,Corrective);
        if SalesInvoiceHeader.Cancelled then begin
          SalesInvoiceEntityAggregate.Status := SalesInvoiceEntityAggregate.Status::Canceled;
          exit;
        end;

        if SalesInvoiceHeader.Corrective then begin
          SalesInvoiceEntityAggregate.Status := SalesInvoiceEntityAggregate.Status::Corrective;
          exit;
        end;

        if SalesInvoiceHeader.Closed then begin
          SalesInvoiceEntityAggregate.Status := SalesInvoiceEntityAggregate.Status::Paid;
          exit;
        end;

        SalesInvoiceEntityAggregate.Status := SalesInvoiceEntityAggregate.Status::Open;
    end;

    local procedure SetStatusOptionFromCustLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
    begin
        if not GraphMgtGeneralTools.IsApiEnabled then
          exit;

        SalesInvoiceEntityAggregate.SetRange("Cust. Ledger Entry No.",CustLedgerEntry."Entry No.");
        SalesInvoiceEntityAggregate.SetRange(Posted,true);

        if not SalesInvoiceEntityAggregate.FindSet(true) then
          exit;

        repeat
          UpdateStatusIfChanged(SalesInvoiceEntityAggregate);
        until SalesInvoiceEntityAggregate.Next = 0;
    end;

    local procedure SetStatusOptionFromCancelledDocument(var CancelledDocument: Record "Cancelled Document")
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
    begin
        if not GraphMgtGeneralTools.IsApiEnabled then
          exit;

        case CancelledDocument."Source ID" of
          DATABASE::"Sales Invoice Header":
            if not SalesInvoiceEntityAggregate.Get(CancelledDocument."Cancelled Doc. No.",true) then
              exit;
          DATABASE::"Sales Cr.Memo Header":
            if not SalesInvoiceEntityAggregate.Get(CancelledDocument."Cancelled By Doc. No.",true) then
              exit;
          else
            exit;
        end;

        UpdateStatusIfChanged(SalesInvoiceEntityAggregate);
    end;

    [Scope('Personalization')]
    procedure SetTaxGroupIdAndCode(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate";TaxGroupCode: Code[20];VATProductPostingGroupCode: Code[20];VATIdentifier: Code[20])
    var
        TaxGroup: Record "Tax Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if GeneralLedgerSetup.UseVat then begin
          SalesInvoiceLineAggregate."Tax Code" := VATIdentifier;
          if VATProductPostingGroup.Get(VATProductPostingGroupCode) then
            SalesInvoiceLineAggregate."Tax Id" := VATProductPostingGroup.Id;
        end else begin
          SalesInvoiceLineAggregate."Tax Code" := TaxGroupCode;
          if TaxGroup.Get(TaxGroupCode) then
            SalesInvoiceLineAggregate."Tax Id" := TaxGroup.Id;
        end;
    end;

    [Scope('Personalization')]
    procedure UpdateUnitOfMeasure(var Item: Record Item;JSONUnitOfMeasureTxt: Text)
    var
        TempFieldSet: Record "Field" temporary;
        GraphCollectionMgtItem: Codeunit "Graph Collection Mgt - Item";
        ItemModified: Boolean;
    begin
        GraphCollectionMgtItem.UpdateOrCreateItemUnitOfMeasureFromSalesDocument(JSONUnitOfMeasureTxt,Item,TempFieldSet,ItemModified);

        if ItemModified then
          Item.Modify(true);
    end;

    local procedure UpdateStatusIfChanged(var SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CurrentStatus: Option;
    begin
        SalesInvoiceHeader.Get(SalesInvoiceEntityAggregate."No.");
        CurrentStatus := SalesInvoiceEntityAggregate.Status;

        SetStatusOptionFromSalesInvoiceHeader(SalesInvoiceHeader,SalesInvoiceEntityAggregate);
        if CurrentStatus <> SalesInvoiceEntityAggregate.Status then
          SalesInvoiceEntityAggregate.Modify(true);
    end;

    local procedure AssignTotalsFromSalesHeader(var SalesHeader: Record "Sales Header";var SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        SalesLine.SetRange("Document Type",SalesHeader."Document Type");

        if not SalesLine.FindFirst then begin
          BlankTotals(SalesLine."Document No.",false);
          exit;
        end;

        AssignTotalsFromSalesLine(SalesLine,SalesInvoiceEntityAggregate,SalesHeader);
    end;

    local procedure AssignTotalsFromSalesInvoiceHeader(var SalesInvoiceHeader: Record "Sales Invoice Header";var SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetRange("Document No.",SalesInvoiceHeader."No.");

        if not SalesInvoiceLine.FindFirst then begin
          BlankTotals(SalesInvoiceLine."Document No.",true);
          exit;
        end;

        AssignTotalsFromSalesInvoiceLine(SalesInvoiceLine,SalesInvoiceEntityAggregate);
    end;

    local procedure AssignTotalsFromSalesLine(var SalesLine: Record "Sales Line";var SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";var SalesHeader: Record "Sales Header")
    var
        TotalSalesLine: Record "Sales Line";
        DocumentTotals: Codeunit "Document Totals";
        VATAmount: Decimal;
    begin
        if SalesLine."VAT Calculation Type" = SalesLine."VAT Calculation Type"::"Sales Tax" then begin
          SalesInvoiceEntityAggregate."Discount Applied Before Tax" := true;
          SalesInvoiceEntityAggregate."Prices Including VAT" := false;
        end else
          SalesInvoiceEntityAggregate."Discount Applied Before Tax" := not SalesHeader."Prices Including VAT";

        DocumentTotals.CalculateSalesTotals(TotalSalesLine,VATAmount,SalesLine);

        SalesInvoiceEntityAggregate."Invoice Discount Amount" := TotalSalesLine."Inv. Discount Amount";
        SalesInvoiceEntityAggregate.Amount := TotalSalesLine.Amount;
        SalesInvoiceEntityAggregate."Total Tax Amount" := VATAmount;
        SalesInvoiceEntityAggregate."Subtotal Amount" := TotalSalesLine."Line Amount";
        SalesInvoiceEntityAggregate."Amount Including VAT" := TotalSalesLine."Amount Including VAT";
    end;

    local procedure AssignTotalsFromSalesInvoiceLine(var SalesInvoiceLine: Record "Sales Invoice Line";var SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TotalSalesInvoiceHeader: Record "Sales Invoice Header";
        TotalSalesInvoiceLine: Record "Sales Invoice Line";
        DocumentTotals: Codeunit "Document Totals";
        VATAmount: Decimal;
    begin
        if SalesInvoiceLine."VAT Calculation Type" = SalesInvoiceLine."VAT Calculation Type"::"Sales Tax" then
          SalesInvoiceEntityAggregate."Discount Applied Before Tax" := true
        else begin
          SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");
          SalesInvoiceEntityAggregate."Discount Applied Before Tax" := not SalesInvoiceHeader."Prices Including VAT";
        end;

        DocumentTotals.CalculatePostedSalesInvoiceTotals(TotalSalesInvoiceHeader,VATAmount,SalesInvoiceLine);

        SalesInvoiceEntityAggregate."Invoice Discount Amount" := TotalSalesInvoiceHeader."Invoice Discount Amount";
        SalesInvoiceEntityAggregate.Amount := TotalSalesInvoiceHeader.Amount;
        SalesInvoiceEntityAggregate."Total Tax Amount" := VATAmount;

        TotalSalesInvoiceLine.SetRange("Document No.",SalesInvoiceLine."Document No.");
        TotalSalesInvoiceLine.CalcSums("Line Amount");
        SalesInvoiceEntityAggregate."Subtotal Amount" := TotalSalesInvoiceLine."Line Amount";
        SalesInvoiceEntityAggregate."Amount Including VAT" := TotalSalesInvoiceHeader."Amount Including VAT";
    end;

    local procedure BlankTotals(DocumentNo: Code[20];Posted: Boolean)
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
    begin
        if not SalesInvoiceEntityAggregate.Get(DocumentNo,Posted) then
          exit;

        SalesInvoiceEntityAggregate."Invoice Discount Amount" := 0;
        SalesInvoiceEntityAggregate."Total Tax Amount" := 0;
        SalesInvoiceEntityAggregate."Subtotal Amount" := 0;
        SalesInvoiceEntityAggregate.Amount := 0;
        SalesInvoiceEntityAggregate."Amount Including VAT" := 0;
        SalesInvoiceEntityAggregate.Modify;
    end;

    local procedure CheckValidRecord(var SalesHeader: Record "Sales Header"): Boolean
    begin
        if SalesHeader.IsTemporary then
          exit(false);

        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice then
          exit(false);

        exit(true);
    end;

    local procedure ModifyTotalsSalesLine(var SalesLine: Record "Sales Line";RecalculateInvoiceDisc: Boolean)
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        SalesHeader: Record "Sales Header";
    begin
        if not RecalculateInvoiceDisc then
          exit;

        if not SalesInvoiceEntityAggregate.Get(SalesLine."Document No.",false) then
          exit;

        if not SalesHeader.Get(SalesLine."Document Type",SalesLine."Document No.") then
          exit;

        AssignTotalsFromSalesLine(SalesLine,SalesInvoiceEntityAggregate,SalesHeader);
        SalesInvoiceEntityAggregate.Modify(true);
    end;

    local procedure TransferSalesInvoiceLineAggregateToSalesLine(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate";var SalesLine: Record "Sales Line";var TempFieldBuffer: Record "Field Buffer" temporary)
    var
        TypeHelper: Codeunit "Type Helper";
        SalesLineRecordRef: RecordRef;
    begin
        SalesLine."Document Type" := SalesLine."Document Type"::Invoice;

        SalesLineRecordRef.GetTable(SalesLine);

        TypeHelper.TransferFieldsWithValidate(TempFieldBuffer,SalesInvoiceLineAggregate,SalesLineRecordRef);
        SalesLineRecordRef.SetTable(SalesLine);
    end;

    local procedure TransferIntegrationRecordID(var SalesHeader: Record "Sales Header")
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        NewIntegrationRecord: Record "Integration Record";
        OldIntegrationRecord: Record "Integration Record";
        IntegrationManagement: Codeunit "Integration Management";
        SalesInvoiceHeaderRecordRef: RecordRef;
        IsRenameAllowed: Boolean;
    begin
        if IsNullGuid(SalesHeader.Id) then
          exit;

        SalesInvoiceHeader.SetRange("Pre-Assigned No.",SalesHeader."No.");
        if not SalesInvoiceHeader.FindFirst then
          exit;

        if SalesInvoiceHeader.Id = SalesHeader.Id then
          exit;

        if OldIntegrationRecord.Get(SalesHeader.Id) then
          OldIntegrationRecord.Delete;

        if NewIntegrationRecord.Get(SalesInvoiceHeader.Id) then
          NewIntegrationRecord.Delete;

        if SalesInvoiceEntityAggregate.Get(SalesInvoiceHeader."No.",true) then
          SalesInvoiceEntityAggregate.Delete(true);

        if SalesInvoiceEntityAggregate.Get(SalesHeader."No.",false) then begin
          IsRenameAllowed := SalesInvoiceEntityAggregate.GetIsRenameAllowed;
          SalesInvoiceEntityAggregate.SetIsRenameAllowed(true);
          SalesInvoiceEntityAggregate.Rename(SalesInvoiceHeader."No.",true);
          SalesInvoiceEntityAggregate.SetIsRenameAllowed(IsRenameAllowed);
        end;

        SalesInvoiceHeader.Id := SalesHeader.Id;
        SalesInvoiceHeader.Modify(true);
        SalesInvoiceHeaderRecordRef.GetTable(SalesInvoiceHeader);

        IntegrationManagement.InsertUpdateIntegrationRecord(SalesInvoiceHeaderRecordRef,CurrentDateTime);
    end;

    [Scope('Personalization')]
    procedure RedistributeInvoiceDiscounts(var SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate")
    var
        SalesLine: Record "Sales Line";
    begin
        if SalesInvoiceEntityAggregate.Posted then
          exit;

        SalesLine.SetRange("Document Type",SalesLine."Document Type"::Invoice);
        SalesLine.SetRange("Document No.",SalesInvoiceEntityAggregate."No.");
        SalesLine.SetRange("Recalculate Invoice Disc.",true);
        if SalesLine.FindFirst then
          CODEUNIT.Run(CODEUNIT::"Sales - Calc Discount By Type",SalesLine);

        SalesInvoiceEntityAggregate.Find;
    end;

    [Scope('Personalization')]
    procedure LoadLines(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate";DocumentIdFilter: Text)
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
    begin
        if DocumentIdFilter = '' then
          Error(DocumentIDNotSpecifiedForLinesErr);

        SalesInvoiceEntityAggregate.SetFilter(Id,DocumentIdFilter);
        if not SalesInvoiceEntityAggregate.FindFirst then
          exit;

        if SalesInvoiceEntityAggregate.Posted then
          LoadSalesInvoiceLines(SalesInvoiceLineAggregate,SalesInvoiceEntityAggregate)
        else
          LoadSalesLines(SalesInvoiceLineAggregate,SalesInvoiceEntityAggregate);
    end;

    local procedure LoadSalesInvoiceLines(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate";var SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetRange("Document No.",SalesInvoiceEntityAggregate."No.");

        if SalesInvoiceLine.FindSet(false,false) then
          repeat
            Clear(SalesInvoiceLineAggregate);
            SalesInvoiceLineAggregate.TransferFields(SalesInvoiceLine,true);
            SalesInvoiceLineAggregate."Document Id" := SalesInvoiceEntityAggregate.Id;
            SalesInvoiceLineAggregate.Id := GetIdFromDocumentIdAndSequence(SalesInvoiceEntityAggregate.Id,SalesInvoiceLine."Line No.");
            SetTaxGroupIdAndCode(
              SalesInvoiceLineAggregate,
              SalesInvoiceLine."Tax Group Code",
              SalesInvoiceLine."VAT Prod. Posting Group",
              SalesInvoiceLine."VAT Identifier");
            SalesInvoiceLineAggregate."VAT %" := SalesInvoiceLine."VAT %";
            SalesInvoiceLineAggregate."Tax Amount" := SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine."VAT Base Amount";
            SalesInvoiceLineAggregate."Currency Code" := SalesInvoiceLine.GetCurrencyCode;
            SalesInvoiceLineAggregate."Prices Including Tax" := SalesInvoiceEntityAggregate."Prices Including VAT";
            SalesInvoiceLineAggregate.SetDiscountValue;
            SalesInvoiceLineAggregate.UpdateReferencedRecordIds;
            UpdateLineAmountsFromSalesInvoiceLine(SalesInvoiceLineAggregate,SalesInvoiceLine);
            SalesInvoiceLineAggregate.Insert(true);
          until SalesInvoiceLine.Next = 0;
    end;

    local procedure LoadSalesLines(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate";var SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type",SalesLine."Document Type"::Invoice);
        SalesLine.SetRange("Document No.",SalesInvoiceEntityAggregate."No.");

        if SalesLine.FindSet(false,false) then
          repeat
            TransferFromSalesLine(SalesInvoiceLineAggregate,SalesInvoiceEntityAggregate,SalesLine);
            SalesInvoiceLineAggregate.Insert(true);
          until SalesLine.Next = 0;
    end;

    local procedure TransferFromSalesLine(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate";var SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";var SalesLine: Record "Sales Line")
    begin
        TransferFromSalesLineToAggregateLine(
          SalesInvoiceLineAggregate,SalesLine,SalesInvoiceEntityAggregate.Id,SalesInvoiceEntityAggregate."Prices Including VAT");
    end;

    [Scope('Personalization')]
    procedure TransferFromSalesLineToAggregateLine(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate";var SalesLine: Record "Sales Line";DocumentId: Guid;PricesIncludingVAT: Boolean)
    begin
        Clear(SalesInvoiceLineAggregate);
        SalesInvoiceLineAggregate.TransferFields(SalesLine,true);
        SalesInvoiceLineAggregate.Id := GetIdFromDocumentIdAndSequence(DocumentId,SalesLine."Line No.");
        SalesInvoiceLineAggregate."Document Id" := DocumentId;
        SetTaxGroupIdAndCode(
          SalesInvoiceLineAggregate,
          SalesLine."Tax Group Code",
          SalesLine."VAT Prod. Posting Group",
          SalesLine."VAT Identifier");
        SalesInvoiceLineAggregate."VAT %" := SalesLine."VAT %";
        SalesInvoiceLineAggregate."Tax Amount" := SalesLine."Amount Including VAT" - SalesLine."VAT Base Amount";
        SalesInvoiceLineAggregate."Prices Including Tax" := PricesIncludingVAT;
        SalesInvoiceLineAggregate.SetDiscountValue;
        SalesInvoiceLineAggregate.UpdateReferencedRecordIds;
        UpdateLineAmountsFromSalesLine(SalesInvoiceLineAggregate,SalesLine);
    end;

    [Scope('Personalization')]
    procedure PropagateInsertLine(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate";var TempFieldBuffer: Record "Field Buffer" temporary)
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        SalesLine: Record "Sales Line";
        LastUsedSalesLine: Record "Sales Line";
    begin
        VerifyCRUDIsPossibleForLine(SalesInvoiceLineAggregate,SalesInvoiceEntityAggregate);

        SalesLine."Document Type" := SalesLine."Document Type"::Invoice;
        SalesLine."Document No." := SalesInvoiceEntityAggregate."No.";

        if SalesInvoiceLineAggregate."Line No." = 0 then begin
          LastUsedSalesLine.SetRange("Document No.",SalesInvoiceEntityAggregate."No.");
          LastUsedSalesLine.SetRange("Document Type",SalesLine."Document Type"::Invoice);
          if LastUsedSalesLine.FindLast then
            SalesInvoiceLineAggregate."Line No." := LastUsedSalesLine."Line No." + 10000
          else
            SalesInvoiceLineAggregate."Line No." := 10000;

          SalesLine."Line No." := SalesInvoiceLineAggregate."Line No.";
        end else
          if SalesLine.Get(SalesLine."Document Type"::Invoice,SalesInvoiceEntityAggregate."No.",SalesInvoiceLineAggregate."Line No.") then
            Error(CannotInsertALineThatAlreadyExistsErr);

        TransferSalesInvoiceLineAggregateToSalesLine(SalesInvoiceLineAggregate,SalesLine,TempFieldBuffer);
        SalesLine.Insert(true);

        if not SkipUpdateDiscounts then
          RedistributeInvoiceDiscounts(SalesInvoiceEntityAggregate);

        SalesLine.Find;
        TransferFromSalesLine(SalesInvoiceLineAggregate,SalesInvoiceEntityAggregate,SalesLine);
    end;

    [Scope('Personalization')]
    procedure PropagateModifyLine(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate";var TempFieldBuffer: Record "Field Buffer" temporary)
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        SalesLine: Record "Sales Line";
    begin
        VerifyCRUDIsPossibleForLine(SalesInvoiceLineAggregate,SalesInvoiceEntityAggregate);

        if not SalesLine.Get(SalesLine."Document Type"::Invoice,SalesInvoiceEntityAggregate."No.",SalesInvoiceLineAggregate."Line No.") then
          Error(CannotModifyALineThatDoesntExistErr);

        TransferSalesInvoiceLineAggregateToSalesLine(SalesInvoiceLineAggregate,SalesLine,TempFieldBuffer);

        SalesLine.Modify(true);

        if not SkipUpdateDiscounts then
          RedistributeInvoiceDiscounts(SalesInvoiceEntityAggregate);

        SalesLine.Find;
        TransferFromSalesLine(SalesInvoiceLineAggregate,SalesInvoiceEntityAggregate,SalesLine);
    end;

    [Scope('Personalization')]
    procedure PropagateDeleteLine(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate")
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        SalesLine: Record "Sales Line";
    begin
        VerifyCRUDIsPossibleForLine(SalesInvoiceLineAggregate,SalesInvoiceEntityAggregate);

        if SalesLine.Get(SalesLine."Document Type"::Invoice,SalesInvoiceEntityAggregate."No.",SalesInvoiceLineAggregate."Line No.") then begin
          SalesLine.Delete(true);
          if not SkipUpdateDiscounts then
            RedistributeInvoiceDiscounts(SalesInvoiceEntityAggregate);
        end;
    end;

    [Scope('Personalization')]
    procedure PropagateMultipleLinesUpdate(var TempNewSalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate" temporary)
    var
        TempCurrentSalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate" temporary;
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        SalesLine: Record "Sales Line";
        TempAllFieldBuffer: Record "Field Buffer" temporary;
        NativeEDMTypes: Codeunit "Native - EDM Types";
    begin
        VerifyCRUDIsPossibleForLine(TempNewSalesInvoiceLineAggregate,SalesInvoiceEntityAggregate);
        NativeEDMTypes.GetFieldSetBufferWithAllFieldsSet(TempAllFieldBuffer);

        if not TempNewSalesInvoiceLineAggregate.FindFirst then begin
          SalesLine.SetRange("Document Type",SalesLine."Document Type"::Invoice);
          SalesLine.SetRange("Document No.",SalesInvoiceEntityAggregate."No.");
          SalesLine.DeleteAll(true);
          exit;
        end;

        LoadLines(TempCurrentSalesInvoiceLineAggregate,SalesInvoiceEntityAggregate.Id);

        SkipUpdateDiscounts := true;

        // Remove deleted lines
        if TempCurrentSalesInvoiceLineAggregate.FindSet(true,false) then
          repeat
            if not TempNewSalesInvoiceLineAggregate.Get(SalesInvoiceEntityAggregate.Id,TempCurrentSalesInvoiceLineAggregate."Line No.") then
              PropagateDeleteLine(TempCurrentSalesInvoiceLineAggregate);
          until TempCurrentSalesInvoiceLineAggregate.Next = 0;

        // Update Lines
        TempNewSalesInvoiceLineAggregate.FindFirst;

        repeat
          if not TempCurrentSalesInvoiceLineAggregate.Get(
               TempNewSalesInvoiceLineAggregate."Document Id",TempNewSalesInvoiceLineAggregate."Line No.")
          then
            PropagateInsertLine(TempNewSalesInvoiceLineAggregate,TempAllFieldBuffer)
          else
            PropagateModifyLine(TempNewSalesInvoiceLineAggregate,TempAllFieldBuffer);
        until TempNewSalesInvoiceLineAggregate.Next = 0;

        SalesInvoiceEntityAggregate.Find;
    end;

    local procedure VerifyCRUDIsPossibleForLine(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate";var SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate")
    var
        SearchSalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        DocumentIDFilter: Text;
    begin
        if IsNullGuid(SalesInvoiceLineAggregate."Document Id") then begin
          DocumentIDFilter := SalesInvoiceLineAggregate.GetFilter("Document Id");
          if DocumentIDFilter = '' then
            Error(DocumentIDNotSpecifiedForLinesErr);
          SalesInvoiceEntityAggregate.SetFilter(Id,DocumentIDFilter);
        end else
          SalesInvoiceEntityAggregate.SetRange(Id,SalesInvoiceLineAggregate."Document Id");

        if not SalesInvoiceEntityAggregate.FindFirst then
          Error(DocumentDoesNotExistErr);

        SearchSalesInvoiceEntityAggregate.Copy(SalesInvoiceEntityAggregate);
        if SearchSalesInvoiceEntityAggregate.Next <> 0 then
          Error(MultipleDocumentsFoundForIdErr);

        if SalesInvoiceEntityAggregate.Posted then
          Error(CannotModifyPostedInvioceErr);
    end;

    local procedure UpdateLineAmountsFromSalesLine(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate";var SalesLine: Record "Sales Line")
    begin
        SalesInvoiceLineAggregate."Line Amount Excluding Tax" := SalesLine.GetLineAmountExclVAT;
        SalesInvoiceLineAggregate."Line Amount Including Tax" := SalesLine.GetLineAmountInclVAT;
        SalesInvoiceLineAggregate."Line Tax Amount" :=
          SalesInvoiceLineAggregate."Line Amount Including Tax" - SalesInvoiceLineAggregate."Line Amount Excluding Tax";
        UpdateInvoiceDiscountAmount(SalesInvoiceLineAggregate);
    end;

    local procedure UpdateLineAmountsFromSalesInvoiceLine(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate";var SalesInvoiceLine: Record "Sales Invoice Line")
    begin
        SalesInvoiceLineAggregate."Line Amount Excluding Tax" := SalesInvoiceLine.GetLineAmountExclVAT;
        SalesInvoiceLineAggregate."Line Amount Including Tax" := SalesInvoiceLine.GetLineAmountInclVAT;
        SalesInvoiceLineAggregate."Line Tax Amount" :=
          SalesInvoiceLineAggregate."Line Amount Including Tax" - SalesInvoiceLineAggregate."Line Amount Excluding Tax";
        UpdateInvoiceDiscountAmount(SalesInvoiceLineAggregate);
    end;

    [Scope('Personalization')]
    procedure UpdateInvoiceDiscountAmount(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate")
    begin
        if SalesInvoiceLineAggregate."Prices Including Tax" then
          SalesInvoiceLineAggregate."Inv. Discount Amount Excl. VAT" :=
            SalesInvoiceLineAggregate."Line Amount Excluding Tax" - SalesInvoiceLineAggregate.Amount
        else
          SalesInvoiceLineAggregate."Inv. Discount Amount Excl. VAT" := SalesInvoiceLineAggregate."Inv. Discount Amount";
    end;

    [Scope('Personalization')]
    procedure VerifyCanUpdateUOM(var SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate")
    begin
        if SalesInvoiceLineAggregate."API Type" <> SalesInvoiceLineAggregate."API Type"::Item then
          Error(CanOnlySetUOMForTypeItemErr);
    end;

    local procedure CheckValidLineRecord(var SalesLine: Record "Sales Line"): Boolean
    begin
        if SalesLine.IsTemporary then
          exit(false);

        if not GraphMgtGeneralTools.IsApiEnabled then
          exit(false);

        if SalesLine."Document Type" <> SalesLine."Document Type"::Invoice then
          exit(false);

        exit(true);
    end;

    procedure GetIdFromDocumentIdAndSequence(DocumentId: Guid;Sequence: Integer): Text[50]
    var
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        exit(LowerCase(GraphMgtGeneralTools.StripBrackets(Format(DocumentId))) + '-' + Format(Sequence));
    end;
}
