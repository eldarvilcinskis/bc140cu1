page 480 "Edit Dimension Set Entries"
{
    Caption = 'Edit Dimension Set Entries';
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Dimension Set Entry";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Dimension Code";"Dimension Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = "Dimension Value Code" = '';
                    ToolTip = 'Specifies the dimension.';
                }
                field("Dimension Name";"Dimension Name")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the descriptive name of the Dimension Code field.';
                    Visible = false;
                }
                field(DimensionValueCode;"Dimension Value Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the dimension value.';
                }
                field("Dimension Value Name";"Dimension Value Name")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the descriptive name of the Dimension Value Code field.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnClosePage()
    begin
        DimSetID := DimMgt.GetDimensionSetID(Rec);
    end;

    trigger OnOpenPage()
    begin
        DimSetID := GetRangeMin("Dimension Set ID");
        DimMgt.GetDimensionSet(Rec,DimSetID);
        if FormCaption <> '' then
          CurrPage.Caption := FormCaption;
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        DimSetID: Integer;
        FormCaption: Text[250];

    [Scope('Personalization')]
    procedure GetDimensionID(): Integer
    begin
        exit(DimSetID);
    end;

    [Scope('Personalization')]
    procedure SetFormCaption(NewFormCaption: Text[250])
    begin
        FormCaption := CopyStr(NewFormCaption + ' - ' + CurrPage.Caption,1,MaxStrLen(FormCaption));
    end;
}

