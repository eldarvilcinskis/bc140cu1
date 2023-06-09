codeunit 88 "Sales Post via Job Queue"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        SalesPostPrint: Codeunit "Sales-Post + Print";
        RecRef: RecordRef;
    begin
        TestField("Record ID to Process");
        RecRef.Get("Record ID to Process");
        RecRef.SetTable(SalesHeader);
        SalesHeader.Find;

        SetJobQueueStatus(SalesHeader, SalesHeader."Job Queue Status"::Posting);
        if not CODEUNIT.Run(CODEUNIT::"Sales-Post", SalesHeader) then begin
            SetJobQueueStatus(SalesHeader, SalesHeader."Job Queue Status"::Error);
            Error(GetLastErrorText);
        end;
        if SalesHeader."Print Posted Documents" then
            SalesPostPrint.GetReport(SalesHeader);

        SetJobQueueStatus(SalesHeader, SalesHeader."Job Queue Status"::" ");
    end;

    var
        PostDescription: Label 'Post Sales %1 %2.', Comment = '%1 = document type, %2 = document number. Example: Post Sales Order 1234.';
        PostAndPrintDescription: Label 'Post and Print Sales %1 %2.', Comment = '%1 = document type, %2 = document number. Example: Post Sales Order 1234.';
        Confirmation: Label '%1 %2 has been scheduled for posting.', Comment = '%1=document type, %2=number, e.g. Order 123  or Invoice 234.';
        WrongJobQueueStatus: Label '%1 %2 cannot be posted because it has already been scheduled for posting. Choose the Remove from Job Queue action to reset the job queue status and then post again.', Comment = '%1 = document type, %2 = document number. Example: Sales Order 1234 or Invoice 1234.';

    local procedure SetJobQueueStatus(var SalesHeader: Record "Sales Header"; NewStatus: Option)
    begin
        SalesHeader.LockTable;
        if SalesHeader.Find then begin
            SalesHeader."Job Queue Status" := NewStatus;
            SalesHeader.Modify;
            Commit;
        end;
    end;

    [Scope('Personalization')]
    procedure EnqueueSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        EnqueueSalesDocWithUI(SalesHeader, true);
    end;

    [Scope('Personalization')]
    procedure EnqueueSalesDocWithUI(var SalesHeader: Record "Sales Header"; WithUI: Boolean)
    var
        TempInvoice: Boolean;
        TempRcpt: Boolean;
        TempShip: Boolean;
        Handled: Boolean;
    begin
        OnBeforeEnqueueSalesDoc(SalesHeader, Handled);
        if Handled then
            exit;

        with SalesHeader do begin
            if not ("Job Queue Status" in ["Job Queue Status"::" ", "Job Queue Status"::Error]) then
                Error(WrongJobQueueStatus, "Document Type", "No.");
            TempInvoice := Invoice;
            TempRcpt := Receive;
            TempShip := Ship;
            OnBeforeReleaseSalesDoc(SalesHeader);
            if Status = Status::Open then
                CODEUNIT.Run(CODEUNIT::"Release Sales Document", SalesHeader);
            Invoice := TempInvoice;
            Receive := TempRcpt;
            Ship := TempShip;
            "Job Queue Status" := "Job Queue Status"::"Scheduled for Posting";
            "Job Queue Entry ID" := EnqueueJobEntry(SalesHeader);
            Modify;

            if GuiAllowed then
                if WithUI then
                    Message(Confirmation, "Document Type", "No.");
        end;
    end;

    local procedure EnqueueJobEntry(SalesHeader: Record "Sales Header"): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        with JobQueueEntry do begin
            Clear(ID);
            "Object Type to Run" := "Object Type to Run"::Codeunit;
            "Object ID to Run" := CODEUNIT::"Sales Post via Job Queue";
            "Record ID to Process" := SalesHeader.RecordId;
            FillJobEntryFromSalesSetup(JobQueueEntry, SalesHeader."Print Posted Documents");
            FillJobEntrySalesDescription(JobQueueEntry, SalesHeader);
            CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry);
            exit(ID)
        end;
    end;

    local procedure FillJobEntryFromSalesSetup(var JobQueueEntry: Record "Job Queue Entry"; PostAndPrint: Boolean)
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get;
        with JobQueueEntry do begin
            "Notify On Success" := SalesSetup."Notify On Success";
            "Job Queue Category Code" := SalesSetup."Job Queue Category Code";
            if PostAndPrint then
                Priority := SalesSetup."Job Q. Prio. for Post & Print"
            else
                Priority := SalesSetup."Job Queue Priority for Post";
        end;
    end;

    local procedure FillJobEntrySalesDescription(var JobQueueEntry: Record "Job Queue Entry"; SalesHeader: Record "Sales Header")
    begin
        with JobQueueEntry do begin
            if SalesHeader."Print Posted Documents" then
                Description := PostAndPrintDescription
            else
                Description := PostDescription;
            Description :=
              CopyStr(StrSubstNo(Description, SalesHeader."Document Type", SalesHeader."No."), 1, MaxStrLen(Description));
        end;
    end;

    [Scope('Personalization')]
    procedure CancelQueueEntry(var SalesHeader: Record "Sales Header")
    begin
        with SalesHeader do
            if "Job Queue Status" <> "Job Queue Status"::" " then begin
                DeleteJobs(SalesHeader);
                "Job Queue Status" := "Job Queue Status"::" ";
                Modify;
            end;
    end;

    local procedure DeleteJobs(SalesHeader: Record "Sales Header")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        with SalesHeader do begin
            if not IsNullGuid("Job Queue Entry ID") then
                JobQueueEntry.SetRange(ID, "Job Queue Entry ID");
            JobQueueEntry.SetRange("Record ID to Process", RecordId);
            if not JobQueueEntry.IsEmpty then
                JobQueueEntry.DeleteAll(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEnqueueSalesDoc(var SalesHeader: Record "Sales Header"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header")
    begin
    end;
}

