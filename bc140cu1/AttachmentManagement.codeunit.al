codeunit 5052 "AttachmentManagement"
{

    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Send attachments...\\';
        Text001: Label 'Preparing';
        Text002: Label 'Deliver misc.';
        Text008: Label 'You must select an interaction template with an attachment.';
        AttachmentTok: Label 'Attachment';

    [Scope('Internal')]
    procedure InsertAttachment(AttachmentNo: Integer): Integer
    var
        Attachment: Record Attachment;
        Attachment3: Record Attachment;
    begin
        if AttachmentNo <> 0 then begin
            Attachment.Get(AttachmentNo);
            if Attachment."Storage Type" = Attachment."Storage Type"::Embedded then
                Attachment.CalcFields("Attachment File");
            Attachment3 := Attachment; // Remember "from" attachment
        end;

        Attachment.Insert(true);

        if AttachmentNo <> 0 then
            // New attachment is based on old attachment
            TransferAttachment(Attachment3, Attachment); // Transfer attachments of different types.

        exit(Attachment."No.");
    end;

    [Scope('Internal')]
    procedure Send(var DeliverySorter: Record "Delivery Sorter")
    var
        TempDeliverySorterHtml: Record "Delivery Sorter" temporary;
        TempDeliverySorterWord: Record "Delivery Sorter" temporary;
        TempDeliverySorterOther: Record "Delivery Sorter" temporary;
        InteractLogEntry: Record "Interaction Log Entry";
        WordManagement: Codeunit WordManagement;
    begin
        ProcessDeliverySorter(DeliverySorter, TempDeliverySorterHtml, TempDeliverySorterWord, TempDeliverySorterOther);

        if TempDeliverySorterWord.FindFirst then
            WordManagement.Merge(TempDeliverySorterWord);

        if TempDeliverySorterHtml.FindFirst then
            DeliverHTMLEmail(TempDeliverySorterHtml, InteractLogEntry);

        if TempDeliverySorterOther.FindFirst then
            DeliverEmailWithAttachment(TempDeliverySorterOther, InteractLogEntry);
    end;

    [Scope('Internal')]
    procedure SendUsingExchange(var DeliverySorter: Record "Delivery Sorter")
    var
        TempDeliverySorterHtml: Record "Delivery Sorter" temporary;
        TempDeliverySorterWord: Record "Delivery Sorter" temporary;
        TempDeliverySorterOther: Record "Delivery Sorter" temporary;
        InteractLogEntry: Record "Interaction Log Entry";
        WordManagement: Codeunit WordManagement;
        ExchangeWebServicesServer: Codeunit "Exchange Web Services Server";
    begin
        ProcessDeliverySorter(DeliverySorter, TempDeliverySorterHtml, TempDeliverySorterWord, TempDeliverySorterOther);

        if TempDeliverySorterWord.FindFirst then
            WordManagement.Merge(TempDeliverySorterWord);

        InitializeExchange(ExchangeWebServicesServer);
        if TempDeliverySorterHtml.FindFirst then
            DeliverHTMLEmailViaExchange(ExchangeWebServicesServer, TempDeliverySorterHtml, InteractLogEntry);

        if TempDeliverySorterOther.FindFirst then
            DeliverEmailWithAttachmentViaExchange(ExchangeWebServicesServer, TempDeliverySorterOther, InteractLogEntry);
    end;

    local procedure TransferAttachment(FromAttachment: Record Attachment; var ToAttachment: Record Attachment)
    var
        RMSetup: Record "Marketing Setup";
        FileName: Text;
    begin
        // Transfer attachments of different types

        if (FromAttachment."Storage Type" = FromAttachment."Storage Type"::Embedded) and
           (ToAttachment."Storage Type" = ToAttachment."Storage Type"::"Disk File")
        then begin
            FileName := ToAttachment.ConstDiskFileName;
            FromAttachment.ExportAttachmentToServerFile(FileName); // Export blob to UNC location
            with ToAttachment do begin
                Clear("Attachment File");
                RMSetup.Get;
                RMSetup.TestField("Attachment Storage Location");
                "Storage Pointer" := RMSetup."Attachment Storage Location";
                Modify;
            end;
        end;

        if (FromAttachment."Storage Type" = FromAttachment."Storage Type"::"Disk File") and
           (ToAttachment."Storage Type" = ToAttachment."Storage Type"::"Disk File")
        then begin
            // Copy external attachment (to new storage)
            RMSetup.Get;
            RMSetup.TestField("Attachment Storage Location");
            ToAttachment."Storage Pointer" := RMSetup."Attachment Storage Location";
            ToAttachment.Modify;
            FILE.Copy(FromAttachment.ConstDiskFileName, ToAttachment.ConstDiskFileName);
        end;

        if (FromAttachment."Storage Type" = FromAttachment."Storage Type"::"Disk File") and
           (ToAttachment."Storage Type" = ToAttachment."Storage Type"::Embedded)
        then
            // Transfer External to Embedded attachment
            with ToAttachment do begin
                ImportAttachmentFromServerFile(FromAttachment.ConstDiskFileName, true, false); // Import file from UNC location
                "File Extension" := FromAttachment."File Extension";
                "Storage Pointer" := '';
                Modify;
            end;
    end;

    [Scope('Personalization')]
    procedure InteractionEMail(var InteractLogEntry: Record "Interaction Log Entry"): Text[80]
    var
        Cont: Record Contact;
        ContAltAddr: Record "Contact Alt. Address";
    begin
        if InteractLogEntry."Contact Alt. Address Code" = '' then begin
            Cont.Get(InteractLogEntry."Contact No.");
            exit(Cont."E-Mail");
        end;
        ContAltAddr.Get(InteractLogEntry."Contact No.", InteractLogEntry."Contact Alt. Address Code");
        if ContAltAddr."E-Mail" <> '' then
            exit(ContAltAddr."E-Mail");

        Cont.Get(InteractLogEntry."Contact No.");
        exit(Cont."E-Mail");
    end;

    [Scope('Personalization')]
    procedure InteractionFax(var InteractLogEntry: Record "Interaction Log Entry"): Text[30]
    var
        Cont: Record Contact;
        ContAltAddr: Record "Contact Alt. Address";
    begin
        if InteractLogEntry."Contact Alt. Address Code" = '' then begin
            Cont.Get(InteractLogEntry."Contact No.");
            exit(Cont."Fax No.");
        end;
        ContAltAddr.Get(InteractLogEntry."Contact No.", InteractLogEntry."Contact Alt. Address Code");
        if ContAltAddr."Fax No." <> '' then
            exit(ContAltAddr."Fax No.");

        Cont.Get(InteractLogEntry."Contact No.");
        exit(Cont."Fax No.");
    end;

    [Scope('Internal')]
    procedure GenerateHTMLContent(var Attachment: Record Attachment; SegmentLine: Record "Segment Line"): Boolean
    begin
        if not Attachment.IsHTML then
            exit(false);

        if Attachment.IsHTMLReady then
            exit(true);

        exit(GenerateHTMLReadyAttachmentFromCustomLayout(Attachment, SegmentLine));
    end;

    [Scope('Internal')]
    procedure LoadHTMLContent(var Attachment: Record Attachment; SegmentLine: Record "Segment Line"): Text
    begin
        if not Attachment.IsHTML then
            exit('');

        if Attachment.IsHTMLReady then
            exit(Attachment.Read);

        exit(LoadHTMLContentFromCustomLayoutAttachment(Attachment, SegmentLine));
    end;

    local procedure LoadHTMLContentFromCustomLayoutAttachment(var Attachment: Record Attachment; SegmentLine: Record "Segment Line") Result: Text
    var
        TempAttachment: Record Attachment temporary;
        FileName: Text;
    begin
        Result := '';
        FileName := GenerateHTMLReadyContentFromCustomLayoutAttachment(Attachment, SegmentLine);
        if FileName = '' then
            exit;

        TempAttachment.Init;
        TempAttachment.ImportAttachmentFromServerFile(FileName, true, true);
        TempAttachment."No." := 0;
        TempAttachment.Insert;
        Result := TempAttachment.Read;
        TempAttachment.RemoveAttachment(false);
    end;

    local procedure GenerateHTMLReadyAttachmentFromCustomLayout(var Attachment: Record Attachment; SegmentLine: Record "Segment Line"): Boolean
    var
        FileName: Text;
    begin
        FileName := GenerateHTMLReadyContentFromCustomLayoutAttachment(Attachment, SegmentLine);
        if FileName = '' then
            exit(false);

        Attachment.Delete;
        Attachment.Init;
        Attachment.ImportAttachmentFromServerFile(FileName, true, true);
        Attachment."No." := 0;
        Attachment.Insert;

        exit(true);
    end;

    local procedure GenerateHTMLReadyContentFromCustomLayoutAttachment(var Attachment: Record Attachment; SegmentLine: Record "Segment Line") FileName: Text
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        EmailMerge: Report "Email Merge";
        FileMgt: Codeunit "File Management";
        ContentBodyText: Text;
        CustomLayoutNo: Code[20];
    begin
        Clear(EmailMerge);
        FileName := FileMgt.ServerTempFileName('html');
        if FileName = '' then
            exit;

        Attachment.ReadHTMLCustomLayoutAttachment(ContentBodyText, CustomLayoutNo);
        ReportLayoutSelection.SetTempLayoutSelected(CustomLayoutNo);
        EmailMerge.InitializeRequest(SegmentLine, ContentBodyText);
        EmailMerge.SaveAsHtml(FileName);
        ReportLayoutSelection.SetTempLayoutSelected('');
    end;

    local procedure InitializeExchange(var ExchangeWebServicesServer: Codeunit "Exchange Web Services Server")
    var
        User: Record User;
    begin
        Commit;
        User.SetRange("User Name", UserId);
        if not User.FindFirst and not InitializeExchangeWithToken(ExchangeWebServicesServer, User."Authentication Email") then
            if not InitializeExchangeWithCredentials(ExchangeWebServicesServer) then
                Error('');
    end;

    [TryFunction]
    local procedure InitializeExchangeWithCredentials(var ExchangeWebServicesServer: Codeunit "Exchange Web Services Server")
    var
        TempOfficeAdminCredentials: Record "Office Admin. Credentials" temporary;
        WebCredentials: DotNet WebCredentials;
        WebCredentialsLogin: Text[250];
    begin
        TempOfficeAdminCredentials.Init;
        TempOfficeAdminCredentials.Insert;
        Commit;
        ClearLastError;
        if PAGE.RunModal(PAGE::"Office 365 Credentials", TempOfficeAdminCredentials) <> ACTION::LookupOK then
            Error('');
        WebCredentialsLogin := TempOfficeAdminCredentials.Email;
        WebCredentials := WebCredentials.WebCredentials(WebCredentialsLogin, TempOfficeAdminCredentials.GetPassword);
        TempOfficeAdminCredentials.Delete;
        ExchangeWebServicesServer.Initialize(
          WebCredentialsLogin, ExchangeWebServicesServer.ProdEndpoint, WebCredentials, false);
    end;

    [TryFunction]
    local procedure InitializeExchangeWithToken(var ExchangeWebServicesServer: Codeunit "Exchange Web Services Server"; AuthenticationEmail: Text[250])
    var
        ExchangeServiceSetup: Record "Exchange Service Setup";
        AzureADMgt: Codeunit "Azure AD Mgt.";
        AccessToken: Text;
    begin
        AccessToken := AzureADMgt.GetAccessToken(AzureADMgt.GetO365Resource, AzureADMgt.GetO365ResourceName, false);

        if AccessToken <> '' then begin
            ExchangeWebServicesServer.InitializeWithOAuthToken(AccessToken, ExchangeWebServicesServer.GetEndpoint);
            exit;
        end;

        ExchangeServiceSetup.Get;

        ExchangeWebServicesServer.InitializeWithCertificate(
          ExchangeServiceSetup."Azure AD App. ID", ExchangeServiceSetup."Azure AD App. Cert. Thumbprint",
          ExchangeServiceSetup."Azure AD Auth. Endpoint", ExchangeServiceSetup."Exchange Service Endpoint",
          ExchangeServiceSetup."Exchange Resource Uri");

        ExchangeWebServicesServer.SetImpersonatedIdentity(AuthenticationEmail);
    end;

    local procedure GetSenderSalesPersonEmail(var InteractLogEntry: Record "Interaction Log Entry"): Text
    var
        SalesPersonPurchaser: Record "Salesperson/Purchaser";
    begin
        SalesPersonPurchaser.Get(InteractLogEntry."Salesperson Code");
        exit(SalesPersonPurchaser."E-Mail");
    end;

    local procedure DeliverHTMLEmail(var TempDeliverySorterHtml: Record "Delivery Sorter" temporary; var InteractLogEntry: Record "Interaction Log Entry")
    var
        Attachment: Record Attachment;
        FileMgt: Codeunit "File Management";
        EmailBodyFilePath: Text;
    begin
        InteractLogEntry.LockTable;
        repeat
            InteractLogEntry.Get(TempDeliverySorterHtml."No.");

            if TempDeliverySorterHtml."Correspondence Type" = TempDeliverySorterHtml."Correspondence Type"::Email then begin
                GetAttachment(Attachment, TempDeliverySorterHtml."Attachment No.", false);
                EmailBodyFilePath := FileMgt.ServerTempFileName('HTML');
                Attachment.ExportAttachmentToServerFile(EmailBodyFilePath);

                Commit;
                SendHTMLEmail(
                  TempDeliverySorterHtml, InteractLogEntry, EmailBodyFilePath);
                // Clean up
                FileMgt.DeleteServerFile(EmailBodyFilePath)
            end else
                SetDeliveryState(InteractLogEntry, false);
        until TempDeliverySorterHtml.Next = 0;
    end;

    local procedure DeliverHTMLEmailViaExchange(var ExchangeWebServicesServer: Codeunit "Exchange Web Services Server"; var TempDeliverySorterHtml: Record "Delivery Sorter" temporary; var InteractLogEntry: Record "Interaction Log Entry")
    var
        Attachment: Record Attachment;
        FileMgt: Codeunit "File Management";
        EmailBodyFilePath: Text;
    begin
        InteractLogEntry.LockTable;
        repeat
            InteractLogEntry.Get(TempDeliverySorterHtml."No.");

            if TempDeliverySorterHtml."Correspondence Type" = TempDeliverySorterHtml."Correspondence Type"::Email then begin
                GetAttachment(Attachment, TempDeliverySorterHtml."Attachment No.", false);
                EmailBodyFilePath := FileMgt.ServerTempFileName('HTML');
                Attachment.ExportAttachmentToServerFile(EmailBodyFilePath);

                Commit;
                SendHTMLEmailViaExchange(
                  ExchangeWebServicesServer, TempDeliverySorterHtml, InteractLogEntry, Attachment);
                // Clean up
                FileMgt.DeleteServerFile(EmailBodyFilePath)
            end else
                SetDeliveryState(InteractLogEntry, false);
        until TempDeliverySorterHtml.Next = 0;
    end;

    local procedure DeliverEmailWithAttachment(var TempDeliverySorterOther: Record "Delivery Sorter" temporary; var InteractLogEntry: Record "Interaction Log Entry")
    var
        FileMgt: Codeunit "File Management";
        AttachmentFileFullName: Text;
        EmailBodyFilePath: Text;
    begin
        repeat
            InteractLogEntry.LockTable;
            InteractLogEntry.Get(TempDeliverySorterOther."No.");
            if TempDeliverySorterOther."Correspondence Type" = TempDeliverySorterOther."Correspondence Type"::Email then begin
                // Export the attachment to the client TEMP directory, giving it a GUID
                AttachmentFileFullName := PrepareServerAttachment(TempDeliverySorterOther."Attachment No.");
                EmailBodyFilePath := PrepareDummyEmailBody;

                Commit;
                SendEmailWithAttachment(
                  TempDeliverySorterOther, InteractLogEntry, AttachmentFileFullName, EmailBodyFilePath);
                // Clean up
                FileMgt.DeleteServerFile(AttachmentFileFullName);
                FileMgt.DeleteServerFile(EmailBodyFilePath);
            end else
                SetDeliveryState(InteractLogEntry, false);
        until TempDeliverySorterOther.Next = 0;
    end;

    local procedure DeliverEmailWithAttachmentViaExchange(var ExchangeWebServicesServer: Codeunit "Exchange Web Services Server"; var TempDeliverySorterOther: Record "Delivery Sorter" temporary; var InteractLogEntry: Record "Interaction Log Entry")
    var
        Contact: Record Contact;
        FileMgt: Codeunit "File Management";
        Window: Dialog;
        I: Integer;
        NoOfAttachments: Integer;
        AttachmentFileFullName: Text;
    begin
        Window.Open(
          Text000 +
          '#1############ @2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\' +
          '#3############ @4@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');

        Window.Update(1, Text001);
        Window.Update(2, 10000);
        Window.Update(3, Text002);
        I := 0;
        NoOfAttachments := TempDeliverySorterOther.Count;
        repeat
            InteractLogEntry.LockTable;
            InteractLogEntry.Get(TempDeliverySorterOther."No.");
            if TempDeliverySorterOther."Correspondence Type" = TempDeliverySorterOther."Correspondence Type"::Email then begin
                // Export the attachment to the server TEMP directory, giving it a GUID
                AttachmentFileFullName := PrepareServerAttachment(
                    TempDeliverySorterOther."Attachment No.");

                // Send the mail
                Contact.Get(InteractLogEntry."Contact No.");
                SendEmailWithAttachmentViaExchange(
                  ExchangeWebServicesServer, TempDeliverySorterOther, InteractLogEntry, AttachmentFileFullName);
                // Clean up
                FileMgt.DeleteServerFile(AttachmentFileFullName);
            end else
                SetDeliveryState(InteractLogEntry, false);
            I := I + 1;
            Window.Update(4, Round(I / NoOfAttachments * 10000, 1));
        until TempDeliverySorterOther.Next = 0;
        Window.Close;
    end;

    local procedure SendHTMLEmail(var TempDeliverySorterHtml: Record "Delivery Sorter" temporary; var InteractLogEntry: Record "Interaction Log Entry"; EmailBodyFilePath: Text)
    var
        DocumentMailing: Codeunit "Document-Mailing";
        IsSent: Boolean;
    begin
        IsSent :=
          DocumentMailing.EmailFileWithSubject(
            '', '', EmailBodyFilePath,
            TempDeliverySorterHtml.Subject, InteractionEMail(InteractLogEntry), false);

        SetDeliveryState(InteractLogEntry, IsSent);
    end;

    local procedure SendHTMLEmailViaExchange(var ExchangeWebServicesServer: Codeunit "Exchange Web Services Server"; var TempDeliverySorterHtml: Record "Delivery Sorter" temporary; var InteractLogEntry: Record "Interaction Log Entry"; Attachment: Record Attachment)
    var
        IsSent: Boolean;
    begin
        IsSent :=
          ExchangeWebServicesServer.SendEmailMessageWithAttachment(
            TempDeliverySorterHtml.Subject, InteractionEMail(InteractLogEntry),
            Attachment.Read, '', GetSenderSalesPersonEmail(InteractLogEntry));

        SetDeliveryState(InteractLogEntry, IsSent);
    end;

    local procedure SendEmailWithAttachment(TempDeliverySorterOther: Record "Delivery Sorter" temporary; InteractLogEntry: Record "Interaction Log Entry"; AttachmentFileFullName: Text; EmailBodyFilePath: Text)
    var
        DocumentMailing: Codeunit "Document-Mailing";
        IsSent: Boolean;
    begin
        IsSent :=
          DocumentMailing.EmailFileWithSubject(
            AttachmentFileFullName, GetAttachmentFileDefaultName(TempDeliverySorterOther."Attachment No."),
            EmailBodyFilePath, TempDeliverySorterOther.Subject, InteractionEMail(InteractLogEntry), false);

        SetDeliveryState(InteractLogEntry, IsSent);
    end;

    local procedure SendEmailWithAttachmentViaExchange(var ExchangeWebServicesServer: Codeunit "Exchange Web Services Server"; TempDeliverySorterOther: Record "Delivery Sorter" temporary; InteractLogEntry: Record "Interaction Log Entry"; AttachmentFileFullName: Text)
    var
        IsSent: Boolean;
    begin
        IsSent :=
          ExchangeWebServicesServer.SendEmailMessageWithAttachment(
            TempDeliverySorterOther.Subject, InteractionEMail(InteractLogEntry),
            '', AttachmentFileFullName, GetSenderSalesPersonEmail(InteractLogEntry));
        SetDeliveryState(InteractLogEntry, IsSent);
    end;

    local procedure PrepareServerAttachment(AttachmentNo: Integer): Text
    var
        Attachment: Record Attachment;
        FileManagement: Codeunit "File Management";
        TempFileFullName: Text;
        AttachmentFileFullName: Text;
    begin
        GetAttachment(Attachment, AttachmentNo, true);
        TempFileFullName := FileManagement.ServerTempFileName('');
        Attachment.ExportAttachmentToServerFile(TempFileFullName);
        AttachmentFileFullName := FileManagement.CombinePath(
            FileManagement.GetDirectoryName(TempFileFullName), AttachmentTok + '.' + Attachment."File Extension");
        FileManagement.CopyServerFile(TempFileFullName, AttachmentFileFullName, true);
        FileManagement.DeleteServerFile(TempFileFullName);
        exit(AttachmentFileFullName);
    end;

    local procedure SetDeliveryState(var InteractLogEntry: Record "Interaction Log Entry"; IsSent: Boolean)
    begin
        if IsSent then
            InteractLogEntry."Delivery Status" := InteractLogEntry."Delivery Status"::" "
        else
            InteractLogEntry."Delivery Status" := InteractLogEntry."Delivery Status"::Error;
        InteractLogEntry.Modify;
        Commit;
    end;

    local procedure ProcessDeliverySorter(var DeliverySorter: Record "Delivery Sorter"; var TempDeliverySorterHtml: Record "Delivery Sorter" temporary; var TempDeliverySorterWord: Record "Delivery Sorter" temporary; var TempDeliverySorterOther: Record "Delivery Sorter" temporary)
    var
        Attachment: Record Attachment;
        WordManagement: Codeunit WordManagement;
        ClientTypeManagement: Codeunit "Client Type Management";
        WordApplicationHandler: Codeunit WordApplicationHandler;
        Window: Dialog;
        NoOfAttachments: Integer;
        I: Integer;
    begin
        Window.Open(
          Text000 +
          '#1############ @2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\' +
          '#3############ @4@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');

        Window.Update(1, Text001);
        Window.Update(3, Text002);

        if DeliverySorter.Find('-') then begin
            NoOfAttachments := DeliverySorter.Count;
            repeat
                DeliverySorter.TestField("Correspondence Type");
                if not Attachment.Get(DeliverySorter."Attachment No.") then
                    Error(Text008);
                if WordManagement.IsWordDocumentExtension(Attachment."File Extension") then
                    WordManagement.Activate(WordApplicationHandler, 5052);
                case true of
                    Attachment."File Extension" = 'HTML':
                        begin
                            TempDeliverySorterHtml := DeliverySorter;
                            TempDeliverySorterHtml.Insert;
                        end;
                    WordManagement.IsWordDocumentExtension(Attachment."File Extension") and not
                  (ClientTypeManagement.GetCurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop]):
                        if WordManagement.CanRunWordApp then begin
                            TempDeliverySorterWord := DeliverySorter;
                            TempDeliverySorterWord.Insert;
                        end else begin
                            TempDeliverySorterOther := DeliverySorter;
                            TempDeliverySorterOther.Insert;
                        end;
                    else begin
                        TempDeliverySorterOther := DeliverySorter;
                        TempDeliverySorterOther.Insert;
                    end;
                end;
                I := I + 1;
                Window.Update(2, Round(I / NoOfAttachments * 10000, 1));
            until DeliverySorter.Next = 0;
        end;
        Window.Close;
    end;

    local procedure GetAttachment(var Attachment: Record Attachment; AttachmentNo: Integer; CheckExtension: Boolean)
    begin
        Attachment.Get(AttachmentNo);
        if CheckExtension then
            Attachment.TestField("File Extension");
        Attachment.CalcFields("Attachment File");
    end;

    local procedure PrepareDummyEmailBody(): Text
    var
        FileMgt: Codeunit "File Management";
        OStream: OutStream;
        EmailBodyFile: File;
        EmailBodyFilePath: Text;
    begin
        EmailBodyFilePath := FileMgt.ServerTempFileName('HTML');
        EmailBodyFile.Create(EmailBodyFilePath);
        EmailBodyFile.CreateOutStream(OStream);
        OStream.WriteText('<html><body></body></html>');
        EmailBodyFile.Close;
        exit(EmailBodyFilePath);
    end;

    local procedure GetAttachmentFileDefaultName(AttachmentNo: Integer): Text
    var
        Attachment: Record Attachment;
    begin
        Attachment.Get(AttachmentNo);
        exit(AttachmentTok + '.' + Attachment."File Extension");
    end;
}
