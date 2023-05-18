codeunit 3034 DotNet_Stream
{

    trigger OnRun()
    begin
    end;

    var
        DotNetStream: DotNet Stream;

    [Scope('Personalization')]
    procedure FromInStream(InputStream: InStream)
    begin
        DotNetStream := InputStream;
    end;

    [Scope('Personalization')]
    procedure FromOutStream(OutputStream: OutStream)
    begin
        DotNetStream := OutputStream;
    end;

    [Scope('Personalization')]
    procedure IsDotNetNull(): Boolean
    begin
        exit(SYSTEM.IsNull(DotNetStream));
    end;

    [Scope('Personalization')]
    procedure Close()
    begin
        DotNetStream.Close();
    end;

    [Scope('Personalization')]
    procedure Dispose()
    begin
        DotNetStream.Dispose();
    end;

    [Scope('Personalization')]
    procedure CanSeek(): Boolean
    begin
        exit(DotNetStream.CanSeek);
    end;

    [Scope('Personalization')]
    procedure CanRead(): Boolean
    begin
        exit(DotNetStream.CanRead);
    end;

    [Scope('Personalization')]
    procedure CanWrite(): Boolean
    begin
        exit(DotNetStream.CanWrite);
    end;

    [Scope('Personalization')]
    procedure Length(): BigInteger
    begin
        exit(DotNetStream.Length);
    end;

    [Scope('Personalization')]
    procedure Position(): BigInteger
    begin
        exit(DotNetStream.Position);
    end;

    [Scope('Personalization')]
    procedure ReadByte(): Integer
    begin
        exit(DotNetStream.ReadByte());
    end;

    [Scope('Personalization')]
    procedure WriteByte(Value: Integer)
    begin
        DotNetStream.WriteByte(Value);
    end;

    [Scope('Personalization')]
    procedure Seek(Offset: Integer;var DotNet_SeekOrigin: Codeunit DotNet_SeekOrigin): BigInteger
    var
        DotNetSeekOrigin: DotNet SeekOrigin;
    begin
        DotNet_SeekOrigin.GetSeekOrigin(DotNetSeekOrigin);
        exit(DotNetStream.Seek(Offset,DotNetSeekOrigin));
    end;

    [Scope('Personalization')]
    procedure Read(var DotNet_Array: Codeunit DotNet_Array;Offset: Integer;"Count": Integer): Integer
    var
        DotNetArray: DotNet Array;
    begin
        DotNet_Array.GetArray(DotNetArray);
        exit(DotNetStream.Read(DotNetArray,Offset,Count));
    end;

    [Scope('Personalization')]
    procedure Write(var DotNet_Array: Codeunit DotNet_Array;Offset: Integer;"Count": Integer)
    var
        DotNetArray: DotNet Array;
    begin
        DotNet_Array.GetArray(DotNetArray);
        DotNetStream.Write(DotNetArray,Offset,Count);
    end;

    procedure GetStream(var CurrentDotNetStream: DotNet Stream)
    begin
        CurrentDotNetStream := DotNetStream;
    end;

    procedure SetStream(NewDotNetStream: DotNet Stream)
    begin
        DotNetStream := NewDotNetStream;
    end;
}

