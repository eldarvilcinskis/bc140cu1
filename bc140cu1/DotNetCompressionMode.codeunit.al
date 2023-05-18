codeunit 3037 "DotNet_CompressionMode"
{

    trigger OnRun()
    begin
    end;

    var
        DotNetCompressionMode: DotNet CompressionMode;

    [Scope('Personalization')]
    procedure Compress()
    begin
        DotNetCompressionMode := DotNetCompressionMode.Compress
    end;

    [Scope('Personalization')]
    procedure Decompress()
    begin
        DotNetCompressionMode := DotNetCompressionMode.Decompress
    end;

    procedure GetCompressionMode(var DotNetCompressionMode2: DotNet CompressionMode)
    begin
        DotNetCompressionMode2 := DotNetCompressionMode
    end;

    procedure SetCompressionMode(var DotNetCompressionMode2: DotNet CompressionMode)
    begin
        DotNetCompressionMode := DotNetCompressionMode2
    end;
}

