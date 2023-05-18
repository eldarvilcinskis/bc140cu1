page 358 Objects
{
    Caption = 'Objects';
    Editable = false;
    PageType = List;
    SourceTable = AllObjWithCaption;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Object Type";"Object Type")
                {
                    ApplicationArea = All;
                    Caption = 'Type';
                    ToolTip = 'Specifies the object type.';
                    Visible = false;
                }
                field("Object ID";"Object ID")
                {
                    ApplicationArea = All;
                    Caption = 'ID';
                    ToolTip = 'Specifies the object ID.';
                }
                field("Object Caption";"Object Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    DrillDown = false;
                    ToolTip = 'Specifies the name of the object.';
                }
                field("Object Name";"Object Name")
                {
                    ApplicationArea = All;
                    Caption = 'Object Name';
                    ToolTip = 'Specifies the name of the object.';
                    Visible = false;
                }
                field(ExtensionName;ExtensionName)
                {
                    ApplicationArea = All;
                    Caption = 'Extension Name';
                    ToolTip = 'Specifies the name of the extension.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        NAVApp: Record "NAV App";
    begin
        ExtensionName := '';
        if IsNullGuid("App Package ID") then
          exit;
        if NAVApp.Get("App Package ID") then
          ExtensionName := NAVApp.Name;
    end;

    var
        ExtensionName: Text;
}

