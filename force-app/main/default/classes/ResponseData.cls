public class ResponseData {
    @AuraEnabled
    public Boolean isSuccess {get;set;}
    @AuraEnabled
    public String message {get;set;}
    @AuraEnabled
    public List<MetaDataComponent> metaData{get;set;}
    @AuraEnabled
    public List<MetadataComponentDependency> metaDataComponetDep{get;set;}
}