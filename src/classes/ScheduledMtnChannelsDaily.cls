global class ScheduledMtnChannelsDaily implements Schedulable {

     // CronExpression = Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
     // Run every day at 5:30pm
     public static String cronExpression = '0 30 17 * * ?';
     
     global void execute(SchedulableContext sc) {
          Map<String, List<String>> addresses = new Map<String, List<String>>();
          Date startDate = Date.today();
          List<String> generalEmails= new List<String>();
          // These are general 
          generalEmails.add('machoj@mtn.co.ug');
          generalEmails.add('musenzc@mtn.co.ug');
          generalEmails.add('mwesigj@mtn.co.ug');
          generalEmails.add('kwetonj@mtn.co.ug');
          generalEmails.add('mutiibs@mtn.co.ug');
          
          // Grameen emails to send
          generalEmails.add('jolooonyango@grameenfoundation.org');
          generalEmails.add('ekamara@grameenfoundation.org');
          generalEmails.add('fbyarugaba@grameenfoundation.org');
          addresses.put('all', generalEmails);
          
          List<String> eastEmails= new List<String>();
          eastEmails.add('okanyap@mtn.co.ug');
          addresses.put('Eastern', eastEmails);
          
          List<String> westEmails= new List<String>();
          westEmails.add('amijim@mtn.co.ug');
          addresses.put('Western', westEmails);
          
          List<String> northEmails= new List<String>();
          northEmails.add('kalibbp@mtn.co.ug');
          addresses.put('Northern', northEmails);
          
          List<String> southEmails= new List<String>();
          southEmails.add('mutiibs@mtn.co.ug');
          addresses.put('South Western', southEmails);
          
          List<String> centralEmails= new List<String>();
          centralEmails.add('akankwa@mtn.co.ug');
          addresses.put('Central', centralEmails);          

          List<String> personIds = new List<String>();
          Person__c[] people = 
              [SELECT 
                  Id 
              FROM 
                  Person__c 
              WHERE 
                  Type__c = 'MTN Channel Staff' 
                AND 
                  ID IN 
                  (SELECT 
                       Person__c 
                   FROM 
                       MTN_Channels_Staff__c 
                   WHERE 
                       Active__c = true)];
                       
        for (Person__c person : people) {
            personIds.add(person.Id);
        }
        MtnChannelsEmailHelpers.generateDailyEmails(addresses, personIds, startDate);
     }
     
    static testMethod void myScheduledClass() {

        Test.startTest();
        
        String CRON_EXP = '0 0 0 1 1 ? 2035';  
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new ScheduledMtnChannelsDaily());

        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2035-01-01 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
}