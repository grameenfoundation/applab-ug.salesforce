global class ScheduledCalculateUniqueOneOnOnes implements Schedulable {

    public static String cronExpression = '0 0 4 * * ?'; // run every day at 4am

    global void execute(SchedulableContext sc) {
        User ckwadmin = [Select Id from User where alias = 'ckwadmin'];
        String query = 
            'SELECT '                +
                'Id,'                +
                'Name '              +
            'FROM '                  +
                'Contact '           +
            'WHERE '                 +
                'OwnerId = \'' + ckwadmin.Id + '\' '     + 
                'AND Id In (select gfsurveys__Contact__c from gfsurveys__Mobile_User__c where gfsurveys__Status__c = \'Active\')';
            
        ID batchprocessid = Database.executeBatch(new CalculateUniqueOneOnOnes(query), 10);
    }

}