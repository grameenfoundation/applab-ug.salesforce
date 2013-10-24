global class ScheduledIconWeatherFeedUpdate implements Schedulable{
	// CronExpression = Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
	public static String cronExpression = '0 0 5 * * ?'; // run every day at 5am
	//public static String cronExpression = '0 0 1-23 * * ?'; // run every hour
	global void execute(SchedulableContext sc) {
		
		// Scheduled Apex must call a method annotated with @future in order to do callouts
		IconWeatherFeedUpdater.updateIconWeather();
		ErrorLog.flush();
	}

}