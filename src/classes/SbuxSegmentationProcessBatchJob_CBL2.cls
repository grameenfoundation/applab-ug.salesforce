global class SbuxSegmentationProcessBatchJob_CBL2 implements Database.Batchable<sObject>{

  global Database.QueryLocator start(Database.BatchableContext bc) {
  String query = 'Select Id, sbuxSegment__c, sbuxSegmentProbability__c from CBL2_Farmer__c where sbuxSegment__c = null';
  return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext bc, List<CBL2_Farmer__c> bls) {
    for (CBL2_Farmer__c bl : bls) {
        SBuxSegmentationProcessHandler_CBL2 handler = new SBuxSegmentationProcessHandler_CBL2(bl);
        handler.handle();
    }
  }
  
  global void finish(Database.BatchableContext bc) {
    // Do nothing
  }

}