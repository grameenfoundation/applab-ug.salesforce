global class ScheduledUpdateKeywords implements Schedulable {

    // Cron expression => Seconds Hours DayOfMonth DayOfWeek OptionalYear
    public static String cronExpression = '0 30 6 * * ?'; // runs at 6:30 everyday
    
    global void execute(SchedulableContext sc) {
        UpdateKeywords.saveMenuItemsToStaticResource('CKW Search', 'CKWSearch');
    }
    
    static testMethod void myScheduledClass() {

        Test.startTest();
        
        String CRON_EXP = '0 0 0 1 1 ? 2035';  
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new ScheduledUpdateKeywords());

        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2035-01-01 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
}