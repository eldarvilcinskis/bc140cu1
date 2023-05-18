page 2115 "Report Viewer"
{
    Caption = 'Report Viewer';

    layout
    {
        area(content)
        {
            usercontrol(PdfViewer;"Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = Basic,Suite,Invoicing;

                trigger ControlAddInReady(callbackUrl: Text)
                var
                    FileManagement: Codeunit "File Management";
                begin
                    if DocumentPath = '' then
                      Error(NoDocErr);

                    CurrPage.PdfViewer.SetContent(FileManagement.GetFileContent(DocumentPath));
                end;

                trigger DocumentReady()
                begin
                end;

                trigger Callback(data: Text)
                begin
                end;

                trigger Refresh(callbackUrl: Text)
                var
                    FileManagement: Codeunit "File Management";
                begin
                    if DocumentPath <> '' then
                      CurrPage.PdfViewer.SetContent(FileManagement.GetFileContent(DocumentPath));
                end;
            }
        }
    }

    actions
    {
    }

    var
        DocumentPath: Text[250];
        NoDocErr: Label 'No document has been specified.';

    [Scope('Internal')]
    procedure SetDocument(RecordVariant: Variant;ReportType: Integer;CustNo: Code[20])
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.GetHtmlReport(DocumentPath,ReportType,RecordVariant,CustNo);
    end;
}

