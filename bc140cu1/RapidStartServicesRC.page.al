page 9021 "RapidStart Services RC"
{
    Caption = 'RapidStart Services Implementer', Comment='{Dependency=Match,"ProfileDescription_RAPIDSTARTSERVICES"}';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            group(Control2)
            {
                ShowCaption = false;
                part(Activities;"RapidStart Services Activities")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Activities';
                }
                part("Configuration Areas";"Config. Areas")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Configuration Areas';
                    SubPageView = SORTING("Vertical Sorting");
                }
            }
            group(Control5)
            {
                ShowCaption = false;
                systempart(Control10;MyNotes)
                {
                    ApplicationArea = Basic,Suite;
                }
                systempart(Control14;Links)
                {
                    ApplicationArea = RecordLinks;
                }
            }
        }
    }

    actions
    {
        area(embedding)
        {
            group("RapidStart Services")
            {
                Caption = 'RapidStart Services';
                action(Worksheet)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Worksheet';
                    RunObject = Page "Config. Worksheet";
                    ToolTip = 'Plan and configure how to initialize a new solution based on legacy data and the customers requirements.';
                }
                action(Packages)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Packages';
                    RunObject = Page "Config. Packages";
                    ToolTip = 'View or edit packages of data to be migrated.';
                }
                action(Tables)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Tables';
                    RunObject = Page "Config. Tables";
                    ToolTip = 'View the list of tables that hold data to be migrated. ';
                }
                action(Questionnaires)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Questionnaires';
                    RunObject = Page "Config. Questionnaire";
                    ToolTip = 'View the list of questionnaires that the customer has filled in to structure and document the solution needs and setup data.';
                }
                action(Templates)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Templates';
                    RunObject = Page "Config. Template List";
                    ToolTip = 'View or edit data templates.';
                }
            }
        }
        area(processing)
        {
            group("Actions")
            {
                Caption = 'Actions';
                action("RapidStart Services Wizard")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'RapidStart Services Wizard';
                    Image = Questionaire;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Config. Wizard";
                    ToolTip = 'Open the assisted setup guide for initializing a new solution based on legacy data and the customers requirements.';
                }
                action(ConfigurationWorksheet)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Configuration Worksheet';
                    Ellipsis = true;
                    Image = SetupLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Config. Worksheet";
                    ToolTip = 'Plan and configure how to initialize a new solution based on legacy data and the customers requirements.';
                }
                action("Complete Setup")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Complete Setup';
                    Image = Completed;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Configuration Completion";
                    ToolTip = 'Open the Rapid Start setup wizard.';
                }
            }
        }
    }
}

