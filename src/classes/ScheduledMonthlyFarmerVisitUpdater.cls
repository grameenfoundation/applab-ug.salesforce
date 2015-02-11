global class ScheduledMonthlyFarmerVisitUpdater implements Schedulable {

    public static String cronExpression = '0 0 3 * * ?'; // run every day at 3am

    global void execute(SchedulableContext sc) {
        CreateMonthlyFarmerVisit.createVisit(date.today());
    }

}