report 7305 "Whse.-Source - Create Document"
{
    Caption = 'Whse.-Source - Create Document';
    Permissions = TableData "Whse. Item Tracking Line"=rm;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Posted Whse. Receipt Line";"Posted Whse. Receipt Line")
        {
            DataItemTableView = SORTING("No.","Line No.");

            trigger OnAfterGetRecord()
            var
                PostedWhseReceiptLine2: Record "Posted Whse. Receipt Line";
                TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
                WMSMgt: Codeunit "WMS Management";
                ItemTrackingManagement: Codeunit "Item Tracking Management";
                WhseSNRequired: Boolean;
                WhseLNRequired: Boolean;
            begin
                WMSMgt.CheckOutboundBlockedBin("Location Code","Bin Code","Item No.","Variant Code","Unit of Measure Code");

                WhseWkshLine.SetRange("Whse. Document Line No.","Line No.");
                if not WhseWkshLine.FindFirst then begin
                  PostedWhseReceiptLine2 := "Posted Whse. Receipt Line";
                  PostedWhseReceiptLine2.TestField("Qty. per Unit of Measure");
                  PostedWhseReceiptLine2.CalcFields("Put-away Qty. (Base)");
                  PostedWhseReceiptLine2."Qty. (Base)" :=
                    PostedWhseReceiptLine2."Qty. (Base)" -
                    (PostedWhseReceiptLine2."Qty. Put Away (Base)" +
                     PostedWhseReceiptLine2."Put-away Qty. (Base)");
                  if PostedWhseReceiptLine2."Qty. (Base)" > 0 then begin
                    PostedWhseReceiptLine2.Quantity :=
                      Round(
                        PostedWhseReceiptLine2."Qty. (Base)" /
                        PostedWhseReceiptLine2."Qty. per Unit of Measure",UOMMgt.QtyRndPrecision);

                    ItemTrackingManagement.CheckWhseItemTrkgSetup("Item No.",WhseSNRequired,WhseLNRequired,false);
                    if WhseSNRequired or WhseLNRequired then
                      ItemTrackingManagement.InitItemTrkgForTempWkshLine(
                        WhseWkshLine."Whse. Document Type"::Receipt,
                        PostedWhseReceiptLine2."No.",
                        PostedWhseReceiptLine2."Line No.",
                        PostedWhseReceiptLine2."Source Type",
                        PostedWhseReceiptLine2."Source Subtype",
                        PostedWhseReceiptLine2."Source No.",
                        PostedWhseReceiptLine2."Source Line No.",
                        0);

                    CreatePutAway.SetCrossDockValues(PostedWhseReceiptLine2."Qty. Cross-Docked" <> 0);
                    CreatePutAwayFromDiffSource(PostedWhseReceiptLine2,DATABASE::"Posted Whse. Receipt Line");
                    CreatePutAway.GetQtyHandledBase(TempWhseItemTrkgLine);
                    UpdateWhseItemTrkgLines(PostedWhseReceiptLine2,DATABASE::"Posted Whse. Receipt Line",TempWhseItemTrkgLine);

                    if CreateErrorText = '' then
                      CreatePutAway.GetMessage(CreateErrorText);
                    if EverythingHandled then
                      EverythingHandled := CreatePutAway.EverythingIsHandled;
                  end;
                end;
            end;

            trigger OnPostDataItem()
            begin
                OnAfterPostedWhseReceiptLineOnPostDataItem("Posted Whse. Receipt Line");
            end;

            trigger OnPreDataItem()
            begin
                if WhseDoc <> WhseDoc::"Posted Receipt" then
                  CurrReport.Break;

                CreatePutAway.SetValues(AssignedID,SortActivity,DoNotFillQtytoHandle,BreakbulkFilter);
                CopyFilters(PostedWhseReceiptLine);

                WhseWkshLine.SetCurrentKey("Whse. Document Type","Whse. Document No.","Whse. Document Line No.");
                WhseWkshLine.SetRange(
                  "Whse. Document Type",WhseWkshLine."Whse. Document Type"::Receipt);
                WhseWkshLine.SetRange("Whse. Document No.",PostedWhseReceiptLine."No.");
            end;
        }
        dataitem("Whse. Mov.-Worksheet Line";"Whse. Worksheet Line")
        {
            DataItemTableView = SORTING("Worksheet Template Name",Name,"Location Code","Line No.");

            trigger OnAfterGetRecord()
            var
                ItemTrackingMgt: Codeunit "Item Tracking Management";
                PickQty: Decimal;
                PickQtyBase: Decimal;
            begin
                if FEFOLocation("Location Code") and ItemTracking("Item No.") then
                  CreatePick.SetCalledFromWksh(true)
                else
                  CreatePick.SetCalledFromWksh(false);

                TestField("Qty. per Unit of Measure");
                if WhseWkshLine.CheckAvailQtytoMove < 0 then
                  Error(
                    Text004,
                    TableCaption,FieldCaption("Worksheet Template Name"),"Worksheet Template Name",
                    FieldCaption(Name),Name,FieldCaption("Location Code"),"Location Code",
                    FieldCaption("Line No."),"Line No.");

                CheckBin("Location Code","From Bin Code",false);
                CheckBin("Location Code","To Bin Code",true);
                CreatePick.SetCalledFromWksh(true);
                CreatePick.SetWhseWkshLine("Whse. Mov.-Worksheet Line",1);
                CreatePick.SetTempWhseItemTrkgLine(
                  Name,DATABASE::"Whse. Worksheet Line","Worksheet Template Name",0,
                  "Line No.","Location Code");
                PickQty := "Qty. to Handle";
                PickQtyBase := "Qty. to Handle (Base)";
                CreatePick.CreateTempLine(
                  "Location Code","Item No.","Variant Code","Unit of Measure Code",
                  "From Bin Code","To Bin Code","Qty. per Unit of Measure",PickQty,PickQtyBase);

                WhseWkshLine := "Whse. Mov.-Worksheet Line";
                if WhseWkshLine."Qty. to Handle" = WhseWkshLine."Qty. Outstanding" then begin
                  WhseWkshLine.Delete;
                  ItemTrackingMgt.DeleteWhseItemTrkgLines(
                    DATABASE::"Whse. Worksheet Line",0,Name,"Worksheet Template Name",0,"Line No.","Location Code",true);
                end else begin
                  PickQtyBase := "Qty. Handled (Base)" + "Qty. to Handle (Base)" - PickQtyBase;
                  WhseWkshLine.Validate("Qty. Handled","Qty. Handled" + "Qty. to Handle" - PickQty);
                  WhseWkshLine."Qty. Handled (Base)" := PickQtyBase;
                  WhseWkshLine."Qty. Outstanding (Base)" := "Qty. (Base)" - WhseWkshLine."Qty. Handled (Base)";
                  WhseWkshLine.Modify;
                end;
            end;

            trigger OnPreDataItem()
            begin
                if WhseDoc <> WhseDoc::"Whse. Mov.-Worksheet" then
                  CurrReport.Break;

                CreatePick.SetValues(
                  AssignedID,2,SortActivity,2,0,0,false,DoNotFillQtytoHandle,BreakbulkFilter,false);

                CreatePick.SetCalledFromMoveWksh(true);

                CopyFilters(WhseWkshLine);
                SetFilter("Qty. to Handle (Base)",'>0');
                LockTable;

                OnBeforeProcessWhseMovWkshLines("Whse. Mov.-Worksheet Line");
            end;
        }
        dataitem("Whse. Put-away Worksheet Line";"Whse. Worksheet Line")
        {
            DataItemTableView = SORTING("Worksheet Template Name",Name,"Location Code","Line No.") WHERE("Whse. Document Type"=FILTER(Receipt|"Internal Put-away"));

            trigger OnAfterGetRecord()
            var
                PostedWhseRcptLine: Record "Posted Whse. Receipt Line";
                TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
                QtyHandledBase: Decimal;
                SourceType: Integer;
            begin
                LockTable;

                CheckBin("Location Code","From Bin Code",false);
                if not PostedWhseRcptLine.Get("Whse. Document No.","Whse. Document Line No.") then begin
                  PostedWhseRcptLine.Init;
                  PostedWhseRcptLine."No." := "Whse. Document No.";
                  PostedWhseRcptLine."Line No." := "Whse. Document Line No.";
                  PostedWhseRcptLine."Item No." := "Item No.";
                  PostedWhseRcptLine.Description := Description;
                  PostedWhseRcptLine."Description 2" := "Description 2";
                  PostedWhseRcptLine."Location Code" := "Location Code";
                  PostedWhseRcptLine."Zone Code" := "From Zone Code";
                  PostedWhseRcptLine."Bin Code" := "From Bin Code";
                  PostedWhseRcptLine."Shelf No." := "Shelf No.";
                  PostedWhseRcptLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
                  PostedWhseRcptLine."Due Date" := "Due Date";
                  PostedWhseRcptLine."Unit of Measure Code" := "Unit of Measure Code";
                  SourceType := DATABASE::"Whse. Internal Put-away Line";
                end else
                  SourceType := DATABASE::"Posted Whse. Receipt Line";

                PostedWhseRcptLine.TestField("Qty. per Unit of Measure");
                PostedWhseRcptLine.Quantity := "Qty. to Handle";
                PostedWhseRcptLine."Qty. (Base)" := "Qty. to Handle (Base)";

                CreatePutAway.SetCrossDockValues(PostedWhseRcptLine."Qty. Cross-Docked" <> 0);
                CreatePutAwayFromDiffSource(PostedWhseRcptLine,SourceType);

                if "Qty. to Handle" <> "Qty. Outstanding" then
                  EverythingHandled := false;

                if EverythingHandled then
                  EverythingHandled := CreatePutAway.EverythingIsHandled;

                QtyHandledBase := CreatePutAway.GetQtyHandledBase(TempWhseItemTrkgLine);

                if QtyHandledBase > 0 then begin
                  // update/delete line
                  WhseWkshLine := "Whse. Put-away Worksheet Line";
                  WhseWkshLine.Validate("Qty. Handled (Base)","Qty. Handled (Base)" + QtyHandledBase);
                  if (WhseWkshLine."Qty. Outstanding" = 0) and
                     (WhseWkshLine."Qty. Outstanding (Base)" = 0)
                  then
                    WhseWkshLine.Delete
                  else
                    WhseWkshLine.Modify;
                  UpdateWhseItemTrkgLines(PostedWhseRcptLine,SourceType,TempWhseItemTrkgLine);
                end else
                  if CreateErrorText = '' then
                    CreatePutAway.GetMessage(CreateErrorText);
            end;

            trigger OnPreDataItem()
            begin
                if WhseDoc <> WhseDoc::"Put-away Worksheet" then
                  CurrReport.Break;

                CreatePutAway.SetValues(AssignedID,SortActivity,DoNotFillQtytoHandle,BreakbulkFilter);

                CopyFilters(WhseWkshLine);
                SetFilter("Qty. to Handle (Base)",'>0');
            end;
        }
        dataitem("Whse. Internal Pick Line";"Whse. Internal Pick Line")
        {
            DataItemTableView = SORTING("No.","Line No.");

            trigger OnAfterGetRecord()
            var
                WMSMgt: Codeunit "WMS Management";
                QtyToPick: Decimal;
                QtyToPickBase: Decimal;
            begin
                WMSMgt.CheckInboundBlockedBin("Location Code","To Bin Code","Item No.","Variant Code","Unit of Measure Code");

                CheckBin(false);
                WhseWkshLine.SetRange("Whse. Document Line No.","Line No.");
                if not WhseWkshLine.FindFirst then begin
                  TestField("Qty. per Unit of Measure");
                  CalcFields("Pick Qty. (Base)");
                  QtyToPickBase := "Qty. (Base)" - ("Qty. Picked (Base)" + "Pick Qty. (Base)");
                  QtyToPick :=
                    Round(
                      ("Qty. (Base)" - ("Qty. Picked (Base)" + "Pick Qty. (Base)")) /
                      "Qty. per Unit of Measure",UOMMgt.QtyRndPrecision);
                  if QtyToPick > 0 then begin
                    CreatePick.SetWhseInternalPickLine("Whse. Internal Pick Line",1);
                    CreatePick.SetTempWhseItemTrkgLine(
                      "No.",DATABASE::"Whse. Internal Pick Line",'',0,"Line No.","Location Code");
                    CreatePick.CreateTempLine(
                      "Location Code","Item No.","Variant Code","Unit of Measure Code",
                      '',"To Bin Code","Qty. per Unit of Measure",QtyToPick,QtyToPickBase);
                  end;
                end else
                  WhseWkshLineFound := true;
            end;

            trigger OnPreDataItem()
            begin
                if WhseDoc <> WhseDoc::"Internal Pick" then
                  CurrReport.Break;

                CreatePick.SetValues(
                  AssignedID,3,SortActivity,1,0,0,false,DoNotFillQtytoHandle,BreakbulkFilter,false);

                CopyFilters(WhseInternalPickLine);
                SetFilter("Qty. (Base)",'>0');

                WhseWkshLine.SetCurrentKey("Whse. Document Type","Whse. Document No.","Whse. Document Line No.");
                WhseWkshLine.SetRange(
                  "Whse. Document Type",WhseWkshLine."Whse. Document Type"::"Internal Pick");
                WhseWkshLine.SetRange("Whse. Document No.",WhseInternalPickLine."No.");
            end;
        }
        dataitem("Whse. Internal Put-away Line";"Whse. Internal Put-away Line")
        {
            DataItemTableView = SORTING("No.","Line No.");

            trigger OnAfterGetRecord()
            var
                TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
                WMSMgt: Codeunit "WMS Management";
                QtyToPutAway: Decimal;
            begin
                WMSMgt.CheckOutboundBlockedBin("Location Code","From Bin Code","Item No.","Variant Code","Unit of Measure Code");
                CheckCurrentLineQty;
                WhseWkshLine.SetRange("Whse. Document Line No.","Line No.");
                if not WhseWkshLine.FindFirst then begin
                  TestField("Qty. per Unit of Measure");
                  CalcFields("Put-away Qty. (Base)");
                  QtyToPutAway :=
                    Round(
                      ("Qty. (Base)" - ("Qty. Put Away (Base)" + "Put-away Qty. (Base)")) /
                      "Qty. per Unit of Measure",UOMMgt.QtyRndPrecision);

                  if QtyToPutAway > 0 then
                    with PostedWhseReceiptLine do begin
                      Init;
                      "No." := "Whse. Internal Put-away Line"."No.";
                      "Line No." := "Whse. Internal Put-away Line"."Line No.";
                      "Location Code" := "Whse. Internal Put-away Line"."Location Code";
                      "Bin Code" := "Whse. Internal Put-away Line"."From Bin Code";
                      "Zone Code" := "Whse. Internal Put-away Line"."From Zone Code";
                      "Item No." := "Whse. Internal Put-away Line"."Item No.";
                      "Shelf No." := "Whse. Internal Put-away Line"."Shelf No.";
                      Quantity := QtyToPutAway;
                      "Qty. (Base)" :=
                        "Whse. Internal Put-away Line"."Qty. (Base)" -
                        ("Whse. Internal Put-away Line"."Qty. Put Away (Base)" +
                         "Whse. Internal Put-away Line"."Put-away Qty. (Base)");
                      "Qty. Put Away" := "Whse. Internal Put-away Line"."Qty. Put Away";
                      "Qty. Put Away (Base)" := "Whse. Internal Put-away Line"."Qty. Put Away (Base)";
                      "Put-away Qty." := "Whse. Internal Put-away Line"."Put-away Qty.";
                      "Put-away Qty. (Base)" := "Whse. Internal Put-away Line"."Put-away Qty. (Base)";
                      "Unit of Measure Code" := "Whse. Internal Put-away Line"."Unit of Measure Code";
                      "Qty. per Unit of Measure" := "Whse. Internal Put-away Line"."Qty. per Unit of Measure";
                      "Variant Code" := "Whse. Internal Put-away Line"."Variant Code";
                      Description := "Whse. Internal Put-away Line".Description;
                      "Description 2" := "Whse. Internal Put-away Line"."Description 2";
                      "Due Date" := "Whse. Internal Put-away Line"."Due Date";
                      CreatePutAwayFromDiffSource(PostedWhseReceiptLine,DATABASE::"Whse. Internal Put-away Line");
                      CreatePutAway.GetQtyHandledBase(TempWhseItemTrkgLine);
                      UpdateWhseItemTrkgLines(PostedWhseReceiptLine,DATABASE::"Whse. Internal Put-away Line",TempWhseItemTrkgLine);
                    end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                if WhseDoc <> WhseDoc::"Internal Put-away" then
                  CurrReport.Break;

                CreatePutAway.SetValues(AssignedID,SortActivity,DoNotFillQtytoHandle,BreakbulkFilter);

                SetRange("No.",WhseInternalPutAwayHeader."No.");
                SetFilter("Qty. (Base)",'>0');

                WhseWkshLine.SetCurrentKey("Whse. Document Type","Whse. Document No.","Whse. Document Line No.");
                WhseWkshLine.SetRange(
                  "Whse. Document Type",WhseWkshLine."Whse. Document Type"::"Internal Put-away");
                WhseWkshLine.SetRange("Whse. Document No.",WhseInternalPutAwayHeader."No.");

                OnBeforeProcessWhseMovWkshLines("Whse. Put-away Worksheet Line");
            end;
        }
        dataitem("Prod. Order Component";"Prod. Order Component")
        {
            DataItemTableView = SORTING(Status,"Prod. Order No.","Prod. Order Line No.","Line No.");

            trigger OnAfterGetRecord()
            var
                WMSMgt: Codeunit "WMS Management";
                QtyToPick: Decimal;
                QtyToPickBase: Decimal;
                SkipProdOrderComp: Boolean;
            begin
                if ("Flushing Method" = "Flushing Method"::"Pick + Forward") and ("Routing Link Code" = '') then
                  CurrReport.Skip;

                WMSMgt.CheckInboundBlockedBin("Location Code","Bin Code","Item No.","Variant Code","Unit of Measure Code");

                SkipProdOrderComp := false;
                OnAfterGetRecordProdOrderComponent("Prod. Order Component",SkipProdOrderComp);
                if SkipProdOrderComp then
                  CurrReport.Skip;

                WhseWkshLine.SetRange("Source Line No.","Prod. Order Line No.");
                WhseWkshLine.SetRange("Source Subline No.","Line No.");
                if not WhseWkshLine.FindFirst then begin
                  TestField("Qty. per Unit of Measure");
                  CalcFields("Pick Qty. (Base)");
                  QtyToPickBase := "Expected Qty. (Base)" - ("Qty. Picked (Base)" + "Pick Qty. (Base)");
                  QtyToPick :=
                    Round(
                      ("Expected Qty. (Base)" - ("Qty. Picked (Base)" + "Pick Qty. (Base)")) /
                      "Qty. per Unit of Measure",UOMMgt.QtyRndPrecision);
                  if QtyToPick > 0 then begin
                    CreatePick.SetProdOrderCompLine("Prod. Order Component",1);
                    CreatePick.SetTempWhseItemTrkgLine(
                      "Prod. Order No.",DATABASE::"Prod. Order Component",'',
                      "Prod. Order Line No.","Line No.","Location Code");
                    CreatePick.CreateTempLine(
                      "Location Code","Item No.","Variant Code","Unit of Measure Code",
                      '',"Bin Code",
                      "Qty. per Unit of Measure",QtyToPick,QtyToPickBase);
                  end;
                end else
                  WhseWkshLineFound := true;
            end;

            trigger OnPreDataItem()
            begin
                if WhseDoc <> WhseDoc::Production then
                  CurrReport.Break;

                WhseSetup.Get;
                CreatePick.SetValues(
                  AssignedID,4,SortActivity,1,0,0,false,DoNotFillQtytoHandle,BreakbulkFilter,false);

                SetRange("Prod. Order No.",ProdOrderHeader."No.");
                SetRange(Status,Status::Released);
                SetFilter(
                  "Flushing Method",'%1|%2|%3',
                  "Flushing Method"::Manual,
                  "Flushing Method"::"Pick + Forward",
                  "Flushing Method"::"Pick + Backward");
                SetRange("Planning Level Code",0);
                SetFilter("Expected Qty. (Base)",'>0');

                WhseWkshLine.SetCurrentKey(
                  "Source Type","Source Subtype","Source No.","Source Line No.","Source Subline No.");
                WhseWkshLine.SetRange("Source Type",DATABASE::"Prod. Order Component");
                WhseWkshLine.SetRange("Source Subtype",ProdOrderHeader.Status);
                WhseWkshLine.SetRange("Source No.",ProdOrderHeader."No.");
            end;
        }
        dataitem("Assembly Line";"Assembly Line")
        {
            DataItemTableView = SORTING("Document Type","Document No.",Type,"Location Code") WHERE(Type=CONST(Item));

            trigger OnAfterGetRecord()
            var
                WMSMgt: Codeunit "WMS Management";
            begin
                WMSMgt.CheckInboundBlockedBin("Location Code","Bin Code","No.","Variant Code","Unit of Measure Code");

                WhseWkshLine.SetRange("Source Line No.","Line No.");
                if not WhseWkshLine.FindFirst then
                  CreatePick.CreateAssemblyPickLine("Assembly Line")
                else
                  WhseWkshLineFound := true;
            end;

            trigger OnPreDataItem()
            begin
                if WhseDoc <> WhseDoc::Assembly then
                  CurrReport.Break;

                WhseSetup.Get;
                CreatePick.SetValues(
                  AssignedID,5,SortActivity,1,0,0,false,DoNotFillQtytoHandle,BreakbulkFilter,false);

                SetRange("Document No.",AssemblyHeader."No.");
                SetRange("Document Type",AssemblyHeader."Document Type");
                SetRange(Type,Type::Item);
                SetFilter("Remaining Quantity (Base)",'>0');

                WhseWkshLine.SetCurrentKey(
                  "Source Type","Source Subtype","Source No.","Source Line No.","Source Subline No.");
                WhseWkshLine.SetRange("Source Type",DATABASE::"Assembly Line");
                WhseWkshLine.SetRange("Source Subtype",AssemblyHeader."Document Type");
                WhseWkshLine.SetRange("Source No.",AssemblyHeader."No.");
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(AssignedID;AssignedID)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Assigned User ID';
                        TableRelation = "Warehouse Employee";
                        ToolTip = 'Specifies the ID of the assigned user to perform the pick instruction.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            WhseEmployee: Record "Warehouse Employee";
                            LookupWhseEmployee: Page "Warehouse Employee List";
                        begin
                            WhseEmployee.SetCurrentKey("Location Code");
                            WhseEmployee.SetRange("Location Code",GetHeaderLocationCode);
                            LookupWhseEmployee.LookupMode(true);
                            LookupWhseEmployee.SetTableView(WhseEmployee);
                            if LookupWhseEmployee.RunModal = ACTION::LookupOK then begin
                              LookupWhseEmployee.GetRecord(WhseEmployee);
                              AssignedID := WhseEmployee."User ID";
                            end;
                        end;

                        trigger OnValidate()
                        var
                            WhseEmployee: Record "Warehouse Employee";
                        begin
                            if AssignedID <> '' then
                              WhseEmployee.Get(AssignedID,GetHeaderLocationCode);
                        end;
                    }
                    field(SortingMethodForActivityLines;SortActivity)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Sorting Method for Activity Lines';
                        MultiLine = true;
                        OptionCaption = ' ,Item,Document,Shelf or Bin,Due Date,,Bin Ranking,Action Type';
                        ToolTip = 'Specifies the method by which the lines in the instruction will be sorted. The options are by item, document, shelf or bin (when the location uses bins, this is the bin code), due date, bin ranking, or action type.';
                    }
                    field(BreakbulkFilter;BreakbulkFilter)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Set Breakbulk Filter';
                        ToolTip = 'Specifies if you want the program to hide intermediate break-bulk lines when an entire larger unit of measure is converted to a smaller unit of measure and picked completely.';
                    }
                    field(DoNotFillQtytoHandle;DoNotFillQtytoHandle)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Do Not Fill Qty. to Handle';
                        ToolTip = 'Specifies if you want to manually fill in the Quantity to Handle field on each line.';
                    }
                    field(PrintDoc;PrintDoc)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Print Document';
                        ToolTip = 'Specifies if you want the instructions to be printed. Otherwise, you can print it later from the warehouse instruction window.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        var
            Location: Record Location;
        begin
            GetLocation(Location,GetHeaderLocationCode);
            if Location."Use ADCS" then
              DoNotFillQtytoHandle := true;

            OnAfterOpenPage(Location);
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    var
        WhseActivHeader: Record "Warehouse Activity Header";
        TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        if (CreateErrorText <> '') and (FirstActivityNo = '') and (LastActivityNo = '') then
          Error(CreateErrorText);
        if not (WhseDoc in
                [WhseDoc::"Put-away Worksheet",WhseDoc::"Posted Receipt",WhseDoc::"Internal Put-away"])
        then begin
          CreatePick.CreateWhseDocument(FirstActivityNo,LastActivityNo,true);
          CreatePick.ReturnTempItemTrkgLines(TempWhseItemTrkgLine);
          ItemTrackingMgt.UpdateWhseItemTrkgLines(TempWhseItemTrkgLine);
          Commit;
        end else
          CreatePutAway.GetWhseActivHeaderNo(FirstActivityNo,LastActivityNo);

        WhseActivHeader.SetRange("No.",FirstActivityNo,LastActivityNo);

        case WhseDoc of
          WhseDoc::"Internal Pick",WhseDoc::Production,WhseDoc::Assembly:
            WhseActivHeader.SetRange(Type,WhseActivHeader.Type::Pick);
          WhseDoc::"Whse. Mov.-Worksheet":
            WhseActivHeader.SetRange(Type,WhseActivHeader.Type::Movement);
          WhseDoc::"Posted Receipt",WhseDoc::"Put-away Worksheet",WhseDoc::"Internal Put-away":
            WhseActivHeader.SetRange(Type,WhseActivHeader.Type::"Put-away");
        end;

        if WhseActivHeader.Find('-') then begin
          repeat
            CreatePutAway.DeleteBlankBinContent(WhseActivHeader);
            if SortActivity > 0 then
              WhseActivHeader.SortWhseDoc;
            Commit;
          until WhseActivHeader.Next = 0;

          if PrintDoc then begin
            case WhseDoc of
              WhseDoc::"Internal Pick",WhseDoc::Production,WhseDoc::Assembly:
                REPORT.Run(REPORT::"Picking List",false,false,WhseActivHeader);
              WhseDoc::"Whse. Mov.-Worksheet":
                REPORT.Run(REPORT::"Movement List",false,false,WhseActivHeader);
              WhseDoc::"Posted Receipt",WhseDoc::"Put-away Worksheet",WhseDoc::"Internal Put-away":
                REPORT.Run(REPORT::"Put-away List",false,false,WhseActivHeader);
            end
          end
        end else
          Error(Text003);

        OnAfterPostReport(FirstActivityNo,LastActivityNo);
    end;

    trigger OnPreReport()
    begin
        Clear(CreatePick);
        Clear(CreatePutAway);
        EverythingHandled := true;
    end;

    var
        WhseSetup: Record "Warehouse Setup";
        WhseWkshLine: Record "Whse. Worksheet Line";
        WhseInternalPickLine: Record "Whse. Internal Pick Line";
        WhseInternalPutAwayHeader: Record "Whse. Internal Put-away Header";
        ProdOrderHeader: Record "Production Order";
        AssemblyHeader: Record "Assembly Header";
        PostedWhseReceiptLine: Record "Posted Whse. Receipt Line";
        CreatePick: Codeunit "Create Pick";
        CreatePutAway: Codeunit "Create Put-away";
        UOMMgt: Codeunit "Unit of Measure Management";
        FirstActivityNo: Code[20];
        LastActivityNo: Code[20];
        AssignedID: Code[50];
        WhseDoc: Option "Whse. Mov.-Worksheet","Posted Receipt","Internal Pick","Internal Put-away",Production,"Put-away Worksheet",Assembly,"Service Order";
        SortActivity: Option " ",Item,Document,"Shelf/Bin No.","Due Date","Ship-To","Bin Ranking","Action Type";
        SourceTableCaption: Text[30];
        CreateErrorText: Text[80];
        Text000: Label '%1 activity no. %2 has been created.';
        Text001: Label '%1 activities no. %2 to %3 have been created.';
        PrintDoc: Boolean;
        EverythingHandled: Boolean;
        WhseWkshLineFound: Boolean;
        Text002: Label '\For %1 with existing Warehouse Worksheet Lines, no %2 lines have been created.';
        HideValidationDialog: Boolean;
        Text003: Label 'There is nothing to handle.';
        DoNotFillQtytoHandle: Boolean;
        Text004: Label 'You can create a Movement only for the available quantity in %1 %2 = %3,%4 = %5,%6 = %7,%8 = %9.';
        BreakbulkFilter: Boolean;

    [Scope('Personalization')]
    procedure SetPostedWhseReceiptLine(var PostedWhseReceiptLine2: Record "Posted Whse. Receipt Line";AssignedID2: Code[50])
    begin
        PostedWhseReceiptLine.Copy(PostedWhseReceiptLine2);
        WhseDoc := WhseDoc::"Posted Receipt";
        SourceTableCaption := PostedWhseReceiptLine.TableCaption;
        AssignedID := AssignedID2;
    end;

    [Scope('Personalization')]
    procedure SetWhseWkshLine(var WhseWkshLine2: Record "Whse. Worksheet Line")
    begin
        WhseWkshLine.Copy(WhseWkshLine2);
        case WhseWkshLine."Whse. Document Type" of
          WhseWkshLine."Whse. Document Type"::Receipt,
          WhseWkshLine."Whse. Document Type"::"Internal Put-away":
            WhseDoc := WhseDoc::"Put-away Worksheet";
          WhseWkshLine."Whse. Document Type"::" ":
            WhseDoc := WhseDoc::"Whse. Mov.-Worksheet";
        end;
    end;

    [Scope('Personalization')]
    procedure SetWhseInternalPickLine(var WhseInternalPickLine2: Record "Whse. Internal Pick Line";AssignedID2: Code[50])
    begin
        WhseInternalPickLine.Copy(WhseInternalPickLine2);
        WhseDoc := WhseDoc::"Internal Pick";
        SourceTableCaption := WhseInternalPickLine.TableCaption;
        AssignedID := AssignedID2;
    end;

    [Scope('Personalization')]
    procedure SetWhseInternalPutAway(var WhseInternalPutAwayHeader2: Record "Whse. Internal Put-away Header")
    begin
        WhseInternalPutAwayHeader.Copy(WhseInternalPutAwayHeader2);
        WhseDoc := WhseDoc::"Internal Put-away";
        SourceTableCaption := WhseInternalPutAwayHeader.TableCaption;
        AssignedID := WhseInternalPutAwayHeader2."Assigned User ID";
    end;

    [Scope('Personalization')]
    procedure SetProdOrder(var ProdOrderHeader2: Record "Production Order")
    begin
        ProdOrderHeader.Copy(ProdOrderHeader2);
        WhseDoc := WhseDoc::Production;
        SourceTableCaption := ProdOrderHeader.TableCaption;
    end;

    [Scope('Personalization')]
    procedure SetAssemblyOrder(var AssemblyHeader2: Record "Assembly Header")
    begin
        AssemblyHeader.Copy(AssemblyHeader2);
        WhseDoc := WhseDoc::Assembly;
        SourceTableCaption := AssemblyHeader.TableCaption;
    end;

    [Scope('Personalization')]
    procedure GetResultMessage(WhseDocType: Option): Boolean
    var
        WhseActivHeader: Record "Warehouse Activity Header";
    begin
        if FirstActivityNo = '' then
          exit(false);

        if not HideValidationDialog then begin
          WhseActivHeader.Type := WhseDocType;
          if WhseWkshLineFound then begin
            if FirstActivityNo = LastActivityNo then
              Message(
                StrSubstNo(
                  Text000,Format(WhseActivHeader.Type),FirstActivityNo) +
                StrSubstNo(
                  Text002,SourceTableCaption,Format(WhseActivHeader.Type)))
            else
              Message(
                StrSubstNo(
                  Text001,
                  Format(WhseActivHeader.Type),FirstActivityNo,LastActivityNo) +
                StrSubstNo(
                  Text002,SourceTableCaption,Format(WhseActivHeader.Type)));
          end else begin
            if FirstActivityNo = LastActivityNo then
              Message(Text000,Format(WhseActivHeader.Type),FirstActivityNo)
            else
              Message(Text001,Format(WhseActivHeader.Type),FirstActivityNo,LastActivityNo);
          end;
        end;
        exit(EverythingHandled);
    end;

    [Scope('Personalization')]
    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure GetLocation(var Location: Record Location;LocationCode: Code[10])
    begin
        if Location.Code <> LocationCode then
          if LocationCode = '' then
            Clear(Location)
          else
            Location.Get(LocationCode);
    end;

    [Scope('Personalization')]
    procedure Initialize(AssignedID2: Code[50];SortActivity2: Option " ",Item,Document,"Shelf/Bin No.","Due Date","Ship-To","Bin Ranking","Action Type";PrintDoc2: Boolean;DoNotFillQtytoHandle2: Boolean;BreakbulkFilter2: Boolean)
    begin
        AssignedID := AssignedID2;
        SortActivity := SortActivity2;
        PrintDoc := PrintDoc2;
        DoNotFillQtytoHandle := DoNotFillQtytoHandle2;
        BreakbulkFilter := BreakbulkFilter2;
    end;

    [Scope('Personalization')]
    procedure SetQuantity(var PostedWhseRcptLine: Record "Posted Whse. Receipt Line";SourceType: Integer;var QtyToHandleBase: Decimal)
    var
        WhseItemTrackingLine: Record "Whse. Item Tracking Line";
    begin
        with WhseItemTrackingLine do begin
          Reset;
          SetCurrentKey("Serial No.","Lot No.");
          SetRange("Serial No.",PostedWhseRcptLine."Serial No.");
          SetRange("Lot No.",PostedWhseRcptLine."Lot No.");
          SetRange("Source Type",SourceType);
          SetRange("Source ID",PostedWhseRcptLine."No.");
          SetRange("Source Ref. No.",PostedWhseRcptLine."Line No.");
          if FindFirst then begin
            if QtyToHandleBase < "Qty. to Handle (Base)" then
              PostedWhseRcptLine."Qty. (Base)" := QtyToHandleBase
            else
              PostedWhseRcptLine."Qty. (Base)" := "Qty. to Handle (Base)";
            QtyToHandleBase -= PostedWhseRcptLine."Qty. (Base)";
            PostedWhseRcptLine.Quantity :=
              Round(PostedWhseRcptLine."Qty. (Base)" / PostedWhseRcptLine."Qty. per Unit of Measure",UOMMgt.QtyRndPrecision);
          end;
        end
    end;

    [Scope('Personalization')]
    procedure UpdateWhseItemTrkgLines(PostedWhseRcptLine: Record "Posted Whse. Receipt Line";SourceType: Integer;var TempWhseItemTrkgLine: Record "Whse. Item Tracking Line")
    var
        WhseItemTrackingLine: Record "Whse. Item Tracking Line";
    begin
        with WhseItemTrackingLine do begin
          Reset;
          SetCurrentKey(
            "Source ID","Source Type","Source Subtype","Source Batch Name",
            "Source Prod. Order Line","Source Ref. No.");
          SetRange("Source ID",PostedWhseRcptLine."No.");
          SetRange("Source Type",SourceType);
          SetRange("Source Subtype",0);
          SetRange("Source Batch Name",'');
          SetRange("Source Prod. Order Line",0);
          SetRange("Source Ref. No.",PostedWhseRcptLine."Line No.");
          if Find('-') then
            repeat
              TempWhseItemTrkgLine.SetRange("Source Type","Source Type");
              TempWhseItemTrkgLine.SetRange("Source ID","Source ID");
              TempWhseItemTrkgLine.SetRange("Source Ref. No.","Source Ref. No.");
              TempWhseItemTrkgLine.SetRange("Serial No.","Serial No.");
              TempWhseItemTrkgLine.SetRange("Lot No.","Lot No.");
              if TempWhseItemTrkgLine.Find('-') then
                "Quantity Handled (Base)" += TempWhseItemTrkgLine."Quantity (Base)";
              "Qty. to Handle (Base)" := "Quantity (Base)" - "Quantity Handled (Base)";
              Modify;
            until Next = 0;
        end
    end;

    [Scope('Personalization')]
    procedure CreatePutAwayFromDiffSource(PostedWhseRcptLine: Record "Posted Whse. Receipt Line";SourceType: Integer)
    var
        TempPostedWhseRcptLine: Record "Posted Whse. Receipt Line" temporary;
        TempPostedWhseRcptLine2: Record "Posted Whse. Receipt Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        RemQtyToHandleBase: Decimal;
    begin
        case SourceType of
          DATABASE::"Whse. Internal Put-away Line":
            ItemTrackingMgt.SplitInternalPutAwayLine(PostedWhseRcptLine,TempPostedWhseRcptLine);
          DATABASE::"Posted Whse. Receipt Line":
            ItemTrackingMgt.SplitPostedWhseRcptLine(PostedWhseRcptLine,TempPostedWhseRcptLine);
        end;
        RemQtyToHandleBase := PostedWhseRcptLine."Qty. (Base)";

        TempPostedWhseRcptLine.Reset;
        if TempPostedWhseRcptLine.Find('-') then
          repeat
            TempPostedWhseRcptLine2 := TempPostedWhseRcptLine;
            TempPostedWhseRcptLine2."Line No." := PostedWhseRcptLine."Line No.";
            SetQuantity(TempPostedWhseRcptLine2,SourceType,RemQtyToHandleBase);
            if TempPostedWhseRcptLine2."Qty. (Base)" > 0 then begin
              CreatePutAway.Run(TempPostedWhseRcptLine2);
              CreatePutAway.UpdateTempWhseItemTrkgLines(TempPostedWhseRcptLine2,SourceType);
            end;
          until TempPostedWhseRcptLine.Next = 0;
    end;

    [Scope('Personalization')]
    procedure FEFOLocation(LocCode: Code[10]): Boolean
    var
        Location2: Record Location;
    begin
        if LocCode <> '' then begin
          Location2.Get(LocCode);
          exit(Location2."Pick According to FEFO");
        end;
        exit(false);
    end;

    [Scope('Personalization')]
    procedure ItemTracking(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if ItemNo <> '' then begin
          Item.Get(ItemNo);
          if Item."Item Tracking Code" <> '' then begin
            ItemTrackingCode.Get(Item."Item Tracking Code");
            exit((ItemTrackingCode."SN Specific Tracking" or ItemTrackingCode."Lot Specific Tracking"));
          end;
        end;
        exit(false);
    end;

    local procedure GetHeaderLocationCode(): Code[10]
    begin
        case WhseDoc of
          WhseDoc::"Posted Receipt":
            exit(PostedWhseReceiptLine."Location Code");
          WhseDoc::"Put-away Worksheet",
          WhseDoc::"Whse. Mov.-Worksheet":
            exit(WhseWkshLine."Location Code");
          WhseDoc::"Internal Pick":
            exit(WhseInternalPickLine."Location Code");
          WhseDoc::"Internal Put-away":
            exit(WhseInternalPutAwayHeader."Location Code");
          WhseDoc::Production:
            exit(ProdOrderHeader."Location Code");
          WhseDoc::Assembly:
            exit(AssemblyHeader."Location Code");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetRecordProdOrderComponent(var ProdOrderComponent: Record "Prod. Order Component";var SkipProdOrderComp: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, TRUE)]
    local procedure OnAfterOpenPage(var Location: Record Location)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostReport(FirstActivityNo: Code[20];LastActivityNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostedWhseReceiptLineOnPostDataItem(var PostedWhseReceiptLine: Record "Posted Whse. Receipt Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessWhseMovWkshLines(var WhseWorksheetLine: Record "Whse. Worksheet Line")
    begin
    end;
}

