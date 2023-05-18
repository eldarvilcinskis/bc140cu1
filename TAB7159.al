table 7159 "Analysis Selected Dimension"
{
    Caption = 'Analysis Selected Dimension';

    fields
    {
        field(1;"User ID";Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("User ID");
            end;
        }
        field(2;"Object Type";Integer)
        {
            Caption = 'Object Type';
        }
        field(3;"Object ID";Integer)
        {
            Caption = 'Object ID';
        }
        field(4;"Dimension Code";Text[30])
        {
            Caption = 'Dimension Code';
        }
        field(5;"New Dimension Value Code";Code[20])
        {
            Caption = 'New Dimension Value Code';
        }
        field(6;"Dimension Value Filter";Code[250])
        {
            Caption = 'Dimension Value Filter';
        }
        field(7;Level;Option)
        {
            Caption = 'Level';
            OptionCaption = ' ,Level 1,Level 2,Level 3';
            OptionMembers = " ","Level 1","Level 2","Level 3";
        }
        field(8;"Analysis View Code";Code[10])
        {
            Caption = 'Analysis View Code';
            TableRelation = "Item Analysis View".Code WHERE ("Analysis Area"=FIELD("Analysis Area"));
        }
        field(9;"Analysis Area";Option)
        {
            Caption = 'Analysis Area';
            OptionCaption = 'Sales,Purchase,Inventory';
            OptionMembers = Sales,Purchase,Inventory;
        }
    }

    keys
    {
        key(Key1;"User ID","Object Type","Object ID","Analysis Area","Analysis View Code","Dimension Code")
        {
        }
        key(Key2;"User ID","Object Type","Object ID","Analysis Area","Analysis View Code",Level,"Dimension Code")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure GetSelectedDim(UserID2: Code[50];ObjectType: Integer;ObjectID: Integer;AnalysisArea: Integer;AnalysisViewCode: Code[10];var TempAnalysisSelectedDim: Record "Analysis Selected Dimension" temporary)
    begin
        SetRange("User ID",UserID2);
        SetRange("Object Type",ObjectType);
        SetRange("Object ID",ObjectID);
        SetRange("Analysis Area",AnalysisArea);
        SetRange("Analysis View Code",AnalysisViewCode);
        if Find('-') then
          repeat
            TempAnalysisSelectedDim := Rec;
            TempAnalysisSelectedDim.Insert;
          until Next = 0;
    end;
}
