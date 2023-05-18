page 684 "Date-Time Dialog"
{
    Caption = 'Date-Time Dialog';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(Date;DateValue)
            {
                ApplicationArea = All;
                Caption = 'Date';

                trigger OnValidate()
                begin
                    if TimeValue = 0T then
                      TimeValue := 000000T;
                end;
            }
            field(Time;TimeValue)
            {
                ApplicationArea = All;
                Caption = 'Time';
            }
        }
    }

    actions
    {
    }

    var
        DateValue: Date;
        TimeValue: Time;

    [Scope('Personalization')]
    procedure SetDateTime(DateTime: DateTime)
    begin
        // Setter method to initialize the Date and Time fields on the page

        DateValue := DT2Date(DateTime);
        TimeValue := DT2Time(DateTime);
    end;

    [Scope('Personalization')]
    procedure GetDateTime(): DateTime
    begin
        // Getter method for the entered datatime value

        exit(CreateDateTime(DateValue,TimeValue));
    end;
}

