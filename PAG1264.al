page 1264 "Change User"
{
    Caption = 'Change User';
    SourceTable = "Isolated Certificate";

    layout
    {
        area(content)
        {
            field("User ID";"User ID")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'User assigned to the certificate';

                trigger OnLookup(var Text: Text): Boolean
                var
                    UserManagement: Codeunit "User Management";
                begin
                    UserManagement.LookupUserID("User ID");
                end;

                trigger OnValidate()
                begin
                    TestField("User ID");
                end;
            }
        }
    }

    actions
    {
    }
}

