page 9631 "Page Inspection"
{
    Caption = 'Page Inspection';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    InstructionalText = 'See information about the page, its different elements, and the source behind the data it displays.';
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Page Info And Fields";

    layout
    {
        area(content)
        {
            group(Control5)
            {
                ShowCaption = false;
                field(PageInfo;PageInfo)
                {
                    ApplicationArea = All;
                    Caption = 'Page';
                    ToolTip = 'Specifies the selected page''s name, number, and type.';
                }
            }
            group(Control12)
            {
                ShowCaption = false;
                Visible = PageIsReport;
                field(PageIsReportTextLbl;PageIsReportTextLbl)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the page is a related to a report.';
                }
            }
            group(Control20)
            {
                ShowCaption = false;
                Visible = PageIsRoleCenter;
                field(PageIsRoleCenterTextLbl;PageIsRoleCenterTextLbl)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the page has a Role Center type page.';
                }
            }
            group(Control24)
            {
                ShowCaption = false;
                Visible = IsViewQueryPage;
                field(QueryInfo;QueryInfo)
                {
                    ApplicationArea = All;
                    Caption = 'Query';
                    ToolTip = 'Specifies the name and number of the inspected query.';
                }
            }
            group(Control10)
            {
                ShowCaption = false;
                Visible = NOT PageIsReport AND NOT PageIsRoleCenter AND NOT IsViewQueryPage;
                field(TableInfo;TableInfo)
                {
                    ApplicationArea = All;
                    Caption = 'Table';
                    ToolTip = 'Specifies the name and number of the selected page''s source table.';
                }
            }
            group(Control11)
            {
                ShowCaption = false;
                Visible = NOT PageIsReport AND NOT PageIsRoleCenter AND NOT IsViewTablePage AND PageHasSourceTable AND NOT PageSourceTableIsTemporary AND NOT IsViewQueryPage;
                field(ViewTableLbl;ViewTableLbl)
                {
                    AccessByPermission = System "Tools, Zoom"=X;
                    ApplicationArea = All;
                    DrillDown = true;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the URL to view all records and fields of the page''s source table in a separate browser window. Requires permission to run tables.';

                    trigger OnDrillDown()
                    begin
                        HyperLink(ViewFullTableURL);
                    end;
                }
            }
            group(Control7)
            {
                ShowCaption = false;
                Visible = NOT PageIsReport AND NOT PageIsRoleCenter AND NOT PageIsSystemPart AND NOT IsViewQueryPage AND PageHasSourceTable AND PageSourceTableIsTemporary;
                field(SourceTableIsTemporaryLbl;SourceTableIsTemporaryLbl)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the table is a temporary table.';
                }
            }
            grid(Control13)
            {
                ShowCaption = false;
                field(ShowFieldsTextLbl;ShowFieldsTextLbl)
                {
                    AccessByPermission = System "Tools, Zoom"=X;
                    ApplicationArea = All;
                    DrillDown = true;
                    Style = Strong;
                    StyleExpr = ShowFields;
                    ToolTip = 'Specifies all fields for the current record, including those not shown on the page. The information includes the field''s name, number, data type, value, and if it is a primary key (PK).';

                    trigger OnDrillDown()
                    begin
                        ShowFields := true;
                        ShowExtensions := false;
                        ShowFilters := false;

                        // hide message about access in Fields are active tab
                        ShowNoPermissionForExtensions := false;

                        CurrPage.Fields.PAGE.UpdatePage("Current Form ID");
                    end;
                }
                field(ShowExtensionsTextLbl;ShowExtensionsTextLbl)
                {
                    AccessByPermission = System "Tools, Zoom"=X;
                    ApplicationArea = All;
                    DrillDown = true;
                    Style = Strong;
                    StyleExpr = ShowExtensions;
                    ToolTip = 'Specifies which installed extensions add or modify the page or source table.';

                    trigger OnDrillDown()
                    var
                        NavAppObjectMetadata: Record "NAV App Object Metadata";
                        NavAppInstalledApp: Record "NAV App Installed App";
                    begin
                        ShowExtensions := true;
                        ShowFields := false;
                        ShowFilters := false;

                        if NavAppObjectMetadata.ReadPermission and NavAppInstalledApp.ReadPermission then
                          ShowNoPermissionForExtensions := false
                        else
                          ShowNoPermissionForExtensions := true;

                        CurrPage.Extensions.PAGE.FilterForExtAffectingPage("Page ID","Source Table No.");
                    end;
                }
                field(ShowFiltersTextLbl;ShowFiltersTextLbl)
                {
                    AccessByPermission = System "Tools, Zoom"=X;
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = ShowFilters;
                    ToolTip = 'Specifies the filters that are applied to the page to refine the data.';

                    trigger OnDrillDown()
                    begin
                        ShowFilters := true;
                        ShowFields := false;
                        ShowExtensions := false;

                        // hide message about access in Fields are active tab
                        ShowNoPermissionForExtensions := false;

                        CurrPage.Filters.PAGE.UpdatePage("Current Form ID");
                    end;
                }
            }
            part("Fields";"Page Inspection Fields")
            {
                AccessByPermission = System "Tools, Zoom"=X;
                ApplicationArea = All;
                Visible = ShowFields;
            }
            part(Extensions;"Page Inspection Extensions")
            {
                AccessByPermission = System "Tools, Zoom"=X;
                ApplicationArea = All;
                Editable = false;
                Enabled = false;
                Visible = ShowExtensions;
            }
            part(Filters;"Page Inspection Filters")
            {
                AccessByPermission = System "Tools, Zoom"=X;
                ApplicationArea = All;
                Visible = ShowFilters;
            }
            group(Control22)
            {
                ShowCaption = false;
                Visible = ShowNoPermissionForExtensions;
                field(NoViewExtensionsPermissionLbl;NoViewExtensionsPermissionLbl)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies that you do not have permission to view the tables that list the extensions affecting this page.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetElementsVisibilities;

        CurrPage.Fields.PAGE.UpdatePage("Current Form ID");
        CurrPage.Fields.PAGE.SetFieldListVisbility(PageHasSourceTable);

        CurrPage.Extensions.PAGE.FilterForExtAffectingPage("Page ID","Source Table No.");
        CurrPage.Extensions.PAGE.SetExtensionListVisbility(not PageIsReport);

        CurrPage.Filters.PAGE.UpdatePage("Current Form ID");
        CurrPage.Filters.PAGE.SetFilterListVisbility(PageHasSourceTable);
    end;

    trigger OnOpenPage()
    begin
        SetInitialVisibilities;
    end;

    var
        PageInfo: Text;
        TableInfo: Text;
        QueryInfo: Text;
        ViewFullTableURL: Text;
        ViewTableLbl: Label 'View table';
        ShowFields: Boolean;
        ShowExtensions: Boolean;
        ShowFilters: Boolean;
        ShowFieldsTextLbl: Label 'Table Fields';
        ShowExtensionsTextLbl: Label 'Extensions';
        ShowFiltersTextLbl: Label 'Page Filters';
        NoViewExtensionsPermissionLbl: Label 'You do not have permission to view the tables that list the extensions affecting this page.';
        NoSourceTableLbl: Label 'This page does not have a source table.';
        ShowNoPermissionForExtensions: Boolean;
        PageHasSourceTable: Boolean;
        PageSourceTableIsTemporary: Boolean;
        SourceTableIsTemporaryLbl: Label 'The source table of this page is temporary.';
        PageIsSystemPart: Boolean;
        PageIsReport: Boolean;
        PageIsReportTextLbl: Label 'This page is a Report page.';
        PageIsRoleCenter: Boolean;
        PageIsRoleCenterTextLbl: Label 'This is a Role Center page.';
        IsViewTablePage: Boolean;
        ViewTablePageLbl: Label 'View Table page.';
        IsViewQueryPage: Boolean;

    local procedure SetInitialVisibilities()
    begin
        ShowFields := true;
        ShowExtensions := false;
        ShowFilters := false;
        ShowNoPermissionForExtensions := false;
        PageHasSourceTable := true;
        PageSourceTableIsTemporary := false;

        PageIsSystemPart := false;
        PageIsReport := false;
        PageIsRoleCenter := false;
        IsViewTablePage := false;
        IsViewQueryPage := false;
    end;

    local procedure SetElementsVisibilities()
    var
        PageMetadata: Record "Page Metadata";
        BaseUrlTxt: Text;
    begin
        // for some reason that helps to reset range in data provider
        // when going from form without a source table to form with a source table
        SetInitialVisibilities;

        if "Source Data Type" = 'Query' then begin
          IsViewQueryPage := true;
          QueryInfo := StrSubstNo('%1 (%2)',"Source Table Name","Source Table No.");
        end;

        PageMetadata.Reset;
        PageMetadata.SetFilter(ID,'%1',"Page ID");
        if PageMetadata.FindFirst then
          PageSourceTableIsTemporary := PageMetadata.SourceTableTemporary;

        PageInfo := StrSubstNo('%1 (%2, %3)',"Page Name","Page ID","Page Type");
        if "Page Name" = ViewTablePageLbl then begin
          IsViewTablePage := true;
          PageInfo := StrSubstNo('%1 (%2)',"Page Name","Page Type");
        end;

        if "Source Table No." <= 0 then begin
          TableInfo := NoSourceTableLbl;
          PageHasSourceTable := false;
        end else begin
          TableInfo := StrSubstNo('%1 (%2)',"Source Table Name","Source Table No.");
          PageHasSourceTable := true;
          BaseUrlTxt := GetUrl(CLIENTTYPE::Current,CompanyName);
          if StrPos(BaseUrlTxt,'?') = 0 then
            ViewFullTableURL := StrSubstNo('%1?table=%2',BaseUrlTxt,"Source Table No.")
          else
            ViewFullTableURL := StrSubstNo('%1&table=%2',BaseUrlTxt,"Source Table No.");
        end;

        if "Current Form ID" = '00000000-0000-0000-0000-000000000001' then
          PageIsRoleCenter := true
        else
          PageIsRoleCenter := false;

        if "Current Form ID" = '00000000-0000-0000-0000-000000000002' then
          PageIsReport := true
        else
          PageIsReport := false;

        PageIsSystemPart := ("Current Form ID" = '00000000-0000-0000-0000-000000000003') or
          ("Current Form ID" = '00000000-0000-0000-0000-000000000004');
    end;
}

