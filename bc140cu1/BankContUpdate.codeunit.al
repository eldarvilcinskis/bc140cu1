codeunit 5058 "BankCont-Update"
{

    trigger OnRun()
    begin
    end;

    var
        RMSetup: Record "Marketing Setup";

    [Scope('Personalization')]
    procedure OnInsert(var BankAcc: Record "Bank Account")
    begin
        RMSetup.Get;
        if RMSetup."Bus. Rel. Code for Bank Accs." = '' then
            exit;

        InsertNewContact(BankAcc, true);
    end;

    [Scope('Personalization')]
    procedure OnModify(var BankAcc: Record "Bank Account")
    var
        Cont: Record Contact;
        OldCont: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        ContNo: Code[20];
        NoSeries: Code[20];
        SalespersonCode: Code[20];
    begin
        with ContBusRel do begin
            SetCurrentKey("Link to Table", "No.");
            SetRange("Link to Table", "Link to Table"::"Bank Account");
            SetRange("No.", BankAcc."No.");
            if not FindFirst then
                exit;
            Cont.Get("Contact No.");
            OldCont := Cont;
        end;

        ContNo := Cont."No.";
        NoSeries := Cont."No. Series";
        SalespersonCode := Cont."Salesperson Code";
        Cont.Validate("E-Mail", BankAcc."E-Mail");
        Cont.TransferFields(BankAcc);
        OnAfterTransferFieldsFromBankAccToCont(Cont, BankAcc);
        Cont."No." := ContNo;
        Cont."No. Series" := NoSeries;
        Cont."Salesperson Code" := SalespersonCode;
        Cont.Validate(Name);
        Cont.OnModify(OldCont);
        Cont.Modify(true);

        BankAcc.Get(BankAcc."No.");
    end;

    [Scope('Personalization')]
    procedure OnDelete(var BankAcc: Record "Bank Account")
    var
        ContBusRel: Record "Contact Business Relation";
    begin
        with ContBusRel do begin
            SetCurrentKey("Link to Table", "No.");
            SetRange("Link to Table", "Link to Table"::"Bank Account");
            SetRange("No.", BankAcc."No.");
            DeleteAll(true);
        end;
    end;

    [Scope('Personalization')]
    procedure InsertNewContact(var BankAcc: Record "Bank Account"; LocalCall: Boolean)
    var
        Cont: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if not LocalCall then begin
            RMSetup.Get;
            RMSetup.TestField("Bus. Rel. Code for Bank Accs.");
        end;

        with Cont do begin
            Init;
            TransferFields(BankAcc);
            Validate(Name);
            Validate("E-Mail");
            "No." := '';
            "No. Series" := '';
            RMSetup.TestField("Contact Nos.");
            NoSeriesMgt.InitSeries(RMSetup."Contact Nos.", '', 0D, "No.", "No. Series");
            Type := Type::Company;
            TypeChange;
            SetSkipDefault;
            Insert(true);
        end;

        with ContBusRel do begin
            Init;
            "Contact No." := Cont."No.";
            "Business Relation Code" := RMSetup."Bus. Rel. Code for Bank Accs.";
            "Link to Table" := "Link to Table"::"Bank Account";
            "No." := BankAcc."No.";
            Insert(true);
        end;
    end;

    [Scope('Personalization')]
    procedure ContactNameIsBlank(BankAccountNo: Code[20]): Boolean
    var
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        with ContactBusinessRelation do begin
            SetCurrentKey("Link to Table", "No.");
            SetRange("Link to Table", "Link to Table"::"Bank Account");
            SetRange("No.", BankAccountNo);
            if not FindFirst then
                exit(false);
            Contact.Get("Contact No.");
            exit(Contact.Name = '');
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferFieldsFromBankAccToCont(var Contact: Record Contact; BankAccount: Record "Bank Account")
    begin
    end;
}

