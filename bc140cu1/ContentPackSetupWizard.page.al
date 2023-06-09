page 6316 "Content Pack Setup Wizard"
{
    // // Wizard page to walk the user through connecting PBI content packs to their NAV data.
    // // This page is the wizard frame and text, all actual fields are in the page part, 6317.

    Caption = 'Connector Setup Information';
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
            field("Connectors enable Business Central to communicate with Power BI, PowerApps, and Microsoft Flow.";'')
            {
                ApplicationArea = All;
                Caption = 'Connectors enable Business Central to communicate with Power BI, PowerApps, and Microsoft Flow.';
            }
            field(Control6;'')
            {
                ApplicationArea = All;
                Caption = 'This page provides the required information you will need to connect to these applications. Simply copy and paste this information into the Power BI, PowerApp, or Microsoft Flow connector when prompted.';
            }
            field(Control7;'')
            {
                ApplicationArea = All;
                Caption = 'Depending on your configuration, you will either connect using the password for the user name displayed below, or with the web service access key displayed below.';
            }
            part(ContentPackSetup;"Content Pack Setup Part")
            {
                ApplicationArea = All;
                Caption = ' ', Locked=true;
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }
}

