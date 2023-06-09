codeunit 6224 "XML DOM Management"
{

    trigger OnRun()
    begin
    end;

    var
        EmptyPrefixErr: Label 'Retrieval of an XML element cannot be done with an empty prefix.';
        SeparatorTxt: Label '/', Locked = true;
        DotDotTxt: Label '..', Locked = true;
        NodePathErr: Label 'Node path cannot be empty.';
        BasePathErr: Label 'Base path cannot be empty.';
        XMLTransformErr: Label 'The XML cannot be transformed.';

    procedure AddElement(var XMLNode: DotNet XmlNode; NodeName: Text; NodeText: Text; NameSpace: Text; var CreatedXMLNode: DotNet XmlNode): Integer
    var
        NewChildNode: DotNet XmlNode;
    begin
        NewChildNode := XMLNode.OwnerDocument.CreateNode('element', NodeName, NameSpace);
        exit(AddElementToNode(XMLNode, NewChildNode, NodeText, CreatedXMLNode));
    end;

    [Scope('Internal')]
    procedure AddRootElement(var XMLDoc: DotNet XmlDocument; NodeName: Text; var CreatedXMLNode: DotNet XmlNode)
    begin
        CreatedXMLNode := XMLDoc.CreateElement(NodeName);
        XMLDoc.AppendChild(CreatedXMLNode);
    end;

    [Scope('Internal')]
    procedure AddRootElementWithPrefix(var XMLDoc: DotNet XmlDocument; NodeName: Text; Prefix: Text; NameSpace: Text; var CreatedXMLNode: DotNet XmlNode)
    begin
        CreatedXMLNode := XMLDoc.CreateElement(Prefix, NodeName, NameSpace);
        XMLDoc.AppendChild(CreatedXMLNode);
    end;

    procedure AddElementWithPrefix(var XMLNode: DotNet XmlNode; NodeName: Text; NodeText: Text; Prefix: Text; NameSpace: Text; var CreatedXMLNode: DotNet XmlNode): Integer
    var
        NewChildNode: DotNet XmlNode;
    begin
        NewChildNode := XMLNode.OwnerDocument.CreateElement(Prefix, NodeName, NameSpace);
        exit(AddElementToNode(XMLNode, NewChildNode, NodeText, CreatedXMLNode));
    end;

    local procedure AddElementToNode(var XMLNode: DotNet XmlNode; var NewChildNode: DotNet XmlNode; NodeText: Text; var CreatedXMLNode: DotNet XmlNode) ExitStatus: Integer
    begin
        if IsNull(NewChildNode) then begin
            ExitStatus := 50;
            exit;
        end;

        if NodeText <> '' then
            NewChildNode.InnerText := NodeText;

        XMLNode.AppendChild(NewChildNode);
        CreatedXMLNode := NewChildNode;

        ExitStatus := 0;
    end;

    procedure AddAttribute(var XMLNode: DotNet XmlNode; Name: Text; NodeValue: Text): Integer
    var
        XMLNewAttributeNode: DotNet XmlNode;
    begin
        XMLNewAttributeNode := XMLNode.OwnerDocument.CreateAttribute(Name);
        exit(AddAttributeToNode(XMLNode, XMLNewAttributeNode, NodeValue));
    end;

    procedure AddAttributeWithPrefix(var XMLNode: DotNet XmlNode; Name: Text; Prefix: Text; NameSpace: Text; NodeValue: Text): Integer
    var
        XMLNewAttributeNode: DotNet XmlNode;
    begin
        XMLNewAttributeNode := XMLNode.OwnerDocument.CreateAttribute(Prefix, Name, NameSpace);
        exit(AddAttributeToNode(XMLNode, XMLNewAttributeNode, NodeValue));
    end;

    local procedure AddAttributeToNode(var XMLNode: DotNet XmlNode; var XMLNewAttributeNode: DotNet XmlNode; NodeValue: Text) ExitStatus: Integer
    begin
        if IsNull(XMLNewAttributeNode) then begin
            ExitStatus := 60;
            exit(ExitStatus)
        end;

        if NodeValue <> '' then
            XMLNewAttributeNode.Value := NodeValue;

        XMLNode.Attributes.SetNamedItem(XMLNewAttributeNode);
    end;

    procedure FindNode(XMLRootNode: DotNet XmlNode; NodePath: Text; var FoundXMLNode: DotNet XmlNode): Boolean
    begin
        if IsNull(XMLRootNode) then
            exit(false);

        FoundXMLNode := XMLRootNode.SelectSingleNode(NodePath);

        if IsNull(FoundXMLNode) then
            exit(false);

        exit(true);
    end;

    procedure FindNodeWithNamespace(XMLRootNode: DotNet XmlNode; NodePath: Text; Prefix: Text; NameSpace: Text; var FoundXMLNode: DotNet XmlNode): Boolean
    var
        XMLNamespaceMgr: DotNet XmlNamespaceManager;
    begin
        if IsNull(XMLRootNode) then
            exit(false);

        XMLNamespaceMgr := XMLNamespaceMgr.XmlNamespaceManager(XMLRootNode.OwnerDocument.NameTable);
        XMLNamespaceMgr.AddNamespace(Prefix, NameSpace);
        FoundXMLNode := XMLRootNode.SelectSingleNode(NodePath, XMLNamespaceMgr);

        if IsNull(FoundXMLNode) then
            exit(false);

        exit(true);
    end;

    procedure FindNodesWithNamespace(XMLRootNode: DotNet XmlNode; XPath: Text; Prefix: Text; NameSpace: Text; var FoundXMLNodeList: DotNet XmlNodeList): Boolean
    var
        XMLNamespaceMgr: DotNet XmlNamespaceManager;
    begin
        XMLNamespaceMgr := XMLNamespaceMgr.XmlNamespaceManager(XMLRootNode.OwnerDocument.NameTable);
        XMLNamespaceMgr.AddNamespace(Prefix, NameSpace);
        exit(FindNodesWithNamespaceManager(XMLRootNode, XPath, XMLNamespaceMgr, FoundXMLNodeList));
    end;

    procedure FindNodesWithNamespaceManager(XMLRootNode: DotNet XmlNode; XPath: Text; XMLNamespaceMgr: DotNet XmlNamespaceManager; var FoundXMLNodeList: DotNet XmlNodeList): Boolean
    begin
        if IsNull(XMLRootNode) then
            exit(false);

        FoundXMLNodeList := XMLRootNode.SelectNodes(XPath, XMLNamespaceMgr);

        if IsNull(FoundXMLNodeList) then
            exit(false);

        if FoundXMLNodeList.Count = 0 then
            exit(false);

        exit(true);
    end;

    procedure FindNodeXML(XMLRootNode: DotNet XmlNode; NodePath: Text): Text
    var
        FoundXMLNode: DotNet XmlNode;
    begin
        if IsNull(XMLRootNode) then
            exit('');

        FoundXMLNode := XMLRootNode.SelectSingleNode(NodePath);

        if IsNull(FoundXMLNode) then
            exit('');

        exit(FoundXMLNode.InnerXml);
    end;

    procedure FindNodeText(XMLRootNode: DotNet XmlNode; NodePath: Text): Text
    var
        FoundXMLNode: DotNet XmlNode;
    begin
        if IsNull(XMLRootNode) then
            exit('');

        FoundXMLNode := XMLRootNode.SelectSingleNode(NodePath);

        if IsNull(FoundXMLNode) then
            exit('');

        exit(FoundXMLNode.InnerText);
    end;

    procedure FindNodeTextWithNamespace(XMLRootNode: DotNet XmlNode; NodePath: Text; Prefix: Text; NameSpace: Text): Text
    var
        XMLNamespaceMgr: DotNet XmlNamespaceManager;
    begin
        if Prefix = '' then
            Error(EmptyPrefixErr);

        if IsNull(XMLRootNode) then
            exit('');

        XMLNamespaceMgr := XMLNamespaceMgr.XmlNamespaceManager(XMLRootNode.OwnerDocument.NameTable);
        XMLNamespaceMgr.AddNamespace(Prefix, NameSpace);

        exit(FindNodeTextNs(XMLRootNode, NodePath, XMLNamespaceMgr));
    end;

    procedure FindNodeTextNs(XMLRootNode: DotNet XmlNode; NodePath: Text; XmlNsMgr: DotNet XmlNamespaceManager): Text
    var
        FoundXMLNode: DotNet XmlNode;
    begin
        FoundXMLNode := XMLRootNode.SelectSingleNode(NodePath, XmlNsMgr);

        if IsNull(FoundXMLNode) then
            exit('');

        exit(FoundXMLNode.InnerText);
    end;

    procedure FindNodes(XMLRootNode: DotNet XmlNode; NodePath: Text; var ReturnedXMLNodeList: DotNet XmlNodeList): Boolean
    begin
        ReturnedXMLNodeList := XMLRootNode.SelectNodes(NodePath);

        if IsNull(ReturnedXMLNodeList) then
            exit(false);

        if ReturnedXMLNodeList.Count = 0 then
            exit(false);

        exit(true);
    end;

    procedure FindAttribute(var XmlNode: DotNet XmlNode; var XmlAttribute: DotNet XmlAttribute; AttributeName: Text): Boolean
    begin
        XmlAttribute := XmlNode.Attributes.GetNamedItem(AttributeName);
        exit(not IsNull(XmlAttribute));
    end;

    procedure GetAttributeValue(xmlNode: DotNet XmlNode; attributeName: Text): Text
    var
        xmlAttribute: DotNet XmlAttribute;
    begin
        xmlAttribute := xmlNode.Attributes.GetNamedItem(attributeName);
        if IsNull(xmlAttribute) then
            exit('');

        exit(xmlAttribute.Value)
    end;

    [Scope('Internal')]
    procedure AddDeclaration(var XMLDoc: DotNet XmlDocument; Version: Text; Encoding: Text; Standalone: Text)
    var
        XMLDeclaration: DotNet XmlDeclaration;
    begin
        XMLDeclaration := XMLDoc.CreateXmlDeclaration(Version, Encoding, Standalone);
        XMLDoc.InsertBefore(XMLDeclaration, XMLDoc.DocumentElement);
    end;

    [Scope('Internal')]
    procedure AddGroupNode(var XMLNode: DotNet XmlNode; NodeName: Text)
    var
        XMLNewChild: DotNet XmlDocument;
    begin
        AddElement(XMLNode, NodeName, '', '', XMLNewChild);
        XMLNode := XMLNewChild;
    end;

    procedure AddNode(var XMLNode: DotNet XmlNode; NodeName: Text; NodeText: Text)
    var
        XMLNewChild: DotNet XmlNode;
    begin
        AddElement(XMLNode, NodeName, NodeText, '', XMLNewChild);
    end;

    procedure AddLastNode(var XMLNode: DotNet XmlNode; NodeName: Text; NodeText: Text)
    var
        XMLNewChild: DotNet XmlNode;
    begin
        AddElement(XMLNode, NodeName, NodeText, '', XMLNewChild);
        XMLNode := XMLNode.ParentNode;
    end;

    [Scope('Internal')]
    procedure AddNamespaces(var XmlNamespaceManager: DotNet XmlNamespaceManager; XmlDocument: DotNet XmlDocument)
    var
        XmlAttributeCollection: DotNet XmlAttributeCollection;
        XmlAttribute: DotNet XmlAttribute;
    begin
        XmlNamespaceManager := XmlNamespaceManager.XmlNamespaceManager(XmlDocument.NameTable);
        XmlAttributeCollection := XmlDocument.DocumentElement.Attributes;

        if XmlDocument.DocumentElement.NamespaceURI <> '' then
            XmlNamespaceManager.AddNamespace('', XmlDocument.DocumentElement.NamespaceURI);

        foreach XmlAttribute in XmlAttributeCollection do
            if StrPos(XmlAttribute.Name, 'xmlns:') = 1 then
                XmlNamespaceManager.AddNamespace(DelStr(XmlAttribute.Name, 1, 6), XmlAttribute.Value);
    end;

    [Scope('Personalization')]
    procedure IsValidXMLNameStartCharacter(InputChar: Char): Boolean
    var
        CharCode: Integer;
    begin
        if IsXMLRestrictedCharacter(InputChar) then
            exit(false);

        // NameStartChar ::= ":" | [A-Z] | "_" | [a-z] | [#xC0-#xD6] | [#xD8-#xF6] | [#xF8-#x2FF] | [#x370-#x37D] | [#x37F-#x1FFF] | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF] | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFF
        if InputChar in [':', '_', 'A' .. 'Z', 'a' .. 'z', 'Ç' .. 'ƒ', 'á' .. 'Ù'] then
            exit(true);

        CharCode := InputChar;
        exit(CharCode in [192 .. 214, 216 .. 246, 248 .. 767, 880 .. 893, 895 .. 8191, 8204 .. 8205,
                          8304 .. 8591, 11264 .. 12271, 12289 .. 55259, 63744 .. 64975, 65008 .. 65533, 65536 .. 983039]);
    end;

    [Scope('Personalization')]
    procedure IsValidXMLNameCharacter(InputChar: Char): Boolean
    var
        CharCode: Integer;
    begin
        // NameChar ::= NameStartChar | "-" | "." | [0-9] | #xB7 | [#x0300-#x036F] | [#x203F-#x2040]
        if IsValidXMLNameStartCharacter(InputChar) then
            exit(true);

        if InputChar in ['-', '.', '0' .. '9'] then
            exit(true);

        CharCode := InputChar;
        exit(CharCode in [183, 768 .. 879, 8255 .. 8256]);
    end;

    [Scope('Personalization')]
    procedure IsXMLRestrictedCharacter(InputChar: Char): Boolean
    var
        CharCode: Integer;
    begin
        // RestrictedChar ::= [#x1-#x8] | [#xB-#xC] | [#xE-#x1F] | [#x7F-#x84] | [#x86-#x9F]
        CharCode := InputChar;
        exit(CharCode in [1 .. 8, 11 .. 12, 14 .. 31, 127 .. 132, 134 .. 159]);
    end;

    [Scope('Internal')]
    procedure XMLEscape(Text: Text): Text
    var
        XMLDocument: DotNet XmlDocument;
        XMLNode: DotNet XmlNode;
    begin
        XMLDocument := XMLDocument.XmlDocument;
        XMLNode := XMLDocument.CreateElement('XMLEscape');

        XMLNode.InnerText(Text);
        exit(XMLNode.InnerXml);
    end;

    [TryFunction]
    [Scope('Internal')]
    procedure LoadXMLDocumentFromText(XmlText: Text; var XmlDocument: DotNet XmlDocument)
    var
        XmlReaderSettings: DotNet XmlReaderSettings;
    begin
        LoadXmlDocFromText(XmlText, XmlDocument, XmlReaderSettings.XmlReaderSettings);
    end;

    [Scope('Internal')]
    procedure LoadXMLNodeFromText(XmlText: Text; var XmlNode: DotNet XmlNode)
    var
        XmlDocument: DotNet XmlDocument;
        XmlReaderSettings: DotNet XmlReaderSettings;
    begin
        LoadXmlDocFromText(XmlText, XmlDocument, XmlReaderSettings.XmlReaderSettings);
        XmlNode := XmlDocument.DocumentElement;
    end;

    [TryFunction]
    [Scope('Internal')]
    procedure LoadXMLDocumentFromInStream(InStream: InStream; var XmlDocument: DotNet XmlDocument)
    begin
        XmlDocument := XmlDocument.XmlDocument;
        XmlDocument.Load(InStream);
    end;

    [TryFunction]
    [Scope('Internal')]
    procedure LoadXMLNodeFromInStream(InStream: InStream; var XmlNode: DotNet XmlNode)
    var
        XmlDocument: DotNet XmlDocument;
    begin
        LoadXMLDocumentFromInStream(InStream, XmlDocument);
        XmlNode := XmlDocument.DocumentElement;
    end;

    [Scope('Internal')]
    procedure LoadXMLDocumentFromOutStream(OutStream: OutStream; var XmlDocument: DotNet XmlDocument)
    begin
        XmlDocument := XmlDocument.XmlDocument;
        XmlDocument.Load(OutStream);
    end;

    [Scope('Internal')]
    procedure LoadXMLDocumentFromFile(FileName: Text; var XmlDocument: DotNet XmlDocument)
    var
        FileManagement: Codeunit "File Management";
        File: DotNet File;
    begin
        FileManagement.IsAllowedPath(FileName, false);
        LoadXMLDocumentFromText(File.ReadAllText(FileName), XmlDocument);
    end;

    [Scope('Internal')]
    procedure LoadXMLDocumentFromFileWithXmlReaderSettings(FileName: Text; var XmlDocument: DotNet XmlDocument; XmlReaderSettings: DotNet XmlReaderSettings)
    var
        File: DotNet File;
        XmlDocumentTypeOld: DotNet XmlDocumentType;
        XmlDocumentTypeNew: DotNet XmlDocumentType;
        DoctypeParams: array[4] of DotNet String;
    begin
        LoadXmlDocFromText(File.ReadAllText(FileName), XmlDocument, XmlReaderSettings);
        XmlDocumentTypeOld := XmlDocument.DocumentType;
        if not IsNull(XmlDocumentTypeOld) then begin
            if XmlDocumentTypeOld.Name <> '' then
                DoctypeParams[1] := XmlDocumentTypeOld.Name;
            if XmlDocumentTypeOld.PublicId <> '' then
                DoctypeParams[2] := XmlDocumentTypeOld.PublicId;
            if XmlDocumentTypeOld.SystemId <> '' then
                DoctypeParams[3] := XmlDocumentTypeOld.SystemId;
            if XmlDocumentTypeOld.InternalSubset <> '' then
                DoctypeParams[4] := XmlDocumentTypeOld.InternalSubset;
            XmlDocumentTypeNew := XmlDocument.CreateDocumentType(DoctypeParams[1], DoctypeParams[2], DoctypeParams[3], DoctypeParams[4]);
            XmlDocument.ReplaceChild(XmlDocumentTypeNew, XmlDocumentTypeOld);
        end;
    end;

    local procedure LoadXmlDocFromText(XmlText: Text; var XmlDocument: DotNet XmlDocument; XmlReaderSettings: DotNet XmlReaderSettings)
    var
        StringReader: DotNet StringReader;
        XmlTextReader: DotNet XmlTextReader0;
    begin
        XmlDocument := XmlDocument.XmlDocument;

        if XmlText = '' then
            exit;

        ClearUTF8BOMSymbols(XmlText);
        StringReader := StringReader.StringReader(XmlText);
        XmlTextReader := XmlTextReader.Create(StringReader, XmlReaderSettings);
        XmlDocument.Load(XmlTextReader);
        XmlTextReader.Close;
        StringReader.Close;
    end;

    [Scope('Internal')]
    procedure LoadXMLDocumentFromUri(Uri: Text; var XmlDocument: DotNet XmlDocument)
    var
        XMLRootNode: DotNet XmlNode;
    begin
        LoadXMLNodeFromUri(Uri, XMLRootNode);
        XmlDocument := XMLRootNode.OwnerDocument;
    end;

    [Scope('Internal')]
    procedure LoadXMLNodeFromUri(Uri: Text; var XMLRootNode: DotNet XmlNode)
    var
        WebClient: DotNet WebClient;
        XmlText: Text;
    begin
        WebClient := WebClient.WebClient;
        XmlText := WebClient.DownloadString(Uri);
        LoadXMLNodeFromText(XmlText, XMLRootNode);
    end;

    local procedure ClearUTF8BOMSymbols(var XmlText: Text)
    var
        UTF8Encoding: DotNet UTF8Encoding;
        ByteOrderMarkUtf8: Text;
    begin
        UTF8Encoding := UTF8Encoding.UTF8Encoding;
        ByteOrderMarkUtf8 := UTF8Encoding.GetString(UTF8Encoding.GetPreamble);
        if StrPos(XmlText, ByteOrderMarkUtf8) = 1 then
            XmlText := DelStr(XmlText, 1, StrLen(ByteOrderMarkUtf8));
    end;

    [TryFunction]
    procedure SaveXMLDocumentToOutStream(var OutStream: OutStream; XMLRootNode: DotNet XmlNode)
    begin
        XMLRootNode.OwnerDocument.Save(OutStream);
    end;

    [Scope('Personalization')]
    procedure GetRelativePath(NodePath: Text; BasePath: Text) result: Text
    var
        RegEx: DotNet Regex;
        BaseParts: DotNet Array;
        NodeParts: DotNet Array;
        commonCount: Integer;
        "part": Integer;
        Done: Boolean;
    begin
        if NodePath = '' then
            Error(NodePathErr);

        if BasePath = '' then
            Error(BasePathErr);

        if LowerCase(NodePath) = LowerCase(BasePath) then
            exit('.');

        NodeParts := RegEx.Split(NodePath, SeparatorTxt);
        BaseParts := RegEx.Split(BasePath, SeparatorTxt);

        // Cut off the common path parts
        while (commonCount < NodeParts.Length) and (commonCount < BaseParts.Length) and not Done do begin
            Done := LowerCase(NodeParts.GetValue(commonCount)) <> LowerCase(BaseParts.GetValue(commonCount));
            if not Done then
                commonCount += 1
        end;

        // Add .. for the way up from Base
        for part := commonCount to BaseParts.Length - 1 do
            result += SeparatorTxt + DotDotTxt;

        // Append the remaining part of the path
        for part := commonCount to NodeParts.Length - 1 do
            result += SeparatorTxt + Format(NodeParts.GetValue(part));

        // Cut off leading separator
        result := CopyStr(result, 2);
    end;

    [Scope('Personalization')]
    procedure ReplaceXMLInvalidCharacters(InputText: Text; ReplaceChar: Char): Text
    var
        Result: Text;
        Index: Integer;
        "Count": Integer;
    begin
        if InputText = '' then
            exit('');

        Result := InputText;
        Count := StrLen(InputText);

        if not IsValidXMLNameStartCharacter(InputText[1]) then
            Result[1] := ReplaceChar;
        for Index := 2 to Count do
            if not IsValidXMLNameCharacter(InputText[Index]) then
                Result[Index] := ReplaceChar;

        exit(Result);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure TryTransformXMLToOutStream(var XmlInStream: InStream; var XslInStream: InStream; var XmlOutStream: OutStream)
    var
        XslCompiledTransform: DotNet XslCompiledTransform;
        XslReader: DotNet XmlReader;
        XmlWriter: DotNet XmlWriter;
        XmlReader: DotNet XmlReader;
        XmlIn: DotNet XmlDocument;
    begin
        XmlIn := XmlIn.XmlDocument;
        XmlIn.PreserveWhitespace(false);

        CreateXMLReaderFromInStream(XmlInStream, XmlReader);
        XmlIn.Load(XmlReader);

        CreateXMLReaderFromInStream(XslInStream, XslReader);
        XslCompiledTransform := XslCompiledTransform.XslCompiledTransform;
        XslCompiledTransform.Load(XslReader);

        XmlWriter := XmlWriter.Create(XmlOutStream);
        XslCompiledTransform.Transform(XmlIn.CreateNavigator, XmlWriter);
        XmlWriter.Flush;

        XmlReader.Close;
        XslReader.Close;
        XmlWriter.Close;
    end;

    [Scope('Personalization')]
    procedure TransformXMLText(XmlInText: Text; XslInText: Text): Text
    var
        TempBlobXmlIn: Record TempBlob temporary;
        TempBlobXsl: Record TempBlob temporary;
        TempBlobXmlOut: Record TempBlob temporary;
        XmlInStream: InStream;
        XslInStream: InStream;
        XmlOutStream: OutStream;
    begin
        TempBlobXmlIn.WriteAsText(XmlInText, TEXTENCODING::UTF8);
        TempBlobXmlIn.Blob.CreateInStream(XmlInStream);

        TempBlobXsl.WriteAsText(XslInText, TEXTENCODING::UTF8);
        TempBlobXsl.Blob.CreateInStream(XslInStream);

        TempBlobXmlOut.Blob.CreateOutStream(XmlOutStream);
        if not TryTransformXMLToOutStream(XmlInStream, XslInStream, XmlOutStream) then
            Error(XMLTransformErr);
        exit(TempBlobXmlOut.GetXMLAsText);
    end;

    local procedure CreateXMLReaderFromInStream(var XmlInStream: InStream; var XmlReader: DotNet XmlReader)
    var
        XmlReaderSettings: DotNet XmlReaderSettings;
        DtdProcessing: DotNet DtdProcessing;
    begin
        XmlReaderSettings := XmlReaderSettings.XmlReaderSettings;
        XmlReaderSettings.DtdProcessing := DtdProcessing.Ignore;
        XmlReader := XmlReader.Create(XmlInStream, XmlReaderSettings);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure TryFormatXML(XMLText: Text; var FormattedXMLText: Text)
    var
        XDocument: DotNet XDocument;
        SystemEnvironment: DotNet Environment;
    begin
        XDocument := XDocument.Parse(XMLText);
        FormattedXMLText :=
          XDocument.Declaration.ToString + SystemEnvironment.NewLine + XDocument.ToString;
    end;

    [Scope('Personalization')]
    procedure RemoveNamespaces(XMLText: Text): Text
    begin
        exit(TransformXMLText(XMLText, GetRemoveNamespacesXSLTText));
    end;

    local procedure GetRemoveNamespacesXSLTText(): Text
    begin
        exit(
          '<?xml version="1.0" encoding="UTF-8"?>' +
          '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">' +
          '<xsl:output method="xml" encoding="UTF-8" />' +
          '<xsl:template match="/">' +
          '<xsl:copy>' +
          '<xsl:apply-templates />' +
          '</xsl:copy>' +
          '</xsl:template>' +
          '<xsl:template match="*">' +
          '<xsl:element name="{local-name()}">' +
          '<xsl:apply-templates select="@* | node()" />' +
          '</xsl:element>' +
          '</xsl:template>' +
          '<xsl:template match="@*">' +
          '<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>' +
          '</xsl:template>' +
          '<xsl:template match="text() | processing-instruction() | comment()">' +
          '<xsl:copy />' +
          '</xsl:template>' +
          '</xsl:stylesheet>');
    end;

    [Scope('Personalization')]
    procedure CreateXslTransformFromBlob(var TempBlob: Record TempBlob; var DotNet_XslCompiledTransform: Codeunit DotNet_XslCompiledTransform)
    var
        DotNet_XmlDocument: Codeunit DotNet_XmlDocument;
        TransformStream: InStream;
    begin
        TempBlob.Blob.CreateInStream(TransformStream);
        DotNet_XslCompiledTransform.XslCompiledTransform;
        DotNet_XmlDocument.InitXmlDocument;
        DotNet_XmlDocument.Load(TransformStream);
        DotNet_XslCompiledTransform.Load(DotNet_XmlDocument);
    end;

    [Scope('Personalization')]
    procedure XslCompiledTransformToBlob(var DotNet_XslCompiledTransform: Codeunit DotNet_XslCompiledTransform; var TempBlob: Record TempBlob; var DestinationStream: OutStream)
    var
        SourceStream: InStream;
    begin
        TempBlob.Blob.CreateInStream(SourceStream);
        XslCompiledTransformToStream(DotNet_XslCompiledTransform, SourceStream, DestinationStream);
    end;

    [Scope('Personalization')]
    procedure XslCompiledTransformToStream(var DotNet_XslCompiledTransform: Codeunit DotNet_XslCompiledTransform; var SourceXmlStream: InStream; var DestinationStream: OutStream)
    var
        DotNet_XmlDocument: Codeunit DotNet_XmlDocument;
        DotNet_XsltArgumentList: Codeunit DotNet_XsltArgumentList;
    begin
        DotNet_XmlDocument.InitXmlDocument;
        DotNet_XmlDocument.Load(SourceXmlStream);
        DotNet_XslCompiledTransform.Transform(DotNet_XmlDocument, DotNet_XsltArgumentList, DestinationStream);
    end;
}

