page 375 "Bank Account Statistics"
{
    Caption = 'Bank Account Statistics';
    DataCaptionFields = "No.",Name;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    SourceTable = "Bank Account";

    layout
    {
        area(content)
        {
            group(Balance)
            {
                Caption = 'Balance';
                field("Balance (LCY)";"Balance (LCY)")
                {
                    ApplicationArea = Basic,Suite;
                    AutoFormatType = 1;
                    Caption = 'Balance (LCY)';
                    ToolTip = 'Specifies the bank account''s current balance in LCY.';
                }
                field(Control3;Balance)
                {
                    ApplicationArea = Basic,Suite;
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                    ShowCaption = false;
                    ToolTip = 'Specifies the bank account''s current balance denominated in the applicable foreign currency.';
                }
                field("Min. Balance";"Min. Balance")
                {
                    ApplicationArea = Basic,Suite;
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                    ToolTip = 'Specifies a minimum balance for the bank account.';
                }
                field("Currency Code";"Currency Code")
                {
                    ApplicationArea = Suite;
                    Caption = 'Currency';
                    Lookup = false;
                    ToolTip = 'Specifies the currency code for the bank account.';
                }
            }
            group("Net Change")
            {
                Caption = 'Net Change';
                fixed(Control1904230801)
                {
                    ShowCaption = false;
                    group("This Period")
                    {
                        Caption = 'This Period';
                        field("BankAccDateName[1]";BankAccDateName[1])
                        {
                            ApplicationArea = Basic,Suite;
                            Caption = 'Date Name';
                            ToolTip = 'Specifies the date.';
                        }
                        field("BankAccNetChange[1]";BankAccNetChange[1])
                        {
                            ApplicationArea = Basic,Suite;
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                            Caption = 'Net Change';
                            ToolTip = 'Specifies the net value of entries in LCY on the bank account for the periods: Current Month, This Year, Last Year and To Date.';
                        }
                        field("BankAccNetChangeLCY[1]";BankAccNetChangeLCY[1])
                        {
                            ApplicationArea = Basic,Suite;
                            AutoFormatType = 1;
                            Caption = 'Net Change (LCY)';
                            ToolTip = 'Specifies the net value of entries in LCY on the bank account for the periods: Current Month, This Year, Last Year, and To Date.';
                        }
                    }
                    group("This Year")
                    {
                        Caption = 'This Year';
                        field(Text000;Text000)
                        {
                            ApplicationArea = Basic,Suite;
                            Visible = false;
                        }
                        field("BankAccNetChange[2]";BankAccNetChange[2])
                        {
                            ApplicationArea = Basic,Suite;
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                            Caption = 'Net Change';
                            ToolTip = 'Specifies the net value of entries in LCY on the bank account for the periods: Current Month, This Year, Last Year and To Date.';
                        }
                        field("BankAccNetChangeLCY[2]";BankAccNetChangeLCY[2])
                        {
                            ApplicationArea = Basic,Suite;
                            AutoFormatType = 1;
                            Caption = 'Net Change (LCY)';
                            ToolTip = 'Specifies the net value of entries in LCY on the bank account for the periods: Current Month, This Year, Last Year, and To Date.';
                        }
                    }
                    group("Last Year")
                    {
                        Caption = 'Last Year';
                        field(Control27;Text000)
                        {
                            ApplicationArea = Basic,Suite;
                            ShowCaption = false;
                            Visible = false;
                        }
                        field("BankAccNetChange[3]";BankAccNetChange[3])
                        {
                            ApplicationArea = Basic,Suite;
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                            Caption = 'Net Change';
                            ToolTip = 'Specifies the net value of entries in LCY on the bank account for the periods: Current Month, This Year, Last Year and To Date.';
                        }
                        field("BankAccNetChangeLCY[3]";BankAccNetChangeLCY[3])
                        {
                            ApplicationArea = Basic,Suite;
                            AutoFormatType = 1;
                            Caption = 'Net Change (LCY)';
                            ToolTip = 'Specifies the net value of entries in LCY on the bank account for the periods: Current Month, This Year, Last Year, and To Date.';
                        }
                    }
                    group("To Date")
                    {
                        Caption = 'To Date';
                        field(Control28;Text000)
                        {
                            ApplicationArea = Basic,Suite;
                            ShowCaption = false;
                            Visible = false;
                        }
                        field("BankAccNetChange[4]";BankAccNetChange[4])
                        {
                            ApplicationArea = Basic,Suite;
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                            Caption = 'Net Change';
                            ToolTip = 'Specifies the net value of entries in LCY on the bank account for the periods: Current Month, This Year, Last Year and To Date.';
                        }
                        field("BankAccNetChangeLCY[4]";BankAccNetChangeLCY[4])
                        {
                            ApplicationArea = Basic,Suite;
                            AutoFormatType = 1;
                            Caption = 'Net Change (LCY)';
                            ToolTip = 'Specifies the net value of entries in LCY on the bank account for the periods: Current Month, This Year, Last Year, and To Date.';
                        }
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        if CurrentDate <> WorkDate then begin
          CurrentDate := WorkDate;
          DateFilterCalc.CreateAccountingPeriodFilter(BankAccDateFilter[1],BankAccDateName[1],CurrentDate,0);
          DateFilterCalc.CreateFiscalYearFilter(BankAccDateFilter[2],BankAccDateName[2],CurrentDate,0);
          DateFilterCalc.CreateFiscalYearFilter(BankAccDateFilter[3],BankAccDateName[3],CurrentDate,-1);
        end;

        SetRange("Date Filter",0D,CurrentDate);
        CalcFields(Balance,"Balance (LCY)");

        for i := 1 to 4 do begin
          SetFilter("Date Filter",BankAccDateFilter[i]);
          CalcFields("Net Change","Net Change (LCY)");
          BankAccNetChange[i] := "Net Change";
          BankAccNetChangeLCY[i] := "Net Change (LCY)";
        end;
        SetRange("Date Filter",0D,CurrentDate);
    end;

    var
        DateFilterCalc: Codeunit "DateFilter-Calc";
        BankAccDateFilter: array [4] of Text[30];
        BankAccDateName: array [4] of Text[30];
        CurrentDate: Date;
        BankAccNetChange: array [4] of Decimal;
        BankAccNetChangeLCY: array [4] of Decimal;
        i: Integer;
        Text000: Label 'Placeholder';
}

