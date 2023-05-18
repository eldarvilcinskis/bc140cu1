table 1432 "Net Promoter Score Setup"
{
    Caption = 'Net Promoter Score Setup';
    DataPerCompany = false;

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2;"API URL";BLOB)
        {
            Caption = 'API URL';
            DataClassification = SystemMetadata;
        }
        field(3;"Expire Time";DateTime)
        {
            Caption = 'Expire Time';
            DataClassification = SystemMetadata;
        }
        field(4;"Time Between Requests";Integer)
        {
            Caption = 'Time Between Requests';
            ObsoleteReason = 'This field is not needed and it is not used anymore.';
            ObsoleteState = Removed;
        }
        field(5;"Request Timeout";Integer)
        {
            Caption = 'Request Timeout';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    var
        NpsApiUrlTxt: Label 'NpsApiUrl', Locked=true;
        NpsRequestTimeoutTxt: Label 'NpsRequestTimeout', Locked=true;
        NpsCacheLifeTimeTxt: Label 'NpsCacheLifeTime', Locked=true;
        NpsParametersTxt: Label 'NpsParameters', Locked=true;
        NpsCategoryTxt: Label 'AL NPS Prompt', Locked=true;
        SecretNotFoundMsg: Label 'Secret %1 is not found.', Locked=true;
        ParameterNotFoundMsg: Label 'Parameter %1 is not found.', Locked=true;

    [Scope('Internal')]
    procedure GetApiUrl(): Text
    var
        InStream: InStream;
        ApiUrl: Text;
    begin
        SetApiUrl;

        if not Get then
          exit('');

        ApiUrl := '';
        CalcFields("API URL");
        if "API URL".HasValue then begin
          "API URL".CreateInStream(InStream);
          InStream.Read(ApiUrl);
        end;
        exit(ApiUrl);
    end;

    local procedure SetApiUrl()
    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
        OutStream: OutStream;
        ApiUrl: Text;
        CacheLifeTime: Integer;
        RequestTimeout: Integer;
    begin
        if Get then
          if CurrentDateTime < "Expire Time" then
            exit;

        RequestTimeout := DefaultRequestTimeout;
        CacheLifeTime := DefaultCacheLifeTime;
        if AzureKeyVaultManagement.IsEnabled then
          if not GetNetPromoterScoreParameters(ApiUrl,RequestTimeout,CacheLifeTime) then
            if AzureKeyVaultManagement.GetAzureKeyVaultSecret(ApiUrl,NpsApiUrlTxt) then
              CacheLifeTime := GetCacheLifeTimeFromAzureKeyVault;

        LockTable;

        if not Get then begin
          Init;
          "Primary Key" := '';
          Insert;
        end;

        if ApiUrl = '' then
          Clear("API URL")
        else begin
          "API URL".CreateOutStream(OutStream);
          OutStream.Write(ApiUrl);
        end;

        "Request Timeout" := RequestTimeout;
        "Expire Time" := CurrentDateTime + CacheLifeTime * MillisecondsInMinute;
        Modify;

        Commit;
    end;

    procedure GetRequestTimeout(): Integer
    begin
        if not Get then
          exit(DefaultRequestTimeout);
        if "Request Timeout" <= 0 then
          exit(DefaultRequestTimeout);
        if "Request Timeout" < MinRequestTimeout then
          exit(MinRequestTimeout);
        exit("Request Timeout");
    end;

    local procedure GetCacheLifeTimeFromAzureKeyVault(): Integer
    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
        CacheLifeTimeValue: Text;
        CacheLifeTimeNumber: Integer;
    begin
        if AzureKeyVaultManagement.GetAzureKeyVaultSecret(CacheLifeTimeValue,NpsCacheLifeTimeTxt) then
          if Evaluate(CacheLifeTimeNumber,CacheLifeTimeValue) then begin
            if CacheLifeTimeNumber < MinCacheLifeTime then
              CacheLifeTimeNumber := MinCacheLifeTime;
            exit(CacheLifeTimeNumber);
          end;
        exit(DefaultCacheLifeTime);
    end;

    local procedure GetNetPromoterScoreParameters(var ApiUrl: Text;var RequestTimeoutMilliseconds: Integer;var CacheLifeTimeMinutes: Integer): Boolean
    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
        JSONManagement: Codeunit "JSON Management";
        JsonObject: DotNet JObject;
        SecretValue: Text;
        RequestTimeoutValueTxt: Text;
        CacheLifeTimeValueTxt: Text;
    begin
        AzureKeyVaultManagement.AddAllowedSecretName(NpsParametersTxt);
        if not AzureKeyVaultManagement.GetAzureKeyVaultSecret(SecretValue,NpsParametersTxt) then begin
          SendTraceTag('0000832',NpsCategoryTxt,VERBOSITY::Warning,
            StrSubstNo(SecretNotFoundMsg,NpsParametersTxt),DATACLASSIFICATION::SystemMetadata);
          exit(false);
        end;

        JSONManagement.InitializeObject(SecretValue);
        JSONManagement.GetJSONObject(JsonObject);

        if not JSONManagement.GetStringPropertyValueFromJObjectByName(JsonObject,NpsApiUrlTxt,ApiUrl) then begin
          SendTraceTag('0000833',NpsCategoryTxt,VERBOSITY::Warning,
            StrSubstNo(ParameterNotFoundMsg,NpsApiUrlTxt),DATACLASSIFICATION::SystemMetadata);
          exit(false);
        end;

        if JSONManagement.GetStringPropertyValueFromJObjectByName(JsonObject,NpsRequestTimeoutTxt,RequestTimeoutValueTxt) then
          if Evaluate(RequestTimeoutMilliseconds,RequestTimeoutValueTxt) then
            if (RequestTimeoutMilliseconds > 0) and (RequestTimeoutMilliseconds < MinRequestTimeout) then
              RequestTimeoutMilliseconds := MinRequestTimeout;
        if RequestTimeoutMilliseconds = 0 then begin
          SendTraceTag('0000834',NpsCategoryTxt,VERBOSITY::Warning,
            StrSubstNo(ParameterNotFoundMsg,NpsRequestTimeoutTxt),DATACLASSIFICATION::SystemMetadata);
          RequestTimeoutMilliseconds := DefaultRequestTimeout;
        end;

        if JSONManagement.GetStringPropertyValueFromJObjectByName(JsonObject,NpsCacheLifeTimeTxt,CacheLifeTimeValueTxt) then
          if Evaluate(CacheLifeTimeMinutes,CacheLifeTimeValueTxt) then
            if CacheLifeTimeMinutes < MinCacheLifeTime then
              CacheLifeTimeMinutes := MinCacheLifeTime;
        if CacheLifeTimeMinutes = 0 then begin
          SendTraceTag('0000835',NpsCategoryTxt,VERBOSITY::Warning,
            StrSubstNo(ParameterNotFoundMsg,NpsCacheLifeTimeTxt),DATACLASSIFICATION::SystemMetadata);
          CacheLifeTimeMinutes := DefaultCacheLifeTime;
        end;

        exit(true);
    end;

    local procedure MinCacheLifeTime(): Integer
    begin
        exit(1); // one minute
    end;

    local procedure DefaultCacheLifeTime(): Integer
    begin
        exit(1440); // 24 hours
    end;

    local procedure MinRequestTimeout(): Integer
    begin
        exit(250); // 250 milliseconds
    end;

    local procedure DefaultRequestTimeout(): Integer
    begin
        exit(5000); // 5 seconds
    end;

    local procedure MillisecondsInMinute(): Integer
    begin
        exit(60000);
    end;
}

