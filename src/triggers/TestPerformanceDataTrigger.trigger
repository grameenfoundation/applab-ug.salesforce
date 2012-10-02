trigger TestPerformanceDataTrigger on Error_Log__c (after delete) {
	//PerformanceDataCollector.collectAndUpdateCkwData();	
	//ErrorLog.flush();
	//ErrorLog.write('trigger', 'main', 'finished execution', 3);
}