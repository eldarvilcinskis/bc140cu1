page 964 "Period Summary Archive FactBox"
{
    Caption = 'Period Summary';
    PageType = CardPart;

    layout
    {
        area(content)
        {
            field("DateQuantity[1]";DateQuantity[1])
            {
                ApplicationArea = Jobs;
                CaptionClass = '3,' + DateDescription[1];
                Editable = false;
                ShowCaption = false;
            }
            field("DateQuantity[2]";DateQuantity[2])
            {
                ApplicationArea = Jobs;
                CaptionClass = '3,' + DateDescription[2];
                Editable = false;
                ShowCaption = false;
            }
            field("DateQuantity[3]";DateQuantity[3])
            {
                ApplicationArea = Jobs;
                CaptionClass = '3,' + DateDescription[3];
                Editable = false;
                ShowCaption = false;
            }
            field("DateQuantity[4]";DateQuantity[4])
            {
                ApplicationArea = Jobs;
                CaptionClass = '3,' + DateDescription[4];
                Editable = false;
                ShowCaption = false;
            }
            field("DateQuantity[5]";DateQuantity[5])
            {
                ApplicationArea = Jobs;
                CaptionClass = '3,' + DateDescription[5];
                Editable = false;
                ShowCaption = false;
            }
            field("DateQuantity[6]";DateQuantity[6])
            {
                ApplicationArea = Jobs;
                CaptionClass = '3,' + DateDescription[6];
                Editable = false;
                ShowCaption = false;
            }
            field("DateQuantity[7]";DateQuantity[7])
            {
                ApplicationArea = Jobs;
                CaptionClass = '3,' + DateDescription[7];
                Editable = false;
                ShowCaption = false;
            }
            field(TotalQuantity;TotalQuantity)
            {
                ApplicationArea = Jobs;
                Caption = 'Total';
                Editable = false;
                Style = Strong;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the total.';
            }
            field(PresenceQty;PresenceQty)
            {
                ApplicationArea = Jobs;
                Caption = 'Total Presence';
                ToolTip = 'Specifies the total presence (calculated in days or hours) for all resources on the line.';
            }
            field(AbsenceQty;AbsenceQty)
            {
                ApplicationArea = Jobs;
                Caption = 'Total Absence';
                ToolTip = 'Specifies the total absence (calculated in days or hours) for all resources on the line.';
            }
        }
    }

    actions
    {
    }

    var
        TimeSheetMgt: Codeunit "Time Sheet Management";
        DateDescription: array [7] of Text[30];
        DateQuantity: array [7] of Decimal;
        TotalQuantity: Decimal;
        PresenceQty: Decimal;
        AbsenceQty: Decimal;

    [Scope('Personalization')]
    procedure UpdateData(TimeSheetHeaderArchive: Record "Time Sheet Header Archive")
    begin
        TimeSheetMgt.CalcSummaryArcFactBoxData(TimeSheetHeaderArchive,DateDescription,DateQuantity,TotalQuantity,AbsenceQty);
        PresenceQty := TotalQuantity - AbsenceQty;
        CurrPage.Update(false);
    end;
}

