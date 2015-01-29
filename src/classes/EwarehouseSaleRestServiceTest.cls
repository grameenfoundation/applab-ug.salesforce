/**
 * This class contains unit tests for validating the behavior of Ewarehouse Sales REST API
 */
@isTest
private class EwarehouseSaleRestServiceTest {
	
	private static ServiceLogger logger = new ServiceLogger();
	
	private static String testRequestURI = '/services/apexrest/ewarehouse/salelist'; 

    static testMethod void getSalesNoParameter() {
    	
    	// insert test data
        Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
    	
 		// ready to start the test
 		test.startTest();
    	
    	// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the sales (normally converted to JSON via API)
		EwarehouseSaleRestService.SalesResponse result = (EwarehouseSaleRestService.SalesResponse) EwarehouseSaleRestService.getSales();
		
		test.stopTest();
		
		// assert what was stored
		logger.debug(result);
		
		// assert error returned
		System.assertEquals('200',result.code);
		//System.assertEquals(2, result.sales.Count);
		Boolean sale1_1IdFound = false;
		Boolean sale1_2IdFound = false;
		Boolean sale2_1IdFound = false;
		Boolean sale2_2IdFound = false;
		
		
		for(EwarehouseSale es : result.saleList){
			logger.debug('es.Id: ' + es.Id);
			logger.debug('sale1_1Name: ' + ids.get('sale1_1Name'));
			if(ids.get('sale1_1Name').contains(es.Id)){
				System.assert(ids.get('sale1_1Name').contains(es.Id));
				System.assertEquals(ids.get('farmer1Name'), es.FarmerID);
				sale1_1IdFound = true;
			}
			
			if(ids.get('sale1_2Name').contains(es.Id)){
				System.assert(ids.get('sale1_2Name').contains(es.Id));
				System.assertEquals(ids.get('farmer2Name'), es.FarmerID);
				sale1_2IdFound = true;
			}
			
			if(ids.get('sale2_1Name').contains(es.Id)){
				System.assert(ids.get('sale2_1Name').contains(es.Id));
				System.assertEquals(ids.get('farmer1Name'), es.FarmerID);
				sale2_1IdFound = true;
			}
			
			if(ids.get('sale2_2Name').contains(es.Id)){
				System.assert(ids.get('sale2_2Name').contains(es.Id));
				System.assertEquals(ids.get('farmer2Name'), es.FarmerID);
				sale2_2IdFound = true;
			}
			
			System.assertEquals(1, es.BeansNo90kgBags);
			System.assertEquals(2, es.CowPeasNo90kgBags);
			System.assertEquals(3, es.DolichosNo90kgBags);
			System.assertEquals(4, es.GreenGramsNo90kgBags);
			System.assertEquals(5, es.MaizeNo90kgBags);
			System.assertEquals(6, es.PigeonPeasNo90kgBags);
			
			System.assertEquals(10, es.BeansPrice90kgBag);
			System.assertEquals(20, es.CowPeasPrice90kgBag);
			System.assertEquals(30, es.DolichosPrice90kgBag);
			System.assertEquals(40, es.GreenGramsPrice90kgBag);
			System.assertEquals(50, es.MaizePrice90kgBag);
			System.assertEquals(6, es.PigeonPeasPrice90kgBag);
			
			System.assertEquals(date.newInstance(2014, 2, 4), es.SaleDate);
			System.assertEquals(date.newInstance(2014, 2, 5), es.BankDepositDate);
			System.assertEquals(null, es.SaleStatus);
		}
		logger.debug(sale1_1IdFound);
		logger.debug(sale1_2IdFound);
		logger.debug(sale2_1IdFound);
		logger.debug(sale2_2IdFound);
		System.assert(sale1_1IdFound && sale1_2IdFound && sale2_1IdFound && sale2_2IdFound, 'Not all sales where found in the resulting list');
		
		logger.debug('Test finished');
    }
    
