global class ScheduledMessageSender implements Schedulable {
 
   // CronExpression = Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
     public static String cronExpression = '0 0 1-23 * * ?'; // run every hour, daily

     global void execute(SchedulableContext sc) {

        DateTime startTime = DateTime.now();
        String queryString = 
        	'SELECT ' 											+
                'Id, ' 											+
                'Group__c, ' 									+
                'Person__c, ' 									+
                'Person__r.First_Name__c, ' 					+
                'Person__r.Middle_Name__c, ' 					+
                'Person__r.Last_Name__c, ' 						+
                'Person__r.Mobile_Number__c, ' 					+
                'Person__r.Country__r.ISO_Standard_Code__c, ' 	+
                'Message__c, ' 									+
                'Sender__c, ' 									+
                'Sender__r.Name, ' 								+
                'Subject__c, ' 									+
                'Send_Date_Time__c, ' 							+
                'Expiration_Date__c, ' 							+
                'Send_Via_Pulse__c, ' 							+
                'Category__c, ' 								+
                'Send_Via_Sms__c ' 								+
            'FROM ' 											+
                'Scheduled_Message_Queue__c ' 					+
            'WHERE ' 											+
                'Send_Date_Time__c <= ' + MetricHelpers.convertDateTimeToString(startTime, false);
        ID batchprocessid = Database.executeBatch(new SendSMS(queryString, startTime), 10);
        //Message.sendScheduledMessages();
        //ErorLog.flush();r
     }
}