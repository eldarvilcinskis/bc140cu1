report 5185 "Log Segment"
{
    Caption = 'Log Segment';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Segment Header";"Segment Header")
        {
            DataItemTableView = SORTING("No.");

            trigger OnAfterGetRecord()
            begin
                SegManagement.LogSegment("Segment Header",Send,FollowUp);
            end;

            trigger OnPreDataItem()
            begin
                SetRange("No.",SegmentNo);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(Deliver;Send)
                    {
                        ApplicationArea = RelationshipMgmt;
                        Caption = 'Send Attachments';
                        Enabled = DeliverEnable;
                        ToolTip = 'Specifies if you want to deliver the attachments and send them by e-mail or fax, or print them when you choose OK.';
                    }
                    field(FollowUp;FollowUp)
                    {
                        ApplicationArea = RelationshipMgmt;
                        Caption = 'Create Follow-up Segment';
                        ToolTip = 'Specifies if you want to create a new segment that Specifies the same contacts when you choose OK.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            DeliverEnable := true;
        end;

        trigger OnOpenPage()
        var
            SegLine: Record "Segment Line";
        begin
            SegLine.SetRange("Segment No.",SegmentNo);
            SegLine.SetFilter("Correspondence Type",'<>0');
            Send := SegLine.FindFirst;
            DeliverEnable := Send;
        end;
    }

    labels
    {
    }

    var
        SegManagement: Codeunit SegManagement;
        SegmentNo: Code[20];
        Send: Boolean;
        FollowUp: Boolean;
        [InDataSet]
        DeliverEnable: Boolean;

    [Scope('Personalization')]
    procedure SetSegmentNo(SegmentFilter: Code[20])
    begin
        SegmentNo := SegmentFilter;
    end;

    [Scope('Personalization')]
    procedure InitializeRequest(SendFrom: Boolean;FollowUpFrom: Boolean)
    begin
        Send := SendFrom;
        FollowUp := FollowUpFrom;
    end;
}