    static testMethod void getSalesNew() {
    	
    	// insert test data
        Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
    	
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
		
		// load the results in the sales (normally converted to JSON via API)
		EwarehouseSaleRestService.SalesResponse result = (EwarehouseSaleRestService.SalesResponse) EwarehouseSaleRestService.getSales();
		
		test.stopTest();
		
		// assert what was stored
		logger.debug(result);
		
		// assert error returned
		System.assertEquals('200',result.code);
		//System.assertEquals(2, result.sales.Count);
		Boolean sale1_1IdFound = false;
		Boolean sale1_2IdFound = false;
		Boolean sale2_1IdFound = false;
		Boolean sale2_2IdFound = false;
		
		
		for(EwarehouseSale es : result.saleList){
			logger.debug('es.Id: ' + es.Id);
			logger.debug('sale1_1Name: ' + ids.get('sale1_1Name'));
			if(ids.get('sale1_1Name').contains(es.Id)){
				System.assert(ids.get('sale1_1Name').contains(es.Id));
				System.assertEquals(ids.get('farmer1Name'), es.FarmerID);
				sale1_1IdFound = true;
			}
			
			if(ids.get('sale1_2Name').contains(es.Id)){
				System.assert(ids.get('sale1_2Name').contains(es.Id));
				System.assertEquals(ids.get('farmer2Name'), es.FarmerID);
				sale1_2IdFound = true;
			}
			
			if(ids.get('sale2_1Name').contains(es.Id)){
				System.assert(ids.get('sale2_1Name').contains(es.Id));
				System.assertEquals(ids.get('farmer1Name'), es.FarmerID);
				sale2_1IdFound = true;
			}
			
			if(ids.get('sale2_2Name').contains(es.Id)){
				System.assert(ids.get('sale2_2Name').contains(es.Id));
				System.assertEquals(ids.get('farmer2Name'), es.FarmerID);
				sale2_2IdFound = true;
			}
			
			System.assertEquals(1, es.BeansNo90kgBags);
			System.assertEquals(2, es.CowPeasNo90kgBags);
			System.assertEquals(3, es.DolichosNo90kgBags);
			System.assertEquals(4, es.GreenGramsNo90kgBags);
			System.assertEquals(5, es.MaizeNo90kgBags);
			System.assertEquals(6, es.PigeonPeasNo90kgBags);
			
			System.assertEquals(10, es.BeansPrice90kgBag);
			System.assertEquals(20, es.CowPeasPrice90kgBag);
			System.assertEquals(30, es.DolichosPrice90kgBag);
			System.assertEquals(40, es.GreenGramsPrice90kgBag);
			System.assertEquals(50, es.MaizePrice90kgBag);
			System.assertEquals(6, es.PigeonPeasPrice90kgBag);
			
			System.assertEquals(date.newInstance(2014, 2, 4), es.SaleDate);
			System.assertEquals(date.newInstance(2014, 2, 5), es.BankDepositDate);
			System.assertEquals(null, es.SaleStatus);
		}

		System.assert(sale1_1IdFound && sale1_2IdFound && sale2_1IdFound && sale2_2IdFound, 'Not all sales where found in the resulting list');
		
		logger.debug('Test finished');
    }
    
