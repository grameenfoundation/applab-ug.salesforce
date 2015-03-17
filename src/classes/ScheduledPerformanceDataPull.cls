global class ScheduledPerformanceDataPull implements Schedulable {

    // CronExpression = Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    public static String cronExpression = '0 0 3 * * ?'; // run every day at 3am

    global void execute(SchedulableContext context){
        // Scheduled Apex must call a method annotated with @future in order to do callouts
        PerformanceDataCollector.collectAndUpdateCkwData(); 
        ErrorLog.flush();
    }
}