table 457 "Posted Approval Comment Line"
{
    Caption = 'Posted Approval Comment Line';
    DrillDownPageID = "Posted Approval Comments";
    LookupPageID = "Posted Approval Comments";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(2;"Table ID";Integer)
        {
            Caption = 'Table ID';
        }
        field(4;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(5;"User ID";Code[50])
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
        field(6;"Date and Time";DateTime)
        {
            Caption = 'Date and Time';
        }
        field(7;Comment;Text[80])
        {
            Caption = 'Comment';
        }
        field(8;"Posted Record ID";RecordID)
        {
            Caption = 'Posted Record ID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Table ID","Document No.","Date and Time")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Entry No." = 0 then
          "Entry No." := GetNextEntryNo;
    end;

    local procedure GetNextEntryNo(): Integer
    var
        PostedApprovalCommentLine: Record "Posted Approval Comment Line";
    begin
        PostedApprovalCommentLine.SetCurrentKey("Entry No.");
        if PostedApprovalCommentLine.FindLast then
          exit(PostedApprovalCommentLine."Entry No." + 1);

        exit(1);
    end;
}
