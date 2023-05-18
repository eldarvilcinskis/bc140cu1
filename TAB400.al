table 400 "XBRL Linkbase"
{
    Caption = 'XBRL Linkbase';

    fields
    {
        field(1;"XBRL Taxonomy Name";Code[20])
        {
            Caption = 'XBRL Taxonomy Name';
            NotBlank = true;
        }
        field(2;"XBRL Schema Line No.";Integer)
        {
            Caption = 'XBRL Schema Line No.';
        }
        field(3;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(4;Description;Text[100])
        {
            Caption = 'Description';
        }
        field(5;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Label,Presentation,Calculation,Reference';
            OptionMembers = Label,Presentation,Calculation,Reference;

            trigger OnValidate()
            begin
                if "Line No." <> 0 then begin
                  CalcFields(XML);
                  if XML.HasValue then
                    Error(Text001,FieldCaption(Type));
                end;
            end;
        }
        field(7;XML;BLOB)
        {
            Caption = 'XML';
            SubType = Memo;
        }
        field(8;"File Name";Text[250])
        {
            Caption = 'File Name';
        }
    }

    keys
    {
        key(Key1;"XBRL Taxonomy Name","XBRL Schema Line No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'You cannot change %1 when you have imported a linkbase.';
}

