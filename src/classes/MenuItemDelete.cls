public with sharing class MenuItemDelete {
    public Menu_Item__c currentMenuItem {get; set;}
    
    public MenuItemDelete(ApexPages.StandardController controller) {
        this.currentMenuItem = this.loadCurrentMenuItem();
    }
    
     public MenuItemDelete() {
        this.currentMenuItem = this.loadCurrentMenuItem();
    }
    
    public PageReference deleteFamilyTree() {
        deleteDescendants(this.currentMenuItem);
        String retUrl = '';
        if(null != this.currentMenuItem.Parent_Item__c) {
            retUrl = '/apex/MenuItemManagement?id=' + this.currentMenuItem.Parent_Item__c; 
        } else if(null != this.currentMenuItem.Menu__c) {
            retUrl = '/apex/MenuManagement?id=' + this.currentMenuItem.Menu__c; 
        } else {
            retUrl = '/apex/ViewOrphanedMenuItems';
        }
        
        delete this.currentMenuItem;
        
        PageReference redirectPage = new PageReference(retUrl);
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    
    private void deleteDescendants(Menu_Item__c menuItem) {
        // Find children
        for(Menu_Item__c[] children: [Select Id from Menu_Item__c where Parent_Item__c = :menuItem.Id]) {
            for(Menu_Item__c child: children) {
                this.deleteDescendants(child);
            }
            
            delete children;
        }
    }
    
    private Menu_Item__c loadCurrentMenuItem() {
        return this.loadMenuItemFromId(System.currentPageReference().getParameters().get('id'));
    }
    
    private Menu_Item__c loadMenuItemFromId(String Id) {
        return [Select Id, Name, Label__c, Article_Id__c, Parent_Item__c, Menu__c, Menu__r.Name, Menu__r.Id, Menu__r.Label__c from Menu_Item__c where Id = :Id limit 1];
    }
    
    static testMethod void testMenuItemDelete() {
        Menu_Item__c testItem = new Menu_Item__c();
        testItem.Label__c = 'test';
        database.insert(testItem);
        
        System.currentPageReference().getParameters().put('id', testItem.Id);
        MenuItemDelete md = new MenuItemDelete();
        md.loadCurrentMenuItem();
        md.deleteFamilyTree();
    }
}