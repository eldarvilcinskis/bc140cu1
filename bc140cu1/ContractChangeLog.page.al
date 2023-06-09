page 6063 "Contract Change Log"
{
    Caption = 'Contract Change Log';
    DataCaptionExpression = GetCaption;
    Editable = false;
    PageType = List;
    SourceTable = "Contract Change Log";
    SourceTableView = SORTING("Contract No.","Change No.")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Contract Part";"Contract Part")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the part of the contract that was changed.';
                }
                field("Type of Change";"Type of Change")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the type of change on the contract.';
                }
                field("Field Description";"Field Description")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the description of the field that was modified.';
                }
                field("New Value";"New Value")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the contents of the modified field after the change has taken place.';
                }
                field("Old Value";"Old Value")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the contents of the modified field before the change takes place.';
                }
                field("Date of Change";"Date of Change")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the date of the change.';
                }
                field("Service Item No.";"Service Item No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the number of the item on the service contract line, for which a log entry was created.';
                }
                field("Serv. Contract Line No.";"Serv. Contract Line No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the number of the service contract line for which a log entry was created.';
                }
                field("Time of Change";"Time of Change")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the time of the change.';
                }
                field("User ID";"User ID")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
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

    local procedure GetCaption(): Text[80]
    var
        ServContract: Record "Service Contract Header";
    begin
        if not ServContract.Get("Contract Type","Contract No.") then
          exit(StrSubstNo('%1',"Contract No."));

        exit(StrSubstNo('%1 %2',"Contract No.",ServContract.Description));
    end;
}

