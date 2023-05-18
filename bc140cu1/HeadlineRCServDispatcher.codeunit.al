codeunit 1448 "Headline RC Serv. Dispatcher"
{

    trigger OnRun()
    var
        HeadlineRCServDispatcher: Record "Headline RC Serv. Dispatcher";
    begin
        HeadlineRCServDispatcher.Get;
        WorkDate := HeadlineRCServDispatcher."Workdate for computations";
        OnComputeHeadlines;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnComputeHeadlines()
    begin
    end;
}

