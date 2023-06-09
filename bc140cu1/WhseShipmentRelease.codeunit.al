codeunit 7310 "Whse.-Shipment Release"
{

    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'There is nothing to release for %1 %2.';
        Text001: Label 'You cannot reopen the shipment because warehouse worksheet lines exist that must first be handled or deleted.';
        Text002: Label 'You cannot reopen the shipment because warehouse activity lines exist that must first be handled or deleted.';

    [Scope('Personalization')]
    procedure Release(var WhseShptHeader: Record "Warehouse Shipment Header")
    var
        Location: Record Location;
        WhsePickRqst: Record "Whse. Pick Request";
        WhseShptLine: Record "Warehouse Shipment Line";
        ATOLink: Record "Assemble-to-Order Link";
        AsmLine: Record "Assembly Line";
    begin
        with WhseShptHeader do begin
            if Status = Status::Released then
                exit;

            OnBeforeRelease(WhseShptHeader);

            WhseShptLine.SetRange("No.", "No.");
            WhseShptLine.SetFilter(Quantity, '<>0');
            if not WhseShptLine.Find('-') then
                Error(Text000, TableCaption, "No.");

            if "Location Code" <> '' then
                Location.Get("Location Code");

            repeat
                WhseShptLine.TestField("Item No.");
                WhseShptLine.TestField("Unit of Measure Code");
                if Location."Directed Put-away and Pick" then
                    WhseShptLine.TestField("Zone Code");
                if Location."Bin Mandatory" then begin
                    WhseShptLine.TestField("Bin Code");
                    if WhseShptLine."Assemble to Order" then begin
                        ATOLink.AsmExistsForWhseShptLine(WhseShptLine);
                        AsmLine.SetCurrentKey("Document Type", "Document No.", Type);
                        AsmLine.SetRange("Document Type", ATOLink."Assembly Document Type");
                        AsmLine.SetRange("Document No.", ATOLink."Assembly Document No.");
                        AsmLine.SetRange(Type, AsmLine.Type::Item);
                        if AsmLine.FindSet then
                            repeat
                                if AsmLine.CalcQtyToPickBase > 0 then
                                    AsmLine.TestField("Bin Code");
                            until AsmLine.Next = 0;
                    end;
                end;
            until WhseShptLine.Next = 0;

            OnAfterTestWhseShptLine(WhseShptHeader, WhseShptLine);

            Status := Status::Released;
            Modify;

            CreateWhsePickRqst(WhseShptHeader);

            WhsePickRqst.SetRange("Document Type", WhsePickRqst."Document Type"::Shipment);
            WhsePickRqst.SetRange("Document No.", "No.");
            WhsePickRqst.SetRange(Status, Status::Open);
            if not WhsePickRqst.IsEmpty then
                WhsePickRqst.DeleteAll(true);

            Commit;
        end;

        OnAfterRelease(WhseShptHeader, WhseShptLine);
    end;

    [Scope('Personalization')]
    procedure Reopen(WhseShptHeader: Record "Warehouse Shipment Header")
    var
        WhsePickRqst: Record "Whse. Pick Request";
        PickWkshLine: Record "Whse. Worksheet Line";
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        with WhseShptHeader do begin
            if Status = Status::Open then
                exit;

            OnBeforeReopen(WhseShptHeader);

            PickWkshLine.SetCurrentKey("Whse. Document Type", "Whse. Document No.");
            PickWkshLine.SetRange("Whse. Document Type", PickWkshLine."Whse. Document Type"::Shipment);
            PickWkshLine.SetRange("Whse. Document No.", "No.");
            if not PickWkshLine.IsEmpty then
                Error(Text001);

            WhseActivLine.SetCurrentKey("Whse. Document No.", "Whse. Document Type", "Activity Type");
            WhseActivLine.SetRange("Whse. Document No.", "No.");
            WhseActivLine.SetRange("Whse. Document Type", WhseActivLine."Whse. Document Type"::Shipment);
            WhseActivLine.SetRange("Activity Type", WhseActivLine."Activity Type"::Pick);
            if not WhseActivLine.IsEmpty then
                Error(Text002);

            WhsePickRqst.SetRange("Document Type", WhsePickRqst."Document Type"::Shipment);
            WhsePickRqst.SetRange("Document No.", "No.");
            WhsePickRqst.SetRange(Status, Status::Released);
            if not WhsePickRqst.IsEmpty then
                WhsePickRqst.ModifyAll(Status, WhsePickRqst.Status::Open);

            Status := Status::Open;
            Modify;
        end;

        OnAfterReopen(WhseShptHeader);
    end;

    local procedure CreateWhsePickRqst(var WhseShptHeader: Record "Warehouse Shipment Header")
    var
        WhsePickRqst: Record "Whse. Pick Request";
        Location: Record Location;
    begin
        with WhseShptHeader do
            if Location.RequirePicking("Location Code") then begin
                WhsePickRqst."Document Type" := WhsePickRqst."Document Type"::Shipment;
                WhsePickRqst."Document No." := "No.";
                WhsePickRqst.Status := Status;
                WhsePickRqst."Location Code" := "Location Code";
                WhsePickRqst."Zone Code" := "Zone Code";
                WhsePickRqst."Bin Code" := "Bin Code";
                CalcFields("Completely Picked");
                WhsePickRqst."Completely Picked" := "Completely Picked";
                if not WhsePickRqst.Insert then
                    WhsePickRqst.Modify;
            end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRelease(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReopen(var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestWhseShptLine(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRelease(var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopen(var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
    end;
}

