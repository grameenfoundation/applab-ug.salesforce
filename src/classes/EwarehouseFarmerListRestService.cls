@RestResource(urlMapping='/ewarehouse/farmerlist/*')
global with sharing class EwarehouseFarmerListRestService  extends EwarehouseServiceBase {
 	
 	private static ServiceLogger logger = new ServiceLogger();

	/*
        FarmerList GET - retrieve a list of clients with a given Status
    */
    @HttpGet
    global static EwarehouseServiceBase.ServiceResultResponse getFarmers() {
        
        // define all the allowed statuses
        Set<String> allowedStatus = new Set<String>{'New', 'Processed', 'Failed', 'Duplicate'};
        
        // get the id from the request parameter
        String status = RestContext.request.params.get('Status');
        
        // check if Status param is null
        if(status == null){
        	string message = 'ERROR: request param [Status] should not be null. We could find required parameter [Status]';
            logger.error(message);
            return new ErrorResponse(message);
        }
        
        // Check if the Status value is in allowed range of statuses
        if(!allowedStatus.contains(status)){
        	string message = 'ERROR: request param [Status] can only be: New, Processed, Failed, Duplicate';
            logger.debug(message);
            return new ErrorResponse(message);
        }
        
        logger.debug('Status = ' + status);
        
        // get all the farmers with the requested status
        List<EwarehouseFarmer> farmerList = new List<EwarehouseFarmer>();
        List<Ewarehouse_Farmer__c> sfObjectList;
        try {
            sfObjectList = EwarehouseServiceBase.dataSource.getFarmersByStatus(status);
        }
        catch(Exception e){
            logger.error('ERROR: ' + e);
            return new ExceptionResponse(e);
        }
                
        // iterate through sfObjects and convert to EwarehouseFarmer                                                       
        for(Ewarehouse_Farmer__c ef: sfObjectList){
        	EwarehouseFarmer result = EwarehouseFarmer.fromSfObject(ef);
        	if(result != null)
            	farmerList.add(result);
        }
        
        // return the farmers
        return new EwarehouseFarmerListRestService.FarmerListResponse(farmerList);
    }
    
    
    @HttpPost
    global static EwarehouseServiceBase.ServiceResultResponse updateFarmers(){ //String id, String status
        
        // take the JSON from the body
    	String jsonString = RestContext.request.requestBody.toString(); 
        logger.debug('json: ' + jsonString);
        
        // parse the client update data
        List<Map<String, String>> parameters = (List<Map<String, String>>) JSON.deserialize(jsonString, List<Map<String, String>>.class);
        logger.debug(parameters);
        
        // Store all the Ids in a Set and the objects in its own update map to be able to find the Status by Id
        Set<String> ids = new Set<String>();
        Map<String, String> updateMap = new Map<String, String>();
        for(Map<String, String> item : parameters){
            // first check if the required parameters are available
            if(!item.containsKey('Id'))
                return new ErrorResponse('JSON ERROR: We could find required parameter [Id] in one of the objects');
            if(!item.containsKey('Status'))
                return new ErrorResponse('JSON ERROR: We could find required parameter [Status] in one of the objects');
                
            // build id not found exception
            ids.add(item.get('Id'));
            updateMap.put(item.get('Id'), item.get('Status'));
        }
        logger.debug(ids);
        
        // put the whole loop for updating records in a try-catch, any exception thrown will be returned to the user
        try {
            // build a query with all the Ids and update item per item
            for(Ewarehouse_Farmer__c f: (Ewarehouse_Farmer__c[]) EwarehouseServiceBase.dataSource.getFarmers(ids)){
                // check if the Id can be found in the update map, using the Farmer.Name field
                if(!updateMap.containsKey(f.Name))
                    return new ErrorResponse('Trying to update ['+f.Name+'], while the Status is not stored in the Map.');
                    
                // update the farmer, set the status to the one given
                f.Status__c = updateMap.get(f.Name);
                EwarehouseServiceBase.dataSource.updateFarmer(f);
                
                // remove the farmer from the update map, the map while then be left with farmers not found in the query 
                updateMap.remove(f.Name);
            }   
        }
        catch(Exception e){
            logger.error('EXCEPTION: ' + e);
            return new ExceptionResponse(e);
        }
        
        if(updateMap.isEmpty()){
            return new SuccessResponse('Update success');
        }
        else {
            logger.debug(updateMap);
            return new ErrorMapResponse('Not all IDs where found as client, attached Ids not updated.', updateMap);
        }
    }
    
    global class FarmerListResponse extends ServiceResultResponse {
        public FarmerListResponse(EwarehouseFarmer[] farmerList){
            this.code = '200';
            this.description = 'OK';
            this.farmerList = farmerList;
        }
        
        public EwarehouseFarmer[] farmerList;
    }
    
}