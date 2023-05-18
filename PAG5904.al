page 5904 "Service Line List"
{
    Caption = 'Service Line List';
    DataCaptionFields = "Fault Reason Code";
    Editable = false;
    PageType = List;
    SourceTable = "Service Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Line No.";"Line No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the number of the line.';
                }
                field("Posting Date";"Posting Date")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the date when the service line should be posted.';
                }
                field("Document Type";"Document Type")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the type of the service document associated with this line.';
                }
                field("Document No.";"Document No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the service order number associated with this line.';
                }
                field(Type;Type)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the type of the service line.';
                }
                field("No.";"No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Location Code";"Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the inventory location from where the items on the line should be taken and where they should be registered.';
                    Visible = false;
                }
                field("Customer No.";"Customer No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the number of the customer who owns the items to be serviced under the service order.';
                }
                field("Ship-to Code";"Ship-to Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies a code for an alternate shipment address if you want to ship to another address than the one that has been entered automatically. This field is also used in case of drop shipment.';
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Job No.";"Job No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the number of the related job.';
                    Visible = false;
                }
                field("Job Task No.";"Job Task No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the number of the related job task.';
                    Visible = false;
                }
                field("Job Line Type";"Job Line Type")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the type of journal line that is created in the Job Planning Line table from this line.';
                    Visible = false;
                }
                field("Needed by Date";"Needed by Date")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the date when you require the item to be available for a service order.';
                }
                field(Quantity;Quantity)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the number of item units, resource hours, cost on the service line.';
                }
                field("Quantity (Base)";"Quantity (Base)")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the quantity of items, resource time, costs, or general ledger account payments, expressed in base units of measure.';
                }
                field("Outstanding Qty. (Base)";"Outstanding Qty. (Base)")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the quantity of registered items, resource time, costs, or payments to the general ledger account that have not been shipped.';
                }
                field("Line Amount";"Line Amount")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the net amount, excluding any invoice discount amount, that must be paid for products on the line.';
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
                }
                field("Line Discount Type";"Line Discount Type")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the type of the line discount assigned to this line.';
                }
                field("Spare Part Action";"Spare Part Action")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies whether the item was used to replace the whole service item, one of the service item components, installed as a new component, or used as a supplementary tool.';
                    Visible = false;
                }
                field("Fault Reason Code";"Fault Reason Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the code of the fault reason for this service line.';
                    Visible = false;
                }
                field("Exclude Warranty";"Exclude Warranty")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies that the warranty discount is excluded on this line.';
                }
                field(Warranty;Warranty)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies that a warranty discount is available on this line of type Item or Resource.';
                }
                field("Contract No.";"Contract No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the number of the contract, if the service order originated from a service contract.';
                }
                field("Service Item Line No.";"Service Item Line No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the service item line number linked to this service line.';
                }
                field("Service Item No.";"Service Item No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the service item number linked to this service line.';
                }
                field("Service Item Serial No.";"Service Item Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the service item serial number linked to this line.';
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
                action("Show Document")
                {
                    ApplicationArea = Service;
                    Caption = 'Show Document';
                    Image = View;
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'Open the document that the selected line exists on.';

                    trigger OnAction()
                    var
                        PageManagement: Codeunit "Page Management";
                    begin
                        if ServHeader.Get("Document Type","Document No.") then
                          PageManagement.PageRun(ServHeader);
                    end;
                }
            }
        }
    }

    var
        ServHeader: Record "Service Header";
}

