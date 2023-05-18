codeunit 3033 DotNet_BinaryWriter
{

    trigger OnRun()
    begin
    end;

    var
        DotNetBinaryWriter: DotNet BinaryWriter;

    [Scope('Personalization')]
    procedure BinaryWriter(var DotNet_Stream: Codeunit DotNet_Stream)
    var
        DotNetStream: DotNet Stream;
    begin
        DotNet_Stream.GetStream(DotNetStream);
        DotNetBinaryWriter := DotNetBinaryWriter.BinaryWriter(DotNetStream);
    end;

    [Scope('Personalization')]
    procedure BinaryWriterWithEncoding(var DotNet_Stream: Codeunit DotNet_Stream;var DotNet_Encoding: Codeunit DotNet_Encoding)
    var
        DotNetEncoding: DotNet Encoding;
        DotNetStream: DotNet Stream;
    begin
        DotNet_Encoding.GetEncoding(DotNetEncoding);
        DotNet_Stream.GetStream(DotNetStream);
        DotNetBinaryWriter := DotNetBinaryWriter.BinaryWriter(DotNetStream,DotNetEncoding);
    end;

    [Scope('Personalization')]
    procedure Close()
    begin
        DotNetBinaryWriter.Close();
    end;

    [Scope('Personalization')]
    procedure Dispose()
    begin
        DotNetBinaryWriter.Dispose();
    end;

    [Scope('Personalization')]
    procedure Flush()
    begin
        DotNetBinaryWriter.Flush();
    end;

    [Scope('Personalization')]
    procedure IsDotNetNull(): Boolean
    begin
        exit(IsNull(DotNetBinaryWriter));
    end;

    [Scope('Personalization')]
    procedure Seek(Offset: Integer;var DotNet_SeekOrigin: Codeunit DotNet_SeekOrigin): BigInteger
    var
        DotNetSeekOrigin: DotNet SeekOrigin;
    begin
        DotNet_SeekOrigin.GetSeekOrigin(DotNetSeekOrigin);
        exit(DotNetBinaryWriter.Seek(Offset,DotNetSeekOrigin));
    end;

    [Scope('Personalization')]
    procedure WriteByte(Byte: Byte)
    begin
        DotNetBinaryWriter.Write(Byte);
    end;

    [Scope('Personalization')]
    procedure WriteInt32("Integer": Integer)
    var
        DotNetConvert: DotNet Convert;
    begin
        DotNetBinaryWriter.Write(DotNetConvert.ToInt32(Integer));
    end;

    [Scope('Personalization')]
    procedure WriteInt16("Integer": Integer)
    var
        DotNetConvert: DotNet Convert;
    begin
        DotNetBinaryWriter.Write(DotNetConvert.ToInt16(Integer))
    end;

    [Scope('Personalization')]
    procedure WriteUInt16("Integer": Integer)
    var
        DotNetConvert: DotNet Convert;
    begin
        DotNetBinaryWriter.Write(DotNetConvert.ToUInt16(Integer))
    end;

    [Scope('Personalization')]
    procedure WriteUInt32("Integer": Integer)
    var
        DotNetConvert: DotNet Convert;
    begin
        DotNetBinaryWriter.Write(DotNetConvert.ToUInt32(Integer))
    end;

    [Scope('Personalization')]
    procedure WriteChar(Char: Char)
    begin
        DotNetBinaryWriter.Write(Char)
    end;

    [Scope('Personalization')]
    procedure BaseStream(var DotNet_Stream: Codeunit DotNet_Stream)
    begin
        DotNet_Stream.SetStream(DotNetBinaryWriter.BaseStream);
    end;

    [Scope('Personalization')]
    procedure WriteString(Text: Text)
    begin
        DotNetBinaryWriter.Write(Text);
    end;

    [Scope('Personalization')]
    procedure WriteBoolean(Boolean: Boolean)
    begin
        DotNetBinaryWriter.Write(Boolean)
    end;

    [Scope('Personalization')]
    procedure WriteDecimal(Decimal: Decimal)
    begin
        DotNetBinaryWriter.Write(Decimal);
    end;
}

