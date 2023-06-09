report 5195 "Create Conts. from Customers"
{
    ApplicationArea = RelationshipMgmt;
    Caption = 'Create Contacts from Customers';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(Customer;Customer)
        {
            RequestFilterFields = "No.","Search Name","Customer Posting Group","Currency Code";

            trigger OnAfterGetRecord()
            var
                CustContUpdate: Codeunit "CustCont-Update";
            begin
                Window.Update(1);

                with ContBusRel do begin
                  SetRange("Link to Table","Link to Table"::Customer);
                  SetRange("No.",Customer."No.");
                  if FindFirst then
                    CurrReport.Skip;
                end;

                Cont.Init;
                Cont.TransferFields(Customer);
                Cont."No." := '';
                Cont.SetSkipDefault;
                Cont.Insert(true);
                DuplMgt.MakeContIndex(Cont);

                if not DuplicateContactExist then
                  DuplicateContactExist := DuplMgt.DuplicateExist(Cont);

                with ContBusRel do begin
                  Init;
                  "Contact No." := Cont."No.";
                  "Business Relation Code" := RMSetup."Bus. Rel. Code for Customers";
                  "Link to Table" := "Link to Table"::Customer;
                  "No." := Customer."No.";
                  Insert;
                end;

                if Contact = '' then
                  "Primary Contact No." := Cont."No."
                else
                  CustContUpdate.InsertNewContactPerson(Customer,false);
                Modify(true);
            end;

            trigger OnPostDataItem()
            begin
                Window.Close;

                if DuplicateContactExist then begin
                  Commit;
                  PAGE.RunModal(PAGE::"Contact Duplicates");
                end;
            end;

            trigger OnPreDataItem()
            begin
                Window.Open(Text000 +
                  Text001,"No.");
            end;
        }
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

    trigger OnPreReport()
    begin
        RMSetup.Get;
        RMSetup.TestField("Bus. Rel. Code for Customers");
    end;

    var
        Text000: Label 'Processing customers...\\';
        Text001: Label 'Customer No.    #1##########';
        RMSetup: Record "Marketing Setup";
        Cont: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        DuplMgt: Codeunit DuplicateManagement;
        Window: Dialog;
        DuplicateContactExist: Boolean;
}

