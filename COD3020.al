codeunit 3020 DotNet_NavDesignerALFunctions
{

    trigger OnRun()
    begin
    end;

    var
        DotNetNavDesignerALFunctions: DotNet NavDesignerALFunctions;

    [Scope('Internal')]
    procedure GenerateDesignerPackageZipStreamByVersion(var OutStream: OutStream;ID: Guid;VersionString: Text)
    begin
        // do not make external
        DotNetNavDesignerALFunctions.GenerateDesignerPackageZipStreamByVersion(OutStream,ID,VersionString)
    end;

    [Scope('Internal')]
    procedure SanitizeDesignerFileName(Filename: Text;ReplacementCharacter: Char): Text
    begin
        // do not make external
        exit(DotNetNavDesignerALFunctions.SanitizeDesignerFileName(Filename,ReplacementCharacter))
    end;

    [Scope('Internal')]
    procedure GetNavDesignerALFunctions(var DotNetNavDesignerALFunctions2: DotNet NavDesignerALFunctions)
    begin
        DotNetNavDesignerALFunctions2 := DotNetNavDesignerALFunctions
    end;

    [Scope('Internal')]
    procedure SetNavDesignerALFunctions(DotNetNavDesignerALFunctions2: DotNet NavDesignerALFunctions)
    begin
        DotNetNavDesignerALFunctions := DotNetNavDesignerALFunctions2
    end;
}

