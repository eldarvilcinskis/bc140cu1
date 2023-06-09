query 7300 "Lot Numbers by Bin"
{
    Caption = 'Lot Numbers by Bin';
    OrderBy = Ascending(Bin_Code);

    elements
    {
        dataitem(Warehouse_Entry;"Warehouse Entry")
        {
            column(Location_Code;"Location Code")
            {
            }
            column(Item_No;"Item No.")
            {
            }
            column(Variant_Code;"Variant Code")
            {
            }
            column(Zone_Code;"Zone Code")
            {
            }
            column(Bin_Code;"Bin Code")
            {
            }
            column(Lot_No;"Lot No.")
            {
                ColumnFilter = Lot_No=FILTER(<>'');
            }
            column(Sum_Qty_Base;"Qty. (Base)")
            {
                ColumnFilter = Sum_Qty_Base=FILTER(<>0);
                Method = Sum;
            }
        }
    }
}

