table 1221 "Data Exch. Field"
{
    Caption = 'Data Exch. Field';
    Permissions = TableData "Data Exch. Field"=rimd;

    fields
    {
        field(1;"Data Exch. No.";Integer)
        {
            Caption = 'Data Exch. No.';
            NotBlank = true;
            TableRelation = "Data Exch.";
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
            NotBlank = true;
        }
        field(3;"Column No.";Integer)
        {
            Caption = 'Column No.';
            NotBlank = true;
        }
        field(4;Value;Text[250])
        {
            Caption = 'Value';
        }
        field(5;"Node ID";Text[250])
        {
            Caption = 'Node ID';
        }
        field(6;"Data Exch. Line Def Code";Code[20])
        {
            Caption = 'Data Exch. Line Def Code';
            TableRelation = "Data Exch. Line Def".Code;
        }
        field(10;"Parent Node ID";Text[250])
        {
            Caption = 'Parent Node ID';
        }
        field(11;"Data Exch. Def Code";Code[20])
        {
            CalcFormula = Lookup("Data Exch."."Data Exch. Def Code" WHERE ("Entry No."=FIELD("Data Exch. No.")));
            Caption = 'Data Exch. Def Code';
            FieldClass = FlowField;
        }
        field(16;"Value BLOB";BLOB)
        {
            Caption = 'Value BLOB';
        }
    }

    keys
    {
        key(Key1;"Data Exch. No.","Line No.","Column No.","Node ID")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure InsertRec(DataExchNo: Integer;LineNo: Integer;ColumnNo: Integer;NewValue: Text;DataExchLineDefCode: Code[20])
    begin
        Init;
        Validate("Data Exch. No.",DataExchNo);
        Validate("Line No.",LineNo);
        Validate("Column No.",ColumnNo);
        SetValueWithoutModifying(NewValue);
        Validate("Data Exch. Line Def Code",DataExchLineDefCode);
        Insert;
    end;

    [Scope('Personalization')]
    procedure InsertRecXMLField(DataExchNo: Integer;LineNo: Integer;ColumnNo: Integer;NodeId: Text[250];NodeValue: Text;DataExchLineDefCode: Code[20])
    begin
        InsertRecXMLFieldWithParentNodeID(DataExchNo,LineNo,ColumnNo,NodeId,'',NodeValue,DataExchLineDefCode)
    end;

    [Scope('Personalization')]
    procedure InsertRecXMLFieldWithParentNodeID(DataExchNo: Integer;LineNo: Integer;ColumnNo: Integer;NodeId: Text[250];ParentNodeId: Text[250];NodeValue: Text;DataExchLineDefCode: Code[20])
    begin
        Init;
        Validate("Data Exch. No.",DataExchNo);
        Validate("Line No.",LineNo);
        Validate("Column No.",ColumnNo);
        Validate("Node ID",NodeId);
        SetValueWithoutModifying(NodeValue);
        Validate("Parent Node ID",ParentNodeId);
        Validate("Data Exch. Line Def Code",DataExchLineDefCode);
        Insert;
    end;

    [Scope('Personalization')]
    procedure InsertRecXMLFieldDefinition(DataExchNo: Integer;LineNo: Integer;NodeId: Text[250];ParentNodeId: Text[250];NewValue: Text[250];DataExchLineDefCode: Code[20])
    begin
        // this record represents the line definition and it has ColumnNo set to -1
        // even if we are not extracting anything from the line, we need to insert the definition
        // so that the child nodes can hook up to their parent.
        InsertRecXMLFieldWithParentNodeID(DataExchNo,LineNo,-1,NodeId,ParentNodeId,NewValue,DataExchLineDefCode)
    end;

    [Scope('Personalization')]
    procedure GetFieldName(): Text
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExch: Record "Data Exch.";
    begin
        DataExch.Get("Data Exch. No.");
        if DataExchColumnDef.Get(DataExch."Data Exch. Def Code",DataExch."Data Exch. Line Def Code","Column No.") then
          exit(DataExchColumnDef.Name);
        exit('');
    end;

    [Scope('Personalization')]
    procedure DeleteRelatedRecords(DataExchNo: Integer;LineNo: Integer)
    begin
        SetRange("Data Exch. No.",DataExchNo);
        SetRange("Line No.",LineNo);
        if not IsEmpty then
          DeleteAll(true);
    end;

    [Scope('Personalization')]
    procedure GetValue(): Text
    var
        TempBlob: Record TempBlob;
        CR: Text[1];
    begin
        if not "Value BLOB".HasValue then
          exit(Value);
        CR[1] := 10;
        CalcFields("Value BLOB");
        TempBlob.Blob := "Value BLOB";
        exit(TempBlob.ReadAsText(CR,TEXTENCODING::Windows));
    end;

    [Scope('Personalization')]
    procedure SetValue(NewValue: Text)
    begin
        SetValueWithoutModifying(NewValue);
        Modify;
    end;

    [Scope('Personalization')]
    procedure SetValueWithoutModifying(NewValue: Text)
    var
        TempBlob: Record TempBlob;
    begin
        Clear("Value BLOB");
        Value := CopyStr(NewValue,1,MaxStrLen(Value));
        if StrLen(NewValue) <= MaxStrLen(Value) then
          exit; // No need to store anything in the blob
        if NewValue = '' then
          exit;
        TempBlob.WriteAsText(NewValue,TEXTENCODING::Windows);
        "Value BLOB" := TempBlob.Blob;
    end;
}

