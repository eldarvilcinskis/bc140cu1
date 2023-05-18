codeunit 491 "Memory Mapped File"
{

    trigger OnRun()
    begin
    end;

    var
        MemoryMappedFile: DotNet MemoryMappedFile;
        MemFileName: Text;
        NoNameSpecifiedErr: Label 'You need to specify a name for the memory mapped file.';

    [TryFunction]
    procedure CreateMemoryMappedFileFromText(Text: Text; Name: Text)
    var
        MemoryMappedViewStream: DotNet MemoryMappedViewStream;
        c: Char;
        i: Integer;
    begin
        MemFileName := Name;
        MemoryMappedFile := MemoryMappedFile.CreateOrOpen(MemFileName, StrLen(Text));
        MemoryMappedViewStream := MemoryMappedFile.CreateViewStream;
        for i := 1 to StrLen(Text) do begin
            c := Text[i];
            MemoryMappedViewStream.WriteByte(c);
        end;
        MemoryMappedViewStream.Flush;
        MemoryMappedViewStream.Dispose;
    end;

    [TryFunction]
    procedure CreateMemoryMappedFileFromTempBlob(var TempBlob: Record TempBlob; Name: Text)
    begin
        // clean up previous use
        if not IsNull(MemoryMappedFile) then
            if Dispose then;
        if not TempBlob.Blob.HasValue then
            exit;
        CreateMemoryMappedFileFromText(TempBlob.GetXMLAsText, Name);
    end;

    [TryFunction]
    procedure CreateMemoryMappedFileFromJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    var
        TempBlob: Record TempBlob;
    begin
        TempBlob.Blob := JobQueueEntry.XML;
        CreateMemoryMappedFileFromTempBlob(TempBlob, Format(JobQueueEntry.ID));
    end;

    [TryFunction]
    procedure OpenMemoryMappedFile(Name: Text)
    begin
        if Name = '' then
            Error(NoNameSpecifiedErr);
        MemFileName := Name;
        MemoryMappedFile := MemoryMappedFile.OpenExisting(MemFileName);
    end;

    [TryFunction]
    procedure ReadTextFromMemoryMappedFile(var Text: Text)
    var
        TempBlob: Record TempBlob temporary;
        InStr: InStream;
        MemoryMappedViewStream: DotNet MemoryMappedViewStream;
    begin
        if MemFileName = '' then
            Error(NoNameSpecifiedErr);

        MemoryMappedViewStream := MemoryMappedFile.CreateViewStream;
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(InStr);
        MemoryMappedViewStream.CopyTo(InStr);
        InStr.ReadText(Text);
        Clear(TempBlob.Blob);
        MemoryMappedViewStream.Dispose;
    end;

    procedure GetName(): Text
    begin
        exit(MemFileName);
    end;

    [TryFunction]
    procedure Dispose()
    begin
        MemoryMappedFile.Dispose;
        MemFileName := '';
    end;
}

