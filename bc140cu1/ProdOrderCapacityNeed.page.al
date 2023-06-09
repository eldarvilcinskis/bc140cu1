page 99000820 "Prod. Order Capacity Need"
{
    Caption = 'Prod. Order Capacity Need';
    DataCaptionFields = Status,"Prod. Order No.";
    Editable = false;
    PageType = List;
    SourceTable = "Prod. Order Capacity Need";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Prod. Order No.";"Prod. Order No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the related production order.';
                    Visible = false;
                }
                field(Type;Type)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the type of capacity need.';
                }
                field("No.";"No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Starting Time";"Starting Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the starting time of the capacity need.';
                }
                field("Starting Date-Time";"Starting Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date and the starting time, which are combined in a format called "starting date-time".';
                    Visible = false;
                }
                field("Ending Time";"Ending Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the ending time of the capacity need.';
                }
                field("Ending Date-Time";"Ending Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date and the ending time, which are combined in a format called "ending date-time".';
                    Visible = false;
                }
                field(Date;Date)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date when this capacity need occurred.';
                }
                field("Send-Ahead Type";"Send-Ahead Type")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies if the send-ahead quantity is of type Input, Output, or Both.';
                }
                field("Time Type";"Time Type")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the time type of the capacity need.';
                }
                field("Allocated Time";"Allocated Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the capacity need of planned operations.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

