report 99001043 "Exchange Production BOM Item"
{
    ApplicationArea = Manufacturing;
    Caption = 'Exchange Production BOM Item';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Integer";"Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;

            trigger OnPostDataItem()
            var
                ProdBOMHeader2: Record "Production BOM Header";
                FirstVersion: Boolean;
            begin
                Window.Open(
                  Text004 +
                  Text005);

                Window.Update(1,SelectStr(Type[1] + 1,TypeTxt));
                Window.Update(2,No[1]);

                ProdBOMLine.SetCurrentKey(Type,"No.");
                ProdBOMLine.SetRange(Type,Type[1]);
                ProdBOMLine.SetRange("No.",No[1]);

                if ProdBOMLine.Find('+') then
                  repeat
                    FirstVersion := true;
                    ProdBOMHeader.Get(ProdBOMLine."Production BOM No.");
                    if ProdBOMLine."Version Code" <> '' then begin
                      ProdBOMVersionList.Get(
                        ProdBOMLine."Production BOM No.",ProdBOMLine."Version Code");
                      ProdBOMHeader.Status := ProdBOMVersionList.Status;
                      ProdBOMHeader2 := ProdBOMHeader;
                      ProdBOMHeader2."Unit of Measure Code" := ProdBOMVersionList."Unit of Measure Code";
                    end else begin
                      ProdBOMVersionList.SetRange("Production BOM No.");
                      ProdBOMVersionList."Version Code" := '';
                      ProdBOMHeader2 := ProdBOMHeader;
                    end;

                    if IsActiveBOMVersion(ProdBOMHeader,ProdBOMLine) then begin
                      Window.Update(3,ProdBOMLine."Production BOM No.");
                      if not CreateNewVersion then begin
                        if ProdBOMLine."Version Code" <> '' then begin
                          ProdBOMVersionList.Status := ProdBOMVersionList.Status::"Under Development";
                          ProdBOMVersionList.Modify;
                          ProdBOMVersionList.Mark(true);
                        end else begin
                          ProdBOMHeader.Status := ProdBOMHeader.Status::"Under Development";
                          ProdBOMHeader.Modify;
                          ProdBOMHeader.Mark(true);
                        end;
                      end else begin
                        if ProdBOMLine."Production BOM No." <> ProdBOMLine2."Production BOM No." then begin
                          ProdBOMVersionList.SetRange("Production BOM No.",ProdBOMLine."Production BOM No.");

                          if ProdBOMVersionList.Find('+') then
                            ProdBOMVersionList."Version Code" := IncrementVersionNo(ProdBOMVersionList."Production BOM No.")
                          else begin
                            ProdBOMVersionList."Production BOM No." := ProdBOMLine."Production BOM No.";
                            ProdBOMVersionList."Version Code" := '1';
                          end;
                          ProdBOMVersionList.Description := ProdBOMHeader2.Description;
                          ProdBOMVersionList.Validate("Starting Date",StartingDate);
                          ProdBOMVersionList."Unit of Measure Code" := ProdBOMHeader2."Unit of Measure Code";
                          ProdBOMVersionList."Last Date Modified" := Today;
                          ProdBOMVersionList.Status := ProdBOMVersionList.Status::New;
                          if  ProdBOMHeader2."Version Nos." <> '' then begin
                            ProdBOMVersionList."No. Series" := ProdBOMHeader2."Version Nos.";
                            ProdBOMVersionList."Version Code" := '';
                            ProdBOMVersionList.Insert(true);
                          end else
                            ProdBOMVersionList.Insert;
                          ProdBOMVersionList.Mark(true);
                          ProdBOMLine3.Reset;
                          ProdBOMLine3.SetRange("Production BOM No.",ProdBOMLine."Production BOM No.");
                          ProdBOMLine3.SetRange("Version Code",ProdBOMLine."Version Code");
                          if ProdBOMLine3.Find('-') then
                            repeat
                              if (ProdBOMLine.Type <> ProdBOMLine3.Type) or
                                 (ProdBOMLine."No." <> ProdBOMLine3."No.")
                              then begin
                                ProdBOMLine2 := ProdBOMLine3;
                                ProdBOMLine2."Version Code" := ProdBOMVersionList."Version Code";
                                ProdBOMLine2.Insert;
                              end;
                            until ProdBOMLine3.Next = 0;
                        end else
                          FirstVersion := false;
                      end;

                      if (No[2] <> '') and FirstVersion then
                        if CreateNewVersion then begin
                          ProdBOMLine3.SetCurrentKey("Production BOM No.","Version Code");
                          ProdBOMLine3.SetRange(Type,Type[1]);
                          ProdBOMLine3.SetRange("No.",No[1]);
                          ProdBOMLine3.SetRange("Production BOM No.",ProdBOMLine."Production BOM No.");
                          ProdBOMLine3.SetRange("Version Code",ProdBOMLine."Version Code");
                          if ProdBOMLine3.Find('-') then
                            repeat
                              ProdBOMLine2 := ProdBOMLine3;
                              ProdBOMLine2."Version Code" := ProdBOMVersionList."Version Code";
                              ProdBOMLine2.Validate(Type,Type[2]);
                              ProdBOMLine2.Validate("No.",No[2]);
                              ProdBOMLine2.Validate("Quantity per",ProdBOMLine3."Quantity per" * QtyMultiply);
                              if CopyRoutingLink then
                                ProdBOMLine2.Validate("Routing Link Code",ProdBOMLine3."Routing Link Code");
                              ProdBOMLine2."Ending Date" := 0D;
                              OnBeforeInsertNewProdBOMLine(ProdBOMLine2,ProdBOMLine3);
                              ProdBOMLine2.Insert;
                            until ProdBOMLine3.Next = 0;
                        end else begin
                          ProdBOMLine3.SetRange("Production BOM No.",ProdBOMLine."Production BOM No.");
                          ProdBOMLine3.SetRange("Version Code",ProdBOMVersionList."Version Code");
                          if not ProdBOMLine3.Find('+') then
                            Clear(ProdBOMLine3);
                          ProdBOMLine3."Line No." := ProdBOMLine3."Line No." + 10000;
                          ProdBOMLine2 := ProdBOMLine;
                          ProdBOMLine2."Version Code" := ProdBOMVersionList."Version Code";
                          ProdBOMLine2."Line No." := ProdBOMLine3."Line No.";
                          ProdBOMLine2.Validate(Type,Type[2]);
                          ProdBOMLine2.Validate("No.",No[2]);
                          ProdBOMLine2.Validate("Quantity per",ProdBOMLine."Quantity per" * QtyMultiply);
                          if CopyRoutingLink then
                            ProdBOMLine2.Validate("Routing Link Code",ProdBOMLine."Routing Link Code");
                          if not CreateNewVersion then
                            ProdBOMLine2."Starting Date" := StartingDate;
                          ProdBOMLine2."Ending Date" := 0D;
                          ProdBOMLine2.Insert;
                          if DeleteExcComp then
                            ProdBOMLine.Delete(true)
                          else begin
                            ProdBOMLine."Ending Date" := StartingDate - 1;
                            ProdBOMLine.Modify;
                          end;
                        end;
                    end;
                  until ProdBOMLine.Next(-1) = 0;
            end;
        }
        dataitem(RecertifyLoop;"Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;

            trigger OnAfterGetRecord()
            begin
                if Recertify then begin
                  ProdBOMHeader.MarkedOnly(true);
                  if ProdBOMHeader.Find('-') then
                    repeat
                      ProdBOMHeader.Validate(Status,ProdBOMHeader.Status::Certified);
                      ProdBOMHeader.Modify;
                    until ProdBOMHeader.Next = 0;

                  ProdBOMVersionList.SetRange("Production BOM No.");
                  ProdBOMVersionList.MarkedOnly(true);
                  if ProdBOMVersionList.Find('-') then
                    repeat
                      ProdBOMVersionList.Validate(Status,ProdBOMVersionList.Status::Certified);
                      ProdBOMVersionList.Modify;
                    until ProdBOMVersionList.Next = 0;
                end;
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
                    group(Exchange)
                    {
                        Caption = 'Exchange';
                        field(ExchangeType;Type[1])
                        {
                            ApplicationArea = Manufacturing;
                            Caption = 'Type';
                            OptionCaption = ' ,Item,Production BOM';
                            ToolTip = 'Specifies what is to be exchanged here - Item or Production BOM.';

                            trigger OnValidate()
                            begin
                                No[1] := '';
                            end;
                        }
                        field(ExchangeNo;No[1])
                        {
                            ApplicationArea = Manufacturing;
                            Caption = 'No.';
                            ToolTip = 'Specifies the number of the item.';

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                case Type[1] of
                                  Type[1]::Item:
                                    if PAGE.RunModal(0,Item) = ACTION::LookupOK then begin
                                      Text := Item."No.";
                                      exit(true);
                                    end;
                                  Type[1]::"Production BOM":
                                    if PAGE.RunModal(0,ProdBOMHeader) = ACTION::LookupOK then begin
                                      Text := ProdBOMHeader."No.";
                                      exit(true);
                                    end;
                                end;
                            end;

                            trigger OnValidate()
                            begin
                                if Type[1] = Type::" " then
                                  Error(Text006);

                                case Type[1] of
                                  Type[1]::Item:
                                    Item.Get(No[1]);
                                  Type[1]::"Production BOM":
                                    ProdBOMHeader.Get(No[1]);
                                end;
                            end;
                        }
                    }
                    group("With")
                    {
                        Caption = 'With';
                        field(WithType;Type[2])
                        {
                            ApplicationArea = Manufacturing;
                            Caption = 'Type';
                            OptionCaption = ' ,Item,Production BOM';
                            ToolTip = 'Specifies your new selection that will replace what you selected in the Exchange Type field - Item or Production BOM.';

                            trigger OnValidate()
                            begin
                                No[2] := '';
                            end;
                        }
                        field(WithNo;No[2])
                        {
                            ApplicationArea = Manufacturing;
                            Caption = 'No.';
                            ToolTip = 'Specifies the number of the item.';

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                case Type[2] of
                                  Type[2]::Item:
                                    if PAGE.RunModal(0,Item) = ACTION::LookupOK then begin
                                      Text := Item."No.";
                                      exit(true);
                                    end;
                                  Type[2]::"Production BOM":
                                    if PAGE.RunModal(0,ProdBOMHeader) = ACTION::LookupOK then begin
                                      Text := ProdBOMHeader."No.";
                                      exit(true);
                                    end;
                                end;
                                exit(false);
                            end;

                            trigger OnValidate()
                            begin
                                if Type[1] = Type::" " then
                                  Error(Text006);

                                case Type[2] of
                                  Type[2]::Item:
                                    Item.Get(No[2]);
                                  Type[2]::"Production BOM":
                                    ProdBOMHeader.Get(No[2]);
                                end;
                            end;
                        }
                    }
                    field("Create New Version";CreateNewVersion)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Create New Version';
                        Editable = CreateNewVersionEditable;
                        ToolTip = 'Specifies if you want to make the exchange in a new version.';

                        trigger OnValidate()
                        begin
                            CreateNewVersionOnAfterValidat;
                        end;
                    }
                    field(MultiplyQtyWith;QtyMultiply)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Multiply Qty. with';
                        DecimalPlaces = 0:5;
                        ToolTip = 'Specifies the value of a quantity change here. If the quantity is to remain the same, enter 1 here. If you enter 2, the new quantities doubled in comparison with original quantity.';
                    }
                    field(StartingDate;StartingDate)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the date from which these changes are to become valid.';
                    }
                    field(Recertify;Recertify)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Recertify';
                        ToolTip = 'Specifies if you want the production BOM to be certified after the change.';
                    }
                    field(CopyRoutingLink;CopyRoutingLink)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Copy Routing Link';
                        ToolTip = 'Specifies whether or not you want the routing link copied.';
                    }
                    field("Delete Exchanged Component";DeleteExcComp)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Delete Exchanged Component';
                        Editable = DeleteExchangedComponentEditab;
                        ToolTip = 'Specifies whether you want the exchanged component deleted.';

                        trigger OnValidate()
                        begin
                            DeleteExcCompOnAfterValidate;
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            DeleteExchangedComponentEditab := true;
            CreateNewVersionEditable := true;
            CreateNewVersion := true;
            QtyMultiply := 1;
            StartingDate := WorkDate;
        end;

        trigger OnOpenPage()
        begin
            CreateNewVersionEditable := not DeleteExcComp;
            DeleteExchangedComponentEditab := not CreateNewVersion;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        Recertify := true;
        CopyRoutingLink := true;
    end;

    trigger OnPreReport()
    begin
        if StartingDate = 0D then
          Error(Text000);

        if Type[1] = Type[1]::" " then
          Error(Text001);

        if No[1] = '' then
          Error(Text002);

        if (Type[1] = Type[2]) and (No[1] = No[2]) then
          Error(ItemBOMExchangeErr,SelectStr(Type[1] + 1,TypeTxt),No[1],SelectStr(Type[2] + 1,TypeTxt),No[2]);
    end;

    var
        Text000: Label 'You must enter a Starting Date.';
        Text001: Label 'You must enter the Type to exchange.';
        Text002: Label 'You must enter the No. to exchange.';
        ItemBOMExchangeErr: Label 'You cannot exchange %1 %2 with %3 %4.', Comment='%1 and %3 are strings (''Item'' or ''Production BOM''), %2 and %4 are either an Item No. or a Production BOM Header No. (Code[20])';
        Text004: Label 'Exchanging #1########## #2############\';
        Text005: Label 'Production BOM No.      #3############';
        Text006: Label 'Type must be entered.';
        Item: Record Item;
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMVersionList: Record "Production BOM Version";
        ProdBOMLine: Record "Production BOM Line";
        ProdBOMLine2: Record "Production BOM Line";
        ProdBOMLine3: Record "Production BOM Line";
        Window: Dialog;
        Type: array [2] of Option " ",Item,"Production BOM";
        No: array [2] of Code[20];
        QtyMultiply: Decimal;
        CreateNewVersion: Boolean;
        StartingDate: Date;
        Recertify: Boolean;
        TypeTxt: Label ' ,Item,Production BOM';
        CopyRoutingLink: Boolean;
        DeleteExcComp: Boolean;
        [InDataSet]
        CreateNewVersionEditable: Boolean;
        [InDataSet]
        DeleteExchangedComponentEditab: Boolean;

    local procedure CreateNewVersionOnAfterValidat()
    begin
        CreateNewVersionEditable := not DeleteExcComp;
        DeleteExchangedComponentEditab := not CreateNewVersion;
    end;

    local procedure DeleteExcCompOnAfterValidate()
    begin
        CreateNewVersionEditable := not DeleteExcComp;
        DeleteExchangedComponentEditab := not CreateNewVersion;
    end;

    local procedure IsActiveBOMVersion(ProdBOMHeader: Record "Production BOM Header";ProdBOMLine: Record "Production BOM Line"): Boolean
    var
        VersionManagement: Codeunit VersionManagement;
    begin
        if ProdBOMHeader.Status = ProdBOMHeader.Status::Closed then
          exit(false);

        exit(ProdBOMLine."Version Code" = VersionManagement.GetBOMVersion(ProdBOMLine."Production BOM No.",StartingDate,true));
    end;

    local procedure IncrementVersionNo(ProductionBOMNo: Code[20]) Result: Code[20]
    var
        ProductionBOMVersion: Record "Production BOM Version";
    begin
        ProductionBOMVersion.SetRange("Production BOM No.",ProductionBOMNo);
        if ProductionBOMVersion.FindLast then begin
          Result := IncStr(ProductionBOMVersion."Version Code");
          ProductionBOMVersion.SetRange("Version Code",Result);
          while not ProductionBOMVersion.IsEmpty do begin
            Result := IncStr(Result);
            if Result = '' then
              exit(Result);
            ProductionBOMVersion.SetRange("Version Code",Result);
          end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertNewProdBOMLine(var ProductionBOMLine: Record "Production BOM Line";FromProductionBOMLine: Record "Production BOM Line")
    begin
    end;
}

