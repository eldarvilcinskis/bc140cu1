codeunit 314 "Sales Shpt.-Printed"
{
    Permissions = TableData "Sales Shipment Header"=rimd;
    TableNo = "Sales Shipment Header";

    trigger OnRun()
    begin
        Find;
        "No. Printed" := "No. Printed" + 1;
        OnBeforeModify(Rec);
        Modify;
        Commit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(var SalesShipmentHeader: Record "Sales Shipment Header")
    begin
    end;
}

