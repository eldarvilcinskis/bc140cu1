page 1750 "Field Data Classification"
{
    Caption = 'Field Data Classification';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Field";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(TableNo; TableNo)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number.';
                }
                field(TableName; TableName)
                {
                    ApplicationArea = All;
                }
                field(FieldName; FieldName)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field(Class; Class)
                {
                    ApplicationArea = All;
                }
                field("Type Name"; "Type Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of data.';
                }
                field(RelationTableNo; RelationTableNo)
                {
                    ApplicationArea = All;
                }
                field(OptionString; OptionString)
                {
                    ApplicationArea = All;
                }
                field(DataClassification; DataClassification)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

