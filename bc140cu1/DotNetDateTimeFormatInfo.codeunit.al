codeunit 3022 "DotNet_DateTimeFormatInfo"
{

    trigger OnRun()
    begin
    end;

    var
        DotNetDateTimeFormatInfo: DotNet DateTimeFormatInfo;

    procedure GetDateTimeFormatInfo(var DotNetDateTimeFormatInfo2: DotNet DateTimeFormatInfo)
    begin
        DotNetDateTimeFormatInfo2 := DotNetDateTimeFormatInfo
    end;

    procedure SetDateTimeFormatInfo(DotNetDateTimeFormatInfo2: DotNet DateTimeFormatInfo)
    begin
        DotNetDateTimeFormatInfo := DotNetDateTimeFormatInfo2
    end;
}

