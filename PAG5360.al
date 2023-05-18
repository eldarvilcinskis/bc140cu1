page 5360 "CRM Statistics FactBox"
{
    Caption = 'Dynamics 365 for Sales Statistics';
    PageType = CardPart;
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            field(Opportunities;GetNoOfCRMOpportunities)
            {
                ApplicationArea = Suite;
                Caption = 'Opportunities';
                ToolTip = 'Specifies the sales opportunity that is coupled to this Dynamics 365 for Sales opportunity.';

                trigger OnDrillDown()
                var
                    CRMIntegrationManagement: Codeunit "CRM Integration Management";
                begin
                    CRMIntegrationManagement.ShowCustomerCRMOpportunities(Rec);
                end;
            }
            field(Quotes;GetNoOfCRMQuotes)
            {
                ApplicationArea = Suite;
                Caption = 'Quotes';
                ToolTip = 'Specifies information related to the Dynamics 365 for Sales connection. ';

                trigger OnDrillDown()
                var
                    CRMIntegrationManagement: Codeunit "CRM Integration Management";
                begin
                    CRMIntegrationManagement.ShowCustomerCRMQuotes(Rec);
                end;
            }
            field(Cases;GetNoOfCRMCases)
            {
                ApplicationArea = Suite;
                Caption = 'Cases';
                ToolTip = 'Specifies information related to the Dynamics 365 for Sales connection. ';

                trigger OnDrillDown()
                var
                    CRMIntegrationManagement: Codeunit "CRM Integration Management";
                begin
                    CRMIntegrationManagement.ShowCustomerCRMCases(Rec);
                end;
            }
        }
    }

    actions
    {
    }

    local procedure GetNoOfCRMOpportunities(): Integer
    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
    begin
        exit(CRMIntegrationManagement.GetNoOfCRMOpportunities(Rec));
    end;

    local procedure GetNoOfCRMQuotes(): Integer
    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
    begin
        exit(CRMIntegrationManagement.GetNoOfCRMQuotes(Rec));
    end;

    local procedure GetNoOfCRMCases(): Integer
    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
    begin
        exit(CRMIntegrationManagement.GetNoOfCRMCases(Rec));
    end;
}

