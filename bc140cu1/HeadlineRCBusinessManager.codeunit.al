codeunit 1440 "Headline RC Business Manager"
{

    trigger OnRun()
    var
        HeadlineRCBusinessManager: Record "Headline RC Business Manager";
    begin
        HeadlineRCBusinessManager.Get;
        WorkDate := HeadlineRCBusinessManager."Workdate for computations";
        OnComputeHeadlines;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnComputeHeadlines()
    begin
    end;
}

