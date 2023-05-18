page 9165 "Support Contact Info Card"
{
    Caption = 'Support Contact Info Card';
    DataCaptionExpression = '';
    PageType = StandardDialog;
    Permissions = TableData "Support Contact Information"=rimd;

    layout
    {
        area(content)
        {
            group(Control2)
            {
                InstructionalText = 'This email address is shown in the Help & Support page so that users know how to contact the people who are responsible for technical support.';
                ShowCaption = false;
            }
            field(EmailInputControl;SupportContactEmail)
            {
                ApplicationArea = All;
                Caption = 'Support email address';
                Editable = SupportContactEmailEditable;

                trigger OnValidate()
                begin
                    MailManagement.ValidateEmailAddressField(SupportContactEmail);
                end;
            }
            field(PopulateFromAuthControl;PopulateFromAuthText)
            {
                ApplicationArea = All;
                Editable = false;
                ShowCaption = false;
                Visible = PopulateFromAuthVisible;

                trigger OnDrillDown()
                var
                    User: Record User;
                begin
                    if User.ReadPermission and User.Get(UserSecurityId) then begin
                      SupportContactEmail := User."Authentication Email";
                      MailManagement.ValidateEmailAddressField(SupportContactEmail);
                    end;
                end;
            }
            field(PopulateFromContactControl;PopulateFromContactText)
            {
                ApplicationArea = All;
                Editable = false;
                ShowCaption = false;
                Visible = PopulateFromContactVisible;

                trigger OnDrillDown()
                var
                    User: Record User;
                begin
                    if User.ReadPermission and User.Get(UserSecurityId) then begin
                      SupportContactEmail := User."Contact Email";
                      MailManagement.ValidateEmailAddressField(SupportContactEmail);
                    end;
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }

    trigger OnInit()
    begin
        PopulateFields;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [ACTION::LookupOK,ACTION::OK] then
          SaveContactEmailAddress(SupportContactEmail);
    end;

    var
        SupportContactInformation: Record "Support Contact Information";
        MailManagement: Codeunit "Mail Management";
        SupportContactEmail: Text[250];
        PopulateEmailFromAuthLbl: Label 'Use my authentication email (%1)', Comment='%1 = the email that the user used to log in';
        PopulateEmailFromContactLbl: Label 'Use my contact email (%1)', Comment='%1 = the email that the user specified as contact email';
        SupportContactEmailEditable: Boolean;
        PopulateFromAuthVisible: Boolean;
        PopulateFromAuthText: Text;
        PopulateFromContactVisible: Boolean;
        PopulateFromContactText: Text;

    local procedure PopulateFields()
    var
        User: Record User;
    begin
        if SupportContactInformation.Get then
          SupportContactEmail := SupportContactInformation.Email
        else begin
          SupportContactInformation.Init;
          SupportContactInformation.Insert(true);
        end;

        SupportContactEmailEditable := SupportContactInformation.WritePermission;

        PopulateFromAuthVisible := false;
        PopulateFromContactVisible := false;

        if SupportContactEmailEditable then // Do not show the field if the user will not have permissions anyway
          if User.ReadPermission then
            if User.Get(UserSecurityId) then begin
              if User."Authentication Email" <> '' then begin
                PopulateFromAuthVisible := true;
                PopulateFromAuthText := StrSubstNo(PopulateEmailFromAuthLbl,User."Authentication Email");
              end;

              if User."Contact Email" <> '' then begin
                PopulateFromContactVisible := true;
                PopulateFromContactText := StrSubstNo(PopulateEmailFromContactLbl,User."Contact Email");
              end;
            end;
    end;

    local procedure SaveContactEmailAddress(EmailAddress: Text[250])
    begin
        SupportContactInformation.Validate(Email,EmailAddress);
        SupportContactInformation.Modify(true);
    end;
}

