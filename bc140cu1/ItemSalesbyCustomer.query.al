query 102 "Item Sales by Customer"
{
    Caption = 'Item Sales by Customer';

    elements
    {
        dataitem(Value_Entry;"Value Entry")
        {
            DataItemTableFilter = "Source Type"=FILTER(Customer),"Item Ledger Entry No."=FILTER(<>0),"Document Type"=FILTER("Sales Invoice");
            column(Entry_No;"Entry No.")
            {
            }
            column(Document_No;"Document No.")
            {
            }
            column(Posting_Date;"Posting Date")
            {
            }
            column(Item_No;"Item No.")
            {
            }
            column(Item_Ledger_Entry_Quantity;"Item Ledger Entry Quantity")
            {
            }
            column(Dimension_Set_ID;"Dimension Set ID")
            {
            }
            dataitem(Customer;Customer)
            {
                DataItemLink = "No."=Value_Entry."Source No.";
                column(CustomerNo;"No.")
                {
                }
                column(Name;Name)
                {
                }
                dataitem(Item;Item)
                {
                    DataItemLink = "No."=Value_Entry."Item No.";
                    column(Description;Description)
                    {
                    }
                    column(Gen_Prod_Posting_Group;"Gen. Prod. Posting Group")
                    {
                    }
                }
            }
        }
    }
}

