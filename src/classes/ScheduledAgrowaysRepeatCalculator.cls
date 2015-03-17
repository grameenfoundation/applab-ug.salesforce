global class ScheduledAgrowaysRepeatCalculator implements Schedulable {
    public static String cronExpression = '0 0 7 * * ?'; // run every day at 7 am

    global void execute(SchedulableContext sc) {
        String farmerQuery =
            'SELECT '                   +
                'Name, '                +
                'Id, '                  +
                'Person__c, '           +
                'Person__r.Gender__c, ' +
                'Person__r.Village__c ' +
            'FROM '                     +
                'Farmer__c '            +
            'WHERE '                    +
                'Person__r.First_Name__c != \'Not Registered\' ' +
                'AND Name LIKE \'U%\' ' +
                ' AND Performance_Date__c = LAST_MONTH' +
                ' AND Registered_By__c IN (SELECT ' +
                ' Person__c FROM Person_Group_Association__c ' +
                'WHERE group__r.Name = \'Agroways VACs\')';

        ID batchprocessid = Database.executeBatch(new AgrowaysRepeatUsageCalculator(farmerQuery));
    }
}