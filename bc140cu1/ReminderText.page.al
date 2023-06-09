page 433 "Reminder Text"
{
    AutoSplitKey = true;
    Caption = 'Reminder Text';
    DataCaptionExpression = PageCaption;
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = List;
    SaveValues = true;
    SourceTable = "Reminder Text";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Reminder Terms Code";"Reminder Terms Code")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the reminder terms code this text applies to.';
                    Visible = false;
                }
                field("Reminder Level";"Reminder Level")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the reminder level this text applies to.';
                    Visible = false;
                }
                field(Position;Position)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies whether the text will appear at the beginning or the end of the reminder.';
                    Visible = false;
                }
                field(Text;Text)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the text that you want to insert in the reminder.';
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

    trigger OnOpenPage()
    begin
        PageCaption := "Reminder Terms Code" + ' ' + Format("Reminder Level") + ' ' + Format(Position);
    end;

    var
        PageCaption: Text[250];
}

