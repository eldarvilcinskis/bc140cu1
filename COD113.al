codeunit 113 "Vend. Entry-Edit"
{
    Permissions = TableData "Vendor Ledger Entry"=m,
                  TableData "Detailed Vendor Ledg. Entry"=m;
    TableNo = "Vendor Ledger Entry";

    trigger OnRun()
    begin
        VendLedgEntry := Rec;
        VendLedgEntry.LockTable;
        VendLedgEntry.Find;
        VendLedgEntry."On Hold" := "On Hold";
        if VendLedgEntry.Open then begin
          VendLedgEntry."Due Date" := "Due Date";
          DtldVendLedgEntry.SetCurrentKey("Vendor Ledger Entry No.");
          DtldVendLedgEntry.SetRange("Vendor Ledger Entry No.",VendLedgEntry."Entry No.");
          DtldVendLedgEntry.ModifyAll("Initial Entry Due Date","Due Date");
          VendLedgEntry."Pmt. Discount Date" := "Pmt. Discount Date";
          VendLedgEntry."Applies-to ID" := "Applies-to ID";
          VendLedgEntry.Validate("Payment Method Code","Payment Method Code");
          VendLedgEntry.Validate("Remaining Pmt. Disc. Possible","Remaining Pmt. Disc. Possible");
          VendLedgEntry."Pmt. Disc. Tolerance Date" := "Pmt. Disc. Tolerance Date";
          VendLedgEntry.Validate("Max. Payment Tolerance","Max. Payment Tolerance");
          VendLedgEntry.Validate("Accepted Payment Tolerance","Accepted Payment Tolerance");
          VendLedgEntry.Validate("Accepted Pmt. Disc. Tolerance","Accepted Pmt. Disc. Tolerance");
          VendLedgEntry.Validate("Amount to Apply","Amount to Apply");
          VendLedgEntry.Validate("Applying Entry","Applying Entry");
          VendLedgEntry.Validate("Applies-to Ext. Doc. No.","Applies-to Ext. Doc. No.");
          VendLedgEntry.Validate("Message to Recipient","Message to Recipient");
        end;
        VendLedgEntry.Validate("Exported to Payment File","Exported to Payment File");
        VendLedgEntry.Validate("Creditor No.","Creditor No.");
        VendLedgEntry.Validate("Payment Reference","Payment Reference");
        OnBeforeVendLedgEntryModify(VendLedgEntry,Rec);
        VendLedgEntry.TestField("Entry No.","Entry No.");
        VendLedgEntry.Modify;
        Rec := VendLedgEntry;
    end;

    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        VendorNamesUpdateQst: Label '%1 vendor ledger entries with empty Vendor Name found. Do you want to copy the name on vendor cards to these vendor ledger entries?', Comment='%1 = number of entries';

    procedure UpdateVendorNamesInLedgerEntries()
    var
        Vendor: Record Vendor;
        ConfirmManagement: Codeunit "Confirm Management";
        Counter: Integer;
    begin
        VendLedgEntry.Reset;
        VendLedgEntry.SetRange("Vendor Name",'');
        if VendLedgEntry.IsEmpty then
          exit;

        Counter := VendLedgEntry.Count;
        if not ConfirmManagement.ConfirmProcess(StrSubstNo(VendorNamesUpdateQst,Counter),true) then
          exit;

        if VendLedgEntry.FindSet(true,false) then
          repeat
            if Vendor.Get(VendLedgEntry."Vendor No.") then begin
              VendLedgEntry."Vendor Name" := Vendor.Name;
              VendLedgEntry.Modify;
            end;
          until VendLedgEntry.Next = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVendLedgEntryModify(var VendLedgEntry: Record "Vendor Ledger Entry";FromVendLedgEntry: Record "Vendor Ledger Entry")
    begin
    end;
}

