public class SearchKeywordsController {

    Menu__c[] menus = null;
    
    public Menu__c[] getMenus() {
        if (this.menus == null) {
            this.menus = [SELECT m.Id, m.Name, m.Label__c 
                  FROM Menu__c m]; 
        }
        return this.menus;
    }
      
    public PageReference getMenuItems() {
        String menuId = ApexPages.currentPage().getParameters().get('mId');
        
        return null;
    }
    
   // public MenuItem__c[] getMenuItems() {
     //   return null;
    //}
}