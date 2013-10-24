public with sharing class MenuManagement { 
    public Menu__c currentMenu {get; set;}
    
    public MenuManagement(ApexPages.StandardController controller) {
        this.currentMenu = this.loadCurrentMenu();
    }
    
    public MenuManagement() {
        this.currentMenu = this.loadCurrentMenu();
    }
    
    public Menu_Item__c[] getTopLevelMenuItems() {
        return [Select Id, Name, Article_Id__c, Content__c, Position__c, Label__c, Attribution__c from Menu_Item__c where Menu__c = :System.currentPageReference().getParameters().get('id') and (Parent_Item__c = NULL or Parent_Item__c = '') order by Position__c ASC, Label__c ASC];
    }
    
    private Menu__c loadCurrentMenu() {
        return [Select Id, Name from Menu__c where Id = :System.currentPageReference().getParameters().get('id') limit 1];
    }
    
    static testMethod void testMenuManagement() {
        Menu__c testMenu = new Menu__c();
        testMenu.Label__c = 'test';
        database.insert(testMenu);
        
        Menu_Item__c testItem = new Menu_Item__c();
        testItem.Label__c = 'test';
        testItem.Menu__c = testMenu.Id;
        database.insert(testItem);
        
        System.currentPageReference().getParameters().put('id', testMenu.Id);
        MenuManagement mm = new MenuManagement();
        mm.loadCurrentMenu();
        mm.getTopLevelMenuItems();
    }
}