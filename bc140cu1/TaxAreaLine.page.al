page 465 "Tax Area Line"
{
    Caption = 'Lines';
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Tax Area Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Tax Jurisdiction Code";"Tax Jurisdiction Code")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a tax jurisdiction code.';
                }
                field("Jurisdiction Description";"Jurisdiction Description")
                {
                    ApplicationArea = Basic,Suite;
                    Editable = false;
                    ToolTip = 'Specifies the description from the tax jurisdiction table when you enter the tax jurisdiction code.';
                }
                field("Calculation Order";"Calculation Order")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies an integer to determine the sequence the program must use when tax is calculated.';
                }
            }
        }
    }

    actions
    {
    }
}

