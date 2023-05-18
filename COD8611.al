codeunit 8611 "Config. Package Management"
{
    TableNo = "Config. Package Record";

    trigger OnRun()
    begin
        Clear(RecordsInsertedCount);
        Clear(RecordsModifiedCount);
        InsertPackageRecord(Rec);
    end;

    var
        KeyFieldValueMissingErr: Label 'The value of the key field %1 has not been filled in for record %2 : %3.', Comment='Parameter 1 - field name, 2 - table name, 3 - code value. Example: The value of the key field Customer Posting Group has not been filled in for record Customer : XXXXX.';
        ValidatingTableRelationsMsg: Label 'Validating table relations';
        RecordsXofYMsg: Label 'Records: %1 of %2', Comment='Sample: 5 of 1025. 1025 is total number of records, 5 is a number of the current record ';
        ApplyingPackageMsg: Label 'Applying package %1', Comment='%1 = The name of the package being applied.';
        ApplyingTableMsg: Label 'Applying table %1', Comment='%1 = The name of the table being applied.';
        NoTablesAndErrorsMsg: Label '%1 tables are processed.\%2 errors found.\%3 records inserted.\%4 records modified.', Comment='%1 = number of tables processed, %2 = number of errors, %3 = number of records inserted, %4 = number of records modified';
        NoTablesMsg: Label '%1 tables are processed.', Comment='%1 = The number of tables that were processed.';
        UpdatingDimSetsMsg: Label 'Updating dimension sets';
        TempConfigRecordForProcessing: Record "Config. Record For Processing" temporary;
        TempAppliedConfigPackageRecord: Record "Config. Package Record" temporary;
        ConfigProgressBar: Codeunit "Config. Progress Bar";
        ConfigValidateMgt: Codeunit "Config. Validate Management";
        ConfigMgt: Codeunit "Config. Management";
        TypeHelper: Codeunit "Type Helper";
        ValidationFieldID: Integer;
        RecordsInsertedCount: Integer;
        RecordsModifiedCount: Integer;
        ApplyMode: Option ,PrimaryKey,NonKeyFields;
        ProcessingOrderErr: Label 'Cannot set up processing order numbers. A cycle reference exists in the primary keys for table %1.', Comment='%1 = The name of the table.';
        ErrorTypeEnum: Option General,TableRelation;
        HideDialog: Boolean;
        ReferenceSameTableErr: Label 'Some lines refer to the same table. You cannot assign a table to a package more than one time.';
        BlankTxt: Label '[Blank]';
        DimValueDoesNotExistsErr: Label 'Dimension Value %1 %2 does not exist.', Comment='%1 = Dimension Code, %2 = Dimension Value Code';
        MSGPPackageCodeTxt: Label 'GB.ENU.CSV';
        QBPackageCodeTxt: Label 'DM.IIF';

    [Scope('Personalization')]
    procedure InsertPackage(var ConfigPackage: Record "Config. Package";PackageCode: Code[20];PackageName: Text[50];ExcludeConfigTables: Boolean)
    begin
        ConfigPackage.Code := PackageCode;
        ConfigPackage."Package Name" := PackageName;
        ConfigPackage."Exclude Config. Tables" := ExcludeConfigTables;
        ConfigPackage.Insert;
    end;

    [Scope('Personalization')]
    procedure InsertPackageTable(var ConfigPackageTable: Record "Config. Package Table";PackageCode: Code[20];TableID: Integer)
    begin
        if not ConfigPackageTable.Get(PackageCode,TableID) then begin
          ConfigPackageTable.Init;
          ConfigPackageTable.Validate("Package Code",PackageCode);
          ConfigPackageTable.Validate("Table ID",TableID);
          ConfigPackageTable.Insert(true);
        end;
    end;

    [Scope('Personalization')]
    procedure InsertPackageTableWithoutValidation(var ConfigPackageTable: Record "Config. Package Table";PackageCode: Code[20];TableID: Integer)
    begin
        if not ConfigPackageTable.Get(PackageCode,TableID) then begin
          ConfigPackageTable.Init;
          ConfigPackageTable."Package Code" := PackageCode;
          ConfigPackageTable."Table ID" := TableID;
          ConfigPackageTable.Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure InsertPackageField(var ConfigPackageField: Record "Config. Package Field";PackageCode: Code[20];TableID: Integer;FieldID: Integer;FieldName: Text[30];FieldCaption: Text[250];SetInclude: Boolean;SetValidate: Boolean;SetLocalize: Boolean;SetDimension: Boolean)
    begin
        if not ConfigPackageField.Get(PackageCode,TableID,FieldID) then begin
          ConfigPackageField.Init;
          ConfigPackageField.Validate("Package Code",PackageCode);
          ConfigPackageField.Validate("Table ID",TableID);
          ConfigPackageField.Validate(Dimension,SetDimension);
          ConfigPackageField.Validate("Field ID",FieldID);
          ConfigPackageField."Field Name" := FieldName;
          ConfigPackageField."Field Caption" := FieldCaption;
          ConfigPackageField."Primary Key" := ConfigValidateMgt.IsKeyField(TableID,FieldID);
          ConfigPackageField."Include Field" := SetInclude or ConfigPackageField."Primary Key";
          if not SetDimension then begin
            ConfigPackageField."Relation Table ID" := ConfigValidateMgt.GetRelationTableID(TableID,FieldID);
            ConfigPackageField."Validate Field" :=
              ConfigPackageField."Include Field" and SetValidate and not ValidateException(TableID,FieldID);
          end;
          ConfigPackageField."Localize Field" := SetLocalize;
          ConfigPackageField.Dimension := SetDimension;
          if SetDimension then
            ConfigPackageField."Processing Order" := ConfigPackageField."Field ID";
          ConfigPackageField.Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure InsertPackageFilter(var ConfigPackageFilter: Record "Config. Package Filter";PackageCode: Code[20];TableID: Integer;ProcessingRuleNo: Integer;FieldID: Integer;FieldFilter: Text[250])
    begin
        if not ConfigPackageFilter.Get(PackageCode,TableID,0,FieldID) then begin
          ConfigPackageFilter.Init;
          ConfigPackageFilter.Validate("Package Code",PackageCode);
          ConfigPackageFilter.Validate("Table ID",TableID);
          ConfigPackageFilter.Validate("Processing Rule No.",ProcessingRuleNo);
          ConfigPackageFilter.Validate("Field ID",FieldID);
          ConfigPackageFilter.Validate("Field Filter",FieldFilter);
          ConfigPackageFilter.Insert;
        end else
          if ConfigPackageFilter."Field Filter" <> FieldFilter then begin
            ConfigPackageFilter."Field Filter" := FieldFilter;
            ConfigPackageFilter.Modify;
          end;
    end;

    [Scope('Personalization')]
    procedure InsertPackageRecord(ConfigPackageRecord: Record "Config. Package Record")
    var
        ConfigPackageTable: Record "Config. Package Table";
        RecRef: RecordRef;
        DelayedInsert: Boolean;
    begin
        if (ConfigPackageRecord."Package Code" = '') or (ConfigPackageRecord."Table ID" = 0) then
          exit;

        if ConfigMgt.IsSystemTable(ConfigPackageRecord."Table ID") then
          exit;

        RecRef.Open(ConfigPackageRecord."Table ID");
        if ApplyMode <> ApplyMode::NonKeyFields then
          RecRef.Init;

        ConfigPackageTable.Get(ConfigPackageRecord."Package Code",ConfigPackageRecord."Table ID");
        DelayedInsert := ConfigPackageTable."Delayed Insert";
        InsertPrimaryKeyFields(RecRef,ConfigPackageRecord,true,DelayedInsert);

        if ApplyMode = ApplyMode::PrimaryKey then
          UpdateKeyInfoForConfigPackageRecord(RecRef,ConfigPackageRecord);

        if (ApplyMode = ApplyMode::NonKeyFields) or DelayedInsert then
          ModifyRecordDataFields(RecRef,ConfigPackageRecord,true,DelayedInsert);
    end;

    [Scope('Personalization')]
    procedure InsertPackageData(var ConfigPackageData: Record "Config. Package Data";PackageCode: Code[20];TableID: Integer;No: Integer;FieldID: Integer;Value: Text[250];Invalid: Boolean)
    begin
        if not ConfigPackageData.Get(PackageCode,TableID,No,FieldID) then begin
          ConfigPackageData.Init;
          ConfigPackageData."Package Code" := PackageCode;
          ConfigPackageData."Table ID" := TableID;
          ConfigPackageData."No." := No;
          ConfigPackageData."Field ID" := FieldID;
          ConfigPackageData.Value := Value;
          ConfigPackageData.Invalid := Invalid;
          ConfigPackageData.Insert;
        end else
          if ConfigPackageData.Value <> Value then begin
            ConfigPackageData.Value := Value;
            ConfigPackageData.Modify;
          end;
    end;

    [Scope('Personalization')]
    procedure InsertProcessingRule(var ConfigTableProcessingRule: Record "Config. Table Processing Rule";ConfigPackageTable: Record "Config. Package Table";RuleNo: Integer;NewAction: Option)
    begin
        with ConfigTableProcessingRule do begin
          Validate("Package Code",ConfigPackageTable."Package Code");
          Validate("Table ID",ConfigPackageTable."Table ID");
          Validate("Rule No.",RuleNo);
          Validate(Action,NewAction);
          Insert(true);
        end;
    end;

    [Scope('Personalization')]
    procedure InsertProcessingRuleCustom(var ConfigTableProcessingRule: Record "Config. Table Processing Rule";ConfigPackageTable: Record "Config. Package Table";RuleNo: Integer;CodeunitID: Integer)
    begin
        with ConfigTableProcessingRule do begin
          Validate("Package Code",ConfigPackageTable."Package Code");
          Validate("Table ID",ConfigPackageTable."Table ID");
          Validate("Rule No.",RuleNo);
          Validate(Action,Action::Custom);
          Validate("Custom Processing Codeunit ID",CodeunitID);
          Insert(true);
        end;
    end;

    [Scope('Personalization')]
    procedure SetSkipTableTriggers(var ConfigPackageTable: Record "Config. Package Table";PackageCode: Code[20];TableID: Integer;Skip: Boolean)
    begin
        if ConfigPackageTable.Get(PackageCode,TableID) then begin
          ConfigPackageTable.Validate("Skip Table Triggers",Skip);
          ConfigPackageTable.Modify(true);
        end;
    end;

    [Scope('Personalization')]
    procedure GetNumberOfRecordsInserted(): Integer
    begin
        exit(RecordsInsertedCount);
    end;

    [Scope('Personalization')]
    procedure GetNumberOfRecordsModified(): Integer
    begin
        exit(RecordsModifiedCount);
    end;

    local procedure InsertPrimaryKeyFields(var RecRef: RecordRef;ConfigPackageRecord: Record "Config. Package Record";DoInsert: Boolean;var DelayedInsert: Boolean)
    var
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageField: Record "Config. Package Field";
        TempConfigPackageField: Record "Config. Package Field" temporary;
        ConfigPackageError: Record "Config. Package Error";
        RecRef1: RecordRef;
        FieldRef: FieldRef;
    begin
        ConfigPackageData.SetRange("Package Code",ConfigPackageRecord."Package Code");
        ConfigPackageData.SetRange("Table ID",ConfigPackageRecord."Table ID");
        ConfigPackageData.SetRange("No.",ConfigPackageRecord."No.");

        GetKeyFieldsOrder(RecRef,ConfigPackageRecord."Package Code",TempConfigPackageField);
        GetFieldsMarkedAsPrimaryKey(ConfigPackageRecord."Package Code",RecRef.Number,TempConfigPackageField);

        TempConfigPackageField.Reset;
        TempConfigPackageField.SetCurrentKey("Package Code","Table ID","Processing Order");

        TempConfigPackageField.FindSet;
        repeat
          FieldRef := RecRef.Field(TempConfigPackageField."Field ID");
          ConfigPackageData.SetRange("Field ID",TempConfigPackageField."Field ID");
          if ConfigPackageData.FindFirst then begin
            ConfigPackageField.Get(ConfigPackageData."Package Code",ConfigPackageData."Table ID",ConfigPackageData."Field ID");
            UpdateValueUsingMapping(ConfigPackageData,ConfigPackageField,ConfigPackageRecord."Package Code");
            ValidationFieldID := FieldRef.Number;
            ConfigValidateMgt.EvaluateTextToFieldRef(
              ConfigPackageData.Value,FieldRef,ConfigPackageField."Validate Field" and (ApplyMode = ApplyMode::PrimaryKey));
          end else
            Error(KeyFieldValueMissingErr,FieldRef.Name,RecRef.Name,ConfigPackageData."No.");
        until TempConfigPackageField.Next = 0;

        RecRef1 := RecRef.Duplicate;

        if RecRef1.Find then begin
          RecRef := RecRef1;
          exit
        end;
        if ((ConfigPackageRecord."Package Code" = QBPackageCodeTxt) or (ConfigPackageRecord."Package Code" = MSGPPackageCodeTxt)) and
           (ConfigPackageRecord."Table ID" = 15)
        then
          if ConfigPackageError.Get(
               ConfigPackageRecord."Package Code",ConfigPackageRecord."Table ID",ConfigPackageRecord."No.",1)
          then
            exit;

        if DelayedInsert then
          exit;

        if DoInsert then begin
          DelayedInsert := InsertRecord(RecRef,ConfigPackageRecord);
          RecordsInsertedCount += 1;
        end else
          DelayedInsert := false;
    end;

    local procedure UpdateKeyInfoForConfigPackageRecord(RecRef: RecordRef;ConfigPackageRecord: Record "Config. Package Record")
    var
        ConfigPackageData: Record "Config. Package Data";
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        KeyFieldCount: Integer;
    begin
        KeyRef := RecRef.KeyIndex(1);
        for KeyFieldCount := 1 to KeyRef.FieldCount do begin
          FieldRef := KeyRef.FieldIndex(KeyFieldCount);

          ConfigPackageData.Get(
            ConfigPackageRecord."Package Code",ConfigPackageRecord."Table ID",ConfigPackageRecord."No.",FieldRef.Number);
          ConfigPackageData.Value := Format(FieldRef.Value);
          ConfigPackageData.Modify;
        end;
    end;

    [Scope('Personalization')]
    procedure InitPackageRecord(var ConfigPackageRecord: Record "Config. Package Record";PackageCode: Code[20];TableID: Integer)
    var
        NextNo: Integer;
    begin
        ConfigPackageRecord.Reset;
        ConfigPackageRecord.SetRange("Package Code",PackageCode);
        ConfigPackageRecord.SetRange("Table ID",TableID);
        if ConfigPackageRecord.FindLast then
          NextNo := ConfigPackageRecord."No." + 1
        else
          NextNo := 1;

        ConfigPackageRecord.Init;
        ConfigPackageRecord."Package Code" := PackageCode;
        ConfigPackageRecord."Table ID" := TableID;
        ConfigPackageRecord."No." := NextNo;
        ConfigPackageRecord.Insert;
    end;

    local procedure InsertRecord(var RecRef: RecordRef;ConfigPackageRecord: Record "Config. Package Record"): Boolean
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigInsertWithValidation: Codeunit "Config. Insert With Validation";
    begin
        ConfigPackageTable.Get(ConfigPackageRecord."Package Code",ConfigPackageRecord."Table ID");
        if ConfigPackageTable."Skip Table Triggers" then
          RecRef.Insert
        else begin
          Commit;
          ConfigInsertWithValidation.SetInsertParameters(RecRef);
          if not ConfigInsertWithValidation.Run then begin
            ClearLastError;
            exit(true);
          end;
        end;
        exit(false);
    end;

    local procedure ModifyRecordDataFields(var RecRef: RecordRef;ConfigPackageRecord: Record "Config. Package Record";DoModify: Boolean;DelayedInsert: Boolean)
    var
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageField: Record "Config. Package Field";
        ConfigQuestion: Record "Config. Question";
        "Field": Record "Field";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageError: Record "Config. Package Error";
        ConfigQuestionnaireMgt: Codeunit "Questionnaire Management";
        FieldRef: FieldRef;
        IsTemplate: Boolean;
    begin
        ConfigPackageField.Reset;
        ConfigPackageField.SetCurrentKey("Package Code","Table ID","Processing Order");
        ConfigPackageField.SetRange("Package Code",ConfigPackageRecord."Package Code");
        ConfigPackageField.SetRange("Table ID",ConfigPackageRecord."Table ID");
        ConfigPackageField.SetRange("Include Field",true);
        ConfigPackageField.SetRange(Dimension,false);

        ConfigPackageTable.Get(ConfigPackageRecord."Package Code",ConfigPackageRecord."Table ID");
        if DoModify or DelayedInsert then
          ApplyTemplate(ConfigPackageTable,RecRef);

        if ConfigPackageField.FindSet then
          repeat
            ValidationFieldID := ConfigPackageField."Field ID";
            if ((ConfigPackageRecord."Package Code" = QBPackageCodeTxt) or (ConfigPackageRecord."Package Code" = MSGPPackageCodeTxt)) and
               ((ConfigPackageRecord."Table ID" = 15) or (ConfigPackageRecord."Table ID" = 18) or
                (ConfigPackageRecord."Table ID" = 23) or (ConfigPackageRecord."Table ID" = 27))
            then
              if ConfigPackageError.Get(
                   ConfigPackageRecord."Package Code",ConfigPackageRecord."Table ID",ConfigPackageRecord."No.",1)
              then
                exit;

            if ConfigPackageData.Get(
                 ConfigPackageRecord."Package Code",ConfigPackageRecord."Table ID",ConfigPackageRecord."No.",
                 ConfigPackageField."Field ID")
            then
              if not (ConfigPackageField."Primary Key" or ConfigPackageField.AutoIncrement) then begin
                IsTemplate := IsTemplateField(ConfigPackageTable."Data Template",ConfigPackageField."Field ID");
                if not IsTemplate or (IsTemplate and (ConfigPackageData.Value <> '')) then begin
                  FieldRef := RecRef.Field(ConfigPackageField."Field ID");
                  UpdateValueUsingMapping(ConfigPackageData,ConfigPackageField,ConfigPackageRecord."Package Code");

                  case true of
                    IsBLOBField(ConfigPackageData."Table ID",ConfigPackageData."Field ID"):
                      EvaluateBLOBToFieldRef(ConfigPackageData,FieldRef);
                    IsMediaSetField(ConfigPackageData."Table ID",ConfigPackageData."Field ID"):
                      ImportMediaSetFiles(ConfigPackageData,FieldRef,DoModify);
                    IsMediaField(ConfigPackageData."Table ID",ConfigPackageData."Field ID"):
                      ImportMediaFiles(ConfigPackageData,FieldRef,DoModify);
                    else
                      ConfigValidateMgt.EvaluateTextToFieldRef(
                        ConfigPackageData.Value,FieldRef,
                        ConfigPackageField."Validate Field" and ((ApplyMode = ApplyMode::NonKeyFields) or DelayedInsert));
                  end;
                end;
              end;
          until ConfigPackageField.Next = 0;

        if DoModify then begin
          if DelayedInsert then
            RecRef.Insert(true)
          else begin
            RecRef.Modify(not ConfigPackageTable."Skip Table Triggers");
            RecordsModifiedCount += 1;
          end;

          if RecRef.Number <> DATABASE::"Config. Question" then
            exit;

          RecRef.SetTable(ConfigQuestion);

          SetFieldFilter(Field,ConfigQuestion."Table ID",ConfigQuestion."Field ID");
          if Field.FindFirst then
            ConfigQuestionnaireMgt.ModifyConfigQuestionAnswer(ConfigQuestion,Field);
        end;
    end;

    [Scope('Personalization')]
    procedure RemoveRecordsWithObsoleteTableID(TableID: Integer;TableIDFieldNo: Integer)
    var
        TableMetadata: Record "Table Metadata";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.Open(TableID);
        FieldRef := RecRef.Field(TableIDFieldNo);
        TableMetadata.SetRange(ObsoleteState,TableMetadata.ObsoleteState::Removed);
        if TableMetadata.FindSet then
          repeat
            FieldRef.SetRange(TableMetadata.ID);
            if not RecRef.IsEmpty then
              RecRef.DeleteAll(true);
          until TableMetadata.Next = 0;
        RecRef.Close;
    end;

    local procedure ApplyTemplate(ConfigPackageTable: Record "Config. Package Table";var RecRef: RecordRef)
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
    begin
        if ConfigTemplateHeader.Get(ConfigPackageTable."Data Template") then begin
          ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader,RecRef);
          InsertDimensionsFromTemplates(ConfigPackageTable."Table ID",ConfigTemplateHeader,RecRef);
        end;
    end;

    local procedure InsertDimensionsFromTemplates(TableID: Integer;ConfigTemplateHeader: Record "Config. Template Header";var RecRef: RecordRef)
    var
        DimensionsTemplate: Record "Dimensions Template";
        KeyRef: KeyRef;
        FieldRef: FieldRef;
    begin
        KeyRef := RecRef.KeyIndex(1);
        if KeyRef.FieldCount = 1 then begin
          FieldRef := KeyRef.FieldIndex(1);
          if Format(FieldRef.Value) <> '' then
            DimensionsTemplate.InsertDimensionsFromTemplates(
              ConfigTemplateHeader,Format(FieldRef.Value),TableID);
        end;
    end;

    local procedure IsTemplateField(TemplateCode: Code[20];FieldNo: Integer): Boolean
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        if TemplateCode = '' then
          exit(false);

        if not ConfigTemplateHeader.Get(TemplateCode) then
          exit(false);

        ConfigTemplateLine.SetRange("Data Template Code",ConfigTemplateHeader.Code);
        ConfigTemplateLine.SetRange("Field ID",FieldNo);
        ConfigTemplateLine.SetRange(Type,ConfigTemplateLine.Type::Field);
        if not ConfigTemplateLine.IsEmpty then
          exit(true);

        ConfigTemplateLine.SetRange("Field ID");
        ConfigTemplateLine.SetRange(Type,ConfigTemplateLine.Type::Template);
        if ConfigTemplateLine.FindSet then
          repeat
            if IsTemplateField(ConfigTemplateLine."Template Code",FieldNo) then
              exit(true);
          until ConfigTemplateLine.Next = 0;
        exit(false);
    end;

    [Scope('Personalization')]
    procedure ValidatePackageRelations(var ConfigPackageTable: Record "Config. Package Table";var TempConfigPackageTable: Record "Config. Package Table" temporary;SetupProcessingOrderForTables: Boolean)
    var
        TableCount: Integer;
    begin
        if SetupProcessingOrderForTables then
          SetupProcessingOrder(ConfigPackageTable);

        with ConfigPackageTable do begin
          TableCount := Count;
          if not HideDialog then
            ConfigProgressBar.Init(TableCount,1,ValidatingTableRelationsMsg);

          ModifyAll(Validated,false);

          SetCurrentKey("Package Processing Order","Processing Order");
          if FindSet then
            repeat
              CalcFields("Table Name");
              if not HideDialog then
                ConfigProgressBar.Update("Table Name");
              ValidateTableRelation("Package Code","Table ID",TempConfigPackageTable);

              TempConfigPackageTable.Init;
              TempConfigPackageTable."Package Code" := "Package Code";
              TempConfigPackageTable."Table ID" := "Table ID";
              TempConfigPackageTable.Insert;
              Validated := true;
              Modify;
            until Next = 0;
          if not HideDialog then
            ConfigProgressBar.Close;
        end;

        if not HideDialog then
          Message(NoTablesMsg,TableCount);
    end;

    local procedure ValidateTableRelation(PackageCode: Code[20];TableId: Integer;var ValidatedConfigPackageTable: Record "Config. Package Table")
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.SetCurrentKey("Package Code","Table ID","Processing Order");
        ConfigPackageField.SetRange("Package Code",PackageCode);
        ConfigPackageField.SetRange("Table ID",TableId);
        ConfigPackageField.SetRange("Validate Field",true);
        if ConfigPackageField.FindSet then
          repeat
            ValidateFieldRelation(ConfigPackageField,ValidatedConfigPackageTable);
          until ConfigPackageField.Next = 0;
    end;

    procedure ValidateFieldRelation(ConfigPackageField: Record "Config. Package Field";var ValidatedConfigPackageTable: Record "Config. Package Table") NoValidateErrors: Boolean
    var
        ConfigPackageData: Record "Config. Package Data";
    begin
        NoValidateErrors := true;

        ConfigPackageData.SetRange("Package Code",ConfigPackageField."Package Code");
        ConfigPackageData.SetRange("Table ID",ConfigPackageField."Table ID");
        ConfigPackageData.SetRange("Field ID",ConfigPackageField."Field ID");
        if ConfigPackageData.FindSet then
          repeat
            NoValidateErrors :=
              NoValidateErrors and
              ValidatePackageDataRelation(ConfigPackageData,ValidatedConfigPackageTable,ConfigPackageField,true);
          until ConfigPackageData.Next = 0;
    end;

    procedure ValidateSinglePackageDataRelation(var ConfigPackageData: Record "Config. Package Data"): Boolean
    var
        TempConfigPackageTable: Record "Config. Package Table" temporary;
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.Get(ConfigPackageData."Package Code",ConfigPackageData."Table ID",ConfigPackageData."Field ID");
        exit(ValidatePackageDataRelation(ConfigPackageData,TempConfigPackageTable,ConfigPackageField,false));
    end;

    local procedure ValidatePackageDataRelation(var ConfigPackageData: Record "Config. Package Data";var ValidatedConfigPackageTable: Record "Config. Package Table";var ConfigPackageField: Record "Config. Package Field";GenerateFieldError: Boolean): Boolean
    var
        ErrorText: Text[250];
        RelationTableNo: Integer;
        RelationFieldNo: Integer;
        DataInPackageData: Boolean;
    begin
        if Format(ConfigPackageData.Value) <> '' then begin
          DataInPackageData := false;
          if GetRelationInfo(ConfigPackageField,RelationTableNo,RelationFieldNo) then
            DataInPackageData :=
              ValidateFieldRelationAgainstPackageData(
                ConfigPackageData,ValidatedConfigPackageTable,RelationTableNo,RelationFieldNo);

          OnAfterValidatePackageDataRelation(
            ConfigPackageData,ConfigPackageField,ValidatedConfigPackageTable,RelationTableNo,RelationFieldNo,DataInPackageData);

          if not DataInPackageData then begin
            ErrorText := ValidateFieldRelationAgainstCompanyData(ConfigPackageData);
            if ErrorText <> '' then begin
              if GenerateFieldError then
                FieldError(ConfigPackageData,ErrorText,ErrorTypeEnum::TableRelation);
              exit(false);
            end;
          end;
        end;

        if PackageErrorsExists(ConfigPackageData,ErrorTypeEnum::TableRelation) then
          CleanFieldError(ConfigPackageData);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure ValidateException(TableID: Integer;FieldID: Integer): Boolean
    begin
        case TableID of
          // Dimension Value ID: ERROR message
          DATABASE::"Dimension Value":
            exit(FieldID = 12);
          // Default Dimension: multi-relations
          DATABASE::"Default Dimension":
            exit(FieldID = 2);
          // VAT %: CheckVATIdentifier
          DATABASE::"VAT Posting Setup":
            exit(FieldID = 4);
          // Table ID - OnValidate
          DATABASE::"Config. Template Header":
            exit(FieldID = 3);
          // Field ID relation
          DATABASE::"Config. Template Line":
            exit(FieldID in [4,8,12]);
          // Dimensions as Columns
          DATABASE::"Config. Line":
            exit(FieldID = 12);
          // Customer : Contact OnValidate
          DATABASE::Customer:
            exit(FieldID = 8);
          // Vendor : Contact OnValidate
          DATABASE::Vendor:
            exit(FieldID = 8);
          // Item : Base Unit of Measure OnValidate
          DATABASE::Item:
            exit(FieldID = 8);
          // "No." to pass not manual No. Series
          DATABASE::"Sales Header",DATABASE::"Purchase Header":
            exit(FieldID = 3);
          // "Document No." conditional relation
          DATABASE::"Sales Line",DATABASE::"Purchase Line":
            exit(FieldID = 3);
        end;
        exit(false);
    end;

    [Scope('Personalization')]
    procedure IsDimSetIDField(TableId: Integer;FieldId: Integer): Boolean
    var
        DimensionValue: Record "Dimension Value";
    begin
        exit((TableId = DATABASE::"Dimension Value") and (DimensionValue.FieldNo("Dimension Value ID") = FieldId));
    end;

    local procedure GetRelationInfo(ConfigPackageField: Record "Config. Package Field";var RelationTableNo: Integer;var RelationFieldNo: Integer): Boolean
    begin
        exit(
          ConfigValidateMgt.GetRelationInfoByIDs(
            ConfigPackageField."Table ID",ConfigPackageField."Field ID",RelationTableNo,RelationFieldNo));
    end;

    local procedure ValidateFieldRelationAgainstCompanyData(ConfigPackageData: Record "Config. Package Data"): Text[250]
    var
        TempConfigPackageField: Record "Config. Package Field" temporary;
        ConfigPackageRecord: Record "Config. Package Record";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        DelayedInsert: Boolean;
    begin
        RecRef.Open(ConfigPackageData."Table ID");
        ConfigPackageRecord.Get(ConfigPackageData."Package Code",ConfigPackageData."Table ID",ConfigPackageData."No.");
        InsertPrimaryKeyFields(RecRef,ConfigPackageRecord,false,DelayedInsert);
        ModifyRecordDataFields(RecRef,ConfigPackageRecord,false,false);

        FieldRef := RecRef.Field(ConfigPackageData."Field ID");
        ConfigValidateMgt.EvaluateValue(FieldRef,ConfigPackageData.Value,false);

        GetFieldsOrder(RecRef,ConfigPackageRecord."Package Code",TempConfigPackageField);
        exit(ConfigValidateMgt.ValidateFieldRefRelationAgainstCompanyData(FieldRef,TempConfigPackageField));
    end;

    local procedure ValidateFieldRelationAgainstPackageData(ConfigPackageData: Record "Config. Package Data";var ValidatedConfigPackageTable: Record "Config. Package Table";RelationTableNo: Integer;RelationFieldNo: Integer): Boolean
    var
        RelatedConfigPackageData: Record "Config. Package Data";
        ConfigPackageTable: Record "Config. Package Table";
        TablePriority: Integer;
    begin
        if not ConfigPackageTable.Get(ConfigPackageData."Package Code",RelationTableNo) then
          exit(false);

        TablePriority := ConfigPackageTable."Processing Order";
        if ConfigValidateMgt.IsRelationInKeyFields(ConfigPackageData."Table ID",ConfigPackageData."Field ID") then begin
          ConfigPackageTable.Get(ConfigPackageData."Package Code",ConfigPackageData."Table ID");

          if ConfigPackageTable."Processing Order" < TablePriority then
            exit(false);

          // That current order will be for apply data
          ValidatedConfigPackageTable.Reset;
          ValidatedConfigPackageTable.SetRange("Table ID",RelationTableNo);
          if ValidatedConfigPackageTable.IsEmpty then
            exit(false);
        end;

        RelatedConfigPackageData.SetRange("Package Code",ConfigPackageData."Package Code");
        RelatedConfigPackageData.SetRange("Table ID",RelationTableNo);
        RelatedConfigPackageData.SetRange("Field ID",RelationFieldNo);
        RelatedConfigPackageData.SetRange(Value,ConfigPackageData.Value);
        exit(not RelatedConfigPackageData.IsEmpty);
    end;

    [Scope('Personalization')]
    procedure RecordError(var ConfigPackageRecord: Record "Config. Package Record";ValidationFieldID: Integer;ErrorText: Text[250])
    var
        ConfigPackageError: Record "Config. Package Error";
        ConfigPackageData: Record "Config. Package Data";
        RecordID: RecordID;
    begin
        if ErrorText = '' then
          exit;

        ConfigPackageError.Init;
        ConfigPackageError."Package Code" := ConfigPackageRecord."Package Code";
        ConfigPackageError."Table ID" := ConfigPackageRecord."Table ID";
        ConfigPackageError."Record No." := ConfigPackageRecord."No.";
        ConfigPackageError."Field ID" := ValidationFieldID;
        ConfigPackageError."Error Text" := ErrorText;

        ConfigPackageData.SetRange("Package Code",ConfigPackageRecord."Package Code");
        ConfigPackageData.SetRange("Table ID",ConfigPackageRecord."Table ID");
        ConfigPackageData.SetRange("No.",ConfigPackageRecord."No.");
        if Evaluate(RecordID,GetRecordIDOfRecordError(ConfigPackageData)) then
          ConfigPackageError."Record ID" := RecordID;
        if not ConfigPackageError.Insert then
          ConfigPackageError.Modify;
        ConfigPackageRecord.Invalid := true;
        ConfigPackageRecord.Modify;
    end;

    [Scope('Personalization')]
    procedure FieldError(var ConfigPackageData: Record "Config. Package Data";ErrorText: Text[250];ErrorType: Option ,TableRelation)
    var
        ConfigPackageRecord: Record "Config. Package Record";
        ConfigPackageError: Record "Config. Package Error";
        ConfigPackageData2: Record "Config. Package Data";
        RecordID: RecordID;
    begin
        if ErrorText = '' then
          exit;

        ConfigPackageError.Init;
        ConfigPackageError."Package Code" := ConfigPackageData."Package Code";
        ConfigPackageError."Table ID" := ConfigPackageData."Table ID";
        ConfigPackageError."Record No." := ConfigPackageData."No.";
        ConfigPackageError."Field ID" := ConfigPackageData."Field ID";
        ConfigPackageError."Error Text" := ErrorText;
        ConfigPackageError."Error Type" := ErrorType;

        ConfigPackageData2.SetRange("Package Code",ConfigPackageData."Package Code");
        ConfigPackageData2.SetRange("Table ID",ConfigPackageData."Table ID");
        ConfigPackageData2.SetRange("No.",ConfigPackageData."No.");
        if Evaluate(RecordID,GetRecordIDOfRecordError(ConfigPackageData2)) then
          ConfigPackageError."Record ID" := RecordID;
        if not ConfigPackageError.Insert then
          ConfigPackageError.Modify;

        ConfigPackageData.Invalid := true;
        ConfigPackageData.Modify;

        ConfigPackageRecord.Get(ConfigPackageData."Package Code",ConfigPackageData."Table ID",ConfigPackageData."No.");
        ConfigPackageRecord.Invalid := true;
        ConfigPackageRecord.Modify;
    end;

    [Scope('Personalization')]
    procedure CleanRecordError(var ConfigPackageRecord: Record "Config. Package Record")
    var
        ConfigPackageError: Record "Config. Package Error";
    begin
        ConfigPackageError.SetRange("Package Code",ConfigPackageRecord."Package Code");
        ConfigPackageError.SetRange("Table ID",ConfigPackageRecord."Table ID");
        ConfigPackageError.SetRange("Record No.",ConfigPackageRecord."No.");
        ConfigPackageError.DeleteAll;
    end;

    [Scope('Personalization')]
    procedure CleanFieldError(var ConfigPackageData: Record "Config. Package Data")
    var
        ConfigPackageError: Record "Config. Package Error";
        ConfigPackageRecord: Record "Config. Package Record";
        HasError: Boolean;
    begin
        with ConfigPackageData do
          if ConfigPackageError.Get("Package Code","Table ID","No.","Field ID") then begin
            ConfigPackageError.Delete;
            Invalid := false;
            Modify;

            ConfigPackageRecord.Get("Package Code","Table ID","No.");
            HasError := IsRecordErrorsExists(ConfigPackageRecord);
            if ConfigPackageRecord.Invalid <> HasError then begin
              ConfigPackageRecord.Invalid := HasError;
              ConfigPackageRecord.Modify;
            end;
          end;
    end;

    [Scope('Personalization')]
    procedure CleanPackageErrors(PackageCode: Code[20];TableFilter: Text)
    var
        ConfigPackageError: Record "Config. Package Error";
    begin
        ConfigPackageError.SetRange("Package Code",PackageCode);
        if TableFilter <> '' then
          ConfigPackageError.SetFilter("Table ID",TableFilter);

        ConfigPackageError.DeleteAll;
    end;

    local procedure PackageErrorsExists(ConfigPackageData: Record "Config. Package Data";ErrorType: Option General,TableRelation): Boolean
    var
        ConfigPackageError: Record "Config. Package Error";
    begin
        if not ConfigPackageError.Get(
             ConfigPackageData."Package Code",ConfigPackageData."Table ID",ConfigPackageData."No.",ConfigPackageData."Field ID")
        then
          exit(false);

        if ConfigPackageError."Error Type" = ErrorType then
          exit(true);

        exit(false)
    end;

    [Scope('Personalization')]
    procedure GetValidationFieldID(): Integer
    begin
        exit(ValidationFieldID);
    end;

    [Scope('Personalization')]
    procedure ApplyConfigLines(var ConfigLine: Record "Config. Line")
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigMgt: Codeunit "Config. Management";
        "Filter": Text;
    begin
        ConfigLine.FindFirst;
        ConfigPackage.Get(ConfigLine."Package Code");
        ConfigPackageTable.SetRange("Package Code",ConfigLine."Package Code");
        Filter := ConfigMgt.MakeTableFilter(ConfigLine,false);

        if Filter = '' then
          exit;

        ConfigPackageTable.SetFilter("Table ID",Filter);
        ApplyPackage(ConfigPackage,ConfigPackageTable,true);
    end;

    [Scope('Personalization')]
    procedure ApplyPackage(ConfigPackage: Record "Config. Package";var ConfigPackageTable: Record "Config. Package Table";SetupProcessingOrderForTables: Boolean) ErrorCount: Integer
    var
        DimSetEntry: Record "Dimension Set Entry";
        ConfigPackageTableParent: Record "Config. Package Table";
        IntegrationService: Codeunit "Integration Service";
        IntegrationManagement: Codeunit "Integration Management";
        TableCount: Integer;
        DimSetIDUsed: Boolean;
    begin
        BindSubscription(IntegrationService);
        IntegrationManagement.ResetIntegrationActivated;

        ConfigPackage.CalcFields("No. of Records","No. of Errors");
        TableCount := ConfigPackageTable.Count;
        if (ConfigPackage.Code <> MSGPPackageCodeTxt) and (ConfigPackage.Code <> QBPackageCodeTxt) then
          // Hold the error count for duplicate records.
          ErrorCount := ConfigPackage."No. of Errors";
        if (TableCount = 0) or (ConfigPackage."No. of Records" = 0) then
          exit;
        if (ConfigPackage.Code <> MSGPPackageCodeTxt) and (ConfigPackage.Code <> QBPackageCodeTxt) then
          // Skip this code to hold the error count for duplicate records.
          CleanPackageErrors(ConfigPackage.Code,ConfigPackageTable.GetFilter("Table ID"));

        if SetupProcessingOrderForTables then begin
          SetupProcessingOrder(ConfigPackageTable);
          Commit;
        end;

        DimSetIDUsed := false;
        if ConfigPackageTable.FindSet then
          repeat
            DimSetIDUsed := ConfigMgt.IsDimSetIDTable(ConfigPackageTable."Table ID");
          until (ConfigPackageTable.Next = 0) or DimSetIDUsed;

        if DimSetIDUsed and not DimSetEntry.IsEmpty then
          UpdateDimSetIDValues(ConfigPackage);
        if (ConfigPackage.Code <> MSGPPackageCodeTxt) and (ConfigPackage.Code <> QBPackageCodeTxt) then
          DeleteAppliedPackageRecords(TempAppliedConfigPackageRecord); // Do not delete PackageRecords till transactions are created

        Commit;

        TempAppliedConfigPackageRecord.DeleteAll;
        TempConfigRecordForProcessing.DeleteAll;
        Clear(RecordsInsertedCount);
        Clear(RecordsModifiedCount);

        // Handle independent tables
        ConfigPackageTable.SetRange("Parent Table ID",0);
        ApplyPackageTables(ConfigPackage,ConfigPackageTable,ApplyMode::PrimaryKey);
        ApplyPackageTables(ConfigPackage,ConfigPackageTable,ApplyMode::NonKeyFields);

        // Handle children tables
        ConfigPackageTable.SetFilter("Parent Table ID",'>0');
        if ConfigPackageTable.FindSet then
          repeat
            ConfigPackageTableParent.Get(ConfigPackage.Code,ConfigPackageTable."Parent Table ID");
            if ConfigPackageTableParent."Parent Table ID" = 0 then
              ConfigPackageTable.Mark(true);
          until ConfigPackageTable.Next = 0;
        ConfigPackageTable.MarkedOnly(true);
        ApplyPackageTables(ConfigPackage,ConfigPackageTable,ApplyMode::PrimaryKey);
        ApplyPackageTables(ConfigPackage,ConfigPackageTable,ApplyMode::NonKeyFields);

        // Handle grandchildren tables
        ConfigPackageTable.ClearMarks;
        ConfigPackageTable.MarkedOnly(false);
        if ConfigPackageTable.FindSet then
          repeat
            ConfigPackageTableParent.Get(ConfigPackage.Code,ConfigPackageTable."Parent Table ID");
            if ConfigPackageTableParent."Parent Table ID" > 0 then
              ConfigPackageTable.Mark(true);
          until ConfigPackageTable.Next = 0;
        ConfigPackageTable.MarkedOnly(true);
        ApplyPackageTables(ConfigPackage,ConfigPackageTable,ApplyMode::PrimaryKey);
        ApplyPackageTables(ConfigPackage,ConfigPackageTable,ApplyMode::NonKeyFields);

        ProcessAppliedPackageRecords(TempConfigRecordForProcessing,TempAppliedConfigPackageRecord);
        if (ConfigPackage.Code <> MSGPPackageCodeTxt) and (ConfigPackage.Code <> QBPackageCodeTxt) then
          DeleteAppliedPackageRecords(TempAppliedConfigPackageRecord); // Do not delete PackageRecords till transactions are created

        ConfigPackage.CalcFields("No. of Errors");
        ErrorCount := ConfigPackage."No. of Errors" - ErrorCount;
        if ErrorCount < 0 then
          ErrorCount := 0;

        RecordsModifiedCount := MaxInt(RecordsModifiedCount - RecordsInsertedCount,0);

        if not HideDialog then
          Message(NoTablesAndErrorsMsg,TableCount,ErrorCount,RecordsInsertedCount,RecordsModifiedCount);
    end;

    local procedure ApplyPackageTables(ConfigPackage: Record "Config. Package";var ConfigPackageTable: Record "Config. Package Table";ApplyMode: Option ,PrimaryKey,NonKeyFields)
    var
        ConfigPackageRecord: Record "Config. Package Record";
    begin
        ConfigPackageTable.SetCurrentKey("Package Processing Order","Processing Order");

        if not HideDialog then
          ConfigProgressBar.Init(ConfigPackageTable.Count,1,
            StrSubstNo(ApplyingPackageMsg,ConfigPackage.Code));
        if ConfigPackageTable.FindSet then
          repeat
            ConfigPackageTable.CalcFields("Table Name");
            ConfigPackageRecord.SetRange("Package Code",ConfigPackageTable."Package Code");
            ConfigPackageRecord.SetRange("Table ID",ConfigPackageTable."Table ID");
            if not HideDialog then
              ConfigProgressBar.Update(ConfigPackageTable."Table Name");
            if not IsTableErrorsExists(ConfigPackageTable) then// Added to show item duplicate errors
              ApplyPackageRecords(
                ConfigPackageRecord,ConfigPackageTable."Package Code",ConfigPackageTable."Table ID",ApplyMode);
          until ConfigPackageTable.Next = 0;

        if not HideDialog then
          ConfigProgressBar.Close;
    end;

    [Scope('Personalization')]
    procedure ApplySelectedPackageRecords(var ConfigPackageRecord: Record "Config. Package Record";PackageCode: Code[20];TableNo: Integer)
    begin
        TempAppliedConfigPackageRecord.DeleteAll;
        TempConfigRecordForProcessing.DeleteAll;

        ApplyPackageRecords(ConfigPackageRecord,PackageCode,TableNo,ApplyMode::PrimaryKey);
        ApplyPackageRecords(ConfigPackageRecord,PackageCode,TableNo,ApplyMode::NonKeyFields);

        ProcessAppliedPackageRecords(TempConfigRecordForProcessing,TempAppliedConfigPackageRecord);
        DeleteAppliedPackageRecords(TempAppliedConfigPackageRecord);
    end;

    local procedure ApplyPackageRecords(var ConfigPackageRecord: Record "Config. Package Record";PackageCode: Code[20];TableNo: Integer;ApplyMode: Option ,PrimaryKey,NonKeyFields)
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigTableProcessingRule: Record "Config. Table Processing Rule";
        ConfigPackageMgt: Codeunit "Config. Package Management";
        ConfigProgressBarRecord: Codeunit "Config. Progress Bar";
        RecRef: RecordRef;
        RecordCount: Integer;
        StepCount: Integer;
        Counter: Integer;
        ProcessingRuleIsSet: Boolean;
    begin
        ConfigPackageTable.Get(PackageCode,TableNo);
        ProcessingRuleIsSet := ConfigTableProcessingRule.FindTableRules(ConfigPackageTable);

        ConfigPackageMgt.SetApplyMode(ApplyMode);
        RecordCount := ConfigPackageRecord.Count;
        if not HideDialog and (RecordCount > 1000) then begin
          StepCount := Round(RecordCount / 100,1);
          ConfigPackageTable.CalcFields("Table Name");
          ConfigProgressBarRecord.Init(
            RecordCount,StepCount,StrSubstNo(ApplyingTableMsg,ConfigPackageTable."Table Name"));
        end;

        Counter := 0;
        if ConfigPackageRecord.FindSet then begin
          RecRef.Open(ConfigPackageRecord."Table ID");
          if ConfigPackageTable."Delete Recs Before Processing" then begin
            RecRef.DeleteAll;
            Commit;
          end;
          repeat
            Counter := Counter + 1;
            if (ApplyMode = ApplyMode::PrimaryKey) or not IsRecordErrorsExistsInPrimaryKeyFields(ConfigPackageRecord) then begin
              if ConfigPackageMgt.Run(ConfigPackageRecord) then begin
                if not ((ApplyMode = ApplyMode::PrimaryKey) or IsRecordErrorsExists(ConfigPackageRecord)) then begin
                  CollectAppliedPackageRecord(ConfigPackageRecord,TempAppliedConfigPackageRecord);
                  if ProcessingRuleIsSet then
                    CollectRecordForProcessingAction(ConfigPackageRecord,ConfigTableProcessingRule);
                end
              end else
                if GetLastErrorText <> '' then begin
                  ConfigPackageMgt.RecordError(
                    ConfigPackageRecord,ConfigPackageMgt.GetValidationFieldID,CopyStr(GetLastErrorText,1,250));
                  ClearLastError;
                  Commit;
                end;
              RecordsInsertedCount += ConfigPackageMgt.GetNumberOfRecordsInserted;
              RecordsModifiedCount += ConfigPackageMgt.GetNumberOfRecordsModified;
            end;
            if not HideDialog and (RecordCount > 1000) then
              ConfigProgressBarRecord.Update(StrSubstNo(RecordsXofYMsg,Counter,RecordCount));
          until ConfigPackageRecord.Next = 0;
        end;

        if not HideDialog and (RecordCount > 1000) then
          ConfigProgressBarRecord.Close;
    end;

    local procedure CollectRecordForProcessingAction(ConfigPackageRecord: Record "Config. Package Record";var ConfigTableProcessingRule: Record "Config. Table Processing Rule")
    begin
        ConfigTableProcessingRule.FindSet;
        repeat
          if ConfigPackageRecord.FitsProcessingFilter(ConfigTableProcessingRule."Rule No.") then
            TempConfigRecordForProcessing.AddRecord(ConfigPackageRecord,ConfigTableProcessingRule."Rule No.");
        until ConfigTableProcessingRule.Next = 0;
    end;

    local procedure CollectAppliedPackageRecord(ConfigPackageRecord: Record "Config. Package Record";var TempConfigPackageRecord: Record "Config. Package Record" temporary)
    begin
        TempConfigPackageRecord.Init;
        TempConfigPackageRecord := ConfigPackageRecord;
        TempConfigPackageRecord.Insert;
    end;

    local procedure DeleteAppliedPackageRecords(var TempConfigPackageRecord: Record "Config. Package Record" temporary)
    var
        ConfigPackageRecord: Record "Config. Package Record";
    begin
        if TempConfigPackageRecord.FindSet then
          repeat
            ConfigPackageRecord.TransferFields(TempConfigPackageRecord);
            ConfigPackageRecord.Delete(true);
          until TempConfigPackageRecord.Next = 0;
        TempConfigPackageRecord.DeleteAll;
        Commit;
    end;

    [Scope('Personalization')]
    procedure ApplyConfigTables(ConfigPackage: Record "Config. Package")
    var
        ConfigPackageTable: Record "Config. Package Table";
    begin
        ConfigPackageTable.Reset;
        ConfigPackageTable.SetRange("Package Code",ConfigPackage.Code);
        ConfigPackageTable.SetFilter("Table ID",'%1|%2|%3|%4|%5|%6|%7|%8',
          DATABASE::"Config. Template Header",DATABASE::"Config. Template Line",
          DATABASE::"Config. Questionnaire",DATABASE::"Config. Question Area",DATABASE::"Config. Question",
          DATABASE::"Config. Line",DATABASE::"Config. Package Filter",DATABASE::"Config. Table Processing Rule");
        if not ConfigPackageTable.IsEmpty then begin
          Commit;
          SetHideDialog(true);
          ApplyPackageTables(ConfigPackage,ConfigPackageTable,ApplyMode::PrimaryKey);
          ApplyPackageTables(ConfigPackage,ConfigPackageTable,ApplyMode::NonKeyFields);
          DeleteAppliedPackageRecords(TempAppliedConfigPackageRecord);
        end;
    end;

    local procedure ProcessAppliedPackageRecords(var TempConfigRecordForProcessing: Record "Config. Record For Processing" temporary;var TempConfigPackageRecord: Record "Config. Package Record" temporary)
    var
        ConfigTableProcessingRule: Record "Config. Table Processing Rule";
        Subscriber: Variant;
    begin
        OnPreProcessPackage(TempConfigRecordForProcessing,Subscriber);
        if TempConfigRecordForProcessing.FindSet then
          repeat
            if not ConfigTableProcessingRule.Process(TempConfigRecordForProcessing) then begin
              TempConfigRecordForProcessing.FindConfigRecord(TempConfigPackageRecord);
              RecordError(TempConfigPackageRecord,0,CopyStr(GetLastErrorText,1,250));
              TempConfigPackageRecord.Delete; // Remove it from the buffer to avoid deletion in the package
              Commit;
            end;
          until TempConfigRecordForProcessing.Next = 0;
        TempConfigRecordForProcessing.DeleteAll;
        OnPostProcessPackage;
    end;

    [Scope('Personalization')]
    procedure SetApplyMode(NewApplyMode: Option ,PrimaryKey,NonKeyFields)
    begin
        ApplyMode := NewApplyMode;
    end;

    [Scope('Personalization')]
    procedure SetFieldFilter(var "Field": Record "Field";TableID: Integer;FieldID: Integer)
    begin
        Field.Reset;
        if TableID > 0 then
          Field.SetRange(TableNo,TableID);
        if FieldID > 0 then
          Field.SetRange("No.",FieldID);
        Field.SetRange(Class,Field.Class::Normal);
        Field.SetRange(Enabled,true);
        Field.SetFilter(ObsoleteState,'<>%1',Field.ObsoleteState::Removed);
    end;

    [Scope('Personalization')]
    procedure SelectAllPackageFields(var ConfigPackageField: Record "Config. Package Field";SetInclude: Boolean)
    var
        ConfigPackageField2: Record "Config. Package Field";
    begin
        ConfigPackageField.SetRange("Primary Key",false);
        ConfigPackageField.SetRange("Include Field",not SetInclude);
        if ConfigPackageField.FindSet then
          repeat
            ConfigPackageField2.Get(ConfigPackageField."Package Code",ConfigPackageField."Table ID",ConfigPackageField."Field ID");
            ConfigPackageField2."Include Field" := SetInclude;
            ConfigPackageField2."Validate Field" :=
              SetInclude and not ValidateException(ConfigPackageField."Table ID",ConfigPackageField."Field ID");
            ConfigPackageField2.Modify;
          until ConfigPackageField.Next = 0;
        ConfigPackageField.SetRange("Include Field");
        ConfigPackageField.SetRange("Primary Key");
    end;

    [Scope('Personalization')]
    procedure SetupProcessingOrder(var ConfigPackageTable: Record "Config. Package Table")
    var
        ConfigPackageTableLoop: Record "Config. Package Table";
        TempConfigPackageTable: Record "Config. Package Table" temporary;
        Flag: Integer;
    begin
        ConfigPackageTableLoop.CopyFilters(ConfigPackageTable);
        if not ConfigPackageTableLoop.FindSet(true) then
          exit;

        Flag := -1; // flag for all selected records: record processing order no was not initialized

        repeat
          ConfigPackageTableLoop."Processing Order" := Flag;
          ConfigPackageTableLoop.Modify;
        until ConfigPackageTableLoop.Next = 0;

        ConfigPackageTable.FindSet(true);
        repeat
          if ConfigPackageTable."Processing Order" = Flag then begin
            SetupTableProcessingOrder(ConfigPackageTable."Package Code",ConfigPackageTable."Table ID",TempConfigPackageTable,1);
            TempConfigPackageTable.Reset;
            TempConfigPackageTable.DeleteAll;
          end;
        until ConfigPackageTable.Next = 0;
    end;

    local procedure SetupTableProcessingOrder(PackageCode: Code[20];TableId: Integer;var CheckedConfigPackageTable: Record "Config. Package Table";StackLevel: Integer): Integer
    var
        ConfigPackageTable: Record "Config. Package Table";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        I: Integer;
        ProcessingOrder: Integer;
    begin
        if CheckedConfigPackageTable.Get(PackageCode,TableId) then
          Error(ProcessingOrderErr,TableId);

        CheckedConfigPackageTable.Init;
        CheckedConfigPackageTable."Package Code" := PackageCode;
        CheckedConfigPackageTable."Table ID" := TableId;
        // level to cleanup temptable from field branch checking history for case with multiple field branches
        CheckedConfigPackageTable."Processing Order" := StackLevel;
        CheckedConfigPackageTable.Insert;

        RecRef.Open(TableId);
        KeyRef := RecRef.KeyIndex(1);

        ProcessingOrder := 1;

        for I := 1 to KeyRef.FieldCount do begin
          FieldRef := KeyRef.FieldIndex(I);
          if (FieldRef.Relation <> 0) and (FieldRef.Relation <> TableId) then
            if ConfigPackageTable.Get(PackageCode,FieldRef.Relation) then begin
              ProcessingOrder :=
                MaxInt(
                  SetupTableProcessingOrder(PackageCode,FieldRef.Relation,CheckedConfigPackageTable,StackLevel + 1) + 1,ProcessingOrder);
              ClearFieldBranchCheckingHistory(PackageCode,CheckedConfigPackageTable,StackLevel);
            end;
        end;

        if ConfigPackageTable.Get(PackageCode,TableId) then begin
          ConfigPackageTable."Processing Order" := ProcessingOrder;
          AdjustProcessingOrder(ConfigPackageTable);
          ConfigPackageTable.Modify;
        end;

        exit(ProcessingOrder);
    end;

    local procedure AdjustProcessingOrder(var ConfigPackageTable: Record "Config. Package Table")
    var
        RelatedConfigPackageTable: Record "Config. Package Table";
    begin
        with ConfigPackageTable do
          case "Table ID" of
            DATABASE::"G/L Account Category": // Pushing G/L Account Category before G/L Account
              if RelatedConfigPackageTable.Get("Package Code",DATABASE::"G/L Account") then
                "Processing Order" := RelatedConfigPackageTable."Processing Order" - 1;
            DATABASE::"Sales Header"..DATABASE::"Purchase Line": // Moving Sales/Purchase Documents down
              "Processing Order" += 4;
            DATABASE::"Company Information":
              "Processing Order" += 1;
            DATABASE::"Custom Report Layout": // Moving Layouts to be on the top
              "Processing Order" := 0;
            // Moving Jobs tables down so contacts table can be processed first
            DATABASE::Job, DATABASE::"Job Task", DATABASE::"Job Planning Line", DATABASE::"Job Journal Line",
            DATABASE::"Job Journal Batch", DATABASE::"Job Posting Group", DATABASE::"Job Journal Template",
            DATABASE::"Job Responsibility":
              "Processing Order" += 4;
          end;
    end;

    local procedure ClearFieldBranchCheckingHistory(PackageCode: Code[20];var CheckedConfigPackageTable: Record "Config. Package Table";StackLevel: Integer)
    begin
        CheckedConfigPackageTable.SetRange("Package Code",PackageCode);
        CheckedConfigPackageTable.SetFilter("Processing Order",'>%1',StackLevel);
        CheckedConfigPackageTable.DeleteAll;
    end;

    local procedure MaxInt(Int1: Integer;Int2: Integer): Integer
    begin
        if Int1 > Int2 then
          exit(Int1);

        exit(Int2);
    end;

    local procedure GetDimSetID(PackageCode: Code[20];DimSetValue: Text[250]): Integer
    var
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageData2: Record "Config. Package Data";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
    begin
        ConfigPackageData.SetRange("Package Code",PackageCode);
        ConfigPackageData.SetRange("Table ID",DATABASE::"Dimension Set Entry");
        ConfigPackageData.SetRange("Field ID",TempDimSetEntry.FieldNo("Dimension Set ID"));
        if ConfigPackageData.FindSet then
          repeat
            if ConfigPackageData.Value = DimSetValue then begin
              TempDimSetEntry.Init;
              ConfigPackageData2.Get(
                ConfigPackageData."Package Code",ConfigPackageData."Table ID",ConfigPackageData."No.",
                TempDimSetEntry.FieldNo("Dimension Code"));
              TempDimSetEntry.Validate("Dimension Code",Format(ConfigPackageData2.Value));
              ConfigPackageData2.Get(
                ConfigPackageData."Package Code",ConfigPackageData."Table ID",ConfigPackageData."No.",
                TempDimSetEntry.FieldNo("Dimension Value Code"));
              TempDimSetEntry.Validate(
                "Dimension Value Code",CopyStr(Format(ConfigPackageData2.Value),1,MaxStrLen(TempDimSetEntry."Dimension Value Code")));
              TempDimSetEntry.Insert;
            end;
          until ConfigPackageData.Next = 0;

        exit(DimMgt.GetDimensionSetID(TempDimSetEntry));
    end;

    [Scope('Personalization')]
    procedure GetDimSetIDForRecord(ConfigPackageRecord: Record "Config. Package Record"): Integer
    var
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageField: Record "Config. Package Field";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimValue: Record "Dimension Value";
        DimMgt: Codeunit DimensionManagement;
        ConfigPackageMgt: Codeunit "Config. Package Management";
        DimCode: Code[20];
        DimValueCode: Code[20];
        DimValueNotFound: Boolean;
    begin
        ConfigPackageData.SetRange("Package Code",ConfigPackageRecord."Package Code");
        ConfigPackageData.SetRange("Table ID",ConfigPackageRecord."Table ID");
        ConfigPackageData.SetRange("No.",ConfigPackageRecord."No.");
        ConfigPackageData.SetRange("Field ID",ConfigMgt.DimensionFieldID,ConfigMgt.DimensionFieldID + 999);
        ConfigPackageData.SetFilter(Value,'<>%1','');
        if ConfigPackageData.FindSet then
          repeat
            if ConfigPackageField.Get(ConfigPackageData."Package Code",ConfigPackageData."Table ID",ConfigPackageData."Field ID") then begin
              ConfigPackageField.TestField(Dimension);
              DimCode := CopyStr(Format(ConfigPackageField."Field Name"),1,20);
              DimValueCode := CopyStr(Format(ConfigPackageData.Value),1,MaxStrLen(TempDimSetEntry."Dimension Value Code"));
              TempDimSetEntry.Init;
              TempDimSetEntry.Validate("Dimension Code",DimCode);
              if DimValue.Get(DimCode,DimValueCode) then begin
                TempDimSetEntry.Validate("Dimension Value Code",DimValueCode);
                TempDimSetEntry.Insert;
              end else begin
                ConfigPackageMgt.FieldError(
                  ConfigPackageData,StrSubstNo(DimValueDoesNotExistsErr,DimCode,DimValueCode),ErrorTypeEnum::General);
                DimValueNotFound := true;
              end;
            end;
          until ConfigPackageData.Next = 0;
        if DimValueNotFound then
          exit(0);
        exit(DimMgt.GetDimensionSetID(TempDimSetEntry));
    end;

    local procedure UpdateDimSetIDValues(ConfigPackage: Record "Config. Package")
    var
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageTableDim: Record "Config. Package Table";
        ConfigPackageDataDimSet: Record "Config. Package Data";
        DimSetEntry: Record "Dimension Set Entry";
    begin
        ConfigPackageTableDim.SetRange("Package Code",ConfigPackage.Code);
        ConfigPackageTableDim.SetRange("Table ID",DATABASE::Dimension,DATABASE::"Default Dimension Priority");
        if not ConfigPackageTableDim.IsEmpty then begin
          ApplyPackageTables(ConfigPackage,ConfigPackageTableDim,ApplyMode::PrimaryKey);
          ApplyPackageTables(ConfigPackage,ConfigPackageTableDim,ApplyMode::NonKeyFields);
        end;

        ConfigPackageDataDimSet.SetRange("Package Code",ConfigPackage.Code);
        ConfigPackageDataDimSet.SetRange("Table ID",DATABASE::"Dimension Set Entry");
        ConfigPackageDataDimSet.SetRange("Field ID",DimSetEntry.FieldNo("Dimension Set ID"));
        if ConfigPackageDataDimSet.IsEmpty then
          exit;

        ConfigPackageData.Reset;
        ConfigPackageData.SetRange("Package Code",ConfigPackage.Code);
        ConfigPackageData.SetFilter("Table ID",'<>%1',DATABASE::"Dimension Set Entry");
        ConfigPackageData.SetRange("Field ID",DATABASE::"Dimension Set Entry");
        if ConfigPackageData.FindSet(true) then begin
          if not HideDialog then
            ConfigProgressBar.Init(ConfigPackageData.Count,1,UpdatingDimSetsMsg);
          repeat
            ConfigPackageTable.Get(ConfigPackage.Code,ConfigPackageData."Table ID");
            ConfigPackageTable.CalcFields("Table Name");
            if not HideDialog then
              ConfigProgressBar.Update(ConfigPackageTable."Table Name");
            if ConfigPackageData.Value <> '' then begin
              ConfigPackageData.Value := Format(GetDimSetID(ConfigPackage.Code,ConfigPackageData.Value));
              ConfigPackageData.Modify;
            end;
          until ConfigPackageData.Next = 0;
          if not HideDialog then
            ConfigProgressBar.Close;
        end;
    end;

    [Scope('Personalization')]
    procedure UpdateDefaultDimValues(ConfigPackageRecord: Record "Config. Package Record";MasterNo: Code[20])
    var
        ConfigPackageTableDim: Record "Config. Package Table";
        ConfigPackageRecordDim: Record "Config. Package Record";
        ConfigPackageDataDim: array [4] of Record "Config. Package Data";
        ConfigPackageField: Record "Config. Package Field";
        ConfigPackageData: Record "Config. Package Data";
        DefaultDim: Record "Default Dimension";
        DimValue: Record "Dimension Value";
        RecordFound: Boolean;
    begin
        ConfigPackageRecord.TestField("Package Code");
        ConfigPackageRecord.TestField("Table ID");

        ConfigPackageData.Reset;
        ConfigPackageData.SetRange("Package Code",ConfigPackageRecord."Package Code");
        ConfigPackageData.SetRange("Table ID",ConfigPackageRecord."Table ID");
        ConfigPackageData.SetRange("No.",ConfigPackageRecord."No.");
        ConfigPackageData.SetRange("Field ID",ConfigMgt.DimensionFieldID,ConfigMgt.DimensionFieldID + 999);
        ConfigPackageData.SetFilter(Value,'<>%1','');
        if ConfigPackageData.FindSet then
          repeat
            if ConfigPackageField.Get(ConfigPackageData."Package Code",ConfigPackageData."Table ID",ConfigPackageData."Field ID") then begin
              // find if Dimension Code already exist
              RecordFound := false;
              ConfigPackageDataDim[1].SetRange("Package Code",ConfigPackageRecord."Package Code");
              ConfigPackageDataDim[1].SetRange("Table ID",DATABASE::"Default Dimension");
              ConfigPackageDataDim[1].SetRange("Field ID",DefaultDim.FieldNo("Table ID"));
              ConfigPackageDataDim[1].SetRange(Value,Format(ConfigPackageRecord."Table ID"));
              if ConfigPackageDataDim[1].FindSet then
                repeat
                  ConfigPackageDataDim[2].SetRange("Package Code",ConfigPackageRecord."Package Code");
                  ConfigPackageDataDim[2].SetRange("Table ID",DATABASE::"Default Dimension");
                  ConfigPackageDataDim[2].SetRange("No.",ConfigPackageDataDim[1]."No.");
                  ConfigPackageDataDim[2].SetRange("Field ID",DefaultDim.FieldNo("No."));
                  ConfigPackageDataDim[2].SetRange(Value,MasterNo);
                  if ConfigPackageDataDim[2].FindSet then
                    repeat
                      ConfigPackageDataDim[3].SetRange("Package Code",ConfigPackageRecord."Package Code");
                      ConfigPackageDataDim[3].SetRange("Table ID",DATABASE::"Default Dimension");
                      ConfigPackageDataDim[3].SetRange("No.",ConfigPackageDataDim[2]."No.");
                      ConfigPackageDataDim[3].SetRange("Field ID",DefaultDim.FieldNo("Dimension Code"));
                      ConfigPackageDataDim[3].SetRange(Value,ConfigPackageField."Field Name");
                      RecordFound := ConfigPackageDataDim[3].FindFirst;
                    until (ConfigPackageDataDim[2].Next = 0) or RecordFound;
                until (ConfigPackageDataDim[1].Next = 0) or RecordFound;
              if not RecordFound then begin
                if not ConfigPackageTableDim.Get(ConfigPackageRecord."Package Code",DATABASE::"Default Dimension") then
                  InsertPackageTable(ConfigPackageTableDim,ConfigPackageRecord."Package Code",DATABASE::"Default Dimension");
                InitPackageRecord(ConfigPackageRecordDim,ConfigPackageTableDim."Package Code",ConfigPackageTableDim."Table ID");
                // Insert Default Dimension record
                InsertPackageData(ConfigPackageDataDim[4],
                  ConfigPackageRecordDim."Package Code",ConfigPackageRecordDim."Table ID",ConfigPackageRecordDim."No.",
                  DefaultDim.FieldNo("Table ID"),Format(ConfigPackageRecord."Table ID"),false);
                InsertPackageData(ConfigPackageDataDim[4],
                  ConfigPackageRecordDim."Package Code",ConfigPackageRecordDim."Table ID",ConfigPackageRecordDim."No.",
                  DefaultDim.FieldNo("No."),Format(MasterNo),false);
                InsertPackageData(ConfigPackageDataDim[4],
                  ConfigPackageRecordDim."Package Code",ConfigPackageRecordDim."Table ID",ConfigPackageRecordDim."No.",
                  DefaultDim.FieldNo("Dimension Code"),ConfigPackageField."Field Name",false);
                if IsBlankDim(ConfigPackageData.Value) then
                  InsertPackageData(ConfigPackageDataDim[4],
                    ConfigPackageRecordDim."Package Code",ConfigPackageRecordDim."Table ID",ConfigPackageRecordDim."No.",
                    DefaultDim.FieldNo("Dimension Value Code"),'',false)
                else
                  InsertPackageData(ConfigPackageDataDim[4],
                    ConfigPackageRecordDim."Package Code",ConfigPackageRecordDim."Table ID",ConfigPackageRecordDim."No.",
                    DefaultDim.FieldNo("Dimension Value Code"),ConfigPackageData.Value,false);
              end else begin
                ConfigPackageDataDim[3].SetRange("Field ID",DefaultDim.FieldNo("Dimension Value Code"));
                ConfigPackageDataDim[3].SetRange(Value);
                ConfigPackageDataDim[3].FindFirst;
                ConfigPackageDataDim[3].Value := ConfigPackageData.Value;
                ConfigPackageDataDim[3].Modify;
              end;
              // Insert Dimension value if needed
              if not IsBlankDim(ConfigPackageData.Value) then
                if not DimValue.Get(ConfigPackageField."Field Name",ConfigPackageData.Value) then begin
                  ConfigPackageRecord.TestField("Package Code");
                  if not ConfigPackageTableDim.Get(ConfigPackageRecord."Package Code",DATABASE::"Dimension Value") then
                    InsertPackageTable(ConfigPackageTableDim,ConfigPackageRecord."Package Code",DATABASE::"Dimension Value");
                  InitPackageRecord(ConfigPackageRecordDim,ConfigPackageTableDim."Package Code",ConfigPackageTableDim."Table ID");
                  InsertPackageData(ConfigPackageDataDim[4],
                    ConfigPackageRecordDim."Package Code",ConfigPackageRecordDim."Table ID",ConfigPackageRecordDim."No.",
                    DimValue.FieldNo("Dimension Code"),ConfigPackageField."Field Name",false);
                  InsertPackageData(ConfigPackageDataDim[4],
                    ConfigPackageRecordDim."Package Code",ConfigPackageRecordDim."Table ID",ConfigPackageRecordDim."No.",
                    DimValue.FieldNo(Code),ConfigPackageData.Value,false);
                end;
            end;
          until ConfigPackageData.Next = 0;
    end;

    local procedure IsBlankDim(Value: Text[250]): Boolean
    begin
        exit(UpperCase(Value) = UpperCase(BlankTxt));
    end;

    [Scope('Personalization')]
    procedure SetHideDialog(NewHideDialog: Boolean)
    begin
        HideDialog := NewHideDialog;
    end;

    [Scope('Personalization')]
    procedure AddConfigTables(PackageCode: Code[20])
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageFilter: Record "Config. Package Filter";
        ConfigLine: Record "Config. Line";
    begin
        ConfigPackageTable.Init;
        InsertPackageTable(ConfigPackageTable,PackageCode,DATABASE::"Config. Questionnaire");
        InsertPackageTable(ConfigPackageTable,PackageCode,DATABASE::"Config. Question Area");
        InsertPackageTable(ConfigPackageTable,PackageCode,DATABASE::"Config. Question");
        InsertPackageTable(ConfigPackageTable,PackageCode,DATABASE::"Config. Template Header");
        InsertPackageTable(ConfigPackageTable,PackageCode,DATABASE::"Config. Template Line");
        InsertPackageTable(ConfigPackageTable,PackageCode,DATABASE::"Config. Tmpl. Selection Rules");
        InsertPackageTable(ConfigPackageTable,PackageCode,DATABASE::"Config. Line");
        InsertPackageFilter(ConfigPackageFilter,PackageCode,DATABASE::"Config. Line",0,ConfigLine.FieldNo("Package Code"),PackageCode);
        InsertPackageTable(ConfigPackageTable,PackageCode,DATABASE::"Config. Package Filter");
        InsertPackageFilter(
          ConfigPackageFilter,PackageCode,DATABASE::"Config. Package Filter",0,ConfigPackageFilter.FieldNo("Package Code"),PackageCode);
        InsertPackageTable(ConfigPackageTable,PackageCode,DATABASE::"Config. Field Mapping");
        InsertPackageTable(ConfigPackageTable,PackageCode,DATABASE::"Config. Table Processing Rule");
        SetSkipTableTriggers(ConfigPackageTable,PackageCode,DATABASE::"Config. Table Processing Rule",true);
        InsertPackageFilter(
          ConfigPackageFilter,PackageCode,DATABASE::"Config. Table Processing Rule",0,
          ConfigPackageFilter.FieldNo("Package Code"),PackageCode);
    end;

    [Scope('Personalization')]
    procedure AssignPackage(var ConfigLine: Record "Config. Line";PackageCode: Code[20])
    var
        ConfigLine2: Record "Config. Line";
        TempConfigLine: Record "Config. Line" temporary;
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageTable2: Record "Config. Package Table";
        LineTypeFilter: Text;
    begin
        CreateConfigLineBuffer(ConfigLine,TempConfigLine,PackageCode);
        CheckConfigLinesToAssign(TempConfigLine);

        LineTypeFilter := ConfigLine.GetFilter("Line Type");
        ConfigLine.SetFilter("Package Code",'<>%1',PackageCode);
        ConfigLine.SetRange("Line Type");
        if ConfigLine.FindSet(true) then
          repeat
            ConfigLine.CheckBlocked;
            if ConfigLine.Status <= ConfigLine.Status::"In Progress" then begin
              if ConfigLine."Line Type" = ConfigLine."Line Type"::Table then begin
                ConfigLine.TestField("Table ID");
                if ConfigPackageTable.Get(ConfigLine."Package Code",ConfigLine."Table ID") then begin
                  ConfigLine2.SetRange("Package Code",PackageCode);
                  ConfigLine2.SetRange("Table ID",ConfigLine."Table ID");
                  CheckConfigLinesToAssign(ConfigLine2);
                  InsertPackageTable(ConfigPackageTable2,PackageCode,ConfigLine."Table ID");
                  ChangePackageCode(ConfigLine."Package Code",PackageCode,ConfigLine."Table ID");
                  ConfigPackageTable.Delete(true);
                end else
                  if not ConfigPackageTable.Get(PackageCode,ConfigLine."Table ID") then
                    InsertPackageTable(ConfigPackageTable,PackageCode,ConfigLine."Table ID");
              end;
              ConfigLine."Package Code" := PackageCode;
              ConfigLine.Modify;
            end;
          until ConfigLine.Next = 0;

        ConfigLine.SetRange("Package Code");
        if LineTypeFilter <> '' then
          ConfigLine.SetFilter("Line Type",LineTypeFilter);
    end;

    local procedure ChangePackageCode(OldPackageCode: Code[20];NewPackageCode: Code[20];TableID: Integer)
    var
        ConfigPackageRecord: Record "Config. Package Record";
        TempConfigPackageRecord: Record "Config. Package Record" temporary;
        ConfigPackageData: Record "Config. Package Data";
        TempConfigPackageData: Record "Config. Package Data" temporary;
        ConfigPackageFilter: Record "Config. Package Filter";
        TempConfigPackageFilter: Record "Config. Package Filter" temporary;
        ConfigPackageError: Record "Config. Package Error";
        TempConfigPackageError: Record "Config. Package Error" temporary;
    begin
        TempConfigPackageRecord.DeleteAll;
        ConfigPackageRecord.SetRange("Package Code",OldPackageCode);
        ConfigPackageRecord.SetRange("Table ID",TableID);
        if ConfigPackageRecord.FindSet(true,true) then
          repeat
            TempConfigPackageRecord := ConfigPackageRecord;
            TempConfigPackageRecord."Package Code" := NewPackageCode;
            TempConfigPackageRecord.Insert;
          until ConfigPackageRecord.Next = 0;
        if TempConfigPackageRecord.FindSet then
          repeat
            ConfigPackageRecord := TempConfigPackageRecord;
            ConfigPackageRecord.Insert;
          until TempConfigPackageRecord.Next = 0;

        TempConfigPackageData.DeleteAll;
        ConfigPackageData.SetRange("Package Code",OldPackageCode);
        ConfigPackageData.SetRange("Table ID",TableID);
        if ConfigPackageData.FindSet(true,true) then
          repeat
            TempConfigPackageData := ConfigPackageData;
            TempConfigPackageData."Package Code" := NewPackageCode;
            TempConfigPackageData.Insert;
          until ConfigPackageData.Next = 0;
        if TempConfigPackageData.FindSet then
          repeat
            ConfigPackageData := TempConfigPackageData;
            ConfigPackageData.Insert;
          until TempConfigPackageData.Next = 0;

        TempConfigPackageError.DeleteAll;
        ConfigPackageError.SetRange("Package Code",OldPackageCode);
        ConfigPackageError.SetRange("Table ID",TableID);
        if ConfigPackageError.FindSet(true,true) then
          repeat
            TempConfigPackageError := ConfigPackageError;
            TempConfigPackageError."Package Code" := NewPackageCode;
            TempConfigPackageError.Insert;
          until ConfigPackageError.Next = 0;
        if TempConfigPackageError.FindSet then
          repeat
            ConfigPackageError := TempConfigPackageError;
            ConfigPackageError.Insert;
          until TempConfigPackageError.Next = 0;

        TempConfigPackageFilter.DeleteAll;
        ConfigPackageFilter.SetRange("Package Code",OldPackageCode);
        ConfigPackageFilter.SetRange("Table ID",TableID);
        if ConfigPackageFilter.FindSet(true,true) then
          repeat
            TempConfigPackageFilter := ConfigPackageFilter;
            TempConfigPackageFilter."Package Code" := NewPackageCode;
            TempConfigPackageFilter.Insert;
          until ConfigPackageFilter.Next = 0;
        if TempConfigPackageFilter.FindSet then
          repeat
            ConfigPackageFilter := TempConfigPackageFilter;
            ConfigPackageFilter.Insert;
          until TempConfigPackageFilter.Next = 0;
    end;

    [Scope('Personalization')]
    procedure CheckConfigLinesToAssign(var ConfigLine: Record "Config. Line")
    var
        TempAllObj: Record AllObj temporary;
    begin
        ConfigLine.SetRange("Line Type",ConfigLine."Line Type"::Table);
        if ConfigLine.FindSet then
          repeat
            if TempAllObj.Get(TempAllObj."Object Type"::Table,ConfigLine."Table ID") then
              Error(ReferenceSameTableErr);
            TempAllObj."Object Type" := TempAllObj."Object Type"::Table;
            TempAllObj."Object ID" := ConfigLine."Table ID";
            TempAllObj.Insert;
          until ConfigLine.Next = 0;
    end;

    local procedure CreateConfigLineBuffer(var ConfigLineNew: Record "Config. Line";var ConfigLineBuffer: Record "Config. Line";PackageCode: Code[20])
    var
        ConfigLine: Record "Config. Line";
    begin
        ConfigLine.SetRange("Package Code",PackageCode);
        AddConfigLineToBuffer(ConfigLine,ConfigLineBuffer);
        AddConfigLineToBuffer(ConfigLineNew,ConfigLineBuffer);
    end;

    local procedure AddConfigLineToBuffer(var ConfigLine: Record "Config. Line";var ConfigLineBuffer: Record "Config. Line")
    begin
        if ConfigLine.FindSet then
          repeat
            if not ConfigLineBuffer.Get(ConfigLine."Line No.") then begin
              ConfigLineBuffer.Init;
              ConfigLineBuffer.TransferFields(ConfigLine);
              ConfigLineBuffer.Insert;
            end;
          until ConfigLine.Next = 0;
    end;

    [Scope('Personalization')]
    procedure GetRelatedTables(var ConfigPackageTable: Record "Config. Package Table")
    var
        TempConfigPackageTable: Record "Config. Package Table" temporary;
        "Field": Record "Field";
        IsHandled: Boolean;
    begin
        TempConfigPackageTable.DeleteAll;
        if ConfigPackageTable.FindSet then
          repeat
            SetFieldFilter(Field,ConfigPackageTable."Table ID",0);
            Field.SetFilter(RelationTableNo,'<>%1&<>%2&..%3',0,ConfigPackageTable."Table ID",99000999);
            IsHandled := false;
            OnBeforeGetFieldRelationTableNo(ConfigPackageTable,Field,TempConfigPackageTable,IsHandled);
            if not IsHandled then
              if Field.FindSet then
                repeat
                  TempConfigPackageTable."Package Code" := ConfigPackageTable."Package Code";
                  TempConfigPackageTable."Table ID" := Field.RelationTableNo;
                  if TempConfigPackageTable.Insert then;
                until Field.Next = 0;
          until ConfigPackageTable.Next = 0;

        ConfigPackageTable.Reset;
        if TempConfigPackageTable.FindSet then
          repeat
            if not ConfigPackageTable.Get(TempConfigPackageTable."Package Code",TempConfigPackageTable."Table ID") then
              InsertPackageTable(ConfigPackageTable,TempConfigPackageTable."Package Code",TempConfigPackageTable."Table ID");
          until TempConfigPackageTable.Next = 0;
    end;

    local procedure GetKeyFieldsOrder(RecRef: RecordRef;PackageCode: Code[20];var TempConfigPackageField: Record "Config. Package Field" temporary)
    var
        ConfigPackageField: Record "Config. Package Field";
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        KeyFieldCount: Integer;
    begin
        KeyRef := RecRef.KeyIndex(1);
        for KeyFieldCount := 1 to KeyRef.FieldCount do begin
          FieldRef := KeyRef.FieldIndex(KeyFieldCount);
          ValidationFieldID := FieldRef.Number;

          if ConfigPackageField.Get(PackageCode,RecRef.Number,FieldRef.Number) then;

          TempConfigPackageField.Init;
          TempConfigPackageField."Package Code" := PackageCode;
          TempConfigPackageField."Table ID" := RecRef.Number;
          TempConfigPackageField."Field ID" := FieldRef.Number;
          TempConfigPackageField."Processing Order" := ConfigPackageField."Processing Order";
          TempConfigPackageField.Insert;
        end;
    end;

    local procedure GetFieldsMarkedAsPrimaryKey(PackageCode: Code[20];TableID: Integer;var TempConfigPackageField: Record "Config. Package Field" temporary)
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.SetRange("Package Code",PackageCode);
        ConfigPackageField.SetRange("Table ID",TableID);
        ConfigPackageField.FilterGroup(-1);
        ConfigPackageField.SetRange("Primary Key",true);
        ConfigPackageField.SetRange(AutoIncrement,true);
        ConfigPackageField.FilterGroup(0);
        if ConfigPackageField.FindSet then
          repeat
            TempConfigPackageField.TransferFields(ConfigPackageField);
            if TempConfigPackageField.Insert then;
          until ConfigPackageField.Next = 0;
    end;

    [Scope('Personalization')]
    procedure GetFieldsOrder(RecRef: RecordRef;PackageCode: Code[20];var TempConfigPackageField: Record "Config. Package Field" temporary)
    var
        ConfigPackageField: Record "Config. Package Field";
        FieldRef: FieldRef;
        FieldCount: Integer;
    begin
        for FieldCount := 1 to RecRef.FieldCount do begin
          FieldRef := RecRef.FieldIndex(FieldCount);

          if ConfigPackageField.Get(PackageCode,RecRef.Number,FieldRef.Number) then;

          TempConfigPackageField.Init;
          TempConfigPackageField."Package Code" := PackageCode;
          TempConfigPackageField."Table ID" := RecRef.Number;
          TempConfigPackageField."Field ID" := FieldRef.Number;
          TempConfigPackageField."Processing Order" := ConfigPackageField."Processing Order";
          TempConfigPackageField.Insert;
        end;
    end;

    local procedure IsRecordErrorsExists(ConfigPackageRecord: Record "Config. Package Record"): Boolean
    var
        ConfigPackageError: Record "Config. Package Error";
    begin
        ConfigPackageError.SetRange("Package Code",ConfigPackageRecord."Package Code");
        ConfigPackageError.SetRange("Table ID",ConfigPackageRecord."Table ID");
        ConfigPackageError.SetRange("Record No.",ConfigPackageRecord."No.");
        exit(not ConfigPackageError.IsEmpty);
    end;

    local procedure IsRecordErrorsExistsInPrimaryKeyFields(ConfigPackageRecord: Record "Config. Package Record"): Boolean
    var
        ConfigPackageError: Record "Config. Package Error";
    begin
        with ConfigPackageError do begin
          SetRange("Package Code",ConfigPackageRecord."Package Code");
          SetRange("Table ID",ConfigPackageRecord."Table ID");
          SetRange("Record No.",ConfigPackageRecord."No.");

          if FindSet then
            repeat
              if ConfigValidateMgt.IsKeyField("Table ID","Field ID") then
                exit(true);
            until Next = 0;
        end;

        exit(false);
    end;

    [Scope('Personalization')]
    procedure UpdateConfigLinePackageData(ConfigPackageCode: Code[20])
    var
        ConfigLine: Record "Config. Line";
        ConfigPackageData: Record "Config. Package Data";
        ShiftLineNo: BigInteger;
        ShiftVertNo: Integer;
        TempValue: BigInteger;
    begin
        ConfigLine.Reset;
        if not ConfigLine.FindLast then
          exit;

        ShiftLineNo := ConfigLine."Line No." + 10000L;
        ShiftVertNo := ConfigLine."Vertical Sorting" + 1;

        with ConfigPackageData do begin
          SetRange("Package Code",ConfigPackageCode);
          SetRange("Table ID",DATABASE::"Config. Line");
          SetRange("Field ID",ConfigLine.FieldNo("Line No."));
          if FindSet then
            repeat
              if Evaluate(TempValue,Value) then begin
                Value := Format(TempValue + ShiftLineNo);
                Modify;
              end;
            until Next = 0;
          SetRange("Field ID",ConfigLine.FieldNo("Vertical Sorting"));
          if FindSet then
            repeat
              if Evaluate(TempValue,Value) then begin
                Value := Format(TempValue + ShiftVertNo);
                Modify;
              end;
            until Next = 0;
        end;
    end;

    [Scope('Personalization')]
    procedure HandlePackageDataDimSetIDForRecord(ConfigPackageRecord: Record "Config. Package Record")
    var
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageMgt: Codeunit "Config. Package Management";
        DimPackageDataExists: Boolean;
        DimSetID: Integer;
    begin
        DimSetID := ConfigPackageMgt.GetDimSetIDForRecord(ConfigPackageRecord);
        DimPackageDataExists :=
          GetDimPackageDataFromRecord(ConfigPackageData,ConfigPackageRecord);
        if DimSetID = 0 then begin
          if DimPackageDataExists then
            ConfigPackageData.Delete(true);
        end else
          if not DimPackageDataExists then
            CreateDimPackageDataFromRecord(ConfigPackageData,ConfigPackageRecord,DimSetID)
          else
            if ConfigPackageData.Value <> Format(DimSetID) then begin
              ConfigPackageData.Value := Format(DimSetID);
              ConfigPackageData.Modify;
            end;
    end;

    local procedure GetDimPackageDataFromRecord(var ConfigPackageData: Record "Config. Package Data";ConfigPackageRecord: Record "Config. Package Record"): Boolean
    begin
        exit(
          ConfigPackageData.Get(
            ConfigPackageRecord."Package Code",ConfigPackageRecord."Table ID",ConfigPackageRecord."No.",
            DATABASE::"Dimension Set Entry"));
    end;

    local procedure CreateDimPackageDataFromRecord(var ConfigPackageData: Record "Config. Package Data";ConfigPackageRecord: Record "Config. Package Record";DimSetID: Integer)
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        if ConfigPackageField.Get(ConfigPackageRecord."Package Code",ConfigPackageRecord."Table ID",DATABASE::"Dimension Set Entry") then begin
          ConfigPackageField.Validate("Include Field",true);
          ConfigPackageField.Modify(true);
        end;

        with ConfigPackageData do begin
          Init;
          "Package Code" := ConfigPackageRecord."Package Code";
          "Table ID" := ConfigPackageRecord."Table ID";
          "Field ID" := DATABASE::"Dimension Set Entry";
          "No." := ConfigPackageRecord."No.";
          Value := Format(DimSetID);
          Insert;
        end;
    end;

    local procedure UpdateValueUsingMapping(var ConfigPackageData: Record "Config. Package Data";ConfigPackageField: Record "Config. Package Field";PackageCode: Code[20])
    var
        ConfigFieldMapping: Record "Config. Field Mapping";
        NewValue: Text[250];
    begin
        if ConfigFieldMapping.Get(
             ConfigPackageData."Package Code",
             ConfigPackageField."Table ID",
             ConfigPackageField."Field ID",
             ConfigPackageData.Value)
        then
          NewValue := ConfigFieldMapping."New Value";

        if (NewValue = '') and (ConfigPackageField."Relation Table ID" <> 0) then
          NewValue := GetMappingFromPKOfRelatedTable(ConfigPackageField,ConfigPackageData.Value);

        if NewValue <> '' then begin
          ConfigPackageData.Validate(Value,NewValue);
          ConfigPackageData.Modify;
        end;

        if ConfigPackageField."Create Missing Codes" then
          CreateMissingCodes(ConfigPackageData,ConfigPackageField."Relation Table ID",PackageCode);
    end;

    local procedure CreateMissingCodes(var ConfigPackageData: Record "Config. Package Data";RelationTableID: Integer;PackageCode: Code[20])
    var
        RecRef: RecordRef;
        KeyRef: KeyRef;
        FieldRef: array [16] of FieldRef;
        i: Integer;
    begin
        RecRef.Open(RelationTableID);
        KeyRef := RecRef.KeyIndex(1);
        for i := 1 to KeyRef.FieldCount do begin
          FieldRef[i] := KeyRef.FieldIndex(i);
          FieldRef[i].Value(RelatedKeyFieldValue(ConfigPackageData,RelationTableID,FieldRef[i].Number));
        end;

        // even "Create Missing Codes" is marked we should not create for blank account numbers and blank/zero account categories should not be created
        if ConfigPackageData."Table ID" <> 15 then begin
          if RecRef.Insert then;
        end else
          if (ConfigPackageData.Value <> '') and ((ConfigPackageData.Value <> '0') and (ConfigPackageData."Field ID" = 80)) or
             ((PackageCode <> QBPackageCodeTxt) and (PackageCode <> MSGPPackageCodeTxt))
          then
            if RecRef.Insert then;
    end;

    local procedure RelatedKeyFieldValue(var ConfigPackageData: Record "Config. Package Data";TableID: Integer;FieldNo: Integer): Text[250]
    var
        ConfigPackageDataOtherFields: Record "Config. Package Data";
        TableRelationsMetadata: Record "Table Relations Metadata";
    begin
        TableRelationsMetadata.SetRange("Table ID",TableID);
        TableRelationsMetadata.SetRange("Field No.",FieldNo);
        TableRelationsMetadata.SetRange("Related Table ID",ConfigPackageData."Table ID");
        if TableRelationsMetadata.FindFirst then begin
          ConfigPackageDataOtherFields.SetRange("Package Code",ConfigPackageData."Package Code");
          ConfigPackageDataOtherFields.SetRange("Table ID",ConfigPackageData."Table ID");
          ConfigPackageDataOtherFields.SetRange("No.",ConfigPackageData."No.");
          ConfigPackageDataOtherFields.SetRange("Field ID",TableRelationsMetadata."Related Field No.");
          ConfigPackageDataOtherFields.FindFirst;
          exit(ConfigPackageDataOtherFields.Value);
        end;
        exit(ConfigPackageData.Value);
    end;

    local procedure GetMappingFromPKOfRelatedTable(ConfigPackageField: Record "Config. Package Field";MappingOldValue: Text[250]): Text[250]
    var
        ConfigPackageField2: Record "Config. Package Field";
        ConfigFieldMapping: Record "Config. Field Mapping";
    begin
        ConfigPackageField2.SetRange("Package Code",ConfigPackageField."Package Code");
        ConfigPackageField2.SetRange("Table ID",ConfigPackageField."Relation Table ID");
        ConfigPackageField2.SetRange("Primary Key",true);
        if ConfigPackageField2.FindFirst then
          if ConfigFieldMapping.Get(
               ConfigPackageField2."Package Code",
               ConfigPackageField2."Table ID",
               ConfigPackageField2."Field ID",
               MappingOldValue)
          then
            exit(ConfigFieldMapping."New Value");
    end;

    [Scope('Personalization')]
    procedure ShowFieldMapping(ConfigPackageField: Record "Config. Package Field")
    var
        ConfigFieldMapping: Record "Config. Field Mapping";
        ConfigFieldMappingPage: Page "Config. Field Mapping";
    begin
        Clear(ConfigFieldMappingPage);
        ConfigFieldMapping.FilterGroup(2);
        ConfigFieldMapping.SetRange("Package Code",ConfigPackageField."Package Code");
        ConfigFieldMapping.SetRange("Table ID",ConfigPackageField."Table ID");
        ConfigFieldMapping.SetRange("Field ID",ConfigPackageField."Field ID");
        ConfigFieldMapping.FilterGroup(0);
        ConfigFieldMappingPage.SetTableView(ConfigFieldMapping);
        ConfigFieldMappingPage.RunModal;
    end;

    [Scope('Personalization')]
    procedure IsBLOBField(TableId: Integer;FieldId: Integer): Boolean
    var
        "Field": Record "Field";
    begin
        if TypeHelper.GetField(TableId,FieldId,Field) then
          exit(Field.Type = Field.Type::BLOB);
        exit(false);
    end;

    local procedure EvaluateBLOBToFieldRef(var ConfigPackageData: Record "Config. Package Data";var FieldRef: FieldRef)
    begin
        ConfigPackageData.CalcFields("BLOB Value");
        FieldRef.Value := ConfigPackageData."BLOB Value";
    end;

    [Scope('Personalization')]
    procedure IsMediaSetField(TableId: Integer;FieldId: Integer): Boolean
    var
        "Field": Record "Field";
    begin
        if TypeHelper.GetField(TableId,FieldId,Field) then
          exit(Field.Type = Field.Type::MediaSet);
        exit(false);
    end;

    local procedure ImportMediaSetFiles(var ConfigPackageData: Record "Config. Package Data";var FieldRef: FieldRef;DoModify: Boolean)
    var
        TempConfigMediaBuffer: Record "Config. Media Buffer" temporary;
        MediaSetIDConfigPackageData: Record "Config. Package Data";
        BlobMediaSetConfigPackageData: Record "Config. Package Data";
        BlobInStream: InStream;
        MediaSetID: Text;
    begin
        if not CanImportMediaField(ConfigPackageData,FieldRef,DoModify,MediaSetID) then
          exit;

        MediaSetIDConfigPackageData.SetRange("Package Code",ConfigPackageData."Package Code");
        MediaSetIDConfigPackageData.SetRange("Table ID",DATABASE::"Config. Media Buffer");
        MediaSetIDConfigPackageData.SetRange("Field ID",TempConfigMediaBuffer.FieldNo("Media Set ID"));
        MediaSetIDConfigPackageData.SetRange(Value,MediaSetID);

        if not MediaSetIDConfigPackageData.FindSet then
          exit;

        TempConfigMediaBuffer.Init;
        TempConfigMediaBuffer.Insert;
        BlobMediaSetConfigPackageData.SetAutoCalcFields("BLOB Value");

        repeat
          BlobMediaSetConfigPackageData.Get(
            MediaSetIDConfigPackageData."Package Code",MediaSetIDConfigPackageData."Table ID",MediaSetIDConfigPackageData."No.",
            TempConfigMediaBuffer.FieldNo("Media Blob"));
          BlobMediaSetConfigPackageData."BLOB Value".CreateInStream(BlobInStream);
          TempConfigMediaBuffer."Media Set".ImportStream(BlobInStream,'');
          TempConfigMediaBuffer.Modify;
        until MediaSetIDConfigPackageData.Next = 0;

        FieldRef.Value := Format(TempConfigMediaBuffer."Media Set");
    end;

    [Scope('Personalization')]
    procedure IsMediaField(TableId: Integer;FieldId: Integer): Boolean
    var
        "Field": Record "Field";
    begin
        if TypeHelper.GetField(TableId,FieldId,Field) then
          exit(Field.Type = Field.Type::Media);
        exit(false);
    end;

    local procedure ImportMediaFiles(var ConfigPackageData: Record "Config. Package Data";var FieldRef: FieldRef;DoModify: Boolean)
    var
        TempConfigMediaBuffer: Record "Config. Media Buffer" temporary;
        MediaIDConfigPackageData: Record "Config. Package Data";
        BlobMediaConfigPackageData: Record "Config. Package Data";
        BlobInStream: InStream;
        MediaID: Text;
    begin
        if not CanImportMediaField(ConfigPackageData,FieldRef,DoModify,MediaID) then
          exit;

        MediaIDConfigPackageData.SetRange("Package Code",ConfigPackageData."Package Code");
        MediaIDConfigPackageData.SetRange("Table ID",DATABASE::"Config. Media Buffer");
        MediaIDConfigPackageData.SetRange("Field ID",TempConfigMediaBuffer.FieldNo("Media ID"));
        MediaIDConfigPackageData.SetRange(Value,MediaID);

        if not MediaIDConfigPackageData.FindFirst then
          exit;

        BlobMediaConfigPackageData.SetAutoCalcFields("BLOB Value");

        BlobMediaConfigPackageData.Get(
          MediaIDConfigPackageData."Package Code",MediaIDConfigPackageData."Table ID",MediaIDConfigPackageData."No.",
          TempConfigMediaBuffer.FieldNo("Media Blob"));
        BlobMediaConfigPackageData."BLOB Value".CreateInStream(BlobInStream);

        TempConfigMediaBuffer.Init;
        TempConfigMediaBuffer.Media.ImportStream(BlobInStream,'');
        TempConfigMediaBuffer.Insert;

        FieldRef.Value := Format(TempConfigMediaBuffer.Media);
    end;

    local procedure CanImportMediaField(var ConfigPackageData: Record "Config. Package Data";var FieldRef: FieldRef;DoModify: Boolean;var MediaID: Text): Boolean
    var
        RecRef: RecordRef;
        DummyNotInitializedGuid: Guid;
    begin
        if not DoModify then
          exit(false);

        RecRef := FieldRef.Record;
        if RecRef.Number = DATABASE::"Config. Media Buffer" then
          exit(false);

        MediaID := Format(ConfigPackageData.Value);
        if (MediaID = Format(DummyNotInitializedGuid)) or (MediaID = '') then
          exit(false);

        exit(true);
    end;

    local procedure GetRecordIDOfRecordError(var ConfigPackageData: Record "Config. Package Data"): Text[250]
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        RecordID: Text;
        KeyFieldCount: Integer;
        KeyFieldValNotEmpty: Boolean;
    begin
        if not ConfigPackageData.FindSet then
          exit;

        RecRef.Open(ConfigPackageData."Table ID");
        KeyRef := RecRef.KeyIndex(1);
        for KeyFieldCount := 1 to KeyRef.FieldCount do begin
          FieldRef := KeyRef.FieldIndex(KeyFieldCount);

          if not ConfigPackageData.Get(ConfigPackageData."Package Code",ConfigPackageData."Table ID",ConfigPackageData."No.",
               FieldRef.Number)
          then
            exit;

          if ConfigPackageData.Value <> '' then
            KeyFieldValNotEmpty := true;

          if KeyFieldCount = 1 then
            RecordID := RecRef.Name + ': ' + ConfigPackageData.Value
          else
            RecordID += ', ' + ConfigPackageData.Value;
        end;

        if not KeyFieldValNotEmpty then
          exit;

        exit(CopyStr(RecordID,1,250));
    end;

    local procedure IsTableErrorsExists(ConfigPackageTable: Record "Config. Package Table"): Boolean
    var
        ConfigPackageError: Record "Config. Package Error";
    begin
        if ConfigPackageTable."Table ID" = 27 then begin
          ConfigPackageError.SetRange("Package Code",ConfigPackageTable."Package Code");
          ConfigPackageError.SetRange("Table ID",ConfigPackageTable."Table ID");
          if ConfigPackageError.Find('-') then
            repeat
              if StrPos(ConfigPackageError."Error Text",'is a duplicate item number') > 0 then
                exit(not ConfigPackageError.IsEmpty);
            until ConfigPackageError.Next = 0;
        end
    end;

    [Scope('Personalization')]
    procedure IsFieldMultiRelation(TableID: Integer;FieldID: Integer): Boolean
    var
        TableRelationsMetadata: Record "Table Relations Metadata";
    begin
        TableRelationsMetadata.SetRange("Table ID",TableID);
        TableRelationsMetadata.SetRange("Field No.",FieldID);
        exit(TableRelationsMetadata.Count > 1);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidatePackageDataRelation(ConfigPackageData: Record "Config. Package Data";ConfigPackageField: Record "Config. Package Field";var ConfigPackageTable: Record "Config. Package Table";var RelationTableNo: Integer;var RelationFieldNo: Integer;var DataInPackageData: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetFieldRelationTableNo(ConfigPackageTable: Record "Config. Package Table";var "Field": Record "Field";var TempConfigPackageTable: Record "Config. Package Table" temporary;var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPreProcessPackage(var ConfigRecordForProcessing: Record "Config. Record For Processing";var Subscriber: Variant)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPostProcessPackage()
    begin
    end;
}

