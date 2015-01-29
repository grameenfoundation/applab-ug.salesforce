/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  This class is a part of the CKW Search 3.0 Bundle
 *  Tests are in SearchServerTests class
 **/
global class SearchCreateLogs {

    public static String createSearchLogs(String jsonRequestString) {
        
        //Create the response wrapper for this request
        ResponseWrapper responseWrapper = new ResponseWrapper();
        
        //Build the request object
        SearchLogRequest request = null;
        try {
            System.debug(jsonRequestString);
            request = (SearchLogRequest) JSON.deserialize(jsonRequestString, SearchLogRequest.class);
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
        Person__c interviewer = people.isEmpty() ? null : people[0];
        if(interviewer == null){
            responseWrapper.resultCode = '10';
            responseWrapper.resultMessage = 'Search logs from unknown user';
            return JSON.serializePretty(responseWrapper);
        }
         
		Person_Group_Association__c[] applabStaffs = [      
	        SELECT 
	            Person__c
	        FROM
	            Person_Group_Association__c
	        WHERE
	            Group__r.Name = 'Applab Staff' AND
	            Person__c = :interviewer.Id
        ];
		if(!applabStaffs.isEmpty()) {
            responseWrapper.resultCode = '0';
            responseWrapper.resultMessage = 'Search logs from staff user ignored. Request Successful';
            return JSON.serializePretty(responseWrapper);			
		}
                
        for(SearchLog searchLog : request.searchLogs){
            String[] location = searchLog.gpsLocation.split(' ');
            String[] submissionLocation = searchLog.submissionLocation.split(' ');
            Integer len = location.size();
            Integer len2 = submissionLocation.size();
            Search_Log__c log = new Search_Log__c();
            log.Accuracy__c = len > 3 ? Double.valueOf(location[3]) : null;
            log.Altitude__c = len > 2 ? Double.valueOf(location[2]) : null;
            log.Handset_Submit_Time__c = Datetime.now();
            log.Interviewee__c = searchLog.clientId.equals(SearchGetFarmersHelper.GROUP_SEARCH_FARMER_TEMPLATE_ID) ? null :
            	[SELECT Person__r.Id FROM Focus_Farmer__c WHERE Id = :searchLog.clientId].get(0).Person__r.Id;
        	log.Group_Search__c = searchLog.clientId.equals(SearchGetFarmersHelper.GROUP_SEARCH_FARMER_TEMPLATE_ID) ? true : false;
            log.Interviewer__c = interviewer.Id;
            log.Interviewer_Contact__c = interviewer.Contact__c;
            log.Query__c = searchLog.content;
            log.Category__c = searchLog.category;
            log.Latitude__c = len > 1 ? Double.valueOf(location[0]) : null;
            log.Longitude__c = len > 1 ? Double.valueOf(location[1]) : null;
            log.Server_Entry_Time__c = Datetime.now();
            log.Submission_Accuracy__c = len2 > 3 ? Double.valueOf(submissionLocation[3]) : null;
            log.Submission_Altitude__c = len2 > 2 ? Double.valueOf(submissionLocation[2]) : null;
            log.Submission_Latitude__c = len2 > 1 ? Double.valueOf(submissionLocation[0]) : null;
            log.Submission_Longitude__c = len2 > 1 ? Double.valueOf(submissionLocation[1]) : null;
            log.Submission_GPS_Timestamp__c = DateTime.valueOfGmt((searchLog.dateCreated).replaceAll('T',' '));
            
            insert log;
        }
        
        responseWrapper.resultCode = '0';
        responseWrapper.resultMessage = 'Request Successful';
        return JSON.serializePretty(responseWrapper);
    }
    
    public class SearchLog {
        //public Integer id{get; set;}
        //public String menuItemId{get; set;}
        public String content{get; set;}
        public String category{get; set;}
        public String dateCreated{get; set;}
        public String clientId{get; set;}
        public String gpsLocation{get; set;}
        public String submissionLocation{get; set;}
        //public boolean testLog{get; set;}
    }
    
    public class SearchLogRequest {
        //String request {get;set;}
        String imei {get;set;}
        List<SearchLog> searchLogs {get;set;}        
    }
    
    class ResponseWrapper {
        String resultCode {get;set;}
        String resultMessage {get;set;}
    }
}