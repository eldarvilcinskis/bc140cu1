table 8623 "Config. Package"
{
    Caption = 'Config. Package';
    LookupPageID = "Config. Packages";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;"Package Name";Text[50])
        {
            Caption = 'Package Name';
        }
        field(4;"Language ID";Integer)
        {
            Caption = 'Language ID';
            TableRelation = "Windows Language";
        }
        field(5;"No. of Tables";Integer)
        {
            CalcFormula = Count("Config. Package Table" WHERE ("Package Code"=FIELD(Code)));
            Caption = 'No. of Tables';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6;"Product Version";Text[248])
        {
            Caption = 'Product Version';
        }
        field(11;"Exclude Config. Tables";Boolean)
        {
            Caption = 'Exclude Config. Tables';
        }
        field(12;"Processing Order";Integer)
        {
            Caption = 'Processing Order';

            trigger OnValidate()
            var
                ConfigPackageTable: Record "Config. Package Table";
            begin
                ConfigPackageTable.SetRange("Package Code",Code);
                ConfigPackageTable.ModifyAll("Package Processing Order","Processing Order");
            end;
        }
        field(13;"No. of Records";Integer)
        {
            CalcFormula = Count("Config. Package Record" WHERE ("Package Code"=FIELD(Code)));
            Caption = 'No. of Records';
            Editable = false;
            FieldClass = FlowField;
        }
        field(16;"No. of Errors";Integer)
        {
            CalcFormula = Count("Config. Package Error" WHERE ("Package Code"=FIELD(Code)));
            Caption = 'No. of Errors';
            Editable = false;
            FieldClass = FlowField;
        }
        field(17;"Import Status";Option)
        {
            Caption = 'Import Status';
            DataClassification = SystemMetadata;
            Editable = false;
            OptionCaption = 'No,Scheduled,InProgress,Completed,Error', Locked=true;
            OptionMembers = No,Scheduled,InProgress,Completed,Error;
        }
        field(18;"Apply Status";Option)
        {
            Caption = 'Apply Status';
            DataClassification = SystemMetadata;
            Editable = false;
            OptionCaption = 'No,Scheduled,InProgress,Completed,Error', Locked=true;
            OptionMembers = No,Scheduled,InProgress,Completed,Error;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
        key(Key2;"Processing Order")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigLine: Record "Config. Line";
        ConfigMediaBuffer: Record "Config. Media Buffer";
        TenantConfigPackageFile: Record "Tenant Config. Package File";
    begin
        ConfigPackageTable.DeletePackageDataForPackage(Code,0);
        ConfigPackageTable.DeleteRelatedTables(Code,0);
        ConfigPackageTable.SetRange("Package Code",Code);
        ConfigPackageTable.DeleteAll;

        ConfigMediaBuffer.SetRange("Package Code",Code);
        ConfigMediaBuffer.DeleteAll;

        ConfigLine.SetRange("Package Code",Code);
        ConfigLine.ModifyAll("Package Code",'');

        TenantConfigPackageFile.SetRange(Code,Code);
        TenantConfigPackageFile.DeleteAll;
    end;

    procedure ShowErrors()
    var
        ConfigPackageError: Record "Config. Package Error";
    begin
        ConfigPackageError.FilterGroup(2);
        ConfigPackageError.SetRange("Package Code",Code);
        ConfigPackageError.FilterGroup(0);
        if not ConfigPackageError.IsEmpty then
          PAGE.Run(PAGE::"Config. Package Errors",ConfigPackageError);
    end;
}

