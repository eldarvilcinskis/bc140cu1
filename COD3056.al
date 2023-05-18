codeunit 3056 DotNet_Capture
{

    trigger OnRun()
    begin
    end;

    var
        DotNetCapture: DotNet Capture;

    [Scope('Personalization')]
    procedure Index(): Integer
    begin
        exit(DotNetCapture.Index);
    end;

    [Scope('Personalization')]
    procedure Length(): Integer
    begin
        exit(DotNetCapture.Length);
    end;

    [Scope('Personalization')]
    procedure Value(): Text
    begin
        exit(DotNetCapture.Value);
    end;

    [Scope('Personalization')]
    procedure Equals(var DotNet_Capture: Codeunit DotNet_Capture): Boolean
    var
        DotNetCapture2: DotNet Capture;
    begin
        DotNet_Capture.GetCapture(DotNetCapture2);

        exit(DotNetCapture.Equals(DotNetCapture2));
    end;

    [Scope('Personalization')]
    procedure GetHashCode(): Integer
    begin
        exit(DotNetCapture.GetHashCode());
    end;

    [Scope('Personalization')]
    procedure IsDotNetNull(): Boolean
    begin
        exit(IsNull(DotNetCapture));
    end;

    procedure GetCapture(var DotNetCapture2: DotNet Capture)
    begin
        DotNetCapture2 := DotNetCapture;
    end;

    procedure SetCapture(var DotNetCapture2: DotNet Capture)
    begin
        DotNetCapture := DotNetCapture2;
    end;
}

