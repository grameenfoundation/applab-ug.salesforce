/**
*
* Copyright (c) 2015 AppLab, Grameen Foundation
*
* Class Updates PHIL Parker/ICON weather Feeds for Obul Search
* Tests are contained in UpdateObulSearchWeatherTest 
**/
public with sharing class UpdateObulSearchWeather {
	public UpdateObulSearchWeather() {
	}

    public static void updateWeather() {
        List<Menu_Item__c> newSearch = [Select Id, Label__c, Parent_Item__r.Label__c from Menu_Item__c where
                                        Menu__r.Label__c='OBUL CKW Search' and Attribution__c !=: null and 
                                        Parent_Item__r.Parent_Item__r.Parent_Item__r.Label__c = 'Daily and 5 day Forecast'];
        
        for(Menu_Item__c item2Update:newSearch){
            String locationName = item2Update.Label__c;
            
            Menu_Item__c ckwSearchItem = [Select Label__c, Content__c, Attribution__c from Menu_Item__c
                                          where Menu__r.Label__c='CKW Search' and Attribution__c != null and 
                                          Parent_Item__r.Parent_Item__r.Parent_Item__r.Label__c = 'Daily and 5 day Forecast'
                                          and Label__c =:locationName LIMIT 1];
 
            item2Update.Content__c = ckwSearchItem.Content__c;
            item2Update.Last_Modified_Date__c = DateTime.Now();
            item2Update.Attribution__c = ckwSearchItem.Attribution__c;
            update item2Update;
        }  
    }
}