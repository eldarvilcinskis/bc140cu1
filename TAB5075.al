table 5075 "Logged Segment"
{
    Caption = 'Logged Segment';
    LookupPageID = "Logged Segments";
    ReplicateData = false;

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(2;"Segment No.";Code[20])
        {
            Caption = 'Segment No.';
        }
        field(3;Description;Text[100])
        {
            Caption = 'Description';
        }
        field(4;"No. of Interactions";Integer)
        {
            CalcFormula = Count("Interaction Log Entry" WHERE ("Logged Segment Entry No."=FIELD("Entry No."),
                                                               Canceled=FIELD(Canceled)));
            Caption = 'No. of Interactions';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5;"No. of Campaign Entries";Integer)
        {
            CalcFormula = Count("Campaign Entry" WHERE ("Register No."=FIELD("Entry No."),
                                                        Canceled=FIELD(Canceled)));
            Caption = 'No. of Campaign Entries';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6;"Creation Date";Date)
        {
            Caption = 'Creation Date';
        }
        field(7;"User ID";Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("User ID");
            end;
        }
        field(8;Canceled;Boolean)
        {
            Caption = 'Canceled';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Segment No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"Entry No.",Description,"Segment No.","Creation Date")
        {
        }
    }

    var
        Text000: Label '%1 %2 is marked %3.\Do you wish to remove the checkmark?';
        Text002: Label 'Do you wish to mark %1 %2 as %3?';
        Text005: Label 'Do you wish to remove the checkmark from the selected %1 lines?';
        Text006: Label 'Do you wish to mark the selected %1 lines as %2? ';

    [Scope('Personalization')]
    procedure ToggleCanceledCheckmark()
    var
        MasterCanceledCheckmark: Boolean;
    begin
        if Find('-') then begin
          if ConfirmToggleCanceledCheckmark(Count) then begin
            MasterCanceledCheckmark := not Canceled;
            repeat
              SetCanceledCheckmark(MasterCanceledCheckmark);
            until Next = 0
          end;
        end
    end;

    [Scope('Personalization')]
    procedure SetCanceledCheckmark(CanceledCheckmark: Boolean)
    var
        InteractLogEntry: Record "Interaction Log Entry";
        CampaignEntry: Record "Campaign Entry";
    begin
        Canceled := CanceledCheckmark;
        Modify;

        CampaignEntry.SetCurrentKey("Register No.");
        CampaignEntry.SetRange("Register No.","Entry No.");
        CampaignEntry.ModifyAll(Canceled,Canceled);

        InteractLogEntry.SetCurrentKey("Logged Segment Entry No.");
        InteractLogEntry.SetRange("Logged Segment Entry No.","Entry No.");
        InteractLogEntry.ModifyAll(Canceled,Canceled);
    end;

    local procedure ConfirmToggleCanceledCheckmark(NumberOfSelectedLines: Integer): Boolean
    begin
        if NumberOfSelectedLines = 1 then begin
          if Canceled then
            exit(Confirm(Text000,true,TableCaption,"Entry No.",FieldCaption(Canceled)));

          exit(Confirm(Text002,true,TableCaption,"Entry No.",FieldCaption(Canceled)));
        end;

        if Canceled then
          exit(Confirm(Text005,true,TableCaption));

        exit(Confirm(Text006,true,TableCaption,FieldCaption(Canceled)));
    end;
}

