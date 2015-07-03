@isTest
private class ManaFoodConsRecCreateBatchJobTest {
    
     @isTest static void testBatchJob() {

        Mana_Household__c mhh = new Mana_Household__c();
        mhh.Name = '123';
        insert mhh;

        gfsurveys__Survey__c survey =new gfsurveys__Survey__c();
        survey.Name = 'prueba';
        insert survey;

        gfsurveys__Submission__c submission = new gfsurveys__Submission__c();
        submission.gfsurveys__Survey__c = survey.Id;
        insert submission;
        
        Mana_Food_Consumption_Submission__c mfcs = new Mana_Food_Consumption_Submission__c();
        mfcs.Household__c = mhh.Id;
        mfcs.Submission__c = submission.Id;
        mfcs.temp_processed__c = False;
        insert  mfcs;

        ManaFoodConsumptionRecordsCreateBatchJob  manaCreateRecords = new ManaFoodConsumptionRecordsCreateBatchJob();

        Test.startTest();
        Database.executeBatch(manaCreateRecords,1);
        Test.stopTest();
    }
    
}