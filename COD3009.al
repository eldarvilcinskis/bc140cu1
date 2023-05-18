codeunit 3009 DotNet_MemoryStream
{

    trigger OnRun()
    begin
    end;

    var
        DotNetMemoryStream: DotNet MemoryStream;

    [Scope('Personalization')]
    procedure InitMemoryStream()
    begin
        DotNetMemoryStream := DotNetMemoryStream.MemoryStream
    end;

    [Scope('Personalization')]
    procedure InitMemoryStreamFromArray(var DotNet_Array: Codeunit DotNet_Array)
    var
        DotNetArray: DotNet Array;
    begin
        DotNet_Array.GetArray(DotNetArray);
        DotNetMemoryStream := DotNetMemoryStream.MemoryStream(DotNetArray)
    end;

    [Scope('Personalization')]
    procedure ToArray(var DotNet_Array: Codeunit DotNet_Array)
    begin
        DotNet_Array.SetArray(DotNetMemoryStream.ToArray)
    end;

    [Scope('Personalization')]
    procedure WriteTo(var OutStream: OutStream)
    begin
        DotNetMemoryStream.WriteTo(OutStream)
    end;

    [Scope('Personalization')]
    procedure Close()
    begin
        DotNetMemoryStream.Close
    end;

    [Scope('Personalization')]
    procedure CopyFromInStream(var InStream: InStream)
    begin
        CopyStream(DotNetMemoryStream,InStream)
    end;

    [Scope('Personalization')]
    procedure GetDotNetStream(var DotNet_Stream: Codeunit DotNet_Stream)
    begin
        DotNet_Stream.SetStream(DotNetMemoryStream);
    end;

    [Scope('Personalization')]
    procedure SetPosition(NewPosition: Integer)
    begin
        DotNetMemoryStream.Position := NewPosition;
    end;

    procedure GetMemoryStream(var DotNetMemoryStream2: DotNet MemoryStream)
    begin
        DotNetMemoryStream2 := DotNetMemoryStream
    end;

    procedure SetMemoryStream(DotNetMemoryStream2: DotNet MemoryStream)
    begin
        DotNetMemoryStream := DotNetMemoryStream2
    end;
}

