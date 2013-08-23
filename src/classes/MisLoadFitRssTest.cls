/**
* Copyright (c) 2013 AppLab, Grameen Foundation
*
* Two classes are tested herein;
* MisLoadFitRss in which we test Loading of the RSS XML
* ScheduledMisLoadFitRss where we test the scheduling
* Class List
* MisLoadFitRss,
* ScheduledMisLoadFitRss
*/
@isTest(SeeAllData=true)
public class MisLoadFitRssTest {
    static MisLoadFitRss batchKeywordsExporter = new MisLoadFitRss();
    
    static testmethod void testBatchScheduling(){
    	//test scheduling
    	String cronID = System.scheduleBatch(batchKeywordsExporter, 'Batch Load FIT Prices', 1);
    	CronTrigger ct = [SELECT Id, TimesTriggered, NextFireTime
            				FROM CronTrigger 
            				WHERE Id = :cronID];
    	System.assertEquals(0, ct.TimesTriggered);
		System.debug('Next fire time: ' + ct.NextFireTime);
    }
    
    static testmethod void testBatchDataLoading(){
		Test.startTest();
		Menu__c menu = null;
		Integer result = [SELECT Count() FROM Menu__c WHERE Label__c = 'CKW Search'];
		if(result == 0){
        	menu = new Menu__c(Label__c = 'CKW Search');
        	insert(menu);
		}
		else{
			menu = [SELECT Id, Label__c FROM Menu__c WHERE Label__c = 'CKW Search'];
		}
        Country__c country = new Country__c();
        insert(country);
        Region__c region = new Region__c(Country__c=country.Id, Display_Name__c='North_Region');
        insert(region);
        Market__c market = new Market__c(Market__c='AmuruMarket', Region__c='North_Region');
        insert(market);
		Database.executeBatch(batchKeywordsExporter, 53);		
		Test.stopTest();    	
    }
}