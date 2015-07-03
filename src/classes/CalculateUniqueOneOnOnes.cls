/**
 *
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 *  Calculates unique farmers a CKW has interacted (through cluster meetings and searches) with in a month and updates the C3P0_CKW_Performance__c object
 *  It does not create performace records in case they dont exists. For this reason, it would be best it runs
 *  after the ScheduledCkwPerformanceCalculator has run
 *
 *  Test methods are in the TestCalculateFarmerInteractions class
 **/
global class CalculateUniqueOneOnOnes implements Database.batchable<sObject> {
    
    String query;
    global Integer day = date.today().day();
    
    global CalculateUniqueOneOnOnes(String query) {
        this.query = query;
    }
       
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
    
        List<C3P0_CKW_Performance__c> performance = new List<C3P0_CKW_Performance__c>();
        Map<String, C3P0_CKW_Performance__c> contactMap = new Map<String, C3P0_CKW_Performance__c>();
        List<C3P0_CKW_Performance__c> updates = new List<C3P0_CKW_Performance__c>();
        
        if (day == 1) {
            performance = [
                Select 
                    Id, 
                    Contact__c,
                    Contact__r.Id,
                    Performance_Date__c,
                    Unique_Farmer_Visits__c, 
                    Unique_Searches__c,
                    Visits_to_F0__c,
                    Unique_One_to_One__c
                FROM
                    C3P0_CKW_Performance__c
                WHERE
                    Performance_Date__c = LAST_MONTH
                AND
                    Contact__c in:scope
            ];
            for(C3P0_CKW_Performance__c perf : performance) {
                contactMap.put(perf.Contact__r.Id, perf);
            }
            
            for(Contact contact : scope) {
                //mettings
                Set<String> uniquePersons = new Set<String>();
                List<Farmer_Cluster_Meeting__c> meetings = [SELECT Focus_Farmer__c, Focus_Farmer__r.Person__r.Id FROM Farmer_Cluster_Meeting__c WHERE Date__c = LAST_MONTH AND Contact__c = :contact.Id];
                for(Farmer_Cluster_Meeting__c meet : meetings) {
                    uniquePersons.add(meet.Focus_Farmer__r.Person__r.Id);
                }
                //searches
                List<C3P0_Farmer_Visit__c> searches = [SELECT Person__c, Person__r.Id, Person__r.Contact__c FROM C3P0_Farmer_Visit__c WHERE Visit_Date__c = LAST_MONTH AND Contact__c = :contact.Id];
                for(C3P0_Farmer_Visit__c search : searches) {
                    if(!String.valueOf(contact.Id).equals(search.Person__r.Contact__c)) {
                        uniquePersons.add(search.Person__r.Id);
                    }
                }
                //fo visit
                List<Monthly_CKW_Visit__c> visits = [SELECT CKW__c, FO__c FROM Monthly_CKW_Visit__c WHERE Visit_Date__c = LAST_MONTH AND CKW__c =:contact.Id];               
                C3P0_CKW_Performance__c perform = contactMap.get(contact.Id);
                if(perform != null) {
                    perform.Unique_One_to_One__c = uniquePersons.size();
                    perform.Unique_One_to_One__c = visits.size() > 0 ? perform.Unique_One_to_One__c + 1 : perform.Unique_One_to_One__c;
                    updates.add(perform);
                }
            }
        } else {
            performance = [
                Select 
                    Id, 
                    Contact__c,
                    Contact__r.Id,
                    Performance_Date__c,
                    Unique_Farmer_Visits__c, 
                    Unique_Searches__c,
                    Visits_to_F0__c,
                    Unique_One_to_One__c
                FROM
                    C3P0_CKW_Performance__c
                WHERE
                    Performance_Date__c = THIS_MONTH
                AND
                    Contact__c in:scope
            ];
            for(C3P0_CKW_Performance__c perf : performance) {
                contactMap.put(perf.Contact__r.Id, perf);
            }
            
            for(Contact contact : scope) {
                //mettings
                Set<String> uniquePersons = new Set<String>();
                List<Farmer_Cluster_Meeting__c> meetings = [SELECT Focus_Farmer__c, Focus_Farmer__r.Person__r.Id FROM Farmer_Cluster_Meeting__c WHERE Date__c = THIS_MONTH AND Contact__c = :contact.Id];
                for(Farmer_Cluster_Meeting__c meet : meetings) {
                    uniquePersons.add(meet.Focus_Farmer__r.Person__r.Id);
                }
                //searches
                List<C3P0_Farmer_Visit__c> searches = [SELECT Person__c, Person__r.Contact__c FROM C3P0_Farmer_Visit__c WHERE Visit_Date__c = THIS_MONTH AND Contact__c = :contact.Id];
                for(C3P0_Farmer_Visit__c search : searches) {
                    if(!String.valueOf(contact.Id).equals(search.Person__r.Contact__c)) {
                        uniquePersons.add(search.Person__c);
                    }
                }
                //fo visit
                List<Monthly_CKW_Visit__c> visits = [SELECT CKW__c, FO__c FROM Monthly_CKW_Visit__c WHERE Visit_Date__c = THIS_MONTH AND CKW__c =:contact.Id];               
                C3P0_CKW_Performance__c perform = contactMap.get(contact.Id);
                if(perform != null) {
                    perform.Unique_One_to_One__c = uniquePersons.size();
                    perform.Unique_One_to_One__c = visits.size() > 0 ? perform.Unique_One_to_One__c + 1 : perform.Unique_One_to_One__c;
                    updates.add(perform);
                }
            }        
        }
        update updates;
    }

    global void finish(Database.BatchableContext BC) {
    }
}