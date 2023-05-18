page 9658 "Vendor Report Selections"
{
    Caption = 'Vendor Report Selections';
    DataCaptionFields = "Source No.";
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Custom Report Selection";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = "Custom Report Description";
                field(Usage2;Usage2)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Usage';
                    OptionCaption = 'Purchase Order,Vendor Remittance,Vendor Remittance - Posted Entries';
                    ToolTip = 'Specifies which type of document the report is used for.';

                    trigger OnValidate()
                    begin
                        case Usage2 of
                          Usage2::"Purchase Order":
                            Usage := Usage::"P.Order";
                          Usage2::"Vendor Remittance":
                            Usage := Usage::"V.Remittance";
                          Usage2::"Vendor Remittance - Posted Entries":
                            Usage := Usage::"P.V.Remit.";
                        end;
                    end;
                }
                field(ReportID;"Report ID")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Report ID';
                    ToolTip = 'Specifies the ID of the report.';
                }
                field(ReportCaption;"Report Caption")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Report Caption';
                    ToolTip = 'Specifies the name of the report.';
                }
                field("Custom Report Description";"Custom Report Description")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Custom Layout Description';
                    DrillDown = true;
                    Lookup = true;
                    ToolTip = 'Specifies a description of the custom report layout.';

                    trigger OnDrillDown()
                    begin
                        LookupCustomReportDescription;
                        CurrPage.Update(true);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupCustomReportDescription;
                        CurrPage.Update(true);
                    end;

                    trigger OnValidate()
                    var
                        CustomReportLayout: Record "Custom Report Layout";
                    begin
                        if "Custom Report Description" = '' then begin
                          Validate("Custom Report Layout Code",'');
                          Modify(true);
                        end else begin
                          CustomReportLayout.SetRange("Report ID","Report ID");
                          CustomReportLayout.SetFilter(Description,StrSubstNo('@*%1*',"Custom Report Description"));
                          if not CustomReportLayout.FindFirst then
                            Error(CouldNotFindCustomReportLayoutErr,"Custom Report Description");

                          Validate("Custom Report Layout Code",CustomReportLayout.Code);
                          Modify(true);
                        end;
                    end;
                }
                field(SendToEmail;"Send To Email")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Send To Email';
                    ToolTip = 'Specifies that the report is used when sending emails.';
                }
                field("Use for Email Body";"Use for Email Body")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies that summarized information, such as invoice number, due date, and payment service link, will be inserted in the body of the email that you send.';
                }
                field("Email Body Layout Code";"Email Body Layout Code")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the ID of the email body layout that is used.';
                    Visible = false;
                }
                field("Email Body Layout Description";"Email Body Layout Description")
                {
                    ApplicationArea = Basic,Suite;
                    DrillDown = true;
                    Lookup = true;
                    ToolTip = 'Specifies a description of the email body layout that is used.';

                    trigger OnDrillDown()
                    begin
                        LookupEmailBodyDescription;
                        CurrPage.Update(true);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupEmailBodyDescription;
                        CurrPage.Update(true);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        MapTableUsageValueToPageValue;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        // Set the default usage to the same as the page default.
        if Usage = 0 then
          Usage := Usage::"P.Order";

        MapTableUsageValueToPageValue;
    end;

    var
        Usage2: Option "Purchase Order","Vendor Remittance","Vendor Remittance - Posted Entries";
        CouldNotFindCustomReportLayoutErr: Label 'There is no custom report layout with %1 in the description.', Comment='%1 Description of custom report layout';

    local procedure MapTableUsageValueToPageValue()
    var
        CustomReportSelection: Record "Custom Report Selection";
    begin
        case Usage of
          CustomReportSelection.Usage::"P.Order":
            Usage2 := Usage2::"Purchase Order";
          CustomReportSelection.Usage::"V.Remittance":
            Usage2 := Usage2::"Vendor Remittance";
          CustomReportSelection.Usage::"P.V.Remit.":
            Usage2 := Usage2::"Vendor Remittance - Posted Entries";
        end;
    end;
}
