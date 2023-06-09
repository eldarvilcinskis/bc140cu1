codeunit 5402 "Unit of Measure Management"
{

    trigger OnRun()
    begin
    end;

    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ResourceUnitOfMeasure: Record "Resource Unit of Measure";
        Text001: Label 'Quantity per unit of measure must be defined.';

    [Scope('Personalization')]
    procedure GetQtyPerUnitOfMeasure(Item: Record Item; UnitOfMeasureCode: Code[10]) QtyPerUnitOfMeasure: Decimal
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetQtyPerUnitOfMeasure(Item, UnitOfMeasureCode, QtyPerUnitOfMeasure, IsHandled);
        if IsHandled then
            exit(QtyPerUnitOfMeasure);

        Item.TestField("No.");
        if UnitOfMeasureCode in [Item."Base Unit of Measure", ''] then
            exit(1);
        if (Item."No." <> ItemUnitOfMeasure."Item No.") or
           (UnitOfMeasureCode <> ItemUnitOfMeasure.Code)
        then
            ItemUnitOfMeasure.Get(Item."No.", UnitOfMeasureCode);
        ItemUnitOfMeasure.TestField("Qty. per Unit of Measure");
        exit(ItemUnitOfMeasure."Qty. per Unit of Measure");
    end;

    [Scope('Personalization')]
    procedure GetResQtyPerUnitOfMeasure(Resource: Record Resource; UnitOfMeasureCode: Code[10]) QtyPerUnitOfMeasure: Decimal
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetResQtyPerUnitOfMeasure(Resource, UnitOfMeasureCode, QtyPerUnitOfMeasure, IsHandled);
        if IsHandled then
            exit(QtyPerUnitOfMeasure);

        Resource.TestField("No.");
        if UnitOfMeasureCode in [Resource."Base Unit of Measure", ''] then
            exit(1);
        if (Resource."No." <> ResourceUnitOfMeasure."Resource No.") or
           (UnitOfMeasureCode <> ResourceUnitOfMeasure.Code)
        then
            ResourceUnitOfMeasure.Get(Resource."No.", UnitOfMeasureCode);
        ResourceUnitOfMeasure.TestField("Qty. per Unit of Measure");
        exit(ResourceUnitOfMeasure."Qty. per Unit of Measure");
    end;

    [Scope('Personalization')]
    procedure CalcBaseQty(Qty: Decimal; QtyPerUOM: Decimal): Decimal
    begin
        if QtyPerUOM = 0 then
            Error(Text001);

        exit(RoundQty(Qty * QtyPerUOM));
    end;

    [Scope('Personalization')]
    procedure CalcQtyFromBase(QtyBase: Decimal; QtyPerUOM: Decimal): Decimal
    begin
        if QtyPerUOM = 0 then
            Error(Text001);

        exit(RoundQty(QtyBase / QtyPerUOM));
    end;

    [Scope('Personalization')]
    procedure RoundQty(Qty: Decimal): Decimal
    begin
        exit(Round(Qty, QtyRndPrecision));
    end;

    [Scope('Personalization')]
    procedure QtyRndPrecision(): Decimal
    var
        RoundingPrecision: Decimal;
    begin
        OnBeforeQtyRndPrecision(RoundingPrecision);
        if RoundingPrecision = 0 then
            RoundingPrecision := 0.00001;
        exit(RoundingPrecision);
    end;

    [Scope('Personalization')]
    procedure CubageRndPrecision(): Decimal
    var
        RoundingPrecision: Decimal;
    begin
        OnBeforeCubageRndPrecision(RoundingPrecision);
        if RoundingPrecision = 0 then
            RoundingPrecision := 0.00001;
        exit(RoundingPrecision);
    end;

    [Scope('Personalization')]
    procedure TimeRndPrecision(): Decimal
    var
        RoundingPrecision: Decimal;
    begin
        OnBeforeTimeRndPrecision(RoundingPrecision);
        if RoundingPrecision = 0 then
            RoundingPrecision := 0.00001;
        exit(RoundingPrecision);
    end;

    [Scope('Personalization')]
    procedure WeightRndPrecision(): Decimal
    var
        RoundingPrecision: Decimal;
    begin
        OnBeforeWeightRndPrecision(RoundingPrecision);
        if RoundingPrecision = 0 then
            RoundingPrecision := 0.00001;
        exit(RoundingPrecision);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetQtyPerUnitOfMeasure(Item: Record Item; UnitOfMeasureCode: Code[10]; var QtyPerUnitOfMeasure: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetResQtyPerUnitOfMeasure(Resource: Record Resource; ResUnitOfMeasureCode: Code[10]; var QtyPerUnitOfMeasure: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCubageRndPrecision(var RoundingPrecision: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeQtyRndPrecision(var RoundingPrecision: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTimeRndPrecision(var RoundingPrecision: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWeightRndPrecision(var RoundingPrecision: Decimal)
    begin
    end;
}

