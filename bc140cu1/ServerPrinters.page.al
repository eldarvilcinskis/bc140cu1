page 683 "Server Printers"
{
    Caption = 'Server Printers';
    Editable = false;
    LinksAllowed = false;
    PageType = StandardDialog;
    SourceTable = Printer;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field(ID;ID)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Printer Name';
                    ToolTip = 'Specifies the name of the printer.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        CODEUNIT.Run(CODEUNIT::"Init. Server Printer Table",Rec);
        if SelectedPrinterName <> '' then begin
          ID := SelectedPrinterName;
          if Find then;
        end;
    end;

    var
        SelectedPrinterName: Text[250];

    [Scope('Personalization')]
    procedure SetSelectedPrinterName(NewName: Text[250])
    begin
        SelectedPrinterName := NewName;
    end;

    [Scope('Personalization')]
    procedure GetSelectedPrinterName(): Text[250]
    begin
        exit(ID);
    end;
}

