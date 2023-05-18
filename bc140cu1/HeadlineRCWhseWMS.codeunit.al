codeunit 1456 "Headline RC Whse. WMS"
{

    trigger OnRun()
    var
        HeadlineRCWhseWMS: Record "Headline RC Whse. WMS";
    begin
        HeadlineRCWhseWMS.Get;
        WorkDate := HeadlineRCWhseWMS."Workdate for computations";
        OnComputeHeadlines;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnComputeHeadlines()
    begin
    end;
}

