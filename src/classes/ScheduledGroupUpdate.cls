global class ScheduledGroupUpdate implements Schedulable {

	// CronExpression = Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
	public static String cronExpression = '0 0 2 * * ?'; // run every day at 2am

	global void execute(SchedulableContext sc) {
		
		// Scheduled Apex must call a method annotated with @future in order to do callouts
		CKWGroups.markGroupsForUpdate();	
		ErrorLog.flush();
	}
}