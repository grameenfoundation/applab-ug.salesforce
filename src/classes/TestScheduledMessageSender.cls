@isTest
private class TestScheduledMessageSender {
    static testMethod void test() {
        Test.startTest();
        
        String jobId = '';
        
		if(Test.isRunningTest() && Limits.getFutureCalls() >= Limits.getLimitFutureCalls()) {
		     system.debug(LoggingLevel.Error, 'Future method limit reached. Skipping...');
		} else {
		    jobId = System.schedule('testScheduledMessageSender',
            ScheduledMessageSender.cronExpression, new ScheduledMessageSender());
		}
		
        // Get the information from the CronTrigger API object  
        CronTrigger cronTrigger = [SELECT id, CronExpression, TimesTriggered, NextFireTime
                                    FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same  
        System.assertEquals(ScheduledMessageSender.cronExpression, cronTrigger.CronExpression);
        // Verify the job has not run  
        System.assertEquals(0, cronTrigger.TimesTriggered);
        Test.stopTest();
    }
    
    static testMethod void myScheduledClass() {

        Test.startTest();
        
        String CRON_EXP = '0 0 0 1 1 ? 2035';  
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new ScheduledHarvestMessageSender());

        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2035-01-01 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
}