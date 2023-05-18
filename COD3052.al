codeunit 3052 DotNet_Match
{

    trigger OnRun()
    begin
    end;

    var
        DotNetMatch: DotNet Match;

    [Scope('Personalization')]
    procedure Groups(var DotNet_GroupCollection: Codeunit DotNet_GroupCollection)
    var
        DotNetGroups: DotNet GroupCollection;
    begin
        DotNetGroups := DotNetMatch.Groups;
        DotNet_GroupCollection.SetGroupCollection(DotNetGroups);
    end;

    [Scope('Personalization')]
    procedure Index(): Integer
    begin
        exit(DotNetMatch.Index);
    end;

    [Scope('Personalization')]
    procedure Length(): Integer
    begin
        exit(DotNetMatch.Length);
    end;

    [Scope('Personalization')]
    procedure Name(): Text
    begin
        exit(DotNetMatch.Name);
    end;

    [Scope('Personalization')]
    procedure Success(): Boolean
    begin
        exit(DotNetMatch.Success);
    end;

    [Scope('Personalization')]
    procedure Value(): Text
    begin
        exit(DotNetMatch.Value);
    end;

    [Scope('Personalization')]
    procedure Equals(var DotNet_Match: Codeunit DotNet_Match): Boolean
    var
        DotNetMatch2: DotNet Match;
    begin
        DotNet_Match.GetDotNetMatch(DotNetMatch2);
        exit(DotNetMatch.Equals(DotNetMatch2));
    end;

    [Scope('Personalization')]
    procedure GetHashCode(): Integer
    begin
        exit(DotNetMatch.GetHashCode());
    end;

    [Scope('Personalization')]
    procedure NextMatch(var NextDotNet_Match: Codeunit DotNet_Match)
    var
        NextDotNetMatch: DotNet Match;
    begin
        NextDotNetMatch := DotNetMatch.NextMatch();
        NextDotNet_Match.SetDotNetMatch(NextDotNetMatch);
    end;

    [Scope('Personalization')]
    procedure Result(Replacement: Text): Text
    begin
        exit(DotNetMatch.Result(Replacement));
    end;

    [Scope('Personalization')]
    procedure IsDotNetNull(): Boolean
    begin
        exit(IsNull(DotNetMatch));
    end;

    procedure GetDotNetMatch(var DotNetMatch2: DotNet Match)
    begin
        DotNetMatch2 := DotNetMatch;
    end;

    procedure SetDotNetMatch(var DotNetMatch2: DotNet Match)
    begin
        DotNetMatch := DotNetMatch2;
    end;
}

