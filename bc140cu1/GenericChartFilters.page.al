page 9181 "Generic Chart Filters"
{
    AutoSplitKey = true;
    Caption = 'Generic Chart Filters';
    PageType = List;
    SourceTable = "Generic Chart Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Filter Field ID";"Filter Field ID")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the ID. This field is intended only for internal use.';
                    Visible = false;
                }
                field("Filter Field Name";"Filter Field Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the filter field.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        GenericChartMgt.RetrieveFieldColumn(TempGenericChartSetup,"Filter Field ID","Filter Field Name","Filter Field Name",0,true);
                    end;

                    trigger OnValidate()
                    var
                        DummyAggregation: Option "None","Count","Sum","Min","Max",Avg;
                    begin
                        GenericChartMgt.ValidateFieldColumn(
                          TempGenericChartSetup,"Filter Field ID","Filter Field Name","Filter Field Name",0,true,DummyAggregation);
                    end;
                }
                field("Filter Value";"Filter Value")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the filter value.';
                }
            }
        }
    }

    actions
    {
    }

    var
        TempGenericChartSetup: Record "Generic Chart Setup" temporary;
        GenericChartMgt: Codeunit "Generic Chart Mgt";

    [Scope('Personalization')]
    procedure SetFilters(var TempGenericChartFilter2: Record "Generic Chart Filter" temporary)
    begin
        DeleteAll;
        if TempGenericChartFilter2.Find('-') then
          repeat
            Rec := TempGenericChartFilter2;
            Insert;
          until TempGenericChartFilter2.Next = 0;
    end;

    [Scope('Personalization')]
    procedure GetFilters(var TempGenericChartFilter2: Record "Generic Chart Filter" temporary)
    begin
        TempGenericChartFilter2.DeleteAll;
        if Find('-') then
          repeat
            TempGenericChartFilter2 := Rec;
            TempGenericChartFilter2.Insert;
          until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetTempGenericChart(GenericChartSetup2: Record "Generic Chart Setup")
    begin
        TempGenericChartSetup := GenericChartSetup2;
    end;

    [Scope('Personalization')]
    procedure GetTempGenericChart(var GenericChartSetup2: Record "Generic Chart Setup")
    begin
        GenericChartSetup2 := TempGenericChartSetup;
    end;
}

