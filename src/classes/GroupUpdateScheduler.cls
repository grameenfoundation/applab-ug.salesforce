global class GroupUpdateScheduler {

	public static void start(String jobName) {				
		String result = System.schedule('Group Update', ScheduledGroupUpdate.cronExpression, 
			new ScheduledGroupUpdate());
		System.debug('Schedule result = ' + result);
	}
	
	static testMethod void testStart() {
		GroupUpdateScheduler.start('Test Group Update');
	}
}