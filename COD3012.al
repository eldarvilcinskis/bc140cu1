codeunit 3012 DotNet_ImageFormat
{

    trigger OnRun()
    begin
    end;

    var
        DotNetImageFormat: DotNet ImageFormat;

    procedure GetImageFormat(var DotNetImageFormat2: DotNet ImageFormat)
    begin
        DotNetImageFormat2 := DotNetImageFormat
    end;

    procedure SetImageFormat(DotNetImageFormat2: DotNet ImageFormat)
    begin
        DotNetImageFormat := DotNetImageFormat2
    end;
}

