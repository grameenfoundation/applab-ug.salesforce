global class SbuxSegmentationProcessBatchJob implements Database.Batchable<sObject>{

  global Database.QueryLocator start(Database.BatchableContext bc) {
	String query = 'Select Id, Sbux_Segment__c, Sbux_Segment_Probability__c from CBL_CoffeeBaseline__c where Sbux_Segment__c = null';
	return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext bc, List<CBL_CoffeeBaseline__c> bls) {
    for (CBL_CoffeeBaseline__c bl : bls) {
        SBuxSegmentationProcessHandler handler = new SBuxSegmentationProcessHandler(bl);
        handler.handle();
    }
  }
  
  global void finish(Database.BatchableContext bc) {
    // Do nothing
  }

}