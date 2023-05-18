page 9831 "User Group Members"
{
    Caption = 'User Group Members';
    DataCaptionFields = "User Group Code","User Group Name";
    DelayedInsert = true;
    InsertAllowed = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "User Group Member";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(SelectedCompany;SelectedCompany)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Company Name';
                    TableRelation = Company;
                    ToolTip = 'Specifies the company that you want to see users for.';

                    trigger OnValidate()
                    begin
                        UpdateCompany;
                    end;
                }
            }
            repeater(Group)
            {
                field(UserName;UserName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'User Name';
                    Lookup = true;
                    LookupPageID = Users;
                    ShowMandatory = true;
                    TableRelation = User;
                    ToolTip = 'Specifies the name of the user.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        User: Record User;
                        UserLookup: Page "User Lookup";
                    begin
                        if Text <> '' then begin
                          User.SetRange("User Name",Text);
                          if User.FindFirst then;
                          UserLookup.SetRecord(User);
                        end;
                        UserLookup.LookupMode := true;
                        if UserLookup.RunModal = ACTION::LookupOK then begin
                          UserLookup.GetRecord(User);
                          if User."User Security ID" = "User Security ID" then
                            exit;
                          if Get("User Group Code","User Security ID",SelectedCompany) then
                            Delete(true);
                          Init;
                          Validate("User Security ID",User."User Security ID");
                          Validate("Company Name",SelectedCompany);
                          CalcFields("User Name");
                          Insert(true);
                          CurrPage.Update(false);
                        end;
                    end;

                    trigger OnValidate()
                    var
                        User: Record User;
                    begin
                        if UserName = '' then
                          exit;
                        User.SetRange("User Name",UserName);
                        User.FindFirst;
                        Init;
                        Validate("User Security ID",User."User Security ID");
                        Validate("Company Name",SelectedCompany);
                        CalcFields("User Name");
                        Insert(true);
                        CurrPage.Update(false);
                    end;
                }
                field("User Full Name";"User Full Name")
                {
                    ApplicationArea = All;
                    Caption = 'Full Name';
                    ToolTip = 'Specifies the full name of the user.';
                }
                field("User Group Code";"User Group Code")
                {
                    ApplicationArea = Basic,Suite;
                    ShowMandatory = true;
                    TableRelation = "User Group".Code;
                    ToolTip = 'Specifies a user group.';
                }
                field("Company Name";"Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the company.';
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(AddUsers)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Add Users';
                Image = Users;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'See a list of existing users and add users to the user group.';

                trigger OnAction()
                begin
                    AddUsers(Company.Name);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields("User Name");
        UserName := "User Name";
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        exit(not IsNullGuid("User Security ID"));
    end;

    trigger OnModifyRecord(): Boolean
    begin
        TestField("User Name");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        UserName := '';
    end;

    trigger OnOpenPage()
    begin
        SelectedCompany := CompanyName;
        UpdateCompany;
    end;

    var
        Company: Record Company;
        SelectedCompany: Text[30];
        UserName: Code[50];

    local procedure UpdateCompany()
    begin
        Company.Name := SelectedCompany;
        if SelectedCompany <> '' then begin
          Company.Find('=<>');
          SelectedCompany := Company.Name;
        end;
        SetRange("Company Name",Company.Name);
        CurrPage.Update(false);
    end;
}

