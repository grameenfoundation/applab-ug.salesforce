global class ScheduledMonthlyCkwVisitUpdater implements Schedulable {

    public static String cronExpression = '0 0 4 * * ?'; // run every day at 4am

    global void execute(SchedulableContext sc) {
        CreateMonthlyCkwVisit.createVisit(date.today());
    }

}