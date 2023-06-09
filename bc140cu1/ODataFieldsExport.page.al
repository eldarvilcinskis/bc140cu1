page 6713 "OData Fields Export"
{
    Caption = 'Select Fields to Export';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            part(ODataColumnChooseSubForm;"OData Column Choose SubForm")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Choose columns to export';
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        CurrPage.ODataColumnChooseSubForm.PAGE.InitColumns(
          TenantWebService."Object Type",TenantWebService."Object ID",2,TenantWebService."Service Name",'');
        CurrPage.ODataColumnChooseSubForm.PAGE.SetCalledForExcelExport(RecRef);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        TempTenantWebServiceColumns: Record "Tenant Web Service Columns" temporary;
        TenantWebServiceColumns: Record "Tenant Web Service Columns";
        TenantWebServiceFilter: Record "Tenant Web Service Filter";
        TenantWebServiceOData: Record "Tenant Web Service OData";
        ODataUtility: Codeunit ODataUtility;
        SelectText: Text;
        ODataV3FilterText: Text;
        ODataV4FilterText: Text;
    begin
        if CloseAction = ACTION::OK then begin
          CurrPage.ODataColumnChooseSubForm.PAGE.GetColumns(TempTenantWebServiceColumns);
          TenantWebServiceColumns.CreateFromTemp(TempTenantWebServiceColumns,TenantWebService.RecordId);
          TenantWebServiceFilter.CreateFromRecordRef(RecRef,TenantWebService.RecordId);

          TenantWebServiceOData.SetRange(TenantWebServiceID,TenantWebService.RecordId);
          TenantWebServiceOData.FindFirst;
          ODataUtility.GenerateSelectText(TenantWebService."Service Name",TenantWebService."Object Type",SelectText);
          ODataUtility.GenerateODataV3FilterText(TenantWebService."Service Name",TenantWebService."Object Type",ODataV3FilterText);
          ODataUtility.GenerateODataV4FilterText(TenantWebService."Service Name",TenantWebService."Object Type",ODataV4FilterText);
          TenantWebServiceOData.SetOdataSelectClause(SelectText);
          TenantWebServiceOData.SetOdataFilterClause(ODataV3FilterText);
          TenantWebServiceOData.SetOdataV4FilterClause(ODataV4FilterText);
          TenantWebServiceOData.Modify(true);

          ODataUtility.GenerateExcelWorkBook(TenantWebService."Object Type",TenantWebService."Service Name",true);
        end;
    end;

    var
        TenantWebService: Record "Tenant Web Service";
        RecRef: RecordRef;

    [Scope('Personalization')]
    procedure SetExportData(var ExportTenantWebService: Record "Tenant Web Service";var ExportRecRef: RecordRef)
    begin
        TenantWebService := ExportTenantWebService;
        RecRef := ExportRecRef;
    end;
}

