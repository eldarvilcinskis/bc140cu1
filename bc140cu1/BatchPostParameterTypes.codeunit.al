codeunit 1370 "Batch Post Parameter Types"
{

    trigger OnRun()
    begin
    end;

    var
        Parameter: Option Invoice,Ship,Receive,"Posting Date","Replace Posting Date","Replace Document Date","Calculate Invoice Discount",Print;

    [Scope('Personalization')]
    procedure Invoice(): Integer
    begin
        exit(Parameter::Invoice);
    end;

    [Scope('Personalization')]
    procedure Ship(): Integer
    begin
        exit(Parameter::Ship);
    end;

    [Scope('Personalization')]
    procedure Receive(): Integer
    begin
        exit(Parameter::Receive);
    end;

    [Scope('Personalization')]
    procedure Print(): Integer
    begin
        exit(Parameter::Print);
    end;

    [Scope('Personalization')]
    procedure CalcInvoiceDiscount(): Integer
    begin
        exit(Parameter::"Calculate Invoice Discount");
    end;

    [Scope('Personalization')]
    procedure ReplaceDocumentDate(): Integer
    begin
        exit(Parameter::"Replace Document Date");
    end;

    [Scope('Personalization')]
    procedure ReplacePostingDate(): Integer
    begin
        exit(Parameter::"Replace Posting Date");
    end;

    [Scope('Personalization')]
    procedure PostingDate(): Integer
    begin
        exit(Parameter::"Posting Date");
    end;
}

