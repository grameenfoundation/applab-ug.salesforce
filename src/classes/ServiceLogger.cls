public with sharing class ServiceLogger {
	public void debug(object pAny){
		System.debug(LoggingLevel.Debug, pAny);
	}
	
	public void error(object pAny){
		System.debug(LoggingLevel.Error, pAny);
	}
}