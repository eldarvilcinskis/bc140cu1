page 1820 "Video link Part"
{
    Caption = 'Video link Part';
    Editable = false;
    PageType = CardPart;

    layout
    {
        area(content)
        {
            usercontrol(WebPageViewer; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = Basic, Suite;

                trigger ControlAddInReady(callbackUrl: Text)
                begin
                    CurrPage.WebPageViewer.Navigate(URL);
                end;

                trigger DocumentReady()
                begin
                end;

                trigger Callback(data: Text)
                begin
                    CurrPage.Close;
                end;
            }
        }
    }

    actions
    {
    }

    var
        URL: Text;

    [Scope('Personalization')]
    procedure SetURL(NavigateToURL: Text)
    begin
        URL := NavigateToURL;
    end;

    procedure Navigate(NavigateToUrl: Text)
    begin
        URL := NavigateToUrl;
        CurrPage.WebPageViewer.Navigate(URL);
    end;
}

