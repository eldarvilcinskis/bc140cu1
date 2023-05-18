page 9980 "Contact MS Sales"
{
    Caption = 'Contact MS Sales';
    Editable = false;

    layout
    {
        area(content)
        {
            usercontrol(WebPageViewer;"Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = Basic,Suite;

                trigger ControlAddInReady(callbackUrl: Text)
                begin
                    CurrPage.WebPageViewer.Navigate(ForwardLinkMgt.GetLanguageSpecificUrl(ContactSalesForwardLinkTxt));
                end;

                trigger DocumentReady()
                begin
                end;

                trigger Callback(data: Text)
                begin
                end;

                trigger Refresh(callbackUrl: Text)
                begin
                    CurrPage.WebPageViewer.Navigate(ForwardLinkMgt.GetLanguageSpecificUrl(ContactSalesForwardLinkTxt));
                end;
            }
        }
    }

    actions
    {
    }

    var
        ContactSalesForwardLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828707', Locked=true;
        ForwardLinkMgt: Codeunit "Forward Link Mgt.";
}

