trigger updateMenuItemTrigger on Menu_Item__c (before insert, before update) {
    for (Menu_Item__c item : Trigger.new) {
        item.Last_Modified_Date__c = DateTime.Now();  
    }    
}