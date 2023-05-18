codeunit 358 "DateFilter-Calc"
{

    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Fiscal Year %1';
        AccountingPeriod: Record "Accounting Period";
        StartDate: Date;

    [Scope('Personalization')]
    procedure CreateFiscalYearFilter(var "Filter": Text[30];var Name: Text[30];Date: Date;NextStep: Integer)
    begin
        CreateAccountingDateFilter(Filter,Name,true,Date,NextStep);
    end;

    [Scope('Personalization')]
    procedure CreateAccountingPeriodFilter(var "Filter": Text[30];var Name: Text[30];Date: Date;NextStep: Integer)
    begin
        CreateAccountingDateFilter(Filter,Name,false,Date,NextStep);
    end;

    [Scope('Personalization')]
    procedure ConvertToUtcDateTime(LocalDateTime: DateTime): DateTime
    var
        DotNetDateTimeOffset: DotNet DateTimeOffset;
        DotNetDateTimeOffsetNow: DotNet DateTimeOffset;
    begin
        if LocalDateTime = CreateDateTime(0D,0T) then
          exit(CreateDateTime(0D,0T));

        DotNetDateTimeOffset := DotNetDateTimeOffset.DateTimeOffset(LocalDateTime);
        DotNetDateTimeOffsetNow := DotNetDateTimeOffset.Now;
        exit(DotNetDateTimeOffset.LocalDateTime - DotNetDateTimeOffsetNow.Offset);
    end;

    local procedure CreateAccountingDateFilter(var "Filter": Text[30];var Name: Text[30];FiscalYear: Boolean;Date: Date;NextStep: Integer)
    begin
        AccountingPeriod.Reset;
        if FiscalYear then
          AccountingPeriod.SetRange("New Fiscal Year",true);
        AccountingPeriod."Starting Date" := Date;
        if not AccountingPeriod.Find('=<>') then
          exit;
        if AccountingPeriod."Starting Date" > Date then
          NextStep := NextStep - 1;
        if NextStep <> 0 then
          if AccountingPeriod.Next(NextStep) <> NextStep then begin
            if NextStep < 0 then
              Filter := '..' + Format(AccountingPeriod."Starting Date" - 1)
            else
              Filter := Format(AccountingPeriod."Starting Date") + '..' + Format(DMY2Date(31,12,9999));
            Name := '...';
            exit;
          end;
        StartDate := AccountingPeriod."Starting Date";
        if FiscalYear then
          Name := StrSubstNo(Text000,Format(Date2DMY(StartDate,3)))
        else
          Name := AccountingPeriod.Name;
        if AccountingPeriod.Next <> 0 then
          Filter := Format(StartDate) + '..' + Format(AccountingPeriod."Starting Date" - 1)
        else begin
          Filter := Format(StartDate) + '..' + Format(DMY2Date(31,12,9999));
          Name := Name + '...';
        end;
    end;
}

