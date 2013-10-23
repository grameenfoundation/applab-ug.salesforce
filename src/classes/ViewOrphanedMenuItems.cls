public with sharing class ViewOrphanedMenuItems {
    public Menu_Item__c[] getOrphanedMenuItems() {
        return [Select Id, Name, Article_Id__c, Position__c, Label__c from Menu_Item__c where (Menu__c = NULL or Menu__c = '') and (Parent_Item__c = NULL or Parent_Item__c = '') order by Position__c ASC, Label__c ASC];
    }
}