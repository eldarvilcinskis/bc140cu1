table 1610 "Office Add-in"
{
    Caption = 'Office Add-in';
    DataPerCompany = false;

    fields
    {
        field(1;"Application ID";Guid)
        {
            Caption = 'Application ID';
        }
        field(2;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(3;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(5;Version;Text[20])
        {
            Caption = 'Version';
        }
        field(6;"Manifest Codeunit";Integer)
        {
            Caption = 'Manifest Codeunit';
        }
        field(10;"Deployment Date";Date)
        {
            Caption = 'Deployment Date';
        }
        field(12;"Default Manifest";BLOB)
        {
            Caption = 'Default Manifest';
        }
        field(13;Manifest;BLOB)
        {
            Caption = 'Manifest';
        }
        field(14;Breaking;Boolean)
        {
            Caption = 'Breaking';
        }
    }

    keys
    {
        key(Key1;"Application ID")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure GetAddins(): Boolean
    var
        AddinManifestManagement: Codeunit "Add-in Manifest Management";
    begin
        if IsEmpty then
          AddinManifestManagement.CreateDefaultAddins(Rec);

        exit(FindSet);
    end;

    [Scope('Personalization')]
    procedure GetDefaultManifestText() ManifestText: Text
    var
        ManifestInStream: InStream;
    begin
        CalcFields("Default Manifest");
        "Default Manifest".CreateInStream(ManifestInStream,TEXTENCODING::UTF8);
        ManifestInStream.Read(ManifestText);
    end;

    [Scope('Personalization')]
    procedure SetDefaultManifestText(ManifestText: Text)
    var
        ManifestOutStream: OutStream;
    begin
        Clear("Default Manifest");
        "Default Manifest".CreateOutStream(ManifestOutStream,TEXTENCODING::UTF8);
        ManifestOutStream.WriteText(ManifestText);
    end;

    [Scope('Personalization')]
    procedure IsAdminDeployed(): Boolean
    begin
        exit(Format("Deployment Date") <> '');
    end;

    [Scope('Internal')]
    procedure IsBreakingChange(UserVersion: Text) IsBreaking: Boolean
    var
        Components: DotNet Array;
        UserComponents: DotNet Array;
        Separator: DotNet String;
        TempString: DotNet String;
        i: Integer;
    begin
        Separator := '.';
        TempString := UserVersion;
        UserComponents := TempString.Split(Separator.ToCharArray);
        TempString := Version;
        Components := TempString.Split(Separator.ToCharArray);

        for i := 0 to 2 do
          IsBreaking := IsBreaking or (Format(UserComponents.GetValue(i)) <> Format(Components.GetValue(i)));
    end;
}

