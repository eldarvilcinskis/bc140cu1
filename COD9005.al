codeunit 9005 "Environment Mgt."
{

    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure IsPPE(): Boolean
    var
        Url: Text;
    begin
        Url := LowerCase(GetUrl(CLIENTTYPE::Web));
        exit(
          (StrPos(Url,'projectmadeira-test') <> 0) or (StrPos(Url,'projectmadeira-ppe') <> 0) or
          (StrPos(Url,'financials.dynamics-tie.com') <> 0) or (StrPos(Url,'financials.dynamics-ppe.com') <> 0) or
          (StrPos(Url,'invoicing.officeppe.com') <> 0) or (StrPos(Url,'businesscentral.dynamics-tie.com') <> 0) or
          (StrPos(Url,'businesscentral.dynamics-ppe.com') <> 0));
    end;

    [Scope('Personalization')]
    procedure IsPROD(): Boolean
    var
        Url: Text;
    begin
        Url := LowerCase(GetUrl(CLIENTTYPE::Web));
        exit(
          (StrPos(Url,'financials.dynamics.com') <> 0) or (StrPos(Url,'invoicing.office.net') <> 0) or
          (StrPos(Url,'businesscentral.dynamics.com') <> 0));
    end;

    [Scope('Personalization')]
    procedure IsTIE(): Boolean
    var
        Url: Text;
    begin
        Url := LowerCase(GetUrl(CLIENTTYPE::Web));
        exit(
          (StrPos(Url,'financials.dynamics-servicestie.com') <> 0) or (StrPos(Url,'invoicing.office-int.com') <> 0) or
          (StrPos(Url,'businesscentral.dynamics-servicestie.com') <> 0));
    end;

    [Scope('Personalization')]
    procedure IsPartnerPPE(): Boolean
    var
        Url: Text;
    begin
        Url := LowerCase(GetUrl(CLIENTTYPE::Web));
        exit(StrPos(Url,'bc.dynamics-tie.com') <> 0);
    end;

    [Scope('Personalization')]
    procedure IsPartnerPROD(): Boolean
    var
        Url: Text;
    begin
        Url := LowerCase(GetUrl(CLIENTTYPE::Web));
        exit(StrPos(Url,'bc.dynamics.com') <> 0);
    end;

    [Scope('Personalization')]
    procedure IsPartnerTIE(): Boolean
    var
        Url: Text;
    begin
        Url := LowerCase(GetUrl(CLIENTTYPE::Web));
        exit(StrPos(Url,'bc.dynamics-servicestie.com') <> 0);
    end;
}

