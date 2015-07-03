global class ScheduledC3P0FarmerInteractionCalculator implements Schedulable {

    public static String cronExpression = '0 0 5 * * ?'; // run every day at 5am
    
    global void execute(SchedulableContext sc) {
        String farmerQuery =
            'SELECT '                   +
                'Name, '                +
                'Id, '                  +
                'Gender__c, ' +
                'Village__c ' +
            'FROM '                     +
                'Person__c '            +
            'WHERE '                    +
                'Type__c = \'Focus Farmer\' ';
        ID batchprocessid = Database.executeBatch(new CalculateFarmerInteractions(farmerQuery), 10);
    }
}