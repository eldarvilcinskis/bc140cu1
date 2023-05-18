codeunit 3039 DotNet_SeekOrigin
{

    trigger OnRun()
    begin
    end;

    var
        DotNetSeekOrigin: DotNet SeekOrigin;

    [Scope('Personalization')]
    procedure SeekBegin()
    begin
        DotNetSeekOrigin := DotNetSeekOrigin."Begin";
    end;

    [Scope('Personalization')]
    procedure SeekCurrent()
    begin
        DotNetSeekOrigin := DotNetSeekOrigin.Current;
    end;

    [Scope('Personalization')]
    procedure SeekEnd()
    begin
        DotNetSeekOrigin := DotNetSeekOrigin."End";
    end;

    procedure GetSeekOrigin(var DotNetSeekOrigin2: DotNet SeekOrigin)
    begin
        DotNetSeekOrigin2 := DotNetSeekOrigin;
    end;

    procedure SetSeekOrigin(var DotNetSeekOrigin2: DotNet SeekOrigin)
    begin
        DotNetSeekOrigin := DotNetSeekOrigin2;
    end;
}

