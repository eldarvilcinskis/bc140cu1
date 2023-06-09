table 1319 "Sales by Cust. Grp.Chart Setup"
{
    Caption = 'Sales by Cust. Grp.Chart Setup';
    LookupPageID = "Account Schedule Chart List";

    fields
    {
        field(1;"User ID";Text[132])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(31;"Start Date";Date)
        {
            Caption = 'Start Date';

            trigger OnValidate()
            begin
                TestField("Start Date");
            end;
        }
        field(41;"Period Length";Option)
        {
            Caption = 'Period Length';
            OptionCaption = 'Day,Week,Month,Quarter,Year';
            OptionMembers = Day,Week,Month,Quarter,Year;
        }
    }

    keys
    {
        key(Key1;"User ID")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure SetPeriod(Which: Option " ",Next,Previous)
    var
        BusinessChartBuffer: Record "Business Chart Buffer";
    begin
        if Which = Which::" " then
          exit;

        Get(UserId);
        BusinessChartBuffer."Period Length" := "Period Length";
        case Which of
          Which::Previous:
            "Start Date" := CalcDate('<-1D>',BusinessChartBuffer.CalcFromDate("Start Date"));
          Which::Next:
            "Start Date" := CalcDate('<1D>',BusinessChartBuffer.CalcToDate("Start Date"));
        end;
        Modify;
    end;

    [Scope('Personalization')]
    procedure SetPeriodLength(PeriodLength: Option)
    begin
        Get(UserId);
        "Period Length" := PeriodLength;
        Modify(true);
    end;
}

