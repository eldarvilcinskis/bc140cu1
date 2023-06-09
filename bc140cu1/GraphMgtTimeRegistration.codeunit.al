codeunit 5513 "Graph Mgt - Time Registration"
{

    trigger OnRun()
    begin
    end;

    procedure InitUserSetup()
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId) then begin
            UserSetup.Validate("User ID", UserId);
            UserSetup.Validate("Time Sheet Admin.", true);
            UserSetup.Insert(true);
        end;
    end;

    procedure ModifyResourceToUseTimeSheet(var Resource: Record Resource)
    begin
        if SetResourceFieldsToUseTimeSheet(Resource) then
            Resource.Modify(true);
    end;

    procedure CreateResourceToUseTimeSheet(var Resource: Record Resource)
    var
        TempFieldSet: Record "Field" temporary;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        ResourceRecRef: RecordRef;
    begin
        Clear(Resource);
        Resource.Insert(true);

        ResourceRecRef.GetTable(Resource);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(ResourceRecRef, TempFieldSet, CreateDateTime(Resource."Last Date Modified", 0T));
        ResourceRecRef.SetTable(Resource);

        ModifyResourceToUseTimeSheet(Resource);
    end;

    procedure GetTimeSheetHeader(ResouceNo: Code[20]; StartingDate: Date): Code[20]
    var
        TimeSheetHeader: Record "Time Sheet Header";
    begin
        TimeSheetHeader.Reset;
        TimeSheetHeader.SetRange("Starting Date", StartingDate);
        TimeSheetHeader.SetRange("Resource No.", ResouceNo);
        if not TimeSheetHeader.FindFirst then begin
            CreateTimeSheetHeader(StartingDate, ResouceNo);
            TimeSheetHeader.FindFirst;
        end;

        exit(TimeSheetHeader."No.");
    end;

    procedure GetTimeSheetLineWithEmptyDate(var TimeSheetLine: Record "Time Sheet Line"; TimeSheetHeaderNo: Code[20]; TimeSheetDetailDate: Date)
    var
        TimeSheetDetail: Record "Time Sheet Detail";
        TimeSheetLineNo: Integer;
    begin
        TimeSheetLine.Reset;
        TimeSheetLine.SetRange(Type, TimeSheetDetail.Type::Resource);
        TimeSheetLine.SetRange(Status, TimeSheetLine.Status::Open);
        TimeSheetLine.SetRange("Time Sheet No.", TimeSheetHeaderNo);
        if TimeSheetLine.FindSet then
            repeat
                if not TimeSheetDetail.Get(TimeSheetHeaderNo, TimeSheetLine."Line No.", TimeSheetDetailDate) then
                    exit;
            until TimeSheetLine.Next = 0;

        TimeSheetLine.Reset;
        TimeSheetLine.SetRange("Time Sheet No.", TimeSheetHeaderNo);
        if TimeSheetLine.FindLast then
            TimeSheetLineNo := TimeSheetLine."Line No." + 10000
        else
            TimeSheetLineNo := 10000;

        CreateTimeSheetLine(TimeSheetHeaderNo, TimeSheetLineNo);
        TimeSheetLine.Get(TimeSheetHeaderNo, TimeSheetLineNo);
    end;

    procedure AddTimeSheetDetail(var TimeSheetDetail: Record "Time Sheet Detail"; TimeSheetLine: Record "Time Sheet Line"; Date: Date; Quantity: Decimal)
    begin
        Clear(TimeSheetDetail);
        TimeSheetDetail.CopyFromTimeSheetLine(TimeSheetLine);
        TimeSheetDetail.Date := Date;
        TimeSheetDetail.Quantity := Quantity;
        TimeSheetDetail.Insert(true);
    end;

    procedure UpdateIntegrationRecords(OnlyTimeSheetDetailsWithoutId: Boolean)
    var
        DummyTimeSheetDetail: Record "Time Sheet Detail";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        TimeSheetDetailRecordRef: RecordRef;
    begin
        TimeSheetDetailRecordRef.Open(DATABASE::"Time Sheet Detail");
        GraphMgtGeneralTools.UpdateIntegrationRecords(
          TimeSheetDetailRecordRef, DummyTimeSheetDetail.FieldNo(Id), OnlyTimeSheetDetailsWithoutId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5465, 'ApiSetup', '', false, false)]
    local procedure HandleApiSetup()
    begin
        UpdateIntegrationRecords(false);
    end;

    local procedure SetResourceFieldsToUseTimeSheet(var Resource: Record Resource): Boolean
    begin
        if Resource."Use Time Sheet" and
           (Resource."Time Sheet Approver User ID" <> '') and
           (Resource."Time Sheet Owner User ID" <> '')
        then
            exit(false);

        if not Resource."Use Time Sheet" then
            Resource.Validate("Use Time Sheet", true);
        if Resource."Time Sheet Approver User ID" = '' then
            Resource.Validate("Time Sheet Approver User ID", UserId);
        if Resource."Time Sheet Owner User ID" = '' then
            Resource.Validate("Time Sheet Owner User ID", UserId);

        exit(true);
    end;

    local procedure CreateTimeSheetHeader(StartingDate: Date; ResourceNumber: Code[20])
    var
        CreateTimeSheets: Report "Create Time Sheets";
    begin
        CreateTimeSheets.InitParameters(StartingDate, 1, ResourceNumber, false, true);
        CreateTimeSheets.UseRequestPage(false);
        CreateTimeSheets.Run;
    end;

    local procedure CreateTimeSheetLine(TimeSheetHeaderNo: Code[20]; TimeSheetLineNo: Integer)
    var
        TimeSheetLine: Record "Time Sheet Line";
    begin
        TimeSheetLine."Time Sheet No." := TimeSheetHeaderNo;
        TimeSheetLine."Line No." := TimeSheetLineNo;
        TimeSheetLine.Type := TimeSheetLine.Type::Resource;
        TimeSheetLine.Insert(true);
    end;
}

