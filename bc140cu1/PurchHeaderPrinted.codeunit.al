codeunit 317 "Purch.Header-Printed"
{
    TableNo = "Purchase Header";

    trigger OnRun()
    begin
        Find;
        "No. Printed" := "No. Printed" + 1;
        OnBeforeModify(Rec);
        Modify;
        Commit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(var PurchaseHeader: Record "Purchase Header")
    begin
    end;
}

