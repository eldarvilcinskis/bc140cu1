codeunit 3004 DotNet_DateTimeStyles
{

    trigger OnRun()
    begin
    end;

    var
        DotNetDateTimeStyles: DotNet DateTimeStyles;

    [Scope('Personalization')]
    procedure "None"()
    begin
        DotNetDateTimeStyles := DotNetDateTimeStyles.None
    end;

    procedure GetDateTimeStyles(var DotNetDateTimeStyles2: DotNet DateTimeStyles)
    begin
        DotNetDateTimeStyles2 := DotNetDateTimeStyles
    end;

    procedure SetDateTimeStyles(DotNetDateTimeStyles2: DotNet DateTimeStyles)
    begin
        DotNetDateTimeStyles := DotNetDateTimeStyles2
    end;
}

