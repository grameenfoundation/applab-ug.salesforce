@isTest
private class TestScheduledPerformanceDataPull {

	// This test is somewhat trivial. We can't actually validate in the test that the
	// scheduled script is doing its job because it calls a callout, which can't be
	// executed from a testMethod.
    static testMethod void test() {
    	Test.startTest();
    	    	
		// Schedule the test job  
		//TODO: Consider Reverting this
		    
		String jobId = System.schedule('testScheduledPerformanceDataPull',
			ScheduledPerformanceDataPull.cronExpression, new ScheduledPerformanceDataPull());
		
		// Get the information from the CronTrigger API object  
		CronTrigger cronTrigger = [SELECT id, CronExpression, TimesTriggered, NextFireTime
									FROM CronTrigger WHERE id = :jobId];
		// Verify the expressions are the same  
		System.assertEquals(ScheduledPerformanceDataPull.cronExpression, cronTrigger.CronExpression);
		// Verify the job has not run  
    	System.assertEquals(0, cronTrigger.TimesTriggered);
    	
    	Test.stopTest();    	
	}
}