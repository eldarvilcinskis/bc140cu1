table 5480 "Tax Group Buffer"
{
    Caption = 'Tax Group Buffer';
    ReplicateData = false;

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(2;Description;Text[100])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(8000;Id;Guid)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }
        field(8005;"Last Modified DateTime";DateTime)
        {
            Caption = 'Last Modified DateTime';
            DataClassification = SystemMetadata;
        }
        field(9600;Type;Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Sales Tax,VAT', Locked=true;
            OptionMembers = "Sales Tax",VAT;
        }
    }

    keys
    {
        key(Key1;Id)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnRename()
    begin
        Error(CannotChangeIDErr);
    end;

    var
        CannotChangeIDErr: Label 'The id cannot be changed.', Locked=true;
        RecordMustBeTemporaryErr: Label 'Tax Group Entity must be used as a temporary record.';

    [Scope('Personalization')]
    procedure PropagateInsert()
    begin
        PropagateUpdate(true);
    end;

    [Scope('Personalization')]
    procedure PropagateModify()
    begin
        PropagateUpdate(false);
    end;

    local procedure PropagateUpdate(Insert: Boolean)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        TaxGroup: Record "Tax Group";
    begin
        if not IsTemporary then
          Error(RecordMustBeTemporaryErr);

        if GeneralLedgerSetup.UseVat then begin
          if Insert then begin
            VATProductPostingGroup.TransferFields(Rec,true);
            VATProductPostingGroup.Insert(true)
          end else begin
            if xRec.Code <> Code then begin
              VATProductPostingGroup.Get(xRec.Code);
              VATProductPostingGroup.Rename(Code);
            end;

            VATProductPostingGroup.TransferFields(Rec,true);
            VATProductPostingGroup.Modify(true);
          end;

          UpdateFromVATProductPostingGroup(VATProductPostingGroup);
        end else begin
          if Insert then begin
            TaxGroup.TransferFields(Rec,true);
            TaxGroup.Insert(true)
          end else begin
            if xRec.Code <> Code then begin
              TaxGroup.Get(xRec.Code);
              TaxGroup.Rename(true)
            end;

            TaxGroup.TransferFields(Rec,true);
            TaxGroup.Modify(true);
          end;

          UpdateFromTaxGroup(TaxGroup);
        end;
    end;

    [Scope('Personalization')]
    procedure PropagateDelete()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        TaxGroup: Record "Tax Group";
    begin
        if GeneralLedgerSetup.UseVat then begin
          VATProductPostingGroup.Get(Code);
          VATProductPostingGroup.Delete(true);
        end else begin
          TaxGroup.Get(Code);
          TaxGroup.Delete(true);
        end;
    end;

    [Scope('Personalization')]
    procedure LoadRecords(): Boolean
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if not IsTemporary then
          Error(RecordMustBeTemporaryErr);

        if GeneralLedgerSetup.UseVat then
          LoadFromVATProductPostingGroup
        else
          LoadFromTaxGroup;

        exit(FindFirst);
    end;

    local procedure LoadFromTaxGroup()
    var
        TaxGroup: Record "Tax Group";
    begin
        if not TaxGroup.FindSet then
          exit;

        repeat
          UpdateFromTaxGroup(TaxGroup);
          Insert;
        until TaxGroup.Next = 0;
    end;

    local procedure LoadFromVATProductPostingGroup()
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        if not VATProductPostingGroup.FindSet then
          exit;

        repeat
          UpdateFromVATProductPostingGroup(VATProductPostingGroup);
          Insert;
        until VATProductPostingGroup.Next = 0;
    end;

    [Scope('Personalization')]
    procedure GetCodesFromTaxGroupId(TaxGroupID: Guid;var SalesTaxGroupCode: Code[20];var VATProductPostingGroupCode: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        TaxGroup: Record "Tax Group";
    begin
        Clear(SalesTaxGroupCode);
        Clear(VATProductPostingGroupCode);

        if IsNullGuid(TaxGroupID) then
          exit;

        if GeneralLedgerSetup.UseVat then begin
          VATProductPostingGroup.SetRange(Id,TaxGroupID);
          if VATProductPostingGroup.FindFirst then
            VATProductPostingGroupCode := VATProductPostingGroup.Code;

          exit;
        end;

        TaxGroup.SetRange(Id,TaxGroupID);
        if TaxGroup.FindFirst then
          SalesTaxGroupCode := TaxGroup.Code;
    end;

    local procedure UpdateFromVATProductPostingGroup(var VATProductPostingGroup: Record "VAT Product Posting Group")
    begin
        TransferFields(VATProductPostingGroup,true);
        Type := Type::VAT;
    end;

    local procedure UpdateFromTaxGroup(var TaxGroup: Record "Tax Group")
    begin
        TransferFields(TaxGroup,true);
        Type := Type::"Sales Tax";
    end;
}
