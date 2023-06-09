table 91 "User Setup"
{
    Caption = 'User Setup';
    DrillDownPageID = "User Setup";
    LookupPageID = "User Setup";
    ReplicateData = false;

    fields
    {
        field(1;"User ID";Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("User ID");
            end;

            trigger OnValidate()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.ValidateUserID("User ID");
            end;
        }
        field(2;"Allow Posting From";Date)
        {
            Caption = 'Allow Posting From';

            trigger OnValidate()
            begin
                CheckAllowedPostingDates(0);
            end;
        }
        field(3;"Allow Posting To";Date)
        {
            Caption = 'Allow Posting To';

            trigger OnValidate()
            begin
                CheckAllowedPostingDates(0);
            end;
        }
        field(4;"Register Time";Boolean)
        {
            Caption = 'Register Time';
        }
        field(10;"Salespers./Purch. Code";Code[20])
        {
            Caption = 'Salespers./Purch. Code';
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate()
            var
                UserSetup: Record "User Setup";
            begin
                if "Salespers./Purch. Code" <> '' then begin
                  ValidateSalesPersonPurchOnUserSetup(Rec);
                  UserSetup.SetCurrentKey("Salespers./Purch. Code");
                  UserSetup.SetRange("Salespers./Purch. Code","Salespers./Purch. Code");
                  if UserSetup.FindFirst then
                    Error(Text001,"Salespers./Purch. Code",UserSetup."User ID");
                  UpdateSalesPerson;
                end;
            end;
        }
        field(11;"Approver ID";Code[50])
        {
            Caption = 'Approver ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "User Setup"."User ID";

            trigger OnLookup()
            var
                UserSetup: Record "User Setup";
            begin
                UserSetup.SetFilter("User ID",'<>%1',"User ID");
                if PAGE.RunModal(PAGE::"Approval User Setup",UserSetup) = ACTION::LookupOK then
                  Validate("Approver ID",UserSetup."User ID");
            end;

            trigger OnValidate()
            begin
                if "Approver ID" = "User ID" then
                  FieldError("Approver ID");
            end;
        }
        field(12;"Sales Amount Approval Limit";Integer)
        {
            BlankZero = true;
            Caption = 'Sales Amount Approval Limit';

            trigger OnValidate()
            begin
                if "Unlimited Sales Approval" and ("Sales Amount Approval Limit" <> 0) then
                  Error(Text003,FieldCaption("Sales Amount Approval Limit"),FieldCaption("Unlimited Sales Approval"));
                if "Sales Amount Approval Limit" < 0 then
                  Error(Text005);
            end;
        }
        field(13;"Purchase Amount Approval Limit";Integer)
        {
            BlankZero = true;
            Caption = 'Purchase Amount Approval Limit';

            trigger OnValidate()
            begin
                if "Unlimited Purchase Approval" and ("Purchase Amount Approval Limit" <> 0) then
                  Error(Text003,FieldCaption("Purchase Amount Approval Limit"),FieldCaption("Unlimited Purchase Approval"));
                if "Purchase Amount Approval Limit" < 0 then
                  Error(Text005);
            end;
        }
        field(14;"Unlimited Sales Approval";Boolean)
        {
            Caption = 'Unlimited Sales Approval';

            trigger OnValidate()
            begin
                if "Unlimited Sales Approval" then
                  "Sales Amount Approval Limit" := 0;
            end;
        }
        field(15;"Unlimited Purchase Approval";Boolean)
        {
            Caption = 'Unlimited Purchase Approval';

            trigger OnValidate()
            begin
                if "Unlimited Purchase Approval" then
                  "Purchase Amount Approval Limit" := 0;
            end;
        }
        field(16;Substitute;Code[50])
        {
            Caption = 'Substitute';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "User Setup"."User ID";

            trigger OnLookup()
            var
                UserSetup: Record "User Setup";
            begin
                UserSetup.SetFilter("User ID",'<>%1',"User ID");
                if PAGE.RunModal(PAGE::"Approval User Setup",UserSetup) = ACTION::LookupOK then
                  Validate(Substitute,UserSetup."User ID");
            end;

            trigger OnValidate()
            begin
                if Substitute = "User ID" then
                  FieldError(Substitute);
            end;
        }
        field(17;"E-Mail";Text[100])
        {
            Caption = 'E-Mail';
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                UpdateSalesPerson;
                MailManagement.ValidateEmailAddressField("E-Mail");
            end;
        }
        field(19;"Request Amount Approval Limit";Integer)
        {
            BlankZero = true;
            Caption = 'Request Amount Approval Limit';

            trigger OnValidate()
            begin
                if "Unlimited Request Approval" and ("Request Amount Approval Limit" <> 0) then
                  Error(Text003,FieldCaption("Request Amount Approval Limit"),FieldCaption("Unlimited Request Approval"));
                if "Request Amount Approval Limit" < 0 then
                  Error(Text005);
            end;
        }
        field(20;"Unlimited Request Approval";Boolean)
        {
            Caption = 'Unlimited Request Approval';

            trigger OnValidate()
            begin
                if "Unlimited Request Approval" then
                  "Request Amount Approval Limit" := 0;
            end;
        }
        field(21;"Approval Administrator";Boolean)
        {
            Caption = 'Approval Administrator';

            trigger OnValidate()
            var
                UserSetup: Record "User Setup";
            begin
                if "Approval Administrator" then begin
                  UserSetup.SetRange("Approval Administrator",true);
                  if not UserSetup.IsEmpty then
                    FieldError("Approval Administrator");
                end;
            end;
        }
        field(31;"License Type";Option)
        {
            CalcFormula = Lookup(User."License Type" WHERE ("User Name"=FIELD("User ID")));
            Caption = 'License Type';
            FieldClass = FlowField;
            OptionCaption = 'Full User,Limited User,Device Only User,Windows Group,External User';
            OptionMembers = "Full User","Limited User","Device Only User","Windows Group","External User";
        }
        field(950;"Time Sheet Admin.";Boolean)
        {
            Caption = 'Time Sheet Admin.';
        }
        field(5600;"Allow FA Posting From";Date)
        {
            Caption = 'Allow FA Posting From';
        }
        field(5601;"Allow FA Posting To";Date)
        {
            Caption = 'Allow FA Posting To';
        }
        field(5700;"Sales Resp. Ctr. Filter";Code[10])
        {
            Caption = 'Sales Resp. Ctr. Filter';
            TableRelation = "Responsibility Center".Code;
        }
        field(5701;"Purchase Resp. Ctr. Filter";Code[10])
        {
            Caption = 'Purchase Resp. Ctr. Filter';
            TableRelation = "Responsibility Center";
        }
        field(5900;"Service Resp. Ctr. Filter";Code[10])
        {
            Caption = 'Service Resp. Ctr. Filter';
            TableRelation = "Responsibility Center";
        }
    }

    keys
    {
        key(Key1;"User ID")
        {
        }
        key(Key2;"Salespers./Purch. Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NotificationSetup: Record "Notification Setup";
    begin
        NotificationSetup.SetRange("User ID","User ID");
        NotificationSetup.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        User: Record User;
    begin
        if "E-Mail" <> '' then
          exit;
        if "User ID" <> '' then
          exit;
        User.SetRange("User Name","User ID");
        if User.FindFirst then
          "E-Mail" := CopyStr(User."Contact Email",1,MaxStrLen("E-Mail"));
    end;

    var
        Text001: Label 'The %1 Salesperson/Purchaser code is already assigned to another User ID %2.';
        Text003: Label 'You cannot have both a %1 and %2. ';
        Text005: Label 'You cannot have approval limits less than zero.';
        SalesPersonPurchaser: Record "Salesperson/Purchaser";
        PrivacyBlockedGenericErr: Label 'Privacy Blocked must not be true for Salesperson / Purchaser %1.', Comment='%1 = salesperson / purchaser code.';
        UserSetupManagement: Codeunit "User Setup Management";

    [Scope('Personalization')]
    procedure CreateApprovalUserSetup(User: Record User)
    var
        UserSetup: Record "User Setup";
        ApprovalUserSetup: Record "User Setup";
    begin
        ApprovalUserSetup.Init;
        ApprovalUserSetup.Validate("User ID",User."User Name");
        ApprovalUserSetup.Validate("Sales Amount Approval Limit",GetDefaultSalesAmountApprovalLimit);
        ApprovalUserSetup.Validate("Purchase Amount Approval Limit",GetDefaultPurchaseAmountApprovalLimit);
        ApprovalUserSetup.Validate("E-Mail",User."Contact Email");
        UserSetup.SetRange("Sales Amount Approval Limit",UserSetup.GetDefaultSalesAmountApprovalLimit);
        if UserSetup.FindFirst then
          ApprovalUserSetup.Validate("Approver ID",UserSetup."Approver ID");
        if ApprovalUserSetup.Insert then;
    end;

    [Scope('Personalization')]
    procedure GetDefaultSalesAmountApprovalLimit(): Integer
    var
        UserSetup: Record "User Setup";
        DefaultApprovalLimit: Integer;
        LimitedApprovers: Integer;
    begin
        UserSetup.SetRange("Unlimited Sales Approval",false);

        if UserSetup.FindFirst then begin
          DefaultApprovalLimit := UserSetup."Sales Amount Approval Limit";
          LimitedApprovers := UserSetup.Count;
          UserSetup.SetRange("Sales Amount Approval Limit",DefaultApprovalLimit);
          if LimitedApprovers = UserSetup.Count then
            exit(DefaultApprovalLimit);
        end;

        // Return 0 if no user setup exists or no default value is found
        exit(0);
    end;

    [Scope('Personalization')]
    procedure GetDefaultPurchaseAmountApprovalLimit(): Integer
    var
        UserSetup: Record "User Setup";
        DefaultApprovalLimit: Integer;
        LimitedApprovers: Integer;
    begin
        UserSetup.SetRange("Unlimited Purchase Approval",false);

        if UserSetup.FindFirst then begin
          DefaultApprovalLimit := UserSetup."Purchase Amount Approval Limit";
          LimitedApprovers := UserSetup.Count;
          UserSetup.SetRange("Purchase Amount Approval Limit",DefaultApprovalLimit);
          if LimitedApprovers = UserSetup.Count then
            exit(DefaultApprovalLimit);
        end;

        // Return 0 if no user setup exists or no default value is found
        exit(0);
    end;

    [Scope('Personalization')]
    procedure HideExternalUsers()
    var
        PermissionManager: Codeunit "Permission Manager";
        OriginalFilterGroup: Integer;
    begin
        if not PermissionManager.SoftwareAsAService then
          exit;

        OriginalFilterGroup := FilterGroup;
        FilterGroup := 2;
        CalcFields("License Type");
        SetFilter("License Type",'<>%1',"License Type"::"External User");
        FilterGroup := OriginalFilterGroup;
    end;

    local procedure UpdateSalesPerson()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        if ("E-Mail" <> '') and SalespersonPurchaser.Get("Salespers./Purch. Code") then begin
          SalespersonPurchaser."E-Mail" := CopyStr("E-Mail",1,MaxStrLen(SalespersonPurchaser."E-Mail"));
          SalespersonPurchaser.Modify;
        end;
    end;

    local procedure ValidateSalesPersonPurchOnUserSetup(UserSetup2: Record "User Setup")
    begin
        if UserSetup2."Salespers./Purch. Code" <> '' then
          if SalesPersonPurchaser.Get(UserSetup2."Salespers./Purch. Code") then
            if SalesPersonPurchaser.VerifySalesPersonPurchaserPrivacyBlocked(SalesPersonPurchaser) then
              Error(PrivacyBlockedGenericErr,UserSetup2."Salespers./Purch. Code")
    end;

    [Scope('Personalization')]
    procedure CheckAllowedPostingDates(NotificationType: Option Error,Notification)
    begin
        UserSetupManagement.CheckAllowedPostingDatesRange(
          "Allow Posting From","Allow Posting To",NotificationType,DATABASE::"User Setup");
    end;
}

