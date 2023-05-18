codeunit 1289 "Imp. Bank List Ext. Data Hndl"
{
    Permissions = TableData "Bank Data Conv. Bank" = rimd,
                  TableData "Bank Data Conv. Service Setup" = r;

    trigger OnRun()
    begin
        GetBankListFromConversionService(true, '', 5000);
    end;

    var
        AddnlInfoTxt: Label 'For more information, go to %1.';
        BankDataConvServMgt: Codeunit "Bank Data Conv. Serv. Mgt.";
        ResponseNodeTxt: Label 'bankListResponse', Locked = true;
        BankDataConvServSysErr: Label 'The bank data conversion service has returned the following error message:';
        ApiVersionTxt: Label 'nav02', Locked = true;

    [Scope('Internal')]
    procedure GetBankListFromConversionService(ShowErrors: Boolean; CountryFilter: Text; Timeout: Integer)
    var
        RequestBodyTempBlob: Record TempBlob;
        BankDataConvServMgt: Codeunit "Bank Data Conv. Serv. Mgt.";
    begin
        RequestBodyTempBlob.Init;

        SendRequestToConversionService(RequestBodyTempBlob, ShowErrors, Timeout, CountryFilter);

        if BankDataConvServMgt.BankDataConvApiVersion = ApiVersionTxt then
            InsertBankData(RequestBodyTempBlob, CountryFilter)
        else
            InsertBankData_APIXX(RequestBodyTempBlob, CountryFilter);
    end;

    local procedure SendRequestToConversionService(var BodyTempBlob: Record TempBlob; EnableUI: Boolean; Timeout: Integer; CountryFilter: Text)
    var
        BankDataConvServiceSetup: Record "Bank Data Conv. Service Setup";
        SOAPWebServiceRequestMgt: Codeunit "SOAP Web Service Request Mgt.";
        ResponseInStream: InStream;
        InStream: InStream;
        ResponseOutStream: OutStream;
    begin
        BankDataConvServMgt.CheckCredentials;

        PrepareSOAPRequestBody(BodyTempBlob, CountryFilter);

        BankDataConvServiceSetup.Get;
        BodyTempBlob.Blob.CreateInStream(InStream);
        SOAPWebServiceRequestMgt.SetGlobals(InStream,
          BankDataConvServiceSetup."Service URL", BankDataConvServiceSetup.GetUserName, BankDataConvServiceSetup.GetPassword);
        SOAPWebServiceRequestMgt.SetTimeout(Timeout);
        if not EnableUI then
            SOAPWebServiceRequestMgt.DisableProgressDialog;

        if SOAPWebServiceRequestMgt.SendRequestToWebService then begin
            SOAPWebServiceRequestMgt.GetResponseContent(ResponseInStream);

            if EnableUI then
                CheckIfErrorsOccurred(ResponseInStream);

            BodyTempBlob.Blob.CreateOutStream(ResponseOutStream);
            CopyStream(ResponseOutStream, ResponseInStream);
        end else
            if EnableUI then
                SOAPWebServiceRequestMgt.ProcessFaultResponse(StrSubstNo(AddnlInfoTxt, BankDataConvServiceSetup."Support URL"));
    end;

    local procedure PrepareSOAPRequestBody(var BodyTempBlob: Record TempBlob; CountryFilter: Text)
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        BodyContentInputStream: InStream;
        BodyContentOutputStream: OutStream;
        BodyContentXmlDoc: DotNet XmlDocument;
        OperationXmlNode: DotNet XmlNode;
        ElementXmlNode: DotNet XmlNode;
    begin
        BodyTempBlob.Blob.CreateInStream(BodyContentInputStream);
        BodyContentXmlDoc := BodyContentXmlDoc.XmlDocument;

        XMLDOMMgt.AddRootElementWithPrefix(BodyContentXmlDoc, 'bankList', '', BankDataConvServMgt.GetNamespace, OperationXmlNode);
        XMLDOMMgt.AddElementWithPrefix(OperationXmlNode, 'compressed', 'true', '', '', ElementXmlNode);
        XMLDOMMgt.AddElementWithPrefix(OperationXmlNode, 'filterbycountry', CountryFilter, '', '', ElementXmlNode);

        Clear(BodyTempBlob.Blob);
        BodyTempBlob.Blob.CreateOutStream(BodyContentOutputStream);
        BodyContentXmlDoc.Save(BodyContentOutputStream);
    end;

    local procedure InsertBankData(ResponseBodyTempBlob: Record TempBlob; CountryFilter: Text)
    var
        BankDataConvBank: Record "Bank Data Conv. Bank";
        XMLDOMMgt: Codeunit "XML DOM Management";
        XMLDocOut: DotNet XmlDocument;
        InStream: InStream;
        XmlNodeList: DotNet XmlNodeList;
        index: Integer;
        XPath: Text;
        Found: Boolean;
    begin
        ResponseBodyTempBlob.Blob.CreateInStream(InStream);
        XMLDOMMgt.LoadXMLDocumentFromInStream(InStream, XMLDocOut);

        XPath := '/amc:bankListResponse/return/pack/bank';

        Found := XMLDOMMgt.FindNodesWithNamespace(XMLDocOut.DocumentElement, XPath, 'amc', BankDataConvServMgt.GetNamespace, XmlNodeList);

        if not Found then
            exit;

        if XmlNodeList.Count > 0 then begin
            if CountryFilter <> '' then
                BankDataConvBank.SetRange("Country/Region Code", CountryFilter);
            BankDataConvBank.DeleteAll;
            for index := 0 to XmlNodeList.Count do
                if not IsNull(XmlNodeList.Item(index)) then begin
                    Clear(BankDataConvBank);
                    BankDataConvBank.Bank := XmlNodeList.Item(index).Attributes.GetNamedItem('bank').Value;
                    BankDataConvBank."Bank Name" := XmlNodeList.Item(index).Attributes.GetNamedItem('bankname').Value;
                    BankDataConvBank."Country/Region Code" := CopyStr(XmlNodeList.Item(index).Attributes.GetNamedItem('countryoforigin').Value,
                        1, 10);
                    BankDataConvBank."Last Update Date" := Today;
                    BankDataConvBank.Insert;
                end;
        end;
    end;

    local procedure InsertBankData_APIXX(ResponseBodyTempBlob: Record TempBlob; CountryFilter: Text)
    var
        BankDataConvBank: Record "Bank Data Conv. Bank";
        XMLDOMMgt: Codeunit "XML DOM Management";
        XMLDocOut: DotNet XmlDocument;
        XmlNodeList: DotNet XmlNodeList;
        ChildNode: DotNet XmlNode;
        InStream: InStream;
        index: Integer;
        XPath: Text;
        Found: Boolean;
        ChildCounter: Integer;
    begin
        ResponseBodyTempBlob.Blob.CreateInStream(InStream);
        XMLDOMMgt.LoadXMLDocumentFromInStream(InStream, XMLDocOut);

        XPath := '/amc:bankListResponse/return/pack/bank';

        Found := XMLDOMMgt.FindNodesWithNamespace(XMLDocOut.DocumentElement, XPath, 'amc', BankDataConvServMgt.GetNamespace, XmlNodeList);

        if not Found then
            exit;

        if XmlNodeList.Count > 0 then begin
            if CountryFilter <> '' then
                BankDataConvBank.SetRange("Country/Region Code", CountryFilter);
            BankDataConvBank.DeleteAll;
            for index := 0 to XmlNodeList.Count do
                if not IsNull(XmlNodeList.Item(index)) then begin
                    Clear(BankDataConvBank);
                    if XmlNodeList.Item(index).HasChildNodes then begin
                        for ChildCounter := 0 to XmlNodeList.Item(index).ChildNodes.Count - 1 do begin
                            ChildNode := XmlNodeList.Item(index).ChildNodes.Item(ChildCounter);
                            if ChildNode.Name = 'bank' then
                                BankDataConvBank.Bank := ChildNode.InnerText
                            else
                                if ChildNode.Name = 'bankname' then
                                    BankDataConvBank."Bank Name" := ChildNode.InnerText
                                else
                                    if ChildNode.Name = 'countryoforigin' then
                                        BankDataConvBank."Country/Region Code" := ChildNode.InnerText;
                            BankDataConvBank."Last Update Date" := Today;
                        end;
                        BankDataConvBank.Insert;
                    end;
                end;
        end;
    end;

    local procedure CheckIfErrorsOccurred(var ResponseInStream: InStream)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        ResponseXmlDoc: DotNet XmlDocument;
    begin
        XMLDOMManagement.LoadXMLDocumentFromInStream(ResponseInStream, ResponseXmlDoc);

        if ResponseHasErrors(ResponseXmlDoc) then
            DisplayErrorFromResponse(ResponseXmlDoc);
    end;

    local procedure ResponseHasErrors(ResponseXmlDoc: DotNet XmlDocument): Boolean
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        XmlNode: DotNet XmlNode;
    begin
        exit(XMLDOMMgt.FindNodeWithNamespace(ResponseXmlDoc.DocumentElement,
            BankDataConvServMgt.GetErrorXPath(ResponseNodeTxt), 'amc', BankDataConvServMgt.GetNamespace, XmlNode));
    end;

    local procedure DisplayErrorFromResponse(ResponseXmlDoc: DotNet XmlDocument)
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        XMLNodeList: DotNet XmlNodeList;
        Found: Boolean;
        ErrorText: Text;
        i: Integer;
    begin
        Found := XMLDOMMgt.FindNodesWithNamespace(ResponseXmlDoc.DocumentElement,
            BankDataConvServMgt.GetErrorXPath(ResponseNodeTxt), 'amc', BankDataConvServMgt.GetNamespace, XMLNodeList);
        if Found then begin
            ErrorText := BankDataConvServSysErr;
            for i := 1 to XMLNodeList.Count do
                ErrorText += '\\' + XMLDOMMgt.FindNodeText(XMLNodeList.Item(i - 1), 'text') + '\' +
                  XMLDOMMgt.FindNodeText(XMLNodeList.Item(i - 1), 'hinttext') + '\\' +
                  StrSubstNo(AddnlInfoTxt, BankDataConvServMgt.GetSupportURL(XMLNodeList.Item(i - 1)));

            Error(ErrorText);
        end;
    end;
}

