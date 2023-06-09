codeunit 1239 "XML Buffer Reader"
{

    trigger OnRun()
    begin
    end;

    var
        DefaultNamespace: Text;

    [TryFunction]
    [Scope('Internal')]
    procedure SaveToFile(FilePath: Text; var XMLBuffer: Record "XML Buffer")
    var
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
    begin
        SaveToTempBlobWithEncoding(TempBlob, XMLBuffer, 'UTF-8');
        FileMgt.BLOBExportToServerFile(TempBlob, FilePath);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure SaveToTempBlob(var TempBlob: Record TempBlob; var XMLBuffer: Record "XML Buffer")
    begin
        SaveToTempBlobWithEncoding(TempBlob, XMLBuffer, 'UTF-8');
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure SaveToTempBlobWithEncoding(var TempBlob: Record TempBlob; var XMLBuffer: Record "XML Buffer"; Encoding: Text)
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        TempAttributeXMLBuffer: Record "XML Buffer" temporary;
        XMLDOMManagement: Codeunit "XML DOM Management";
        XmlDocument: DotNet XmlDocument;
        RootElement: DotNet XmlNode;
        OutStr: OutStream;
        Header: Text;
    begin
        TempXMLBuffer.CopyImportFrom(XMLBuffer);
        TempXMLBuffer := XMLBuffer;
        TempXMLBuffer.SetCurrentKey("Parent Entry No.", Type, "Node Number");
        Header := '<?xml version="1.0" encoding="' + Encoding + '"?>' +
          '<' + TempXMLBuffer.GetElementName + ' ';
        DefaultNamespace := TempXMLBuffer.GetAttributeValue('xmlns');
        if TempXMLBuffer.FindAttributes(TempAttributeXMLBuffer) then
            repeat
                Header += TempAttributeXMLBuffer.Name + '="' + TempAttributeXMLBuffer.Value + '" ';
            until TempAttributeXMLBuffer.Next = 0;
        Header += '/>';

        XMLDOMManagement.LoadXMLDocumentFromText(Header, XmlDocument);
        RootElement := XmlDocument.DocumentElement;

        SaveChildElements(TempXMLBuffer, RootElement, XmlDocument);

        TempBlob.Blob.CreateOutStream(OutStr);
        XmlDocument.Save(OutStr);
    end;

    local procedure SaveChildElements(var TempParentElementXMLBuffer: Record "XML Buffer" temporary; XMLCurrElement: DotNet XmlNode; XmlDocument: DotNet XmlDocument)
    var
        TempElementXMLBuffer: Record "XML Buffer" temporary;
        ChildElement: DotNet XmlNode;
        Namespace: Text;
        ElementValue: Text;
    begin
        if TempParentElementXMLBuffer.FindChildElements(TempElementXMLBuffer) then
            repeat
                if TempElementXMLBuffer.Namespace = '' then
                    Namespace := DefaultNamespace
                else
                    Namespace := TempElementXMLBuffer.Namespace;
                ChildElement := XmlDocument.CreateNode('element', TempElementXMLBuffer.GetElementName, Namespace);
                ElementValue := TempElementXMLBuffer.GetValue;
                if ElementValue <> '' then
                    ChildElement.InnerText := ElementValue;
                XMLCurrElement.AppendChild(ChildElement);
                SaveProcessingInstructions(TempElementXMLBuffer, ChildElement, XmlDocument);
                SaveAttributes(TempElementXMLBuffer, ChildElement, XmlDocument);
                SaveChildElements(TempElementXMLBuffer, ChildElement, XmlDocument);
            until TempElementXMLBuffer.Next = 0;
    end;

    local procedure SaveAttributes(var TempParentElementXMLBuffer: Record "XML Buffer" temporary; XMLCurrElement: DotNet XmlNode; XmlDocument: DotNet XmlDocument)
    var
        TempAttributeXMLBuffer: Record "XML Buffer" temporary;
        Attribute: DotNet XmlAttribute;
    begin
        if TempParentElementXMLBuffer.FindAttributes(TempAttributeXMLBuffer) then
            repeat
                Attribute := XmlDocument.CreateAttribute(TempAttributeXMLBuffer.Name);
                Attribute.InnerText := TempAttributeXMLBuffer.Value;
                XMLCurrElement.Attributes.SetNamedItem(Attribute);
            until TempAttributeXMLBuffer.Next = 0;
    end;

    local procedure SaveProcessingInstructions(var TempParentElementXMLBuffer: Record "XML Buffer" temporary; XMLCurrElement: DotNet XmlNode; XmlDocument: DotNet XmlDocument)
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        ProcessingInstruction: DotNet XmlProcessingInstruction;
    begin
        if TempParentElementXMLBuffer.FindProcessingInstructions(TempXMLBuffer) then
            repeat
                ProcessingInstruction := XmlDocument.CreateProcessingInstruction(TempXMLBuffer.Name, TempXMLBuffer.GetValue);
                XMLCurrElement.AppendChild(ProcessingInstruction);
            until TempXMLBuffer.Next = 0;
    end;
}

