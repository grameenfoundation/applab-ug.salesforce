@RestResource(urlMapping='/ewarehouse/farmer/*')
global with sharing class EwarehouseFarmerRestService  extends EwarehouseServiceBase {
 	
 	private static ServiceLogger logger = new ServiceLogger();
 	
 	@HttpGet
    global static EwarehouseServiceBase.ServiceResultResponse getFarmer() {
        
        Map<String, String> params = null;
        
        // get the id from the request parameter
        String id = RestContext.request.params.get('Id');
        
        if(id == null){
        	string message = 'ERROR: request param [Id] should not be null. We could not find a valid required parameter [Id]';
            logger.error(message);
            return new ErrorResponse(message);
        }
        
        logger.debug('id = ' + id);
        
        List<Ewarehouse_Farmer__c> lstFarmer;
        try {
            lstFarmer = EwarehouseServiceBase.dataSource.getFarmer(id);
        }
        catch(Exception e){
            logger.error('ERROR: ' + e);
            return new ExceptionResponse(e);
        }                                                               
        
        if (lstFarmer.size() > 0)
        {
            Ewarehouse_Farmer__c clObj = lstFarmer.get(0);
            EwarehouseFarmer result = EwarehouseFarmer.fromSfObject(clObj);
            if(result == null)
            	return new ErrorResponse('Farmer with Id ['+id+'], does not have a valid person object.');
            
            return new EwarehouseFarmerRestService.FarmerResponse(result);
        }
        else{
            logger.debug('no Farmer found with Id:' + id);
            return new ErrorResponse('We could not find a farmer with the gived Id: ['+id+']');
        }
    }

    
    @HttpPost
    global static EwarehouseServiceBase.ServiceResultResponse updateFarmer(){ //String id, String status
        
        // take the client from the parameters
        String jsonString = RestContext.request.requestBody.toString(); 
        logger.debug('json: ' + jsonString);
        
        // parse the client data
        Map<String, String> parameters = (Map<String, String>) JSON.deserialize(jsonString, Map<String, String>.class);
        logger.debug(parameters);
        
        // get id parameter
        String id = EwarehouseServiceBase.getParameter(parameters, 'Id');
        if(id == null){
            logger.error('ERROR: request param [Id] should not be null');
            return new ErrorResponse('We could find required parameter [Id]');
        }
        
        String status = EwarehouseServiceBase.getParameter(parameters, 'Status');
        if(status == null){
            logger.error('ERROR: request param [Status] should not be null');
            return new ErrorResponse('We could find required parameter [Status]');
        }
        
        // get the appropriate client
        List<Ewarehouse_Farmer__c> lstFarmer = null;
        
        try {
            lstFarmer = EwarehouseServiceBase.dataSource.getFarmer(id);
        }
        catch(Exception e){
            logger.error('EXCEPTION: ' + e);
            return new ExceptionResponse(e);
        }
        
        // check if the client exists
        if (lstFarmer.size() == 0) {
            // no client found to update
            return new ErrorResponse('We could find a farmer with the gived id: ['+ id +']');
        }
        
        // seems there is a farmer with this Id to update
        Ewarehouse_Farmer__c farmerObj = lstFarmer.get(0);
        farmerObj.Status__c = status;
        
        // save the update
        Database.SaveResult results;
        try {
            results = EwarehouseServiceBase.dataSource.updateFarmer(farmerObj);
        }
        catch(Exception e){
            logger.error('ERROR: ' + e);
            return new ExceptionResponse(e);
        }
        
        logger.debug(results);
        
        // check if the update was succesful otherwise return the errors -- TODO check how I can get a DML Error in the update for testing
        if(results.isSuccess()){
            return new SuccessResponse('Updated: farmer id ['+id+'], status: ['+status+']');
        }
        else{
            logger.error('ERROR: ' + results.getErrors());
            return new DmlErrorResponse('We could update farmer with the gived id: ['+ id +']', results.getErrors());
        }
    }
    
    global class FarmerResponse extends ServiceResultResponse {
        public FarmerResponse(EwarehouseFarmer farmer){
            this.code = '200';
            this.description = 'OK';
            this.farmer = farmer;
        }
        
        public EwarehouseFarmer farmer;
    }
}