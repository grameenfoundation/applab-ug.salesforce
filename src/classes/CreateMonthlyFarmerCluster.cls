public class CreateMonthlyFarmerCluster {
    
    public static void createVisit(Date aDay) {
        Date thisDay = aDay;
        Date previousDay = aDay.addDays(-1);
        
        List<Farmer_Cluster_Meeting__c> meets = new List<Farmer_Cluster_Meeting__c>();
        
        List<String> focusFarmerIds = new List<String>();
        if (thisDay.day() != 1) {
            for (Farmer_Cluster_Meeting__c thisMonthVisit : [SELECT Id, Focus_Farmer__c from Farmer_Cluster_Meeting__c
                  where Date__c = THIS_MONTH]) {
                if (null != thisMonthVisit) {
                    focusFarmerIds.add(thisMonthVisit.Focus_Farmer__c);
                }
            }
        }
        else {
            for (Farmer_Cluster_Meeting__c thisMonthVisit : [SELECT Id, Focus_Farmer__c from Farmer_Cluster_Meeting__c
                  where Date__c = LAST_MONTH]) {
                focusFarmerIds.add(thisMonthVisit.Focus_Farmer__c);
            }
        }
        Map<String, String> focusFarmerMeets = new Map<String, String>();

        // Get Banana Cluster Meeting info
        for (Banana_Cluster_Meeting__c clusterMeet : [Select Contact__c, Banana_Farmer__r.Focus_Farmer__c, CreatedDate from Banana_Cluster_Meeting__c
            where CreatedDate >=: previousDay and CreatedDate <: thisDay and Banana_Farmer__r.Focus_Farmer__c not in: focusFarmerIds]) {
            
            if (null != clusterMeet) {
                focusFarmerMeets.put(clusterMeet.Banana_Farmer__r.Focus_Farmer__c, clusterMeet.Contact__c);
            }
        }

        // Get Coffee Cluster Meeting Info
        for (Coffee_Cluster_Meeting__c clusterMeet : [Select Contact__c, Coffee_Farmer__r.Focus_Farmer__c, CreatedDate from Coffee_Cluster_Meeting__c
            where CreatedDate >=: previousDay and CreatedDate <: thisDay and Coffee_Farmer__r.Focus_Farmer__c not in: focusFarmerIds]) {
            
            if (null != clusterMeet) {
                focusFarmerMeets.put(clusterMeet.Coffee_Farmer__r.Focus_Farmer__c, clusterMeet.Contact__c);
            }
        }

        // Get Maize Cluster Meeting info
        for (Maize_Cluster_Meeting__c clusterMeet : [Select Contact__c, Maize_Farmer__r.Focus_Farmer__c, CreatedDate from Maize_Cluster_Meeting__c
            where CreatedDate >=: previousDay and CreatedDate <: thisDay and Maize_Farmer__r.Focus_Farmer__c not in: focusFarmerIds]) {
            
            if (null != clusterMeet) {
                focusFarmerMeets.put(clusterMeet.Maize_Farmer__r.Focus_Farmer__c, clusterMeet.Contact__c);
            }
        }
        for (String focusFarmer : focusFarmerMeets.keyset()) {
            String contactId = focusFarmerMeets.get(focusFarmer);
            Farmer_Cluster_Meeting__c meet = new Farmer_Cluster_Meeting__c();
            meet.Contact__c= contactId;
            meet.Focus_Farmer__c = focusFarmer;
            meet.Date__c = previousDay;
            meets.add(meet);
        }
        insert meets; 
    }
}