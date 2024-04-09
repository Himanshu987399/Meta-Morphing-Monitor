public class IntegrationUtils {
    public static String getSessionIdFrmVFPg(PageReference vfPageContainSessionId){
        String data = vfPageContainSessionId.getContent().toString();
        return data.substring(data.indexOf('Session_Id_Start_Here') + 'Session_Id_Start_Here'.length(), data.indexOf('Session_Id_End_Here'));
    }
    public static ResponseData generateToolingData(String metaData,String endPointUrl,String accessToken,String method){
        ResponseData resp = new ResponseData();
        try{
            HttpRequest request = new HttpRequest();
            if(String.isNotBlank(accessToken)){
                request.setHeader('Authorization', 'Bearer ' + accessToken);
            }
            request.setHeader('Content-Type', 'application/json');
            request.setEndpoint(endPointUrl);
            request.setMethod(method);
            if(String.isNotBlank(metadata)){
                request.setBody(metadata);
            }
            Http http = new Http();
            HTTPResponse res = http.send(request);
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 204){
                resp.isSuccess = true;
                resp.message = res.getBody();
            }else{
                resp.isSuccess = false;
                resp.message = res.getBody();
            }
        }catch(Exception ex){
            resp.isSuccess = false;
            resp.message = ex.getMessage();
        }
        return resp;
    }   
    public static ResponseData getMetaDataDependency(){
        ResponseData resp = new ResponseData();
        try{
            Set<String> remoteSiteUrl = new Set<String>();
            String endPointUrl = System.URL.getOrgDomainURL().toExternalForm()+'/services/data/v58.0/tooling/query/?q=SELECT+MetadataComponentName,MetadataComponentType,RefMetadataComponentName,RefMetadataComponentType,MetadataComponentId,RefMetadataComponentId+FROM+MetadataComponentDependency';
            String metadata = '';
            ResponseData resRemoteSite = generateToolingData(metadata,endPointUrl,getSessionIdFrmVFPg(Page.sessionIdVfPage),'GET');
            if(resRemoteSite.isSuccess){
                List<MetadataComponentDependency> metaDataCompList = new List<MetadataComponentDependency>();
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(resRemoteSite.message);
                List<Object> records = (List<Object>) jsonResponse.get('records');
                for (Object record : records) {
                    Map<String, Object> recordMap = (Map<String, Object>) record;
                    MetadataComponentDependency metaDataInstance = new MetadataComponentDependency();
                    metaDataInstance.MetadataComponentName = (String) recordMap.get('MetadataComponentName');
                    metaDataInstance.MetadataComponentId = (String) recordMap.get('MetadataComponentId');
                    metaDataInstance.MetadataComponentType = (String) recordMap.get('MetadataComponentType');
                    metaDataInstance.RefMetadataComponentId = (String) recordMap.get('RefMetadataComponentId');
                    metaDataInstance.RefMetadataComponentName = (String) recordMap.get('RefMetadataComponentName');
                    metaDataInstance.RefMetadataComponentType = (String) recordMap.get('RefMetadataComponentType');
                    metaDataCompList.add(metaDataInstance);
                }
                resp.isSuccess = true;
                resp.message = '';
                resp.metaDataComponetDep = metaDataCompList;
            }else{
                resp.isSuccess = false;
                resp.message = resRemoteSite.message;
            }
            
        }catch(Exception ex){
            resp.isSuccess = false;
            resp.message = ex.getMessage();
        }
        return resp;
    }
    
    public static ResponseData getDataOfQuery(String Query){
        ResponseData resp = new ResponseData();
        try{
            Set<String> remoteSiteUrl = new Set<String>();
            String endPointUrl = System.URL.getOrgDomainURL().toExternalForm()+'/services/data/v58.0/tooling/query/?q='+Query;
            endPointUrl = endPointUrl.replaceAll('\"', '');
            String metadata = '';
            resp = generateToolingData(metadata,endPointUrl,getSessionIdFrmVFPg(Page.sessionIdVfPage),'GET');
            return resp;
        }catch(Exception ex){
            resp.isSuccess = false;
            resp.message = ex.getMessage();
            return resp;
        }
    }
    
   
}