codeunit 2502 "Extension License Mgmt"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure LicenseCount(ProductId: Text; SkuId: Text): Integer
    begin
        exit(GetIsvLicenseCount(ProductId, SkuId, ''));
    end;

    [Scope('Personalization')]
    procedure GetIsvLicenseCount(ProductId: Text; SkuId: Text; IsvPrefix: Text): Integer
    var
        DotNet_ExtLicInfoProvider: Codeunit DotNet_ExtLicInfoProvider;
    begin
        if (ProductId = '') or (SkuId = '') then
            exit(-1);

        exit(DotNet_ExtLicInfoProvider.ALLicenseCount(ProductId, SkuId, IsvPrefix));
    end;
}

