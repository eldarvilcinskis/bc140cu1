codeunit 396 "NoSeriesManagement"
{
    Permissions = TableData "No. Series Line" = rimd;

    trigger OnRun()
    begin
        TryNo := GetNextNo(TryNoSeriesCode, TrySeriesDate, false);
    end;

    var
        Text000: Label 'You may not enter numbers manually. ';
        Text001: Label 'If you want to enter numbers manually, please activate %1 in %2 %3.';
        Text003: Label 'It is not possible to assign numbers automatically. If you want the program to assign numbers automatically, please activate %1 in %2 %3.', Comment = '%1=Default Nos. setting,%2=No. Series table caption,%3=No. Series Code';
        Text004: Label 'You cannot assign new numbers from the number series %1 on %2.';
        Text005: Label 'You cannot assign new numbers from the number series %1.';
        Text006: Label 'You cannot assign new numbers from the number series %1 on a date before %2.';
        Text007: Label 'You cannot assign numbers greater than %1 from the number series %2.';
        Text009: Label 'The number format in %1 must be the same as the number format in %2.';
        Text010: Label 'The number %1 cannot be extended to more than 20 characters.';
        NoSeries: Record "No. Series";
        LastNoSeriesLine: Record "No. Series Line";
        NoSeriesCode: Code[20];
        WarningNoSeriesCode: Code[20];
        TryNoSeriesCode: Code[20];
        TrySeriesDate: Date;
        TryNo: Code[20];
        PostErr: Label 'You have one or more documents that must be posted before you post document no. %1 according to your company''s No. Series setup.', Comment = '%1=Document No.';

    [Scope('Personalization')]
    procedure TestManual(DefaultNoSeriesCode: Code[20])
    begin
        if DefaultNoSeriesCode <> '' then begin
            NoSeries.Get(DefaultNoSeriesCode);
            if not NoSeries."Manual Nos." then
                Error(
                  Text000 +
                  Text001,
                  NoSeries.FieldCaption("Manual Nos."), NoSeries.TableCaption, NoSeries.Code);
        end;
    end;

    [Scope('Personalization')]
    procedure TestManualWithDocumentNo(DefaultNoSeriesCode: Code[20]; DocumentNo: Code[20])
    begin
        if DefaultNoSeriesCode <> '' then begin
            NoSeries.Get(DefaultNoSeriesCode);
            if not NoSeries."Manual Nos." then
                Error(PostErr, DocumentNo);
        end;
    end;

    [Scope('Personalization')]
    procedure InitSeries(DefaultNoSeriesCode: Code[20]; OldNoSeriesCode: Code[20]; NewDate: Date; var NewNo: Code[20]; var NewNoSeriesCode: Code[20])
    begin
        if NewNo = '' then begin
            NoSeries.Get(DefaultNoSeriesCode);
            if not NoSeries."Default Nos." then
                Error(
                  Text003,
                  NoSeries.FieldCaption("Default Nos."), NoSeries.TableCaption, NoSeries.Code);
            if OldNoSeriesCode <> '' then begin
                NoSeriesCode := DefaultNoSeriesCode;
                FilterSeries;
                NoSeries.Code := OldNoSeriesCode;
                if not NoSeries.Find then
                    NoSeries.Get(DefaultNoSeriesCode);
            end;
            NewNo := GetNextNo(NoSeries.Code, NewDate, true);
            NewNoSeriesCode := NoSeries.Code;
        end else
            TestManual(DefaultNoSeriesCode);
    end;

    [Scope('Personalization')]
    procedure SetDefaultSeries(var NewNoSeriesCode: Code[20]; NoSeriesCode: Code[20])
    begin
        if NoSeriesCode <> '' then begin
            NoSeries.Get(NoSeriesCode);
            if NoSeries."Default Nos." then
                NewNoSeriesCode := NoSeries.Code;
        end;
    end;

    [Scope('Personalization')]
    procedure SelectSeries(DefaultNoSeriesCode: Code[20]; OldNoSeriesCode: Code[20]; var NewNoSeriesCode: Code[20]): Boolean
    begin
        NoSeriesCode := DefaultNoSeriesCode;
        FilterSeries;
        if NewNoSeriesCode = '' then begin
            if OldNoSeriesCode <> '' then
                NoSeries.Code := OldNoSeriesCode;
        end else
            NoSeries.Code := NewNoSeriesCode;
        if PAGE.RunModal(0, NoSeries) = ACTION::LookupOK then begin
            NewNoSeriesCode := NoSeries.Code;
            exit(true);
        end;
    end;

    [Scope('Personalization')]
    procedure LookupSeries(DefaultNoSeriesCode: Code[20]; var NewNoSeriesCode: Code[20]): Boolean
    begin
        exit(SelectSeries(DefaultNoSeriesCode, NewNoSeriesCode, NewNoSeriesCode));
    end;

    [Scope('Personalization')]
    procedure TestSeries(DefaultNoSeriesCode: Code[20]; NewNoSeriesCode: Code[20])
    begin
        NoSeriesCode := DefaultNoSeriesCode;
        FilterSeries;
        NoSeries.Code := NewNoSeriesCode;
        NoSeries.Find;
    end;

    [Scope('Personalization')]
    procedure SetSeries(var NewNo: Code[20])
    var
        NoSeriesCode2: Code[20];
    begin
        NoSeriesCode2 := NoSeries.Code;
        FilterSeries;
        NoSeries.Code := NoSeriesCode2;
        NoSeries.Find;
        NewNo := GetNextNo(NoSeries.Code, 0D, true);
    end;

    local procedure FilterSeries()
    var
        NoSeriesRelationship: Record "No. Series Relationship";
    begin
        NoSeries.Reset;
        NoSeriesRelationship.SetRange(Code, NoSeriesCode);
        if NoSeriesRelationship.FindSet then
            repeat
                NoSeries.Code := NoSeriesRelationship."Series Code";
                NoSeries.Mark := true;
            until NoSeriesRelationship.Next = 0;
        if NoSeries.Get(NoSeriesCode) then
            NoSeries.Mark := true;
        NoSeries.MarkedOnly := true;
    end;

    [Scope('Personalization')]
    procedure GetNextNo(NoSeriesCode: Code[20]; SeriesDate: Date; ModifySeries: Boolean): Code[20]
    begin
        exit(DoGetNextNo(NoSeriesCode, SeriesDate, ModifySeries, false));
    end;

    [Scope('Personalization')]
    procedure GetNextNo3(NoSeriesCode: Code[20]; SeriesDate: Date; ModifySeries: Boolean; NoErrorsOrWarnings: Boolean): Code[20]
    begin
        // This function is deprecated. Use the function in the line below instead:
        exit(DoGetNextNo(NoSeriesCode, SeriesDate, ModifySeries, NoErrorsOrWarnings));
    end;

    [Scope('Personalization')]
    procedure DoGetNextNo(NoSeriesCode: Code[20]; SeriesDate: Date; ModifySeries: Boolean; NoErrorsOrWarnings: Boolean): Code[20]
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        OnBeforeDoGetNextNo(NoSeriesCode, SeriesDate, ModifySeries, NoErrorsOrWarnings);

        if SeriesDate = 0D then
            SeriesDate := WorkDate;

        if ModifySeries or (LastNoSeriesLine."Series Code" = '') then begin
            if ModifySeries then
                NoSeriesLine.LockTable;
            NoSeries.Get(NoSeriesCode);
            SetNoSeriesLineFilter(NoSeriesLine, NoSeriesCode, SeriesDate);
            if not NoSeriesLine.FindFirst then begin
                if NoErrorsOrWarnings then
                    exit('');
                NoSeriesLine.SetRange("Starting Date");
                if not NoSeriesLine.IsEmpty then
                    Error(
                      Text004,
                      NoSeriesCode, SeriesDate);
                Error(
                  Text005,
                  NoSeriesCode);
            end;
        end else
            NoSeriesLine := LastNoSeriesLine;

        if NoSeries."Date Order" and (SeriesDate < NoSeriesLine."Last Date Used") then begin
            if NoErrorsOrWarnings then
                exit('');
            Error(
              Text006,
              NoSeries.Code, NoSeriesLine."Last Date Used");
        end;
        NoSeriesLine."Last Date Used" := SeriesDate;
        if NoSeriesLine."Last No. Used" = '' then begin
            if NoErrorsOrWarnings and (NoSeriesLine."Starting No." = '') then
                exit('');
            NoSeriesLine.TestField("Starting No.");
            NoSeriesLine."Last No. Used" := NoSeriesLine."Starting No.";
        end else
            if NoSeriesLine."Increment-by No." <= 1 then
                NoSeriesLine."Last No. Used" := IncStr(NoSeriesLine."Last No. Used")
            else
                IncrementNoText(NoSeriesLine."Last No. Used", NoSeriesLine."Increment-by No.");
        if (NoSeriesLine."Ending No." <> '') and
           (NoSeriesLine."Last No. Used" > NoSeriesLine."Ending No.")
        then begin
            if NoErrorsOrWarnings then
                exit('');
            Error(
              Text007,
              NoSeriesLine."Ending No.", NoSeriesCode);
        end;
        if (NoSeriesLine."Ending No." <> '') and
           (NoSeriesLine."Warning No." <> '') and
           (NoSeriesLine."Last No. Used" >= NoSeriesLine."Warning No.") and
           (NoSeriesCode <> WarningNoSeriesCode) and
           (TryNoSeriesCode = '')
        then begin
            if NoErrorsOrWarnings then
                exit('');
            WarningNoSeriesCode := NoSeriesCode;
            Message(
              Text007,
              NoSeriesLine."Ending No.", NoSeriesCode);
        end;
        NoSeriesLine.Validate(Open);

        if ModifySeries then
            NoSeriesLine.Modify
        else
            LastNoSeriesLine := NoSeriesLine;

        OnAfterGetNextNo3(NoSeriesLine, ModifySeries);

        exit(NoSeriesLine."Last No. Used");
    end;

    [Scope('Personalization')]
    procedure TryGetNextNo(NoSeriesCode: Code[20]; SeriesDate: Date): Code[20]
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        NoSeriesMgt.SetParametersBeforeRun(NoSeriesCode, SeriesDate);
        if NoSeriesMgt.Run then
            exit(NoSeriesMgt.GetNextNoAfterRun);
    end;

    [Scope('Personalization')]
    procedure GetNextNo1(NoSeriesCode: Code[20]; SeriesDate: Date)
    begin
        // This function is deprecated. Use the function in the line below instead:
        SetParametersBeforeRun(NoSeriesCode, SeriesDate);
    end;

    [Scope('Personalization')]
    procedure SetParametersBeforeRun(NoSeriesCode: Code[20]; SeriesDate: Date)
    begin
        TryNoSeriesCode := NoSeriesCode;
        TrySeriesDate := SeriesDate;
    end;

    [Scope('Personalization')]
    procedure GetNextNo2(): Code[20]
    begin
        // This function is deprecated. Use the function in the line below instead:
        exit(GetNextNoAfterRun);
    end;

    [Scope('Personalization')]
    procedure GetNextNoAfterRun(): Code[20]
    begin
        exit(TryNo);
    end;

    [Scope('Personalization')]
    procedure SaveNoSeries()
    begin
        if LastNoSeriesLine."Series Code" <> '' then
            LastNoSeriesLine.Modify;

        OnAfterSaveNoSeries(LastNoSeriesLine);
    end;

    [Scope('Personalization')]
    procedure SetNoSeriesLineFilter(var NoSeriesLine: Record "No. Series Line"; NoSeriesCode: Code[20]; StartDate: Date)
    begin
        if StartDate = 0D then
            StartDate := WorkDate;
        NoSeriesLine.Reset;
        NoSeriesLine.SetCurrentKey("Series Code", "Starting Date");
        NoSeriesLine.SetRange("Series Code", NoSeriesCode);
        NoSeriesLine.SetRange("Starting Date", 0D, StartDate);
        if NoSeriesLine.FindLast then begin
            NoSeriesLine.SetRange("Starting Date", NoSeriesLine."Starting Date");
            NoSeriesLine.SetRange(Open, true);
        end;
    end;

    [Scope('Personalization')]
    procedure IncrementNoText(var No: Code[20]; IncrementByNo: Decimal)
    var
        BigIntNo: BigInteger;
        BigIntIncByNo: BigInteger;
        StartPos: Integer;
        EndPos: Integer;
        NewNo: Text[30];
    begin
        GetIntegerPos(No, StartPos, EndPos);
        Evaluate(BigIntNo, CopyStr(No, StartPos, EndPos - StartPos + 1));
        BigIntIncByNo := IncrementByNo;
        NewNo := Format(BigIntNo + BigIntIncByNo, 0, 1);
        ReplaceNoText(No, NewNo, 0, StartPos, EndPos);
    end;

    [Scope('Personalization')]
    procedure UpdateNoSeriesLine(var NoSeriesLine: Record "No. Series Line"; NewNo: Code[20]; NewFieldName: Text[100])
    var
        NoSeriesLine2: Record "No. Series Line";
        TextManagement: Codeunit TextManagement;
        Length: Integer;
    begin
        if NewNo <> '' then begin
            TextManagement.EvaluateIncStr(NewNo, NewFieldName);
            NoSeriesLine2 := NoSeriesLine;
            if NewNo = GetNoText(NewNo) then
                Length := 0
            else begin
                Length := StrLen(GetNoText(NewNo));
                UpdateLength(NoSeriesLine."Starting No.", Length);
                UpdateLength(NoSeriesLine."Ending No.", Length);
                UpdateLength(NoSeriesLine."Last No. Used", Length);
                UpdateLength(NoSeriesLine."Warning No.", Length);
            end;
            UpdateNo(NoSeriesLine."Starting No.", NewNo, Length);
            UpdateNo(NoSeriesLine."Ending No.", NewNo, Length);
            UpdateNo(NoSeriesLine."Last No. Used", NewNo, Length);
            UpdateNo(NoSeriesLine."Warning No.", NewNo, Length);
            if (NewFieldName <> NoSeriesLine.FieldCaption("Last No. Used")) and
               (NoSeriesLine."Last No. Used" <> NoSeriesLine2."Last No. Used")
            then
                Error(
                  Text009,
                  NewFieldName, NoSeriesLine.FieldCaption("Last No. Used"));
        end;
    end;

    local procedure UpdateLength(No: Code[20]; var MaxLength: Integer)
    var
        Length: Integer;
    begin
        if No <> '' then begin
            Length := StrLen(DelChr(GetNoText(No), '<', '0'));
            if Length > MaxLength then
                MaxLength := Length;
        end;
    end;

    local procedure UpdateNo(var No: Code[20]; NewNo: Code[20]; Length: Integer)
    var
        StartPos: Integer;
        EndPos: Integer;
        TempNo: Code[20];
    begin
        if No <> '' then
            if Length <> 0 then begin
                No := DelChr(GetNoText(No), '<', '0');
                TempNo := No;
                No := NewNo;
                NewNo := TempNo;
                GetIntegerPos(No, StartPos, EndPos);
                ReplaceNoText(No, NewNo, Length, StartPos, EndPos);
            end;
    end;

    local procedure ReplaceNoText(var No: Code[20]; NewNo: Code[20]; FixedLength: Integer; StartPos: Integer; EndPos: Integer)
    var
        StartNo: Code[20];
        EndNo: Code[20];
        ZeroNo: Code[20];
        NewLength: Integer;
        OldLength: Integer;
    begin
        if StartPos > 1 then
            StartNo := CopyStr(No, 1, StartPos - 1);
        if EndPos < StrLen(No) then
            EndNo := CopyStr(No, EndPos + 1);
        NewLength := StrLen(NewNo);
        OldLength := EndPos - StartPos + 1;
        if FixedLength > OldLength then
            OldLength := FixedLength;
        if OldLength > NewLength then
            ZeroNo := PadStr('', OldLength - NewLength, '0');
        if StrLen(StartNo) + StrLen(ZeroNo) + StrLen(NewNo) + StrLen(EndNo) > 20 then
            Error(
              Text010,
              No);
        No := StartNo + ZeroNo + NewNo + EndNo;
    end;

    local procedure GetNoText(No: Code[20]): Code[20]
    var
        StartPos: Integer;
        EndPos: Integer;
    begin
        GetIntegerPos(No, StartPos, EndPos);
        if StartPos <> 0 then
            exit(CopyStr(No, StartPos, EndPos - StartPos + 1));
    end;

    local procedure GetIntegerPos(No: Code[20]; var StartPos: Integer; var EndPos: Integer)
    var
        IsDigit: Boolean;
        i: Integer;
    begin
        StartPos := 0;
        EndPos := 0;
        if No <> '' then begin
            i := StrLen(No);
            repeat
                IsDigit := No[i] in ['0' .. '9'];
                if IsDigit then begin
                    if EndPos = 0 then
                        EndPos := i;
                    StartPos := i;
                end;
                i := i - 1;
            until (i = 0) or (StartPos <> 0) and not IsDigit;
        end;
    end;

    [Scope('Personalization')]
    procedure GetNoSeriesWithCheck(NewNoSeriesCode: Code[20]; SelectNoSeriesAllowed: Boolean; CurrentNoSeriesCode: Code[20]): Code[20]
    begin
        if not SelectNoSeriesAllowed then
            exit(NewNoSeriesCode);

        NoSeries.Get(NewNoSeriesCode);
        if NoSeries."Default Nos." then
            exit(NewNoSeriesCode);

        if SeriesHasRelations(NewNoSeriesCode) then
            if SelectSeries(NewNoSeriesCode, '', CurrentNoSeriesCode) then
                exit(CurrentNoSeriesCode);
        exit(NewNoSeriesCode);
    end;

    [Scope('Personalization')]
    procedure SeriesHasRelations(DefaultNoSeriesCode: Code[20]): Boolean
    var
        NoSeriesRelationship: Record "No. Series Relationship";
    begin
        NoSeriesRelationship.Reset;
        NoSeriesRelationship.SetRange(Code, DefaultNoSeriesCode);
        exit(not NoSeriesRelationship.IsEmpty);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetNextNo3(var NoSeriesLine: Record "No. Series Line"; ModifySeries: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSaveNoSeries(var NoSeriesLine: Record "No. Series Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDoGetNextNo(var NoSeriesCode: Code[20]; var SeriesDate: Date; var ModifySeries: Boolean; var NoErrorsOrWarnings: Boolean)
    begin
    end;

    [Scope('Personalization')]
    procedure ClearStateAndGetNextNo(NoSeriesCode: Code[20]): Code[20]
    begin
        Clear(LastNoSeriesLine);
        Clear(TryNoSeriesCode);
        Clear(NoSeries);

        exit(GetNextNo(NoSeriesCode, WorkDate, false));
    end;
}

