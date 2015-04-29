/**
* Copyright (c) 2015 AppLab, Grameen Foundation
*
* Two classes are tested herein for 3.0 search;
* MisLoadFitRss3_o in which we test Loading of the RSS XML
* ScheduledMisLoadFitRss3_o where we test the scheduling
* Class List
* MisLoadFitRss3_o,
* ScheduledMisLoadFitRss3_o
*/
@isTest
private class MisLoadFitRss3_oTest {

    static MisLoadFitRss3_o batchKeywordsExporter = new MisLoadFitRss3_o();
    /**
    *   tests scheduling of the data loading operation*/

    static testmethod void testBatchScheduling() {
        //test scheduling
        String cronID = System.scheduleBatch(batchKeywordsExporter, 'Batch Load FIT Prices', 1);
        CronTrigger ct = [SELECT Id, TimesTriggered, NextFireTime
                          FROM CronTrigger
                          WHERE Id = :cronID];
        System.assertEquals(0, ct.TimesTriggered);
        System.debug('Next fire time: ' + ct.NextFireTime);
    }

    static testmethod void testBatchDataLoading() {
        Test.startTest();
        Menu__c menu = null;
        Integer result = [SELECT Count() FROM Menu__c WHERE Label__c = 'CKW 3.0 Search'];
        if (result == 0) {
            menu = new Menu__c(Label__c = 'CKW 3.0 Search');
            insert(menu);
        } else {
            menu = [SELECT Id, Label__c FROM Menu__c WHERE Label__c = 'CKW 3.0 Search'];
        }
        Country__c country = new Country__c();
        insert(country);
        Region__c region = new Region__c(Country__c = country.Id, Display_Name__c = 'North_Region');
        insert(region);
        Market__c market = new Market__c(Market__c = 'AmuruMarket', Region__c = 'North_Region');
        insert(market);
        Database.executeBatch(batchKeywordsExporter, 53);
        System.debug(LoggingLevel.DEBUG, 'New Menu Label ' + menu.Label__c);
        Test.stopTest();
    }
}