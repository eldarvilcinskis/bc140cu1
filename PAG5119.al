page 5119 "Sales Cycles"
{
    ApplicationArea = RelationshipMgmt;
    Caption = 'Sales Cycles';
    PageType = List;
    SourceTable = "Sales Cycle";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the sales cycle.';
                }
                field(Description;Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the sales cycle.';
                }
                field("Probability Calculation";"Probability Calculation")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the method to use to calculate the probability of opportunities completing the sales cycle. There are four options:';
                }
                field(Blocked;Blocked)
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies that the related record is blocked from being posted in transactions, for example a customer that is declared insolvent or an item that is placed in quarantine.';
                }
                field(Comment;Comment)
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies that you have assigned comments to the sales cycle.';
                }
            }
        }
        area(factboxes)
        {
            part(Control5;"Sales Cycle Statistics FactBox")
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Statistics';
                SubPageLink = Code=FIELD(Code);
            }
            systempart(Control1900383207;Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Sales &Cycle")
            {
                Caption = 'Sales &Cycle';
                Image = Stages;
                action(Statistics)
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Sales Cycle Statistics";
                    RunPageLink = Code=FIELD(Code);
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';
                }
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Rlshp. Mgt. Comment Sheet";
                    RunPageLink = "Table Name"=CONST("Sales Cycle"),
                                  "No."=FIELD(Code),
                                  "Sub No."=CONST(0);
                    ToolTip = 'View or add comments for the record.';
                }
                action("S&tages")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'S&tages';
                    Image = Stages;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Sales Cycle Stages";
                    RunPageLink = "Sales Cycle Code"=FIELD(Code);
                    ToolTip = 'View a list of the different stages within the sales cycle.';
                }
            }
        }
    }
}

