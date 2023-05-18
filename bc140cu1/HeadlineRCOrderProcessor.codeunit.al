codeunit 1441 "Headline RC Order Processor"
{

    trigger OnRun()
    var
        HeadlineRCOrderProcessor: Record "Headline RC Order Processor";
    begin
        HeadlineRCOrderProcessor.Get;
        WorkDate := HeadlineRCOrderProcessor."Workdate for computations";
        OnComputeHeadlines;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnComputeHeadlines()
    begin
    end;
}

