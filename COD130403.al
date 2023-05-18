codeunit 130403 "CAL Test Runner Publisher"
{

    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure SetSeed(NewSeed: Integer)
    begin
        OnSetSeed(NewSeed);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetSeed(NewSeed: Integer)
    begin
    end;
}

