/**
 *
 * Copyright (c) 2015 AppLab, Grameen Foundation
 *
 * Tests for this class are in CompileGapsDiscussionsTests class
 **/
global class CompileGapsDiscussionsScheduler implements Schedulable {

    public static String cronExpression = '0 0 4 * * ?'; // run every day at 4am
    
    global void execute(SchedulableContext sc) {
    
        String banana = date.today().day() == 1 ?        
            'SELECT '                                        +
                'Id,'                                        +
                'What_GAPs_were_discussed_at_the_meeting__c,'+
                'Meeting_Date__c '                           +
            'FROM '                                          +
                'Banana_Cluster_Meeting__c '                 +
            'WHERE '                                         +
                'Meeting_Date__c = LAST_MONTH ' :
            'SELECT '                                        +
                'Id,'                                        +
                'What_GAPs_were_discussed_at_the_meeting__c,'+
                'Meeting_Date__c '                           +
            'FROM '                                          +
                'Banana_Cluster_Meeting__c '                 +
            'WHERE '                                         +
                'Meeting_Date__c = THIS_MONTH ';       
                
        String coffee = date.today().day() == 1 ?        
            'SELECT '                                        +
                'Id,'                                        +
                'What_GAPs_were_discussed_at_the_meeting__c,'+
                'Please_add_the_date_of_the_meeting__c  '    +
            'FROM '                                          +
                'Coffee_Cluster_Meeting__c '                 +
            'WHERE '                                         +
                'Please_add_the_date_of_the_meeting__c  = LAST_MONTH ' :
            'SELECT '                                        +
                'Id,'                                        +
                'What_GAPs_were_discussed_at_the_meeting__c,'+
                'Please_add_the_date_of_the_meeting__c  '    +
            'FROM '                                          +
                'Coffee_Cluster_Meeting__c '                 +
            'WHERE '                                         +
                'Please_add_the_date_of_the_meeting__c  = THIS_MONTH ';                   
        
        String maize = date.today().day() == 1 ?        
            'SELECT '                                        +
                'Id,'                                        +
                'What_GAPs_were_discussed_at_the_meeting__c,'+
                'Meeting_Date__c '                           +
            'FROM '                                          +
                'Maize_Cluster_Meeting__c '                  +
            'WHERE '                                         +
                'Meeting_Date__c = LAST_MONTH ' :
            'SELECT '                                        +
                'Id,'                                        +
                'What_GAPs_were_discussed_at_the_meeting__c,'+
                'Meeting_Date__c  '                          +
            'FROM '                                          +
                'Maize_Cluster_Meeting__c '                  +
            'WHERE '                                         +
                'Meeting_Date__c  = THIS_MONTH ';
                        
        Database.executeBatch(new CompileGapsDiscussionsFarmerMeetings(banana, 'Banana'), 50);
        Database.executeBatch(new CompileGapsDiscussionsFarmerMeetings(coffee, 'Coffee'), 50);
        Database.executeBatch(new CompileGapsDiscussionsFarmerMeetings(maize, 'Maize'), 50);
    }
}