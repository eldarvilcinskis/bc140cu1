codeunit 5000 "BaseApp Install"
{
    SubType = Install;

    trigger OnInstallAppPerDatabase()
    begin
        DisableBlankProfile();
    end;

    local procedure DisableBlankProfile()
    var
        AllProfile: Record "All Profile";
    begin
        AllProfile.Get(AllProfile.Scope::Tenant, '63ca2fa4-4f03-4f2b-a480-172fef340d3f', 'BLANK');
        if AllProfile.Enabled then begin
            AllProfile.Enabled := false;
            AllProfile.Modify();
        end;
    end;
}