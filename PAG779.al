page 779 "Analysis Report Chart List"
{
    Caption = 'Analysis Report Chart List';
    CardPageID = "Analysis Report Chart Setup";
    PageType = List;
    SourceTable = "Analysis Report Chart Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User ID";"User ID")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
                    Visible = false;
                }
                field(Name;Name)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of the specific chart.';
                }
                field("Analysis Area";"Analysis Area")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies if the analysis report chart shows values for sales, purchase, or inventory.';
                    Visible = false;
                }
                field("Analysis Report Name";"Analysis Report Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the analysis report that is used to generate the specific chart that is shown in, for example, the Sales Performance window.';
                    Visible = false;
                }
                field("Analysis Line Template Name";"Analysis Line Template Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the analysis line template that is used to generate the specific chart that is shown in, for example, the Sales Performance window.';
                    Visible = false;
                }
                field("Analysis Column Template Name";"Analysis Column Template Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the analysis column template that is used to generate the chart that is shown in, for example, the Sales Performance window.';
                    Visible = false;
                }
                field("Base X-Axis on";"Base X-Axis on")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies how the values from the selected analysis report are displayed in the specific chart.';
                    Visible = false;
                }
                field("Start Date";"Start Date")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the first date on which analysis report values are included in the chart.';
                }
                field("End Date";"End Date")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the last date on which analysis report values are included in the chart.';
                }
                field("Period Length";"Period Length")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the length of periods in the chart.';
                    Visible = false;
                }
                field("No. of Periods";"No. of Periods")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies how many periods are shown in the chart.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Start Date" := WorkDate;
    end;
}

