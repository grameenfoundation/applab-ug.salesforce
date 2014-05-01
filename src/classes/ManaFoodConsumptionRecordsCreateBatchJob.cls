global class ManaFoodConsumptionRecordsCreateBatchJob implements Database.Batchable<sObject>{
  global Database.QueryLocator start(Database.BatchableContext bc) {
      String query = 'SELECT Id, Submission__c, temp_processed__c, Household__c from Mana_Food_Consumption_Submission__c WHERE Submission__c !=  NULL AND temp_processed__c = false';
      return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext bc, List<Mana_Food_Consumption_Submission__c> submissions) {
    for (Mana_Food_Consumption_Submission__c submission : submissions) {
        ManaFoodConsumptionSubmissionHandler handler = new ManaFoodConsumptionSubmissionHandler(submission);
        handler.handle();
        submission.temp_processed__c = true;
    }
    update submissions;
  }
  
  global void finish(Database.BatchableContext bc) {
    // Do nothing
  }
}