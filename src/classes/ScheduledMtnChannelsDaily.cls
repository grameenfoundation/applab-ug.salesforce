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
          
          // These are to be reset to right regions
          generalEmails.add('kalibbp@mtn.co.ug');
          generalEmails.add('mutiibs@mtn.co.ug');
          generalEmails.add('amijim@mtn.co.ug');
          generalEmails.add('akankwa@mtn.co.ug');
          generalEmails.add('okanyap@mtn.co.ug');
          addresses.put('all', generalEmails);
          
          // uncomment these when it is clear what needs to be done
         /* List<String> easternEmails = new List<String>();
          myEmail.add('odavies@applab.org');
          addresses.put('East', easternEmails );
          
          List<String> centralEmails = new List<String>();
          myEmail.add('odavies@applab.org');
          addresses.put('West', centralEmails);
          
          List<String> centralEmails = new List<String>();
          myEmail.add('odavies@applab.org');
          addresses.put('North', centralEmails);
          
          List<String> centralEmails = new List<String>();
          myEmail.add('odavies@applab.org');
          addresses.put('South', centralEmails); */

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
}