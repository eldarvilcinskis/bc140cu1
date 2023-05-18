page 1821 "Video link"
{
    Caption = 'Video link';
    Editable = false;
    PageType = Card;

    layout
    {
        area(content)
        {
            group(Control5)
            {
                ShowCaption = false;
            }
            usercontrol(WebPageViewer; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = Basic, Suite, Invoicing;

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

