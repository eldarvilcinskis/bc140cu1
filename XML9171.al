xmlport 9171 "Import/Export Permission Sets"
{
    Caption = 'Import/Export Permission Sets';
    Format = VariableText;

    schema
    {
        textelement(Root)
        {
            tableelement("Permission Set";"Permission Set")
            {
                XmlName = 'UserRole';
                fieldelement(RoleID;"Permission Set"."Role ID")
                {
                }
                fieldelement(Name;"Permission Set".Name)
                {
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }
}

