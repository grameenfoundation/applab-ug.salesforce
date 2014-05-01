global class MarketPriceSender implements Database.Batchable<sObject> {
    
    global static final String senderName = 'ckw admin';
    global static final String subject = 'Market Price Notification';
    global final String query;
    
    global MarketPriceSender(String baseQuery) {
        query = baseQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Market_Price__c> inputPrices) {
        User sender = [
            SELECT
                Id,
                Name
            FROM
                User
            WHERE
                Name = :senderName
                ];

        Savepoint sp = Database.setSavepoint();
        Boolean rescheduled = false;

        List<Scheduled_Message_Queue__c> messageQueue = new List<Scheduled_Message_Queue__c>();
        for (Market_Price__c marketPrice: inputPrices) {
            //Should select the market price for a distinct commodity and then gett the prices in the
            // different markerts from here
            // 
            //generate the message
            String messageText = generateMessage(marketPrice.Commodity__r.Name);
            List<Id> recipients = new List<Id>();
            recipients = generateRecipients(marketPrice.Commodity__r.Name);
            

                // Send the messages immediately through the relevant gateways
                rescheduled = SendSmsHelpers.sendThroughGateways(
                    SendSmsHelpers.generateMessage(
                        recipients, subject, messageText, sender.Id, sender.Name, false, true, datetime.now(), datetime.now().addDays(1)
                    ), true
                );
            

        }       
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    private String generateMessage(String commodity) {
        String message = 'The price of' + commodity + ' in the different markets is: ';
        for (Market_Price__c marketPrice: [SELECT Commodity__r.Market__r.Name, Name, Commodity__r.Name, Effective_Date__c, Buying__c, Selling_Price__c, CreatedDate FROM Market_Price__c WHERE Market_Price__c.CreatedDate = TODAY AND Commodity__r.Name=: commodity]) {
            message += 'in ' + marketPrice.Commodity__r.Market__r.Name + ': ' + marketPrice.Buying__c + 'KES per 90kg bag,';
        }
        message.removeEnd(',');
        return message;
    }

    private List<Id> generateRecipients(String commodity) {
        List<Id> recipients = new List<Id>();
        for (Ewarehouse_Harvest_Crop__c harvest: [SELECT Ewarehouse_Harvest__r.Ewarehouse_Farmer__r.Ewarehouse_Person__r.Id FROM Ewarehouse_Harvest_Crop__c WHERE Crop__c INCLUDES (: commodity)]) {
            recipients.add(harvest.Ewarehouse_Harvest__r.Ewarehouse_Farmer__r.Ewarehouse_Person__r.Id);
        }
        return recipients;
    }
}