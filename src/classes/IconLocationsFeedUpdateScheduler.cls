public with sharing class IconLocationsFeedUpdateScheduler {

	public static void start(String jobName) {				
		String result = System.schedule(jobName, ScheduledIconLocationsFeedUpdate.cronExpression, 
			new ScheduledIconLocationsFeedUpdate());
		System.debug('Schedule result = ' + result);
	}
	
	static testMethod void testStart() {
		IconLocationsFeedUpdateScheduler.start('Icon Locations Feed Update');
	}
}