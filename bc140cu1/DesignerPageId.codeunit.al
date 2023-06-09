codeunit 9621 "DesignerPageId"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        DesignerPageId: Integer;

    [Scope('Personalization')]
    procedure GetPageId(): Integer
    begin
        exit(DesignerPageId);
    end;

    [Scope('Personalization')]
    procedure SetPageId(PageId: Integer): Boolean
    begin
        DesignerPageId := PageId;
        exit(true);
    end;
}

