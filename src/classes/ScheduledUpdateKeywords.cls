global class ScheduledUpdateKeywords implements Schedulable {

    // Cron expression => Seconds Hours DayOfMonth DayOfWeek OptionalYear
    public static String cronExpression = '0 30 6 * * ?'; // runs at 6:30 everyday
    
    global void execute(SchedulableContext sc) {
        UpdateKeywords.saveMenuItemsToStaticResource('CKW Search', 'CKWSearch');
    }
}