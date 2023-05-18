codeunit 458 "Azure AD Licenses"
{

    trigger OnRun()
    begin
    end;

    var
        GraphClient: DotNet GraphQuery;
        SubscribedSkuEnumerator: DotNet IEnumerator;
        SubscribedSku: DotNet SkuInfo;
        ServicePlanEnumerator: DotNet IEnumerator;
        ServicePlan: DotNet ServicePlanInfo;
        DoIncludeUnknownPlans: Boolean;

    local procedure Initialize()
    begin
        if IsNull(GraphClient) then
          GraphClient := GraphClient.GraphQuery();
    end;

    [Scope('Personalization')]
    procedure Reset()
    begin
        if IsNull(GraphClient) then
          Initialize;

        if IsNull(SubscribedSkuEnumerator) then
          SubscribedSkuEnumerator := GraphClient.GetDirectorySubscribedSkus().GetEnumerator()
        else
          SubscribedSkuEnumerator.Reset;
    end;

    [Scope('Personalization')]
    procedure Next(): Boolean
    var
        MembershipEntitlement: Record "Membership Entitlement";
        TempSubscribedSku: DotNet SkuInfo;
        TempServicePlanEnumerator: DotNet IEnumerator;
        FoundKnownPlan: Boolean;
    begin
        if IsNull(GraphClient) then
          Reset;

        MembershipEntitlement.SetRange(Type,MembershipEntitlement.Type::"Azure AD Plan");

        TempSubscribedSku := SubscribedSku;
        TempServicePlanEnumerator := ServicePlanEnumerator;

        if SubscribedSkuEnumerator.MoveNext then begin
          SubscribedSku := SubscribedSkuEnumerator.Current;
          ServicePlanEnumerator := SubscribedSku.ServicePlans.GetEnumerator();

          if not DoIncludeUnknownPlans then begin
            FoundKnownPlan := false;
            while NextServicePlan do begin
              MembershipEntitlement.SetFilter(ID,LowerCase(ServicePlanId));
              if MembershipEntitlement.Count > 0 then
                FoundKnownPlan := true
              else begin
                MembershipEntitlement.SetFilter(ID,UpperCase(ServicePlanId));
                if MembershipEntitlement.Count > 0 then
                  FoundKnownPlan := true;
              end;
            end;

            if not FoundKnownPlan then begin
              SubscribedSku := TempSubscribedSku;
              ServicePlanEnumerator := TempServicePlanEnumerator;
              exit(Next);
            end;

            ServicePlanEnumerator.Reset;
          end;

          exit(true);
        end;

        exit(false)
    end;

    [Scope('Personalization')]
    procedure CapabilityStatus(): Text
    begin
        if IsNull(SubscribedSku) then
          exit('');

        exit(SubscribedSku.CapabilityStatus);
    end;

    [Scope('Personalization')]
    procedure ConsumedUnits(): Integer
    begin
        if IsNull(SubscribedSku) then
          exit(0);

        exit(SubscribedSku.ConsumedUnits);
    end;

    [Scope('Personalization')]
    procedure ObjectId(): Text
    begin
        if IsNull(SubscribedSku) then
          exit('');

        exit(SubscribedSku.ObjectId);
    end;

    [Scope('Personalization')]
    procedure PrepaidUnitsInEnabledState(): Integer
    begin
        if IsNull(SubscribedSku) then
          exit(0);

        exit(SubscribedSku.PrepaidUnits.Enabled);
    end;

    [Scope('Personalization')]
    procedure PrepaidUnitsInSuspendedState(): Integer
    begin
        if IsNull(SubscribedSku) then
          exit(0);

        exit(SubscribedSku.PrepaidUnits.Suspended);
    end;

    [Scope('Personalization')]
    procedure PrepaidUnitsInWarningState(): Integer
    begin
        if IsNull(SubscribedSku) then
          exit(0);

        exit(SubscribedSku.PrepaidUnits.Warning);
    end;

    [Scope('Personalization')]
    procedure SkuId(): Text
    begin
        if IsNull(SubscribedSku) then
          exit('');

        exit(SubscribedSku.SkuId);
    end;

    [Scope('Personalization')]
    procedure SkuPartNumber(): Text
    begin
        if IsNull(SubscribedSku) then
          exit('');

        exit(SubscribedSku.SkuPartNumber);
    end;

    [Scope('Personalization')]
    procedure ResetServicePlans()
    begin
        if not IsNull(ServicePlanEnumerator) then
          ServicePlanEnumerator.Reset;
    end;

    [Scope('Personalization')]
    procedure NextServicePlan(): Boolean
    begin
        if IsNull(ServicePlanEnumerator) then
          exit(false);

        if ServicePlanEnumerator.MoveNext() then begin
          ServicePlan := ServicePlanEnumerator.Current;
          exit(true);
        end;

        exit(false);
    end;

    [Scope('Personalization')]
    procedure ServicePlanCapabilityStatus(): Text
    begin
        if IsNull(ServicePlan) then
          exit('');

        exit(ServicePlan.CapabilityStatus);
    end;

    [Scope('Personalization')]
    procedure ServicePlanId() FoundServicePlanId: Text
    begin
        if IsNull(ServicePlan) then
          exit('');

        FoundServicePlanId := ServicePlan.ServicePlanId;
        if StrLen(FoundServicePlanId) > 2 then
          FoundServicePlanId := CopyStr(FoundServicePlanId,2,StrLen(FoundServicePlanId) - 2);
    end;

    [Scope('Personalization')]
    procedure ServicePlanName(): Text
    begin
        if IsNull(ServicePlan) then
          exit('');

        exit(ServicePlan.ServicePlanName);
    end;

    procedure IncludeUnknownPlans(): Boolean
    begin
        exit(DoIncludeUnknownPlans);
    end;

    procedure SetIncludeUnknownPlans(IncludeUnknownPlans: Boolean)
    begin
        DoIncludeUnknownPlans := IncludeUnknownPlans;
    end;
}

