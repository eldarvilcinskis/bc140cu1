codeunit 3001 "DotNet_Regex"
{

    trigger OnRun()
    begin
    end;

    var
        DotNetRegex: DotNet Regex;

    [Scope('Personalization')]
    procedure Split(Input: Text; Pattern: Text; var DotNet_Array: Codeunit DotNet_Array)
    var
        DotNetArray: DotNet Array;
    begin
        DotNetArray := DotNetRegex.Split(Input, Pattern);
        DotNet_Array.SetArray(DotNetArray)
    end;

    [Scope('Personalization')]
    procedure Regex(Pattern: Text)
    begin
        DotNetRegex := DotNetRegex.Regex(Pattern)
    end;

    [Scope('Personalization')]
    procedure Replace(Input: Text; Evaluator: Text): Text
    begin
        exit(DotNetRegex.Replace(Input, Evaluator))
    end;

    [Scope('Personalization')]
    procedure RegexWithOptions(Pattern: Text; var DotNet_RegexOptions: Codeunit DotNet_RegexOptions)
    var
        DotNetRegexOptions: DotNet RegexOptions;
    begin
        DotNet_RegexOptions.GetRegexOptions(DotNetRegexOptions);
        DotNetRegex := DotNetRegex.Regex(Pattern, DotNetRegexOptions);
    end;

    [Scope('Personalization')]
    procedure RegexWithOptionsAndMatchTimeout(Pattern: Text; var DotNet_RegexOptions: Codeunit DotNet_RegexOptions; MatchTimeout: Duration)
    var
        DotNetRegexOptions: DotNet RegexOptions;
    begin
        DotNet_RegexOptions.GetRegexOptions(DotNetRegexOptions);
        DotNetRegex := DotNetRegex.Regex(Pattern, DotNetRegexOptions, MatchTimeout);
    end;

    [Scope('Personalization')]
    procedure GetCacheSize(): Integer
    begin
        exit(DotNetRegex.CacheSize);
    end;

    [Scope('Personalization')]
    procedure SetCacheSize(CacheSize: Integer)
    begin
        DotNetRegex.CacheSize := CacheSize;
    end;

    [Scope('Personalization')]
    procedure GetGroupNames(var DotNet_Array: Codeunit DotNet_Array)
    var
        DotNetNames: DotNet Array;
    begin
        DotNetNames := DotNetRegex.GetGroupNames();
        DotNet_Array.SetArray(DotNetNames);
    end;

    [Scope('Personalization')]
    procedure GetGroupNumbers(var DotNet_Array: Codeunit DotNet_Array)
    var
        DotNetNumbers: DotNet Array;
    begin
        DotNetNumbers := DotNetRegex.GetGroupNumbers();
        DotNet_Array.SetArray(DotNetNumbers);
    end;

    [Scope('Personalization')]
    procedure GroupNameFromNumber(Number: Integer): Text
    begin
        exit(DotNetRegex.GroupNameFromNumber(Number));
    end;

    [Scope('Personalization')]
    procedure GroupNumberFromName(Name: Text): Integer
    begin
        exit(DotNetRegex.GroupNumberFromName(Name));
    end;

    [Scope('Personalization')]
    procedure IsMatch(Input: Text): Boolean
    begin
        exit(DotNetRegex.IsMatch(Input));
    end;

    [Scope('Personalization')]
    procedure IsMatch2(Input: Text; StartAt: Integer): Boolean
    begin
        exit(DotNetRegex.IsMatch(Input, StartAt));
    end;

    [Scope('Personalization')]
    procedure IsMatch3(Input: Text; Pattern: Text): Boolean
    begin
        exit(DotNetRegex.IsMatch(Input, Pattern));
    end;

    [Scope('Personalization')]
    procedure IsMatch4(Input: Text; Pattern: Text; var DotNet_RegexOptions: Codeunit DotNet_RegexOptions): Boolean
    var
        DotNetRegexOptions: DotNet RegexOptions;
    begin
        DotNet_RegexOptions.GetRegexOptions(DotNetRegexOptions);
        exit(DotNetRegex.IsMatch(Input, Pattern, DotNetRegexOptions));
    end;

    [Scope('Personalization')]
    procedure IsMatch5(Input: Text; Pattern: Text; var DotNet_RegexOptions: Codeunit DotNet_RegexOptions; MatchTimeout: Duration): Boolean
    var
        DotNetRegexOptions: DotNet RegexOptions;
    begin
        DotNet_RegexOptions.GetRegexOptions(DotNetRegexOptions);
        exit(DotNetRegex.IsMatch(Input, Pattern, DotNetRegexOptions, MatchTimeout));
    end;

    [Scope('Personalization')]
    procedure Match(Input: Text; var DotNet_Match: Codeunit DotNet_Match)
    var
        DotNetMatch: DotNet Match;
    begin
        DotNetMatch := DotNetRegex.Match(Input);
        DotNet_Match.SetDotNetMatch(DotNetMatch);
    end;

    [Scope('Personalization')]
    procedure Match2(Input: Text; StartAt: Integer; var DotNet_Match: Codeunit DotNet_Match)
    var
        DotNetMatch: DotNet Match;
    begin
        DotNetMatch := DotNetRegex.Match(Input, StartAt);
        DotNet_Match.SetDotNetMatch(DotNetMatch);
    end;

    [Scope('Personalization')]
    procedure Match3(Input: Text; Beginning: Integer; Length: Integer; var DotNet_Match: Codeunit DotNet_Match)
    var
        DotNetMatch: DotNet Match;
    begin
        DotNetMatch := DotNetRegex.Match(Input, Beginning, Length);
        DotNet_Match.SetDotNetMatch(DotNetMatch);
    end;

    [Scope('Personalization')]
    procedure Match4(Input: Text; Pattern: Text; var DotNet_Match: Codeunit DotNet_Match)
    var
        DotNetMatch: DotNet Match;
    begin
        DotNetMatch := DotNetRegex.Match(Input, Pattern);
        DotNet_Match.SetDotNetMatch(DotNetMatch);
    end;

    [Scope('Personalization')]
    procedure Match5(Input: Text; Pattern: Text; var DotNet_RegexOptions: Codeunit DotNet_RegexOptions; var DotNet_Match: Codeunit DotNet_Match)
    var
        DotNetMatch: DotNet Match;
        DotNetRegexOptions: DotNet RegexOptions;
    begin
        DotNet_RegexOptions.GetRegexOptions(DotNetRegexOptions);

        DotNetMatch := DotNetRegex.Match(Input, Pattern, DotNetRegexOptions);
        DotNet_Match.SetDotNetMatch(DotNetMatch);
    end;

    [Scope('Personalization')]
    procedure Match6(Input: Text; Pattern: Text; var DotNet_RegexOptions: Codeunit DotNet_RegexOptions; MatchTimeout: Duration; var DotNet_Match: Codeunit DotNet_Match)
    var
        DotNetRegexOptions: DotNet RegexOptions;
        DotNetMatch: DotNet Match;
    begin
        DotNet_RegexOptions.GetRegexOptions(DotNetRegexOptions);

        DotNetMatch := DotNetRegex.Match(Input, Pattern, DotNetRegexOptions, MatchTimeout);
        DotNet_Match.SetDotNetMatch(DotNetMatch);
    end;

    [Scope('Personalization')]
    procedure Matches(Input: Text; var DotNet_MatchCollection: Codeunit DotNet_MatchCollection)
    var
        DotNetMatchCollection: DotNet MatchCollection;
    begin
        DotNetMatchCollection := DotNetRegex.Matches(Input);
        DotNet_MatchCollection.SetMatchCollection(DotNetMatchCollection);
    end;

    [Scope('Personalization')]
    procedure Matches2(Input: Text; StartAt: Integer; var DotNet_MatchCollection: Codeunit DotNet_MatchCollection)
    var
        DotNetMatchCollection: DotNet MatchCollection;
    begin
        DotNetMatchCollection := DotNetRegex.Matches(Input, StartAt);
        DotNet_MatchCollection.SetMatchCollection(DotNetMatchCollection);
    end;

    [Scope('Personalization')]
    procedure Matches3(Input: Text; Pattern: Text; var DotNet_MatchCollection: Codeunit DotNet_MatchCollection)
    var
        DotNetMatchCollection: DotNet MatchCollection;
    begin
        DotNetMatchCollection := DotNetRegex.Matches(Input, Pattern);
        DotNet_MatchCollection.SetMatchCollection(DotNetMatchCollection);
    end;

    [Scope('Personalization')]
    procedure Matches4(Input: Text; Pattern: Text; var DotNet_RegexOptions: Codeunit DotNet_RegexOptions; var DotNet_MatchCollection: Codeunit DotNet_MatchCollection)
    var
        DotNetMatchCollection: DotNet MatchCollection;
        DotNetRegexOptions: DotNet RegexOptions;
    begin
        DotNet_RegexOptions.GetRegexOptions(DotNetRegexOptions);

        DotNetMatchCollection := DotNetRegex.Matches(Input, Pattern, DotNetRegexOptions);
        DotNet_MatchCollection.SetMatchCollection(DotNetMatchCollection);
    end;

    [Scope('Personalization')]
    procedure Matches5(Input: Text; Pattern: Text; var DotNet_RegexOptions: Codeunit DotNet_RegexOptions; MatchTimeout: Duration; var DotNet_MatchCollection: Codeunit DotNet_MatchCollection)
    var
        DotNetMatchCollection: DotNet MatchCollection;
        DotNetRegexOptions: DotNet RegexOptions;
    begin
        DotNet_RegexOptions.GetRegexOptions(DotNetRegexOptions);

        DotNetMatchCollection := DotNetRegex.Matches(Input, Pattern, DotNetRegexOptions, MatchTimeout);
        DotNet_MatchCollection.SetMatchCollection(DotNetMatchCollection);
    end;

    [Scope('Personalization')]
    procedure Replace2(Input: Text; Replacement: Text; "Count": Integer): Text
    begin
        exit(DotNetRegex.Replace(Input, Replacement, Count));
    end;

    [Scope('Personalization')]
    procedure Replace3(Input: Text; Replacement: Text; "Count": Integer; StartAt: Integer): Text
    begin
        exit(DotNetRegex.Replace(Input, Replacement, Count, StartAt));
    end;

    [Scope('Personalization')]
    procedure Replace4(Input: Text; Pattern: Text; Replacement: Text): Text
    begin
        exit(DotNetRegex.Replace(Input, Pattern, Replacement));
    end;

    [Scope('Personalization')]
    procedure Replace5(Input: Text; Pattern: Text; Replacement: Text; var DotNet_RegexOptions: Codeunit DotNet_RegexOptions): Text
    var
        DotNetRegexOptions: DotNet RegexOptions;
    begin
        DotNet_RegexOptions.GetRegexOptions(DotNetRegexOptions);

        exit(DotNetRegex.Replace(Input, Pattern, Replacement, DotNetRegexOptions));
    end;

    [Scope('Personalization')]
    procedure Replace6(Input: Text; Pattern: Text; Replacement: Text; var DotNet_RegexOptions: Codeunit DotNet_RegexOptions; MatchTimeout: Duration): Text
    var
        DotNetRegexOptions: DotNet RegexOptions;
    begin
        DotNet_RegexOptions.GetRegexOptions(DotNetRegexOptions);

        exit(DotNetRegex.Replace(Input, Pattern, Replacement, DotNetRegexOptions, MatchTimeout));
    end;

    [Scope('Personalization')]
    procedure Split2(Input: Text; var StringDotNet_Array: Codeunit DotNet_Array)
    var
        StringsDotNetArray: DotNet Array;
    begin
        StringsDotNetArray := DotNetRegex.Split(Input);
        StringDotNet_Array.SetArray(StringsDotNetArray);
    end;

    [Scope('Personalization')]
    procedure Split3(Input: Text; "Count": Integer; var StringDotNet_Array: Codeunit DotNet_Array)
    var
        StringsDotNetArray: DotNet Array;
    begin
        StringsDotNetArray := DotNetRegex.Split(Input, Count);
        StringDotNet_Array.SetArray(StringsDotNetArray);
    end;

    [Scope('Personalization')]
    procedure Split4(Input: Text; "Count": Integer; StartAt: Integer; var StringDotNet_Array: Codeunit DotNet_Array)
    var
        StringsDotNetArray: DotNet Array;
    begin
        StringsDotNetArray := DotNetRegex.Split(Input, Count, StartAt);
        StringDotNet_Array.SetArray(StringsDotNetArray);
    end;

    [Scope('Personalization')]
    procedure Split5(Input: Text; Pattern: Text; var DotNet_RegexOptions: Codeunit DotNet_RegexOptions; var StringDotNet_Array: Codeunit DotNet_Array)
    var
        DotNetRegexOptions: DotNet RegexOptions;
        StringsDotNetArray: DotNet Array;
    begin
        DotNet_RegexOptions.GetRegexOptions(DotNetRegexOptions);

        StringsDotNetArray := DotNetRegex.Split(Input, Pattern, DotNetRegexOptions);
        StringDotNet_Array.SetArray(StringsDotNetArray);
    end;

    [Scope('Personalization')]
    procedure Split6(Input: Text; Pattern: Text; var DotNet_RegexOptions: Codeunit DotNet_RegexOptions; MatchTimeout: Duration; var StringDotNet_Array: Codeunit DotNet_Array)
    var
        DotNetRegexOptions: DotNet RegexOptions;
        StringsDotNetArray: DotNet Array;
    begin
        DotNet_RegexOptions.GetRegexOptions(DotNetRegexOptions);

        StringsDotNetArray := DotNetRegex.Split(Input, Pattern, DotNetRegexOptions, MatchTimeout);
        StringDotNet_Array.SetArray(StringsDotNetArray);
    end;

    [Scope('Personalization')]
    procedure GetHashCode(): Integer
    begin
        exit(DotNetRegex.GetHashCode());
    end;

    [Scope('Personalization')]
    procedure Escape(String: Text): Text
    begin
        exit(DotNetRegex.Escape(String));
    end;

    [Scope('Personalization')]
    procedure Unescape(String: Text): Text
    begin
        exit(DotNetRegex.Unescape(String));
    end;

    [Scope('Personalization')]
    procedure IsDotNetNull(): Boolean
    begin
        exit(IsNull(DotNetRegex));
    end;

    procedure GetRegEx(var DotNetRegex2: DotNet Regex)
    begin
        DotNetRegex2 := DotNetRegex
    end;

    procedure SetRegEx(DotNetRegex2: DotNet Regex)
    begin
        DotNetRegex := DotNetRegex2
    end;
}

