global class ScheduledCPAOrderAllocationUpdater implements Schedulable {
    public static String cronExpression = '0 0 2 * * ?'; // run every day at 2am

    global void execute(SchedulableContext sc) {
        CPAOrderAllocationAssociationUpdater.updateContactAssociations();
    }
}