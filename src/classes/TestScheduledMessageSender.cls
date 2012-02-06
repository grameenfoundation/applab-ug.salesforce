@isTest
private class TestScheduledMessageSender {
    static testMethod void test() {
        Test.startTest();

        String jobId = System.schedule('testScheduledMessageSender',
            ScheduledMessageSender.cronExpression, new ScheduledMessageSender());

            // Get the information from the CronTrigger API object  
        CronTrigger cronTrigger = [SELECT id, CronExpression, TimesTriggered, NextFireTime
                                    FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same  
        System.assertEquals(ScheduledMessageSender.cronExpression, cronTrigger.CronExpression);
        // Verify the job has not run  
        System.assertEquals(0, cronTrigger.TimesTriggered);
        Test.stopTest();
    }
}