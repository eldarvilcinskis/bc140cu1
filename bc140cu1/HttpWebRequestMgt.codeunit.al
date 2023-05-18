codeunit 1297 "Http Web Request Mgt."
{

    trigger OnRun()
    begin
    end;

    var
        HttpWebRequest: DotNet HttpWebRequest;
        TraceLogEnabled: Boolean;
        InvalidUrlErr: Label 'The URL is not valid.';
        NonSecureUrlErr: Label 'The URL is not secure.';
        GlobalSkipCheckHttps: Boolean;
        GlobalProgressDialogEnabled: Boolean;
        InternalErr: Label 'The remote service has returned the following error message:\\';
        NoCookieForYouErr: Label 'The web request has no cookies.';

    [Scope('Internal')]
    procedure InvokeJSONRequest(RequestJson: Text; var ResponseJson: Text; var HttpError: Text) Result: Boolean
    var
        JSONMgt: Codeunit "JSON Management";
        OAuth20Mgt: Codeunit "OAuth 2.0 Mgt.";
    begin
        if JSONMgt.InitializeFromString(RequestJson) then
            if JSONMgt.SelectTokenFromRoot(OAuth20Mgt.GetTestToken) then begin
                OnBeforeInvokeTestJSONRequest(Result, RequestJson, ResponseJson, HttpError);
                exit(Result);
            end;

        ResponseJson := '';
        HttpError := '';

        if ProcessJsonRequestResponse(RequestJson, ResponseJson) then
            exit(true);

        HttpError := ParseFaultJsonResponse(ResponseJson);
        exit(false);
    end;

    [Scope('Internal')]
    procedure GetResponse(var ResponseInStream: InStream; var HttpStatusCode: DotNet HttpStatusCode; var ResponseHeaders: DotNet NameValueCollection): Boolean
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        HttpWebResponse: DotNet HttpWebResponse;
    begin
        exit(WebRequestHelper.GetWebResponse(HttpWebRequest, HttpWebResponse, ResponseInStream, HttpStatusCode,
            ResponseHeaders, GlobalProgressDialogEnabled));
    end;

    [Scope('Internal')]
    procedure GetResponseStream(var ResponseInStream: InStream): Boolean
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        HttpWebResponse: DotNet HttpWebResponse;
        HttpStatusCode: DotNet HttpStatusCode;
        ResponseHeaders: DotNet NameValueCollection;
    begin
        exit(WebRequestHelper.GetWebResponse(HttpWebRequest, HttpWebResponse, ResponseInStream, HttpStatusCode,
            ResponseHeaders, GlobalProgressDialogEnabled));
    end;

    local procedure GetResponseJson(var ResponseJson: Text): Boolean
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        HttpWebResponse: DotNet HttpWebResponse;
        HttpStatusCode: DotNet HttpStatusCode;
        ResponseHeaders: DotNet NameValueCollection;
        ResponseInStream: InStream;
    begin
        ResponseJson := '';
        CreateInstream(ResponseInStream);

        if not WebRequestHelper.GetWebResponse(
             HttpWebRequest, HttpWebResponse, ResponseInStream, HttpStatusCode, ResponseHeaders, GlobalProgressDialogEnabled)
        then
            exit(false);

        SetJSONHeaders(ResponseJson, ResponseHeaders);
        exit(SetJSONContent(ResponseJson, ResponseInStream));
    end;

    [TryFunction]
    [Scope('Internal')]
    procedure ProcessFaultResponse(SupportInfo: Text)
    begin
        ProcessFaultXMLResponse(SupportInfo, '', '', '');
    end;

    [TryFunction]
    [Scope('Internal')]
    procedure ProcessFaultXMLResponse(SupportInfo: Text; NodePath: Text; Prefix: Text; NameSpace: Text)
    var
        TempReturnTempBlob: Record TempBlob temporary;
        WebRequestHelper: Codeunit "Web Request Helper";
        XMLDOMMgt: Codeunit "XML DOM Management";
        WebException: DotNet WebException;
        XmlDoc: DotNet XmlDocument;
        ResponseInputStream: InStream;
        ErrorText: Text;
        ServiceURL: Text;
    begin
        ErrorText := WebRequestHelper.GetWebResponseError(WebException, ServiceURL);

        if not IsNull(WebException.Response) then begin
            ResponseInputStream := WebException.Response.GetResponseStream;

            TraceLogStreamToTempFile(ResponseInputStream, 'WebExceptionResponse', TempReturnTempBlob);

            if NodePath <> '' then
                if TryLoadXMLResponse(ResponseInputStream, XmlDoc) then
                    if Prefix = '' then
                        ErrorText := XMLDOMMgt.FindNodeText(XmlDoc.DocumentElement, NodePath)
                    else
                        ErrorText := XMLDOMMgt.FindNodeTextWithNamespace(XmlDoc.DocumentElement, NodePath, Prefix, NameSpace);
        end;

        if ErrorText = '' then
            ErrorText := WebException.Message;

        ErrorText := InternalErr + ErrorText;

        if SupportInfo <> '' then
            ErrorText += '\\' + SupportInfo;

        Error(ErrorText);
    end;

    local procedure ProcessJsonRequestResponse(RequestJson: Text; var ResponseJson: Text): Boolean
    var
        JSONMgt: Codeunit "JSON Management";
        Content: Text;
    begin
        JSONMgt.InitializeObject(RequestJson);
        Initialize(JSONMgt.GetValue('ServiceURL') + JSONMgt.GetValue('URLRequestPath'));
        SetMethod(JSONMgt.GetValue('Method'));
        GetJSONHeaders(RequestJson);

        Content := JSONMgt.GetValue('Content');
        if Content <> '' then
            AddBodyAsText(Content);

        if GetResponseJson(ResponseJson) then
            exit(true);

        ProcessFaultJsonResponse(ResponseJson);
        exit(false);
    end;

    [TryFunction]
    local procedure ProcessFaultJsonResponse(var ResponseJson: Text)
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        WebException: DotNet WebException;
        ServiceURL: Text;
        HttpError: Text;
    begin
        ResponseJson := '';
        HttpError := WebRequestHelper.GetWebResponseError(WebException, ServiceURL);
        ParseWebResponseError(ResponseJson, WebException);

        if ResponseJson = '' then
            Error(HttpError);
    end;

    local procedure ParseFaultJsonResponse(ResponseJson: Text): Text
    var
        JSONMgt: Codeunit "JSON Management";
        "code": Text;
        name: Text;
        description: Text;
    begin
        if JSONMgt.GetJsonWebResponseError(ResponseJson, code, name, description) then
            exit(StrSubstNo('Http error %1 (%2)\%3', code, name, description));
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure CheckUrl(Url: Text)
    var
        Uri: DotNet Uri;
        UriKind: DotNet UriKind;
    begin
        if not Uri.TryCreate(Url, UriKind.Absolute, Uri) then
            Error(InvalidUrlErr);

        if not GlobalSkipCheckHttps and not (Uri.Scheme = 'https') then
            Error(NonSecureUrlErr);
    end;

    [Scope('Internal')]
    procedure GetUrl(): Text
    begin
        exit(HttpWebRequest.RequestUri.AbsoluteUri);
    end;

    [Scope('Internal')]
    procedure GetUri(): Text
    begin
        exit(HttpWebRequest.RequestUri.PathAndQuery);
    end;

    [Scope('Internal')]
    procedure GetMethod(): Text
    begin
        exit(HttpWebRequest.Method);
    end;

    local procedure TraceLogStreamToTempFile(var ToLogInStream: InStream; Name: Text; var TraceLogTempBlob: Record TempBlob)
    var
        Trace: Codeunit Trace;
    begin
        if TraceLogEnabled then
            Trace.LogStreamToTempFile(ToLogInStream, Name, TraceLogTempBlob);
    end;

    [TryFunction]
    procedure TryLoadXMLResponse(ResponseInputStream: InStream; var XmlDoc: DotNet XmlDocument)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
    begin
        XMLDOMManagement.LoadXMLDocumentFromInStream(ResponseInputStream, XmlDoc);
    end;

    [Scope('Personalization')]
    procedure SetTraceLogEnabled(Enabled: Boolean)
    begin
        TraceLogEnabled := Enabled;
    end;

    [Scope('Personalization')]
    procedure DisableUI()
    begin
        GlobalProgressDialogEnabled := false;
    end;

    [Scope('Internal')]
    procedure Initialize(URL: Text)
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        if not PermissionManager.SoftwareAsAService then
            OnOverrideUrl(URL);

        HttpWebRequest := HttpWebRequest.Create(URL);
        SetDefaults;
    end;

    local procedure SetDefaults()
    var
        CookieContainer: DotNet CookieContainer;
    begin
        HttpWebRequest.Method := 'GET';
        HttpWebRequest.KeepAlive := true;
        HttpWebRequest.AllowAutoRedirect := true;
        HttpWebRequest.UseDefaultCredentials := true;
        HttpWebRequest.Timeout := 60000;
        HttpWebRequest.Accept('application/xml');
        HttpWebRequest.ContentType('application/xml');
        CookieContainer := CookieContainer.CookieContainer;
        HttpWebRequest.CookieContainer := CookieContainer;

        GlobalSkipCheckHttps := true;
        GlobalProgressDialogEnabled := GuiAllowed;
        TraceLogEnabled := true;
    end;

    [Scope('Internal')]
    procedure AddBodyAsText(BodyText: Text)
    var
        Encoding: DotNet Encoding;
    begin
        // Assume UTF8
        AddBodyAsTextWithEncoding(BodyText, Encoding.UTF8);
    end;

    [Scope('Internal')]
    procedure AddBodyAsAsciiText(BodyText: Text)
    var
        Encoding: DotNet Encoding;
    begin
        AddBodyAsTextWithEncoding(BodyText, Encoding.ASCII);
    end;

    local procedure AddBodyAsTextWithEncoding(BodyText: Text; Encoding: DotNet Encoding)
    var
        RequestStr: DotNet Stream;
        StreamWriter: DotNet StreamWriter;
    begin
        RequestStr := HttpWebRequest.GetRequestStream;
        StreamWriter := StreamWriter.StreamWriter(RequestStr, Encoding);
        StreamWriter.Write(BodyText);
        StreamWriter.Flush;
        StreamWriter.Close;
        StreamWriter.Dispose;
    end;

    [Scope('Internal')]
    procedure SetTimeout(NewTimeout: Integer)
    begin
        HttpWebRequest.Timeout := NewTimeout;
    end;

    [Scope('Internal')]
    procedure SetMethod(Method: Text)
    begin
        HttpWebRequest.Method := Method;
    end;

    [Scope('Internal')]
    procedure SetDecompresionMethod(DecompressionMethod: DotNet DecompressionMethods)
    begin
        HttpWebRequest.AutomaticDecompression := DecompressionMethod;
    end;

    [Scope('Internal')]
    procedure SetContentType(ContentType: Text)
    begin
        HttpWebRequest.ContentType := ContentType;
    end;

    [Scope('Internal')]
    procedure SetReturnType(ReturnType: Text)
    begin
        HttpWebRequest.Accept := ReturnType;
    end;

    [Scope('Internal')]
    procedure SetProxy(ProxyUrl: Text)
    var
        WebProxy: DotNet WebProxy;
    begin
        if ProxyUrl = '' then
            exit;

        WebProxy := WebProxy.WebProxy(ProxyUrl);

        HttpWebRequest.Proxy := WebProxy;
    end;

    [Scope('Personalization')]
    procedure SetExpect(expectValue: Boolean)
    begin
        HttpWebRequest.ServicePoint.Expect100Continue := expectValue;
    end;

    [Scope('Internal')]
    procedure SetContentLength(ContentLength: BigInteger)
    begin
        HttpWebRequest.ContentLength := ContentLength;
    end;

    [Scope('Internal')]
    procedure AddSecurityProtocolTls12()
    var
        Convert: DotNet Convert;
        SecurityProtocolType: DotNet SecurityProtocolType;
        SecurityProtocol: Integer;
    begin
        SecurityProtocol := Convert.ToInt32(SecurityProtocolType.Tls12);
        AddSecurityProtocol(SecurityProtocol);
    end;

    local procedure AddSecurityProtocol(SecurityProtocol: Integer)
    var
        TypeHelper: Codeunit "Type Helper";
        Convert: DotNet Convert;
        ServicePointManager: DotNet ServicePointManager;
        CurrentSecurityProtocol: Integer;
    begin
        CurrentSecurityProtocol := Convert.ToInt32(ServicePointManager.SecurityProtocol);
        if TypeHelper.BitwiseAnd(CurrentSecurityProtocol, SecurityProtocol) <> SecurityProtocol then
            ServicePointManager.SecurityProtocol := TypeHelper.BitwiseOr(CurrentSecurityProtocol, SecurityProtocol);
    end;

    [Scope('Internal')]
    procedure AddHeader("Key": Text; Value: Text)
    begin
        case Key of
            'Accept':
                SetReturnType(Value);
            'Content-Type':
                SetContentType(Value);
            else
                HttpWebRequest.Headers.Add(Key, Value);
        end;
    end;

    [Scope('Internal')]
    procedure AddBody(BodyFilePath: Text)
    var
        FileManagement: Codeunit "File Management";
        FileStream: DotNet FileStream;
        FileMode: DotNet FileMode;
    begin
        if BodyFilePath = '' then
            exit;

        FileManagement.IsAllowedPath(BodyFilePath, false);

        FileStream := FileStream.FileStream(BodyFilePath, FileMode.Open);
        FileStream.CopyTo(HttpWebRequest.GetRequestStream);
    end;

    [Scope('Internal')]
    procedure AddBodyBlob(var TempBlob: Record TempBlob)
    var
        RequestStr: DotNet Stream;
        BlobStr: InStream;
    begin
        if not TempBlob.Blob.HasValue then
            exit;

        RequestStr := HttpWebRequest.GetRequestStream;
        TempBlob.Blob.CreateInStream(BlobStr);
        CopyStream(RequestStr, BlobStr);
        RequestStr.Flush;
        RequestStr.Close;
        RequestStr.Dispose;
    end;

    [Scope('Personalization')]
    procedure AddBasicAuthentication(BasicUserId: Text; BasicUserPassword: Text)
    var
        Credential: DotNet NetworkCredential;
    begin
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential;
        Credential.UserName := BasicUserId;
        Credential.Password := BasicUserPassword;
        HttpWebRequest.Credentials := Credential;
    end;

    [Scope('Internal')]
    procedure SetUserAgent(UserAgent: Text)
    begin
        HttpWebRequest.UserAgent := UserAgent;
    end;

    [Scope('Internal')]
    procedure SetCookie(var Cookie: DotNet Cookie)
    begin
        HttpWebRequest.CookieContainer.Add(Cookie);
    end;

    [Scope('Internal')]
    procedure GetCookie(var Cookie: DotNet Cookie)
    var
        CookieCollection: DotNet CookieCollection;
    begin
        if not HasCookie then
            Error(NoCookieForYouErr);
        CookieCollection := HttpWebRequest.CookieContainer.GetCookies(HttpWebRequest.RequestUri);
        Cookie := CookieCollection.Item(0);
    end;

    [Scope('Internal')]
    procedure HasCookie(): Boolean
    begin
        exit(HttpWebRequest.CookieContainer.Count > 0);
    end;

    [Scope('Personalization')]
    procedure CreateInstream(var InStr: InStream)
    var
        TempBlob: Record TempBlob;
    begin
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(InStr);
    end;

    [IntegrationEvent(false, false)]
    procedure OnOverrideUrl(var Url: Text)
    begin
        // Provides an option to rewrite URL in non SaaS environments.
    end;

    [Scope('Internal')]
    procedure SendRequestAndReadTextResponse(var ResponseBody: Text; var ErrorMessage: Text; var ErrorDetails: Text; var HttpStatusCode: DotNet HttpStatusCode; var ResponseHeaders: DotNet NameValueCollection): Boolean
    var
        TempBlob: Record TempBlob temporary;
        ResponseInStream: InStream;
        TextLine: Text;
    begin
        if not SendRequestAndReadResponse(TempBlob, ErrorMessage, ErrorDetails, HttpStatusCode, ResponseHeaders) then
            exit(false);

        TempBlob.Blob.CreateInStream(ResponseInStream);
        while ResponseInStream.ReadText(TextLine) > 0 do
            ResponseBody += TextLine;

        exit(true);
    end;

    [Scope('Internal')]
    procedure SendRequestAndReadResponse(var TempBlob: Record TempBlob; var ErrorMessage: Text; var ErrorDetails: Text; var HttpStatusCode: DotNet HttpStatusCode; var ResponseHeaders: DotNet NameValueCollection): Boolean
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        WebException: DotNet WebException;
        WebExceptionResponse: DotNet HttpWebResponse;
        ResponseInStream: InStream;
        WebExceptionResponseText: Text;
        TextLine: Text;
        ServiceUrl: Text;
    begin
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(ResponseInStream);

        ClearLastError;
        if GetResponse(ResponseInStream, HttpStatusCode, ResponseHeaders) then
            exit(true);

        ErrorMessage := GetLastErrorText;

        WebRequestHelper.GetWebResponseError(WebException, ServiceUrl);
        WebExceptionResponse := WebException.Response;
        if SYSTEM.IsNull(WebExceptionResponse) then
            exit(false);

        HttpStatusCode := WebExceptionResponse.StatusCode;
        ResponseHeaders := WebExceptionResponse.Headers;
        WebExceptionResponse.GetResponseStream.CopyTo(ResponseInStream);
        while ResponseInStream.ReadText(TextLine) > 0 do
            WebExceptionResponseText += TextLine;

        ErrorDetails := WebExceptionResponseText;

        exit(false);
    end;

    local procedure GetJSONHeaders(RequestJson: Text)
    var
        JSONMgt: Codeunit "JSON Management";
        Name: Text;
        Value: Text;
    begin
        JSONMgt.InitializeObject(RequestJson);
        if JSONMgt.SelectTokenFromRoot('Header') then
            if JSONMgt.ReadProperties then
                while JSONMgt.GetNextProperty(Name, Value) do
                    AddHeader(Name, Value);
    end;

    local procedure SetJSONHeaders(var ResponseJson: Text; ResponseHeaders: DotNet NameValueCollection)
    var
        JSONMgt: Codeunit "JSON Management";
        HeaderJson: Text;
        i: Integer;
    begin
        if ResponseHeaders.Count > 0 then begin
            for i := 0 to ResponseHeaders.Count - 1 do
                JSONMgt.SetValue(ResponseHeaders.GetKey(i), ResponseHeaders.Item(i));
            HeaderJson := JSONMgt.WriteObjectToString;
            JSONMgt.InitializeObject(ResponseJson);
            JSONMgt.AddJson('Header', HeaderJson);
            ResponseJson := JSONMgt.WriteObjectToString;
        end;
    end;

    local procedure SetJSONContent(var ResponseJson: Text; ResponseInStream: InStream): Boolean
    var
        JSONMgt: Codeunit "JSON Management";
        ContentJson: Text;
        Content: Text;
    begin
        if ResponseInStream.ReadText(Content) = 0 then
            exit(true);

        if not JSONMgt.InitializeFromString(Content) then
            exit(false);

        ContentJson := JSONMgt.WriteObjectToString;
        JSONMgt.InitializeObject(ResponseJson);
        JSONMgt.AddJson('Content', ContentJson);
        ResponseJson := JSONMgt.WriteObjectToString;
        exit(true);
    end;

    local procedure ParseWebResponseError(var ResponseJson: Text; WebException: DotNet WebException)
    var
        JSONMgt: Codeunit "JSON Management";
        HttpWebResponse: DotNet HttpWebResponse;
        Convert: DotNet Convert;
        ResponseInputStream: InStream;
        ErrorDescription: Text;
    begin
        if IsNull(WebException.Response) then
            exit;
        HttpWebResponse := WebException.Response;

        JSONMgt.SetJsonWebResponseError(
          ResponseJson,
          Format(Convert.ToInt32(HttpWebResponse.StatusCode)),
          HttpWebResponse.StatusCode.ToString,
          HttpWebResponse.StatusDescription);

        // Try to get more details
        ResponseInputStream := HttpWebResponse.GetResponseStream;
        if SetJSONContent(ResponseJson, ResponseInputStream) then
            if JSONMgt.InitializeFromString(ResponseJson) then begin
                ErrorDescription := JSONMgt.GetValue('Content.error_description');
                if ErrorDescription <> '' then begin
                    JSONMgt.SetValue('Error.description', ErrorDescription);
                    ResponseJson := JSONMgt.WriteObjectToString;
                end;
            end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInvokeTestJSONRequest(var Result: Boolean; RequestJson: Text; var ResponseJson: Text; var HttpError: Text)
    begin
    end;
}

