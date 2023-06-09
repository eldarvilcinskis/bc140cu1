table 1518 "My Notifications"
{
    Caption = 'My Notifications';

    fields
    {
        field(1;"User Id";Code[50])
        {
            Caption = 'User Id';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            NotBlank = true;
        }
        field(2;"Notification Id";Guid)
        {
            Caption = 'Notification Id';
            Editable = false;
            NotBlank = true;
        }
        field(3;"Apply to Table Id";Integer)
        {
            Caption = 'Apply to Table Id';
            Editable = false;
        }
        field(4;Enabled;Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            begin
                if Enabled <> xRec.Enabled then
                  OnStateChanged("Notification Id",Enabled);
            end;
        }
        field(5;"Apply to Table Filter";BLOB)
        {
            Caption = 'Filter';
        }
        field(6;Name;Text[128])
        {
            Caption = 'Notification';
            Editable = false;
            NotBlank = true;
        }
        field(7;Description;BLOB)
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"User Id","Notification Id")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ViewFilterDetailsTxt: Label '(View filter details)';
        DefineFiltersTxt: Label 'Define filters...';

    [Scope('Personalization')]
    procedure Disable(NotificationId: Guid): Boolean
    begin
        if Get(UserId,NotificationId) then begin
          Validate(Enabled,false);
          Modify;
          exit(true)
        end;
        exit(false);
    end;

    local procedure IsFilterEnabled(): Boolean
    begin
        exit(("Apply to Table Id" <> 0) and Enabled);
    end;

    local procedure InitRecord(NotificationId: Guid;NotificationName: Text[128];DescriptionText: Text) Result: Boolean
    var
        OutStream: OutStream;
    begin
        if not Get(UserId,NotificationId) then begin
          Init;
          "User Id" := UserId;
          "Notification Id" := NotificationId;
          Enabled := true;
          Name := NotificationName;
          Description.CreateOutStream(OutStream);
          OutStream.Write(DescriptionText);
          Result := true;
        end;
    end;

    [Scope('Personalization')]
    procedure InsertDefault(NotificationId: Guid;NotificationName: Text[128];DescriptionText: Text;DefaultState: Boolean)
    begin
        if InitRecord(NotificationId,NotificationName,DescriptionText) then begin
          Enabled := DefaultState;
          Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure InsertDefaultWithTableNum(NotificationId: Guid;NotificationName: Text[128];DescriptionText: Text;TableNum: Integer)
    begin
        if InitRecord(NotificationId,NotificationName,DescriptionText) then begin
          "Apply to Table Id" := TableNum;
          Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure InsertDefaultWithTableNumAndFilter(NotificationId: Guid;NotificationName: Text[128];DescriptionText: Text;TableNum: Integer;Filters: Text)
    var
        FiltersOutStream: OutStream;
        NewRecord: Boolean;
    begin
        NewRecord := InitRecord(NotificationId,NotificationName,DescriptionText);
        if "Apply to Table Id" = 0 then begin
          "Apply to Table Id" := TableNum;
          "Apply to Table Filter".CreateOutStream(FiltersOutStream);
          FiltersOutStream.Write(GetXmlFromTableView(TableNum,Filters));
          if NewRecord then
            Insert
          else
            Modify;
        end;
    end;

    [Scope('Personalization')]
    procedure GetDescription() Ret: Text
    var
        InStream: InStream;
    begin
        CalcFields(Description);
        if not Description.HasValue then
          exit;
        Description.CreateInStream(InStream);
        InStream.Read(Ret);
    end;

    local procedure GetFilteredRecord(var RecordRef: RecordRef;Filters: Text)
    var
        TempBlob: Record TempBlob;
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FiltersOutStream: OutStream;
    begin
        TempBlob.Init;
        TempBlob.Blob.CreateOutStream(FiltersOutStream);
        FiltersOutStream.Write(Filters);

        RecordRef.Open("Apply to Table Id");
        RequestPageParametersHelper.ConvertParametersToFilters(RecordRef,TempBlob);
    end;

    [Scope('Internal')]
    procedure GetFiltersAsDisplayText(): Text
    var
        RecordRef: RecordRef;
    begin
        if not IsFilterEnabled then
          exit;

        GetFilteredRecord(RecordRef,GetFiltersAsText);

        if RecordRef.GetFilters <> '' then
          exit(RecordRef.GetFilters);

        exit(ViewFilterDetailsTxt);
    end;

    local procedure GetFiltersAsText() Filters: Text
    var
        FiltersInStream: InStream;
    begin
        if not IsFilterEnabled then
          exit;

        CalcFields("Apply to Table Filter");
        if not "Apply to Table Filter".HasValue then
          exit;
        "Apply to Table Filter".CreateInStream(FiltersInStream);
        FiltersInStream.Read(Filters);
    end;

    [Scope('Personalization')]
    procedure GetXmlFromTableView(TableID: Integer;View: Text): Text
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        DataItemXmlNode: DotNet XmlNode;
        DataItemsXmlNode: DotNet XmlNode;
        XmlDoc: DotNet XmlDocument;
        ReportParametersXmlNode: DotNet XmlNode;
    begin
        XmlDoc := XmlDoc.XmlDocument;

        XMLDOMMgt.AddRootElement(XmlDoc,'ReportParameters',ReportParametersXmlNode);
        XMLDOMMgt.AddDeclaration(XmlDoc,'1.0','utf-8','yes');

        XMLDOMMgt.AddElement(ReportParametersXmlNode,'DataItems','','',DataItemsXmlNode);
        XMLDOMMgt.AddElement(DataItemsXmlNode,'DataItem',View,'',DataItemXmlNode);
        XMLDOMMgt.AddAttribute(DataItemXmlNode,'name',StrSubstNo('Table%1',TableID));

        exit(XmlDoc.InnerXml);
    end;

    [Scope('Internal')]
    procedure OpenFilterSettings() Changed: Boolean
    var
        DummyMyNotifications: Record "My Notifications";
        RecordRef: RecordRef;
        FiltersOutStream: OutStream;
        NewFilters: Text;
    begin
        if not IsFilterEnabled then
          exit;

        if RunDynamicRequestPage(NewFilters,
             GetFiltersAsText,
             "Apply to Table Id")
        then begin
          GetFilteredRecord(RecordRef,NewFilters);
          if RecordRef.GetFilters = '' then
            "Apply to Table Filter" := DummyMyNotifications."Apply to Table Filter"
          else begin
            "Apply to Table Filter".CreateOutStream(FiltersOutStream);
            FiltersOutStream.Write(NewFilters);
          end;
          Modify;
          Changed := true;
        end;
    end;

    local procedure RunDynamicRequestPage(var ReturnFilters: Text;Filters: Text;TableNum: Integer) FiltersSet: Boolean
    var
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
    begin
        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder,DefineFiltersTxt,TableNum) then
          exit(false);

        if Filters <> '' then
          if not RequestPageParametersHelper.SetViewOnDynamicRequestPage(
               FilterPageBuilder,Filters,DefineFiltersTxt,TableNum)
          then
            exit(false);

        FilterPageBuilder.PageCaption := DefineFiltersTxt;
        if not FilterPageBuilder.RunModal then
          exit(false);

        ReturnFilters :=
          RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder,DefineFiltersTxt,TableNum);

        FiltersSet := true;
    end;

    [Scope('Internal')]
    procedure InsertNotificationWithDefaultFilter(NotificationId: Guid)
    var
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        if NotificationId = InstructionMgt.GetClosingUnpostedDocumentNotificationId then begin
          InstructionMgt.InsertDefaultUnpostedDoucumentNotification;
          Get(UserId,NotificationId);
        end;
    end;

    [Scope('Personalization')]
    procedure IsEnabledForRecord(NotificationId: Guid;"Record": Variant): Boolean
    var
        RecordRef: RecordRef;
        RecordRefPassed: RecordRef;
        Filters: Text;
    begin
        if not IsEnabled(NotificationId) then
          exit(false);

        if not Record.IsRecord then
          exit(true);

        RecordRefPassed.GetTable(Record);
        RecordRefPassed.FilterGroup(2);
        RecordRefPassed.SetRecFilter;
        RecordRefPassed.FilterGroup(0);

        if not Get(UserId,NotificationId) then
          InsertNotificationWithDefaultFilter(NotificationId);

        Filters := GetFiltersAsText;
        if Filters = '' then
          exit(true);

        GetFilteredRecord(RecordRef,Filters);
        RecordRefPassed.SetView(RecordRef.GetView);
        exit(not RecordRefPassed.IsEmpty);
    end;

    [Scope('Personalization')]
    procedure IsEnabled(NotificationId: Guid): Boolean
    var
        IsNotificationEnabled: Boolean;
    begin
        IsNotificationEnabled := true;

        if Get(UserId,NotificationId) then
          IsNotificationEnabled := Enabled;

        OnAfterIsNotificationEnabled(NotificationId,IsNotificationEnabled);

        exit(IsNotificationEnabled);
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnStateChanged(NotificationId: Guid;NewEnabledState: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterIsNotificationEnabled(NotificationId: Guid;var IsNotificationEnabled: Boolean)
    begin
    end;
}

