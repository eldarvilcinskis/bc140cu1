codeunit 1444 "Headline RC Relationship Mgt."
{

    trigger OnRun()
    var
        HeadlineRCRelationshipMgt: Record "Headline RC Relationship Mgt.";
    begin
        HeadlineRCRelationshipMgt.Get;
        WorkDate := HeadlineRCRelationshipMgt."Workdate for computations";
        OnComputeHeadlines;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnComputeHeadlines()
    begin
    end;
}

