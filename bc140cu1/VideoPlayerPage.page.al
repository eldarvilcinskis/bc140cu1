page 1395 "Video Player Page"
{
    Caption = 'Video Player Page';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    ShowFilter = false;

    layout
    {
        area(content)
        {
            usercontrol(VideoPlayer; "Microsoft.Dynamics.Nav.Client.VideoPlayer")
            {
                ApplicationArea = Basic, Suite;

                trigger AddInReady()
                begin
                    CurrPage.VideoPlayer.SetHeight(Height);
                    CurrPage.VideoPlayer.SetWidth(Width);
                    CurrPage.VideoPlayer.SetFrameAttribute('src', Src);
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        CurrPage.Caption(NewCaption);
    end;

    var
        [InDataSet]
        Height: Integer;
        [InDataSet]
        Width: Integer;
        [InDataSet]
        Src: Text;
        [InDataSet]
        NewCaption: Text;

    [Scope('Personalization')]
    procedure SetParameters(VideoHeight: Integer; VideoWidth: Integer; VideoSrc: Text; PageCaption: Text)
    begin
        Height := VideoHeight;
        Width := VideoWidth;
        Src := VideoSrc;
        NewCaption := PageCaption;
    end;
}

