codeunit 7714 "ADCS WS"
{

    trigger OnRun()
    begin
    end;

    var
        ADCSManagement: Codeunit "ADCS Management";

    [Scope('Personalization')]
    procedure ProcessDocument(var Document: Text)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        InputXmlDocument: DotNet XmlDocument;
        OutputXmlDocument: DotNet XmlDocument;
    begin
        XMLDOMManagement.LoadXMLDocumentFromText(Document, InputXmlDocument);
        ADCSManagement.ProcessDocument(InputXmlDocument);
        ADCSManagement.GetOutboundDocument(OutputXmlDocument);
        Document := OutputXmlDocument.OuterXml;
    end;
}

