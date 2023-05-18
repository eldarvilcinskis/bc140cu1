codeunit 346 "Purch. Line CaptionClass Mgmt"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        GlobalPurchaseHeader: Record "Purchase Header";
        GlobalField: Record "Field";

    [Scope('Personalization')]
    procedure GetPurchaseLineCaptionClass(var PurchaseLine: Record "Purchase Line";FieldNumber: Integer): Text
    begin
        if (GlobalPurchaseHeader."Document Type" <> PurchaseLine."Document Type") or
           (GlobalPurchaseHeader."No." <> PurchaseLine."Document No.")
        then
          if not GlobalPurchaseHeader.Get(PurchaseLine."Document Type",PurchaseLine."Document No.") then
            Clear(GlobalPurchaseHeader);
        case FieldNumber of
          PurchaseLine.FieldNo("No."):
            exit(StrSubstNo('3,%1',GetFieldCaption(DATABASE::"Purchase Line",FieldNumber)));
          else begin
            if GlobalPurchaseHeader."Prices Including VAT" then
              exit('2,1,' + GetFieldCaption(DATABASE::"Purchase Line",FieldNumber));
            exit('2,0,' + GetFieldCaption(DATABASE::"Purchase Line",FieldNumber));
          end;
        end;
    end;

    local procedure GetFieldCaption(TableNumber: Integer;FieldNumber: Integer): Text
    begin
        if (GlobalField.TableNo <> TableNumber) or (GlobalField."No." <> FieldNumber) then
          GlobalField.Get(TableNumber,FieldNumber);
        exit(GlobalField."Field Caption");
    end;

    [EventSubscriber(ObjectType::Table, 38, 'OnAfterChangePricesIncludingVAT', '', true, true)]
    local procedure PurchaseHeaderChangedPricesIncludingVAT(var PurchaseHeader: Record "Purchase Header")
    begin
        GlobalPurchaseHeader := PurchaseHeader;
    end;
}

