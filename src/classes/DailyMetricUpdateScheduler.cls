global class DailyMetricUpdateScheduler {

    public static void start(String jobName) {
        String result = System.schedule('Daily Metric Update', ScheduledDailyMetricsUpdate.cronExpression, 
            new ScheduledDailyMetricsUpdate());
        System.debug('Schedule result = ' + result);
    }

    static testMethod void testStart() {
        DailyMetricUpdateScheduler.start('Test Daily Metric Update');
    }
}