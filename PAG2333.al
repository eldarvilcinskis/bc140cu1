page 2333 "BC O365 Net Promoter Score"
{
    Caption = ' ';
    Editable = false;
    PageType = Card;

    layout
    {
        area(content)
        {
            usercontrol(WebPageViewer;"Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = Basic,Suite,Invoicing;

                trigger ControlAddInReady(callbackUrl: Text)
                begin
                    Navigate;
                end;

                trigger DocumentReady()
                begin
                end;

                trigger Callback(data: Text)
                var
                    MessageType: Text;
                begin
                    NetPromoterScoreMgt.TryGetMessageType(data,MessageType);
                    if UpperCase(MessageType) = UpperCase('closeNpsDialog') then
                      CurrPage.Close;
                end;

                trigger Refresh(CallbackUrl: Text)
                begin
                    Navigate;
                end;
            }
        }
    }

    actions
    {
    }

    var
        O365NetPromoterScoreMgt: Codeunit "O365 Net Promoter Score Mgt.";
        NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";

    local procedure Navigate()
    var
        Url: Text;
    begin
        Url := O365NetPromoterScoreMgt.GetInvRenderUrl;
        if Url = '' then
          exit;
        CurrPage.WebPageViewer.SubscribeToEvent('message',Url);
        CurrPage.WebPageViewer.Navigate(Url);
    end;
}

