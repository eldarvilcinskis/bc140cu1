codeunit 3000 DotNet_Array
{

    trigger OnRun()
    begin
    end;

    var
        DotNetArray: DotNet Array;

    [Scope('Personalization')]
    procedure StringArray(Length: Integer)
    var
        DotNetString: DotNet String;
    begin
        DotNetArray := DotNetArray.CreateInstance(GetDotNetType(DotNetString),Length);
    end;

    [Scope('Personalization')]
    procedure CharArray(Length: Integer)
    var
        DotNetChar: DotNet Char;
    begin
        DotNetArray := DotNetArray.CreateInstance(GetDotNetType(DotNetChar),Length);
    end;

    [Scope('Personalization')]
    procedure ByteArray(Length: Integer)
    var
        DotNetByte: DotNet Byte;
    begin
        DotNetArray := DotNetArray.CreateInstance(GetDotNetType(DotNetByte),Length);
    end;

    [Scope('Personalization')]
    procedure Int32Array(Length: Integer)
    var
        DotNetInt32: DotNet Int32;
    begin
        DotNetArray := DotNetArray.CreateInstance(GetDotNetType(DotNetInt32),Length);
    end;

    [Scope('Personalization')]
    procedure Length(): Integer
    begin
        exit(DotNetArray.Length)
    end;

    [Scope('Personalization')]
    procedure SetTextValue(NewValue: Text;Index: Integer)
    begin
        DotNetArray.SetValue(NewValue,Index);
    end;

    [Scope('Personalization')]
    procedure SetCharValue(NewValue: Char;Index: Integer)
    begin
        DotNetArray.SetValue(NewValue,Index);
    end;

    [Scope('Personalization')]
    procedure SetByteValue(NewValue: Byte;Index: Integer)
    begin
        DotNetArray.SetValue(NewValue,Index);
    end;

    [Scope('Personalization')]
    procedure SetIntValue(NewValue: Integer;Index: Integer)
    begin
        DotNetArray.SetValue(NewValue,Index);
    end;

    [Scope('Personalization')]
    procedure GetValueAsText(Index: Integer): Text
    begin
        exit(DotNetArray.GetValue(Index))
    end;

    [Scope('Personalization')]
    procedure GetValueAsChar(Index: Integer): Char
    begin
        exit(DotNetArray.GetValue(Index));
    end;

    [Scope('Personalization')]
    procedure GetValueAsInteger(Index: Integer): Integer
    begin
        exit(DotNetArray.GetValue(Index));
    end;

    procedure GetArray(var DotNetArray2: DotNet Array)
    begin
        DotNetArray2 := DotNetArray
    end;

    procedure SetArray(DotNetArray2: DotNet Array)
    begin
        DotNetArray := DotNetArray2
    end;

    [Scope('Personalization')]
    procedure IsNull(): Boolean
    begin
        exit(SYSTEM.IsNull(DotNetArray));
    end;
}

