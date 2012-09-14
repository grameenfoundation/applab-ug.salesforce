public with sharing class ErrorLog {

	private static List<Error_Log__c> errors = new List<Error_Log__c>();

	public static void write(String scriptName, String methodName, String message, Double severity) {				
		Error_Log__c logEntry = new Error_Log__c();
		logEntry.Script_Name__c = scriptName;
		logEntry.Method_Name__c = methodName;
		logEntry.Long_Message__c = message;
		logEntry.Severity__c = severity;
		
		Database.insert(logEntry);
		System.debug('\nLog Error: ' + message + '\n');		
	}

	public static void writeLater(String scriptName, String methodName, String message, Double severity) {
		Error_Log__c logEntry = new Error_Log__c();
		logEntry.Script_Name__c = scriptName;
		logEntry.Method_Name__c = methodName;
		logEntry.Long_Message__c = message; // TODO: change to message, remove this field
		logEntry.Severity__c = severity;

		errors.add(logEntry);
		System.debug('\nEnqueued Error: ' + message + '\n');		
	}
		
	public static void flush() {
		Database.insert(errors);
		errors.clear();
	}
	
	static testMethod void testWrite() {
		Integer serverLogEntries = [SELECT count() from Error_Log__c]; 
		ErrorLog.write('testErrorLog', 'testWrite', 'Testing sync error logging', 2);
		Integer updatedLogEntries = [SELECT count() from Error_Log__c];
		System.assert(updatedLogEntries > serverLogEntries); 
	}
	
	static testMethod void testWriteLater() {
		Integer beforeSize = ErrorLog.errors.size();
		ErrorLog.writeLater('testErrorLog', 'testWriteLater', 'Testing async error logging', 2);
		ErrorLog.writeLater('testErrorLog', 'testWriteLater', 'Testing async error logging', 2);
		ErrorLog.writeLater('testErrorLog', 'testWriteLater', 'Testing async error logging', 2);
		Integer afterSize = ErrorLog.errors.size();
		System.assert(afterSize == beforeSize + 3);
	}
}