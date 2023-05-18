codeunit 19 "Gen. Jnl.-Post Preview"
{

    trigger OnRun()
    begin
    end;

    var
        NothingToPostMsg: Label 'There is nothing to post.';
        PreviewModeErr: Label 'Preview mode.';
        PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";
        SubscriberTypeErr: Label 'Invalid Subscriber type. The type must be CODEUNIT.';
        RecVarTypeErr: Label 'Invalid RecVar type. The type must be RECORD.';
        PreviewExitStateErr: Label 'The posting preview has stopped because of a state that is not valid.';

    [Scope('Personalization')]
    procedure Preview(Subscriber: Variant;RecVar: Variant)
    var
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageMgt: Codeunit "Error Message Management";
        RunResult: Boolean;
    begin
        if not Subscriber.IsCodeunit then
          Error(SubscriberTypeErr);
        if not RecVar.IsRecord then
          Error(RecVarTypeErr);

        BindSubscription(PostingPreviewEventHandler);
        ErrorMessageMgt.Activate(ErrorMessageHandler);
        ErrorMessageMgt.PushContext(RecVar,0,PreviewModeErr);
        OnAfterBindSubscription;

        RunResult := RunPreview(Subscriber,RecVar);

        UnbindSubscription(PostingPreviewEventHandler);
        OnAfterUnbindSubscription;

        // The OnRunPreview event expects subscriber following template: Result := <Codeunit>.RUN
        // So we assume RunPreview returns FALSE with the error.
        // To prevent return FALSE without thrown error we check error call stack.
        if RunResult or (GetLastErrorCallstack = '') then
          Error(PreviewExitStateErr);

        if GetLastErrorText <> PreviewModeErr then
          if ErrorMessageHandler.ShowErrors then
            Error('');
        ShowAllEntries;
        Error('');
    end;

    [Scope('Personalization')]
    procedure IsActive(): Boolean
    var
        Result: Boolean;
    begin
        // The lookup to event subscription system virtual table is the performance killer.
        // We call subscriber CU 20 to get active state of posting preview context.
        OnSystemSetPostingPreviewActive(Result);

        OnAfterIsActive(Result);
        exit(Result);
    end;

    local procedure RunPreview(Subscriber: Variant;RecVar: Variant): Boolean
    var
        Result: Boolean;
    begin
        OnRunPreview(Result,Subscriber,RecVar);
        exit(Result);
    end;

    local procedure ShowAllEntries()
    var
        TempDocumentEntry: Record "Document Entry" temporary;
        GLPostingPreview: Page "G/L Posting Preview";
    begin
        PostingPreviewEventHandler.FillDocumentEntry(TempDocumentEntry);
        if not TempDocumentEntry.IsEmpty then begin
          GLPostingPreview.Set(TempDocumentEntry,PostingPreviewEventHandler);
          GLPostingPreview.Run
        end else
          Message(NothingToPostMsg);
    end;

    [Scope('Personalization')]
    procedure ShowDimensions(TableID: Integer;EntryNo: Integer;DimensionSetID: Integer)
    var
        DimMgt: Codeunit DimensionManagement;
        RecRef: RecordRef;
    begin
        RecRef.Open(TableID);
        DimMgt.ShowDimensionSet(DimensionSetID,StrSubstNo('%1 %2',RecRef.Caption,EntryNo));
    end;

    [Scope('Personalization')]
    procedure ThrowError()
    begin
        OnBeforeThrowError;
        Error(PreviewModeErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunPreview(var Result: Boolean;Subscriber: Variant;RecVar: Variant)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBindSubscription()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUnbindSubscription()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSystemSetPostingPreviewActive(var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsActive(var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeThrowError()
    begin
    end;
}

