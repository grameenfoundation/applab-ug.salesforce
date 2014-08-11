global class ScheduledAgrowaysFarmerGroupsReached {
    global void execute(SchedulableContext sc) {
        AgrowaysFarmerGroupsReachedCalculator.calculateFarmerGroupsReached();
    }
}