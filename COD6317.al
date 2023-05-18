codeunit 6317 "Power BI Session Manager"
{
    // // This is singleton class to maintain information about Power BI for a user session.

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        PowerBIUserLicense: Record "Power BI User License";
        HasPowerBILicense: Boolean;

    procedure SetHasPowerBILicense(Value: Boolean)
    begin
        HasPowerBILicense := Value;

        if PowerBIUserLicense.Get(UserSecurityId) then begin
          PowerBIUserLicense."Has Power BI License" := Value;
          PowerBIUserLicense.Modify;
          exit;
        end;

        PowerBIUserLicense.Init;
        PowerBIUserLicense."Has Power BI License" := Value;
        PowerBIUserLicense."User Security ID" := UserSecurityId;
        PowerBIUserLicense.Insert;
    end;

    procedure GetHasPowerBILicense(): Boolean
    begin
        if HasPowerBILicense then
          exit(true);

        if PowerBIUserLicense.Get(UserSecurityId) then
          HasPowerBILicense := PowerBIUserLicense."Has Power BI License";

        exit(HasPowerBILicense);
    end;
}

