@isTest
private class TestTdrDailyEmailScheduler {

    static testMethod void testGroupUpdate () {

        Test.startTest();
        System.debug('START TO TEST THE CRON JOB');

        // Schedule the test job
        String jobId = System.schedule('TDR Daily Email',
            ScheduledTdrDailyEmail.cronExpression, new ScheduledTdrDailyEmail());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(ScheduledTdrDailyEmail.cronExpression, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        System.debug('STOP TESTING THE CRON JOB');

        Test.stopTest();
    }
}