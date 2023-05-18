codeunit 3051 "DotNet_RegexOptions"
{

    trigger OnRun()
    begin
    end;

    var
        DotNetRegexOptions: DotNet RegexOptions;

    [Scope('Personalization')]
    procedure Compiled(): Integer
    begin
        DotNetRegexOptions := DotNetRegexOptions.Compiled;
        exit(DotNetRegexOptions);
    end;

    [Scope('Personalization')]
    procedure CultureInvariant(): Integer
    begin
        DotNetRegexOptions := DotNetRegexOptions.CultureInvariant;
        exit(DotNetRegexOptions);
    end;

    [Scope('Personalization')]
    procedure ECMAScript(): Integer
    begin
        DotNetRegexOptions := DotNetRegexOptions.ECMAScript;
        exit(DotNetRegexOptions);
    end;

    [Scope('Personalization')]
    procedure ExplicitCapture(): Integer
    begin
        DotNetRegexOptions := DotNetRegexOptions.ExplicitCapture;
        exit(DotNetRegexOptions);
    end;

    [Scope('Personalization')]
    procedure IgnoreCase(): Integer
    begin
        DotNetRegexOptions := DotNetRegexOptions.IgnoreCase;
        exit(DotNetRegexOptions);
    end;

    [Scope('Personalization')]
    procedure IgnorePatternWhitespace(): Integer
    begin
        DotNetRegexOptions := DotNetRegexOptions.IgnorePatternWhitespace;
        exit(DotNetRegexOptions);
    end;

    [Scope('Personalization')]
    procedure Multiline(): Integer
    begin
        DotNetRegexOptions := DotNetRegexOptions.Multiline;
        exit(DotNetRegexOptions);
    end;

    [Scope('Personalization')]
    procedure "None"(): Integer
    begin
        DotNetRegexOptions := DotNetRegexOptions.None;
        exit(DotNetRegexOptions);
    end;

    [Scope('Personalization')]
    procedure RightToLeft(): Integer
    begin
        DotNetRegexOptions := DotNetRegexOptions.RightToLeft;
        exit(DotNetRegexOptions);
    end;

    [Scope('Personalization')]
    procedure Singleline(): Integer
    begin
        DotNetRegexOptions := DotNetRegexOptions.Singleline;
        exit(DotNetRegexOptions);
    end;

    [Scope('Personalization')]
    procedure ToString(): Text
    begin
        exit(DotNetRegexOptions.ToString());
    end;

    [Scope('Personalization')]
    procedure ToInteger(): Integer
    begin
        exit(DotNetRegexOptions);
    end;

    [Scope('Personalization')]
    procedure FromInteger(Value: Integer)
    begin
        DotNetRegexOptions := Value;
    end;

    [Scope('Personalization')]
    procedure IsDotNetNull(): Boolean
    begin
        exit(IsNull(DotNetRegexOptions));
    end;

    procedure GetRegexOptions(var DotNetRegexOptions2: DotNet RegexOptions)
    begin
        DotNetRegexOptions2 := DotNetRegexOptions;
    end;

    procedure SetRegexOptions(var DotNetRegexOptions2: DotNet RegexOptions)
    begin
        DotNetRegexOptions := DotNetRegexOptions2;
    end;
}

