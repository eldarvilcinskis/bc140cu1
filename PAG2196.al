page 2196 "O365 Link to Financials"
{
    Caption = 'O365 Link to Financials';
    PageType = CardPart;

    layout
    {
        area(content)
        {
            field(TryOutLbl;'')
            {
                ApplicationArea = Invoicing;
                Caption = 'Thanks for choosing to explore Dynamics 365 Business Central!';
                Editable = false;
                Style = StrongAccent;
                StyleExpr = TRUE;
                ToolTip = 'Specifies thanks for choosing to explore Dynamics 365 Business Central!';
                Visible = ShowLabel;
            }
            field(LinkToFinancials;TryD365FinancialsLbl)
            {
                ApplicationArea = Invoicing;
                Editable = false;
                ShowCaption = false;
                Visible = ShowLabel;

                trigger OnDrillDown()
                begin
                    O365SetupMgmt.ChangeToEvaluationCompany;
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        Initialize;
    end;

    var
        IdentityManagement: Codeunit "Identity Management";
        TryD365FinancialsLbl: Label 'Click here to try out the evaluation company in Dynamics 365 Business Central.';
        O365SetupMgmt: Codeunit "O365 Setup Mgmt";
        ShowLabel: Boolean;

    local procedure Initialize()
    var
        PermissionManager: Codeunit "Permission Manager";
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
        IsFinApp: Boolean;
        IsSaas: Boolean;
        IsInvAppAreaSet: Boolean;
    begin
        IsFinApp := IdentityManagement.IsFinAppId;
        IsSaas := PermissionManager.SoftwareAsAService;
        IsInvAppAreaSet := ApplicationAreaMgmt.IsInvoicingOnlyEnabled;

        ShowLabel := IsFinApp and IsSaas and IsInvAppAreaSet;
    end;
}

