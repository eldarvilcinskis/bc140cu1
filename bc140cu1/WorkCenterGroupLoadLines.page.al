page 99000892 "Work Center Group Load Lines"
{
    Caption = 'Lines';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = ListPart;
    SaveValues = true;
    SourceTable = Date;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Period Start";"Period Start")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Period Start';
                    ToolTip = 'Specifies the starting date of the period that you want to view, for an overview of availability at the current work center group.';
                }
                field("Period Name";"Period Name")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Period Name';
                    ToolTip = 'Specifies the name of the period shown in the line.';
                }
                field(Capacity;WorkCenterGroup."Capacity (Effective)")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Capacity';
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies the amount of work that can be done in a specified time period at this work center group. ';

                    trigger OnDrillDown()
                    var
                        CalendarEntry: Record "Calendar Entry";
                    begin
                        CalendarEntry.SetCurrentKey("Work Center Group Code");
                        CalendarEntry.SetRange("Work Center Group Code",WorkCenterGroup.Code);
                        CalendarEntry.SetFilter(Date,WorkCenterGroup.GetFilter("Date Filter"));
                        PAGE.Run(0,CalendarEntry);
                    end;
                }
                field("WorkCenterGroup.""Prod. Order Need (Qty.)""";WorkCenterGroup."Prod. Order Need (Qty.)")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Allocated Qty.';
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies the amount of capacity that is needed to produce a desired output in a given time period. ';

                    trigger OnDrillDown()
                    var
                        ProdOrderCapNeed: Record "Prod. Order Capacity Need";
                    begin
                        ProdOrderCapNeed.SetCurrentKey("Work Center Group Code",Date);
                        ProdOrderCapNeed.SetRange("Requested Only",false);
                        ProdOrderCapNeed.SetRange("Work Center Group Code",WorkCenterGroup.Code);
                        ProdOrderCapNeed.SetFilter(Date,WorkCenterGroup.GetFilter("Date Filter"));
                        PAGE.Run(0,ProdOrderCapNeed);
                    end;
                }
                field(CapacityAvailable;CapacityAvailable)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Availability After Orders';
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies the available capacity of this work center group that is not used in the planning of a given time period.';
                }
                field(CapacityEfficiency;CapacityEfficiency)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Load';
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies the sum of the required number of times that all the planned and actual orders are run on the work center group in a specified period.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetDateFilter;
        CalculateCapacity(WorkCenterGroup."Capacity (Effective)",WorkCenterGroup."Prod. Order Need (Qty.)");
        CapacityAvailable := WorkCenterGroup."Capacity (Effective)" - WorkCenterGroup."Prod. Order Need (Qty.)";
        if WorkCenterGroup."Capacity (Effective)" <> 0 then
          CapacityEfficiency := Round(WorkCenterGroup."Prod. Order Need (Qty.)" / WorkCenterGroup."Capacity (Effective)" * 100,0.1)
        else
          CapacityEfficiency := 0;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(PeriodFormMgt.FindDate(Which,Rec,PeriodType));
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(PeriodFormMgt.NextDate(Steps,Rec,PeriodType));
    end;

    trigger OnOpenPage()
    begin
        Reset;
        MfgSetup.Get;
        MfgSetup.TestField("Show Capacity In");
    end;

    var
        WorkCenterGroup: Record "Work Center Group";
        MfgSetup: Record "Manufacturing Setup";
        PeriodFormMgt: Codeunit PeriodFormManagement;
        CapacityAvailable: Decimal;
        CapacityEfficiency: Decimal;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        AmountType: Option "Net Change","Balance at Date";
        CapacityUoM: Code[10];

    [Scope('Personalization')]
    procedure Set(var NewWorkCenterGroup: Record "Work Center Group";NewPeriodType: Integer;NewAmountType: Option "Net Change","Balance at Date";NewCapUoM: Code[10])
    begin
        WorkCenterGroup.Copy(NewWorkCenterGroup);
        PeriodType := NewPeriodType;
        AmountType := NewAmountType;
        CapacityUoM := NewCapUoM;
        CurrPage.Update(false);
    end;

    local procedure SetDateFilter()
    begin
        if AmountType = AmountType::"Net Change" then
          WorkCenterGroup.SetRange("Date Filter","Period Start","Period End")
        else
          WorkCenterGroup.SetRange("Date Filter",0D,"Period End");
    end;

    local procedure CalculateCapacity(var CapacityEffective: Decimal;var ProdOrderNeed: Decimal)
    var
        WorkCenter: Record "Work Center";
        CalendarMgt: Codeunit CalendarManagement;
        Capacity: Decimal;
        PONeed: Decimal;
    begin
        if CapacityUoM = '' then
          CapacityUoM := MfgSetup."Show Capacity In";
        WorkCenter.SetCurrentKey("Work Center Group Code");
        WorkCenter.SetRange("Work Center Group Code",WorkCenterGroup.Code);
        if WorkCenter.FindSet then
          repeat
            WorkCenterGroup.CopyFilter("Date Filter",WorkCenter."Date Filter");
            WorkCenter.CalcFields("Capacity (Effective)","Prod. Order Need (Qty.)");
            Capacity :=
              Capacity +
              WorkCenter."Capacity (Effective)" *
              CalendarMgt.TimeFactor(WorkCenter."Unit of Measure Code") /
              CalendarMgt.TimeFactor(CapacityUoM);

            PONeed :=
              PONeed +
              WorkCenter."Prod. Order Need (Qty.)" *
              CalendarMgt.TimeFactor(WorkCenter."Unit of Measure Code") /
              CalendarMgt.TimeFactor(CapacityUoM);
          until WorkCenter.Next = 0;

        CapacityEffective := Capacity;
        ProdOrderNeed := PONeed;
    end;
}