    static testMethod void getSalesProcessedWithNull() {
    	// insert test data
        Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
        
        // update a sale status
    	Sale_Record__c sChange = [SELECT Status__c,Beans_Number_of_90kg_Bags__c,Cow_Peas_Number_of_90kg_Bags__c,Dolichos_Number_of_90kg_Bags__c,Green_Grams_Number_of_90kg_Bags__c,Maize_Number_of_90kg_Bags__c,Pigeon_Peas_Price_per_90kg_Bag__c,Beans_Price_per_90kg_Bag__c,Cow_Peas_Price_per_90kg_Bag__c,Dolichos_Price_per_90kg_Bag__c,Green_Grams_Price_per_90kg_Bag__c,Maize_Price_per_90kg_Bag__c,Pigeon_Peas_Total_Amount__c FROM Sale_Record__c WHERE Id = :ids.get('sale2_1Id')];
    	sChange.Beans_Number_of_90kg_Bags__c = null;
    	sChange.Cow_Peas_Number_of_90kg_Bags__c = null;
		sChange.Dolichos_Number_of_90kg_Bags__c = null;
		sChange.Green_Grams_Number_of_90kg_Bags__c = null;
		sChange.Maize_Number_of_90kg_Bags__c = null;
        
		sChange.Pigeon_Peas_Price_per_90kg_Bag__c = null;
		sChange.Beans_Price_per_90kg_Bag__c = null;
		sChange.Cow_Peas_Price_per_90kg_Bag__c = null;
		sChange.Dolichos_Price_per_90kg_Bag__c = null;
		sChange.Green_Grams_Price_per_90kg_Bag__c = null;
		sChange.Maize_Price_per_90kg_Bag__c = null;
        
		sChange.Pigeon_Peas_Total_Amount__c = null;
        sChange.Status__c = 'Processed';
        
        update sChange;
        
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
		
		// load the results in the sales (normally converted to JSON via API)
		EwarehouseSaleRestService.SalesResponse result = (EwarehouseSaleRestService.SalesResponse) EwarehouseSaleRestService.getSales();
		
		test.stopTest();
		
		// assert what was stored
		logger.debug(result);
		
		// assert error returned
		System.assertEquals('200',result.code);
		/*
		for(EwarehouseSale es : result.saleList){
			
			System.assert(ids.get('sale2_1Name').contains(es.Id));
			System.assertEquals(ids.get('farmer1Name'), es.FarmerID);
			
			System.assertEquals(0, es.BeansNo90kgBags);
			System.assertEquals(0, es.CowPeasNo90kgBags);
			System.assertEquals(0, es.DolichosNo90kgBags);
			System.assertEquals(0, es.GreenGramsNo90kgBags);
			System.assertEquals(0, es.MaizeNo90kgBags);
			System.assertEquals(0, es.PigeonPeasNo90kgBags);
			
			System.assertEquals(0, es.BeansPrice90kgBag);
			System.assertEquals(0, es.CowPeasPrice90kgBag);
			System.assertEquals(0, es.DolichosPrice90kgBag);
			System.assertEquals(0, es.GreenGramsPrice90kgBag);
			System.assertEquals(0, es.MaizePrice90kgBag);
			System.assertEquals(0, es.PigeonPeasPrice90kgBag);
			
			System.assertEquals(date.newInstance(2014, 2, 4), es.SaleDate);
			System.assertEquals(date.newInstance(2014, 2, 5), es.BankDepositDate);
			System.assertEquals('Processed', es.SaleStatus);
		}*/
    }
    
    static testMethod void getSalesNewPartialResults() {
    	
    	// insert test data
        Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
        
        // update a sale status
    	Sale_Record__c sChange = [SELECT Status__c FROM Sale_Record__c WHERE Id = :ids.get('sale2_1Id')];
        sChange.Status__c = 'Processed';
        update sChange;
        
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
		
		// load the results in the sales (normally converted to JSON via API)
		EwarehouseSaleRestService.SalesResponse result = (EwarehouseSaleRestService.SalesResponse) EwarehouseSaleRestService.getSales();
		
		test.stopTest();
		
		// assert what was stored
		logger.debug(result);
		
		// assert error returned
		System.assertEquals('200',result.code);
		//System.assertEquals(2, result.sales.Count);
		Boolean sale1_1IdFound = false;
		Boolean sale1_2IdFound = false;
		Boolean sale2_1IdFound = false;
		Boolean sale2_2IdFound = false;
		
		
		for(EwarehouseSale es : result.saleList){
			logger.debug('es.Id: ' + es.Id);
			logger.debug('sale1_1Name: ' + ids.get('sale1_1Name'));
			if(ids.get('sale1_1Name').contains(es.Id)){
				System.assert(ids.get('sale1_1Name').contains(es.Id));
				System.assertEquals(ids.get('farmer1Name'), es.FarmerID);
				sale1_1IdFound = true;
			}
			
			if(ids.get('sale1_2Name').contains(es.Id)){
				System.assert(ids.get('sale1_2Name').contains(es.Id));
				System.assertEquals(ids.get('farmer2Name'), es.FarmerID);
				sale1_2IdFound = true;
			}
			
			if(ids.get('sale2_1Name').contains(es.Id)){
				System.assert(ids.get('sale2_1Name').contains(es.Id));
				System.assertEquals(ids.get('farmer1Name'), es.FarmerID);
				sale2_1IdFound = true;
			}
			
			if(ids.get('sale2_2Name').contains(es.Id)){
				System.assert(ids.get('sale2_2Name').contains(es.Id));
				System.assertEquals(ids.get('farmer2Name'), es.FarmerID);
				sale2_2IdFound = true;
			}
			
			System.assertEquals(1, es.BeansNo90kgBags);
			System.assertEquals(2, es.CowPeasNo90kgBags);
			System.assertEquals(3, es.DolichosNo90kgBags);
			System.assertEquals(4, es.GreenGramsNo90kgBags);
			System.assertEquals(5, es.MaizeNo90kgBags);
			System.assertEquals(6, es.PigeonPeasNo90kgBags);
			
			System.assertEquals(10, es.BeansPrice90kgBag);
			System.assertEquals(20, es.CowPeasPrice90kgBag);
			System.assertEquals(30, es.DolichosPrice90kgBag);
			System.assertEquals(40, es.GreenGramsPrice90kgBag);
			System.assertEquals(50, es.MaizePrice90kgBag);
			System.assertEquals(6, es.PigeonPeasPrice90kgBag);
			
			System.assertEquals(date.newInstance(2014, 2, 4), es.SaleDate);
			System.assertEquals(date.newInstance(2014, 2, 5), es.BankDepositDate);
			System.assertEquals(null, es.SaleStatus);
		}
		
		System.assert(sale1_1IdFound && sale1_2IdFound && sale2_2IdFound, 'Not all sales where found in the resulting list');
		System.assert(sale2_1IdFound == false);
		logger.debug('Test finished');
    }
    
