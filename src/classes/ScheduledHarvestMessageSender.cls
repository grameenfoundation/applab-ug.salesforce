global class ScheduledHarvestMessageSender implements Schedulable {
    
    // Cron Expression to schedule the job to run at 15 minutes to the top of the hour
    public static String cronExpression = '0 45 1-23 * * ?';
    
    global void execute(SchedulableContext sc) {
        String queryString = 'SELECT ' +
            'Id,' +
            'Ewarehouse_Farmer__r.Id,' +
            'Ewarehouse_Farmer__r.Auto_Generated_Farmer_ID__c,' +
            'Ewarehouse_Farmer__r.Contact__r.FirstName,' +
            'Ewarehouse_Farmer__r.Contact__r.LastName,' +
            'Ewarehouse_Farmer__r.Contact__r.MobilePhone,' +
            'Ewarehouse_Farmer__r.Ewarehouse_Person__r.Id, ' +
            'Harvest_Date__c, ' +
            'Beans_Harvested__c,' +
            'Maize_Harvested__c,' +
            'Cow_Peas_Harvested__c,' +
            'Black_Beans_Harvested__c, ' +
            'Green_Grams_Harvested__c, ' +
            'Pigeon_Peas_Harvested__c ' +
        'FROM ' +
            ' Ewarehouse_Harvest__c ' +
        ' WHERE ' +
            'Notification_Sent__c = false'; 
        ID batchProcessId = Database.executeBatch(new HarvestMessageSender(queryString), 50);
    }
}