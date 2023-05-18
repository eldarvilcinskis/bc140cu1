codeunit 1380 "Batch Processing Mgt."
{
    Permissions = TableData "Batch Processing Parameter" = rimd,
                  TableData "Batch Processing Session Map" = rimd;

    trigger OnRun()
    begin
        RunCustomProcessing;
    end;

    var
        PostingTemplateMsg: Label 'Processing: @1@@@@@@@', Comment = '1 - overall progress';
        TempErrorMessage: Record "Error Message" temporary;
        RecRefCustomerProcessing: RecordRef;
        ProcessingCodeunitID: Integer;
        BatchID: Guid;
        ProcessingCodeunitNotSetErr: Label 'A processing codeunit has not been selected.';
        BatchCompletedMsg: Label 'All the documents were processed.';
        BatchCompletedWithErrorsMsg: Label 'One or more of the documents could not be processed.';
        IsCustomProcessingHandled: Boolean;

    [Scope('Personalization')]
    procedure BatchProcess(var RecRef: RecordRef)
    var
        Window: Dialog;
        CounterTotal: Integer;
        CounterToPost: Integer;
        CounterPosted: Integer;
        BatchConfirm: Option " ",Skip,Update;
    begin
        if ProcessingCodeunitID = 0 then
            Error(ProcessingCodeunitNotSetErr);

        with RecRef do begin
            if IsEmpty then
                exit;

            TempErrorMessage.DeleteAll;

            FillBatchProcessingMap(RecRef);
            Commit;

            FindSet;

            if GuiAllowed then begin
                Window.Open(PostingTemplateMsg);
                CounterTotal := Count;
            end;

            repeat
                if GuiAllowed then begin
                    CounterToPost += 1;
                    Window.Update(1, Round(CounterToPost / CounterTotal * 10000, 1));
                end;

                if CanProcessRecord(RecRef) then
                    if ProcessRecord(RecRef, BatchConfirm) then
                        CounterPosted += 1;
            until Next = 0;

            ResetBatchID;

            if GuiAllowed then begin
                Window.Close;
                if CounterPosted <> CounterTotal then
                    Message(BatchCompletedWithErrorsMsg)
                else
                    Message(BatchCompletedMsg);
            end;
        end;

        OnAfterBatchProcess(RecRef, CounterPosted);
    end;

    local procedure CanProcessRecord(var RecRef: RecordRef): Boolean
    var
        Result: Boolean;
    begin
        Result := true;
        OnVerifyRecord(RecRef, Result);

        exit(Result);
    end;

    local procedure FillBatchProcessingMap(var RecRef: RecordRef)
    begin
        with RecRef do begin
            FindSet;
            repeat
                DeleteLostParameters(RecordId);
                InsertBatchProcessingSessionMapEntry(RecRef);
            until Next = 0;
        end;
    end;

    [Scope('Personalization')]
    procedure GetErrorMessages(var TempErrorMessageResult: Record "Error Message" temporary)
    begin
        TempErrorMessageResult.Copy(TempErrorMessage, true);
    end;

    local procedure InsertBatchProcessingSessionMapEntry(RecRef: RecordRef)
    var
        BatchProcessingSessionMap: Record "Batch Processing Session Map";
    begin
        if IsNullGuid(BatchID) then
            exit;

        BatchProcessingSessionMap.Init;
        BatchProcessingSessionMap."Record ID" := RecRef.RecordId;
        BatchProcessingSessionMap."Batch ID" := BatchID;
        BatchProcessingSessionMap."User ID" := UserSecurityId;
        BatchProcessingSessionMap."Session ID" := SessionId;
        BatchProcessingSessionMap.Insert;
    end;

    local procedure InvokeProcessing(var RecRef: RecordRef): Boolean
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageMgt: Codeunit "Error Message Management";
        RecVar: Variant;
        Result: Boolean;
    begin
        ClearLastError;

        BatchProcessingMgt.SetRecRefForCustomProcessing(RecRef);
        Result := BatchProcessingMgt.Run;
        BatchProcessingMgt.GetRecRefForCustomProcessing(RecRef);

        RecVar := RecRef;

        if (GetLastErrorCallstack = '') and Result and not BatchProcessingMgt.GetIsCustomProcessingHandled then begin
            ErrorMessageMgt.Activate(ErrorMessageHandler);
            ErrorMessageMgt.PushContext(RecRef.RecordId, 0, '');
            Result := CODEUNIT.Run(ProcessingCodeunitID, RecVar);
        end;
        if not Result then
            LogError(RecVar, ErrorMessageHandler);

        RecRef.GetTable(RecVar);

        exit(Result);
    end;

    local procedure RunCustomProcessing()
    var
        Handled: Boolean;
    begin
        OnCustomProcessing(RecRefCustomerProcessing, Handled);
        IsCustomProcessingHandled := Handled;
    end;

    local procedure InitBatchID()
    begin
        if IsNullGuid(BatchID) then
            BatchID := CreateGuid;
    end;

    local procedure LogError(RecVar: Variant; ErrorMessageHandler: Codeunit "Error Message Handler")
    begin
        if not ErrorMessageHandler.AppendTo(TempErrorMessage) then
            TempErrorMessage.LogMessage(RecVar, 0, TempErrorMessage."Message Type"::Error, GetLastErrorText);
    end;

    local procedure ProcessRecord(var RecRef: RecordRef; var BatchConfirm: Option): Boolean
    var
        ProcessingResult: Boolean;
    begin
        OnBeforeBatchProcessing(RecRef, BatchConfirm);

        ProcessingResult := InvokeProcessing(RecRef);

        OnAfterBatchProcessing(RecRef, ProcessingResult);

        exit(ProcessingResult);
    end;

    [Scope('Personalization')]
    procedure ResetBatchID()
    var
        BatchProcessingParameter: Record "Batch Processing Parameter";
        BatchProcessingSessionMap: Record "Batch Processing Session Map";
    begin
        BatchProcessingParameter.SetRange("Batch ID", BatchID);
        BatchProcessingParameter.DeleteAll;

        BatchProcessingSessionMap.SetRange("Batch ID", BatchID);
        BatchProcessingSessionMap.DeleteAll;

        Clear(BatchID);

        Commit;
    end;

    local procedure DeleteLostParameters(RecordID: RecordID)
    var
        BatchProcessingSessionMap: Record "Batch Processing Session Map";
        BatchProcessingParameter: Record "Batch Processing Parameter";
    begin
        BatchProcessingSessionMap.SetRange("Record ID", RecordID);
        BatchProcessingSessionMap.SetRange("User ID", UserSecurityId);
        BatchProcessingSessionMap.SetRange("Session ID", SessionId);
        BatchProcessingSessionMap.SetFilter("Batch ID", '<>%1', BatchID);
        if BatchProcessingSessionMap.FindSet then begin
            repeat
                BatchProcessingParameter.SetRange("Batch ID", BatchProcessingSessionMap."Batch ID");
                if not BatchProcessingParameter.IsEmpty then
                    BatchProcessingParameter.DeleteAll;
            until BatchProcessingSessionMap.Next = 0;
            BatchProcessingSessionMap.DeleteAll;
        end;
    end;

    [Scope('Personalization')]
    procedure AddParameter(ParameterId: Integer; Value: Variant)
    var
        BatchProcessingParameter: Record "Batch Processing Parameter";
    begin
        InitBatchID;

        BatchProcessingParameter.Init;
        BatchProcessingParameter."Batch ID" := BatchID;
        BatchProcessingParameter."Parameter Id" := ParameterId;
        BatchProcessingParameter."Parameter Value" := Format(Value);
        BatchProcessingParameter.Insert;
    end;

    [Scope('Personalization')]
    procedure GetParameterText(RecordID: RecordID; ParameterId: Integer; var ParameterValue: Text[250]): Boolean
    var
        BatchProcessingParameter: Record "Batch Processing Parameter";
        BatchProcessingSessionMap: Record "Batch Processing Session Map";
    begin
        BatchProcessingSessionMap.SetRange("Record ID", RecordID);
        BatchProcessingSessionMap.SetRange("User ID", UserSecurityId);
        BatchProcessingSessionMap.SetRange("Session ID", SessionId);

        if not BatchProcessingSessionMap.FindFirst then
            exit(false);

        if not BatchProcessingParameter.Get(BatchProcessingSessionMap."Batch ID", ParameterId) then
            exit(false);

        ParameterValue := BatchProcessingParameter."Parameter Value";
        exit(true);
    end;

    [Scope('Personalization')]
    procedure GetParameterBoolean(RecordID: RecordID; ParameterId: Integer; var ParameterValue: Boolean): Boolean
    var
        Result: Boolean;
        Value: Text[250];
    begin
        if not GetParameterText(RecordID, ParameterId, Value) then
            exit(false);

        if not Evaluate(Result, Value) then
            exit(false);

        ParameterValue := Result;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure GetParameterInteger(RecordID: RecordID; ParameterId: Integer; var ParameterValue: Integer): Boolean
    var
        Result: Integer;
        Value: Text[250];
    begin
        if not GetParameterText(RecordID, ParameterId, Value) then
            exit(false);

        if not Evaluate(Result, Value) then
            exit(false);

        ParameterValue := Result;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure GetParameterDate(RecordID: RecordID; ParameterId: Integer; var ParameterValue: Date): Boolean
    var
        Result: Date;
        Value: Text[250];
    begin
        if not GetParameterText(RecordID, ParameterId, Value) then
            exit(false);

        if not Evaluate(Result, Value) then
            exit(false);

        ParameterValue := Result;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure GetIsCustomProcessingHandled(): Boolean
    begin
        exit(IsCustomProcessingHandled);
    end;

    [Scope('Personalization')]
    procedure GetRecRefForCustomProcessing(var RecRef: RecordRef)
    begin
        RecRef := RecRefCustomerProcessing;
    end;

    [Scope('Personalization')]
    procedure SetRecRefForCustomProcessing(RecRef: RecordRef)
    begin
        RecRefCustomerProcessing := RecRef;
    end;

    [Scope('Personalization')]
    procedure SetProcessingCodeunit(NewProcessingCodeunitID: Integer)
    begin
        ProcessingCodeunitID := NewProcessingCodeunitID;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnVerifyRecord(var RecRef: RecordRef; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBatchProcessing(var RecRef: RecordRef; var BatchConfirm: Option)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBatchProcess(var RecRef: RecordRef; var CounterPosted: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBatchProcessing(var RecRef: RecordRef; PostingResult: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCustomProcessing(var RecRef: RecordRef; var Handled: Boolean)
    begin
    end;
}

