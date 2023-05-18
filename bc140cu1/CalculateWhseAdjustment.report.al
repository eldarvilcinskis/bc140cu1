report 7315 "Calculate Whse. Adjustment"
{
    Caption = 'Calculate Warehouse Adjustment';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item;Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.","Location Filter","Variant Filter";
            dataitem("Integer";"Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));

                trigger OnAfterGetRecord()
                var
                    ReservationEntry: Record "Reservation Entry";
                begin
                    with AdjmtBinQuantityBuffer do begin
                      Location.Reset;
                      Item.CopyFilter("Location Filter",Location.Code);
                      Location.SetRange("Directed Put-away and Pick",true);
                      if Location.FindSet then
                        repeat
                          WhseEntry.SetRange("Location Code",Location.Code);
                          WhseEntry.SetRange("Bin Code",Location."Adjustment Bin Code");
                          if WhseEntry.FindSet then
                            repeat
                              if WhseEntry."Qty. (Base)" <> 0 then begin
                                Reset;
                                SetRange("Item No.",WhseEntry."Item No.");
                                SetRange("Variant Code",WhseEntry."Variant Code");
                                SetRange("Location Code",WhseEntry."Location Code");
                                SetRange("Bin Code",WhseEntry."Bin Code");
                                SetRange("Unit of Measure Code",WhseEntry."Unit of Measure Code");
                                if WhseEntry."Lot No." <> '' then
                                  SetRange("Lot No.",WhseEntry."Lot No.");
                                if WhseEntry."Serial No." <> '' then
                                  SetRange("Serial No.",WhseEntry."Serial No.");
                                if FindSet then begin
                                  "Qty. to Handle (Base)" := "Qty. to Handle (Base)" + WhseEntry."Qty. (Base)";
                                  Modify;
                                end else begin
                                  Init;
                                  "Item No." := WhseEntry."Item No.";
                                  "Variant Code" := WhseEntry."Variant Code";
                                  "Location Code" := WhseEntry."Location Code";
                                  "Bin Code" := WhseEntry."Bin Code";
                                  "Unit of Measure Code" := WhseEntry."Unit of Measure Code";
                                  "Base Unit of Measure" := Item."Base Unit of Measure";
                                  "Lot No." := WhseEntry."Lot No.";
                                  "Serial No." := WhseEntry."Serial No.";
                                  "Qty. to Handle (Base)" := WhseEntry."Qty. (Base)";
                                  "Qty. Outstanding (Base)" := WhseEntry."Qty. (Base)";
                                  OnBeforeAdjmtBinQuantityBufferInsert(AdjmtBinQuantityBuffer,WhseEntry);
                                  Insert;
                                end;
                              end;
                            until WhseEntry.Next = 0;
                        until Location.Next = 0;

                      Reset;
                      ReservationEntry.Reset;
                      ReservationEntry.SetCurrentKey("Source ID");
                      ItemJnlLine.Reset;
                      ItemJnlLine.SetCurrentKey("Item No.");
                      if FindSet then begin
                        repeat
                          ItemJnlLine.Reset;
                          ItemJnlLine.SetCurrentKey("Item No.");
                          ItemJnlLine.SetRange("Journal Template Name",ItemJnlLine."Journal Template Name");
                          ItemJnlLine.SetRange("Journal Batch Name",ItemJnlLine."Journal Batch Name");
                          ItemJnlLine.SetRange("Item No.","Item No.");
                          ItemJnlLine.SetRange("Location Code","Location Code");
                          ItemJnlLine.SetRange("Unit of Measure Code","Unit of Measure Code");
                          ItemJnlLine.SetRange("Warehouse Adjustment",true);
                          if ItemJnlLine.FindSet then
                            repeat
                              ReservationEntry.SetRange("Source Type",DATABASE::"Item Journal Line");
                              ReservationEntry.SetRange("Source ID",ItemJnlLine."Journal Template Name");
                              ReservationEntry.SetRange("Source Batch Name",ItemJnlLine."Journal Batch Name");
                              ReservationEntry.SetRange("Source Ref. No.",ItemJnlLine."Line No.");
                              if "Lot No." <> '' then
                                ReservationEntry.SetRange("Lot No.","Lot No.");
                              if "Serial No." <> '' then
                                ReservationEntry.SetRange("Serial No.","Serial No.");
                              ReservationEntry.CalcSums("Qty. to Handle (Base)");
                              if ReservationEntry."Qty. to Handle (Base)" <> 0 then begin
                                "Qty. to Handle (Base)" += ReservationEntry."Qty. to Handle (Base)";
                                "Qty. Outstanding (Base)" += ReservationEntry."Qty. to Handle (Base)";
                                Modify;
                              end;
                            until ItemJnlLine.Next = 0;
                        until Next = 0;
                      end;
                    end;
                end;

                trigger OnPostDataItem()
                var
                    ItemUOM: Record "Item Unit of Measure";
                    QtyInUOM: Decimal;
                begin
                    with AdjmtBinQuantityBuffer do begin
                      Reset;
                      if FindSet then
                        repeat
                          if "Location Code" <> '' then
                            SetRange("Location Code","Location Code");
                          SetRange("Variant Code","Variant Code");
                          SetRange("Unit of Measure Code","Unit of Measure Code");

                          WhseQtyBase := 0;
                          SetFilter("Qty. to Handle (Base)",'>0');
                          if FindSet then begin
                            repeat
                              WhseQtyBase := WhseQtyBase - "Qty. to Handle (Base)";
                            until Next = 0
                          end;

                          ItemUOM.Get("Item No.","Unit of Measure Code");
                          QtyInUOM := Round(WhseQtyBase / ItemUOM."Qty. per Unit of Measure",UOMMgt.QtyRndPrecision);
                          if (QtyInUOM <> 0) and FindFirst then
                            InsertItemJnlLine(
                              "Item No.","Variant Code","Location Code",
                              QtyInUOM,WhseQtyBase,"Unit of Measure Code",1);

                          WhseQtyBase := 0;
                          SetFilter("Qty. to Handle (Base)",'<0');
                          if FindSet then
                            repeat
                              WhseQtyBase := WhseQtyBase - "Qty. to Handle (Base)";
                            until Next = 0;
                          QtyInUOM := Round(WhseQtyBase / ItemUOM."Qty. per Unit of Measure",UOMMgt.QtyRndPrecision);
                          if (QtyInUOM <> 0) and FindFirst then
                            InsertItemJnlLine(
                              "Item No.","Variant Code","Location Code",
                              QtyInUOM,WhseQtyBase,"Unit of Measure Code",0);

                          WhseQtyBase := 0;
                          SetRange("Qty. to Handle (Base)");
                          if FindSet then
                            repeat
                              WhseQtyBase := WhseQtyBase - "Qty. to Handle (Base)";
                            until Next = 0;
                          QtyInUOM := Round(WhseQtyBase / ItemUOM."Qty. per Unit of Measure",UOMMgt.QtyRndPrecision);
                          if ((QtyInUOM = 0) and (WhseQtyBase < 0)) and FindFirst then
                            InsertItemJnlLine(
                              "Item No.","Variant Code","Location Code",
                              WhseQtyBase,WhseQtyBase,"Base Unit of Measure",1);

                          FindLast;
                          SetRange("Location Code");
                          SetRange("Variant Code");
                          SetRange("Unit of Measure Code");
                        until Next = 0;
                      Reset;
                      DeleteAll;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    Clear(Location);
                    WhseEntry.Reset;
                    WhseEntry.SetCurrentKey("Item No.","Bin Code","Location Code","Variant Code");
                    WhseEntry.SetRange("Item No.",Item."No.");
                    Item.CopyFilter("Variant Filter",WhseEntry."Variant Code");
                    Item.CopyFilter("Lot No. Filter",WhseEntry."Lot No.");
                    Item.CopyFilter("Serial No. Filter",WhseEntry."Serial No.");

                    if not WhseEntry.Find('-') then
                      CurrReport.Break;

                    FillProspectReservationEntryBuffer(Item,ItemJnlLine."Journal Template Name",ItemJnlLine."Journal Batch Name");

                    AdjmtBinQuantityBuffer.Reset;
                    AdjmtBinQuantityBuffer.DeleteAll;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if not HideValidationDialog then
                  Window.Update;
            end;

            trigger OnPostDataItem()
            begin
                if not HideValidationDialog then
                  Window.Close;
            end;

            trigger OnPreDataItem()
            var
                ItemJnlTemplate: Record "Item Journal Template";
                ItemJnlBatch: Record "Item Journal Batch";
            begin
                if PostingDate = 0D then
                  Error(Text000);

                ItemJnlTemplate.Get(ItemJnlLine."Journal Template Name");
                ItemJnlBatch.Get(ItemJnlLine."Journal Template Name",ItemJnlLine."Journal Batch Name");
                if NextDocNo = '' then begin
                  if ItemJnlBatch."No. Series" <> '' then begin
                    ItemJnlLine.SetRange("Journal Template Name",ItemJnlLine."Journal Template Name");
                    ItemJnlLine.SetRange("Journal Batch Name",ItemJnlLine."Journal Batch Name");
                    if not ItemJnlLine.Find('-') then
                      NextDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series",PostingDate,false);
                    ItemJnlLine.Init;
                  end;
                  if NextDocNo = '' then
                    Error(Text001);
                end;

                NextLineNo := 0;

                if not HideValidationDialog then
                  Window.Open(Text002,"No.");
            end;
        }
    }

    requestpage
    {
        Caption = 'Calculate Inventory';
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PostingDate;PostingDate)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the date for the posting of this batch job. The program automatically enters the work date in this field, but you can change it.';

                        trigger OnValidate()
                        begin
                            ValidatePostingDate;
                        end;
                    }
                    field(NextDocNo;NextDocNo)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies a manually entered document number that will be entered in the Document No. field, on the journal lines created by the batch job.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if PostingDate = 0D then
              PostingDate := WorkDate;
            ValidatePostingDate;
        end;
    }

    labels
    {
    }

    var
        Text000: Label 'Enter the posting date.';
        Text001: Label 'Enter the document no.';
        Text002: Label 'Processing items    #1##########';
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlLine: Record "Item Journal Line";
        WhseEntry: Record "Warehouse Entry";
        Location: Record Location;
        SourceCodeSetup: Record "Source Code Setup";
        AdjmtBinQuantityBuffer: Record "Bin Content Buffer" temporary;
        TempReservationEntryBuffer: Record "Reservation Entry" temporary;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        UOMMgt: Codeunit "Unit of Measure Management";
        Window: Dialog;
        PostingDate: Date;
        NextDocNo: Code[20];
        WhseQtyBase: Decimal;
        NextLineNo: Integer;
        HideValidationDialog: Boolean;

    [Scope('Personalization')]
    procedure SetItemJnlLine(var NewItemJnlLine: Record "Item Journal Line")
    begin
        ItemJnlLine := NewItemJnlLine;
    end;

    local procedure ValidatePostingDate()
    begin
        ItemJnlBatch.Get(ItemJnlLine."Journal Template Name",ItemJnlLine."Journal Batch Name");
        if ItemJnlBatch."No. Series" = '' then
          NextDocNo := ''
        else begin
          NextDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series",PostingDate,false);
          Clear(NoSeriesMgt);
        end;
    end;

    local procedure InsertItemJnlLine(ItemNo: Code[20];VariantCode2: Code[10];LocationCode2: Code[10];Quantity2: Decimal;QuantityBase2: Decimal;UOM2: Code[10];EntryType2: Option "Negative Adjmt.","Positive Adjmt.")
    begin
        OnBeforeFunctionInsertItemJnlLine(ItemNo,VariantCode2,LocationCode2,Quantity2,QuantityBase2,UOM2,EntryType2);

        with ItemJnlLine do begin
          if NextLineNo = 0 then begin
            LockTable;
            Reset;
            SetRange("Journal Template Name","Journal Template Name");
            SetRange("Journal Batch Name","Journal Batch Name");
            if Find('+') then
              NextLineNo := "Line No.";

            SourceCodeSetup.Get;
          end;
          NextLineNo := NextLineNo + 10000;

          if QuantityBase2 <> 0 then begin
            Init;
            "Line No." := NextLineNo;
            Validate("Posting Date",PostingDate);
            if QuantityBase2 > 0 then
              Validate("Entry Type","Entry Type"::"Positive Adjmt.")
            else begin
              Validate("Entry Type","Entry Type"::"Negative Adjmt.");
              Quantity2 := -Quantity2;
              QuantityBase2 := -QuantityBase2;
            end;
            Validate("Document No.",NextDocNo);
            Validate("Item No.",ItemNo);
            Validate("Variant Code",VariantCode2);
            Validate("Location Code",LocationCode2);
            Validate("Source Code",SourceCodeSetup."Item Journal");
            Validate("Unit of Measure Code",UOM2);
            "Posting No. Series" := ItemJnlBatch."Posting No. Series";

            Validate(Quantity,Quantity2);
            "Quantity (Base)" := QuantityBase2;
            "Invoiced Qty. (Base)" := QuantityBase2;
            "Warehouse Adjustment" := true;
            Insert(true);
            OnAfterInsertItemJnlLine(ItemJnlLine);

            CreateReservationEntry(ItemJnlLine,Item,LocationCode2,EntryType2,UOM2);
          end;
        end;
        OnAfterFunctionInsertItemJnlLine(ItemNo,VariantCode2,LocationCode2,Quantity2,QuantityBase2,UOM2,EntryType2,ItemJnlLine);
    end;

    [Scope('Personalization')]
    procedure InitializeRequest(NewPostingDate: Date;DocNo: Code[20])
    begin
        PostingDate := NewPostingDate;
        NextDocNo := DocNo;
    end;

    [Scope('Personalization')]
    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure FillProspectReservationEntryBuffer(var Item: Record Item;JournalTemplateName: Code[10];JournalBatchName: Code[10])
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        TempReservationEntryBuffer.Reset;
        TempReservationEntryBuffer.DeleteAll;
        ReservationEntry.Reset;
        ReservationEntry.SetRange("Source Type",DATABASE::"Item Journal Line");
        ReservationEntry.SetRange("Source ID",JournalTemplateName);
        ReservationEntry.SetRange("Source Batch Name",JournalBatchName);
        ReservationEntry.SetRange("Reservation Status",ReservationEntry."Reservation Status"::Prospect);
        ReservationEntry.SetRange("Item No.",Item."No.");
        ReservationEntry.SetFilter("Variant Code",Item."Variant Filter");

        if ReservationEntry.FindSet then
          repeat
            TempReservationEntryBuffer := ReservationEntry;
            TempReservationEntryBuffer.Insert;
          until ReservationEntry.Next = 0;
    end;

    local procedure CreateReservationEntry(var ItemJournalLine: Record "Item Journal Line";var Item: Record Item;LocationCode: Code[10];EntryType: Option "Negative Adjmt.","Positive Adjmt.";UOMCode: Code[10])
    var
        Location: Record Location;
        WarehouseEntry: Record "Warehouse Entry";
        WarehouseEntry2: Record "Warehouse Entry";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        OrderLineNo: Integer;
    begin
        if LocationCode = '' then
          exit;

        Location.Get(LocationCode);
        if not Location."Directed Put-away and Pick" then
          exit;

        WarehouseEntry.SetCurrentKey(
          "Item No.","Bin Code","Location Code","Variant Code","Unit of Measure Code","Lot No.","Serial No.","Entry Type");
        WarehouseEntry.SetRange("Item No.",ItemJournalLine."Item No.");
        WarehouseEntry.SetRange("Bin Code",Location."Adjustment Bin Code");
        WarehouseEntry.SetRange("Location Code",ItemJournalLine."Location Code");
        WarehouseEntry.SetRange("Variant Code",ItemJournalLine."Variant Code");
        WarehouseEntry.SetRange("Unit of Measure Code",UOMCode);
        WarehouseEntry.SetFilter("Lot No.",Item.GetFilter("Lot No. Filter"));
        WarehouseEntry.SetFilter("Serial No.",Item.GetFilter("Serial No. Filter"));
        WarehouseEntry.SetFilter("Entry Type",'%1|%2',EntryType,WarehouseEntry."Entry Type"::Movement);
        if not WarehouseEntry.FindSet then
          exit;

        repeat
          TempReservationEntryBuffer.Reset;
          WarehouseEntry.SetRange("Lot No.",WarehouseEntry."Lot No.");
          WarehouseEntry.SetRange("Serial No.",WarehouseEntry."Serial No.");
          WarehouseEntry.CalcSums("Qty. (Base)",Quantity);
          UpdateWarehouseEntryQtyByReservationEntryBuffer(WarehouseEntry,WarehouseEntry."Lot No.",WarehouseEntry."Serial No.");

          WarehouseEntry2.SetCurrentKey(
            "Item No.","Bin Code","Location Code","Variant Code","Unit of Measure Code","Lot No.","Serial No.","Entry Type");
          WarehouseEntry2.CopyFilters(WarehouseEntry);
          case EntryType of
            EntryType::"Positive Adjmt.":
              WarehouseEntry2.SetRange("Entry Type",WarehouseEntry2."Entry Type"::"Negative Adjmt.");
            EntryType::"Negative Adjmt.":
              WarehouseEntry2.SetRange("Entry Type",WarehouseEntry2."Entry Type"::"Positive Adjmt.");
          end;
          WarehouseEntry2.CalcSums("Qty. (Base)",Quantity);
          UpdateWarehouseEntryQtyByReservationEntryBuffer(WarehouseEntry2,WarehouseEntry."Lot No.",WarehouseEntry."Serial No.");

          if Abs(WarehouseEntry2."Qty. (Base)") > Abs(WarehouseEntry."Qty. (Base)") then begin
            WarehouseEntry."Qty. (Base)" := 0;
            WarehouseEntry.Quantity := 0;
          end else begin
            WarehouseEntry."Qty. (Base)" += WarehouseEntry2."Qty. (Base)";
            WarehouseEntry.Quantity += WarehouseEntry2.Quantity;
          end;

          if WarehouseEntry."Qty. (Base)" <> 0 then begin
            if ItemJournalLine."Order Type" = ItemJournalLine."Order Type"::Production then
              OrderLineNo := ItemJournalLine."Order Line No.";

            CreateReservEntry.CreateReservEntryFor(
              DATABASE::"Item Journal Line",ItemJournalLine."Entry Type",ItemJournalLine."Journal Template Name",
              ItemJournalLine."Journal Batch Name",OrderLineNo,ItemJournalLine."Line No.",ItemJournalLine."Qty. per Unit of Measure",
              Abs(WarehouseEntry.Quantity),Abs(WarehouseEntry."Qty. (Base)"),WarehouseEntry."Serial No.",WarehouseEntry."Lot No.");
            if WarehouseEntry."Qty. (Base)" < 0 then             // Only Date on positive adjustments
              CreateReservEntry.SetDates(WarehouseEntry."Warranty Date",WarehouseEntry."Expiration Date");
            CreateReservEntry.CreateEntry(
              ItemJournalLine."Item No.",ItemJournalLine."Variant Code",ItemJournalLine."Location Code",ItemJournalLine.Description,
              0D,0D,0,TempReservationEntryBuffer."Reservation Status"::Prospect);
          end;

          WarehouseEntry.Find('+');
          WarehouseEntry.SetFilter("Lot No.",Item.GetFilter("Lot No. Filter"));
          WarehouseEntry.SetFilter("Serial No.",Item.GetFilter("Serial No. Filter"));
        until WarehouseEntry.Next = 0;
    end;

    local procedure UpdateWarehouseEntryQtyByReservationEntryBuffer(var WarehouseEntry: Record "Warehouse Entry";LotNo: Code[50];SerialNo: Code[50])
    begin
        if WarehouseEntry."Qty. (Base)" = 0 then
          exit;

        if LotNo <> '' then
          TempReservationEntryBuffer.SetRange("Lot No.",LotNo);
        if SerialNo <> '' then
          TempReservationEntryBuffer.SetRange("Serial No.",SerialNo);

        if WarehouseEntry."Qty. (Base)" > 0 then
          TempReservationEntryBuffer.SetRange(Positive,false)
        else
          TempReservationEntryBuffer.SetRange(Positive,true);
        TempReservationEntryBuffer.CalcSums("Quantity (Base)",Quantity);

        WarehouseEntry."Qty. (Base)" += TempReservationEntryBuffer."Quantity (Base)";
        WarehouseEntry.Quantity += TempReservationEntryBuffer.Quantity;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFunctionInsertItemJnlLine(ItemNo: Code[20];VariantCode2: Code[10];LocationCode2: Code[10];Quantity2: Decimal;QuantityBase2: Decimal;UOM2: Code[10];EntryType2: Option "Negative Adjmt.","Positive Adjmt.")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertItemJnlLine(var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFunctionInsertItemJnlLine(ItemNo: Code[20];VariantCode2: Code[10];LocationCode2: Code[10];Quantity2: Decimal;QuantityBase2: Decimal;UOM2: Code[10];EntryType2: Option "Negative Adjmt.","Positive Adjmt.";var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAdjmtBinQuantityBufferInsert(var BinContentBuffer: Record "Bin Content Buffer";WarehouseEntry: Record "Warehouse Entry")
    begin
    end;
}

