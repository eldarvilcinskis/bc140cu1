page 1526 "Workflow Event Conditions"
{
    Caption = 'Event Conditions';
    DataCaptionExpression = EventDescription;
    PageType = StandardDialog;
    SourceTable = "Workflow Rule";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control13)
            {
                ShowCaption = false;
                group(Control12)
                {
                    InstructionalText = 'Set conditions for the event:';
                    ShowCaption = false;
                    Visible = ShowFilter;
                    grid(Control15)
                    {
                        GridLayout = Rows;
                        ShowCaption = false;
                        group(Control14)
                        {
                            ShowCaption = false;
                            field(Condition; '')
                            {
                                ApplicationArea = Suite;
                                Caption = 'Condition';
                                ShowCaption = false;
                                ToolTip = 'Specifies the workflow event condition.';
                            }
                            field(FilterConditionText; FilterConditionText)
                            {
                                ApplicationArea = Suite;
                                Editable = false;
                                ShowCaption = false;

                                trigger OnAssistEdit()
                                var
                                    WorkflowStep: Record "Workflow Step";
                                begin
                                    WorkflowStep.Get("Workflow Code", "Workflow Step ID");

                                    WorkflowStep.OpenEventConditions;

                                    FilterConditionText := WorkflowStep.GetConditionAsDisplayText;
                                end;
                            }
                        }
                    }
                }
                group(Control11)
                {
                    InstructionalText = '';
                    ShowCaption = false;
                    group(Control10)
                    {
                        InstructionalText = 'Set a condition for when a field value changes:';
                        ShowCaption = false;
                        Visible = ShowAdvancedCondition;
                        grid(Control9)
                        {
                            GridLayout = Rows;
                            ShowCaption = false;
                            group(Control7)
                            {
                                ShowCaption = false;
                                field("Field"; '')
                                {
                                    ApplicationArea = Suite;
                                    Caption = 'Field';
                                    ShowCaption = false;
                                    ToolTip = 'Specifies the field in which a change can occur that the workflow monitors.';
                                }
                                field(FieldCaption2; FieldCaption2)
                                {
                                    ApplicationArea = Suite;
                                    DrillDown = false;
                                    ShowCaption = false;

                                    trigger OnLookup(var Text: Text): Boolean
                                    var
                                        "Field": Record "Field";
                                    begin
                                        FindAndFilterToField(Field, Text);
                                        Field.SetRange("Field Caption");
                                        Field.SetRange("No.");

                                        if PAGE.RunModal(PAGE::"Field List", Field) = ACTION::LookupOK then
                                            SetField(Field."No.");
                                    end;

                                    trigger OnValidate()
                                    var
                                        "Field": Record "Field";
                                    begin
                                        if FieldCaption2 = '' then begin
                                            SetField(0);
                                            exit;
                                        end;

                                        if not FindAndFilterToField(Field, FieldCaption2) then
                                            Error(FeildNotExistErr, FieldCaption2);

                                        if Field.Count = 1 then begin
                                            SetField(Field."No.");
                                            exit;
                                        end;

                                        if PAGE.RunModal(PAGE::"Field List", Field) = ACTION::LookupOK then
                                            SetField(Field."No.")
                                        else
                                            Error(FeildNotExistErr, FieldCaption2);
                                    end;
                                }
                                field(is; '')
                                {
                                    ApplicationArea = Suite;
                                    Caption = 'is';
                                    ShowCaption = false;
                                }
                                field(Operator; Operator)
                                {
                                    ApplicationArea = Suite;
                                    ShowCaption = false;
                                    ToolTip = 'Specifies the type of change that can occur to the field on the record. In the Change Customer Credit Limit Approval Workflow workflow template, the event condition operators are Increased, Decreased, Changed.';
                                }
                            }
                        }
                    }
                    field(AddChangeValueConditionLbl; AddChangeValueConditionLbl)
                    {
                        ApplicationArea = Suite;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            ShowAdvancedCondition := not ShowAdvancedCondition;

                            if not ShowAdvancedCondition then
                                ClearRule;

                            UpdateLabels;
                        end;
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetField("Field No.");

        ShowFilter := true;

        ShowAdvancedCondition := "Field No." <> 0;
        UpdateLabels;
    end;

    trigger OnInit()
    begin
        CurrPage.LookupMode := true;
    end;

    trigger OnOpenPage()
    var
        WorkflowStep: Record "Workflow Step";
        WorkflowEvent: Record "Workflow Event";
    begin
        WorkflowStep.Get("Workflow Code", "Workflow Step ID");
        WorkflowEvent.Get(WorkflowStep."Function Name");
        EventDescription := WorkflowEvent.Description;
        FilterConditionText := WorkflowStep.GetConditionAsDisplayText;
    end;

    var
        FilterConditionText: Text;
        AddChangeValueConditionLabelTxt: Label 'Add a condition for when a field value changes.';
        ShowAdvancedCondition: Boolean;
        AddChangeValueConditionLbl: Text;
        FieldCaption2: Text[250];
        RemoveChangeValueConditionLabelTxt: Label 'Remove the condition.';
        FeildNotExistErr: Label 'Field %1 does not exist.', Comment = '%1 = Field Caption';
        EventDescription: Text;
        ShowFilter: Boolean;

    [Scope('Personalization')]
    procedure SetRule(TempWorkflowRule: Record "Workflow Rule" temporary)
    begin
        Rec := TempWorkflowRule;
        Insert(true);
    end;

    local procedure ClearRule()
    begin
        SetField(0);
        Operator := Operator::Changed;
    end;

    local procedure SetField(FieldNo: Integer)
    begin
        "Field No." := FieldNo;
        CalcFields("Field Caption");
        FieldCaption2 := "Field Caption";
    end;

    local procedure FindAndFilterToField(var "Field": Record "Field"; CaptionToFind: Text): Boolean
    begin
        Field.FilterGroup(2);
        Field.SetRange(TableNo, "Table ID");
        Field.SetFilter(Type, StrSubstNo('%1|%2|%3|%4|%5|%6|%7|%8|%9|%10|%11|%12|%13',
            Field.Type::Boolean,
            Field.Type::Text,
            Field.Type::Code,
            Field.Type::Decimal,
            Field.Type::Integer,
            Field.Type::BigInteger,
            Field.Type::Date,
            Field.Type::Time,
            Field.Type::DateTime,
            Field.Type::DateFormula,
            Field.Type::Option,
            Field.Type::Duration,
            Field.Type::RecordID));
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);

        if CaptionToFind = "Field Caption" then
            Field.SetRange("No.", "Field No.")
        else
            Field.SetFilter("Field Caption", '%1', '@' + CaptionToFind + '*');

        exit(Field.FindFirst);
    end;

    local procedure UpdateLabels()
    begin
        if ShowAdvancedCondition then
            AddChangeValueConditionLbl := RemoveChangeValueConditionLabelTxt
        else
            AddChangeValueConditionLbl := AddChangeValueConditionLabelTxt;
    end;
}

