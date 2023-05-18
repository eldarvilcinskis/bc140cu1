report 1183 "Shortcut Payment Registration"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Shortcut Payment Registration.rdlc';
    ApplicationArea = Basic,Suite;
    Caption = 'Payment Registration';
    UsageCategory = Tasks;
    UseRequestPage = false;

    dataset
    {
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        PAGE.Run(PAGE::"Payment Registration");
        Error(''); // To prevent pdf of this report from downloading.
    end;
}

