table 289 "Payment Method"
{
    Caption = 'Payment Method';
    DataCaptionFields = "Code",Description;
    DrillDownPageID = "Payment Methods";
    LookupPageID = "Payment Methods";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Description;Text[100])
        {
            Caption = 'Description';
        }
        field(3;"Bal. Account Type";Option)
        {
            Caption = 'Bal. Account Type';
            OptionCaption = 'G/L Account,Bank Account';
            OptionMembers = "G/L Account","Bank Account";

            trigger OnValidate()
            begin
                "Bal. Account No." := '';
            end;
        }
        field(4;"Bal. Account No.";Code[20])
        {
            Caption = 'Bal. Account No.';
            TableRelation = IF ("Bal. Account Type"=CONST("G/L Account")) "G/L Account"
                            ELSE IF ("Bal. Account Type"=CONST("Bank Account")) "Bank Account";

            trigger OnValidate()
            begin
                if "Bal. Account No." <> '' then
                  TestField("Direct Debit",false);
                if "Bal. Account Type" = "Bal. Account Type"::"G/L Account" then
                  CheckGLAcc("Bal. Account No.");
            end;
        }
        field(6;"Direct Debit";Boolean)
        {
            Caption = 'Direct Debit';

            trigger OnValidate()
            begin
                if not "Direct Debit" then
                  "Direct Debit Pmt. Terms Code" := '';
                if "Direct Debit" then
                  TestField("Bal. Account No.",'');
            end;
        }
        field(7;"Direct Debit Pmt. Terms Code";Code[10])
        {
            Caption = 'Direct Debit Pmt. Terms Code';
            TableRelation = "Payment Terms";

            trigger OnValidate()
            begin
                if "Direct Debit Pmt. Terms Code" <> '' then
                  TestField("Direct Debit",true);
            end;
        }
        field(8;"Pmt. Export Line Definition";Code[20])
        {
            Caption = 'Pmt. Export Line Definition';

            trigger OnLookup()
            var
                DataExchLineDef: Record "Data Exch. Line Def";
                TempDataExchLineDef: Record "Data Exch. Line Def" temporary;
                DataExchDef: Record "Data Exch. Def";
            begin
                DataExchLineDef.SetFilter(Code,'<>%1','');
                if DataExchLineDef.FindSet then begin
                  repeat
                    DataExchDef.Get(DataExchLineDef."Data Exch. Def Code");
                    if DataExchDef.Type = DataExchDef.Type::"Payment Export" then begin
                      TempDataExchLineDef.Init;
                      TempDataExchLineDef.Code := DataExchLineDef.Code;
                      TempDataExchLineDef.Name := DataExchLineDef.Name;
                      if TempDataExchLineDef.Insert then;
                    end;
                  until DataExchLineDef.Next = 0;
                  if PAGE.RunModal(PAGE::"Pmt. Export Line Definitions",TempDataExchLineDef) = ACTION::LookupOK then
                    "Pmt. Export Line Definition" := TempDataExchLineDef.Code;
                end;
            end;
        }
        field(9;"Bank Data Conversion Pmt. Type";Text[50])
        {
            Caption = 'Bank Data Conversion Pmt. Type';
            TableRelation = "Bank Data Conversion Pmt. Type";
        }
        field(10;"Use for Invoicing";Boolean)
        {
            Caption = 'Use for Invoicing';

            trigger OnValidate()
            var
                IdentityManagement: Codeunit "Identity Management";
            begin
                if IdentityManagement.IsInvAppId then
                  if not "Use for Invoicing" then
                    Error(UseForInvoicingErr);
            end;
        }
        field(11;"Last Modified Date Time";DateTime)
        {
            Caption = 'Last Modified Date Time';
            Editable = false;
        }
        field(8000;Id;Guid)
        {
            Caption = 'Id';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick;"Code",Description)
        {
        }
    }

    trigger OnDelete()
    var
        PaymentMethodTranslation: Record "Payment Method Translation";
    begin
        PaymentMethodTranslation.SetRange("Payment Method Code",Code);
        PaymentMethodTranslation.DeleteAll;
    end;

    trigger OnInsert()
    var
        IdentityManagement: Codeunit "Identity Management";
    begin
        if IdentityManagement.IsInvAppId then
          if not "Use for Invoicing" then
            Validate("Use for Invoicing",true);

        "Last Modified Date Time" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Last Modified Date Time" := CurrentDateTime;
    end;

    trigger OnRename()
    begin
        "Last Modified Date Time" := CurrentDateTime;
    end;

    var
        UseForInvoicingErr: Label 'The Use for Invoicing property must be set to true in the Invoicing App.';

    local procedure CheckGLAcc(AccNo: Code[20])
    var
        GLAcc: Record "G/L Account";
    begin
        if AccNo <> '' then begin
          GLAcc.Get(AccNo);
          GLAcc.CheckGLAcc;
          GLAcc.TestField("Direct Posting",true);
        end;
    end;

    [Scope('Personalization')]
    procedure TranslateDescription(Language: Code[10])
    var
        PaymentMethodTranslation: Record "Payment Method Translation";
    begin
        if PaymentMethodTranslation.Get(Code,Language) then
          Validate(Description,CopyStr(PaymentMethodTranslation.Description,1,MaxStrLen(Description)));
    end;

    [Scope('Personalization')]
    procedure GetDescriptionInCurrentLanguage(): Text[100]
    var
        Language: Record Language;
        PaymentMethodTranslation: Record "Payment Method Translation";
    begin
        if PaymentMethodTranslation.Get(Code,Language.GetUserLanguage) then
          exit(PaymentMethodTranslation.Description);

        exit(Description);
    end;
}

