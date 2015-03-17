global class ScheduledRepeatUsageCalculator implements Schedulable {
    public static String cronExpression = '0 0 1 * * ?'; // run every day at 1am

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
                ' AND Performance_Date__c = LAST_N_DAYS:365';

        ID batchprocessid = Database.executeBatch(new CkwRepeatUsageCalculator(farmerQuery));
    }
}