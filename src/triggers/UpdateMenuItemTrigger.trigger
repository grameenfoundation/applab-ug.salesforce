trigger UpdateMenuItemTrigger on Menu_Item__c (before insert, before update) {

    if (Trigger.isInsert) {
        for (Menu_Item__c item : Trigger.new) {
            item.Last_Modified_Date__c = DateTime.Now();  
        }
    }
    else {
        Map<Id, Menu_Item__c> itemsMap = new Map<Id, Menu_Item__c>();
        
        // put the old items in a map to ease comparison with new values
        for (Menu_Item__c item : Trigger.old) {
            itemsMap.put(item.Id, item);
        }
        
        // compare relevant values so as to determine wether to update the Last_Modified_Date__c
        for (Menu_Item__c newItem : Trigger.new) {
            Menu_Item__c oldItem = itemsMap.get(newItem.Id);
            
            if (newItem.Article_Id__c != oldItem.Article_Id__c ||
                newItem.Label__c != oldItem.Label__c           ||
                newItem.Menu__c != oldItem.Menu__c             ||
                newItem.Parent_Item__c != oldItem.Parent_Item__c) {
                
                newItem.Last_Modified_Date__c = DateTime.Now(); 
            }
        }        
    }
       
}