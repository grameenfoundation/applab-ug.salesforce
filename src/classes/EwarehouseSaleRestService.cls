@RestResource(urlMapping='/ewarehouse/salelist/*')
global class EwarehouseSaleRestService extends EwarehouseServiceBase {

    private static ServiceLogger logger = new ServiceLogger();

    @HttpGet
    global static EwarehouseServiceBase.ServiceResultResponse getSales() {
        
        // get the id from the request parameter
        String status = RestContext.request.params.get('Status');
        logger.debug('Status: ' + status);
        // if status is not given, set to default status 'New'
        if(status == null){
            status = 'New';
            logger.debug('No Status found, set default: ' + status);
        }
        // create a list of Sale objects for JSOn
        List<EwarehouseSale> sales = new List<EwarehouseSale>();
        
        // retrieve all new Sales
        Sale_Farmer_Associations__c[] newSales;
        
        // we put the whole block inside a try-catch because there are a lot of places where an exception might occur
        try {
        
            newSales = EwarehouseServiceBase.dataSource.getSales(status);
            logger.debug('Sales retrieved: ' + newSales);
            // iterate through the new sale__c objects and convert to Sale
            for(Sale_Farmer_Associations__c sObj : newSales){
                // convert using static converter
                EwarehouseSale sale = EwarehouseSale.fromSfObject(sObj);
                
                // add the sale to the list of sales
                sales.add(sale);
            }
        }
        catch(Exception e){
            logger.error('ERROR: ' + e);
            return new ExceptionResponse(e);
        }
        
        logger.debug('Sales converted: ' + sales);
        
        // return the objects
        return new SalesResponse(sales);
    }
    
    
    @HttpPost
    global static EwarehouseServiceBase.ServiceResultResponse updateSales() {
        
        // take the JSON from the body
        String jsonString = RestContext.request.requestBody.toString(); 
        logger.debug('json: ' + jsonString);
        
        // parse the sales update data
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
            for(Sale_Record__c s: EwarehouseServiceBase.dataSource.getSales(ids)){
                // check if the Id can be found in the update map, using the Sale.Name field
                if(!updateMap.containsKey(s.Name))
                    return new ErrorResponse('Trying to update ['+s.Name+'], while the Status is not stored in the Map.');
                    
                // update the sale, set the status to the one given
                s.Status__c = updateMap.get(s.Name);
                EwarehouseServiceBase.dataSource.updateSale(s);
                
                // remove the sale from the update map, the map will then be left with sales not found in the query 
                updateMap.remove(s.Name);
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
            logger.debug('Not all IDs where found as sales, attached Ids not updated: ' + updateMap);
            return new ErrorMapResponse('Not all IDs where found as sales, attached Ids not updated.', updateMap);
        }
    }
    
    global class SalesResponse extends ServiceResultResponse {
        public SalesResponse(EwarehouseSale[] saleList){
            this.code = '200';
            this.description = 'OK';
            this.saleList = saleList;
        }
        
        public EwarehouseSale[] saleList;
    }
}