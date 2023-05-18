codeunit 3040 "DotNet_XsltArgumentList"
{

    trigger OnRun()
    begin
    end;

    var
        DotNetXsltArgumentList: DotNet XsltArgumentList;

    procedure GetXsltArgumentList(var DotNetXsltArgumentList2: DotNet XsltArgumentList)
    begin
        DotNetXsltArgumentList2 := DotNetXsltArgumentList;
    end;

    procedure SetXsltArgumentList(var DotNetXsltArgumentList2: DotNet XsltArgumentList)
    begin
        DotNetXsltArgumentList := DotNetXsltArgumentList2
    end;
}

