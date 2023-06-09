codeunit 1290 "SOAP Web Service Request Mgt."
{

    trigger OnRun()
    begin
    end;

    var
        BodyPathTxt: Label '/soap:Envelope/soap:Body', Locked = true;
        ContentTypeTxt: Label 'multipart/form-data; charset=utf-8', Locked = true;
        FaultStringXmlPathTxt: Label '/soap:Envelope/soap:Body/soap:Fault/faultstring', Locked = true;
        NoRequestBodyErr: Label 'The request body is not set.';
        NoServiceAddressErr: Label 'The web service URI is not set.';
        ExpectedResponseNotReceivedErr: Label 'The expected data was not received from the web service.';
        SchemaNamespaceTxt: Label 'http://www.w3.org/2001/XMLSchema', Locked = true;
        SchemaInstanceNamespaceTxt: Label 'http://www.w3.org/2001/XMLSchema-instance', Locked = true;
        SecurityUtilityNamespaceTxt: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd', Locked = true;
        SecurityExtensionNamespaceTxt: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', Locked = true;
        SoapNamespaceTxt: Label 'http://schemas.xmlsoap.org/soap/envelope/', Locked = true;
        UsernameTokenNamepsaceTxt: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText', Locked = true;
        TempDebugLogTempBlob: Record TempBlob temporary;
        ResponseBodyTempBlob: Record TempBlob;
        ResponseInStreamTempBlob: Record TempBlob;
        Trace: Codeunit Trace;
        GlobalRequestBodyInStream: InStream;
        HttpWebResponse: DotNet HttpWebResponse;
        GlobalPassword: Text;
        GlobalURL: Text;
        GlobalUsername: Text;
        TraceLogEnabled: Boolean;
        GlobalTimeout: Integer;
        InternalErr: Label 'The remote service has returned the following error message:\\';
        GlobalContentType: Text;
        GlobalSkipCheckHttps: Boolean;
        GlobalProgressDialogEnabled: Boolean;
        InvalidTokenFormatErr: Label 'The token must be in JWS or JWE Compact Serialization Format.';

    [TryFunction]
    [Scope('Internal')]
    procedure SendRequestToWebService()
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        HttpWebRequest: DotNet HttpWebRequest;
        HttpStatusCode: DotNet HttpStatusCode;
        ResponseHeaders: DotNet NameValueCollection;
        ResponseInStream: InStream;
    begin
        CheckGlobals;
        BuildWebRequest(GlobalURL, HttpWebRequest);
        ResponseInStreamTempBlob.Init;
        ResponseInStreamTempBlob.Blob.CreateInStream(ResponseInStream);
        CreateSoapRequest(HttpWebRequest.GetRequestStream, GlobalRequestBodyInStream, GlobalUsername, GlobalPassword);
        WebRequestHelper.GetWebResponse(HttpWebRequest, HttpWebResponse, ResponseInStream,
          HttpStatusCode, ResponseHeaders, GlobalProgressDialogEnabled);
        ExtractContentFromResponse(ResponseInStream, ResponseBodyTempBlob);
    end;

    local procedure BuildWebRequest(ServiceUrl: Text; var HttpWebRequest: DotNet HttpWebRequest)
    var
        DecompressionMethods: DotNet DecompressionMethods;
    begin
        HttpWebRequest := HttpWebRequest.Create(ServiceUrl);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.KeepAlive := true;
        HttpWebRequest.AllowAutoRedirect := true;
        HttpWebRequest.UseDefaultCredentials := true;
        if GlobalContentType = '' then
            GlobalContentType := ContentTypeTxt;
        HttpWebRequest.ContentType := GlobalContentType;
        if GlobalTimeout <= 0 then
            GlobalTimeout := 600000;
        HttpWebRequest.Timeout := GlobalTimeout;
        HttpWebRequest.AutomaticDecompression := DecompressionMethods.GZip;
    end;

    local procedure CreateSoapRequest(RequestOutStream: OutStream; BodyContentInStream: InStream; Username: Text; Password: Text)
    var
        XmlDoc: DotNet XmlDocument;
        BodyXmlNode: DotNet XmlNode;
    begin
        CreateEnvelope(XmlDoc, BodyXmlNode, Username, Password);
        AddBodyToEnvelope(BodyXmlNode, BodyContentInStream);
        XmlDoc.Save(RequestOutStream);
        TraceLogXmlDocToTempFile(XmlDoc, 'FullRequest');
    end;

    local procedure CreateEnvelope(var XmlDoc: DotNet XmlDocument; var BodyXmlNode: DotNet XmlNode; Username: Text; Password: Text)
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        EnvelopeXmlNode: DotNet XmlNode;
        HeaderXmlNode: DotNet XmlNode;
        SecurityXmlNode: DotNet XmlNode;
        UsernameTokenXmlNode: DotNet XmlNode;
        TempXmlNode: DotNet XmlNode;
        PasswordXmlNode: DotNet XmlNode;
    begin
        XmlDoc := XmlDoc.XmlDocument;
        with XMLDOMMgt do begin
            AddRootElementWithPrefix(XmlDoc, 'Envelope', 's', SoapNamespaceTxt, EnvelopeXmlNode);
            AddAttribute(EnvelopeXmlNode, 'xmlns:u', SecurityUtilityNamespaceTxt);

            AddElementWithPrefix(EnvelopeXmlNode, 'Header', '', 's', SoapNamespaceTxt, HeaderXmlNode);

            if (Username <> '') or (Password <> '') then begin
                AddElementWithPrefix(HeaderXmlNode, 'Security', '', 'o', SecurityExtensionNamespaceTxt, SecurityXmlNode);
                AddAttributeWithPrefix(SecurityXmlNode, 'mustUnderstand', 's', SoapNamespaceTxt, '1');

                AddElementWithPrefix(SecurityXmlNode, 'UsernameToken', '', 'o', SecurityExtensionNamespaceTxt, UsernameTokenXmlNode);
                AddAttributeWithPrefix(UsernameTokenXmlNode, 'Id', 'u', SecurityUtilityNamespaceTxt, CreateUUID);

                AddElementWithPrefix(UsernameTokenXmlNode, 'Username', Username, 'o', SecurityExtensionNamespaceTxt, TempXmlNode);
                AddElementWithPrefix(UsernameTokenXmlNode, 'Password', Password, 'o', SecurityExtensionNamespaceTxt, PasswordXmlNode);
                AddAttribute(PasswordXmlNode, 'Type', UsernameTokenNamepsaceTxt);
            end;

            AddElementWithPrefix(EnvelopeXmlNode, 'Body', '', 's', SoapNamespaceTxt, BodyXmlNode);
            AddAttribute(BodyXmlNode, 'xmlns:xsi', SchemaInstanceNamespaceTxt);
            AddAttribute(BodyXmlNode, 'xmlns:xsd', SchemaNamespaceTxt);
        end;
    end;

    local procedure CreateUUID(): Text
    begin
        exit('uuid-' + DelChr(LowerCase(Format(CreateGuid)), '=', '{}'));
    end;

    local procedure AddBodyToEnvelope(var BodyXmlNode: DotNet XmlNode; BodyInStream: InStream)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        BodyContentXmlDoc: DotNet XmlDocument;
    begin
        XMLDOMManagement.LoadXMLDocumentFromInStream(BodyInStream, BodyContentXmlDoc);
        TraceLogXmlDocToTempFile(BodyContentXmlDoc, 'RequestBodyContent');

        BodyXmlNode.AppendChild(BodyXmlNode.OwnerDocument.ImportNode(BodyContentXmlDoc.DocumentElement, true));
    end;

    local procedure ExtractContentFromResponse(ResponseInStream: InStream; var BodyTempBlob: Record TempBlob)
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        ResponseBodyXMLDoc: DotNet XmlDocument;
        ResponseBodyXmlNode: DotNet XmlNode;
        XmlNode: DotNet XmlNode;
        BodyOutStream: OutStream;
        Found: Boolean;
    begin
        TraceLogStreamToTempFile(ResponseInStream, 'FullResponse', TempDebugLogTempBlob);
        XMLDOMMgt.LoadXMLNodeFromInStream(ResponseInStream, XmlNode);

        Found := XMLDOMMgt.FindNodeWithNamespace(XmlNode, BodyPathTxt, 'soap', SoapNamespaceTxt, ResponseBodyXmlNode);
        if not Found then
            Error(ExpectedResponseNotReceivedErr);

        ResponseBodyXMLDoc := ResponseBodyXMLDoc.XmlDocument;
        ResponseBodyXMLDoc.AppendChild(ResponseBodyXMLDoc.ImportNode(ResponseBodyXmlNode.FirstChild, true));

        BodyTempBlob.Blob.CreateOutStream(BodyOutStream);
        ResponseBodyXMLDoc.Save(BodyOutStream);
        TraceLogXmlDocToTempFile(ResponseBodyXMLDoc, 'ResponseBodyContent');
    end;

    procedure GetResponseContent(var ResponseBodyInStream: InStream)
    begin
        ResponseBodyTempBlob.Blob.CreateInStream(ResponseBodyInStream);
    end;

    [Scope('Internal')]
    procedure ProcessFaultResponse(SupportInfo: Text)
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        XMLDOMMgt: Codeunit "XML DOM Management";
        WebException: DotNet WebException;
        XmlNode: DotNet XmlNode;
        ResponseInputStream: InStream;
        ErrorText: Text;
        ServiceURL: Text;
    begin
        ErrorText := WebRequestHelper.GetWebResponseError(WebException, ServiceURL);

        if ErrorText <> '' then
            Error(ErrorText);

        ResponseInputStream := WebException.Response.GetResponseStream;
        if TraceLogEnabled then
            Trace.LogStreamToTempFile(ResponseInputStream, 'WebExceptionResponse', TempDebugLogTempBlob);

        XMLDOMMgt.LoadXMLNodeFromInStream(ResponseInputStream, XmlNode);

        ErrorText := XMLDOMMgt.FindNodeTextWithNamespace(XmlNode, FaultStringXmlPathTxt, 'soap', SoapNamespaceTxt);
        if ErrorText = '' then
            ErrorText := WebException.Message;
        ErrorText := InternalErr + ErrorText + ServiceURL;

        if SupportInfo <> '' then
            ErrorText += '\\' + SupportInfo;

        Error(ErrorText);
    end;

    [Scope('Personalization')]
    procedure SetGlobals(RequestBodyInStream: InStream; URL: Text; Username: Text; Password: Text)
    begin
        GlobalRequestBodyInStream := RequestBodyInStream;

        GlobalSkipCheckHttps := false;

        GlobalURL := URL;
        GlobalUsername := Username;
        GlobalPassword := Password;

        GlobalProgressDialogEnabled := true;

        TraceLogEnabled := false;
    end;

    [Scope('Personalization')]
    procedure SetTimeout(NewTimeout: Integer)
    begin
        GlobalTimeout := NewTimeout;
    end;

    [Scope('Personalization')]
    procedure SetContentType(NewContentType: Text)
    begin
        GlobalContentType := NewContentType;
    end;

    local procedure CheckGlobals()
    var
        WebRequestHelper: Codeunit "Web Request Helper";
    begin
        if GlobalRequestBodyInStream.EOS then
            Error(NoRequestBodyErr);

        if GlobalURL = '' then
            Error(NoServiceAddressErr);

        if GlobalSkipCheckHttps then
            WebRequestHelper.IsValidUri(GlobalURL)
        else
            WebRequestHelper.IsSecureHttpUrl(GlobalURL);
    end;

    local procedure TraceLogStreamToTempFile(var ToLogInStream: InStream; Name: Text; var TraceLogTempBlob: Record TempBlob)
    begin
        if TraceLogEnabled then
            Trace.LogStreamToTempFile(ToLogInStream, Name, TraceLogTempBlob);
    end;

    local procedure TraceLogXmlDocToTempFile(var XmlDoc: DotNet XmlDocument; Name: Text)
    begin
        if TraceLogEnabled then
            Trace.LogXmlDocToTempFile(XmlDoc, Name);
    end;

    [Scope('Personalization')]
    procedure SetTraceMode(NewTraceMode: Boolean)
    begin
        TraceLogEnabled := NewTraceMode;
    end;

    [Scope('Personalization')]
    procedure DisableHttpsCheck()
    begin
        GlobalSkipCheckHttps := true;
    end;

    [Scope('Personalization')]
    procedure DisableProgressDialog()
    begin
        GlobalProgressDialogEnabled := false;
    end;

    [Scope('Personalization')]
    procedure HasJWTExpired(JsonWebToken: Text): Boolean
    var
        WebTokenAsJson: Text;
    begin
        if JsonWebToken = '' then
            exit(true);
        if not GetTokenDetailsAsJson(JsonWebToken, WebTokenAsJson) then
            Error(InvalidTokenFormatErr);
        exit(GetTokenDateTimeValue(WebTokenAsJson, 'exp') < CurrentDateTime);
    end;

    [Scope('Personalization')]
    procedure GetTokenValue(WebTokenAsJson: Text; ClaimType: Text): Text
    var
        JSONManagement: Codeunit "JSON Management";
        JObject: DotNet JObject;
        ClaimValue: Text;
    begin
        JSONManagement.InitializeObject(WebTokenAsJson);
        JSONManagement.GetJSONObject(JObject);
        if JSONManagement.GetStringPropertyValueFromJObjectByName(JObject, ClaimType, ClaimValue) then
            exit(ClaimValue);
    end;

    [Scope('Personalization')]
    procedure GetTokenDateTimeValue(WebTokenAsJson: Text; ClaimType: Text): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
        Timestamp: Decimal;
    begin
        if not Evaluate(Timestamp, GetTokenValue(WebTokenAsJson, ClaimType)) then
            exit;
        exit(TypeHelper.EvaluateUnixTimestamp(Timestamp));
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure GetTokenDetailsAsJson(JsonWebToken: Text; var WebTokenAsJson: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        JwtSecurityTokenHandler: DotNet JwtSecurityTokenHandler;
        JwtSecurityToken: DotNet JwtSecurityToken;
        Claim: DotNet Claim;
        JObject: DotNet JObject;
    begin
        if JsonWebToken = '' then
            exit;

        JwtSecurityTokenHandler := JwtSecurityTokenHandler.JwtSecurityTokenHandler;
        JwtSecurityToken := JwtSecurityTokenHandler.ReadToken(JsonWebToken);

        JSONManagement.InitializeEmptyObject;
        JSONManagement.GetJSONObject(JObject);
        foreach Claim in JwtSecurityToken.Claims do
            JSONManagement.AddJPropertyToJObject(JObject, Claim.Type, Claim.Value);

        WebTokenAsJson := JObject.ToString;
    end;
}

