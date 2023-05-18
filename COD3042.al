codeunit 3042 DotNet_X509ContentType
{

    trigger OnRun()
    begin
    end;

    var
        DotNetX509ContentType: DotNet X509ContentType;

    procedure Pkcs12()
    begin
        DotNetX509ContentType := DotNetX509ContentType.Pkcs12;
    end;

    procedure GetX509ContentType(var DotNetX509ContentType2: DotNet X509ContentType)
    begin
        DotNetX509ContentType2 := DotNetX509ContentType;
    end;

    procedure SetX509ContentType(var DotNetX509ContentType2: DotNet X509ContentType)
    begin
        DotNetX509ContentType := DotNetX509ContentType2;
    end;
}

