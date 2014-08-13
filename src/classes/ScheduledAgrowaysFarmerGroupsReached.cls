global class ScheduledAgrowaysFarmerGroupsReached implements Schedulable {
    global void execute(SchedulableContext sc) {
        AgrowaysFarmerGroupsReachedCalculator.calculateFarmerGroupsReached();
    }
}