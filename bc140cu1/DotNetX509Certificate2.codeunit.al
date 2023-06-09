codeunit 3043 "DotNet_X509Certificate2"
{

    trigger OnRun()
    begin
    end;

    var
        DotNetX509Certificate2: DotNet X509Certificate2;
        LoadCertificateErr: Label 'Failed to load certificate.';

    [Scope('Personalization')]
    procedure X509Certificate2(DotNet_Array: Codeunit DotNet_Array; Password: Text; DotNet_X509KeyStorageFlags: Codeunit DotNet_X509KeyStorageFlags)
    var
        DotNetArray: DotNet Array;
        DotNetX509KeyStorageFlags: DotNet X509KeyStorageFlags;
    begin
        DotNet_Array.GetArray(DotNetArray);
        DotNet_X509KeyStorageFlags.GetX509KeyStorageFlags(DotNetX509KeyStorageFlags);
        DotNetX509Certificate2 := DotNetX509Certificate2.X509Certificate2(DotNetArray, Password, DotNetX509KeyStorageFlags);

        if IsNull(DotNetX509Certificate2) then
            Error(LoadCertificateErr);
    end;

    [Scope('Personalization')]
    procedure Export(DotNet_X509ContentType: Codeunit DotNet_X509ContentType; Password: Text; var DotNet_Array: Codeunit DotNet_Array)
    var
        DotNetX509ContentType: DotNet X509ContentType;
    begin
        DotNet_X509ContentType.GetX509ContentType(DotNetX509ContentType);
        DotNet_Array.SetArray(DotNetX509Certificate2.Export(DotNetX509ContentType, Password));
    end;

    [Scope('Personalization')]
    procedure FriendlyName(): Text
    begin
        exit(DotNetX509Certificate2.FriendlyName);
    end;

    [Scope('Personalization')]
    procedure Thumbprint(): Text
    begin
        exit(DotNetX509Certificate2.Thumbprint);
    end;

    [Scope('Personalization')]
    procedure Issuer(): Text
    begin
        exit(DotNetX509Certificate2.Issuer);
    end;

    [Scope('Personalization')]
    procedure Subject(): Text
    begin
        exit(DotNetX509Certificate2.Subject);
    end;

    [Scope('Personalization')]
    procedure Expiration() Expiration: DateTime
    begin
        Evaluate(Expiration, DotNetX509Certificate2.GetExpirationDateString);
    end;

    [Scope('Personalization')]
    procedure HasPrivateKey(): Boolean
    begin
        exit(DotNetX509Certificate2.HasPrivateKey);
    end;

    procedure GetX509Certificate2(var DotNetX509Certificate2_2: DotNet X509Certificate2)
    begin
        DotNetX509Certificate2_2 := DotNetX509Certificate2;
    end;

    procedure SetX509Certificate2(var DotNetX509Certificate2_2: DotNet X509Certificate2)
    begin
        DotNetX509Certificate2 := DotNetX509Certificate2_2;
    end;
}

