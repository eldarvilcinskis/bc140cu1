codeunit 27 "Confirm Management"
{

    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure ConfirmProcess(ConfirmQuestion: Text;DefaultButton: Boolean): Boolean
    begin
        if not GuiAllowed then
          exit(DefaultButton);
        exit(Confirm(ConfirmQuestion,DefaultButton));
    end;

    [Scope('Personalization')]
    procedure ConfirmProcessUI(ConfirmQuestion: Text;DefaultButton: Boolean): Boolean
    begin
        if not GuiAllowed then
          exit(false);
        exit(Confirm(ConfirmQuestion,DefaultButton));
    end;
}

