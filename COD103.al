codeunit 103 "Cust. Entry-Edit"
{
    Permissions = TableData "Cust. Ledger Entry"=m,
                  TableData "Detailed Cust. Ledg. Entry"=m;
    TableNo = "Cust. Ledger Entry";

    trigger OnRun()
    begin
        CustLedgEntry := Rec;
        CustLedgEntry.LockTable;
        CustLedgEntry.Find;
        CustLedgEntry."On Hold" := "On Hold";
        if CustLedgEntry.Open then begin
          CustLedgEntry."Due Date" := "Due Date";
          DtldCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.");
          DtldCustLedgEntry.SetRange("Cust. Ledger Entry No.",CustLedgEntry."Entry No.");
          DtldCustLedgEntry.ModifyAll("Initial Entry Due Date","Due Date");
          CustLedgEntry."Pmt. Discount Date" := "Pmt. Discount Date";
          CustLedgEntry."Applies-to ID" := "Applies-to ID";
          CustLedgEntry.Validate("Payment Method Code","Payment Method Code");
          CustLedgEntry.Validate("Remaining Pmt. Disc. Possible","Remaining Pmt. Disc. Possible");
          CustLedgEntry."Pmt. Disc. Tolerance Date" := "Pmt. Disc. Tolerance Date";
          CustLedgEntry.Validate("Max. Payment Tolerance","Max. Payment Tolerance");
          CustLedgEntry.Validate("Accepted Payment Tolerance","Accepted Payment Tolerance");
          CustLedgEntry.Validate("Accepted Pmt. Disc. Tolerance","Accepted Pmt. Disc. Tolerance");
          CustLedgEntry.Validate("Amount to Apply","Amount to Apply");
          CustLedgEntry.Validate("Applying Entry","Applying Entry");
          CustLedgEntry.Validate("Applies-to Ext. Doc. No.","Applies-to Ext. Doc. No.");
          CustLedgEntry.Validate("Message to Recipient","Message to Recipient");
          CustLedgEntry."Direct Debit Mandate ID" := "Direct Debit Mandate ID";
        end;
        CustLedgEntry.Validate("Exported to Payment File","Exported to Payment File");
        OnBeforeCustLedgEntryModify(CustLedgEntry,Rec);
        CustLedgEntry.TestField("Entry No.","Entry No.");
        CustLedgEntry.Modify;
        Rec := CustLedgEntry;
    end;

    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        CustomerNamesUpdateQst: Label '%1 customer ledger entries with empty Customer Name found. Do you want to copy the name on customer cards to these customer ledger entries?', Comment='%1 = number of entries';

    procedure UpdateCustomerNamesInLedgerEntries()
    var
        Customer: Record Customer;
        ConfirmManagement: Codeunit "Confirm Management";
        Counter: Integer;
    begin
        CustLedgEntry.Reset;
        CustLedgEntry.SetRange("Customer Name",'');
        if CustLedgEntry.IsEmpty then
          exit;

        Counter := CustLedgEntry.Count;
        if not ConfirmManagement.ConfirmProcess(StrSubstNo(CustomerNamesUpdateQst,Counter),true) then
          exit;

        if CustLedgEntry.FindSet(true,false) then
          repeat
            if Customer.Get(CustLedgEntry."Customer No.") then begin
              CustLedgEntry."Customer Name" := Customer.Name;
              CustLedgEntry.Modify;
            end;
          until CustLedgEntry.Next = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCustLedgEntryModify(var CustLedgEntry: Record "Cust. Ledger Entry";FromCustLedgEntry: Record "Cust. Ledger Entry")
    begin
    end;
}

