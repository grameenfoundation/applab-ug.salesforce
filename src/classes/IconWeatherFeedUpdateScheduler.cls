global class IconWeatherFeedUpdateScheduler {
	public static void start(String jobName) {				
		String result = System.schedule(jobName, ScheduledIconWeatherFeedUpdate.cronExpression, 
			new ScheduledIconWeatherFeedUpdate());
		System.debug('Schedule result = ' + result);
	}
	
	static testMethod void testStart() {
		IconWeatherFeedUpdateScheduler.start('Test Icon Weather Feed Update');
	}
}