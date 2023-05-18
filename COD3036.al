codeunit 3036 DotNet_GzipStream
{

    trigger OnRun()
    begin
    end;

    var
        DotNetGZipStream: DotNet GZipStream;

    [Scope('Personalization')]
    procedure GZipStream(var DotNet_Stream: Codeunit DotNet_Stream;var DotNet_CompressionMode: Codeunit DotNet_CompressionMode)
    var
        DotNetCompressionMode: DotNet CompressionMode;
        DotNetStream: DotNet Stream;
    begin
        DotNet_Stream.GetStream(DotNetStream);
        DotNet_CompressionMode.GetCompressionMode(DotNetCompressionMode);

        DotNetGZipStream := DotNetGZipStream.GZipStream(DotNetStream,DotNetCompressionMode);
    end;

    [Scope('Personalization')]
    procedure CopyTo(var OutStream: OutStream)
    begin
        DotNetGZipStream.CopyTo(OutStream);
    end;

    [Scope('Personalization')]
    procedure CopyFrom(var InStream: InStream)
    begin
        CopyStream(DotNetGZipStream,InStream);
    end;

    [Scope('Personalization')]
    procedure Close()
    begin
        DotNetGZipStream.Close();
    end;

    [Scope('Personalization')]
    procedure Dispose()
    begin
        DotNetGZipStream.Dispose();
    end;

    [Scope('Personalization')]
    procedure CanRead(): Boolean
    begin
        exit(DotNetGZipStream.CanRead);
    end;

    [Scope('Personalization')]
    procedure CanWrite(): Boolean
    begin
        exit(DotNetGZipStream.CanWrite);
    end;

    [Scope('Personalization')]
    procedure GetDotNetStream(var DotNet_Stream: Codeunit DotNet_Stream)
    begin
        DotNet_Stream.SetStream(DotNetGZipStream);
    end;

    [Scope('Personalization')]
    procedure Flush()
    begin
        DotNetGZipStream.Flush();
    end;

    procedure GetGZipStream(var CurrentDotNetGZipStream: DotNet GZipStream)
    begin
        CurrentDotNetGZipStream := DotNetGZipStream;
    end;

    procedure SetGZipStream(NewDotNetGZipStream: DotNet GZipStream)
    begin
        DotNetGZipStream := NewDotNetGZipStream;
    end;
}

