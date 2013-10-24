@isTest
private class TestScheduledDailyMetricsUpdate {

    static testMethod void testDailyMetricUpdate() {

        Test.startTest();
        System.debug('START TO TEST THE CRON JOB');
        
        // Schedule the test job
        String jobId = System.schedule('Daily Metric Update', 
            ScheduledDailyMetricsUpdate.cronExpression, new ScheduledDailyMetricsUpdate());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(ScheduledDailyMetricsUpdate.cronExpression, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        System.debug('STOP TESTING THE CRON JOB');

        Test.stopTest();
    }
}