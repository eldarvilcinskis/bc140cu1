page 5952 "Posted Service Cr. Memo Lines"
{
    Caption = 'Posted Service Cr. Memo Lines';
    Editable = false;
    PageType = List;
    SourceTable = "Service Cr.Memo Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Document No.";"Document No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the number of the credit memo.';
                }
                field("Customer No.";"Customer No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the number of the customer who has received the service on the credit memo.';
                }
                field(Type;Type)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the type of this credit memo line.';
                }
                field("No.";"No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Variant Code";"Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field(Description;Description)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the name of an item, resource, cost, general ledger account description, or some descriptive text on the service credit memo line.';
                }
                field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field(Quantity;Quantity)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the number of item units, resource hours, general ledger account payments, or cost specified on the credit memo line.';
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Unit of Measure";"Unit of Measure")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the name of the item or resource''s unit of measure, such as piece or hour.';
                    Visible = false;
                }
                field("Unit Price";"Unit Price")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the price of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
                }
                field("Unit Cost (LCY)";"Unit Cost (LCY)")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the cost, in LCY, of one unit of the item or resource on the line.';
                    Visible = false;
                }
                field(Amount;Amount)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the total net amount on the service line.';
                }
                field("Amount Including VAT";"Amount Including VAT")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the net amount, including VAT, for this line.';
                    Visible = false;
                }
                field("Line Discount %";"Line Discount %")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the discount percentage that is granted for the item on the line.';
                }
                field("Line Discount Amount";"Line Discount Amount")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the discount amount that is granted for the item on the line.';
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(ShowDocument)
                {
                    ApplicationArea = Service;
                    Caption = 'Show Document';
                    Image = View;
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'Open the document that the selected line exists on.';

                    trigger OnAction()
                    var
                        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
                    begin
                        ServiceCrMemoHeader.Get("Document No.");
                        PAGE.Run(PAGE::"Posted Service Credit Memo",ServiceCrMemoHeader);
                    end;
                }
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension=R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDimensions;
                    end;
                }
                action(ItemTrackingEntries)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item &Tracking Entries';
                    Image = ItemTrackingLedger;
                    ToolTip = 'View serial or lot numbers that are assigned to items.';

                    trigger OnAction()
                    begin
                        ShowItemTrackingLines;
                    end;
                }
            }
        }
    }
}

