codeunit 1455 "Headline RC Whse. Basic"
{

    trigger OnRun()
    var
        HeadlineRCWhseBasic: Record "Headline RC Whse. Basic";
    begin
        HeadlineRCWhseBasic.Get;
        WorkDate := HeadlineRCWhseBasic."Workdate for computations";
        OnComputeHeadlines;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnComputeHeadlines()
    begin
    end;
}

