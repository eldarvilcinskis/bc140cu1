codeunit 98 "Purchase Post via Job Queue"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        PurchHeader: Record "Purchase Header";
        PurchPostPrint: Codeunit "Purch.-Post + Print";
        RecRef: RecordRef;
    begin
        TestField("Record ID to Process");
        RecRef.Get("Record ID to Process");
        RecRef.SetTable(PurchHeader);
        PurchHeader.Find;
        SetJobQueueStatus(PurchHeader, PurchHeader."Job Queue Status"::Posting);
        if not CODEUNIT.Run(CODEUNIT::"Purch.-Post", PurchHeader) then begin
            SetJobQueueStatus(PurchHeader, PurchHeader."Job Queue Status"::Error);
            Error(GetLastErrorText);
        end;
        if PurchHeader."Print Posted Documents" then
            PurchPostPrint.GetReport(PurchHeader);
        SetJobQueueStatus(PurchHeader, PurchHeader."Job Queue Status"::" ");
    end;

    var
        PostDescription: Label 'Post Purchase %1 %2.', Comment = '%1 = document type, %2 = document number. Example: Post Purchase Order 1234.';
        PostAndPrintDescription: Label 'Post and Print Purchase %1 %2.', Comment = '%1 = document type, %2 = document number. Example: Post Purchase Order 1234.';
        Confirmation: Label '%1 %2 has been scheduled for posting.', Comment = '%1=document type, %2=number, e.g. Order 123  or Invoice 234.';
        WrongJobQueueStatus: Label '%1 %2 cannot be posted because it has already been scheduled for posting. Choose the Remove from Job Queue action to reset the job queue status and then post again.', Comment = '%1 = document type, %2 = document number. Example: Purchase Order 1234 or Invoice 1234.';

    local procedure SetJobQueueStatus(var PurchHeader: Record "Purchase Header"; NewStatus: Option)
    begin
        PurchHeader.LockTable;
        if PurchHeader.Find then begin
            PurchHeader."Job Queue Status" := NewStatus;
            PurchHeader.Modify;
            Commit;
        end;
    end;

    [Scope('Personalization')]
    procedure EnqueuePurchDoc(var PurchHeader: Record "Purchase Header")
    begin
        EnqueuePurchDocWithUI(PurchHeader, true);
    end;

    [Scope('Personalization')]
    procedure EnqueuePurchDocWithUI(var PurchHeader: Record "Purchase Header"; WithUI: Boolean)
    var
        TempInvoice: Boolean;
        TempRcpt: Boolean;
        TempShip: Boolean;
        Handled: Boolean;
    begin
        OnBeforeEnqueuePurchDoc(PurchHeader, Handled);
        if Handled then
            exit;

        with PurchHeader do begin
            if not ("Job Queue Status" in ["Job Queue Status"::" ", "Job Queue Status"::Error]) then
                Error(WrongJobQueueStatus, "Document Type", "No.");
            TempInvoice := Invoice;
            TempRcpt := Receive;
            TempShip := Ship;
            OnBeforeReleasePurchDoc(PurchHeader);
            if Status = Status::Open then
                CODEUNIT.Run(CODEUNIT::"Release Purchase Document", PurchHeader);
            Invoice := TempInvoice;
            Receive := TempRcpt;
            Ship := TempShip;
            "Job Queue Status" := "Job Queue Status"::"Scheduled for Posting";
            "Job Queue Entry ID" := EnqueueJobEntry(PurchHeader);
            Modify;

            if GuiAllowed then
                if WithUI then
                    Message(Confirmation, "Document Type", "No.");
        end;
    end;

    local procedure EnqueueJobEntry(PurchHeader: Record "Purchase Header"): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        with JobQueueEntry do begin
            Clear(ID);
            "Object Type to Run" := "Object Type to Run"::Codeunit;
            "Object ID to Run" := CODEUNIT::"Purchase Post via Job Queue";
            "Record ID to Process" := PurchHeader.RecordId;
            FillJobEntryFromPurchSetup(JobQueueEntry, PurchHeader."Print Posted Documents");
            FillJobEntryPurchDescription(JobQueueEntry, PurchHeader);
            CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry);
            exit(ID);
        end;
    end;

    local procedure FillJobEntryFromPurchSetup(var JobQueueEntry: Record "Job Queue Entry"; PostAndPrint: Boolean)
    var
        PurchSetup: Record "Purchases & Payables Setup";
    begin
        PurchSetup.Get;
        with JobQueueEntry do begin
            "Notify On Success" := PurchSetup."Notify On Success";
            "Job Queue Category Code" := PurchSetup."Job Queue Category Code";
            if PostAndPrint then
                Priority := PurchSetup."Job Q. Prio. for Post & Print"
            else
                Priority := PurchSetup."Job Queue Priority for Post";
        end;
    end;

    local procedure FillJobEntryPurchDescription(var JobQueueEntry: Record "Job Queue Entry"; PurchHeader: Record "Purchase Header")
    begin
        with JobQueueEntry do begin
            if PurchHeader."Print Posted Documents" then
                Description := PostAndPrintDescription
            else
                Description := PostDescription;
            Description :=
              CopyStr(StrSubstNo(Description, PurchHeader."Document Type", PurchHeader."No."), 1, MaxStrLen(Description));
        end;
    end;

    [Scope('Personalization')]
    procedure CancelQueueEntry(var PurchHeader: Record "Purchase Header")
    begin
        with PurchHeader do
            if "Job Queue Status" <> "Job Queue Status"::" " then begin
                DeleteJobs(PurchHeader);
                "Job Queue Status" := "Job Queue Status"::" ";
                Modify;
            end;
    end;

    local procedure DeleteJobs(PurchHeader: Record "Purchase Header")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        with PurchHeader do begin
            if not IsNullGuid("Job Queue Entry ID") then
                JobQueueEntry.SetRange(ID, "Job Queue Entry ID");
            JobQueueEntry.SetRange("Record ID to Process", RecordId);
            if not JobQueueEntry.IsEmpty then
                JobQueueEntry.DeleteAll(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEnqueuePurchDoc(var PurchaseHeader: Record "Purchase Header"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleasePurchDoc(var PurchaseHeader: Record "Purchase Header")
    begin
    end;
}

