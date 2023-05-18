codeunit 1446 "Headline RC Team Member"
{

    trigger OnRun()
    var
        HeadlineRCTeamMember: Record "Headline RC Team Member";
    begin
        HeadlineRCTeamMember.Get;
        WorkDate := HeadlineRCTeamMember."Workdate for computations";
        OnComputeHeadlines;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnComputeHeadlines()
    begin
    end;
}

