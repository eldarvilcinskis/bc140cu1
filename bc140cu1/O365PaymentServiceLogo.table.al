table 2119 "O365 Payment Service Logo"
{
    Caption = 'O365 Payment Service Logo';
    ReplicateData = false;

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2;"Payment Service ID";Integer)
        {
            Caption = 'Payment Service ID';
        }
        field(4;"Media Resources Ref";Code[50])
        {
            Caption = 'Media Resources Ref';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure FindO365Logo(PaymentReportingArgument: Record "Payment Reporting Argument"): Boolean
    begin
        SetRange("Payment Service ID",PaymentReportingArgument."Payment Service ID");
        exit(FindFirst);
    end;
}

