codeunit 3016 DotNet_NavAppALInstaller
{

    trigger OnRun()
    begin
    end;

    var
        DotNetNavAppALInstaller: DotNet NavAppALInstaller;

    [Scope('Internal')]
    procedure NavAppALInstaller()
    begin
        // do not make external
        DotNetNavAppALInstaller := DotNetNavAppALInstaller.NavAppALInstaller
    end;

    [Scope('Internal')]
    procedure ALInstallNavApp(PackageID: Guid;Lcid: Integer)
    begin
        // do not make external
        DotNetNavAppALInstaller.ALInstallNavApp(PackageID,Lcid)
    end;

    [Scope('Internal')]
    procedure ALGetAppDependenciesToInstallString(PackageID: Text): Text
    begin
        // do not make external
        exit(DotNetNavAppALInstaller.ALGetAppDependenciesToInstallString(PackageID))
    end;

    [Scope('Internal')]
    procedure ALGetDependentAppsToUninstallString(PackageID: Guid): Text
    begin
        // do not make external
        exit(DotNetNavAppALInstaller.ALGetDependentAppsToUninstallString(PackageID))
    end;

    [Scope('Internal')]
    procedure ALUninstallNavApp(PackageID: Guid)
    begin
        // do not make external
        DotNetNavAppALInstaller.ALUninstallNavApp(PackageID)
    end;

    [Scope('Internal')]
    procedure ALUnpublishNavTenantApp(PackageID: Guid)
    begin
        // do not make external
        DotNetNavAppALInstaller.ALUnpublishNavTenantApp(PackageID)
    end;

    [Scope('Internal')]
    procedure GetNavAppALInstaller(var DotNetNavAppALInstaller2: DotNet NavAppALInstaller)
    begin
        DotNetNavAppALInstaller2 := DotNetNavAppALInstaller;
    end;

    [Scope('Internal')]
    procedure SetNavAppALInstaller(DotNetNavAppALInstaller2: DotNet NavAppALInstaller)
    begin
        DotNetNavAppALInstaller := DotNetNavAppALInstaller2
    end;
}

