page 9825 "Plans FactBox"
{
    Caption = 'Plans';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = Plan;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the record.';
                }
            }
        }
    }

    actions
    {
    }
}

