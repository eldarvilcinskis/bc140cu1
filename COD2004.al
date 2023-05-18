codeunit 2004 "Machine Learning KeyVaultMgmt."
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        LimitTypeOption: Option Year,Month,Day,Hour;

    [Scope('Internal')]
    procedure GetMachineLearningCredentials(SecretName: Text;var ApiUri: Text[250];var ApiKey: Text[200];var LimitType: Option;var Limit: Decimal)
    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
        JSONManagement: Codeunit "JSON Management";
        TenantManagement: Codeunit "Tenant Management";
        JsonObject: DotNet JObject;
        ApiKeyJArray: DotNet JArray;
        ApiUriJArray: DotNet JArray;
        JObject: DotNet JObject;
        SecretValue: Text;
        LimitTxt: Text;
        LimitTypeTxt: Text;
        Index: Integer;
    begin
        if not AzureKeyVaultManagement.GetAzureKeyVaultSecret(SecretValue,SecretName) then
          exit;

        JSONManagement.InitializeObject(SecretValue);
        JSONManagement.GetJSONObject(JsonObject);
        JSONManagement.GetStringPropertyValueFromJObjectByName(JsonObject,'Limit',LimitTxt);
        Evaluate(Limit,LimitTxt,9);
        if not JSONManagement.GetStringPropertyValueFromJObjectByName(JsonObject,'LimitType',LimitTypeTxt) then
          LimitTypeTxt := 'Month';
        LimitType := GetLimitTypeOptionFromText(LimitTypeTxt);
        if not JSONManagement.GetArrayPropertyValueFromJObjectByName(JsonObject,'ApiKeys',ApiKeyJArray) then
          exit;
        if not JSONManagement.GetArrayPropertyValueFromJObjectByName(JsonObject,'ApiUris',ApiUriJArray) then
          exit;

        JSONManagement.InitializeCollectionFromJArray(ApiKeyJArray);
        if JSONManagement.GetCollectionCount > 0 then begin
          Index := TenantManagement.GenerateTenantIdBasedRandomNumber(JSONManagement.GetCollectionCount) - 1;
          if JSONManagement.GetJObjectFromCollectionByIndex(JObject,Index) then
            ApiKey := Format(JObject);
          JSONManagement.InitializeCollectionFromJArray(ApiUriJArray);
          if JSONManagement.GetJObjectFromCollectionByIndex(JObject,Index) then
            ApiUri := Format(JObject);
        end;
    end;

    [Scope('Personalization')]
    procedure GetLimitTypeOptionFromText(LimitTypeTxt: Text): Integer
    begin
        case LimitTypeTxt of
          'Year':
            exit(LimitTypeOption::Year);
          'Month':
            exit(LimitTypeOption::Month);
          'Day':
            exit(LimitTypeOption::Day);
          'Hour':
            exit(LimitTypeOption::Hour);
        end;
    end;
}

