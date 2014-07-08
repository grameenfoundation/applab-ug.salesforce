public with sharing class UpdateAgrowaysWeather {

    public static void updateWeather() {
        List<Menu_Item__c> agroways = [Select Id, Label__c, Parent_Item__r.Label__c from Menu_Item__c where 
                                    Menu__r.Label__c='Agroways' and Attribution__c !=: null and 
                                    Parent_Item__r.Parent_Item__r.Parent_Item__r.Label__c = 'Daily and 5 day forecast'];
        List<String> locationNames = new List<String>();
        Map<String, Menu_Item__c> agrowaysMenuItems = new Map<String, Menu_Item__c>();
        for (Menu_Item__c agroway : agroways) {
            locationNames.add(agroway.Label__c);
            agrowaysMenuItems.put(agroway.Label__c, agroway);
        }
        List<Menu_Item__c> ckwSearchItems = [Select Label__c, Content__c, Attribution__c from Menu_Item__c 
                                        where Menu__r.Label__c='CKW Search' and Attribution__c != null and 
                                        Parent_Item__r.Parent_Item__r.Parent_Item__r.Label__c = 'Daily and 5 day Forecast'
                                        and Label__c in: locationNames];
        
        List<Menu_Item__c> agrowaysItems2Update = new List<Menu_Item__c>();                             
        for (Menu_Item__c ckwSearchItem : ckwSearchItems) {
            Menu_Item__c menuItem = agrowaysMenuItems.get(ckwSearchItem.Label__c);
            if (null != menuItem) {
                menuItem.Attribution__c = ckwSearchItem.Attribution__c;
                menuItem.Content__c = ckwSearchItem.Content__c;
                menuItem.Last_Modified_Date__c = datetime.now();
                agrowaysItems2Update.add(menuItem);
            }
        }
        if (agrowaysItems2Update.size() > 0) {
            update agrowaysItems2Update;
        }
    }
}