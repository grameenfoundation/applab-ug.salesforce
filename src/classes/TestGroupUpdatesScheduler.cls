@isTest
private class TestGroupUpdatesScheduler {

	static testMethod void testGroupUpdate () {

		Test.startTest();
		System.debug('START TO TEST THE CRON JOB');
		
		// Schedule the test job
		String jobId = System.schedule('Group Update', 
			ScheduledGroupUpdate.cronExpression, new ScheduledGroupUpdate());

		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
			FROM CronTrigger WHERE id = :jobId];

		// Verify the expressions are the same
		System.assertEquals(ScheduledGroupUpdate.cronExpression, ct.CronExpression);

		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);
		System.debug('STOP TESTING THE CRON JOB');

		Test.stopTest();
	}
}