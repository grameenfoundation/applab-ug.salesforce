/**
 *
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 *  Tests are in TestUpdateCkwPerformance
 *  
 */
global class UpdateCkwPerformanceBatched implements Database.batchable<sObject>, Database.Stateful {
    
    global List<C3P0_CKW_Performance__c> ckwMonthlyPerformanceStats = new List<C3P0_CKW_Performance__c>();
        
    global Database.QueryLocator start(Database.BatchableContext BC) {
        User ckwadmin = [Select Id from User where alias = 'ckwadmin'];
        return Database.getQueryLocator('Select Id, Name from Contact where Ownerid = \'' + ckwadmin.id + '\' and Id In (Select gfsurveys__Contact__c from gfsurveys__Mobile_User__c where gfsurveys__Status__c = \'Active\')');
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contacts) {
        updatePerformance(contacts);
    }
    
    global void finish(Database.BatchableContext BC) {
        upsert(ckwMonthlyPerformanceStats);
    }
    
    global void updatePerformance(List<Contact> contacts) {
        
        Map<String, Contact> ckws= new Map<String, Contact>();
        
        for(Contact c : contacts) {
            ckws.put(c.Id, c);
        }
        
        List<Person__c> contactPersons = [Select Contact__c, Gender__c, District_Name__c FROM Person__c where Contact__c in:ckws.keyset()];
        Map<String, Person__c> ckwPersonRecords = new Map<String, Person__c>();
        for (Person__c contactPerson : contactPersons) {
            ckwPersonRecords.put(contactPerson.Contact__c, contactPerson);
        }
        
        Map<String, Integer> ckwClusterMeets = new Map<String, Integer>();
        Map<String, Integer> ckwFarmerSearches = new Map<String, Integer>();
        Map<String, Integer> foCkwClusterMeets = new Map<String, Integer>();
        List<C3P0_CKW_Performance__c> monthlyPerformanceList = new List<C3P0_CKW_Performance__c>();
        for (String contactId : ckws.keyset()) {
            ckwClusterMeets.put(contactId, 0);
            ckwFarmerSearches.put(contactId, 0);
            foCkwClusterMeets.put(contactId, 0);
        }
        System.debug(ckwClusterMeets.size());System.debug(ckwFarmerSearches.size());System.debug(foCkwClusterMeets.size());
        AggregateResult[] farmerMonthlyClusterMeets = new AggregateResult[]{};
        AggregateResult[] farmerSearches = new AggregateResult[]{};
        AggregateResult[] foCkwClusters = new AggregateResult[]{};
        Map<String, C3P0_CKW_Performance__c> ckwMonthlyPerformanceStatsMap = new Map<String, C3P0_CKW_Performance__c>();
        
        if (date.today().day() == 1 || date.today().day() == 2) {
        // Get all unique farmer cluster meetings, searches and fo visits for last month
            farmerMonthlyClusterMeets = [Select Contact__c, count(Focus_Farmer__c) clusters from Farmer_Cluster_Meeting__c where date__c = LAST_MONTH group by Contact__c ];
            //farmerSearches = [Select Contact__c, count(Person__c) searches from C3P0_Farmer_Visit__c where Visit_Date__c = LAST_MONTH group by Contact__c ];

            farmerSearches = [
                SELECT 
                    Interviewer_Contact__c, 
                    COUNT_DISTINCT(Interviewee__c) searches
                FROM 
                    Search_Log__c 
                WHERE 
                    CreatedDate = LAST_MONTH 
                    AND
                        Interviewer_Contact__c IN :ckws.keyset()
                    AND 
                        Self_Search__c = False
                    AND 
                        Group_Search__c = False 
                GROUP BY 
                    Interviewer_Contact__c ];
            
            foCkwClusters = [Select CKW__c, count(FO__c) foCluster from Monthly_CKW_Visit__c where Visit_Date__c = LAST_MONTH group by CKW__c];
            monthlyPerformanceList = [Select Id, 
                                            Contact__c,
                                            Performance_Date__c,
                                            Unique_Farmer_Visits__c, 
                                            Unique_Searches__c,
                                            Visits_to_F0__c
                                        FROM
                                            C3P0_CKW_Performance__c
                                        WHERE
                                            Performance_Date__c = LAST_MONTH
                                        AND
                                            Contact__c in:ckws.keyset()];
        }
        else {
            farmerMonthlyClusterMeets = [Select Contact__c, count(Focus_Farmer__c) clusters from Farmer_Cluster_Meeting__c where date__c = THIS_MONTH and Contact__c in:ckws.keyset() group by Contact__c ];

            //farmerSearches = [Select Contact__c, count(Person__c) searches from C3P0_Farmer_Visit__c where Visit_Date__c = THIS_MONTH and Contact__c in:ckws.keyset() group by Contact__c];
            farmerSearches = [
                SELECT Interviewer_Contact__c, 
                    COUNT_DISTINCT(Interviewee__c) searches
                FROM 
                    Search_Log__c 
                WHERE 
                    CreatedDate = THIS_MONTH
                    AND
                        Interviewer_Contact__c IN :ckws.keyset()
                    AND 
                        Self_Search__c = False
                    AND 
                        Group_Search__c = False 
                GROUP BY 
                    Interviewer_Contact__c ];
            
            foCkwClusters = [Select CKW__c, count(FO__c) foCluster from Monthly_CKW_Visit__c where Visit_Date__c = THIS_MONTH and CKW__c in:ckws.keyset() group by CKW__c];
            monthlyPerformanceList = [Select Id, 
                                            Contact__c,
                                            Performance_Date__c,
                                            Unique_Farmer_Visits__c, 
                                            Unique_Searches__c,
                                            Visits_to_F0__c
                                        FROM
                                            C3P0_CKW_Performance__c
                                        WHERE
                                            Performance_Date__c = THIS_MONTH
                                        AND
                                            Contact__c in:ckws.keyset()];

        }
        //AggregateResult[] result = [Select COUNT_DISTINCT(Interviewee__c) from Search_Log__c where Handset_Submit_Time__c >=: firstDate AND Handset_Submit_Time__c <: secondDate AND Interviewer__r.Full_Name__c = 'John Mutagubya'];
        ckwMonthlyPerformanceStatsMap = new Map<String, C3P0_CKW_Performance__c>();
        for (C3P0_CKW_Performance__c performance : monthlyPerformanceList) {
            ckwMonthlyPerformanceStatsMap.put(performance.Contact__c, performance);
        }
        for (AggregateResult farmerMonthlyClusterMeet : farmerMonthlyClusterMeets) {
            String contactId = (String)farmerMonthlyClusterMeet.get('Contact__c');
            Integer clusterCount = (Integer)farmerMonthlyClusterMeet.get('clusters');
            ckwClusterMeets.put(contactId, clusterCount);
        }

        for (AggregateResult farmerSearch : farmerSearches) {
            String contactId = (String)farmerSearch.get('Interviewer_Contact__c');
            Integer searchCount = (Integer)farmerSearch.get('searches');
            ckwFarmerSearches.put(contactId, searchCount);
        }

        for (AggregateResult foCkwCluster : foCkwClusters) {
            String contactId = (String)foCkwCluster.get('CKW__c');
            Integer foClusterCount = (Integer)foCkwCluster.get('foCluster');
            foCkwClusterMeets.put(contactId, foClusterCount);
        }

        If (ckwMonthlyPerformanceStatsMap.size() == 0) {
            for (String contactId : ckws.keyset()) {
                C3P0_CKW_Performance__c ckwPerformance = new C3P0_CKW_Performance__c();
                ckwPerformance.Contact__c = contactId;
                ckwPerformance.Unique_Farmer_Visits__c = 0;
                ckwPerformance.Unique_Searches__c = 0;
                ckwPerformance.Visits_to_F0__c = 0;
                ckwPerformance.CKW_Gender__c = ckwPersonRecords.get(contactId).Gender__c;
                ckwPerformance.District__c = ckwPersonRecords.get(contactId).District_Name__c;
                if (date.today().day() != 1 && date.today().day() != 2) {
                    ckwPerformance.Performance_Date__c = date.today();
                }
                else {
                    ckwPerformance.Performance_Date__c = date.today().day() == 1 ? date.today().addDays(-1) : date.today().addDays(-2);
                }
                ckwMonthlyPerformanceStatsMap.put(contactid, ckwPerformance);
            }
        }
        
        System.debug('performance map size ='+ckwMonthlyPerformanceStatsMap.size());
        for (String contactId : ckws.keyset()) {
            C3P0_CKW_Performance__c performance = ckwMonthlyPerformanceStatsMap.get(contactId);
            if (performance == null) {
                performance = new C3P0_CKW_Performance__c();
                performance.Contact__c = contactId;
                if (date.today().day() != 1 && date.today().day() != 2) {
                    performance.Performance_Date__c = date.today();
                }
                else {
                    performance.Performance_Date__c = date.today().day() == 1 ? date.today().addDays(-1) : date.today().addDays(-2);
                }
            }
            performance.Unique_Farmer_Visits__c = ckwClusterMeets.get(contactId);
            performance.Unique_Searches__c = ckwFarmerSearches.get(contactId);
            performance.Visits_to_F0__c = foCkwClusterMeets.get(contactId);
            System.debug(performance.Unique_Farmer_Visits__c);
            System.debug(performance.Unique_Searches__c);
            System.debug(performance.Visits_to_F0__c);
            ckwMonthlyPerformanceStats.add(performance);
        }        
    }
}