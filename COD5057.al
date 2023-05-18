codeunit 5057 "VendCont-Update"
{

    trigger OnRun()
    begin
    end;

    var
        RMSetup: Record "Marketing Setup";

    [Scope('Personalization')]
    procedure OnInsert(var Vend: Record Vendor)
    begin
        RMSetup.Get;
        if RMSetup."Bus. Rel. Code for Vendors" = '' then
          exit;

        InsertNewContact(Vend,true);
    end;

    [Scope('Personalization')]
    procedure OnModify(var Vend: Record Vendor)
    var
        Cont: Record Contact;
        OldCont: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        ContNo: Code[20];
        NoSeries: Code[20];
        SalespersonCode: Code[20];
    begin
        with ContBusRel do begin
          SetCurrentKey("Link to Table","No.");
          SetRange("Link to Table","Link to Table"::Vendor);
          SetRange("No.",Vend."No.");
          if not FindFirst then
            exit;
          Cont.Get("Contact No.");
          OldCont := Cont;
        end;

        ContNo := Cont."No.";
        NoSeries := Cont."No. Series";
        SalespersonCode := Cont."Salesperson Code";
        Cont.Validate("E-Mail",Vend."E-Mail");
        Cont.TransferFields(Vend);
        OnAfterTransferFieldsFromVendToCont(Cont,Vend);
        Cont."No." := ContNo ;
        Cont."No. Series" := NoSeries;
        Cont."Salesperson Code" := SalespersonCode;
        Cont.Validate(Name);
        Cont.OnModify(OldCont);
        Cont.Modify(true);

        Vend.Get(Vend."No.");
    end;

    [Scope('Personalization')]
    procedure OnDelete(var Vend: Record Vendor)
    var
        ContBusRel: Record "Contact Business Relation";
    begin
        with ContBusRel do begin
          SetCurrentKey("Link to Table","No.");
          SetRange("Link to Table","Link to Table"::Vendor);
          SetRange("No.",Vend."No.");
          DeleteAll(true);
        end;
    end;

    [Scope('Personalization')]
    procedure InsertNewContact(var Vend: Record Vendor;LocalCall: Boolean)
    var
        Cont: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if not LocalCall then begin
          RMSetup.Get;
          RMSetup.TestField("Bus. Rel. Code for Vendors");
        end;

        with Cont do begin
          Init;
          TransferFields(Vend);
          Validate(Name);
          Validate("E-Mail");
          "No." := '';
          "No. Series" := '';
          RMSetup.TestField("Contact Nos.");
          NoSeriesMgt.InitSeries(RMSetup."Contact Nos.",'',0D,"No.","No. Series");
          Type := Type::Company;
          TypeChange;
          SetSkipDefault;
          Insert(true);
        end;

        with ContBusRel do begin
          Init;
          "Contact No." := Cont."No.";
          "Business Relation Code" := RMSetup."Bus. Rel. Code for Vendors";
          "Link to Table" := "Link to Table"::Vendor;
          "No." := Vend."No.";
          Insert(true);
        end;
    end;

    [Scope('Personalization')]
    procedure InsertNewContactPerson(var Vend: Record Vendor;LocalCall: Boolean)
    var
        Cont: Record Contact;
        ContComp: Record Contact;
        ContBusRel: Record "Contact Business Relation";
    begin
        if not LocalCall then begin
          RMSetup.Get;
          RMSetup.TestField("Bus. Rel. Code for Vendors");
        end;

        ContBusRel.SetCurrentKey("Link to Table","No.");
        ContBusRel.SetRange("Link to Table",ContBusRel."Link to Table"::Vendor);
        ContBusRel.SetRange("No.",Vend."No.");
        if ContBusRel.FindFirst then
          if ContComp.Get(ContBusRel."Contact No.") then
            with Cont do begin
              Init;
              "No." := '';
              Insert(true);
              "Company No." := ContComp."No.";
              Type := Type::Person;
              Validate(Name,Vend.Contact);
              InheritCompanyToPersonData(ContComp);
              Modify(true);
              Vend."Primary Contact No." := "No.";
            end
    end;

    [Scope('Personalization')]
    procedure ContactNameIsBlank(VendorNo: Code[20]): Boolean
    var
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        with ContactBusinessRelation do begin
          SetCurrentKey("Link to Table","No.");
          SetRange("Link to Table","Link to Table"::Vendor);
          SetRange("No.",VendorNo);
          if not FindFirst then
            exit(false);
          Contact.Get("Contact No.");
          exit(Contact.Name = '');
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferFieldsFromVendToCont(var Contact: Record Contact;Vendor: Record Vendor)
    begin
    end;
}

