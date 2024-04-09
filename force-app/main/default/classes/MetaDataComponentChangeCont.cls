public class MetaDataComponentChangeCont {
    @AuraEnabled
    public static ResponseData getSubmitData(){
        ResponseData resp = new ResponseData();
        try{
            ResponseData response = IntegrationUtils.getMetaDataDependency();
            if(response.isSuccess){
                List<MetadataComponentDependency> metaDataChange = response.metaDataComponetDep;
                List<MetaDataComponent> metaDataCompList = new List<MetaDataComponent>();
                Map<String,List<Object>> compTypeVsListOfObject = new Map<String,List<Object>>();
                Map<String,String> IdVsNameComp = new Map<String,String>();
                Map<String,String> IdVsNameRefComp = new Map<String,String>();
                Map<String,Set<Id>> metaCmpNameVsMetaCmpId = new Map<String,Set<Id>>();
                Map<String,Set<Id>> metaRefCmpNameVsMetaCmpId = new Map<String,Set<Id>>();
                if(!metaDataChange.isEmpty()){
                    for(MetadataComponentDependency metaDataComp : metaDataChange){
                        IdVsNameComp.put(metaDataComp.MetadataComponentId,metaDataComp.MetadataComponentName);
                        IdVsNameRefComp.put(metaDataComp.RefMetadataComponentId,metaDataComp.RefMetadataComponentName);
                        if(metaRefCmpNameVsMetaCmpId.containsKey(metaDataComp.RefMetadataComponentType)){
                            try{
                                metaRefCmpNameVsMetaCmpId.get(metaDataComp.RefMetadataComponentType).add(metaDataComp.RefMetadataComponentId);
                            }catch(exception ex){
                                
                            }
                        }else{
                            try{	
                                Set<Id> ids = new Set<Id>();
                                ids.add(metaDataComp.MetadataComponentId);
                                metaRefCmpNameVsMetaCmpId.put(metaDataComp.RefMetadataComponentType,ids);
                            }catch(Exception ex){
                                
                            }
                            
                        }
                        if(metaCmpNameVsMetaCmpId.containsKey(metaDataComp.MetadataComponentType)){
                            try{
                                metaCmpNameVsMetaCmpId.get(metaDataComp.MetadataComponentType).add(metaDataComp.MetadataComponentId);
                            }catch(exception ex){
                                
                            }
                        }else{
                            try{	
                                Set<Id> ids = new Set<Id>();
                                ids.add(metaDataComp.MetadataComponentId);
                                metaCmpNameVsMetaCmpId.put(metaDataComp.MetadataComponentType,ids);
                            }catch(Exception ex){
                                
                            }
                        }
                    }
                    for(String compType : metaCmpNameVsMetaCmpId.keySet()){
                        Date today = System.today();
                        List<String> quotedIds = new List<String>();
                        for (Id id : metaCmpNameVsMetaCmpId.get(compType)) {
                            quotedIds.add('\'' + id + '\'');
                        }
                        String ids = '(' + String.join(quotedIds, ',') + ')';
                        String QUERY = 'select+id,LastModifiedDate+from+'+compType+'+Where+Id+IN+'+ids;
                        ResponseData respValue = IntegrationUtils.getDataOfQuery(QUERY);
                        if(respValue.isSuccess){
                            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(respValue.message);
                            List<Object> records = (List<Object>) jsonResponse.get('records');
                            compTypeVsListOfObject.put(compType,records);
                            for (Object record : records) {
                                Map<String, Object> recordMap = (Map<String, Object>) record;
                                MetaDataComponent metaInstance = new MetaDataComponent();
                                metaInstance.compType = compType;
                                String modifiedDate = (String)recordMap.get('LastModifiedDate');
                                metaInstance.compName = IdVsNameComp.get((String)recordMap.get('Id'));
                                metaInstance.lastModifiedDate = modifiedDate.subStringBefore('T');
                                metaDataCompList.add(metaInstance);
                            }
                        }
                    }    
                    for(String compType : metaRefCmpNameVsMetaCmpId.keySet()){
                        Date today = System.today();
                        List<String> quotedIds = new List<String>();
                        for (Id id : metaRefCmpNameVsMetaCmpId.get(compType)) {
                            quotedIds.add('\'' + id + '\'');
                        }
                        String ids = '(' + String.join(quotedIds, ',') + ')';
                        String QUERY = 'select+id,LastModifiedDate+from+'+compType+'+Where+Id+IN+'+ids;
                        ResponseData respValue = IntegrationUtils.getDataOfQuery(QUERY);
                        system.debug('respValue---'+respValue);
                        if(respValue.isSuccess){
                            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(respValue.message);
                            List<Object> records = (List<Object>) jsonResponse.get('records');
                            compTypeVsListOfObject.put(compType,records);
                            for (Object record : records) {
                                Map<String, Object> recordMap = (Map<String, Object>) record;
                                MetaDataComponent metaInstance = new MetaDataComponent();
                                metaInstance.compType = compType;
                                String modifiedDate = (String)recordMap.get('LastModifiedDate');
                                metaInstance.compName = IdVsNameRefComp.get((String)recordMap.get('Id'));
                                metaInstance.lastModifiedDate = modifiedDate.subStringBefore('T');
                                metaDataCompList.add(metaInstance);
                            }
                        }
                    }  
                    resp.isSuccess = true;
                    resp.metaData= metaDataCompList;
                }
            }
        }catch(Exception ex){
            resp.isSuccess = false;
            resp.message= ex.getMessage();
        }
        return resp;
    }
   
}