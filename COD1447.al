codeunit 1447 "Headline RC Prod. Planner"
{

    trigger OnRun()
    var
        HeadlineRCProdPlanner: Record "Headline RC Prod. Planner";
    begin
        HeadlineRCProdPlanner.Get;
        WorkDate := HeadlineRCProdPlanner."Workdate for computations";
        OnComputeHeadlines;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnComputeHeadlines()
    begin
    end;
}

