global class ScheduledIconWeatherFeedUpdate implements Schedulable{
	// CronExpression = Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
	public static String cronExpression = '0 0 5 * * ?'; // run every day at 5am
	//public static String cronExpression = '0 0 1-23 * * ?'; // run every hour
	global void execute(SchedulableContext sc) {
		
		// Scheduled Apex must call a method annotated with @future in order to do callouts
		IconWeatherFeedUpdater.updateIconWeather();
		ErrorLog.flush();
	}

    static testMethod void myScheduledClass() {

        Test.startTest();
        
        String CRON_EXP = '0 0 0 1 1 ? 2035';  
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new ScheduledIconWeatherFeedUpdate());

        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2035-01-01 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
}