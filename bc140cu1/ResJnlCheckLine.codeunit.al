codeunit 211 "Res. Jnl.-Check Line"
{
    TableNo = "Res. Journal Line";

    trigger OnRun()
    begin
        RunCheck(Rec);
    end;

    var
        Text000: Label 'cannot be a closing date';
        Text002: Label 'The combination of dimensions used in %1 %2, %3, %4 is blocked. %5';
        Text003: Label 'A dimension used in %1 %2, %3, %4 has caused an error. %5';
        GLSetup: Record "General Ledger Setup";
        DimMgt: Codeunit DimensionManagement;
        TimeSheetMgt: Codeunit "Time Sheet Management";

    [Scope('Personalization')]
    procedure RunCheck(var ResJnlLine: Record "Res. Journal Line")
    var
        UserSetupManagement: Codeunit "User Setup Management";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeRunCheck(ResJnlLine, IsHandled);
        if IsHandled then
            exit;

        GLSetup.Get;
        with ResJnlLine do begin
            if EmptyLine then
                exit;

            TestField("Resource No.");
            TestField("Posting Date");
            TestField("Gen. Prod. Posting Group");

            if "Posting Date" <> NormalDate("Posting Date") then
                FieldError("Posting Date", Text000);

            UserSetupManagement.CheckAllowedPostingDate("Posting Date");

            if "Document Date" <> 0D then
                if "Document Date" <> NormalDate("Document Date") then
                    FieldError("Document Date", Text000);

            if ("Entry Type" = "Entry Type"::Usage) and ("Time Sheet No." <> '') then
                TimeSheetMgt.CheckResJnlLine(ResJnlLine);

            if not DimMgt.CheckDimIDComb("Dimension Set ID") then
                Error(
                  Text002,
                  TableCaption, "Journal Template Name", "Journal Batch Name", "Line No.",
                  DimMgt.GetDimCombErr);

            TableID[1] := DATABASE::Resource;
            No[1] := "Resource No.";
            TableID[2] := DATABASE::"Resource Group";
            No[2] := "Resource Group No.";
            TableID[3] := DATABASE::Job;
            No[3] := "Job No.";
            if not DimMgt.CheckDimValuePosting(TableID, No, "Dimension Set ID") then
                if "Line No." <> 0 then
                    Error(
                      Text003,
                      TableCaption, "Journal Template Name", "Journal Batch Name", "Line No.",
                      DimMgt.GetDimValuePostingErr)
                else
                    Error(DimMgt.GetDimValuePostingErr);
        end;

        OnAfterRunCheck(ResJnlLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunCheck(var ResJournalLine: Record "Res. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunCheck(var ResJournalLine: Record "Res. Journal Line"; var IsHandled: Boolean)
    begin
    end;
}

