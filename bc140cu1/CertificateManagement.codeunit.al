codeunit 1259 "Certificate Management"
{

    trigger OnRun()
    begin
    end;

    var
        TempBlob: Record TempBlob;
        DotNet_X509Certificate2: Codeunit DotNet_X509Certificate2;
        PasswordSuffixTxt: Label 'Password', Locked = true;
        SavingPasswordErr: Label 'Could not save the password.';
        SavingCertErr: Label 'Could not save the certificate.';
        ReadingCertErr: Label 'Could not get the certificate.';
        FileManagement: Codeunit "File Management";
        SelectFileTxt: Label 'Select a certificate file';
        CertFileNotValidDotNetTok: Label 'Cannot find the requested object.', Locked = true;
        CertFileNotValidErr: Label 'This is not a valid certificate file.';
        CertFileFilterTxt: Label 'Certificate Files (*.pfx, *.p12,*.p7b,*.cer,*.crt,*.der)|*.pfx;*.p12;*.p7b;*.cer;*.crt;*.der', Locked = true;
        CertExtFilterTxt: Label '.pfx.p12.p7b.cer.crt.der', Locked = true;
        EncryptionManagement: Codeunit "Encryption Management";
        UploadedCertFileName: Text;

    procedure UploadAndVerifyCert(var IsolatedCertificate: Record "Isolated Certificate"): Boolean
    var
        FileName: Text;
    begin
        FileName := FileManagement.UploadFileWithFilter(SelectFileTxt, CertExtFilterTxt, CertFileFilterTxt, CertExtFilterTxt);
        if FileName = '' then
            Error('');

        TempBlob.Blob.Import(FileName);
        UploadedCertFileName := FileManagement.GetFileName(FileName);
        FileManagement.DeleteServerFile(FileName);

        exit(VerifyCert(IsolatedCertificate));
    end;

    procedure VerifyCert(var IsolatedCertificate: Record "Isolated Certificate"): Boolean
    begin
        if not TempBlob.Blob.HasValue then
            Error(CertFileNotValidErr);

        if ReadCertFromBlob(IsolatedCertificate.Password) then begin
            ValidateCertFields(IsolatedCertificate);
            exit(true);
        end;

        if StrPos(GetLastErrorText, CertFileNotValidDotNetTok) <> 0 then
            Error(CertFileNotValidErr);
        exit(false);
    end;

    procedure VerifyCertFromString(var IsolatedCertificate: Record "Isolated Certificate"; CertString: Text)
    begin
        TempBlob.Init;
        TempBlob.FromBase64String(CertString);
        VerifyCert(IsolatedCertificate);
    end;

    procedure SaveCertToIsolatedStorage(IsolatedCertificate: Record "Isolated Certificate")
    var
        CertString: Text;
    begin
        if not TempBlob.Blob.HasValue then
            Error(CertFileNotValidErr);

        CertString := TempBlob.ToBase64String;
        if not ISOLATEDSTORAGE.Set(IsolatedCertificate.Code, CertString, GetCertDataScope(IsolatedCertificate)) then
            Error(SavingCertErr);
    end;

    procedure SavePasswordToIsolatedStorage(IsolatedCertificate: Record "Isolated Certificate")
    begin
        with IsolatedCertificate do begin
            if Password <> '' then begin
                if EncryptionManagement.IsEncryptionEnabled then begin
                    if not ISOLATEDSTORAGE.SetEncrypted(Code + PasswordSuffixTxt, Password, GetCertDataScope(IsolatedCertificate)) then
                        Error(SavingPasswordErr);
                end else
                    if not ISOLATEDSTORAGE.Set(Code + PasswordSuffixTxt, Password, GetCertDataScope(IsolatedCertificate)) then
                        Error(SavingPasswordErr);
            end;

            Password := '*';
        end;
    end;

    procedure GetPasswordAsSecureString(var DotNet_SecureString: Codeunit DotNet_SecureString; IsolatedCertificate: Record "Isolated Certificate")
    var
        DotNetHelper_SecureString: Codeunit DotNetHelper_SecureString;
        StoredPassword: Text;
    begin
        StoredPassword := '';
        if ISOLATEDSTORAGE.Get(IsolatedCertificate.Code + PasswordSuffixTxt, GetCertDataScope(IsolatedCertificate), StoredPassword) then;
        DotNetHelper_SecureString.SecureStringFromString(DotNet_SecureString, StoredPassword);
    end;

    procedure GetCertAsBase64String(IsolatedCertificate: Record "Isolated Certificate"): Text
    var
        CertString: Text;
    begin
        CertString := '';
        if not ISOLATEDSTORAGE.Get(IsolatedCertificate.Code, GetCertDataScope(IsolatedCertificate), CertString) then
            Error(ReadingCertErr);
        exit(CertString);
    end;

    procedure GetCertDataScope(IsolatedCertificate: Record "Isolated Certificate"): DataScope
    begin
        case IsolatedCertificate.Scope of
            IsolatedCertificate.Scope::Company:
                exit(DATASCOPE::Company);
            IsolatedCertificate.Scope::CompanyAndUser:
                exit(DATASCOPE::CompanyAndUser);
            IsolatedCertificate.Scope::User:
                exit(DATASCOPE::User);
        end;
    end;

    procedure DeleteCertAndPasswordFromIsolatedStorage(IsolatedCertificate: Record "Isolated Certificate")
    var
        CertDataScope: DataScope;
    begin
        CertDataScope := GetCertDataScope(IsolatedCertificate);
        with IsolatedCertificate do begin
            if ISOLATEDSTORAGE.Contains(Code, CertDataScope) then
                ISOLATEDSTORAGE.Delete(Code, CertDataScope);
            if ISOLATEDSTORAGE.Contains(Code + PasswordSuffixTxt, CertDataScope) then
                ISOLATEDSTORAGE.Delete(Code + PasswordSuffixTxt, CertDataScope);
        end;
    end;

    procedure GetUploadedCertFileName(): Text
    begin
        exit(UploadedCertFileName);
    end;

    [TryFunction]
    local procedure ReadCertFromBlob(Password: Text[50])
    var
        DotNet_X509KeyStorageFlags: Codeunit DotNet_X509KeyStorageFlags;
        DotNet_Array: Codeunit DotNet_Array;
        Convert: DotNet Convert;
    begin
        DotNet_Array.SetArray(Convert.FromBase64String(TempBlob.ToBase64String));
        DotNet_X509KeyStorageFlags.Exportable;
        DotNet_X509Certificate2.X509Certificate2(DotNet_Array, Password, DotNet_X509KeyStorageFlags);
    end;

    local procedure GetIssuer(Issuer: Text): Text
    begin
        if StrPos(Issuer, 'CN=') <> 0 then
            exit(SelectStr(1, CopyStr(Issuer, StrPos(Issuer, 'CN=') + 3)));
    end;

    local procedure ValidateCertFields(var IsolatedCertificate: Record "Isolated Certificate")
    begin
        with IsolatedCertificate do begin
            Validate("Expiry Date", DotNet_X509Certificate2.Expiration);
            Validate("Has Private Key", DotNet_X509Certificate2.HasPrivateKey);
            Validate(ThumbPrint, CopyStr(DotNet_X509Certificate2.Thumbprint, 1, MaxStrLen(ThumbPrint)));
            Validate("Issued By", GetIssuer(DotNet_X509Certificate2.Issuer));
            Validate("Issued To", GetIssuer(DotNet_X509Certificate2.Subject));
        end;
    end;
}

