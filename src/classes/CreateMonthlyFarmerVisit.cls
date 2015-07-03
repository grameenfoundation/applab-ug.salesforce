public class CreateMonthlyFarmerVisit {


    public static void createVisit(Date aDay) {
        
        Date thisDay = aDay;
        Date previousDay = aDay.addDays(-1);
        List<C3P0_Farmer_Visit__c> visits = new List<C3P0_Farmer_Visit__c>();

        List<String> personIds = new List<String>();
        if (thisDay.day() != 1) {
            for (C3P0_Farmer_Visit__c thisMonthVisit : [SELECT Id, Person__c from C3P0_Farmer_Visit__c
                  where Visit_Date__c = THIS_MONTH]) {
                if (null != thisMonthVisit) {
                    personIds.add(thisMonthVisit.Person__c);
                }
            }
        }
        else {
            for (C3P0_Farmer_Visit__c thisMonthVisit : [SELECT Id, Person__c from C3P0_Farmer_Visit__c
                  where Visit_Date__c = LAST_MONTH]) {
                personIds.add(thisMonthVisit.Person__c);
            }
        }
        Map<String, Search_Log__c> personLogs = new Map<String, Search_Log__c>();
        for (Search_Log__c searchLog : [Select Interviewer_Contact__c, Interviewee__c, CreatedDate from Search_Log__c
            where Interviewer_Contact__c != null and CreatedDate >=: previousDay and CreatedDate <: thisDay and Interviewee__c != null and Interviewee__c not in:personIds]) {
            
            if (null != searchLog) {
                personLogs.put(searchLog.Interviewee__c, searchLog);
            }
        }
        for (String personId : personLogs.keyset()) {
            Search_Log__c searchLog = personLogs.get(personId);
            C3P0_Farmer_Visit__c visit = new C3P0_Farmer_Visit__c();
            visit.Contact__c = searchLog.Interviewer_Contact__c;
            visit.Search_Log__c = searchLog.Id;
            visit.Person__c = personId;
            visit.Visit_Date__c = date.newinstance(searchLog.CreatedDate.year(), searchLog.CreatedDate.month(), searchLog.CreatedDate.day());
            visits.add(visit);
        }
        insert visits;
    }

}