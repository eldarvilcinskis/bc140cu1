codeunit 5610 "Calculate Depreciation"
{

    trigger OnRun()
    begin
    end;

    var
        DeprBook: Record "Depreciation Book";
        FADeprBook: Record "FA Depreciation Book";
        CalculateNormalDepr: Codeunit "Calculate Normal Depreciation";
        CalculateCustom1Depr: Codeunit "Calculate Custom 1 Depr.";

    [Scope('Personalization')]
    procedure Calculate(var DeprAmount: Decimal; var Custom1Amount: Decimal; var NumberOfDays: Integer; var Custom1NumberOfDays: Integer; FANo: Code[20]; DeprBookCode: Code[10]; UntilDate: Date; EntryAmounts: array[4] of Decimal; DateFromProjection: Date; DaysInPeriod: Integer)
    begin
        DeprAmount := 0;
        Custom1Amount := 0;
        NumberOfDays := 0;
        Custom1NumberOfDays := 0;
        if not DeprBook.Get(DeprBookCode) then
            exit;
        if not FADeprBook.Get(FANo, DeprBookCode) then
            exit;

        CheckDeprDaysInFiscalYear(DateFromProjection = 0D, UntilDate);

        if DeprBook."Use Custom 1 Depreciation" and
           (FADeprBook."Depr. Ending Date (Custom 1)" > 0D)
        then
            CalculateCustom1Depr.Calculate(
              DeprAmount, Custom1Amount, NumberOfDays,
              Custom1NumberOfDays, FANo, DeprBookCode, UntilDate,
              EntryAmounts, DateFromProjection, DaysInPeriod)
        else
            CalculateNormalDepr.Calculate(
              DeprAmount, NumberOfDays, FANo, DeprBookCode, UntilDate,
              EntryAmounts, DateFromProjection, DaysInPeriod);
    end;

    local procedure CheckDeprDaysInFiscalYear(CheckDeprDays: Boolean; UntilDate: Date)
    var
        DepreciationCalc: Codeunit "Depreciation Calculation";
        FADateCalc: Codeunit "FA Date Calculation";
        FiscalYearBegin: Date;
        NoOfDeprDays: Integer;
    begin
        if DeprBook."Allow more than 360/365 Days" or not CheckDeprDays then
            exit;
        if (FADeprBook."Depreciation Method" = FADeprBook."Depreciation Method"::"Declining-Balance 1") or
           (FADeprBook."Depreciation Method" = FADeprBook."Depreciation Method"::"DB1/SL")
        then
            FiscalYearBegin := FADateCalc.GetFiscalYear(DeprBook.Code, UntilDate);
        if DeprBook."Fiscal Year 365 Days" then
            NoOfDeprDays := 365
        else
            NoOfDeprDays := 360;
        if DepreciationCalc.DeprDays(
             FiscalYearBegin, UntilDate, DeprBook."Fiscal Year 365 Days") > NoOfDeprDays
        then
            DeprBook.TestField("Allow more than 360/365 Days");
    end;
}