    static testMethod void getSalesProcessedPartialResults() {
    	
    	// insert test data
        Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
        
        // update a sale status
    	Sale_Record__c sChange = [SELECT Status__c FROM Sale_Record__c WHERE Id = :ids.get('sale2_1Id')];
        sChange.Status__c = 'Processed';
        update sChange;
        
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
		
		// load the results in the sales (normally converted to JSON via API)
		EwarehouseSaleRestService.SalesResponse result = (EwarehouseSaleRestService.SalesResponse) EwarehouseSaleRestService.getSales();
		
		test.stopTest();
		
		// assert what was stored
		logger.debug(result);
		
		// assert error returned
		System.assertEquals('200',result.code);
		
		for(EwarehouseSale es : result.saleList){
			
			System.assert(ids.get('sale2_1Name').contains(es.Id));
			System.assertEquals(ids.get('farmer1Name'), es.FarmerID);
			
			System.assertEquals(1, es.BeansNo90kgBags);
			System.assertEquals(2, es.CowPeasNo90kgBags);
			System.assertEquals(3, es.DolichosNo90kgBags);
			System.assertEquals(4, es.GreenGramsNo90kgBags);
			System.assertEquals(5, es.MaizeNo90kgBags);
			System.assertEquals(6, es.PigeonPeasNo90kgBags);
			
			System.assertEquals(10, es.BeansPrice90kgBag);
			System.assertEquals(20, es.CowPeasPrice90kgBag);
			System.assertEquals(30, es.DolichosPrice90kgBag);
			System.assertEquals(40, es.GreenGramsPrice90kgBag);
			System.assertEquals(50, es.MaizePrice90kgBag);
			System.assertEquals(6, es.PigeonPeasPrice90kgBag);
			
			System.assertEquals(date.newInstance(2014, 2, 4), es.SaleDate);
			System.assertEquals(date.newInstance(2014, 2, 5), es.BankDepositDate);
			System.assertEquals('Processed', es.SaleStatus);
		}

		logger.debug('Test finished');
    }
    
    static testMethod void getSalesDMLException() {
     	
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
		
		RestContext.request = req;
		RestContext.response = res;
		
		// get an error response instead of sales response
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) EwarehouseSaleRestService.getSales();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('500',result.code);
		
