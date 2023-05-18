codeunit 3054 DotNet_Group
{

    trigger OnRun()
    begin
    end;

    var
        DotNetGroup: DotNet Group;

    [Scope('Personalization')]
    procedure Captures(var DotNet_CaptureCollection: Codeunit DotNet_CaptureCollection)
    var
        DotNetCaptures: DotNet CaptureCollection;
    begin
        DotNetCaptures := DotNetGroup.Captures;
        DotNet_CaptureCollection.SetCaptureCollection(DotNetCaptures);
    end;

    [Scope('Personalization')]
    procedure Index(): Integer
    begin
        exit(DotNetGroup.Index);
    end;

    [Scope('Personalization')]
    procedure Length(): Integer
    begin
        exit(DotNetGroup.Length);
    end;

    [Scope('Personalization')]
    procedure Name(): Text
    begin
        exit(DotNetGroup.Name);
    end;

    [Scope('Personalization')]
    procedure Success(): Boolean
    begin
        exit(DotNetGroup.Success);
    end;

    [Scope('Personalization')]
    procedure Value(): Text
    begin
        exit(DotNetGroup.Value);
    end;

    [Scope('Personalization')]
    procedure Equals(var DotNet_Group: Codeunit DotNet_Group): Boolean
    var
        DotNetGroup2: DotNet Match;
    begin
        DotNet_Group.GetGroup(DotNetGroup2);
        exit(DotNetGroup.Equals(DotNetGroup2));
    end;

    [Scope('Personalization')]
    procedure GetHashCode(): Integer
    begin
        exit(DotNetGroup.GetHashCode());
    end;

    [Scope('Personalization')]
    procedure IsDotNetNull(): Boolean
    begin
        exit(IsNull(DotNetGroup));
    end;

    procedure GetGroup(var DotNetGroup2: DotNet Group)
    begin
        DotNetGroup2 := DotNetGroup;
    end;

    procedure SetGroup(var DotNetGroup2: DotNet Group)
    begin
        DotNetGroup := DotNetGroup2;
    end;
}

