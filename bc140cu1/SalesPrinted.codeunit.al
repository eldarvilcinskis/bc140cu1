codeunit 313 "Sales-Printed"
{
    TableNo = "Sales Header";

    trigger OnRun()
    begin
        Find;
        "No. Printed" := "No. Printed" + 1;
        OnBeforeModify(Rec);
        Modify;
        Commit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(var SalesHeader: Record "Sales Header")
    begin
    end;
}

