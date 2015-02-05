/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  This class is a part of the CKW Search 3.0 Bundle
 *  Tests are in SearchServerTests class
 **/
public class SearchGetFarmersHelper {
    
    private final static String DEFAULT_FARMERS_VERSION = '2014-11-03 00:00:00';
    public final static String GROUP_SEARCH_FARMER_TEMPLATE_ID = 'ID1234567891011';
    public final static String MY_SEARCHES_FARMER_TEMPLATE_ID = 'ID1234567891012';
    
    /**
     * @param jsonRequestString -   JSON request containing the create-date of the latest
     *                              farmer on the requesting device, 
     * @return String JSON  -   with the corresponding details of farmers' created after
     *                          the create-date in the jsonRequest
    */
    public static String getFarmers(String jsonRequestString) {
        
        //Create the response wrapper for this request
        ResponseWrapper responseWrapper = new ResponseWrapper();
        
        //Build the request object
        RequestWrapper request = null;
        try {
            request = (RequestWrapper) JSON.deserialize(jsonRequestString, RequestWrapper.class);
        }
        catch(Exception e) {
            responseWrapper.resultCode = '10';
            responseWrapper.resultMessage = 'Request could not be decoded';
            return JSON.serializePretty(responseWrapper);
        }
        Person__c[] people = [
            SELECT
                Name,
                Id,
                Contact__c
            FROM
                Person__c
            WHERE
                Handset__r.IMEI__c = :request.imei
            LIMIT 1];
        if(people.size() == 0) {
            //unknown device
            responseWrapper.resultCode = '10';
            responseWrapper.resultMessage = 'Request from unknown device';
            return JSON.serializePretty(responseWrapper);
        }
        List<Banana_Farmer__c> bFarmers = [
            SELECT 
                Focus_Farmer_Name__c
            FROM
                Banana_Farmer__c
            WHERE
                Registered_By__c = :people[0].Contact__c
                
        ];
        List<Coffee_Farmer__c> cFarmers = [
            SELECT 
                Focus_Farmer_Name__c
            FROM
                Coffee_Farmer__c
            WHERE
                Registered_By__c = :people[0].Contact__c
                
        ];
        List<Maize_Farmer__c> mFarmers = [
            SELECT 
                Focus_Farmer_Name__c
            FROM
                Maize_Farmer__c
            WHERE
                Registered_By__c = :people[0].Contact__c
                
        ];
        List<String> focusFarmerIds = new List<String>();
        for(Banana_Farmer__c farmer : bFarmers){
            focusFarmerIds.add(farmer.Focus_Farmer_Name__c);
        }
        for(Coffee_Farmer__c farmer : cFarmers){
            focusFarmerIds.add(farmer.Focus_Farmer_Name__c);
        }
        for(Maize_Farmer__c farmer : mFarmers){
            focusFarmerIds.add(farmer.Focus_Farmer_Name__c);
        }
        List<Focus_Farmer__c> farmers  = [
            SELECT
                Id,
                CreatedDate,
                Person__r.First_Name__c,
                Person__r.Last_Name__c,
                Person__r.CreatedDate,
                Subcounty__c,
                Village_LC1__c
            FROM
                Focus_Farmer__c
            WHERE
                Name IN :focusFarmerIds AND
                CreatedDate > :Datetime.valueOf(request.farmersVersion)
            ORDER BY 
                CreatedDate ASC
        ];
        if(farmers.size() == 0 && !DEFAULT_FARMERS_VERSION.equals(request.farmersVersion)) {
            //No newer farmers.
            responseWrapper.resultCode = '0';
            responseWrapper.resultMessage = 'No newer farmers';
            responseWrapper.farmerVersion = request.farmersVersion;
            responseWrapper.farmerCount = farmers.size();
            responseWrapper.afarmerResults = new List<FarmerData>();
            return JSON.serializePretty(responseWrapper);
        }
         
        //Build the farmers' List to return 
        List<FarmerData> farmersDataList = new List<FarmerData>();      
        for(Focus_Farmer__c farmer : farmers) {
            FarmerData tempFarmerData = new FarmerData();
            tempFarmerData.farmerId = farmer.Id;
            tempFarmerData.firstName = farmer.Person__r.First_Name__c;
            tempFarmerData.lastName = farmer.Person__r.Last_Name__c;
            tempFarmerData.creationDate = String.valueOf(farmer.CreatedDate);
            tempFarmerData.subcounty = farmer.Subcounty__c;
            tempFarmerData.village = farmer.Village_LC1__c;            
            farmersDataList.add(tempFarmerData);
        }
         
		//now add a group search template user
		//this user will be attached to all group searches
		//this is added onl on first load hence the IF statement
		FarmerData groupSearchTemplateUser = new FarmerData();
		FarmerData mySearchTemplateUser = new FarmerData();
		if(DEFAULT_FARMERS_VERSION.equals(request.farmersVersion)) {
			groupSearchTemplateUser.farmerId = GROUP_SEARCH_FARMER_TEMPLATE_ID;
	        groupSearchTemplateUser.firstName = 'Group';
	        groupSearchTemplateUser.lastName = 'Search';
	        groupSearchTemplateUser.creationDate = String.valueOf(datetime.now());
	        groupSearchTemplateUser.subcounty = '';
	        groupSearchTemplateUser.village = '';            
	        farmersDataList.add(groupSearchTemplateUser);
			mySearchTemplateUser.farmerId = MY_SEARCHES_FARMER_TEMPLATE_ID;
	        mySearchTemplateUser.firstName = 'My';
	        mySearchTemplateUser.lastName = 'Searches';
	        mySearchTemplateUser.creationDate = String.valueOf(datetime.now());
	        mySearchTemplateUser.subcounty = '';
	        mySearchTemplateUser.village = '';            
	        farmersDataList.add(mySearchTemplateUser);
		}
         
        responseWrapper.resultCode = '0';
        responseWrapper.resultMessage = 'Farmers found';
        responseWrapper.farmerVersion = farmers.size() == 0 ? String.valueOf(groupSearchTemplateUser.creationDate) :
        	String.valueOf(farmers.get(farmers.size() - 1).CreatedDate);
        responseWrapper.farmerCount = farmers.size();
        responseWrapper.afarmerResults = farmersDataList ;

        return JSON.serializePretty(responseWrapper);
    }

    /*
     * Wrapper class for the json requests
     */
    public class RequestWrapper {
        //public String request {get;set;}
        public String imei {get;set;}
        public String farmersVersion {get;set;}
    }
    
    /*
     * Wrapper class for farmer data in response 
    */
    class FarmerData {
        String farmerId {get;set;}
        String firstName {get;set;}
        String lastName {get;set;}
        String creationDate {get;set;}
        String subcounty {get;set;}
        String village {get;set;}
    }
    
    /**
     * Wrapper class for farmers request response has
     * String resultcode
     * String resultmessage
     * List<FarmerData> farmerResults
    */
    class ResponseWrapper {
        String resultCode {get;set;}
        String resultMessage {get;set;}
        String farmerVersion {get; set;}
        Integer farmerCount {get; set;}
        List<FarmerData> afarmerResults {get;set;}
        
        //Constructor, creates an empty list
        public ResponseWrapper() {
            this.resultCode = '0';
            this.resultMessage = 'Operation succesful';
            this.afarmerResults = new List<FarmerData>();
        }
    }
}