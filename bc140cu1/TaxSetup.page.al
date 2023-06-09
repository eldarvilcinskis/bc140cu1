page 485 "Tax Setup"
{
    Caption = 'Tax Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    ShowFilter = false;
    SourceTable = "Tax Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Auto. Create Tax Details";"Auto. Create Tax Details")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies that the required tax information is created automatically.';
                }
                field("Non-Taxable Tax Group Code";"Non-Taxable Tax Group Code")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the group code for non-taxable sales.';
                }
            }
            group("Default Accounts")
            {
                Caption = 'Default Accounts';
                field("Tax Account (Sales)";"Tax Account (Sales)")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account you want to use for posting calculated tax.';
                }
                field("Tax Account (Purchases)";"Tax Account (Purchases)")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account you want to use for posting calculated tax.';
                }
                field("Unreal. Tax Acc. (Sales)";"Unreal. Tax Acc. (Sales)")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account you want to use for posting calculated unrealized tax on sales transaction.';
                }
                field("Unreal. Tax Acc. (Purchases)";"Unreal. Tax Acc. (Purchases)")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account you want to use for posting calculated unrealized tax on purchase transactions.';
                }
                field("Reverse Charge (Purchases)";"Reverse Charge (Purchases)")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account you want to use for posting calculated reverse-charge tax on purchase transactions.';
                }
                field("Unreal. Rev. Charge (Purch.)";"Unreal. Rev. Charge (Purch.)")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the general ledger account you want to use for posting calculated unrealized reverse-charge tax on purchase transactions.';
                }
            }
        }
    }

    actions
    {
    }
}

