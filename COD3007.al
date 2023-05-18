codeunit 3007 DotNet_String
{

    trigger OnRun()
    begin
    end;

    var
        DotNetString: DotNet String;

    [Scope('Personalization')]
    procedure FromCharArray(DotNet_ArrayChar: Codeunit DotNet_Array)
    var
        DotNetArray: DotNet Array;
    begin
        DotNet_ArrayChar.GetArray(DotNetArray);
        DotNetString := DotNetString.String(DotNetArray);
    end;

    [Scope('Personalization')]
    procedure Set(Text: Text)
    begin
        DotNetString := Text
    end;

    [Scope('Personalization')]
    procedure Replace(ToReplace: Text;ReplacementText: Text): Text
    begin
        exit(DotNetString.Replace(ToReplace,ReplacementText))
    end;

    [Scope('Personalization')]
    procedure Split(DotNet_ArraySplit: Codeunit DotNet_Array;var DotNet_ArrayReturn: Codeunit DotNet_Array)
    var
        DotNetArraySplit: DotNet Array;
    begin
        DotNet_ArraySplit.GetArray(DotNetArraySplit);
        DotNet_ArrayReturn.SetArray(DotNetString.Split(DotNetArraySplit));
    end;

    [Scope('Personalization')]
    procedure ToCharArray(StartIndex: Integer;Length: Integer;var DotNet_Array: Codeunit DotNet_Array)
    begin
        DotNet_Array.SetArray(DotNetString.ToCharArray(StartIndex,Length));
    end;

    [Scope('Personalization')]
    procedure Length(): Integer
    begin
        exit(DotNetString.Length);
    end;

    [Scope('Personalization')]
    procedure StartsWith(Value: Text): Boolean
    begin
        exit(DotNetString.StartsWith(Value))
    end;

    [Scope('Personalization')]
    procedure EndsWith(Value: Text): Boolean
    begin
        exit(DotNetString.EndsWith(Value))
    end;

    [Scope('Personalization')]
    procedure ToString(): Text
    begin
        exit(DotNetString.ToString);
    end;

    [Scope('Personalization')]
    procedure IsDotNetNull(): Boolean
    begin
        exit(IsNull(DotNetString));
    end;

    procedure GetString(var DotNetString2: DotNet String)
    begin
        DotNetString2 := DotNetString
    end;

    procedure SetString(DotNetString2: DotNet String)
    begin
        DotNetString := DotNetString2
    end;

    [Scope('Personalization')]
    procedure PadRight(TotalWidth: Integer;PaddingChar: Char): Text
    begin
        exit(DotNetString.PadRight(TotalWidth,PaddingChar));
    end;

    [Scope('Personalization')]
    procedure PadLeft(TotalWidth: Integer;PaddingChar: Char): Text
    begin
        exit(DotNetString.PadLeft(TotalWidth,PaddingChar));
    end;

    [Scope('Personalization')]
    procedure IndexOfChar(Value: Char;StartIndex: Integer): Integer
    begin
        exit(DotNetString.IndexOf(Value,StartIndex));
    end;

    [Scope('Personalization')]
    procedure IndexOfString(Value: Text;StartIndex: Integer): Integer
    begin
        exit(DotNetString.IndexOf(Value,StartIndex));
    end;

    [Scope('Personalization')]
    procedure Substring(StartIndex: Integer;Length: Integer): Text
    begin
        exit(DotNetString.Substring(StartIndex,Length));
    end;

    [Scope('Personalization')]
    procedure Trim(): Text
    begin
        exit(DotNetString.Trim);
    end;

    [Scope('Personalization')]
    procedure TrimStart(var DotNet_ArrayTrimChars: Codeunit DotNet_Array): Text
    var
        DotNetArray: DotNet Array;
    begin
        DotNet_ArrayTrimChars.GetArray(DotNetArray);
        exit(DotNetString.TrimStart(DotNetArray));
    end;

    [Scope('Personalization')]
    procedure TrimEnd(var DotNet_ArrayTrimChars: Codeunit DotNet_Array): Text
    var
        DotNetArray: DotNet Array;
    begin
        DotNet_ArrayTrimChars.GetArray(DotNetArray);
        exit(DotNetString.TrimEnd(DotNetArray));
    end;
}

