/**
 * This class contains unit tests for validating the behavior of Ewrehouse Farmer REST API
 */
@isTest
public with sharing class EwarehouseFarmerRestServiceTest {
	// TODO create test for no farmer found and no parameter given, check other things that might happen

    private static String testRequestURI = '/services/apexrest/ewarehouse/farmer';
    private static ServiceLogger logger = new ServiceLogger();
	
    static testMethod void getFarmer() {
    	
        Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
        
        // get the newly inserted farmer id (name field)
        String id = ids.get('farmer1Name');
        
        logger.debug('Farmer Id=' + id);
        
        // ready to start the test
        test.startTest();
        
        // create request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'GET';
        // set as parameter the just stored id
        req.addParameter('Id', id);
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseFarmerRestService.FarmerResponse result = (EwarehouseFarmerRestService.FarmerResponse) EwarehouseFarmerRestService.getFarmer();
        
        test.stopTest();
        
        // assert what was stored
        
        System.assertEquals('200',result.code);
        System.assertEquals('OK',result.description);
        System.assertEquals('Jane',result.farmer.FirstName);
        System.assertEquals('The Actrice',result.farmer.MiddleName);
        System.assertEquals('Fonda',result.farmer.LastName);
        System.assertEquals('+254123456789',result.farmer.MobilePhone);
        System.assertEquals('Kisumu',result.farmer.Village);
        System.assertEquals('TIGANIA WEST',result.farmer.District);
        System.assertEquals('a3Bn0000000Cf6G',result.farmer.Id);
        System.assertEquals('Processed',result.farmer.Status);
        
        System.assertEquals(datetime.newinstance(2013, 4, 30, 12, 34, 54), result.farmer.RegisterDate);
        System.assertEquals('KARATHIA WOMEN GROUP',result.farmer.GroupName);
        
        logger.debug('Test finished');
    }
    
    
     static testMethod void getFarmerDMLException() {
        
        // set the datasource to mock
        EwarehouseServiceBase.setDataSource(new EwarehouseDataSourceMock.AllExceptionMock());
        
        // ready to start the test
        test.startTest();
        
        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'GET';
        
        // set as parameter the just stored id
        req.addParameter('Id', 'dummy');
        RestContext.request = req;
        RestContext.response = res;
        
        // get an error response instead of client response
        EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) EwarehouseFarmerRestService.getFarmer();
        
        test.stopTest();
    
        // assert error returned
        System.assertEquals('500',result.code);
        //System.assertEquals('EXCEPTION: System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Contact__c]: [Contact__c]',result.description);
        
        System.debug('Test finished');
        // reset the datasource
        EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
     }
    
    static testMethod void getFarmerNoIdParam() {
        // ready to start the test
        test.startTest();
        
        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'GET';
        // set as parameter the just stored id
        req.addParameter('bla-param', 'NOTEXISTING');
        RestContext.request = req;
        RestContext.response = res;
        
        // get an error response instead of client response
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) EwarehouseFarmerRestService.getFarmer();
        
        test.stopTest();
    
        // assert error returned
        System.assertEquals('400',result.code);
        System.assertEquals('ERROR: request param [Id] should not be null. We could not find a valid required parameter [Id]', result.description);
        
        logger.debug('Test finished');
    }
    
    static testMethod void getFarmerNotExist() {

        // ready to start the test
        test.startTest();
        
        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'GET';
        // set as parameter the just stored id
        req.addParameter('Id', 'NOTEXISTING');
        RestContext.request = req;
        RestContext.response = res;
        
        // get an error response instead of client response
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) EwarehouseFarmerRestService.getFarmer();
        
        test.stopTest();
        

        // assert error returned
        System.assertEquals('400',result.code);
        System.assertEquals('We could not find a farmer with the gived Id: [NOTEXISTING]',result.description);
        
        logger.debug('Test finished');
        
    }
    
    static testMethod void updateFarmer() {
         Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
        // get the newly inserted farmer id (name field)
        String id = ids.get('farmer1Name');
        
        logger.debug('farmer id=' + id);
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Id":"'+id+'","Status":"Processed"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.SuccessResponse result = (EwarehouseServiceBase.SuccessResponse) EwarehouseFarmerRestService.updateFarmer();
        
        test.stopTest();
        
        // assert what was stored
        System.assertEquals('200', result.code);
        System.assertEquals('Updated: farmer id ['+id+'], status: [Processed]', result.description);
        
        List<Ewarehouse_Farmer__c> lstFarmer = [SELECT 
                                        ID, 
                                        Name, 
                                        Status__c
                                    FROM Ewarehouse_Farmer__c WHERE Name = :id];
        
        System.assertEquals(1, lstFarmer.size());
        
        Ewarehouse_Farmer__c clObj = lstFarmer.get(0);
        
        System.assertEquals('Processed', clObj.Status__c);
       
        logger.debug('Test finished');
        
    }
    
    static testMethod void updateFarmerNotExists() {
        
        Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
        
        // get the newly inserted farmer id (name field), but create an error
        String id = ids.get('farmer1Name') + 'oeps'; 
        
        logger.debug('farmer id=' + id);
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Id":"'+id+'","Status":"Processed"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) EwarehouseFarmerRestService.updateFarmer();
        
        test.stopTest();
        
        // assert error returned
        System.assertEquals('400',result.code);
       
        logger.debug('Test finished');
        
    }
    
    static testMethod void updateFarmerDMLException() {
        // set the datasource to mock
        EwarehouseServiceBase.setDataSource(new EwarehouseDataSourceMock.UpdateFarmerLoanExceptionMock());
        
         Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
        // get the newly inserted farmer id (name field)
        String id = ids.get('farmer1Name');
        
        logger.debug('farmer id=' + id);
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Id":"'+id+'","Status":"Processed"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) EwarehouseFarmerRestService.updateFarmer();
        
        test.stopTest();
        
        // assert error returned
        System.assertEquals('500',result.code);
        
        EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
        
        logger.debug('Test finished');
        
    }
    
    static testMethod void updateFarmerGetException() {
        // set the datasource to mock
        EwarehouseServiceBase.setDataSource(new EwarehouseDataSourceMock.AllExceptionMock());
        
        // start the test
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Id":"dummy","Status":"Processed"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // get an error response instead of client response
        EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) EwarehouseFarmerRestService.updateFarmer();
        
        test.stopTest();
    
        // assert error returned
        System.assertEquals('500',result.code);
        
        logger.debug('Test finished');
        
        // reset the datasource
        EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
        
    }
    
    static testMethod void updateFarmerNoIdParam() {
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Status":"Processed"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) EwarehouseFarmerRestService.updateFarmer();
        
        test.stopTest();
        
        // assert what was stored
        System.assertEquals('400',result.code);
        System.assertEquals('We could find required parameter [Id]', result.description);
        
       
        logger.debug('Test finished');
        
    }
    
    static testMethod void updateFarmerNoStatusParam() {
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Id":"whatever"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) EwarehouseFarmerRestService.updateFarmer();
        
        test.stopTest();
        
        // assert what was stored
        System.assertEquals('400',result.code);
        System.assertEquals('We could find required parameter [Status]', result.description);
        
       
        logger.debug('Test finished');
        
    }  
    
}