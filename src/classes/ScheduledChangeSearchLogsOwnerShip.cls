global class ScheduledChangeSearchLogsOwnerShip implements Schedulable {

    public static String cronExpression = '0 0 4 * * ?'; // run every day at 4am

    global void execute(SchedulableContext sc) {
        //gumutindo
        String gumutindoPeople = 'SELECT Id, OwnerId FROM Person__c WHERE OwnerId = \'00570000002fpcCAAQ\'';
        Database.executeBatch(new ChangeSearchLogsOwnerShip(gumutindoPeople), 7);
        //mbugo
        String mbugoPeople = 'SELECT Id, OwnerId FROM Person__c WHERE OwnerId = \'00570000002fsZkAAI\'';
        Database.executeBatch(new ChangeSearchLogsOwnerShip(mbugoPeople), 7);
    }

}