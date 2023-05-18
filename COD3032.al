codeunit 3032 DotNet_BinaryReader
{

    trigger OnRun()
    begin
    end;

    var
        DotNetBinaryReader: DotNet BinaryReader;

    [Scope('Personalization')]
    procedure BinaryReader(var DotNet_Stream: Codeunit DotNet_Stream)
    var
        DotNetStream: DotNet Stream;
    begin
        DotNet_Stream.GetStream(DotNetStream);
        DotNetBinaryReader := DotNetBinaryReader.BinaryReader(DotNetStream);
    end;

    [Scope('Personalization')]
    procedure BinaryReaderWithEncoding(var DotNet_Stream: Codeunit DotNet_Stream;var DotNet_Encoding: Codeunit DotNet_Encoding)
    var
        DotNetEncoding: DotNet Encoding;
        DotNetStream: DotNet Stream;
    begin
        DotNet_Stream.GetStream(DotNetStream);
        DotNet_Encoding.GetEncoding(DotNetEncoding);
        DotNetBinaryReader := DotNetBinaryReader.BinaryReader(DotNetStream,DotNetEncoding);
    end;

    [Scope('Personalization')]
    procedure Close()
    begin
        DotNetBinaryReader.Close;
    end;

    [Scope('Personalization')]
    procedure Dispose()
    begin
        DotNetBinaryReader.Dispose;
    end;

    [Scope('Personalization')]
    procedure ReadByte(): Byte
    begin
        exit(DotNetBinaryReader.ReadByte());
    end;

    [Scope('Personalization')]
    procedure ReadUInt32(): Integer
    begin
        exit(DotNetBinaryReader.ReadUInt32());
    end;

    [Scope('Personalization')]
    procedure ReadUInt16(): Integer
    begin
        exit(DotNetBinaryReader.ReadUInt16());
    end;

    [Scope('Personalization')]
    procedure ReadInt16(): Integer
    begin
        exit(DotNetBinaryReader.ReadInt16());
    end;

    [Scope('Personalization')]
    procedure ReadInt32(): Integer
    begin
        exit(DotNetBinaryReader.ReadInt32());
    end;

    [Scope('Personalization')]
    procedure ReadBytes("Count": Integer;var DotNet_Array: Codeunit DotNet_Array)
    begin
        DotNet_Array.SetArray(DotNetBinaryReader.ReadBytes(Count));
    end;

    [Scope('Personalization')]
    procedure ReadChars("Count": Integer;var DotNet_Array: Codeunit DotNet_Array)
    begin
        DotNet_Array.SetArray(DotNetBinaryReader.ReadChars(Count));
    end;

    [Scope('Personalization')]
    procedure IsDotNetNull(): Boolean
    begin
        exit(IsNull(DotNetBinaryReader));
    end;

    [Scope('Personalization')]
    procedure BaseStream(var DotNet_Stream: Codeunit DotNet_Stream)
    begin
        DotNet_Stream.SetStream(DotNetBinaryReader.BaseStream);
    end;

    [Scope('Personalization')]
    procedure ReadChar(): Char
    begin
        exit(DotNetBinaryReader.ReadChar());
    end;

    [Scope('Personalization')]
    procedure ReadString(): Text
    begin
        exit(DotNetBinaryReader.ReadString());
    end;

    [Scope('Personalization')]
    procedure ReadBoolean(): Boolean
    begin
        exit(DotNetBinaryReader.ReadBoolean());
    end;

    [Scope('Personalization')]
    procedure ReadDecimal(): Decimal
    begin
        exit(DotNetBinaryReader.ReadDecimal());
    end;

    procedure GetBinaryReader(var DotNetBinaryReader2: DotNet BinaryReader)
    begin
        DotNetBinaryReader2 := DotNetBinaryReader
    end;

    procedure SetBinaryReader(var DotNetBinaryReader2: DotNet BinaryReader)
    begin
        DotNetBinaryReader := DotNetBinaryReader2
    end;
}

