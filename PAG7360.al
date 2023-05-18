page 7360 "Whse. Internal Pick Lines"
{
    Caption = 'Whse. Internal Pick Lines';
    Editable = false;
    PageType = List;
    SourceTable = "Whse. Internal Pick Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Location Code";"Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code of the location of the internal pick line.';
                    Visible = false;
                }
                field("To Zone Code";"To Zone Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the To Zone Code of the zone where items should be placed once they are picked.';
                    Visible = false;
                }
                field("To Bin Code";"To Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code of the bin into which the items should be placed when they are picked.';
                    Visible = false;
                }
                field("Shelf No.";"Shelf No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the shelf number of the item for informational use.';
                    Visible = false;
                }
                field("Item No.";"Item No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the item that should be picked.';
                }
                field("Variant Code";"Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the description of the item in the line.';
                }
                field("Description 2";"Description 2")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies a second description of the item on the line.';
                    Visible = false;
                }
                field(Quantity;Quantity)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity that should be picked.';
                }
                field("Qty. (Base)";"Qty. (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity that should be picked, in the base unit of measure.';
                    Visible = false;
                }
                field("Qty. Outstanding";"Qty. Outstanding")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity that still needs to be handled.';
                }
                field("Qty. Outstanding (Base)";"Qty. Outstanding (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity that still needs to be handled, in the base unit of measure.';
                    Visible = false;
                }
                field("Qty. Picked";"Qty. Picked")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity of the line that is registered as picked.';
                }
                field("Qty. Picked (Base)";"Qty. Picked (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity of the line that is registered as picked, in the base unit of measure.';
                    Visible = false;
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Qty. per Unit of Measure";"Qty. per Unit of Measure")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of base units of measure, that are in the unit of measure, specified for the item on the line.';
                }
                field(Status;Status)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies if the status is Blank, Partially Picked, or Completely Picked.';
                }
                field("Due Date";"Due Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the date when the warehouse activity must be completed.';
                }
                field("No.";"No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Line No.";"Line No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the line.';
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
                action("Show Whse. Document")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Show Whse. Document';
                    Image = ViewOrder;
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View the related ongoing warehouse document.';

                    trigger OnAction()
                    var
                        WhseInternalPickHeader: Record "Whse. Internal Pick Header";
                    begin
                        WhseInternalPickHeader.Get("No.");
                        PAGE.Run(PAGE::"Whse. Internal Pick",WhseInternalPickHeader);
                    end;
                }
            }
        }
    }
}

