/**
 *
 * This is crucial otherwise all logs will belong to ckwadmin
 * Tests in SearchServerTests
 */
global class ChangeSearchLogsOwnerShip implements Database.Batchable<sObject>, Database.Stateful {
    
    global final String query;
    
    global ChangeSearchLogsOwnerShip(String query) {
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Person__c> persons) {
        List<Search_Log__c> ulogs = new List<Search_Log__c>();
        List<String> ids = new List<String>();
        for(Person__c p : persons) {
            ids.add(p.Id);
        }
        List<Search_Log__c> logs = [select Id, Name, OwnerId from Search_Log__c where Interviewer__c IN :ids and CreatedDate = THIS_MONTH and OwnerId != :persons.get(0).OwnerId];
        for(Search_Log__c l : logs) {
            if(l.OwnerId != persons.get(0).OwnerId) {
                l.OwnerId = persons.get(0).OwnerId;
                ulogs.add(l);
            }
        }
        update ulogs;
    }
    
    global void finish(Database.BatchableContext BC) {        
    }
}