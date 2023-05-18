codeunit 28 "Error Message Management"
{

    trigger OnRun()
    begin
    end;

    var
        JoinedErr: Label '%1 %2.', Locked=true;
        AllowedPostingDateTok: Label 'ALLOWED POSTING DATE', Comment='{MaxLength=30}';

    [Scope('Personalization')]
    procedure Activate(var ErrorMessageHandler: Codeunit "Error Message Handler")
    begin
        if not IsActive then
          ErrorMessageHandler.Activate(ErrorMessageHandler)
    end;

    local procedure AddLink(Name: Code[30])
    var
        NamedForwardLink: Record "Named Forward Link";
    begin
        NamedForwardLink.Init;
        NamedForwardLink.Name := Name;
        if NamedForwardLink.Insert then;
    end;

    [Scope('Personalization')]
    procedure IsActive() IsFound: Boolean
    begin
        OnFindActiveSubscriber(IsFound);
    end;

    [Scope('Personalization')]
    procedure Finish()
    var
        ErrorMessage: Text[250];
    begin
        if GetLastError(ErrorMessage) <> 0 then begin
          if GuiAllowed then
            Error('');
          Error(ErrorMessage);
        end;
        PopContext;
    end;

    [Scope('Personalization')]
    procedure ThrowError(ContextErrorMessage: Text;DetailedErrorMessage: Text)
    begin
        if not IsActive then
          Error(JoinedErr,ContextErrorMessage,DetailedErrorMessage);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindActiveSubscriber(var IsFound: Boolean)
    begin
    end;

    [Scope('Personalization')]
    procedure GetFieldNo(TableNo: Integer;FieldName: Text): Integer
    var
        "Field": Record "Field";
    begin
        Field.SetRange(TableNo,TableNo);
        Field.SetRange(FieldName,FieldName);
        if Field.FindFirst then
          exit(Field."No.");
    end;

    [Scope('Personalization')]
    procedure FindFirstErrorMessage(var ErrorMessage: Text[250]) IsFound: Boolean
    begin
        OnFindFirstErrorMessage(ErrorMessage,IsFound);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindFirstErrorMessage(var ErrorMessage: Text[250];var IsFound: Boolean)
    begin
    end;

    [Scope('Personalization')]
    procedure GetLastError(var ErrorMessage: Text[250]) ID: Integer
    begin
        OnGetLastErrorID(ID,ErrorMessage);
    end;

    [Scope('Personalization')]
    procedure GetLastErrorID() ID: Integer
    var
        ErrorMessage: Text[250];
    begin
        OnGetLastErrorID(ID,ErrorMessage);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetLastErrorID(var ID: Integer;var ErrorMessage: Text[250])
    begin
    end;

    [Scope('Personalization')]
    procedure LogError(SourceVariant: Variant;ErrorMessage: Text;HelpArticleCode: Code[30])
    begin
        LogErrorMessage(0,ErrorMessage,SourceVariant,0,HelpArticleCode);
    end;

    [Scope('Personalization')]
    procedure LogContextFieldError(ContextFieldNo: Integer;ErrorMessage: Text;SourceVariant: Variant;SourceFieldNo: Integer;HelpArticleCode: Code[30])
    begin
        LogErrorMessage(ContextFieldNo,ErrorMessage,SourceVariant,SourceFieldNo,HelpArticleCode);
    end;

    [Scope('Personalization')]
    procedure LogErrorMessage(ContextFieldNo: Integer;ErrorMessage: Text;SourceVariant: Variant;SourceFieldNo: Integer;HelpArticleCode: Code[30]) IsLogged: Boolean
    begin
        OnLogError(ContextFieldNo,ErrorMessage,SourceVariant,SourceFieldNo,HelpArticleCode,IsLogged);
        if not IsLogged then
          Error(ErrorMessage);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLogError(ContextFieldNo: Integer;ErrorMessage: Text;SourceVariant: Variant;SourceFieldNo: Integer;HelpArticleCode: Code[30];var IsLogged: Boolean)
    begin
    end;

    [Scope('Personalization')]
    procedure PopContext() ID: Integer
    begin
        OnPopContext(ID);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPopContext(var ID: Integer)
    begin
    end;

    [Scope('Personalization')]
    procedure PushContext(ContextRecIDVariant: Variant;ContextFieldNo: Integer;AdditionalInfo: Text[250]) ID: Integer
    begin
        OnPushContext(ContextRecIDVariant,ContextFieldNo,AdditionalInfo,ID);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPushContext(ContextRecIDVariant: Variant;ContextFieldNo: Integer;AdditionalInfo: Text[250];var ID: Integer)
    begin
    end;

    [Scope('Personalization')]
    procedure GetHelpCodeForAllowedPostingDate(): Code[30]
    begin
        exit(AllowedPostingDateTok);
    end;

    [EventSubscriber(ObjectType::Table, 1431, 'OnLoad', '', false, false)]
    local procedure OnLoadHelpArticleCodes()
    begin
        AddLink(GetHelpCodeForAllowedPostingDate);
    end;
}

