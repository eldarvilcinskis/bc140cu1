codeunit 8626 "Config. Import Table in Backgr"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        ConfigXMLExchange: Codeunit "Config. XML Exchange";
        MemoryMappedFile: Codeunit "Memory Mapped File";
        PackageXML: DotNet XmlDocument;
        DocumentElement: DotNet XmlElement;
        TableNode: DotNet XmlNode;
        nodetext: Text;
        PackageCode: Code[20];
    begin
        PackageCode := CopyStr("Parameter String", 1, MaxStrLen(PackageCode));
        if PackageCode = '' then
            exit;

        if not MemoryMappedFile.OpenMemoryMappedFile(Format(ID)) then
            exit;
        MemoryMappedFile.ReadTextFromMemoryMappedFile(nodetext);
        MemoryMappedFile.Dispose;

        PackageXML := PackageXML.XmlDocument;
        PackageXML.LoadXml(nodetext);
        if IsNull(PackageXML) then
            exit;
        DocumentElement := PackageXML.DocumentElement;
        if IsNull(DocumentElement) then
            exit;
        TableNode := DocumentElement.FirstChild;
        if IsNull(TableNode) then
            exit;
        ConfigXMLExchange.SetHideDialog(true);
        ConfigXMLExchange.ImportTableFromXMLNode(TableNode, PackageCode);
    end;
}

