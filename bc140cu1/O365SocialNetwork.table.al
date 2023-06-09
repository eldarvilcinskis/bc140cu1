table 2122 "O365 Social Network"
{
    Caption = 'O365 Social Network';
    ReplicateData = false;

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(2;Name;Text[30])
        {
            Caption = 'Name';
        }
        field(3;URL;Text[250])
        {
            Caption = 'URL';

            trigger OnValidate()
            begin
                URL := ConvertStr(URL,'\','/');
                ValidateURLPrefix;
            end;
        }
        field(5;"Media Resources Ref";Code[50])
        {
            Caption = 'Media Resources Ref';
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
    }

    trigger OnInsert()
    var
        CompanyInformation: Record "Company Information";
    begin
        if CompanyInformation.Get then
          CompanyInformation.Modify(true);
    end;

    trigger OnModify()
    var
        CompanyInformation: Record "Company Information";
    begin
        if CompanyInformation.Get then
          CompanyInformation.Modify(true);
    end;

    local procedure ValidateURLPrefix()
    begin
        if URL = '' then
          exit;

        if StrPos(LowerCase(URL),'http') <> 1 then
          URL := 'http://' + URL;
    end;
}

