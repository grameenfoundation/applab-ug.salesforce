/**
 * This class contains unit tests for validating the base class EwarehouseServiceBaseTest
 */
@isTest
public with sharing class EwarehouseServiceBaseTest {
	
	private static String testRequestURI = '/services/apexrest/ewarehouse/farmer';
    private static ServiceLogger logger = new ServiceLogger();
	
	static testMethod void testSetDataSource() {
    	EwarehouseServiceBase base = new EwarehouseServiceBase();
    	EwarehouseServiceBase.setDataSource(new EwarehouseDataSourceMock.AllExceptionMock());
    	
    	try {
    		EwarehouseServiceBase.dataSource.getFarmer('a3Bn0000000CfPI');
    	}
    	catch(Exception ex){
    		System.assertEquals('Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Contact__c]: [Contact__c]', ex.getMessage());
    	}
    	
    }
	
    static testMethod void testSuccessResponse() {
    	EwarehouseServiceBase.SuccessResponse result = new EwarehouseServiceBase.SuccessResponse('test-description');
    	System.assertEquals('200',result.code);
    	System.assertEquals('test-description',result.description);
    }
    
    static testMethod void testErrorResponse() {
    	EwarehouseServiceBase.ErrorResponse result = new EwarehouseServiceBase.ErrorResponse('error-description');
    	System.assertEquals('400',result.code);
    	System.assertEquals('error-description',result.description);
    }
    
    static testMethod void testErrorMapResponse() {
    	Map<String, String> errors = new Map<String, String>();
    	errors.put('key1', 'value1');
    	errors.put('key2', 'value2');
    	
    	EwarehouseServiceBase.ErrorMapResponse result = new EwarehouseServiceBase.ErrorMapResponse('error-description', errors);
    	
    	System.assertEquals('400',result.code);
    	System.assertEquals('error-description',result.description);
    	System.assertEquals('value1',result.objects.get('key1'));
    	System.assertEquals('value2',result.objects.get('key2'));
    	
    }
    
    static testMethod void testExceptionResponse() {
    	
    	EwarehouseServiceBase base = new EwarehouseServiceBase();
    	EwarehouseServiceBase.setDataSource(new EwarehouseDataSourceMock.AllExceptionMock());
    	
    	try {
    		EwarehouseServiceBase.dataSource.getFarmer('a3Bn0000000CfPI');
    	}
    	catch(Exception ex){
    		EwarehouseServiceBase.ExceptionResponse result = new EwarehouseServiceBase.ExceptionResponse(ex);
	    	System.assertEquals('500',result.code);
	    	System.assertEquals('EXCEPTION: System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Contact__c]: [Contact__c]',result.description);
    	}
    }
    
    static testMethod void testDmlErrorResponse() {
    	
    	EwarehouseServiceBase.DmlErrorResponse result = new EwarehouseServiceBase.DmlErrorResponse('desc', null);
    	System.assertEquals('400',result.code);
	    System.assertEquals('desc',result.description);
    	System.assertEquals(null, result.errors);
    }
    
    static testMethod void testGetParameter() {

    	Map<String, String> params = new Map<String, String>();
    	params.put('key1', 'value1');
    	params.put('key2', 'value2');
    	
    	System.assertEquals('value1', EwarehouseServiceBase.getParameter(params, 'key1'));
    	System.assertEquals('value2', EwarehouseServiceBase.getParameter(params, 'key2'));
    	System.assertEquals(null, EwarehouseServiceBase.getParameter(params, 'key3'));
    	
    }
}