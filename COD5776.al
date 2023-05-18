codeunit 5776 "Warehouse Document-Print"
{

    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure PrintPickHeader(WhseActivHeader: Record "Warehouse Activity Header")
    var
        ReportSelectionWhse: Record "Report Selection Warehouse";
    begin
        WhseActivHeader.SetRange(Type,WhseActivHeader.Type::Pick);
        WhseActivHeader.SetRange("No.",WhseActivHeader."No.");
        ReportSelectionWhse.PrintWhseActivHeader(WhseActivHeader,ReportSelectionWhse.Usage::Pick,true);
    end;

    [Scope('Personalization')]
    procedure PrintPutAwayHeader(WhseActivHeader: Record "Warehouse Activity Header")
    var
        ReportSelectionWhse: Record "Report Selection Warehouse";
    begin
        WhseActivHeader.SetRange(Type,WhseActivHeader.Type::"Put-away");
        WhseActivHeader.SetRange("No.",WhseActivHeader."No.");
        ReportSelectionWhse.PrintWhseActivHeader(WhseActivHeader,ReportSelectionWhse.Usage::"Put-away",true);
    end;

    [Scope('Personalization')]
    procedure PrintMovementHeader(WhseActivHeader: Record "Warehouse Activity Header")
    var
        ReportSelectionWhse: Record "Report Selection Warehouse";
    begin
        WhseActivHeader.SetRange(Type,WhseActivHeader.Type::Movement);
        WhseActivHeader.SetRange("No.",WhseActivHeader."No.");
        ReportSelectionWhse.PrintWhseActivHeader(WhseActivHeader,ReportSelectionWhse.Usage::Movement,true);
    end;

    [Scope('Personalization')]
    procedure PrintInvtPickHeader(WhseActivHeader: Record "Warehouse Activity Header";HideDialog: Boolean)
    var
        ReportSelectionWhse: Record "Report Selection Warehouse";
    begin
        WhseActivHeader.SetRange(Type,WhseActivHeader.Type::"Invt. Pick");
        WhseActivHeader.SetRange("No.",WhseActivHeader."No.");
        ReportSelectionWhse.PrintWhseActivHeader(WhseActivHeader,ReportSelectionWhse.Usage::"Invt. Pick",not HideDialog);
    end;

    [Scope('Personalization')]
    procedure PrintInvtPutAwayHeader(WhseActivHeader: Record "Warehouse Activity Header";HideDialog: Boolean)
    var
        ReportSelectionWhse: Record "Report Selection Warehouse";
    begin
        WhseActivHeader.SetRange(Type,WhseActivHeader.Type::"Invt. Put-away");
        WhseActivHeader.SetRange("No.",WhseActivHeader."No.");
        ReportSelectionWhse.PrintWhseActivHeader(WhseActivHeader,ReportSelectionWhse.Usage::"Invt. Pick",not HideDialog);
    end;

    [Scope('Personalization')]
    procedure PrintInvtMovementHeader(WhseActivHeader: Record "Warehouse Activity Header";HideDialog: Boolean)
    var
        ReportSelectionWhse: Record "Report Selection Warehouse";
    begin
        WhseActivHeader.SetRange(Type,WhseActivHeader.Type::"Invt. Movement");
        WhseActivHeader.SetRange("No.",WhseActivHeader."No.");
        ReportSelectionWhse.PrintWhseActivHeader(WhseActivHeader,ReportSelectionWhse.Usage::"Invt. Movement",not HideDialog);
    end;

    [Scope('Personalization')]
    procedure PrintRcptHeader(WarehouseReceiptHeader: Record "Warehouse Receipt Header")
    var
        ReportSelectionWhse: Record "Report Selection Warehouse";
    begin
        WarehouseReceiptHeader.SetRange("No.",WarehouseReceiptHeader."No.");
        ReportSelectionWhse.PrintWhseReceiptHeader(WarehouseReceiptHeader,false);
    end;

    [Scope('Personalization')]
    procedure PrintPostedRcptHeader(PostedWhseReceiptHeader: Record "Posted Whse. Receipt Header")
    var
        ReportSelectionWhse: Record "Report Selection Warehouse";
    begin
        PostedWhseReceiptHeader.SetRange("No.",PostedWhseReceiptHeader."No.");
        ReportSelectionWhse.PrintPostedWhseReceiptHeader(PostedWhseReceiptHeader,false);
    end;

    [Scope('Personalization')]
    procedure PrintShptHeader(WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    var
        ReportSelectionWhse: Record "Report Selection Warehouse";
    begin
        WarehouseShipmentHeader.SetRange("No.",WarehouseShipmentHeader."No.");
        ReportSelectionWhse.PrintWhseShipmentHeader(WarehouseShipmentHeader,false);
    end;

    [Scope('Personalization')]
    procedure PrintPostedShptHeader(PostedWhseShipmentHeader: Record "Posted Whse. Shipment Header")
    var
        ReportSelectionWhse: Record "Report Selection Warehouse";
    begin
        PostedWhseShipmentHeader.SetRange("No.",PostedWhseShipmentHeader."No.");
        ReportSelectionWhse.PrintPostedWhseShipmentHeader(PostedWhseShipmentHeader,false);
    end;
}

