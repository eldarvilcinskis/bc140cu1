page 350 "G/L Acc. Balance/Budget Lines"
{
    Caption = 'Lines';
    DeleteAllowed = false;
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
                    ApplicationArea = Suite;
                    Caption = 'Period Start';
                    Editable = false;
                    ToolTip = 'Specifies the starting date of the period that you want to view.';
                }
                field("Period Name";"Period Name")
                {
                    ApplicationArea = Suite;
                    Caption = 'Period Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the period that you want to view.';
                }
                field(DebitAmount;GLAcc."Debit Amount")
                {
                    ApplicationArea = Suite;
                    AutoFormatType = 1;
                    BlankNumbers = BlankNegAndZero;
                    Caption = 'Actual Debit Amount';
                    DrillDown = true;
                    Editable = false;
                    ToolTip = 'Specifies the total of the debit entries that have been posted to the account.';

                    trigger OnDrillDown()
                    begin
                        BalanceDrillDown;
                    end;
                }
                field(CreditAmount;GLAcc."Credit Amount")
                {
                    ApplicationArea = Suite;
                    AutoFormatType = 1;
                    BlankNumbers = BlankNegAndZero;
                    Caption = 'Actual Credit Amount';
                    DrillDown = true;
                    Editable = false;
                    ToolTip = 'Specifies the total of the credit entries that have been posted to the account.';

                    trigger OnDrillDown()
                    begin
                        BalanceDrillDown;
                    end;
                }
                field(NetChange;GLAcc."Net Change")
                {
                    ApplicationArea = Suite;
                    AutoFormatType = 1;
                    BlankZero = true;
                    Caption = 'Net Change';
                    DrillDown = true;
                    Editable = false;
                    ToolTip = 'Specifies the net change in the account balance during the time period in the Date Filter field.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        BalanceDrillDown;
                    end;
                }
                field(BudgetedDebitAmount;GLAcc."Budgeted Debit Amount")
                {
                    ApplicationArea = Suite;
                    AutoFormatType = 1;
                    BlankNumbers = BlankNegAndZero;
                    Caption = 'Budgeted Debit Amount';
                    DrillDown = true;
                    ToolTip = 'Specifies the total of the budget debit entries that have been posted to the account.';

                    trigger OnDrillDown()
                    begin
                        BudgetDrillDown;
                    end;

                    trigger OnValidate()
                    begin
                        SetDateFilter;
                        GLAcc.Validate("Budgeted Debit Amount");
                        CalcFormFields;
                    end;
                }
                field(BudgetedCreditAmount;GLAcc."Budgeted Credit Amount")
                {
                    ApplicationArea = Suite;
                    AutoFormatType = 1;
                    BlankNumbers = BlankNegAndZero;
                    Caption = 'Budgeted Credit Amount';
                    DrillDown = true;
                    ToolTip = 'Specifies the total of the budget credit entries that have been posted to the account.';

                    trigger OnDrillDown()
                    begin
                        BudgetDrillDown;
                    end;

                    trigger OnValidate()
                    begin
                        SetDateFilter;
                        GLAcc.Validate("Budgeted Credit Amount");
                        CalcFormFields;
                    end;
                }
                field(BudgetedAmount;GLAcc."Budgeted Amount")
                {
                    ApplicationArea = Suite;
                    AutoFormatType = 1;
                    BlankZero = true;
                    Caption = 'Budgeted Amount';
                    DrillDown = true;
                    ToolTip = 'Specifies the total of the budget entries that have been posted to the account.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        BudgetDrillDown;
                    end;

                    trigger OnValidate()
                    begin
                        SetDateFilter;
                        GLAcc.Validate("Budgeted Amount");
                        CalcFormFields;
                    end;
                }
                field(BudgetPct;BudgetPct)
                {
                    ApplicationArea = Suite;
                    BlankZero = true;
                    Caption = 'Balance/Budget (%)';
                    DecimalPlaces = 1:1;
                    Editable = false;
                    ToolTip = 'Specifies a summary of the debit and credit balances and the budgeted amounts for different time periods for the account that you select in the chart of accounts.';
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
        CalcFormFields;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(PeriodFormMgt.FindDate(Which,Rec,GLPeriodLength));
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(PeriodFormMgt.NextDate(Steps,Rec,GLPeriodLength));
    end;

    trigger OnOpenPage()
    begin
        Reset;
    end;

    var
        AccountingPeriod: Record "Accounting Period";
        GLAcc: Record "G/L Account";
        PeriodFormMgt: Codeunit PeriodFormManagement;
        GLPeriodLength: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        BudgetPct: Decimal;
        AmountType: Option "Net Change","Balance at Date";
        ClosingEntryFilter: Option Include,Exclude;

    [Scope('Personalization')]
    procedure Set(var NewGLAcc: Record "G/L Account";NewGLPeriodLength: Integer;NewAmountType: Option "Net Change",Balance;NewClosingEntryFilter: Option Include,Exclude)
    begin
        GLAcc.Copy(NewGLAcc);

        if GLAcc.GetFilter("Date Filter") <> '' then begin
          FilterGroup(2);
          SetFilter("Period Start",GLAcc.GetFilter("Date Filter"));
          FilterGroup(0);
        end;

        GLPeriodLength := NewGLPeriodLength;
        AmountType := NewAmountType;
        ClosingEntryFilter := NewClosingEntryFilter;
        CurrPage.Update(false);
    end;

    local procedure BalanceDrillDown()
    var
        GLEntry: Record "G/L Entry";
    begin
        SetDateFilter;
        GLEntry.Reset;
        GLEntry.SetCurrentKey("G/L Account No.","Posting Date");
        GLEntry.SetRange("G/L Account No.",GLAcc."No.");
        if GLAcc.Totaling <> '' then
          GLEntry.SetFilter("G/L Account No.",GLAcc.Totaling);
        GLEntry.SetFilter("Posting Date",GLAcc.GetFilter("Date Filter"));
        GLEntry.SetFilter("Global Dimension 1 Code",GLAcc.GetFilter("Global Dimension 1 Filter"));
        GLEntry.SetFilter("Global Dimension 2 Code",GLAcc.GetFilter("Global Dimension 2 Filter"));
        GLEntry.SetFilter("Business Unit Code",GLAcc.GetFilter("Business Unit Filter"));
        PAGE.Run(0,GLEntry);
    end;

    local procedure BudgetDrillDown()
    var
        GLBudgetEntry: Record "G/L Budget Entry";
    begin
        SetDateFilter;
        GLBudgetEntry.Reset;
        GLBudgetEntry.SetCurrentKey("Budget Name","G/L Account No.",Date);
        GLBudgetEntry.SetFilter("Budget Name",GLAcc.GetFilter("Budget Filter"));
        GLBudgetEntry.SetRange("G/L Account No.",GLAcc."No.");
        if GLAcc.Totaling <> '' then
          GLBudgetEntry.SetFilter("G/L Account No.",GLAcc.Totaling);
        GLBudgetEntry.SetFilter(Date,GLAcc.GetFilter("Date Filter"));
        GLBudgetEntry.SetFilter("Global Dimension 1 Code",GLAcc.GetFilter("Global Dimension 1 Filter"));
        GLBudgetEntry.SetFilter("Global Dimension 2 Code",GLAcc.GetFilter("Global Dimension 2 Filter"));
        GLBudgetEntry.SetFilter("Business Unit Code",GLAcc.GetFilter("Business Unit Filter"));
        PAGE.Run(0,GLBudgetEntry);
    end;

    local procedure SetDateFilter()
    begin
        if AmountType = AmountType::"Net Change" then begin
          GLAcc.SetRange("Date Filter","Period Start","Period End");
        end else
          GLAcc.SetRange("Date Filter",0D,"Period End");
        if ClosingEntryFilter = ClosingEntryFilter::Exclude then begin
          AccountingPeriod.SetCurrentKey("New Fiscal Year");
          AccountingPeriod.SetRange("New Fiscal Year",true);
          if GLAcc.GetRangeMin("Date Filter") = 0D then
            AccountingPeriod.SetRange("Starting Date",0D,GLAcc.GetRangeMax("Date Filter"))
          else
            AccountingPeriod.SetRange(
              "Starting Date",
              GLAcc.GetRangeMin("Date Filter") + 1,
              GLAcc.GetRangeMax("Date Filter"));
          if AccountingPeriod.Find('-') then
            repeat
              GLAcc.SetFilter(
                "Date Filter",GLAcc.GetFilter("Date Filter") + '&<>%1',
                ClosingDate(AccountingPeriod."Starting Date" - 1));
            until AccountingPeriod.Next = 0;
        end else
          GLAcc.SetRange(
            "Date Filter",
            GLAcc.GetRangeMin("Date Filter"),
            ClosingDate(GLAcc.GetRangeMax("Date Filter")));
    end;

    local procedure CalcFormFields()
    begin
        GLAcc.CalcFields("Net Change","Debit Amount","Credit Amount","Budgeted Amount");
        GLAcc."Budgeted Debit Amount" := GLAcc."Budgeted Amount";
        GLAcc."Budgeted Credit Amount" := -GLAcc."Budgeted Amount";
        if GLAcc."Budgeted Amount" = 0 then
          BudgetPct := 0
        else
          BudgetPct := Round(GLAcc."Net Change" / GLAcc."Budgeted Amount" * 100);

        OnAfterCalcFormFields(GLAcc,BudgetPct);
    end;

    [Scope('Personalization')]
    procedure GetGLAcc(var NewGLAcc: Record "G/L Account")
    begin
        NewGLAcc.Copy(GLAcc);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcFormFields(var GLAccount: Record "G/L Account";var BudgetPct: Decimal)
    begin
    end;
}

