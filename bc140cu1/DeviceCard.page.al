page 9814 "Device Card"
{
    Caption = 'Device Card';
    DelayedInsert = true;
    PageType = Card;
    SourceTable = Device;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("MAC Address";"MAC Address")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the MAC Address for the device. MAC is an acronym for Media Access Control. A MAC Address is a unique identifier that is assigned to network interfaces for communications.';
                }
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a name for the device.';
                }
                field("Device Type";"Device Type")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the device type.';
                }
                field(Enabled;Enabled)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies whether the device is enabled.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control8;Notes)
            {
                ApplicationArea = Notes;
            }
            systempart(Control9;Links)
            {
                ApplicationArea = RecordLinks;
            }
        }
    }

    actions
    {
    }
}

