@isTest
private class TestScheduledMarketPriceSender {
	
	@isTest static void test() {
		Test.startTest();

		String jobId = '';

		if(Test.isRunningTest() && Limits.getFutureCalls() >= Limits.getLimitFutureCalls()) {
			system.debug(LoggingLevel.Error, 'Future method limit reached. Skipping the tests');
		} else {
			jobId = System.schedule('testScheduledMarketPriceSender',
				ScheduledMarketPriceSender.cronExpression, new ScheduledMarketPriceSender());
		}

		// Get the information from the CronTrigger API object
		CronTrigger cronTrigger = [SELECT id, CronExpression, TimesTriggered, NextFireTime 
									FROM CronTrigger WHERE id = :jobId];
		// Verify the epxressions are the same
		System.assertEquals(ScheduledMarketPriceSender.cronExpression, cronTrigger.CronExpression);

		//Verify the job has not run
		System.assertEquals(0, cronTrigger.TimesTriggered);
	}
	
}