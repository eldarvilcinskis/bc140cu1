codeunit 1449 "Headline RC Security Admin"
{

    trigger OnRun()
    var
        HeadlineRCSecurityAdmin: Record "Headline RC Security Admin";
    begin
        HeadlineRCSecurityAdmin.Get;
        WorkDate := HeadlineRCSecurityAdmin."Workdate for computations";
        OnComputeHeadlines;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnComputeHeadlines()
    begin
    end;
}

