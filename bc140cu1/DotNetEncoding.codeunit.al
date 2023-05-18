codeunit 3026 "DotNet_Encoding"
{

    trigger OnRun()
    begin
    end;

    var
        DotNetEncoding: DotNet Encoding;

    [Scope('Personalization')]
    procedure ASCII()
    begin
        DotNetEncoding := DotNetEncoding.ASCII;
    end;

    [Scope('Personalization')]
    procedure UTF8()
    begin
        DotNetEncoding := DotNetEncoding.UTF8;
    end;

    [Scope('Personalization')]
    procedure UTF32()
    begin
        DotNetEncoding := DotNetEncoding.UTF32;
    end;

    [Scope('Personalization')]
    procedure Unicode()
    begin
        DotNetEncoding := DotNetEncoding.Unicode;
    end;

    [Scope('Personalization')]
    procedure Encoding(codePage: Integer)
    begin
        DotNetEncoding := DotNetEncoding.GetEncoding(codePage);
    end;

    [Scope('Personalization')]
    procedure Codepage(): Integer
    begin
        exit(DotNetEncoding.CodePage);
    end;

    procedure GetEncoding(var DotNetEncoding2: DotNet Encoding)
    begin
        DotNetEncoding2 := DotNetEncoding;
    end;

    procedure SetEncoding(DotNetEncoding2: DotNet Encoding)
    begin
        DotNetEncoding := DotNetEncoding2;
    end;

    [Scope('Personalization')]
    procedure GetChars(DotNet_ArrayBytes: Codeunit DotNet_Array; Index: Integer; "Count": Integer; var DotNet_ArrayResult: Codeunit DotNet_Array)
    var
        DotNetArray: DotNet Array;
    begin
        DotNet_ArrayBytes.GetArray(DotNetArray);
        DotNet_ArrayResult.SetArray(DotNetEncoding.GetChars(DotNetArray, Index, Count));
    end;

    [Scope('Personalization')]
    procedure GetBytes(DotNet_ArrayChars: Codeunit DotNet_Array; Index: Integer; "Count": Integer; var DotNet_ArrayResult: Codeunit DotNet_Array)
    var
        DotNetArray: DotNet Array;
    begin
        DotNet_ArrayChars.GetArray(DotNetArray);
        DotNet_ArrayResult.SetArray(DotNetEncoding.GetBytes(DotNetArray, Index, Count));
    end;

    [Scope('Personalization')]
    procedure GetBytesWithOffset(DotNet_ArrayChars: Codeunit DotNet_Array; Index: Integer; "Count": Integer; var DotNet_ArrayResult: Codeunit DotNet_Array; ByteIndex: Integer)
    var
        DotNetArray: DotNet Array;
        DotNetArrayResult: DotNet Array;
    begin
        DotNet_ArrayChars.GetArray(DotNetArray);
        DotNet_ArrayResult.GetArray(DotNetArrayResult);
        DotNetEncoding.GetBytes(DotNetArray, Index, Count, DotNetArrayResult, ByteIndex);
    end;

    [Scope('Personalization')]
    procedure GetString(DotNet_ArrayBytes: Codeunit DotNet_Array; Index: Integer; "Count": Integer): Text
    var
        DotNetArray: DotNet Array;
    begin
        DotNet_ArrayBytes.GetArray(DotNetArray);
        exit(DotNetEncoding.GetString(DotNetArray, Index, Count));
    end;
}

