table 370 "Excel Buffer"
{
    Caption = 'Excel Buffer';
    ReplicateData = false;

    fields
    {
        field(1;"Row No.";Integer)
        {
            Caption = 'Row No.';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                xlRowID := '';
                if "Row No." <> 0 then
                  xlRowID := Format("Row No.");
            end;
        }
        field(2;xlRowID;Text[10])
        {
            Caption = 'xlRowID';
            DataClassification = SystemMetadata;
        }
        field(3;"Column No.";Integer)
        {
            Caption = 'Column No.';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                x: Integer;
                i: Integer;
                y: Integer;
                c: Char;
                t: Text[30];
            begin
                xlColID := '';
                x := "Column No.";
                while x > 26 do begin
                  y := x mod 26;
                  if y = 0 then
                    y := 26;
                  c := 64 + y;
                  i := i + 1;
                  t[i] := c;
                  x := (x - y) div 26;
                end;
                if x > 0 then begin
                  c := 64 + x;
                  i := i + 1;
                  t[i] := c;
                end;
                for x := 1 to i do
                  xlColID[x] := t[1 + i - x];
            end;
        }
        field(4;xlColID;Text[10])
        {
            Caption = 'xlColID';
            DataClassification = SystemMetadata;
        }
        field(5;"Cell Value as Text";Text[250])
        {
            Caption = 'Cell Value as Text';
            DataClassification = SystemMetadata;
        }
        field(6;Comment;Text[250])
        {
            Caption = 'Comment';
            DataClassification = SystemMetadata;
        }
        field(7;Formula;Text[250])
        {
            Caption = 'Formula';
            DataClassification = SystemMetadata;
        }
        field(8;Bold;Boolean)
        {
            Caption = 'Bold';
            DataClassification = SystemMetadata;
        }
        field(9;Italic;Boolean)
        {
            Caption = 'Italic';
            DataClassification = SystemMetadata;
        }
        field(10;Underline;Boolean)
        {
            Caption = 'Underline';
            DataClassification = SystemMetadata;
        }
        field(11;NumberFormat;Text[30])
        {
            Caption = 'NumberFormat';
            DataClassification = SystemMetadata;
        }
        field(12;Formula2;Text[250])
        {
            Caption = 'Formula2';
            DataClassification = SystemMetadata;
        }
        field(13;Formula3;Text[250])
        {
            Caption = 'Formula3';
            DataClassification = SystemMetadata;
        }
        field(14;Formula4;Text[250])
        {
            Caption = 'Formula4';
            DataClassification = SystemMetadata;
        }
        field(15;"Cell Type";Option)
        {
            Caption = 'Cell Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Number,Text,Date,Time';
            OptionMembers = Number,Text,Date,Time;
        }
        field(16;"Double Underline";Boolean)
        {
            Caption = 'Double Underline';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Row No.","Column No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'You must enter a file name.';
        Text002: Label 'You must enter an Excel worksheet name.', Comment='{Locked="Excel"}';
        Text003: Label 'The file %1 does not exist.';
        Text004: Label 'The Excel worksheet %1 does not exist.', Comment='{Locked="Excel"}';
        Text005: Label 'Creating Excel worksheet...\\', Comment='{Locked="Excel"}';
        PageTxt: Label 'Page';
        Text007: Label 'Reading Excel worksheet...\\', Comment='{Locked="Excel"}';
        Text013: Label '&B';
        Text014: Label '&D';
        Text015: Label '&P';
        Text016: Label 'A1';
        Text017: Label 'SUMIF';
        Text018: Label '#N/A';
        Text019: Label 'GLAcc', Comment='{Locked} Used to define an Excel range name. You must refer to Excel rules to change this term.';
        Text020: Label 'Period', Comment='{Locked} Used to define an Excel range name. You must refer to Excel rules to change this term.';
        Text021: Label 'Budget';
        TempInfoExcelBuf: Record "Excel Buffer" temporary;
        FileManagement: Codeunit "File Management";
        OpenXMLManagement: Codeunit "OpenXML Management";
        XlWrkBkWriter: DotNet WorkbookWriter;
        XlWrkBkReader: DotNet WorkbookReader;
        XlWrkShtWriter: DotNet WorksheetWriter;
        XlWrkShtReader: DotNet WorksheetReader;
        StringBld: DotNet StringBuilder;
        RangeStartXlRow: Text[30];
        RangeStartXlCol: Text[30];
        RangeEndXlRow: Text[30];
        RangeEndXlCol: Text[30];
        FileNameServer: Text;
        FriendlyName: Text;
        CurrentRow: Integer;
        CurrentCol: Integer;
        UseInfoSheet: Boolean;
        Text022: Label 'CostAcc', Comment='{Locked} Used to define an Excel range name. You must refer to Excel rules to change this term.';
        Text023: Label 'Information';
        Text034: Label 'Excel Files (*.xls*)|*.xls*|All Files (*.*)|*.*', Comment='{Split=r''\|\*\..{1,4}\|?''}{Locked="Excel"}';
        Text035: Label 'The operation was canceled.';
        Text037: Label 'Could not create the Excel workbook.', Comment='{Locked="Excel"}';
        Text038: Label 'Global variable %1 is not included for test.';
        Text039: Label 'Cell type has not been set.';
        SavingDocumentMsg: Label 'Saving the following document: %1.';
        ExcelFileExtensionTok: Label '.xlsx', Locked=true;
        VmlDrawingXmlTxt: Label '<xml xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel"><o:shapelayout v:ext="edit"><o:idmap v:ext="edit" data="1"/></o:shapelayout><v:shapetype id="_x0000_t202" coordsize="21600,21600" o:spt="202"  path="m,l,21600r21600,l21600,xe"><v:stroke joinstyle="miter"/><v:path gradientshapeok="t" o:connecttype="rect"/></v:shapetype>', Locked=true;
        EndXmlTokenTxt: Label '</xml>', Locked=true;
        ErrorMessage: Text;

    [Scope('Personalization')]
    procedure CreateNewBook(SheetName: Text[250])
    begin
        CreateBook('',SheetName);
    end;

    [Scope('Internal')]
    procedure CreateBook(FileName: Text;SheetName: Text)
    begin
        if SheetName = '' then
          Error(Text002);

        if FileName = '' then
          FileNameServer := FileManagement.ServerTempFileName('xlsx')
        else begin
          if Exists(FileName) then
            Erase(FileName);
          FileNameServer := FileName;
        end;

        XlWrkBkWriter := XlWrkBkWriter.Create(FileNameServer);
        if IsNull(XlWrkBkWriter) then
          Error(Text037);

        XlWrkShtWriter := XlWrkBkWriter.FirstWorksheet;
        if SheetName <> '' then
          XlWrkShtWriter.Name := SheetName;

        OpenXMLManagement.SetupWorksheetHelper(XlWrkBkWriter);
    end;

    [Scope('Internal')]
    procedure OpenBook(FileName: Text;SheetName: Text)
    begin
        if FileName = '' then
          Error(Text001);

        if SheetName = '' then
          Error(Text002);

        if SheetName = 'G/L Account' then
          SheetName := 'GL Account';

        FileManagement.IsAllowedPath(FileName,false);
        XlWrkBkReader := XlWrkBkReader.Open(FileName);
        if XlWrkBkReader.HasWorksheet(SheetName) then begin
          XlWrkShtReader := XlWrkBkReader.GetWorksheetByName(SheetName);
        end else begin
          CloseBook;
          Error(Text004,SheetName);
        end;
    end;

    [Scope('Personalization')]
    procedure OpenBookStream(FileStream: InStream;SheetName: Text): Text
    begin
        if SheetName = '' then
          exit(Text002);

        if SheetName = 'G/L Account' then
          SheetName := 'GL Account';

        XlWrkBkReader := XlWrkBkReader.Open(FileStream);
        if XlWrkBkReader.HasWorksheet(SheetName) then
          XlWrkShtReader := XlWrkBkReader.GetWorksheetByName(SheetName)
        else begin
          CloseBook;
          ErrorMessage := StrSubstNo(Text004,SheetName);
          exit(ErrorMessage);
        end;
    end;

    [Scope('Internal')]
    procedure UpdateBook(FileName: Text;SheetName: Text)
    begin
        UpdateBookExcel(FileName,SheetName,true);
    end;

    [Scope('Internal')]
    procedure UpdateBookExcel(FileName: Text;SheetName: Text;PreserveDataOnUpdate: Boolean)
    begin
        if FileName = '' then
          Error(Text001);

        if SheetName = '' then
          Error(Text002);

        FileNameServer := FileName;
        FileManagement.IsAllowedPath(FileName,false);
        XlWrkBkWriter := XlWrkBkWriter.Open(FileNameServer);
        if XlWrkBkWriter.HasWorksheet(SheetName) then begin
          XlWrkShtWriter := XlWrkBkWriter.GetWorksheetByName(SheetName);
          // Set PreserverDataOnUpdate to false if the sheet writer should clear all empty cells
          // in which NAV does not have new data. Notice that the sheet writer will only clear Excel
          // cells that are addressed by the writer. All other cells will be left unmodified.
          XlWrkShtWriter.PreserveDataOnUpdate := PreserveDataOnUpdate;

          OpenXMLManagement.SetupWorksheetHelper(XlWrkBkWriter);
        end else begin
          CloseBook;
          Error(Text004,SheetName);
        end;
    end;

    [Scope('Personalization')]
    procedure UpdateBookStream(var ExcelStream: InStream;SheetName: Text;PreserveDataOnUpdate: Boolean)
    begin
        FileNameServer := FileManagement.InstreamExportToServerFile(ExcelStream,'xlsx');

        UpdateBookExcel(FileNameServer,SheetName,PreserveDataOnUpdate);
    end;

    [Scope('Personalization')]
    procedure CloseBook()
    begin
        if not IsNull(XlWrkBkWriter) then begin
          XlWrkBkWriter.ClearFormulaCalculations;
          XlWrkBkWriter.ValidateDocument;
          XlWrkBkWriter.Close;
          Clear(XlWrkShtWriter);
          Clear(XlWrkBkWriter);
        end;

        if not IsNull(XlWrkBkReader) then begin
          Clear(XlWrkShtReader);
          Clear(XlWrkBkReader);
        end;
    end;

    [Scope('Personalization')]
    procedure SelectOrAddSheet(NewSheetName: Text)
    begin
        if NewSheetName = '' then
          exit;
        if IsNull(XlWrkBkWriter) then
          Error(Text037);
        if XlWrkBkWriter.HasWorksheet(NewSheetName) then
          XlWrkShtWriter := XlWrkBkWriter.GetWorksheetByName(NewSheetName)
        else
          XlWrkShtWriter := XlWrkBkWriter.AddWorksheet(NewSheetName);
    end;

    [Scope('Personalization')]
    procedure SetActiveReaderSheet(NewSheetName: Text)
    begin
        if NewSheetName = '' then
          exit;

        if XlWrkBkReader.HasWorksheet(NewSheetName) then
          XlWrkShtReader := XlWrkBkReader.GetWorksheetByName(NewSheetName)
        else begin
          CloseBook;
          Error(Text004,NewSheetName);
        end;
    end;

    [Scope('Personalization')]
    procedure WriteSheet(ReportHeader: Text;CompanyName2: Text;UserID2: Text)
    var
        OrientationValues: DotNet OrientationValues;
        XmlTextWriter: DotNet XmlTextWriter0;
        FileMode: DotNet FileMode;
        Encoding: DotNet Encoding;
        VmlDrawingPart: DotNet VmlDrawingPart;
        CRLF: Char;
    begin
        CRLF := 10;

        XlWrkShtWriter.AddPageSetup(OrientationValues.Landscape,9); // 9 - default value for Paper Size - A4
        if ReportHeader <> '' then
          XlWrkShtWriter.AddHeader(
            true,
            StrSubstNo('%1%2%1%3%4',GetExcelReference(1),ReportHeader,CRLF,CompanyName2));

        XlWrkShtWriter.AddHeader(
          false,
          StrSubstNo('%1%3%4%3%5 %2',GetExcelReference(2),GetExcelReference(3),CRLF,UserID2,PageTxt));

        OpenXMLManagement.AddAndInitializeCommentsPart(XlWrkShtWriter,VmlDrawingPart);

        StringBld := StringBld.StringBuilder;
        StringBld.Append(VmlDrawingXmlTxt);

        WriteAllToCurrentSheet(Rec);

        StringBld.Append(EndXmlTokenTxt);

        XmlTextWriter := XmlTextWriter.XmlTextWriter(VmlDrawingPart.GetStream(FileMode.Create),Encoding.UTF8);
        XmlTextWriter.WriteRaw(StringBld.ToString);
        XmlTextWriter.Flush;
        XmlTextWriter.Close;

        if UseInfoSheet then
          if not TempInfoExcelBuf.IsEmpty then begin
            SelectOrAddSheet(Text023);
            WriteAllToCurrentSheet(TempInfoExcelBuf);
          end;
    end;

    [Scope('Personalization')]
    procedure WriteAllToCurrentSheet(var ExcelBuffer: Record "Excel Buffer")
    var
        ExcelBufferDialogMgt: Codeunit "Excel Buffer Dialog Management";
        RecNo: Integer;
        TotalRecNo: Integer;
        LastUpdate: DateTime;
    begin
        if ExcelBuffer.IsEmpty then
          exit;
        ExcelBufferDialogMgt.Open(Text005);
        LastUpdate := CurrentDateTime;
        TotalRecNo := ExcelBuffer.Count;
        if ExcelBuffer.FindSet then
          repeat
            RecNo := RecNo + 1;
            if not UpdateProgressDialog(ExcelBufferDialogMgt,LastUpdate,RecNo,TotalRecNo) then begin
              CloseBook;
              Error(Text035)
            end;
            if Formula = '' then
              WriteCellValue(ExcelBuffer)
            else
              WriteCellFormula(ExcelBuffer)
          until ExcelBuffer.Next = 0;
        ExcelBufferDialogMgt.Close;
    end;

    [Scope('Personalization')]
    procedure WriteCellValue(ExcelBuffer: Record "Excel Buffer")
    var
        Decorator: DotNet CellDecorator;
    begin
        with ExcelBuffer do begin
          GetCellDecorator(Bold,Italic,Underline,"Double Underline",Decorator);

          case "Cell Type" of
            "Cell Type"::Number:
              XlWrkShtWriter.SetCellValueNumber("Row No.",xlColID,"Cell Value as Text",NumberFormat,Decorator);
            "Cell Type"::Text:
              XlWrkShtWriter.SetCellValueText("Row No.",xlColID,"Cell Value as Text",Decorator);
            "Cell Type"::Date:
              XlWrkShtWriter.SetCellValueDate("Row No.",xlColID,"Cell Value as Text",NumberFormat,Decorator);
            "Cell Type"::Time:
              XlWrkShtWriter.SetCellValueTime("Row No.",xlColID,"Cell Value as Text",NumberFormat,Decorator);
            else
              Error(Text039)
          end;

          if Comment <> '' then begin
            OpenXMLManagement.SetCellComment(XlWrkShtWriter,StrSubstNo('%1%2',xlColID,"Row No."),Comment);
            StringBld.Append(OpenXMLManagement.CreateCommentVmlShapeXml("Column No.","Row No."));
          end;
        end;
    end;

    [Scope('Personalization')]
    procedure WriteCellFormula(ExcelBuffer: Record "Excel Buffer")
    var
        Decorator: DotNet CellDecorator;
    begin
        with ExcelBuffer do begin
          GetCellDecorator(Bold,Italic,Underline,"Double Underline",Decorator);

          XlWrkShtWriter.SetCellFormula("Row No.",xlColID,GetFormula,NumberFormat,Decorator);
        end;
    end;

    local procedure GetCellDecorator(IsBold: Boolean;IsItalic: Boolean;IsUnderlined: Boolean;IsDoubleUnderlined: Boolean;var Decorator: DotNet CellDecorator)
    begin
        if IsBold and IsItalic then begin
          if IsDoubleUnderlined then begin
            Decorator := XlWrkShtWriter.DefaultBoldItalicDoubleUnderlinedCellDecorator;
            exit;
          end;
          if IsUnderlined then begin
            Decorator := XlWrkShtWriter.DefaultBoldItalicUnderlinedCellDecorator;
            exit;
          end;
        end;

        if IsBold and IsItalic then begin
          Decorator := XlWrkShtWriter.DefaultBoldItalicCellDecorator;
          exit;
        end;

        if IsBold then begin
          if IsDoubleUnderlined then begin
            Decorator := XlWrkShtWriter.DefaultBoldDoubleUnderlinedCellDecorator;
            exit;
          end;
          if IsUnderlined then begin
            Decorator := XlWrkShtWriter.DefaultBoldUnderlinedCellDecorator;
            exit;
          end;
        end;

        if IsBold then begin
          Decorator := XlWrkShtWriter.DefaultBoldCellDecorator;
          exit;
        end;

        if IsItalic then begin
          if IsDoubleUnderlined then begin
            Decorator := XlWrkShtWriter.DefaultItalicDoubleUnderlinedCellDecorator;
            exit;
          end;
          if IsUnderlined then begin
            Decorator := XlWrkShtWriter.DefaultItalicUnderlinedCellDecorator;
            exit;
          end;
        end;

        if IsItalic then begin
          Decorator := XlWrkShtWriter.DefaultItalicCellDecorator;
          exit;
        end;

        if IsDoubleUnderlined then
          Decorator := XlWrkShtWriter.DefaultDoubleUnderlinedCellDecorator
        else begin
          if IsUnderlined then
            Decorator := XlWrkShtWriter.DefaultUnderlinedCellDecorator
          else
            Decorator := XlWrkShtWriter.DefaultCellDecorator;
        end;
    end;

    [Scope('Personalization')]
    procedure SetColumnWidth(ColName: Text[10];NewColWidth: Decimal)
    begin
        if not IsNull(XlWrkShtWriter) then
          XlWrkShtWriter.SetColumnWidth(ColName,NewColWidth);
    end;

    [Scope('Internal')]
    procedure CreateRangeName(RangeName: Text[30];FromColumnNo: Integer;FromRowNo: Integer)
    var
        TempExcelBuf: Record "Excel Buffer" temporary;
        ToxlRowID: Text[10];
    begin
        SetCurrentKey("Row No.","Column No.");
        if Find('+') then
          ToxlRowID := xlRowID;
        TempExcelBuf.Validate("Row No.",FromRowNo);
        TempExcelBuf.Validate("Column No.",FromColumnNo);

        XlWrkShtWriter.AddRange(
          RangeName,
          GetExcelReference(4) + TempExcelBuf.xlColID + GetExcelReference(4) + TempExcelBuf.xlRowID +
          ':' +
          GetExcelReference(4) + TempExcelBuf.xlColID + GetExcelReference(4) + ToxlRowID);
    end;

    [Scope('Personalization')]
    procedure ReadSheet()
    begin
        ReadSheetContinous('',true);
    end;

    [Scope('Personalization')]
    procedure ReadSheetContinous(SheetName: Text;CloseBookOnCompletion: Boolean)
    var
        ExcelBufferDialogMgt: Codeunit "Excel Buffer Dialog Management";
        CellData: DotNet CellData;
        Enumerator: DotNet IEnumerator;
        RowCount: Integer;
        LastUpdate: DateTime;
    begin
        // Allows reading Excel files with more than one sheet without closing and reopening file
        if SheetName <> '' then
          SetActiveReaderSheet(SheetName);
        LastUpdate := CurrentDateTime;
        ExcelBufferDialogMgt.Open(Text007);
        DeleteAll;

        Enumerator := XlWrkShtReader.GetEnumerator;
        RowCount := XlWrkShtReader.RowCount;
        while Enumerator.MoveNext do begin
          CellData := Enumerator.Current;
          if CellData.HasValue then begin
            Validate("Row No.",CellData.RowNumber);
            Validate("Column No.",CellData.ColumnNumber);
            ParseCellValue(CellData.Value,CellData.Format);
            Insert;

            if not UpdateProgressDialog(ExcelBufferDialogMgt,LastUpdate,CellData.RowNumber,RowCount) then begin
              CloseBook;
              Error(Text035)
            end;
          end;
        end;

        if CloseBookOnCompletion then
          CloseBook;
        ExcelBufferDialogMgt.Close;
    end;

    local procedure ParseCellValue(Value: Text;FormatString: Text)
    var
        Decimal: Decimal;
        IsHandled: Boolean;
    begin
        // The format contains only en-US number separators, this is an OpenXML standard requirement
        // The algorithm sieves the data based on formatting as follows (the steps must run in this order)
        // 1. FormatString = '@' -> Text
        // 2. FormatString.Contains(':') -> Time
        // 3. FormatString.ContainsOneOf('y', 'm', 'd') && FormatString.DoesNotContain('Red') -> Date
        // 4. anything else -> Decimal

        IsHandled := false;
        OnBeforeParseCellValue(Rec,Value,FormatString,IsHandled);
        if IsHandled then
          exit;

        NumberFormat := CopyStr(FormatString,1,30);

        if FormatString = '@' then begin
          "Cell Type" := "Cell Type"::Text;
          "Cell Value as Text" := Value;
          exit;
        end;

        Evaluate(Decimal,Value);

        if StrPos(FormatString,':') <> 0 then begin
          // Excel Time is stored in OADate format
          "Cell Type" := "Cell Type"::Time;
          "Cell Value as Text" := Format(DT2Time(ConvertDateTimeDecimalToDateTime(Decimal)));
          exit;
        end;

        if ((StrPos(FormatString,'y') <> 0) or
            (StrPos(FormatString,'m') <> 0) or
            (StrPos(FormatString,'d') <> 0)) and
           (StrPos(FormatString,'Red') = 0)
        then begin
          "Cell Type" := "Cell Type"::Date;
          "Cell Value as Text" := Format(DT2Date(ConvertDateTimeDecimalToDateTime(Decimal)));
          exit;
        end;

        "Cell Type" := "Cell Type"::Number;
        "Cell Value as Text" := Format(Round(Decimal,0.000001),0,1);
    end;

    [Scope('Internal')]
    procedure SelectSheetsName(FileName: Text): Text[250]
    var
        TempBlob: Record TempBlob temporary;
        InStr: InStream;
    begin
        if FileName = '' then
          Error(Text001);

        FileManagement.BLOBImportFromServerFile(TempBlob,FileName);
        TempBlob.Blob.CreateInStream(InStr);
        exit(SelectSheetsNameStream(InStr));
    end;

    [Scope('Personalization')]
    procedure SelectSheetsNameStream(FileStream: InStream): Text[250]
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        SelectedSheetName: Text[250];
    begin
        if GetSheetsNameListFromStream(FileStream,TempNameValueBuffer) then
          if TempNameValueBuffer.Count = 1 then
            SelectedSheetName := TempNameValueBuffer.Value
          else begin
            TempNameValueBuffer.FindFirst;
            if PAGE.RunModal(PAGE::"Name/Value Lookup",TempNameValueBuffer) = ACTION::LookupOK then
              SelectedSheetName := TempNameValueBuffer.Value;
          end;

        exit(SelectedSheetName);
    end;

    [Scope('Personalization')]
    procedure GetExcelReference(Which: Integer): Text[250]
    begin
        case Which of
          1:
            exit(Text013);
          // DO NOT TRANSLATE: &B is the Excel code to turn bold printing on or off for customized Header/Footer.
          2:
            exit(Text014);
          // DO NOT TRANSLATE: &D is the Excel code to print the current date in customized Header/Footer.
          3:
            exit(Text015);
          // DO NOT TRANSLATE: &P is the Excel code to print the page number in customized Header/Footer.
          4:
            exit('$');
          // DO NOT TRANSLATE: $ is the Excel code for absolute reference to cells.
          5:
            exit(Text016);
          // DO NOT TRANSLATE: A1 is the Excel reference of the first cell.
          6:
            exit(Text017);
          // DO NOT TRANSLATE: SUMIF is the name of the Excel function used to summarize values according to some conditions.
          7:
            exit(Text018);
          // DO NOT TRANSLATE: The #N/A Excel error value occurs when a value is not available to a function or formula.
          8:
            exit(Text019);
          // DO NOT TRANSLATE: GLAcc is used to define an Excel range name. You must refer to Excel rules to change this term.
          9:
            exit(Text020);
          // DO NOT TRANSLATE: Period is used to define an Excel range name. You must refer to Excel rules to change this term.
          10:
            exit(Text021);
          // DO NOT TRANSLATE: Budget is used to define an Excel worksheet name. You must refer to Excel rules to change this term.
          11:
            exit(Text022);
          // DO NOT TRANSLATE: CostAcc is used to define an Excel range name. You must refer to Excel rules to change this term.
        end;
    end;

    [Scope('Personalization')]
    procedure ExportBudgetFilterToFormula(var ExcelBuf: Record "Excel Buffer"): Boolean
    var
        TempExcelBufFormula: Record "Excel Buffer" temporary;
        TempExcelBufFormula2: Record "Excel Buffer" temporary;
        FirstRow: Integer;
        LastRow: Integer;
        HasFormulaError: Boolean;
        ThisCellHasFormulaError: Boolean;
    begin
        ExcelBuf.SetFilter(Formula,'<>%1','');
        if ExcelBuf.FindSet then
          repeat
            TempExcelBufFormula := ExcelBuf;
            TempExcelBufFormula.Insert;
          until ExcelBuf.Next = 0;
        ExcelBuf.Reset;

        with TempExcelBufFormula do
          if FindSet then
            repeat
              ThisCellHasFormulaError := false;
              ExcelBuf.SetRange("Column No.",1);
              ExcelBuf.SetFilter("Row No.",'<>%1',"Row No.");
              ExcelBuf.SetFilter("Cell Value as Text",Formula);
              TempExcelBufFormula2 := TempExcelBufFormula;
              if ExcelBuf.FindSet then
                repeat
                  if not Get(ExcelBuf."Row No.","Column No.") then
                    ExcelBuf.Mark(true);
                until ExcelBuf.Next = 0;
              TempExcelBufFormula := TempExcelBufFormula2;
              ClearFormula;
              ExcelBuf.SetRange("Cell Value as Text");
              ExcelBuf.SetRange("Row No.");
              if ExcelBuf.FindSet then
                repeat
                  if ExcelBuf.Mark then begin
                    LastRow := ExcelBuf."Row No.";
                    if FirstRow = 0 then
                      FirstRow := LastRow;
                  end else
                    if FirstRow <> 0 then begin
                      if FirstRow = LastRow then
                        ThisCellHasFormulaError := AddToFormula(xlColID + Format(FirstRow))
                      else
                        ThisCellHasFormulaError :=
                          AddToFormula('SUM(' + xlColID + Format(FirstRow) + ':' + xlColID + Format(LastRow) + ')');
                      FirstRow := 0;
                      if ThisCellHasFormulaError then
                        SetFormula(ExcelBuf.GetExcelReference(7));
                    end;
                until ThisCellHasFormulaError or (ExcelBuf.Next = 0);

              if not ThisCellHasFormulaError and (FirstRow <> 0) then begin
                if FirstRow = LastRow then
                  ThisCellHasFormulaError := AddToFormula(xlColID + Format(FirstRow))
                else
                  ThisCellHasFormulaError :=
                    AddToFormula('SUM(' + xlColID + Format(FirstRow) + ':' + xlColID + Format(LastRow) + ')');
                FirstRow := 0;
                if ThisCellHasFormulaError then
                  SetFormula(ExcelBuf.GetExcelReference(7));
              end;

              ExcelBuf.Reset;
              ExcelBuf.Get("Row No.","Column No.");
              ExcelBuf.SetFormula(GetFormula);
              ExcelBuf.Modify;
              HasFormulaError := HasFormulaError or ThisCellHasFormulaError;
            until Next = 0;

        exit(HasFormulaError);
    end;

    [Scope('Personalization')]
    procedure AddToFormula(Text: Text[30]): Boolean
    var
        Overflow: Boolean;
        LongFormula: Text[1000];
    begin
        LongFormula := GetFormula;
        if LongFormula = '' then
          LongFormula := '=';
        if LongFormula <> '=' then
          if StrLen(LongFormula) + 1 > MaxStrLen(LongFormula) then
            Overflow := true
          else
            LongFormula := LongFormula + '+';
        if StrLen(LongFormula) + StrLen(Text) > MaxStrLen(LongFormula) then
          Overflow := true
        else
          SetFormula(LongFormula + Text);
        exit(Overflow);
    end;

    [Scope('Personalization')]
    procedure GetFormula(): Text[1000]
    begin
        exit(Formula + Formula2 + Formula3 + Formula4);
    end;

    [Scope('Personalization')]
    procedure SetFormula(LongFormula: Text[1000])
    begin
        ClearFormula;
        if LongFormula = '' then
          exit;

        Formula := CopyStr(LongFormula,1,MaxStrLen(Formula));
        if StrLen(LongFormula) > MaxStrLen(Formula) then
          Formula2 := CopyStr(LongFormula,MaxStrLen(Formula) + 1,MaxStrLen(Formula2));
        if StrLen(LongFormula) > MaxStrLen(Formula) + MaxStrLen(Formula2) then
          Formula3 := CopyStr(LongFormula,MaxStrLen(Formula) + MaxStrLen(Formula2) + 1,MaxStrLen(Formula3));
        if StrLen(LongFormula) > MaxStrLen(Formula) + MaxStrLen(Formula2) + MaxStrLen(Formula3) then
          Formula4 := CopyStr(LongFormula,MaxStrLen(Formula) + MaxStrLen(Formula2) + MaxStrLen(Formula3) + 1,MaxStrLen(Formula4));
    end;

    [Scope('Personalization')]
    procedure ClearFormula()
    begin
        Formula := '';
        Formula2 := '';
        Formula3 := '';
        Formula4 := '';
    end;

    [Scope('Personalization')]
    procedure NewRow()
    begin
        SetCurrent(CurrentRow + 1,0);
    end;

    [Scope('Personalization')]
    procedure AddColumn(Value: Variant;IsFormula: Boolean;CommentText: Text;IsBold: Boolean;IsItalics: Boolean;IsUnderline: Boolean;NumFormat: Text[30];CellType: Option)
    begin
        AddColumnToBuffer(Rec,Value,IsFormula,CommentText,IsBold,IsItalics,IsUnderline,NumFormat,CellType);
    end;

    [Scope('Personalization')]
    procedure AddInfoColumn(Value: Variant;IsFormula: Boolean;IsBold: Boolean;IsItalics: Boolean;IsUnderline: Boolean;NumFormat: Text[30];CellType: Option)
    begin
        AddColumnToBuffer(TempInfoExcelBuf,Value,IsFormula,'',IsBold,IsItalics,IsUnderline,NumFormat,CellType);
    end;

    local procedure AddColumnToBuffer(var ExcelBuffer: Record "Excel Buffer";Value: Variant;IsFormula: Boolean;CommentText: Text;IsBold: Boolean;IsItalics: Boolean;IsUnderline: Boolean;NumFormat: Text[30];CellType: Option)
    begin
        if CurrentRow < 1 then
          NewRow;

        CurrentCol := CurrentCol + 1;
        ExcelBuffer.Init;
        ExcelBuffer.Validate("Row No.",CurrentRow);
        ExcelBuffer.Validate("Column No.",CurrentCol);
        if IsFormula then
          ExcelBuffer.SetFormula(Format(Value))
        else
          ExcelBuffer."Cell Value as Text" := Format(Value);
        ExcelBuffer.Comment := CopyStr(CommentText,1,MaxStrLen(ExcelBuffer.Comment));
        ExcelBuffer.Bold := IsBold;
        ExcelBuffer.Italic := IsItalics;
        ExcelBuffer.Underline := IsUnderline;
        ExcelBuffer.NumberFormat := NumFormat;
        ExcelBuffer."Cell Type" := CellType;
        ExcelBuffer.Insert;
    end;

    [Scope('Personalization')]
    procedure EnterCell(var ExcelBuffer: Record "Excel Buffer";RowNo: Integer;ColumnNo: Integer;Value: Variant;IsBold: Boolean;IsItalics: Boolean;IsUnderline: Boolean)
    begin
        ExcelBuffer.Init;
        ExcelBuffer.Validate("Row No.",RowNo);
        ExcelBuffer.Validate("Column No.",ColumnNo);

        case true of
          Value.IsDecimal or Value.IsInteger:
            ExcelBuffer.Validate("Cell Type",ExcelBuffer."Cell Type"::Number);
          Value.IsDate:
            ExcelBuffer.Validate("Cell Type",ExcelBuffer."Cell Type"::Date);
          else
            ExcelBuffer.Validate("Cell Type",ExcelBuffer."Cell Type"::Text);
        end;

        ExcelBuffer."Cell Value as Text" := CopyStr(Format(Value),1,MaxStrLen(ExcelBuffer."Cell Value as Text" ));
        ExcelBuffer.Bold := IsBold;
        ExcelBuffer.Italic := IsItalics;
        ExcelBuffer.Underline := IsUnderline;
        ExcelBuffer.Insert(true);
    end;

    [Scope('Personalization')]
    procedure StartRange()
    var
        DummyExcelBuf: Record "Excel Buffer";
    begin
        DummyExcelBuf.Validate("Row No.",CurrentRow);
        DummyExcelBuf.Validate("Column No.",CurrentCol);

        RangeStartXlRow := DummyExcelBuf.xlRowID;
        RangeStartXlCol := DummyExcelBuf.xlColID;
    end;

    [Scope('Personalization')]
    procedure EndRange()
    var
        DummyExcelBuf: Record "Excel Buffer";
    begin
        DummyExcelBuf.Validate("Row No.",CurrentRow);
        DummyExcelBuf.Validate("Column No.",CurrentCol);

        RangeEndXlRow := DummyExcelBuf.xlRowID;
        RangeEndXlCol := DummyExcelBuf.xlColID;
    end;

    [Scope('Personalization')]
    procedure CreateRange(RangeName: Text[250])
    begin
        XlWrkShtWriter.AddRange(
          RangeName,
          GetExcelReference(4) + RangeStartXlCol + GetExcelReference(4) + RangeStartXlRow +
          ':' +
          GetExcelReference(4) + RangeEndXlCol + GetExcelReference(4) + RangeEndXlRow);
    end;

    [Scope('Personalization')]
    procedure ClearNewRow()
    begin
        SetCurrent(0,0);
    end;

    [Scope('Personalization')]
    procedure SetUseInfoSheet()
    begin
        UseInfoSheet := true;
    end;

    [Scope('Personalization')]
    procedure UTgetGlobalValue(globalVariable: Text[30];var value: Variant)
    begin
        case globalVariable of
          'CurrentRow':
            value := CurrentRow;
          'CurrentCol':
            value := CurrentCol;
          'RangeStartXlRow':
            value := RangeStartXlRow;
          'RangeStartXlCol':
            value := RangeStartXlCol;
          'RangeEndXlRow':
            value := RangeEndXlRow;
          'RangeEndXlCol':
            value := RangeEndXlCol;
          'XlWrkSht':
            value := XlWrkShtWriter;
          'ExcelFile':
            value := FileNameServer;
          else
            Error(Text038,globalVariable);
        end;
    end;

    [Scope('Personalization')]
    procedure SetCurrent(NewCurrentRow: Integer;NewCurrentCol: Integer)
    begin
        CurrentRow := NewCurrentRow;
        CurrentCol := NewCurrentCol;
    end;

    [Scope('Internal')]
    procedure CreateValidationRule(Range: Code[20])
    begin
        XlWrkShtWriter.AddRangeDataValidation(
          Range,
          GetExcelReference(4) + RangeStartXlCol + GetExcelReference(4) + RangeStartXlRow +
          ':' +
          GetExcelReference(4) + RangeEndXlCol + GetExcelReference(4) + RangeEndXlRow);
    end;

    [Scope('Personalization')]
    procedure QuitExcel()
    begin
        CloseBook;
    end;

    [Scope('Personalization')]
    procedure OpenExcel()
    begin
        if OpenUsingDocumentService('') then
          exit;

        FileManagement.DownloadHandler(FileNameServer,'','',Text034,GetFriendlyFilename);
    end;

    [Scope('Internal')]
    procedure DownloadAndOpenExcel()
    begin
        OpenExcelWithName(GetFriendlyFilename);
    end;

    [Scope('Internal')]
    procedure OpenExcelWithName(FileName: Text)
    begin
        if FileName = '' then
          Error(Text001);

        if OpenUsingDocumentService(FileName) then
          exit;

        FileManagement.DownloadHandler(FileNameServer,'','',Text034,FileName);
    end;

    local procedure OpenUsingDocumentService(FileName: Text): Boolean
    var
        DocumentServiceMgt: Codeunit "Document Service Management";
        FileMgt: Codeunit "File Management";
        PathHelper: DotNet Path;
        DialogWindow: Dialog;
        DocumentUrl: Text;
    begin
        if not Exists(FileNameServer) then
          Error(Text003,FileNameServer);

        // if document service is configured we save the generated document to SharePoint and open it from there.
        if DocumentServiceMgt.IsConfigured then begin
          if FileName = '' then
            FileName := 'Book.' + PathHelper.ChangeExtension(PathHelper.GetRandomFileName,'xlsx')
          else begin
            // if file is not applicable for the service it can not be opened using the document service.
            if not DocumentServiceMgt.IsServiceUri(FileName) then
              exit(false);

            FileName := FileMgt.GetFileName(FileName);
          end;

          DialogWindow.Open(StrSubstNo(SavingDocumentMsg,FileName));
          DocumentUrl := DocumentServiceMgt.SaveFile(FileNameServer,FileName,true);
          DocumentServiceMgt.OpenDocument(DocumentUrl);
          DialogWindow.Close;
          exit(true);
        end;

        exit(false);
    end;

    [Scope('Internal')]
    procedure CreateBookAndOpenExcel(FileName: Text;SheetName: Text[250];ReportHeader: Text;CompanyName2: Text;UserID2: Text)
    begin
        CreateBook(FileName,SheetName);
        WriteSheet(ReportHeader,CompanyName2,UserID2);
        CloseBook;
        OpenExcel;
    end;

    local procedure UpdateProgressDialog(var ExcelBufferDialogManagement: Codeunit "Excel Buffer Dialog Management";var LastUpdate: DateTime;CurrentCount: Integer;TotalCount: Integer): Boolean
    var
        CurrentTime: DateTime;
    begin
        // Refresh at 100%, and every second in between 0% to 100%
        // Duration is measured in miliseconds -> 1 sec = 1000 ms
        CurrentTime := CurrentDateTime;
        if (CurrentCount = TotalCount) or (CurrentTime - LastUpdate >= 1000) then begin
          LastUpdate := CurrentTime;
          if not ExcelBufferDialogManagement.SetProgress(Round(CurrentCount / TotalCount * 10000,1)) then
            exit(false);
        end;

        exit(true)
    end;

    local procedure GetFriendlyFilename(): Text
    begin
        if FriendlyName = '' then
          exit('Book1' + ExcelFileExtensionTok);

        exit(FileManagement.StripNotsupportChrInFileName(FriendlyName) + ExcelFileExtensionTok);
    end;

    [Scope('Personalization')]
    procedure SetFriendlyFilename(Name: Text)
    begin
        FriendlyName := Name;
    end;

    [Scope('Personalization')]
    procedure ConvertDateTimeDecimalToDateTime(DateTimeAsOADate: Decimal): DateTime
    var
        DotNetDateTime: DotNet DateTime;
        DotNetDateTimeWithKind: DotNet DateTime;
        DotNetDateTimeKind: DotNet DateTimeKind;
    begin
        DotNetDateTime := DotNetDateTime.FromOADate(DateTimeAsOADate);
        DotNetDateTimeWithKind := DotNetDateTime.DateTime(DotNetDateTime.Ticks,DotNetDateTimeKind.Local);
        exit(DotNetDateTimeWithKind);
    end;

    [Scope('Personalization')]
    procedure SaveToStream(var ResultStream: OutStream;EraseFileAfterCompletion: Boolean)
    var
        TempBlob: Record TempBlob temporary;
        BlobStream: InStream;
    begin
        FileManagement.BLOBImportFromServerFile(TempBlob,FileNameServer);
        TempBlob.Blob.CreateInStream(BlobStream);
        CopyStream(ResultStream,BlobStream);
        if EraseFileAfterCompletion then
          FILE.Erase(FileNameServer);
    end;

    [Scope('Personalization')]
    procedure GetSheetsNameListFromStream(FileStream: InStream;var TempNameValueBufferOut: Record "Name/Value Buffer" temporary) SheetsFound: Boolean
    var
        SheetNames: DotNet ArrayList;
        SheetName: Text[250];
        i: Integer;
    begin
        XlWrkBkReader := XlWrkBkReader.Open(FileStream);
        TempNameValueBufferOut.Reset;
        TempNameValueBufferOut.DeleteAll;

        SheetNames := SheetNames.ArrayList(XlWrkBkReader.SheetNames);
        if IsNull(SheetNames) then
          exit(false);

        SheetsFound := SheetNames.Count > 0;

        if not SheetsFound then
          exit(false);

        for i := 0 to SheetNames.Count - 1 do begin
          SheetName := SheetNames.Item(i);
          if SheetName <> '' then begin
            TempNameValueBufferOut.Init;
            TempNameValueBufferOut.ID := i;
            TempNameValueBufferOut.Name := Format(i + 1);
            TempNameValueBufferOut.Value := SheetName;
            TempNameValueBufferOut.Insert;
          end;
        end;

        CloseBook;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeParseCellValue(var ExcelBuffer: Record "Excel Buffer";var Value: Text;var FormatString: Text;var IsHandled: Boolean)
    begin
    end;
}

