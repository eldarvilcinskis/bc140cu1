codeunit 29 "Error Message Handler"
{
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        TempErrorMessage: Record "Error Message" temporary;
        Active: Boolean;

    [Scope('Personalization')]
    procedure AppendTo(var TempErrorMessageBuf: Record "Error Message" temporary): Boolean
    var
        NextID: Integer;
    begin
        with TempErrorMessage do begin
            if IsEmpty then
                exit(false);

            LogLastError;

            NextID := 0;
            TempErrorMessageBuf.Reset;
            if TempErrorMessageBuf.FindLast then
                NextID := TempErrorMessageBuf.ID;
            FindSet;
            repeat
                NextID += 1;
                TempErrorMessageBuf := TempErrorMessage;
                TempErrorMessageBuf.ID := NextID;
                TempErrorMessageBuf.Insert;
            until Next = 0;
            exit(true);
        end;
    end;

    [Scope('Personalization')]
    procedure Activate(var ErrorMessageHandler: Codeunit "Error Message Handler")
    begin
        Active := BindSubscription(ErrorMessageHandler);
    end;

    local procedure GetLink("Code": Code[30]): Text[250]
    var
        NamedForwardLink: Record "Named Forward Link";
    begin
        if NamedForwardLink.Get(Code) then
            exit(NamedForwardLink.Link);
    end;

    [Scope('Personalization')]
    procedure ShowErrors(): Boolean
    begin
        if Active then
            exit(TempErrorMessage.ShowErrors);
    end;

    [EventSubscriber(ObjectType::Codeunit, 28, 'OnGetLastErrorID', '', false, false)]
    local procedure OnGetLastErrorID(var ID: Integer; var ErrorMessage: Text[250])
    begin
        if Active then begin
            ID := TempErrorMessage.GetLastID;
            ErrorMessage := TempErrorMessage.Description;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 28, 'OnLogError', '', false, false)]
    local procedure OnLogErrorHandler(ContextFieldNo: Integer; ErrorMessage: Text; SourceVariant: Variant; SourceFieldNo: Integer; HelpArticleCode: Code[30]; var IsLogged: Boolean)
    begin
        if Active then
            IsLogged :=
              TempErrorMessage.LogContextFieldError(
                ContextFieldNo, ErrorMessage, SourceVariant, SourceFieldNo, GetLink(HelpArticleCode)) <> 0
    end;

    [EventSubscriber(ObjectType::Codeunit, 28, 'OnFindActiveSubscriber', '', false, false)]
    local procedure OnFindActiveSubscriberHandler(var IsFound: Boolean)
    begin
        if not IsFound then
            IsFound := Active;
    end;

    [EventSubscriber(ObjectType::Codeunit, 28, 'OnPopContext', '', false, false)]
    local procedure OnPopContextHandler(var ID: Integer)
    begin
        if Active then
            ID := TempErrorMessage.PopContext;
    end;

    [EventSubscriber(ObjectType::Codeunit, 28, 'OnPushContext', '', false, false)]
    local procedure OnPushContextHandler(ContextRecIDVariant: Variant; ContextFieldNo: Integer; AdditionalInfo: Text[250]; var ID: Integer)
    begin
        if Active then
            ID := TempErrorMessage.PushContext(ContextRecIDVariant, ContextFieldNo, AdditionalInfo);
    end;
}

