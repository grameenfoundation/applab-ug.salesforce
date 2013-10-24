global class PerformanceDataPullScheduler {
	
	public static void start(String jobName) {				
		String result = System.schedule(jobName, ScheduledPerformanceDataPull.cronExpression, 
			new ScheduledPerformanceDataPull());
		System.debug('Schedule result = ' + result);
	}
	
	static testMethod void testStart() {
		PerformanceDataPullScheduler.start('Test Performance Data Update');
	}

}