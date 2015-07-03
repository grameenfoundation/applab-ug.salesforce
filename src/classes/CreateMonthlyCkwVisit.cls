public class CreateMonthlyCkwVisit {
    
    public static void createVisit(Date aDay) {
        Date thisDay = aDay;
        Date previousDay = aDay.addDays(-1);
        
        List<Monthly_CKW_Visit__c> visits = new List<Monthly_CKW_Visit__c>();
        
        List<String> contactIds = new List<String>();
        if (thisDay.day() != 1) {
            for (Monthly_CKW_Visit__c thisMonthVisit : [SELECT Id, CKW__c from Monthly_CKW_Visit__c
                  where Visit_Date__c = THIS_MONTH]) {
                if (null != thisMonthVisit) {
                    contactIds.add(thisMonthVisit.CKW__c);
                }
            }
        }
        else {
            for (Monthly_CKW_Visit__c thisMonthVisit : [SELECT Id, CKW__c from Monthly_CKW_Visit__c
                  where Visit_Date__c = LAST_MONTH]) {
                contactIds.add(thisMonthVisit.CKW__c);
            }
        }
        Map<String, CKW_Cluster_Meeting__c> contactMeets = new Map<String, CKW_Cluster_Meeting__c>();
        for (CKW_Cluster_Meeting__c clusterMeet : [Select FO__c, CKW__c, CreatedDate from CKW_Cluster_Meeting__c
            where CreatedDate >=: previousDay and CreatedDate <: thisDay and CKW__c not in:contactIds]) {
            
            if (null != clusterMeet) {
                contactMeets.put(clusterMeet.CKW__c, clusterMeet);
            }
        }
        for (String contactId : contactMeets.keyset()) {
            CKW_Cluster_Meeting__c meet = contactMeets.get(contactId);
            Monthly_CKW_Visit__c visit = new Monthly_CKW_Visit__c();
            visit.FO__c= meet.FO__c;
            visit.CKW__c = contactId;
            visit.Visit_Date__c = date.newinstance(meet.CreatedDate.year(), meet.CreatedDate.month(), meet.CreatedDate.day());
            visits.add(visit);
        }
        insert visits; 
    }
}