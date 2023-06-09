page 568 "Dimension Selection"
{
    Caption = 'Dimension Selection';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Dimension Selection Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies the code for the dimension.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies a description of the dimension.';
                }
            }
        }
    }

    actions
    {
    }

    [Scope('Personalization')]
    procedure GetDimSelCode(): Text[30]
    begin
        exit(Code);
    end;

    [Scope('Personalization')]
    procedure InsertDimSelBuf(NewSelected: Boolean;NewCode: Text[30];NewDescription: Text[30])
    var
        Dim: Record Dimension;
        GLAcc: Record "G/L Account";
        BusinessUnit: Record "Business Unit";
    begin
        if NewDescription = '' then begin
          if Dim.Get(NewCode) then
            NewDescription := Dim.GetMLName(GlobalLanguage);
        end;

        Init;
        Selected := NewSelected;
        Code := NewCode;
        Description := NewDescription;
        case Code of
          GLAcc.TableCaption:
            "Filter Lookup Table No." := DATABASE::"G/L Account";
          BusinessUnit.TableCaption:
            "Filter Lookup Table No." := DATABASE::"Business Unit";
        end;
        Insert;
    end;
}

