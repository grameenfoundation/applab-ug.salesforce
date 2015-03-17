public class EwarehouseHelpers {

    public static String generateMessage(String commodity) {
        String message = 'The price of ' + commodity.uncapitalize() + ' in the different markets is: ';
        for (Market_Price__c marketPrice: [SELECT Commodity__r.Market__r.Name, Name, Commodity__r.Name, Effective_Date__c, Buying__c, Selling_Price__c, CreatedDate FROM Market_Price__c WHERE Market_Price__c.Notification_Sent__c = false AND Commodity__r.Name=: commodity]) {
            message += 'IN ' + marketPrice.Commodity__r.Market__r.Name + '- ' + marketPrice.Buying__c + 'KES per 90kg bag,';
        }
        message = message.trim();
        message = message.removeEnd(',');
        return message;
    }

    public static List<Id> generateRecipients(String commodity) {
        List<Id> recipients = new List<Id>();
        for (Ewarehouse_Harvest_Crop__c harvest: [SELECT Ewarehouse_Harvest__r.Ewarehouse_Farmer__r.Ewarehouse_Person__r.Id FROM Ewarehouse_Harvest_Crop__c WHERE Crop__c INCLUDES(:commodity)]) {
            recipients.add(harvest.Ewarehouse_Harvest__r.Ewarehouse_Farmer__r.Ewarehouse_Person__r.Id);
        }
        return recipients;
    }
    
    public static List<Market_Price__c> setNotificationFlag(String commodity) {
        List<Market_Price__c> marketPricesToUpdate = new List<Market_Price__c>();
        for (Market_Price__c marketPrice: [SELECT Id, Notification_Sent__c FROM Market_Price__c WHERE Market_Price__c.Notification_Sent__c = false AND Commodity__r.Name=: commodity]) {
            marketPrice.Notification_Sent__c = true;
            marketPricesToUpdate.add(marketPrice);
        }
        return marketPricesToUpdate;
    }
}