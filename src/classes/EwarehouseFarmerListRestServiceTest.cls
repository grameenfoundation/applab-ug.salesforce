/**
 * This class contains unit tests for validating the behavior of Ewarehouse Farmer List REST API
 */
@isTest
public with sharing class EwarehouseFarmerListRestServiceTest {
	// TODO create test for no farmer found and no parameter given, check other things that might happen

    private static String testRequestURI = '/services/apexrest/ewarehouse/farmerlist'; 
    private static ServiceLogger logger = new ServiceLogger();

    static testMethod void getFarmerList() {
        // insert test data
        EwarehouseDataSourceMock.insertTestData();
        
        // ready to start the test
        test.startTest();
        
        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'GET';
        // set as parameter the just stored id
        req.addParameter('Status', 'Processed');
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results (normally converted to JSON via API)
        EwarehouseFarmerListRestService.FarmerListResponse result = (EwarehouseFarmerListRestService.FarmerListResponse) EwarehouseFarmerListRestService.getFarmers();
        
        test.stopTest();
        
        // assert what was stored
        System.assertEquals('200',result.code);
        System.assertEquals('OK',result.description);
        System.assertEquals('Jane',result.farmerList[0].FirstName);
        System.assertEquals('The Actrice',result.farmerList[0].MiddleName);
        System.assertEquals('Fonda',result.farmerList[0].LastName);
        System.assertEquals('+254123456789',result.farmerList[0].MobilePhone);
        System.assertEquals('Kisumu',result.farmerList[0].Village);
        System.assertEquals('TIGANIA WEST',result.farmerList[0].District);
        System.assertEquals('a3Bn0000000Cf6G',result.farmerList[0].Id);
        System.assertEquals('Processed',result.farmerList[0].Status);
        System.assertEquals(datetime.newinstance(2013, 4, 30, 12, 34, 54), result.farmerList[0].RegisterDate);
        System.assertEquals('KARATHIA WOMEN GROUP',result.farmerList[0].GroupName);
        
       	System.assertEquals('John',result.farmerList[1].FirstName);
        System.assertEquals('The Actrice',result.farmerList[1].MiddleName);
        System.assertEquals('Lennon',result.farmerList[1].LastName);
        System.assertEquals('+254123456789',result.farmerList[1].MobilePhone);
        System.assertEquals('Kisumu',result.farmerList[1].Village);
        System.assertEquals('TIGANIA WEST',result.farmerList[1].District);
        System.assertEquals('a3Bn0000000CfPI',result.farmerList[1].Id);
        System.assertEquals('Processed',result.farmerList[1].Status);
        System.assertEquals(datetime.newinstance(2013, 4, 30, 12, 34, 54), result.farmerList[1].RegisterDate);
        System.assertEquals('KARATHIA WOMEN GROUP',result.farmerList[1].GroupName);
        
        logger.debug('Test finished');
    }
    
    static testMethod void getNewFarmers() {
        
        // insert test data
        Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
        
        Ewarehouse_Farmer__c farmer = [SELECT Status__c FROM Ewarehouse_Farmer__c WHERE Id = :ids.get('farmer2Id')];
        farmer.Status__c = 'New';
        update farmer;
        
        // ready to start the test
        test.startTest();
        
        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'GET';
        // set as parameter the just stored id
        req.addParameter('Status', 'New');
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results (normally converted to JSON via API)
        EwarehouseFarmerListRestService.FarmerListResponse result = (EwarehouseFarmerListRestService.FarmerListResponse) EwarehouseFarmerListRestService.getFarmers();
        
        test.stopTest();
        
        System.assertEquals(1, result.farmerList.size());
        
        System.assertEquals('200',result.code);
        System.assertEquals('OK',result.description);
        System.assertEquals('John',result.farmerList[0].FirstName);
        System.assertEquals('The Actrice',result.farmerList[0].MiddleName);
        System.assertEquals('Lennon',result.farmerList[0].LastName);
        System.assertEquals('+254123456789',result.farmerList[0].MobilePhone);
        System.assertEquals('Kisumu',result.farmerList[0].Village);
        System.assertEquals('TIGANIA WEST',result.farmerList[0].District);
        System.assertEquals('a3Bn0000000CfPI',result.farmerList[0].Id);
        System.assertEquals('New',result.farmerList[0].Status);
        System.assertEquals(datetime.newinstance(2013, 4, 30, 12, 34, 54), result.farmerList[0].RegisterDate);
        System.assertEquals('KARATHIA WOMEN GROUP',result.farmerList[0].GroupName);
        
        logger.debug('Test finished');
    }
    
    static testMethod void getFarmersWithoutStatus() {
        
        // insert test data
        Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
        
        Ewarehouse_Farmer__c farmer = [SELECT Status__c FROM Ewarehouse_Farmer__c WHERE Id = :ids.get('farmer2Id')];
        farmer.Status__c = null;
        update farmer;
        
        // ready to start the test
        test.startTest();
        
        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'GET';
        // set as parameter the just stored id
        req.addParameter('Status', 'New');
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results (normally converted to JSON via API)
        EwarehouseFarmerListRestService.FarmerListResponse result = (EwarehouseFarmerListRestService.FarmerListResponse) EwarehouseFarmerListRestService.getFarmers();
        
        test.stopTest();
        
        System.assertEquals(1, result.farmerList.size());
        
        System.assertEquals('200',result.code);
        System.assertEquals('OK',result.description);
        System.assertEquals('John',result.farmerList[0].FirstName);
        System.assertEquals('The Actrice',result.farmerList[0].MiddleName);
        System.assertEquals('Lennon',result.farmerList[0].LastName);
        System.assertEquals('+254123456789',result.farmerList[0].MobilePhone);
        System.assertEquals('Kisumu',result.farmerList[0].Village);
        System.assertEquals('TIGANIA WEST',result.farmerList[0].District);
        System.assertEquals('a3Bn0000000CfPI',result.farmerList[0].Id);
        System.assertEquals(null,result.farmerList[0].Status);
        System.assertEquals(datetime.newinstance(2013, 4, 30, 12, 34, 54), result.farmerList[0].RegisterDate);
        System.assertEquals('KARATHIA WOMEN GROUP',result.farmerList[0].GroupName);
        
        logger.debug('Test finished');
    }
    
    static testMethod void getFarmersDMLException() {
        
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
        req.addParameter('Status', 'dummy');
        RestContext.request = req;
        RestContext.response = res;
        
        // get an error response instead of response
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) EwarehouseFarmerListRestService.getFarmers();
        
        test.stopTest();
    
        // assert error returned
        System.assertEquals('400',result.code);
        System.assertEquals('ERROR: request param [Status] can only be: New, Processed, Failed, Duplicate',result.description);
        
        logger.debug('Test finished');
        // reset the datasource
        EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
    }
    
    static testMethod void getFarmersNoStatusParam() {
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
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) EwarehouseFarmerListRestService.getFarmers();
        
        test.stopTest();
    
        // assert error returned
        System.assertEquals('400',result.code);
        System.assertEquals('ERROR: request param [Status] should not be null. We could find required parameter [Status]', result.description);
        
        logger.debug('Test finished');
    }
    
    static testMethod void getNoFarmersReturned() {

        // insert test data
        EwarehouseDataSourceMock.insertTestData();
        
        // ready to start the test
        test.startTest();
        
        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'GET';
        // set as parameter the just stored id
        req.addParameter('Status', 'Duplicate');
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseFarmerListRestService.FarmerListResponse result = (EwarehouseFarmerListRestService.FarmerListResponse) EwarehouseFarmerListRestService.getFarmers();
        
        test.stopTest();
        
        // assert what was stored
        
        System.assertEquals('200',result.code);
        System.assertEquals('OK',result.description);
        System.assertEquals(0,result.farmerList.size());
        logger.debug('Test finished');
        
    }
    
     static testMethod void getOneFarmersReturned() {

        // insert test data
        Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
        
        Ewarehouse_Farmer__c farmer = [SELECT Status__c FROM Ewarehouse_Farmer__c WHERE Id = :ids.get('farmer2Id')];
        farmer.Status__c = 'Duplicate';
        update farmer;
        
        // ready to start the test
        test.startTest();
        
        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'GET';
        // set as parameter the just stored id
        req.addParameter('Status', 'Duplicate');
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseFarmerListRestService.FarmerListResponse result = (EwarehouseFarmerListRestService.FarmerListResponse) EwarehouseFarmerListRestService.getFarmers();
        
        test.stopTest();
        
        // assert what was stored
        
        System.assertEquals('200',result.code);
        System.assertEquals('OK',result.description);
        System.assertEquals(1,result.farmerList.size());
        System.assertEquals('John',result.farmerList[0].FirstName);
        System.assertEquals('The Actrice',result.farmerList[0].MiddleName);
        System.assertEquals('Lennon',result.farmerList[0].LastName);
        System.assertEquals('+254123456789',result.farmerList[0].MobilePhone);
        System.assertEquals('Kisumu',result.farmerList[0].Village);
        System.assertEquals('TIGANIA WEST',result.farmerList[0].District);
        System.assertEquals('a3Bn0000000CfPI',result.farmerList[0].Id);
        System.assertEquals('Duplicate',result.farmerList[0].Status);
        System.assertEquals(datetime.newinstance(2013, 4, 30, 12, 34, 54), result.farmerList[0].RegisterDate);
        System.assertEquals('KARATHIA WOMEN GROUP',result.farmerList[0].GroupName);
        
        logger.debug('Test finished');
        
    }
    
    static testMethod void updateFarmerList() {
        // insert test data
        Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('[{"Id":"'+ids.get('farmer1Name')+'","Status":"Duplicate"},{"Id":"'+ids.get('farmer2Name')+'","Status":"Failed"}]}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.SuccessResponse result = (EwarehouseServiceBase.SuccessResponse) EwarehouseFarmerListRestService.updateFarmers();
        
        test.stopTest();
        
        // assert what was stored
        System.assertEquals('200', result.code);
        System.assertEquals('Update success', result.description);
        
        List<Ewarehouse_Farmer__c> lstFarmer1 = [SELECT 
                                        ID, 
                                        Name, 
                                        Status__c
                                    FROM Ewarehouse_Farmer__c WHERE Name = :ids.get('farmer1Name')];
        
        System.assertEquals(1, lstFarmer1.size());
        System.assertEquals('Duplicate', lstFarmer1.get(0).Status__c);
        
        List<Ewarehouse_Farmer__c> lstFarmer2 = [SELECT 
                                        ID, 
                                        Name, 
                                        Status__c
                                    FROM Ewarehouse_Farmer__c WHERE Name = :ids.get('farmer2Name')];
        
        System.assertEquals(1, lstFarmer2.size());
        System.assertEquals('Failed', lstFarmer2.get(0).Status__c);
       
        logger.debug('Test finished');
        
    }
    
    static testMethod void updateFarmerListNotExists() {
        
        // insert test data
        Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('[{"Id":"'+ids.get('farmer1Name')+'","Status":"Duplicate"},{"Id":"2eyUUE","Status":"Failed"}]}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.ErrorMapResponse result = (EwarehouseServiceBase.ErrorMapResponse) EwarehouseFarmerListRestService.updateFarmers();
        
        test.stopTest();
        
        // assert what was stored
        System.assertEquals('400', result.code);
        System.assertEquals('Not all IDs where found as client, attached Ids not updated.', result.description);
        
        // assert that the farmers are the same for the not updated farmers
        List<Ewarehouse_Farmer__c> lstFarmer1 = [SELECT 
                                        ID, 
                                        Name, 
                                        Status__c
                                    FROM Ewarehouse_Farmer__c WHERE Name = :ids.get('farmer1Name')];
        
        System.assertEquals(1, lstFarmer1.size());
        System.assertEquals('Duplicate', lstFarmer1.get(0).Status__c);
        
        // farmer 2 was not updated, the Id was wrong
        List<Ewarehouse_Farmer__c> lstFarmer2 = [SELECT 
                                        ID, 
                                        Name, 
                                        Status__c
                                    FROM Ewarehouse_Farmer__c WHERE Name = :ids.get('farmer2Name')];
        
        System.assertEquals(1, lstFarmer2.size());
        System.assertEquals('Processed', lstFarmer2.get(0).Status__c);
       
        logger.debug('Test finished');
        
    }
    
     static testMethod void updateFarmerListNoIdParam() {
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        // error in the JSON last Id wrong
        req.requestBody = Blob.valueOf('[{"Id":"dummy","Status":"Duplicate"},{"Ids":"dummy","Status":"Failed"}]}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // retrieve an error
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) EwarehouseFarmerListRestService.updateFarmers();
        
        test.stopTest();
        
        // assert what was stored
        System.assertEquals('400', result.code);
        System.assertEquals('JSON ERROR: We could find required parameter [Id] in one of the objects', result.description);
        
        logger.debug('Test finished');
        
    }
    
    static testMethod void updateFarmerListNoStatusParam() {
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        // error in the JSON, last Status wrong
        req.requestBody = Blob.valueOf('[{"Id":"dummy","Status":"Duplicate"},{"Id":"dummy","Statqs":"Failed"}]}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // retrieve an error
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) EwarehouseFarmerListRestService.updateFarmers();
        
        test.stopTest();
        
        // assert what was stored
        System.assertEquals('400',result.code);
        System.assertEquals('JSON ERROR: We could find required parameter [Status] in one of the objects', result.description);
        
       
        logger.debug('Test finished');
        
    }
    
    static testMethod void updateFarmerListGetException() {
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
        req.requestBody = Blob.valueOf('[{"Id":"dummy","Status":"Processed"}]');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // get an error response instead of client response
        EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) EwarehouseFarmerListRestService.updateFarmers();
        
        test.stopTest();
    
        // assert error returned
        System.assertEquals('500',result.code);
        
        logger.debug('Test finished');
        
        // reset the datasource
        EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
        
    }
    
}