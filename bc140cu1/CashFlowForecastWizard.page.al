page 1818 "Cash Flow Forecast Wizard"
{
    Caption = 'Set Up Cash Flow Forecast';
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
            group(Control6)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible AND NOT FinalStepVisible;
                field("MediaResourcesStandard.""Media Reference"""; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Control8)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible AND FinalStepVisible;
                field("MediaResourcesDone.""Media Reference"""; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Control10)
            {
                ShowCaption = false;
                Visible = FirstStepVisible;
                group("Welcome to the setup of Cash Flow Forecasting")
                {
                    Caption = 'Welcome to the setup of Cash Flow Forecasting';
                    Visible = FirstStepVisible;
                    group(Control12)
                    {
                        InstructionalText = 'The Cash Flow Forecast can help you manage your cash flow. In this guide, you will specify the general ledger accounts that you want to include in the forecast, and how often you want to update the forecast. If you do not want to set this up right now, close this page.';
                        ShowCaption = false;
                        Visible = FirstStepVisible;
                    }
                }
            }
            group(Control13)
            {
                ShowCaption = false;
                Visible = CreationStepVisible;
                group("Set up accounts and forecast frequency, and turn on or off predictions")
                {
                    Caption = 'Set up accounts and forecast frequency, and turn on or off predictions';
                    Visible = CreationStepVisible;
                    group(Control22)
                    {
                        InstructionalText = 'Specify the accounts that you want to base the forecast on. We have suggested your cash accounts, but you can change that.';
                        ShowCaption = false;
                        field(LiquidFundsGLAccountFilter; LiquidFundsGLAccountFilter)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;

                            trigger OnLookup(var Text: Text): Boolean
                            var
                                GLAccount: Record "G/L Account";
                                GLAccountList: Page "G/L Account List";
                                OldText: Text;
                            begin
                                OldText := Text;
                                GLAccount.SetRange("Account Category", GLAccount."Account Category"::" ", GLAccount."Account Category"::Assets);
                                GLAccountList.SetTableView(GLAccount);
                                GLAccountList.LookupMode(true);
                                if not (GLAccountList.RunModal = ACTION::LookupOK) then
                                    exit(false);

                                Text := OldText + GLAccountList.GetSelectionFilter;
                                exit(true);
                            end;
                        }
                    }
                    group(Control15)
                    {
                        InstructionalText = 'How often would you like us to update your cash flow forecast?';
                        ShowCaption = false;
                        field(UpdateFrequency; UpdateFrequency)
                        {
                            ApplicationArea = Basic, Suite;
                            OptionCaption = 'Never,Daily,Weekly';
                            ShowCaption = false;
                        }
                    }
                }
                group("Cortana Intelligence")
                {
                    Caption = 'Cortana Intelligence';
                    group(CortanaIntelligenceForecastsDescription)
                    {
                        Caption = 'Cortana Intelligence forecasts can help you anticipate and proactively address upcoming cash flow needs. If you are using Dynamics 365 Business Central, Azure Machine Learning credentials are set automatically.';
                        field("<CortanaInteligenceEnabled>"; CortanaInteligenceEnabled)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Enable Cortana Intelligence';
                            ShowCaption = true;
                        }
                    }
                }
            }
            group(Control38)
            {
                ShowCaption = false;
                Visible = CortanaStepVisible;
                group("If you have your own Machine Learning service, enter the API URL and API key for the service and use that instead.")
                {
                    Caption = 'If you have your own Machine Learning service, enter the API URL and API key for the service and use that instead.';
                    field(APIURL; APIURL)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'API URL';
                        Editable = CortanaInteligenceEnabled;
                        Visible = CortanaInteligenceEnabled;
                    }
                    field(APIKEY; APIKEY)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'API Key';
                        Editable = CortanaInteligenceEnabled;
                        Visible = CortanaInteligenceEnabled;
                    }
                }
            }
            group(Control26)
            {
                ShowCaption = false;
                Visible = TaxStepVisible;
                group(Control27)
                {
                    Caption = 'Welcome to the setup of Cash Flow Forecasting';
                    Visible = TaxStepVisible;
                    group(Control31)
                    {
                        InstructionalText = 'How often must your company pay taxes?';
                        ShowCaption = false;
                        field(TaxablePeriod; TaxablePeriod)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                        }
                    }
                    group(Control29)
                    {
                        InstructionalText = 'What is the payment window for paying your taxes? For example, if your payment window is 20 days, specify 20D.';
                        ShowCaption = false;
                        field(TaxPaymentWindow; TaxPaymentWindow)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                        }
                    }
                    group(Control25)
                    {
                        InstructionalText = 'Which type of account do you pay your taxes to?';
                        ShowCaption = false;
                        field("DummyCashFlowSetup.""Tax Bal. Account Type"""; DummyCashFlowSetup."Tax Bal. Account Type")
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                DummyCashFlowSetup.EmptyTaxBalAccountIfTypeChanged(CurrentTaxBalAccountType);
                                CurrentTaxBalAccountType := DummyCashFlowSetup."Tax Bal. Account Type";
                                TaxAccountValidType := DummyCashFlowSetup.HasValidTaxAccountInfo;
                                CurrPage.Update;
                            end;
                        }
                    }
                    group(Control23)
                    {
                        InstructionalText = 'What is the number of the account that you pay your taxes to?';
                        ShowCaption = false;
                        Visible = TaxAccountValidType;
                        field("DummyCashFlowSetup.""Tax Bal. Account No."""; DummyCashFlowSetup."Tax Bal. Account No.")
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;

                            trigger OnLookup(var Text: Text): Boolean
                            var
                                Vendor: Record Vendor;
                                GLAccount: Record "G/L Account";
                                Result: Boolean;
                            begin
                                case DummyCashFlowSetup."Tax Bal. Account Type" of
                                    DummyCashFlowSetup."Tax Bal. Account Type"::Vendor:
                                        begin
                                            if Vendor.Get(Text) then;
                                            Result := PAGE.RunModal(PAGE::"Vendor List", Vendor) = ACTION::LookupOK;
                                            Text := Vendor."No.";
                                        end;
                                    DummyCashFlowSetup."Tax Bal. Account Type"::"G/L Account":
                                        begin
                                            if GLAccount.Get(Text) then;
                                            Result := PAGE.RunModal(PAGE::"G/L Account List", GLAccount) = ACTION::LookupOK;
                                            Text := GLAccount."No.";
                                        end;
                                end;

                                exit(Result);
                            end;
                        }
                    }
                }
            }
            group(Control17)
            {
                ShowCaption = false;
                Visible = FinalStepVisible;
                group("That's it!")
                {
                    Caption = 'That''s it!';
                    group(Control19)
                    {
                        InstructionalText = 'When you choose Finish, cash flow forecasting is set up for you. The forecast is shown in a chart on your Home page. If it does not show a forecast yet, you might have to refresh the page.';
                        ShowCaption = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    FinishAction;
                end;
            }
        }
    }

    trigger OnInit()
    begin
        LoadTopBanners;
    end;

    trigger OnOpenPage()
    begin
        Step := Step::Start;
        EnableControls(false);
        UpdateFrequency := UpdateFrequency::Daily;
        TaxablePeriod := TaxablePeriod::Quarterly;
        LiquidFundsGLAccountFilter := GetLiquidFundsGLAccountFilter;
        CortanaInteligenceEnabled := true;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if CloseAction = ACTION::OK then
            if AssistedSetup.GetStatus(PAGE::"Cash Flow Forecast Wizard") = AssistedSetup.Status::"Not Completed" then
                if not Confirm(SetupNotCompletedQst, false) then
                    Error('');
    end;

    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        DummyCashFlowSetup: Record "Cash Flow Setup";
        ClientTypeManagement: Codeunit "Client Type Management";
        Step: Option Start,Creation,Cortana,Tax,Finish;
        TopBannerVisible: Boolean;
        FirstStepVisible: Boolean;
        CreationStepVisible: Boolean;
        TaxStepVisible: Boolean;
        FinalStepVisible: Boolean;
        FinishActionEnabled: Boolean;
        BackActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        UpdateFrequency: Option Never,Daily,Weekly;
        ExistingSetupWillBeDeletedQst: Label 'The existing cash flow forecast setup will be deleted. Are you sure you want to continue?';
        LiquidFundsGLAccountFilter: Code[250];
        SetupNotCompletedQst: Label 'Setup of cash flow forecast has not been completed.\\Are you sure that you want to exit?';
        TaxPaymentWindow: DateFormula;
        TaxablePeriod: Option Monthly,Quarterly,"Accounting Period",Yearly;
        TaxAccountValidType: Boolean;
        CurrentTaxBalAccountType: Option;
        CortanaInteligenceEnabled: Boolean;
        APIURL: Text[250];
        APIKEY: Text[250];
        CortanaStepVisible: Boolean;

    local procedure EnableControls(Backwards: Boolean)
    var
        CashFlowForecast: Record "Cash Flow Forecast";
    begin
        if (Step = Step::Creation) and not Backwards then
            if not CashFlowForecast.IsEmpty then
                if not Confirm(ExistingSetupWillBeDeletedQst) then
                    CurrPage.Close;

        ResetControls;

        case Step of
            Step::Start:
                ShowStartStep;
            Step::Creation:
                ShowCreationStep;
            Step::Cortana:
                ShowCortanaStep;
            Step::Tax:
                ShowTaxStep;
            Step::Finish:
                ShowFinalStep;
        end;
    end;

    local procedure FinishAction()
    var
        AssistedSetup: Record "Assisted Setup";
        CashFlowSetup: Record "Cash Flow Setup";
        CashFlowManagement: Codeunit "Cash Flow Management";
    begin
        CashFlowManagement.SetupCashFlow(LiquidFundsGLAccountFilter);

        CashFlowSetup.UpdateTaxPaymentInfo(TaxablePeriod, TaxPaymentWindow,
          DummyCashFlowSetup."Tax Bal. Account Type", DummyCashFlowSetup."Tax Bal. Account No.");

        CashFlowSetup.Get;
        CashFlowSetup.Validate("Cortana Intelligence Enabled", CortanaInteligenceEnabled);
        CashFlowSetup.Validate("API URL", APIURL);
        CashFlowSetup.SaveUserDefinedAPIKey(APIKEY);
        CashFlowSetup.Validate("Automatic Update Frequency", UpdateFrequency);
        CashFlowSetup.Modify;

        CashFlowManagement.UpdateCashFlowForecast(CortanaInteligenceEnabled);
        AssistedSetup.SetStatus(PAGE::"Cash Flow Forecast Wizard", AssistedSetup.Status::Completed);
        CurrPage.Close;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            // Skip Cortana setup page if it is SaaS or Cortana is disabled
            if (Step = Step::Tax) and (not CortanaInteligenceEnabled or OnSaaS) then
                Step := Step - 2
            else
                Step := Step - 1
        else
            // Skip Cortana setup page if it is SaaS or Cortana is disabled
            if (Step = Step::Creation) and (not CortanaInteligenceEnabled or OnSaaS) then
                Step := Step + 2
            else
                Step := Step + 1;

        EnableControls(Backwards);
    end;

    local procedure ShowStartStep()
    begin
        FirstStepVisible := true;

        FinishActionEnabled := false;
        BackActionEnabled := false;
    end;

    local procedure ShowCreationStep()
    begin
        CreationStepVisible := true;
        CortanaStepVisible := false;
        FinishActionEnabled := false;
    end;

    local procedure ShowTaxStep()
    begin
        TaxStepVisible := true;

        FinishActionEnabled := false;
    end;

    local procedure ShowFinalStep()
    begin
        FinalStepVisible := true;
        NextActionEnabled := false;
    end;

    local procedure ShowCortanaStep()
    begin
        CortanaStepVisible := true;

        FinishActionEnabled := false;
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := true;
        BackActionEnabled := true;
        NextActionEnabled := true;

        TaxStepVisible := false;
        FirstStepVisible := false;
        CreationStepVisible := false;
        FinalStepVisible := false;
        CortanaStepVisible := false;
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(ClientTypeManagement.GetCurrentClientType)) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(ClientTypeManagement.GetCurrentClientType))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue;
    end;

    local procedure GetLiquidFundsGLAccountFilter(): Code[250]
    var
        CashFlowAccount: Record "Cash Flow Account";
        CashFlowManagement: Codeunit "Cash Flow Management";
    begin
        if CashFlowAccount.Get(Format(CashFlowAccount."Source Type"::"Liquid Funds", 20)) then
            if CashFlowAccount."G/L Account Filter" <> '' then
                exit(CashFlowAccount."G/L Account Filter");

        exit(CopyStr(CashFlowManagement.GetCashAccountFilter, 1, 250));
    end;

    local procedure OnSaaS(): Boolean
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        exit(PermissionManager.SoftwareAsAService)
    end;
}

