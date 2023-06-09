page 534 "Application Languages"
{
    Caption = 'Application Languages';
    Editable = false;
    PageType = List;
    SourceTable = "Windows Language";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the language.';
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

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [ACTION::OK,ACTION::LookupOK] then
          OKOnPush;
    end;

    local procedure OKOnPush()
    begin
        GlobalLanguage := "Language ID";
    end;
}

