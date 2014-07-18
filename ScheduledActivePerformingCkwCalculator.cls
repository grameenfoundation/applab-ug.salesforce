global class ScheduledActivePerformingCkwCalculator implements Schedulable {
    public static String cronExpression = '0 0 7 * * ?'; // run every day at 7 am
    
    global void execute(SchedulableContext sc) {
        ActivePerformingCkwCalculator.calculateMonthlyRepeatUsage();
    }
}