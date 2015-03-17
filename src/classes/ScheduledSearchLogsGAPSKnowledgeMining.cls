/**
 *
 * Copyright (c) 2015 Grameen Foundation
 *
 *  Scheduling class for processing previous day's Search Logs by
 *	discovering the GAPs knowledge a farmer acquired
 *
 *  Tests are in SearchServerTests
 **/
global class ScheduledSearchLogsGAPSKnowledgeMining implements Schedulable {
    
    global void execute(SchedulableContext context){
        
        System.debug(Logginglevel.INFO, 'Data mining for GAPs Knowledge in Search Logs started ...');
        
        String query = 
		'SELECT '								+
			'Id, '								+
			'Interviewer__c, '					+
			'Interviewee__c, '					+
			'Submission_GPS_Timestamp__c, '		+
			'Interviewee__r.Name, '				+
			'Query__c '							+
		'FROM '									+
			'Search_Log__c '					+
		'WHERE '								+
			'Server_Entry_Time__c = YESTERDAY';
		
		ID batchprocessid = Database.executeBatch(new SearchLogsGAPSKnowledgeMining(query), 40);
    }
}