page 323 "EC Sales List Reports"
{
    ApplicationArea = Basic, Suite;
    Caption = 'EC Sales List Reports';
    CardPageID = "ECSL Report";
    DeleteAllowed = false;
    Editable = false;
    PageType = List;
    SourceTable = "VAT Report Header";
    SourceTableView = WHERE("VAT Report Config. Code" = FILTER("EC Sales List"));
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("VAT Report Config. Code"; "VAT Report Config. Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the appropriate configuration code for EC Sales List Reports.';
                    Visible = false;
                }
                field("VAT Report Type"; "VAT Report Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want to create a new VAT report, or if you want to change a previously submitted report.';
                    Visible = false;
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the first date of the reporting period.';
                    Visible = false;
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the last date of the EC sales list report.';
                    Visible = false;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series from which entry or record numbers are assigned to new entries or records.';
                    Visible = false;
                }
                field("Original Report No."; "Original Report No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the original report.';
                    Visible = false;
                }
                field("Period Type"; "Period Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the length of the reporting period.';
                }
                field("Period No."; "Period No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the EC sales list reporting period to use.';
                }
                field("Period Year"; "Period Year")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the year of the reporting period.';
                }
                field("Message Id"; "Message Id")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the message ID of the report listing sales to other EU countries/regions.';
                    Visible = false;
                }
                field("Statement Template Name"; "Statement Template Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the statement template from the EC Sales List Report.';
                    Visible = false;
                }
                field("Statement Name"; "Statement Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the statement from the EC Sales List Report.';
                    Visible = false;
                }
                field("VAT Report Version"; "VAT Report Version")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the version of the VAT report.';
                    Visible = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the report, such as Open or Submitted. ';
                }
                field("Submitted By"; SubmittedBy)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Submitted By';
                    ToolTip = 'Specifies the name of the person who submitted the report. ';
                }
                field("Submitted Date"; SubmittedDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Submitted Date';
                    ToolTip = 'Specifies the date when the report was submitted. ';
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        VATReportArchive: Record "VAT Report Archive";
    begin
        if VATReportArchive.Get("VAT Report Type", "No.") then begin
            SubmittedBy := VATReportArchive."Submitted By";
            SubmittedDate := VATReportArchive."Submittion Date";
        end;
    end;

    var
        SubmittedBy: Code[50];
        SubmittedDate: Date;
}

