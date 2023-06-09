page 5336 "CRM Coupling Record"
{
    Caption = 'Dynamics 365 for Sales Coupling Record';
    PageType = StandardDialog;
    SourceTable = "Coupling Record Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control11)
            {
                ShowCaption = false;
                grid(Coupling)
                {
                    Caption = 'Coupling';
                    GridLayout = Columns;
                    group("Business Central")
                    {
                        Caption = 'Business Central';
                        field(NAVName;"NAV Name")
                        {
                            ApplicationArea = Suite;
                            Caption = 'Business Central Name';
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the name of the record in Business Central to couple to an existing Dynamics 365 for Sales record.';
                        }
                        group(Control13)
                        {
                            ShowCaption = false;
                            field(SyncActionControl;"Sync Action")
                            {
                                ApplicationArea = Suite;
                                Caption = 'Synchronize After Coupling';
                                Enabled = NOT "Create New";
                                OptionCaption = 'No,Yes - Use the Business Central data,Yes - Use the Dynamics 365 for Sales data';
                                ToolTip = 'Specifies whether to synchronize the data in the record in Business Central and the record in Dynamics 365 for Sales.';
                            }
                        }
                    }
                    group("Dynamics 365 for Sales")
                    {
                        Caption = 'Dynamics 365 for Sales';
                        field(CRMName;"CRM Name")
                        {
                            ApplicationArea = Suite;
                            Caption = 'Dynamics 365 for Sales Name';
                            Enabled = NOT "Create New";
                            ShowCaption = false;
                            ToolTip = 'Specifies the name of the record in Dynamics 365 for Sales that is coupled to the record in Business Central.';

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                LookUpCRMName;
                                RefreshFields;
                            end;

                            trigger OnValidate()
                            begin
                                RefreshFields
                            end;
                        }
                        group(Control15)
                        {
                            ShowCaption = false;
                            field(CreateNewControl;"Create New")
                            {
                                ApplicationArea = Suite;
                                Caption = 'Create New';
                                Enabled = EnableCreateNew;
                                ToolTip = 'Specifies if a new record in Dynamics 365 for Sales is automatically created and coupled to the related record in Business Central.';
                            }
                        }
                    }
                }
            }
            part(CoupledFields;"CRM Coupled Fields")
            {
                ApplicationArea = Suite;
                Caption = 'Fields';
                ShowFilter = false;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        RefreshFields
    end;

    var
        EnableCreateNew: Boolean;

    [Scope('Personalization')]
    procedure GetCRMId(): Guid
    begin
        exit("CRM ID");
    end;

    [Scope('Personalization')]
    procedure GetPerformInitialSynchronization(): Boolean
    begin
        exit(Rec.GetPerformInitialSynchronization);
    end;

    [Scope('Personalization')]
    procedure GetInitialSynchronizationDirection(): Integer
    begin
        exit(Rec.GetInitialSynchronizationDirection);
    end;

    local procedure RefreshFields()
    begin
        CurrPage.CoupledFields.PAGE.SetSourceRecord(Rec);
    end;

    [Scope('Personalization')]
    procedure SetSourceRecordID(RecordID: RecordID)
    begin
        Initialize(RecordID);
        Insert;
        EnableCreateNew := "Sync Action" = "Sync Action"::"To Integration Table";
    end;
}

