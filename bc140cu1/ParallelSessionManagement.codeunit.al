codeunit 490 "Parallel Session Management"
{

    trigger OnRun()
    begin
    end;

    var
        TempJobQueueEntry: Record "Job Queue Entry" temporary;
        TempIntegerFreeMemMapFile: Record "Integer" temporary;
        TempInteger: Record "Integer" temporary;
        ActiveSession: Record "Active Session";
        MemoryMappedFile: array[1000] of Codeunit "Memory Mapped File";
        NoOfJQEntries: Integer;
        NoOfActiveSessions: Integer;
        RemainingTasksMsg: Label 'Waiting for background tasks to finish.\Remaining tasks: #1####', Comment = '#1## shows a number.';
        MaxNoOfSessions: Integer;
        NoOfMemMappedFiles: Integer;

    procedure NewSessionRunCodeunitWithRecord(CodeunitId: Integer; Parameter: Text; Priority: Integer; RecordIDToRun: RecordID): Boolean
    begin
        if not CreateNewJQEntry(CodeunitId, Parameter, Priority) then
            exit(false);
        TempJobQueueEntry."Record ID to Process" := RecordIDToRun;
        TempJobQueueEntry.Modify;
        StartNewSessions;
        exit(true);
    end;

    procedure NewSessionRunCodeunitWithBlob(CodeunitId: Integer; Parameter: Text; Priority: Integer; var TempBlob: Record TempBlob): Boolean
    begin
        if NoOfMemMappedFiles > ArrayLen(MemoryMappedFile) then
            exit(false);
        if not CreateNewJQEntry(CodeunitId, Parameter, Priority) then
            exit(false);

        if (NoOfMemMappedFiles = 0) and (TempIntegerFreeMemMapFile.Count = 0) then // init
            for TempIntegerFreeMemMapFile.Number := 1 to ArrayLen(MemoryMappedFile) do
                TempIntegerFreeMemMapFile.Insert;

        if not TempIntegerFreeMemMapFile.FindFirst then
            exit(false);

        TempJobQueueEntry."Run in User Session" := true; // used for flagging the existence of a memory mapped file
        TempJobQueueEntry.Modify;

        MemoryMappedFile[TempIntegerFreeMemMapFile.Number].CreateMemoryMappedFileFromTempBlob(TempBlob, Format(TempJobQueueEntry.ID));
        TempIntegerFreeMemMapFile.Delete;
        NoOfMemMappedFiles += 1;

        StartNewSessions;
        exit(true);
    end;

    procedure NewSessionRunCodeunit(CodeunitId: Integer; Parameter: Text; Priority: Integer): Boolean
    begin
        if not CreateNewJQEntry(CodeunitId, Parameter, Priority) then
            exit(false);
        StartNewSessions;
        exit(true);
    end;

    local procedure CreateNewJQEntry(CodeunitId: Integer; Parameter: Text; Priority: Integer): Boolean
    begin
        NoOfJQEntries += 1;
        TempJobQueueEntry.Init;
        TempJobQueueEntry.ID := CreateGuid;
        TempJobQueueEntry."Object Type to Run" :=
          TempJobQueueEntry."Object Type to Run"::Codeunit;
        TempJobQueueEntry."Object ID to Run" := CodeunitId;
        TempJobQueueEntry.Priority := Priority;
        TempJobQueueEntry."Parameter String" :=
          CopyStr(Parameter, 1, MaxStrLen(TempJobQueueEntry."Parameter String"));
        TempJobQueueEntry.Insert;
        exit(true);
    end;

    procedure NoOfActiveJobs(): Integer
    begin
        exit(NoOfJQEntries + NoOfActiveSessions);
    end;

    procedure WaitForAllToFinish(TimeOutInSeconds: Integer): Boolean
    var
        Window: Dialog;
        T0: DateTime;
    begin
        if TimeOutInSeconds = 0 then
            TimeOutInSeconds := 3600;
        T0 := CurrentDateTime + 1000 * TimeOutInSeconds;
        if GuiAllowed then
            Window.Open(RemainingTasksMsg);
        while (NoOfJQEntries > 0) and (CurrentDateTime < T0) do begin
            if GuiAllowed then
                Window.Update(1, NoOfActiveJobs);
            WaitForFreeSessions(TimeOutInSeconds, GetMaxNoOfSessions - 1);
            StartNewSessions;
        end;
        if GuiAllowed then
            Window.Close;
        exit(WaitForFreeSessions(TimeOutInSeconds, 0));
    end;

    local procedure WaitForFreeSessions(TimeOutInSeconds: Integer; NoOfRemainingSessions: Integer): Boolean
    begin
        if TempInteger.IsEmpty then
            exit(true);
        if TimeOutInSeconds = 0 then
            TimeOutInSeconds := 3600;
        RefreshActiveSessions;
        while (NoOfActiveSessions > NoOfRemainingSessions) and (TimeOutInSeconds > 0) do begin
            Sleep(2000);
            TimeOutInSeconds -= 2;
            RefreshActiveSessions;
        end;
        exit(NoOfActiveSessions <= NoOfRemainingSessions);
    end;

    local procedure StartNewSessions()
    begin
        RefreshActiveSessions;
        if NoOfActiveSessions >= GetMaxNoOfSessions then
            exit;

        TempJobQueueEntry.Reset;
        TempJobQueueEntry.SetFilter(Status, '<>%1', TempJobQueueEntry.Status::"In Process");
        TempJobQueueEntry.SetCurrentKey(Priority);
        if TempJobQueueEntry.FindSet then
            repeat
                TempInteger.Init;
                StartSession(TempInteger.Number, TempJobQueueEntry."Object ID to Run", CompanyName, TempJobQueueEntry);
                TempInteger.Insert;
                TempJobQueueEntry.Status := TempJobQueueEntry.Status::"In Process";
                TempJobQueueEntry."Timeout (sec.)" := TempInteger.Number; // Use the timeout field for storing session id.
                TempJobQueueEntry.Modify;
                NoOfActiveSessions += 1;
                NoOfJQEntries -= 1;
            until (TempJobQueueEntry.Next = 0) or (NoOfActiveSessions >= GetMaxNoOfSessions);
    end;

    procedure RunHeartbeat()
    begin
        StartNewSessions;
    end;

    local procedure RefreshActiveSessions()
    var
        i: Integer;
        MemMappedFileFound: Boolean;
    begin
        TempJobQueueEntry.Reset;
        if TempInteger.FindSet then
            repeat
                if not ActiveSession.Get(ServiceInstanceId, TempInteger.Number) then begin
                    TempInteger.Delete;
                    NoOfActiveSessions -= 1;
                    TempJobQueueEntry.SetRange("Timeout (sec.)", TempInteger.Number);
                    if TempJobQueueEntry.FindFirst then begin
                        if TempJobQueueEntry."Run in User Session" then begin
                            i := 1;
                            MemMappedFileFound := false;
                            while (i < ArrayLen(MemoryMappedFile)) and (not MemMappedFileFound) do begin
                                if not TempIntegerFreeMemMapFile.Get(i) then
                                    if MemoryMappedFile[i].GetName = Format(TempJobQueueEntry.ID) then begin
                                        MemoryMappedFile[i].Dispose;
                                        TempIntegerFreeMemMapFile.Number := i;
                                        TempIntegerFreeMemMapFile.Insert;
                                        NoOfMemMappedFiles -= 1;
                                    end;
                                i += 1;
                            end;
                        end;
                        TempJobQueueEntry.Delete;
                    end;
                end;
            until TempInteger.Next = 0;
        TempJobQueueEntry.Reset;
    end;

    procedure GetMaxNoOfSessions(): Integer
    begin
        if MaxNoOfSessions <= 0 then
            SetMaxNoOfSessions(10);
        exit(MaxNoOfSessions);
    end;

    procedure SetMaxNoOfSessions(NewMaxNoOfSessions: Integer)
    begin
        MaxNoOfSessions := NewMaxNoOfSessions;
        if MaxNoOfSessions > ArrayLen(MemoryMappedFile) then
            MaxNoOfSessions := ArrayLen(MemoryMappedFile);
    end;
}

