codeunit 705 "Stream Management"
{

    trigger OnRun()
    begin
    end;

    var
        MemoryStream: DotNet MemoryStream;

    [Scope('Personalization')]
    procedure MtomStreamToXmlStream(MtomStream: InStream; var XmlStream: InStream; ContentType: Text)
    var
        TextEncoding: DotNet Encoding;
        DotNetArray: DotNet Array;
        XmlDocument: DotNet XmlDocument;
        XmlDictionaryReader: DotNet XmlDictionaryReader;
        XmlDictionaryReaderQuotas: DotNet XmlDictionaryReaderQuotas;
    begin
        DotNetArray := DotNetArray.CreateInstance(GetDotNetType(TextEncoding), 1);
        DotNetArray.SetValue(TextEncoding.UTF8, 0);
        XmlDictionaryReader := XmlDictionaryReader.CreateMtomReader(MtomStream, DotNetArray, ContentType, XmlDictionaryReaderQuotas.Max);
        XmlDictionaryReader.MoveToContent;

        XmlDocument := XmlDocument.XmlDocument;
        XmlDocument.PreserveWhitespace := true;
        XmlDocument.Load(XmlDictionaryReader);
        MemoryStream := MemoryStream.MemoryStream;
        XmlDocument.Save(MemoryStream);
        MemoryStream.Position := 0;
        XmlStream := MemoryStream;
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure CreateNameValueBufferFromZipFileStream(Stream: InStream; var NameValueBufferOut: Record "Name/Value Buffer")
    var
        ZipArchive: DotNet ZipArchive;
        FileList: DotNet IReadOnlyList_Of_T;
        ZipArchiveEntry: DotNet ZipArchiveEntry;
        FileStream: InStream;
        out: OutStream;
        NrFiles: Integer;
        I: Integer;
        LastId: Integer;
    begin
        ZipArchive := ZipArchive.ZipArchive(Stream);
        NrFiles := ZipArchive.Entries.Count;
        FileList := ZipArchive.Entries;
        for I := 0 to NrFiles - 1 do begin
            if NameValueBufferOut.FindLast then
                LastId := NameValueBufferOut.ID;
            ZipArchiveEntry := FileList.Item(I);
            FileStream := ZipArchiveEntry.Open;
            NameValueBufferOut.ID := LastId + 1;
            NameValueBufferOut.Name := CopyStr(ZipArchiveEntry.Name, 1, 250);
            NameValueBufferOut."Value BLOB".CreateOutStream(out);
            CopyStream(out, FileStream);
            NameValueBufferOut.Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure InitGzipStreamFromTempBlob(var TempBlob: Record TempBlob; var DotNet_CompressionMode: Codeunit DotNet_CompressionMode; var DotNet_GzipStream: Codeunit DotNet_GzipStream)
    var
        DotNet_Stream: Codeunit DotNet_Stream;
        DotNetCompressionMode: DotNet CompressionMode;
        BaseInStream: InStream;
        BaseOutStream: OutStream;
    begin
        DotNet_CompressionMode.GetCompressionMode(DotNetCompressionMode);

        if DotNetCompressionMode.Equals(DotNetCompressionMode.Compress) then begin
            Clear(TempBlob.Blob);
            TempBlob.Blob.CreateOutStream(BaseOutStream);
            DotNet_Stream.FromOutStream(BaseOutStream);
        end else begin
            TempBlob.Blob.CreateInStream(BaseInStream);
            DotNet_Stream.FromInStream(BaseInStream);
        end;

        DotNet_GzipStream.GZipStream(DotNet_Stream, DotNet_CompressionMode);
    end;

    [Scope('Personalization')]
    procedure WriteGzipStreamToTempBlob(var DotNet_GzipStream: Codeunit DotNet_GzipStream; var TempBlob: Record TempBlob)
    var
        ResultStream: OutStream;
    begin
        Clear(TempBlob.Blob);
        TempBlob.Blob.CreateOutStream(ResultStream);
        DotNet_GzipStream.CopyTo(ResultStream);
    end;

    [Scope('Personalization')]
    procedure ReadGzipStreamFromTempBlob(var DotNet_GzipStream: Codeunit DotNet_GzipStream; var TempBlob: Record TempBlob)
    var
        DataStream: InStream;
    begin
        TempBlob.Blob.CreateInStream(DataStream);
        DotNet_GzipStream.CopyFrom(DataStream);
    end;
}

