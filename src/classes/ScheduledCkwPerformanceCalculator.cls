global class ScheduledCkwPerformanceCalculator implements Schedulable {
    public static String cronExpression = '0 0 5 * * ?'; // run every day at 5 am
    
    global void execute(SchedulableContext sc) {
        // UpdateCkwPerformance.updatePerformance();
        ID batchprocessid = Database.executeBatch(new UpdateCkwPerformanceBatched(), 50);
    }
}