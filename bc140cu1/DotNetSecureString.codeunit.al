codeunit 3044 "DotNet_SecureString"
{

    trigger OnRun()
    begin
    end;

    var
        DotNetSecureString: DotNet SecureString;

    [Scope('Personalization')]
    procedure SecureString()
    begin
        DotNetSecureString := DotNetSecureString.SecureString;
    end;

    [Scope('Personalization')]
    procedure AppendChar(C: Char)
    begin
        DotNetSecureString.AppendChar(C);
    end;

    procedure GetSecureString(var DotNetSecureString2: DotNet SecureString)
    begin
        DotNetSecureString2 := DotNetSecureString;
    end;

    procedure SetSecureString(var DotNetSecureString2: DotNet SecureString)
    begin
        DotNetSecureString := DotNetSecureString2;
    end;
}

