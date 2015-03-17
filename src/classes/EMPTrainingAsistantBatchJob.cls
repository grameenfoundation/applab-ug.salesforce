global class EMPTrainingAsistantBatchJob implements Database.Batchable<sObject> {
	
	 global Database.QueryLocator start(Database.BatchableContext bc) {
      // 
      String query = 'Select Id, EMP_Training_Assistant_Member__c, EMP_Organization_Member_Beneficiary__c, Identification_Number__c from EMP_Training_Assistant__c where EMP_Organization_Member_Beneficiary__c = null' ;
      return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext bc, List<EMP_Training_Assistant__c> empTAs) {
    for (EMP_Training_Assistant__c empTA : empTAs) {
        EMPTrainingasistantHandler handler = new EMPTrainingasistantHandler(empTA); 
        handler.handle();
    }
    update empTAs;
  }
  
  global void finish(Database.BatchableContext bc) {
    // Do nothing
  }
	
}