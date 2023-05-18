page 9039 "O365 Sales Activities"
{
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "O365 Sales Cue";

    layout
    {
        area(content)
        {
            cuegroup(Invoiced)
            {
                Caption = 'Invoiced';
                CueGroupLayout = Wide;
                field("Invoiced YTD";"Invoiced YTD")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    AutoFormatExpression = CurrencyFormatTxt;
                    AutoFormatType = 10;
                    Caption = 'Sales this year';
                    ToolTip = 'Specifies the total invoiced amount for this year.';

                    trigger OnDrillDown()
                    begin
                        ShowYearlySalesOverview;
                    end;
                }
                field("Invoiced CM";"Invoiced CM")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    AutoFormatExpression = CurrencyFormatTxt;
                    AutoFormatType = 10;
                    Caption = 'Sales this month';
                    ToolTip = 'Specifies the total invoiced amount for this year.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        ShowMonthlySalesOverview;
                    end;
                }
            }
            cuegroup(Payments)
            {
                Caption = 'Payments';
                CueGroupLayout = Wide;
                field("Sales Invoices Outstanding";"Sales Invoices Outstanding")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    AutoFormatExpression = CurrencyFormatTxt;
                    AutoFormatType = 10;
                    Caption = 'Outstanding amount';
                    ToolTip = 'Specifies the total amount that has not yet been paid.';

                    trigger OnDrillDown()
                    begin
                        ShowInvoices(false);
                    end;
                }
                field("Sales Invoices Overdue";"Sales Invoices Overdue")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    AutoFormatExpression = CurrencyFormatTxt;
                    AutoFormatType = 10;
                    Caption = 'Overdue amount';
                    Style = Unfavorable;
                    StyleExpr = "Sales Invoices Overdue" > 0;
                    ToolTip = 'Specifies the total amount that has not been paid and is after the due date.';

                    trigger OnDrillDown()
                    begin
                        ShowInvoices(true);
                    end;
                }
            }
            cuegroup("Ongoing sales")
            {
                Caption = 'Ongoing sales';
                field(NoOfDrafts;"No. of Draft Invoices")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Draft invoices';
                    ToolTip = 'Specifies the number of draft invoices.';

                    trigger OnDrillDown()
                    begin
                        ShowDraftInvoices;
                    end;
                }
                field(NoOfQuotes;"No. of Quotes")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Estimates';
                    ToolTip = 'Specifies the number of estimates.';

                    trigger OnDrillDown()
                    begin
                        ShowQuotes;
                    end;
                }
                field(NoOfUnpaidInvoices;NumberOfUnpaidInvoices)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Unpaid invoices';
                    ToolTip = 'Specifies the number of invoices that have been sent but not paid yet.';

                    trigger OnDrillDown()
                    begin
                        ShowUnpaidInvoices;
                    end;
                }
            }
            cuegroup(New)
            {
                Caption = 'New';

                actions
                {
                    action("New invoice")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'New invoice';
                        Image = TileNew;
                        RunObject = Page "BC O365 Sales Invoice";
                        RunPageMode = Create;
                        ToolTip = 'Create a new invoice for the customer.';
                    }
                    action("New estimate")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'New estimate';
                        Image = TileNew;
                        RunObject = Page "BC O365 Sales Quote";
                        RunPageMode = Create;
                        ToolTip = 'Create a new estimate for the customer.';
                    }
                }
            }
            cuegroup("Get started")
            {
                Caption = 'Get started';
                Visible = GettingStartedGroupVisible;

                actions
                {
                    action(CreateTestInvoice)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Send a test invoice';
                        Image = TileNew;
                        RunObject = Page "BC O365 Sales Invoice";
                        RunPageLink = "No."=CONST('TESTINVOICE');
                        RunPageMode = Create;
                        ToolTip = 'Create a new test invoice.';
                        Visible = CreateTestInvoiceVisible;

                        trigger OnAction()
                        begin
                            CurrPage.Update;
                        end;
                    }
                    action(ReplayGettingStarted)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Play Getting Started';
                        Image = TileVideo;
                        ToolTip = 'Show the Getting Started guide.';
                        Visible = ReplayGettingStartedVisible;

                        trigger OnAction()
                        var
                            O365GettingStarted: Record "O365 Getting Started";
                        begin
                            if O365GettingStarted.Get(UserId,ClientTypeManagement.GetCurrentClientType) then begin
                              O365GettingStarted."Tour in Progress" := false;
                              O365GettingStarted."Current Page" := 1;
                              O365GettingStarted.Modify;
                              Commit;
                            end;

                            if O365SetupMgmt.GettingStartedSupportedForInvoicing then
                              PAGE.Run(PAGE::"BC O365 Getting Started");
                        end;
                    }
                    action(SetupBusinessInfo)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Set up your information';
                        Image = TileSettings;
                        ToolTip = 'Set up your key business information';
                        Visible = SetupBusinessInfoVisible;

                        trigger OnAction()
                        begin
                            PAGE.RunModal(PAGE::"BC O365 My Settings");
                        end;
                    }
                    action(SetupPayments)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Set up online payments';
                        Image = TileCurrency;
                        ToolTip = 'Set up your online payments service.';
                        Visible = PaymentServicesVisible;

                        trigger OnAction()
                        begin
                            PAGE.Run(PAGE::"BC O365 Payment Services Card");
                        end;
                    }
                }
            }
            cuegroup(WantMoreGrp)
            {
                Caption = 'Want more?';
                Visible = WantMoreGroupVisible;

                actions
                {
                    action(TryBusinessCentral)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Try Business Central';
                        Image = TileReport;
                        RunObject = Page "O365 To D365 Trial";
                        RunPageMode = View;
                        ToolTip = 'Explore Dynamics 365 Business Central and see what it can do for your business.';

                        trigger OnAction()
                        begin
                            SendTraceTag('000081X',InvToBusinessCentralCategoryLbl,VERBOSITY::Normal,
                              InvToBusinessCentralTrialTelemetryTxt,DATACLASSIFICATION::SystemMetadata);
                        end;
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        RoleCenterNotificationMgt.HideEvaluationNotificationAfterStartingTrial;
        O365DocumentSendMgt.ShowRoleCenterEmailNotification(true);
        NumberOfUnpaidInvoices := GetNumberOfUnpaidInvoices;
        CreateTestInvoiceVisible := O365SetupMgmt.ShowCreateTestInvoice;
        GettingStartedGroupVisible :=
          CreateTestInvoiceVisible or ReplayGettingStartedVisible or PaymentServicesVisible or SetupBusinessInfoVisible;
    end;

    trigger OnInit()
    var
        TempPaymentServiceSetup: Record "Payment Service Setup" temporary;
    begin
        IsDevice := ClientTypeManagement.GetCurrentClientType in [CLIENTTYPE::Tablet,CLIENTTYPE::Phone];
        TempPaymentServiceSetup.OnRegisterPaymentServiceProviders(TempPaymentServiceSetup);
        PaymentServicesVisible := not TempPaymentServiceSetup.IsEmpty and not IsDevice;
        ReplayGettingStartedVisible := O365SetupMgmt.GettingStartedSupportedForInvoicing;
        WantMoreGroupVisible := O365SetupMgmt.GetBusinessCentralTrialVisibility;
        SetupBusinessInfoVisible := not IsDevice;
    end;

    trigger OnOpenPage()
    begin
        OnOpenActivitiesPage(CurrencyFormatTxt);
        SetRange("User ID Filter",UserId);
        PreparePageNotifier;
        O365DocumentSendMgt.ShowRoleCenterEmailNotification(false);
    end;

    var
        O365SetupMgmt: Codeunit "O365 Setup Mgmt";
        ClientTypeManagement: Codeunit "Client Type Management";
        O365DocumentSendMgt: Codeunit "O365 Document Send Mgt";
        [RunOnClient]
        [WithEvents]
        PageNotifier: DotNet PageNotifier;
        CurrencyFormatTxt: Text;
        CreateTestInvoiceVisible: Boolean;
        ReplayGettingStartedVisible: Boolean;
        PaymentServicesVisible: Boolean;
        NumberOfUnpaidInvoices: Integer;
        IsDevice: Boolean;
        SetupBusinessInfoVisible: Boolean;
        GettingStartedGroupVisible: Boolean;
        WantMoreGroupVisible: Boolean;
        InvToBusinessCentralTrialTelemetryTxt: Label 'User clicked the tile to try Business Central from Invoicing.', Locked=true;
        InvToBusinessCentralCategoryLbl: Label 'AL Invoicing To Business Central', Locked=true;

    local procedure PreparePageNotifier()
    begin
        if not PageNotifier.IsAvailable then
          exit;
        PageNotifier := PageNotifier.Create;
        PageNotifier.NotifyPageReady;
    end;

    trigger PageNotifier::PageReady()
    var
        O365NetPromoterScoreMgt: Codeunit "O365 Net Promoter Score Mgt.";
    begin
        if O365SetupMgmt.WizardShouldBeOpenedForInvoicing then begin
          Commit; // COMMIT is required for opening page without write transcation error.
          PAGE.RunModal(PAGE::"BC O365 Getting Started");
          exit;
        end;
        if O365NetPromoterScoreMgt.ShowNpsDialog then;
    end;
}

