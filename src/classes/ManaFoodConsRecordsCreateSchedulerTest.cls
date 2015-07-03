@isTest
private class ManaFoodConsRecordsCreateSchedulerTest {
    
    @isTest static void testSchedule() {
        Test.StartTest();
        ManaFoodConsRecordsCreateScheduler sh1 = new ManaFoodConsRecordsCreateScheduler();      
         String sch = '0 0 23 * * ?';
                system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    
}