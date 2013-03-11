global class ScheduledLACFarmerRegistrationHandler implements Schedulable {
 
   	// CronExpression = Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
     public static String cronExpression = '0 0 1-23 * * ?'; // run every hour, daily

     global void execute(SchedulableContext sc) {
     	LACFarmerRegistrationHandler handler = new LACFarmerRegistrationHandler();
     	Database.executeBatch(handler);
        ErrorLog.flush();
     }
}