		logger.debug('Test finished');
		// reset the datasource
		EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
    }
    
    static testMethod void getNoSalesReturned() {
    	
    	// insert test data
        Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
        
        List<Sale_Record__c> sales =[SELECT Status__c FROM Sale_Record__c];
        for(Sale_Record__c sale : sales){
        	sale.Status__c = 'Processing';
        }
        update sales;
        
    	
 		// ready to start the test
 		test.startTest();
    	
    	// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'GET';
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the sales (normally converted to JSON via API)
		EwarehouseSaleRestService.SalesResponse result = (EwarehouseSaleRestService.SalesResponse) EwarehouseSaleRestService.getSales();
		
		test.stopTest();
		
		// assert what was stored
		
		System.assertEquals('200',result.code);
		System.assertEquals('OK',result.description);
		System.assertEquals(0,result.saleList.size());
		logger.debug('Test finished');
    	
    }
        
    static testMethod void updateSale() {
    	// insert test data
        Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
    		
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('[{"Id":"'+ids.get('sale1_1Name')+'","Status":"Duplicate"},{"Id":"'+ids.get('sale2_1Name')+'","Status":"Failed"}]}');
        logger.debug('[{"Id":"'+ids.get('sale1_1Name')+'","Status":"Duplicate"},{"Id":"'+ids.get('sale2_1Name')+'","Status":"Failed"}]}');
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.SuccessResponse result = (EwarehouseServiceBase.SuccessResponse) EwarehouseSaleRestService.updateSales();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('200', result.code);
		System.assertEquals('Update success', result.description);
		
		List<Sale_Record__c> lstSale1 = [SELECT 
										ID, 
										Status__c
									FROM Sale_Record__c WHERE Id = :ids.get('sale1_1Id')];
		
		System.assertEquals(1, lstSale1.size());
		System.assertEquals('Duplicate', lstSale1.get(0).Status__c);
        
        List<Sale_Record__c> lstSale2 = [SELECT 
										ID, 
										Status__c
									FROM Sale_Record__c WHERE Id = :ids.get('sale2_1Id')];
		
		System.assertEquals(1, lstSale2.size());
		System.assertEquals('Failed', lstSale2.get(0).Status__c);
       
		logger.debug('Test finished');
 		
    }
    
    static testMethod void updateSalesNotExists() {
		// insert test data
        Map<String, String> ids = EwarehouseDataSourceMock.insertTestData();
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('[{"Id":"'+ids.get('sale1_1Name')+'","Status":"Processing"},{"Id":"non-existing","Status":"Failed"}]}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.ErrorMapResponse result = (EwarehouseServiceBase.ErrorMapResponse) EwarehouseSaleRestService.updateSales();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400', result.code);
		System.assertEquals('Not all IDs where found as sales, attached Ids not updated.', result.description);
		
		Sale_Record__c sale1 = [SELECT Status__c FROM Sale_Record__c WHERE Id = :ids.get('sale1_1Id')];
		Sale_Record__c sale2 = [SELECT Status__c FROM Sale_Record__c WHERE Id = :ids.get('sale1_2Id')];
		Sale_Record__c sale3 = [SELECT Status__c FROM Sale_Record__c WHERE Id = :ids.get('sale2_1Id')];
		Sale_Record__c sale4 = [SELECT Status__c FROM Sale_Record__c WHERE Id = :ids.get('sale2_2Id')];
		
		System.assertEquals('Processing', sale1.Status__c);
		System.assertEquals(null, sale2.Status__c);
		System.assertEquals(null, sale3.Status__c);
		System.assertEquals(null, sale4.Status__c);
		
		logger.debug('Test finished');
 		
    }
    
    static testMethod void updateSalesNoIdParam() {
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		// error in the JSON last Id wrong
		String jsonString = '[{"Id":"dummy","Status":"Duplicate"},{"Ids":"dummy","Status":"Failed"}]}';
		req.requestBody = Blob.valueOf(jsonString);
		
		RestContext.request = req;
		RestContext.response = res;
		
		// retrieve an error
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) EwarehouseSaleRestService.updateSales();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400', result.code);
		System.assertEquals('JSON ERROR: We could find required parameter [Id] in one of the objects', result.description);
		
		logger.debug('Test finished');
 		
    }
    
    static testMethod void updateSalesNoStatusParam() {
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		// error in the JSON, last Status wrong
		String jsonString = '[{"Id":"dummy","Status":"Duplicate"},{"Id":"dummy","Statqs":"Failed"}]}';
		req.requestBody = Blob.valueOf(jsonString);
		
		RestContext.request = req;
		RestContext.response = res;
		
		// retrieve an error
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) EwarehouseSaleRestService.updateSales();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400',result.code);
		System.assertEquals('JSON ERROR: We could find required parameter [Status] in one of the objects', result.description);
		
       
		logger.debug('Test finished');
 		
    }
    
    
    static testMethod void updateSalesGetException() {
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
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) EwarehouseSaleRestService.updateSales();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('500',result.code);
		
		logger.debug('Test finished');
		
		// reset the datasource
		EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
 		
    }
}