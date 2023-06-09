page 704 "Merge Duplicate Conflicts"
{
    Caption = 'Merge Duplicate Conflicts';
    Editable = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "Merge Duplicates Conflict";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table ID";"Table ID")
                {
                    ApplicationArea = Basic,Suite;
                }
                field("Table Name";"Table Name")
                {
                    ApplicationArea = Basic,Suite;
                }
                field(Current;GetPK(Current))
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Current';
                    ToolTip = 'Specifies values of the fields in the primary key of the current record.';
                }
                field(Duplicate;GetPK(Duplicate))
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Duplicate';
                    ToolTip = 'Specifies values of the fields in the primary key of the current record.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ViewConflictRecords)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'View Details';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'View the details of conflicting records, rename or remove the duplicate record.';

                trigger OnAction()
                begin
                    if Merge then
                      Delete;
                end;
            }
        }
    }

    [Scope('Personalization')]
    procedure Set(var TempMergeDuplicatesConflict: Record "Merge Duplicates Conflict" temporary)
    begin
        Copy(TempMergeDuplicatesConflict,true);
    end;

    local procedure GetPK(RecordID: RecordID) PrimaryKey: Text
    begin
        PrimaryKey := Format(RecordID);
        PrimaryKey := CopyStr(PrimaryKey,StrPos(PrimaryKey,': ') + 2);
    end;
}

