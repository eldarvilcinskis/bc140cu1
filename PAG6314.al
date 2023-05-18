page 6314 "PBI Sales Pipeline"
{
    Caption = 'PBI Sales Pipeline';
    Editable = false;
    PageType = List;
    SourceTable = "Power BI Chart Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ID;ID)
                {
                    ApplicationArea = All;
                    Caption = 'ID';
                    ToolTip = 'Specifies the ID.';
                }
                field("Row No.";"Row No.")
                {
                    ApplicationArea = All;
                    Caption = 'Stage';
                    ToolTip = 'Specifies the stage of the sales pipeline that this entry is at.';
                }
                field(Value;Value)
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                    ToolTip = 'Specifies the value.';
                }
                field("Measure Name";"Measure Name")
                {
                    ApplicationArea = All;
                    Caption = 'Measure Name';
                    ToolTip = 'Specifies the name.';
                }
                field("Measure No.";"Measure No.")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Cycle Code';
                    ToolTip = 'Specifies a code for the sales process.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        PBISalesPipelineChartCalc: Codeunit "PBI Sales Pipeline Chart Calc.";
    begin
        PBISalesPipelineChartCalc.GetValues(Rec);
    end;
}

