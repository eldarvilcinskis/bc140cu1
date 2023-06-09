codeunit 3053 "DotNet_MatchCollection"
{

    trigger OnRun()
    begin
    end;

    var
        DotNetMatchCollection: DotNet MatchCollection;

    [Scope('Personalization')]
    procedure "Count"(): Integer
    begin
        exit(DotNetMatchCollection.Count);
    end;

    [Scope('Personalization')]
    procedure Item(Index: Integer; var DotNet_Match: Codeunit DotNet_Match)
    var
        DotNetMatch: DotNet Match;
    begin
        DotNetMatch := DotNetMatchCollection.Item(Index);
        DotNet_Match.SetDotNetMatch(DotNetMatch);
    end;

    [Scope('Personalization')]
    procedure CopyTo(var DotNet_Array: Codeunit DotNet_Array; Index: Integer)
    var
        DotNetArray: DotNet Array;
    begin
        DotNetMatchCollection.CopyTo(DotNetArray, Index);
        DotNet_Array.SetArray(DotNetArray);
    end;

    [Scope('Personalization')]
    procedure Equals(var DotNet_MatchCollection: Codeunit DotNet_MatchCollection): Boolean
    var
        DotNetMatches: DotNet MatchCollection;
    begin
        DotNet_MatchCollection.GetMatchCollection(DotNetMatches);
        exit(DotNetMatchCollection.Equals(DotNetMatches));
    end;

    [Scope('Personalization')]
    procedure GetHashCode(): Integer
    begin
        exit(DotNetMatchCollection.GetHashCode());
    end;

    [Scope('Personalization')]
    procedure IsDotNetNull(): Boolean
    begin
        exit(IsNull(DotNetMatchCollection));
    end;

    procedure GetMatchCollection(var DotNetMatchCollection2: DotNet MatchCollection)
    begin
        DotNetMatchCollection2 := DotNetMatchCollection;
    end;

    procedure SetMatchCollection(var DotNetMatchCollection2: DotNet MatchCollection)
    begin
        DotNetMatchCollection := DotNetMatchCollection2;
    end;
}

