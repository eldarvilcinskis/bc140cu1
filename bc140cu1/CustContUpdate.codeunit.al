codeunit 5056 "CustCont-Update"
{

    trigger OnRun()
    begin
    end;

    var
        RMSetup: Record "Marketing Setup";

    [Scope('Personalization')]
    procedure OnInsert(var Cust: Record Customer)
    begin
        RMSetup.Get;
        if RMSetup."Bus. Rel. Code for Customers" = '' then
            exit;

        InsertNewContact(Cust, true);
    end;

    [Scope('Personalization')]
    procedure OnModify(var Cust: Record Customer)
    var
        ContBusRel: Record "Contact Business Relation";
        Cont: Record Contact;
        OldCont: Record Contact;
        IdentityManagement: Codeunit "Identity Management";
        ContNo: Code[20];
        NoSeries: Code[20];
    begin
        with ContBusRel do begin
            SetCurrentKey("Link to Table", "No.");
            SetRange("Link to Table", "Link to Table"::Customer);
            SetRange("No.", Cust."No.");
            if not FindFirst then
                exit;
            Cont.Get("Contact No.");
            OldCont := Cont;
        end;

        ContNo := Cont."No.";
        NoSeries := Cont."No. Series";
        Cont.Validate("E-Mail", Cust."E-Mail");
        Cont.TransferFields(Cust);
        OnAfterTransferFieldsFromCustToCont(Cont, Cust);
        Cont."No." := ContNo;
        Cont."No. Series" := NoSeries;
        if not IdentityManagement.IsInvAppId then
            Cont.Type := OldCont.Type;
        Cont.Validate(Name);
        Cont.OnModify(OldCont);
        Cont.Modify(true);

        Cust.Get(Cust."No.");
    end;

    [Scope('Personalization')]
    procedure OnDelete(var Cust: Record Customer)
    var
        ContBusRel: Record "Contact Business Relation";
    begin
        with ContBusRel do begin
            SetCurrentKey("Link to Table", "No.");
            SetRange("Link to Table", "Link to Table"::Customer);
            SetRange("No.", Cust."No.");
            DeleteAll(true);
        end;
    end;

    [Scope('Personalization')]
    procedure InsertNewContact(var Cust: Record Customer; LocalCall: Boolean)
    var
        ContBusRel: Record "Contact Business Relation";
        Cont: Record Contact;
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if not LocalCall then begin
            RMSetup.Get;
            RMSetup.TestField("Bus. Rel. Code for Customers");
        end;

        with Cont do begin
            Init;
            TransferFields(Cust);
            OnAfterTransferFieldsFromCustToCont(Cont, Cust);
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
            "Business Relation Code" := RMSetup."Bus. Rel. Code for Customers";
            "Link to Table" := "Link to Table"::Customer;
            "No." := Cust."No.";
            Insert(true);
        end;
    end;

    [Scope('Personalization')]
    procedure InsertNewContactPerson(var Cust: Record Customer; LocalCall: Boolean)
    var
        ContComp: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        Cont: Record Contact;
    begin
        if not LocalCall then begin
            RMSetup.Get;
            RMSetup.TestField("Bus. Rel. Code for Customers");
        end;

        ContBusRel.SetCurrentKey("Link to Table", "No.");
        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
        ContBusRel.SetRange("No.", Cust."No.");
        if ContBusRel.FindFirst then
            if ContComp.Get(ContBusRel."Contact No.") then
                with Cont do begin
                    Init;
                    "No." := '';
                    Validate(Type, Type::Person);
                    Insert(true);
                    "Company No." := ContComp."No.";
                    Validate(Name, Cust.Contact);
                    InheritCompanyToPersonData(ContComp);
                    Modify(true);
                    Cust."Primary Contact No." := "No.";
                end
    end;

    [Scope('Personalization')]
    procedure DeleteCustomerContacts(var Customer: Record Customer)
    var
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        with ContactBusinessRelation do begin
            SetCurrentKey("Link to Table", "No.");
            SetRange("Link to Table", "Link to Table"::Customer);
            SetRange("No.", Customer."No.");
            if FindSet then
                repeat
                    if Contact.Get("Contact No.") then
                        Contact.Delete(true);
                until Next = 0;
        end;
    end;

    [Scope('Personalization')]
    procedure ContactNameIsBlank(CustomerNo: Code[20]): Boolean
    var
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        with ContactBusinessRelation do begin
            SetCurrentKey("Link to Table", "No.");
            SetRange("Link to Table", "Link to Table"::Customer);
            SetRange("No.", CustomerNo);
            if not FindFirst then
                exit(false);
            Contact.Get("Contact No.");
            exit(Contact.Name = '');
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferFieldsFromCustToCont(var Contact: Record Contact; Customer: Record Customer)
    begin
    end;
}

