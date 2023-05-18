report 153 "Customer Statement"
{
    ApplicationArea = Basic,Suite;
    Caption = 'Customer Statement';
    ProcessingOnly = true;
    UsageCategory = Documents;
    UseRequestPage = false;

    dataset
    {
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    var
        Customer: Record Customer;
        ReportSelections: Record "Report Selections";
        CustomLayoutReporting: Codeunit "Custom Layout Reporting";
        RecRef: RecordRef;
    begin
        RecRef.Open(DATABASE::Customer);
        CustomLayoutReporting.SetOutputFileBaseName(StatementFileNameTxt);
        CustomLayoutReporting.ProcessReportForData(ReportSelections.Usage::"C.Statement",RecRef,Customer.FieldName("No."),
          DATABASE::Customer,Customer.FieldName("No."),true);
    end;

    var
        StatementFileNameTxt: Label 'Statement', Comment='Shortened form of ''Customer Statement''';
}

