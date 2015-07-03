global class ScheduledCreateMonthlyFarmerCluster implements Schedulable {

    public static String cronExpression = '0 0 4 * * ?'; // run every day at 4am

    global void execute(SchedulableContext sc) {
        CreateMonthlyFarmerCluster.createVisit(date.today());
    }

}