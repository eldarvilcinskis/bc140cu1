page 9839 "Printer Selections FactBox"
{
    Caption = 'Printer Selections';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Printer Selection";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("User ID";"User ID")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the ID of the user for whom you want to define permissions.';
                    Visible = false;
                }
                field("Report ID";"Report ID")
                {
                    ApplicationArea = Basic,Suite;
                    LookupPageID = Objects;
                    ToolTip = 'Specifies the object ID of the report.';
                }
                field("Report Caption";"Report Caption")
                {
                    ApplicationArea = Basic,Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies the display name of the report.';
                }
                field("Printer Name";"Printer Name")
                {
                    ApplicationArea = Basic,Suite;
                    LookupPageID = Printers;
                    ToolTip = 'Specifies the printer that the user will be allowed to use or on which the report will be printed.';
                }
            }
        }
    }

    actions
    {
    }
}

