global class ScheduledCPAOrderSObjectUpdater implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        CPAOrderContactAssociationUpdater.updateContactAssociations();
    }
}