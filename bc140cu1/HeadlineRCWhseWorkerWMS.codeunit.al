codeunit 1457 "Headline RC Whse. Worker WMS"
{

    trigger OnRun()
    var
        HeadlineRCWhseWorkerWMS: Record "Headline RC Whse. Worker WMS";
    begin
        HeadlineRCWhseWorkerWMS.Get;
        WorkDate := HeadlineRCWhseWorkerWMS."Workdate for computations";
        OnComputeHeadlines;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnComputeHeadlines()
    begin
    end;
}

