global class CKWFarmerCountByQuarter implements Database.Batchable<sObject> {

    global final String query;
    global static Double farmerCount = 0;
    global CKWFarmerCountByQuarter(String farmerQuery) {
        query = farmerQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Farmer__c> farmers) {
        
        farmerCount = farmerCount + farmers.size();
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Farmer count for that quarter is '+farmerCount);
    }
}