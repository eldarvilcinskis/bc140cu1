codeunit 374 "Bank Acc. Recon. Apply Entries"
{
    TableNo = "Bank Acc. Reconciliation Line";

    trigger OnRun()
    begin
    end;

    var
        BankAccReconLine2: Record "Bank Acc. Reconciliation Line";
        CheckLedgEntry: Record "Check Ledger Entry";
        ApplyCheckLedgEntry: Page "Apply Check Ledger Entries";

    [Scope('Personalization')]
    procedure ApplyEntries(var BankAccReconLine: Record "Bank Acc. Reconciliation Line")
    begin
        BankAccReconLine2 := BankAccReconLine;
        BankAccReconLine2.TestField("Ready for Application", true);
        with BankAccReconLine2 do
            case Type of
                Type::"Check Ledger Entry":
                    begin
                        CheckLedgEntry.Reset;
                        CheckLedgEntry.SetCurrentKey("Bank Account No.", Open);
                        CheckLedgEntry.SetRange("Bank Account No.", "Bank Account No.");
                        CheckLedgEntry.SetRange(Open, true);
                        CheckLedgEntry.SetFilter(
                          "Entry Status", '%1|%2', CheckLedgEntry."Entry Status"::Posted,
                          CheckLedgEntry."Entry Status"::"Financially Voided");
                        CheckLedgEntry.SetFilter(
                          "Statement Status", '%1|%2', CheckLedgEntry."Statement Status"::Open,
                          CheckLedgEntry."Statement Status"::"Check Entry Applied");
                        CheckLedgEntry.SetFilter("Statement No.", '''''|%1', "Statement No.");
                        CheckLedgEntry.SetFilter("Statement Line No.", '0|%1', "Statement Line No.");
                        ApplyCheckLedgEntry.SetStmtLine(BankAccReconLine);
                        ApplyCheckLedgEntry.SetRecord(CheckLedgEntry);
                        ApplyCheckLedgEntry.SetTableView(CheckLedgEntry);
                        ApplyCheckLedgEntry.LookupMode(true);
                        if ApplyCheckLedgEntry.RunModal = ACTION::LookupOK then;
                        Clear(ApplyCheckLedgEntry);
                    end;
            end;
    end;
}

