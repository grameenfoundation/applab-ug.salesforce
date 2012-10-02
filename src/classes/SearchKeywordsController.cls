public class SearchKeywordsController {

    Menu__c[] menus = null;
    Menu__c currentMenu  = null;
    Menu_Item__c parentMenuItem = null;
    List<Menu_Item__c> menuItems = null;
    String keyword;
    List<String> keywords = new List<String>();
    String articleId;
    String label;
    Boolean hasMenuItems;

    public String getArticleId() {
        return articleId;
    } 

    public Boolean getHasMenuItems() {
        return menuItems.size() > 0;
    }

    // Set the article Id for a menu Item being added
    public void setArticleId(String article_id) {
        this.articleId = article_id;
    }
    
    public String getLabel() {
        return this.label;
    }

    // Set the Label for a menu Item being added
    public void setLabel(String label_l) {
        this.label = label_l; 
    }

    public String getKeyword() {
        return this.keyword;
    }

     public List<Menu_Item__c> getMenuItems() {
        return menuItems;
    }

    public Menu_Item__c getParentMenuItem() {
         return this.parentMenuItem ;
    }
    
     public void setParentMenuItem(Menu_Item__c parentItem) {
         this.parentMenuItem = parentItem;
    }
 
    public Menu__c getCurrentMenu() {
        return this.currentMenu;
    }
    
    public void setCurrentMenu(Menu__c menu) {
        this.currentMenu = menu;
    }

    // Gets the Menus for display 
    public Menu__c[] getMenus() {
        if (this.menus == null) {
            this.menus = [
                SELECT 
                    m.Id, 
                    m.Name, 
                    m.Label__c 
                FROM 
                    Menu__c m]; 
        }
        return this.menus;
    }

    // Gets root menu items for the selected Menu i.e. those without Parent Menu Item
    public PageReference getTopMenuItems() {
        String menuId = ApexPages.currentPage().getParameters().get('mId');
        
        currentMenu = [
            SELECT 
                m.Id, 
                m.Name, 
                m.Label__c
            FROM 
                Menu__c m 
            WHERE 
                m.Id = :menuId 
            LIMIT 1];

        menuItems = [
            SELECT 
                Id, 
                Name, 
                Label__c , 
                Article_Id__c
            FROM 
                Menu_Item__c  
            WHERE 
                Parent_Item__c = null 
            AND Menu__c = :menuId];
    
       keyword = currentMenu.Label__c; 
       // add menu item label to keyword list, this will aid in building keyword for display 
       keywords.add(keyword);       
       return null;
    }

    // Gets all child Menu Items for Selected Menu Item
    public PageReference getChildMenuItems() {
        String menuItemId = ApexPages.currentPage().getParameters().get('miId');
        
         parentMenuItem = [
             SELECT 
                 m.Id, 
                 m.Name, 
                 m.Label__c, 
                 m.Parent_Item__c
             FROM 
                 Menu_Item__c m 
             WHERE 
                 m.Id = :menuItemId 
             LIMIT 1];

         menuItems = [
             SELECT 
                 m.Id, 
                 m.Name, 
                 m.Label__c, 
                 m.Article_Id__c
             FROM 
                 Menu_Item__c m 
             WHERE 
                 m.Parent_Item__c = :menuItemId];
        
        // Generate Keyword for Display in an arrow separated format
        keyword  = keyword + ' -> ' + parentMenuItem.Label__c;
        // Add keyword to list of existing keywords. This is uselful in moving a level up 
        keywords.add(keyword);
        return null;
    }

    // Move to the Parent Menu Item for the Menu Items on display,
    // If these are top level Menu Items, display same results as before 
    public PageReference moveBack() {

        if (parentMenuItem != null) {

            if (parentMenuItem.Parent_Item__c != null) {
                 parentMenuItem = [
                     SELECT 
                         m.Id, 
                         m.Name, 
                         m.Label__c, 
                         m.Parent_Item__c
                     FROM 
                         Menu_Item__c m 
                     WHERE 
                         m.Id = :parentMenuItem.Parent_Item__c 
                     LIMIT 1]; 

             menuItems = [
                 SELECT 
                     m.Id, 
                     m.Name, 
                     m.Label__c, 
                     m.Article_Id__c
                 FROM 
                     Menu_Item__c m 
                 WHERE 
                     m.Parent_Item__c = :parentMenuItem.Id];                         

            }
            else {
                parentMenuItem = null;
                 menuItems = [
                     SELECT 
                         m.Id, 
                         m.Name, 
                         m.Label__c, 
                         m.Article_Id__c
                     FROM 
                         Menu_Item__c m 
                     WHERE 
                         m.Parent_Item__c = null
                     AND 
                         m.Menu__c = :currentMenu.Id];  
            }              
                          
          keywords.remove(keywords.size() - 1);
          keyword = keywords.get(keywords.size() - 1);
        }     
        return null;
    }

    public PageReference addMenuItem() {

        Menu_Item__c newItem = new Menu_Item__c ();
        newItem.Label__c = label;
        newItem.Article_Id__c = articleId;
        newItem.Menu__c = currentMenu.Id;

        if (parentMenuItem != null) {
            newItem.Parent_Item__c = parentMenuItem .Id;
            database.insert(newItem);      
            // clear off the current item to allow new entries
            newItem = new Menu_Item__c();

            // reload the current items to show changes to menu items            
            menuItems = [
                SELECT 
                    m.Id, 
                    m.Name, 
                    m.Label__c, 
                    m.Article_Id__c
                FROM 
                    Menu_Item__c m 
                WHERE 
                    m.Parent_Item__c = :parentMenuItem.Id];
        }

        else {
            database.insert(newItem);      
            // clear off the current item to allow new entries
            newItem = new Menu_Item__c();

            // reload the current items to show changes            
            menuItems = [
                SELECT 
                    Id, 
                    Name, 
                    Label__c, 
                    Article_Id__c
                FROM 
                    Menu_Item__c  
                WHERE 
                    Parent_Item__c = null 
                AND 
                    Menu__c = :currentMenu.Id];
        }
        label = '';
        articleId = '';
        return null;
    }

    public PageReference saveChanges() {
         database.update(menuItems);
         return null;
    }  

     public PageReference deleteMenuItem() {
         String menuItemId = ApexPages.currentPage().getParameters().get('delId');
         Menu_Item__c[] delMenusItems = [
             SELECT 
                 Id, 
                 Name, 
                 Label__c, 
                 Article_Id__c
             FROM 
                 Menu_Item__c  
             WHERE 
                 Parent_Item__c = :menuItemId
             OR 
                 Id = :menuItemId];

        Database.DeleteResult[] firstResult = Database.delete(delMenusItems);
        
        if (parentMenuItem != null) {
         // reload the current items to show change
            menuItems = [
                SELECT 
                    m.Id, 
                    m.Name, 
                    m.Label__c, 
                    m.Article_Id__c
                FROM 
                    Menu_Item__c m 
                WHERE 
                    m.Parent_Item__c = :parentMenuItem.Id];
        }

        else {
         menuItems = [
             SELECT 
                 Id, 
                 Name, 
                 Label__c, 
                 Article_Id__c
             FROM 
                 Menu_Item__c  
             WHERE 
                 Parent_Item__c = null 
             AND 
                 Menu__c = :currentMenu.Id];
        }
        return null;
    }
    
     static testMethod void canGetMenus() {
         SearchKeywordsController controller = new SearchKeywordsController();
         Menu__c[] menus = controller.getMenus();
         system.assert(menus != null);
     }                 
}