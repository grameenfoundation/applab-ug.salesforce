public with sharing class MenuDelete {
    public Menu__c currentMenu {get; set;}
    
    public MenuDelete(ApexPages.StandardController controller) {
        this.currentMenu = this.loadCurrentMenu();
    }
    
    public MenuDelete() {
        this.currentMenu = this.loadCurrentMenu();
    }

    public PageReference deleteFamilyTree() {
        this.deleteDescendants(this.currentMenu);
        
        
        // Get the tab for Menu_c and redirect to that
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 

        Map<String,String> prefixKeyMap = new Map<String,String>{};
        for(String sObj : gd.keySet()){
           Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
           prefixKeyMap.put(r.getName(), r.getKeyPrefix());
        }
        
        String threeLetterCode = prefixKeyMap.get('Menu__c');
        PageReference pageRef = new PageReference('/' + threeLetterCode);
        return pageRef;
    }
    
    private void deleteDescendants(Menu__c menu) {
        // Find children (top level menu items)
        for(Menu_Item__c[] children: [Select Id from Menu_Item__c where (Parent_Item__c = NULL or Parent_Item__c = '') and Menu__c = :menu.Id]) {
            for(Menu_Item__c child: children) {
                this.deleteDescendantMenuItems(child);
            }
            
            delete children;
        }
        
        delete menu;
    }
    
    private void deleteDescendantMenuItems(Menu_Item__c menuItem) {
        // Find children
        for(Menu_Item__c[] children: [Select Id from Menu_Item__c where Parent_Item__c = :menuItem.Id]) {
            for(Menu_Item__c child: children) {
                this.deleteDescendantMenuItems(child);
            }
            
            delete children;
        }
    }
    
    private Menu__c loadCurrentMenu() {
        return [Select Id, Name from Menu__c where Id = :System.currentPageReference().getParameters().get('id') limit 1];
    }
    
    static testMethod void testMenuDelete() {
        Menu__c testMenu = new Menu__c();
        testMenu.Label__c = 'test';
        database.insert(testMenu);
        
        Menu_Item__c testItem = new Menu_Item__c();
        testItem.Label__c = 'test';
        testItem.Menu__c = testMenu.Id;
        database.insert(testItem);
        
        System.currentPageReference().getParameters().put('id', testMenu.Id);
        MenuDelete md = new MenuDelete();
        md.loadCurrentMenu();
        md.deleteFamilyTree();
    }
}