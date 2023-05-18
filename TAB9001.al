table 9001 "User Group Member"
{
    Caption = 'User Group Member';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"User Group Code";Code[20])
        {
            Caption = 'User Group Code';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = "User Group";
        }
        field(2;"User Security ID";Guid)
        {
            Caption = 'User Security ID';
            DataClassification = EndUserPseudonymousIdentifiers;
            NotBlank = true;
            TableRelation = User;
        }
        field(3;"Company Name";Text[30])
        {
            Caption = 'Company Name';
            TableRelation = Company;
        }
        field(4;"User Name";Code[50])
        {
            CalcFormula = Lookup(User."User Name" WHERE ("User Security ID"=FIELD("User Security ID")));
            Caption = 'User Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5;"User Full Name";Text[80])
        {
            CalcFormula = Lookup(User."Full Name" WHERE ("User Security ID"=FIELD("User Security ID")));
            Caption = 'User Full Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6;"User Group Name";Text[50])
        {
            CalcFormula = Lookup("User Group".Name WHERE (Code=FIELD("User Group Code")));
            Caption = 'User Group Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"User Group Code","User Security ID","Company Name")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        UserGroupAccessControl: Record "User Group Access Control";
        PermissionManager: Codeunit "Permission Manager";
    begin
        UserGroupAccessControl.RemoveUserGroupMember("User Group Code","User Security ID","Company Name");

        // In SaaS the default profile comes from the plan and not from the user group
        if not PermissionManager.SoftwareAsAService then
          UpdateDefaultProfileOfUser("User Group Code");
    end;

    trigger OnInsert()
    var
        UserGroupAccessControl: Record "User Group Access Control";
    begin
        UserGroupAccessControl.AddUserGroupMember("User Group Code","User Security ID","Company Name");
        CopyDefaultProfileFromUserGroupToUser("User Group Code",false);
    end;

    trigger OnModify()
    begin
        if ("User Group Code" <> xRec."User Group Code") or
           ("User Security ID" <> xRec."User Security ID") or
           ("Company Name" <> xRec."Company Name")
        then
          ModifyUserGroupMembership;
    end;

    trigger OnRename()
    begin
        ModifyUserGroupMembership;
    end;

    var
        ConfirmPersonalizationChangeQst: Label 'Do you want to change the user''s current personalization profile to the default profile used by user group %1?', Comment='%1 = User Group Code';
        ConfirmPersonalizationChangeDefaultQst: Label 'Do you want to change the user''s current personalization profile to the default value?';
        UserProfileChangeMsg: Label 'The user''s personalization profile was changed to %1.', Comment='%1 = Profile ID';
        UserProfileChangeFailedMsg: Label 'User group %1 has no default profile defined.', Comment='%1 = User Group Code';

    [Scope('Personalization')]
    procedure AddUsers(SelectedCompany: Text[30])
    var
        User: Record User;
        UserLookup: Page "User Lookup";
    begin
        if GetFilter("User Group Code") = '' then
          exit;

        UserLookup.LookupMode := true;
        if UserLookup.RunModal = ACTION::LookupOK then begin
          UserLookup.GetSelectionFilter(User);
          if User.FindSet then
            repeat
              "User Group Code" := GetRangeMin("User Group Code");
              "User Security ID" := User."User Security ID";
              "Company Name" := SelectedCompany;
              if Insert(true) then;
            until User.Next = 0;
        end;
    end;

    local procedure ModifyUserGroupMembership()
    var
        UserGroupAccessControl: Record "User Group Access Control";
        UserGroupMember: Record "User Group Member";
        DefaultProfile: Record "All Profile";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
        NewProfileID: Code[30];
    begin
        if IsNullGuid("User Security ID") or ("User Group Code" = '') then
          exit;
        UserGroupAccessControl.RemoveUserGroupMember(xRec."User Group Code",xRec."User Security ID",xRec."Company Name");
        UserGroupAccessControl.AddUserGroupMember("User Group Code","User Security ID","Company Name");
        if (xRec."User Group Code" = "User Group Code") and (xRec."User Security ID" = "User Security ID") then
          exit;
        // If there is more than one User group assigned to a user, then use the company default profile
        UserGroupMember.SetRange("User Security ID","User Security ID");
        UserGroupMember.SetFilter("User Group Code",'<>%1',xRec."User Group Code");
        if not UserGroupMember.IsEmpty then begin
          // When there are more than two user groups assigned to this user, assign to him the default profile
          if not UserGroupIsAssociatedWithProfile(xRec."User Group Code",xRec."User Security ID") then
            exit;
          if UserHasOtherUserGroupsSupportingProfile(UserGroupMember,xRec."User Security ID") then
            exit;
          if not Confirm(ConfirmPersonalizationChangeDefaultQst) then
            exit;
          ConfPersonalizationMgt.GetDefaultProfile(DefaultProfile);
          CopyDefaultProfileToUser(DefaultProfile,true);
          Message(UserProfileChangeMsg,DefaultProfile."Profile ID");
          exit;
        end;

        // Else ask confirmation whether to change personalization
        if Confirm(StrSubstNo(ConfirmPersonalizationChangeQst,"User Group Code")) then begin
          UpdateDefaultProfileOfUser(xRec."User Group Code");
          NewProfileID := CopyDefaultProfileFromUserGroupToUser("User Group Code",true);
          if NewProfileID <> '' then
            Message(UserProfileChangeMsg,NewProfileID)
          else
            Message(UserProfileChangeFailedMsg,"User Group Code");
        end;
    end;

    local procedure UpdateDefaultProfileOfUser(UserGroupCode: Code[20])
    var
        UserGroupMember: Record "User Group Member";
        UserPersonalization: Record "User Personalization";
    begin
        UserGroupMember.SetRange("User Security ID","User Security ID");
        UserGroupMember.SetFilter("User Group Code",'<>%1',UserGroupCode);
        if not UserGroupMember.FindFirst then begin
          if not UserPersonalization.Get("User Security ID") then
            exit;
          UserPersonalization."Profile ID" := '';
          UserPersonalization.Modify(true);
        end else
          CopyDefaultProfileFromUserGroupToUser(UserGroupMember."User Group Code",true);
    end;

    local procedure CopyDefaultProfileFromUserGroupToUser(UserGroupCode: Code[20];Force: Boolean): Code[30]
    var
        UserGroup: Record "User Group";
        DefaultProfile: Record "All Profile";
    begin
        // Updates the user's personalization, if empty, with the current default profile
        if UserGroup.Get(UserGroupCode) then
          if DefaultProfile.Get(UserGroup."Default Profile Scope",UserGroup."Default Profile App ID",UserGroup."Default Profile ID") then
            exit(CopyDefaultProfileToUser(DefaultProfile,Force));
    end;

    local procedure CopyDefaultProfileToUser(DefaultProfile: Record "All Profile";Force: Boolean): Code[30]
    var
        UserPersonalization: Record "User Personalization";
    begin
        if DefaultProfile."Profile ID" = '' then
          exit('');
        // Force = TRUE overwrites the current default profile
        if not UserPersonalization.Get("User Security ID") then begin
          UserPersonalization.Init;
          UserPersonalization."User SID" := "User Security ID";
          UserPersonalization."Profile ID" := DefaultProfile."Profile ID";
          UserPersonalization."App ID" := DefaultProfile."App ID";
          UserPersonalization.Scope := DefaultProfile.Scope;
          UserPersonalization.Insert(true);
          exit(DefaultProfile."Profile ID");
        end;
        if (UserPersonalization."Profile ID" = '') or Force then begin
          UserPersonalization."Profile ID" := DefaultProfile."Profile ID";
          UserPersonalization."App ID" := DefaultProfile."App ID";
          UserPersonalization.Scope := DefaultProfile.Scope;
          UserPersonalization.Modify(true);
          exit(DefaultProfile."Profile ID");
        end;
        exit('');
    end;

    local procedure UserGroupIsAssociatedWithProfile(UserGroupCode: Code[20];UserSecurityID: Guid): Boolean
    var
        UserPersonalization: Record "User Personalization";
        UserGroup: Record "User Group";
    begin
        if UserPersonalization.Get(UserSecurityID) then begin
          if UserGroup.Get(UserGroupCode) then
            exit(UserPersonalization."Profile ID" = UserGroup."Default Profile ID");
        end;
        exit(false);
    end;

    local procedure UserHasOtherUserGroupsSupportingProfile(var UserGroupMember: Record "User Group Member";UserSecurityID: Guid): Boolean
    var
        UserPersonalization: Record "User Personalization";
        UserGroup: Record "User Group";
    begin
        if UserPersonalization.Get(UserSecurityID) then begin
          UserGroupMember.FindSet;
          repeat
            if UserGroup.Get(UserGroupMember."User Group Code") and
               (UserGroup."Default Profile ID" = UserPersonalization."Profile ID")
            then
              exit(true);
          until UserGroupMember.Next = 0
        end;
        exit(false);
    end;
}

