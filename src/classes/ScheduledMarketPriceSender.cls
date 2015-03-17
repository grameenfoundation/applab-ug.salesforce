global class ScheduledMarketPriceSender implements Schedulable {
    
    // Cron Expression to schedule the job to run at 15 minutes to the top of the hour
    public static String cronExpression = '0 45 1-23 * * ?';
    
    global void execute(SchedulableContext sc) {

        String senderName = 'ckw admin';
        User sender = [SELECT Id, Name FROM User WHERE NAME =:senderName];
        Boolean rescheduled = false;
        String subject = 'Market Price Notification';
        List<Market_Price__c> marketPricesToUpdate = new List<Market_Price__c>();

        //Determine the crops whose market prices have been updated
        for (AggregateResult results: [SELECT Commodity__r.Name FROM Market_Price__c WHERE Notification_Sent__c = false GROUP BY Commodity__r.Name]) {
            String messageText = EwarehouseHelpers.generateMessage((String)results.get('Name'));
            List<Id> recipients = new List<Id>();
            recipients = EwarehouseHelpers.generateRecipients((String)results.get('Name'));
            rescheduled = SendSmsHelpers.sendThroughGateways(
                    SendSmsHelpers.generateMessage(
                        recipients, subject, messageText, sender.Id, sender.Name, false, true, datetime.now(), datetime.now().addDays(1)
                    ), false
                );
            marketPricesToUpdate.addAll(EwarehouseHelpers.setNotificationFlag((String)results.get('Name')));
        }
        
        update marketPricesToUpdate;
    }
}