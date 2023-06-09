table 9510 "Email Parameter"
{
    Caption = 'Email Parameter';

    fields
    {
        field(1;"Document No";Code[20])
        {
            Caption = 'Document No';
        }
        field(2;"Document Type";Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
            TableRelation = "Sales Header"."Document Type";
        }
        field(3;"Parameter Type";Option)
        {
            Caption = 'Parameter Type';
            OptionCaption = ' ,Subject,Address,Body';
            OptionMembers = " ",Subject,Address,Body;
        }
        field(4;"Parameter Value";Text[250])
        {
            Caption = 'Parameter Value';
        }
        field(5;"Parameter BLOB";BLOB)
        {
            Caption = 'Parameter BLOB';
        }
    }

    keys
    {
        key(Key1;"Document No","Document Type","Parameter Type")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ParameterNotSupportedErr: Label 'Report usage is not supported.';

    [Scope('Personalization')]
    procedure GetEntryWithReportUsage(DocumentNo: Code[20];ReportUsage: Integer;ParameterType: Option): Boolean
    var
        ReportSelections: Record "Report Selections";
        DocumentType: Option;
    begin
        if not ReportSelections.ReportUsageToDocumentType(DocumentType,ReportUsage) then
          exit(false);
        exit(Get(DocumentNo,DocumentType,ParameterType));
    end;

    [Scope('Personalization')]
    procedure GetParameterValue(): Text
    begin
        CalcFields("Parameter BLOB");
        if "Parameter BLOB".HasValue then
          exit(GetTextFromBLOB);

        exit("Parameter Value");
    end;

    [Scope('Personalization')]
    procedure SaveParameterValue(DocumentNo: Code[20];DocumentType: Integer;ParameterType: Option;ParameterValue: Text)
    var
        ParameterAlreadyExists: Boolean;
    begin
        ParameterAlreadyExists := Get(DocumentNo,DocumentType,ParameterType);
        if not ParameterAlreadyExists then begin
          Init;
          "Document No" := DocumentNo;
          "Document Type" := DocumentType;
          "Parameter Type" := ParameterType;
        end;

        Clear("Parameter Value");
        Clear("Parameter BLOB");
        if MaxStrLen("Parameter Value") > StrLen(ParameterValue) then
          "Parameter Value" := CopyStr(ParameterValue,1,MaxStrLen("Parameter Value"))
        else
          WriteToBLOB(ParameterValue);

        if ParameterAlreadyExists then
          Modify
        else
          Insert;
    end;

    [Scope('Personalization')]
    procedure SaveParameterValueWithReportUsage(DocumentNo: Code[20];ReportUsage: Integer;ParameterType: Option;ParameterValue: Text)
    var
        ReportSelections: Record "Report Selections";
        DocumentType: Option;
    begin
        if not ReportSelections.ReportUsageToDocumentType(DocumentType,ReportUsage) then
          Error(ParameterNotSupportedErr);
        SaveParameterValue(DocumentNo,DocumentType,ParameterType,ParameterValue);
    end;

    local procedure WriteToBLOB(ParameterValue: Text)
    var
        TempBlob: Record TempBlob;
    begin
        Clear("Parameter BLOB");
        TempBlob.WriteAsText(ParameterValue,TEXTENCODING::Windows);
        "Parameter BLOB" := TempBlob.Blob;
    end;

    local procedure GetTextFromBLOB(): Text
    var
        TempBlob: Record TempBlob;
        CR: Text[1];
    begin
        CalcFields("Parameter BLOB");
        CR[1] := 10;
        TempBlob.Blob := "Parameter BLOB";
        exit(TempBlob.ReadAsText(CR,TEXTENCODING::Windows));
    end;
}

