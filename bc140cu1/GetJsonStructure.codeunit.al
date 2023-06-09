codeunit 1237 "Get Json Structure"
{

    trigger OnRun()
    begin
    end;

    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        JsonConvert: DotNet JsonConvert;
        GLBHttpStatusCode: DotNet HttpStatusCode;
        GLBResponseHeaders: DotNet NameValueCollection;
        FileContent: Text;
        InvalidResponseErr: Label 'The response was not valid.';

    [Scope('Internal')]
    procedure GenerateStructure(Path: Text; var XMLBuffer: Record "XML Buffer")
    var
        TempBlob: Record TempBlob;
        ResponseTempBlob: Record TempBlob;
        XMLBufferWriter: Codeunit "XML Buffer Writer";
        JsonInStream: InStream;
        XMLOutStream: OutStream;
        File: File;
    begin
        if File.Open(Path) then
            File.CreateInStream(JsonInStream)
        else begin
            Clear(ResponseTempBlob);
            ResponseTempBlob.Init;
            ResponseTempBlob.Blob.CreateInStream(JsonInStream);
            Clear(HttpWebRequestMgt);
            HttpWebRequestMgt.Initialize(Path);
            HttpWebRequestMgt.SetMethod('POST');
            HttpWebRequestMgt.SetReturnType('application/json');
            HttpWebRequestMgt.SetContentType('application/x-www-form-urlencoded');
            HttpWebRequestMgt.AddHeader('Accept-Encoding', 'utf-8');
            HttpWebRequestMgt.GetResponse(JsonInStream, GLBHttpStatusCode, GLBResponseHeaders);
        end;

        TempBlob.Init;
        TempBlob.Blob.CreateOutStream(XMLOutStream);
        if not JsonToXML(JsonInStream, XMLOutStream) then
            if not JsonToXMLCreateDefaultRoot(JsonInStream, XMLOutStream) then
                Error(InvalidResponseErr);

        XMLBufferWriter.GenerateStructure(XMLBuffer, XMLOutStream);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure JsonToXML(JsonInStream: InStream; var XMLOutStream: OutStream)
    var
        XmlDocument: DotNet XmlDocument;
        NewContent: Text;
    begin
        while JsonInStream.Read(NewContent) > 0 do
            FileContent += NewContent;

        XmlDocument := JsonConvert.DeserializeXmlNode(FileContent);
        XmlDocument.Save(XMLOutStream);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure JsonToXMLCreateDefaultRoot(JsonInStream: InStream; var XMLOutStream: OutStream)
    var
        XmlDocument: DotNet XmlDocument;
        NewContent: Text;
    begin
        while JsonInStream.Read(NewContent) > 0 do
            FileContent += NewContent;

        FileContent := '{"root":' + FileContent + '}';

        XmlDocument := JsonConvert.DeserializeXmlNode(FileContent, 'root');
        XmlDocument.Save(XMLOutStream);
    end;
}

