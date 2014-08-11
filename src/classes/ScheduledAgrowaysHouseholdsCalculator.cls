global class ScheduledAgrowaysHouseholdsCalculator implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        AgrowaysHouseholdsReachedCalculator.calculateHouseholdsReached();
    }
}