global class ImportBackendServerKeywords {

    /**
      Takes in adapter which is a "linked" list (by path) and menu Label which should be 'CKW Search'
      returns true if successful, false otherwise
     */
    webservice static boolean importBackendKeywords(List<MenuItemAdapter> menuItemAdapters, String menuLabel) {
        Menu__c menu = getMenuByLabel(menuLabel);
        // A set is used to avoid duplicates elegantly
        Set<Menu_Item__c> updateMenuItemsSet = new Set<Menu_Item__c>();
        List<Menu_Item__c> updateMenuItemsList = new List<Menu_Item__c>();
        for (MenuItemAdapter currentAdapter : menuItemAdapters) {            
            // Skip adapter if it has already been processed.
            if (currentAdapter.IsProcessed) {
                continue;
            }
            Menu_Item__c foundItem = getRelatedMenuItem(currentAdapter, menuItemAdapters, menu.Id);
            // check if the menu item has been found if yes update, if no, create menu item, add it to list then continue
            if (null != foundItem) {
                currentAdapter.MenuItem = updateMenuItemContent(currentAdapter, foundItem);
                updateMenuItemsSet.add(currentAdapter.MenuItem);
                continue;
            }
            currentAdapter.MenuItem = createAndSaveMenuItem(currentAdapter, menu, menuItemAdapters);                      
        }        
        // update List of items to be updated
        updateMenuItemsList.addAll(updateMenuItemsSet);
        database.update(updateMenuItemsList);
        return true;
    }
    
    // get menu item by
    private static Menu__c getMenuByLabel(String label) {
      return [SELECT 
                  Id, Label__c 
              FROM 
                  Menu__c
              WHERE
                  Label__c = :label
              LIMIT 1];
    }
    
    // check if sent menu item exists in salesforce, returns it if it exists
    private static Menu_Item__c getRelatedMenuItem(MenuItemAdapter menuItemAdapter, List<MenuItemAdapter> adapters, String menuId) {
       MenuItemAdapter previousAdapter = findAdapterByPath(menuItemAdapter.PreviousItemPath, adapters);
       List<Menu_Item__c> menuItems = null;
       
       if (previousAdapter != null && previousAdapter.MenuItem != null) {
           menuItems = [
           SELECT
               Id, Label__c, Attribution__c, Content__c, Is_Active__c, Parent_Item__c, Last_Modified_Date__c
           FROM
               Menu_Item__c
           WHERE
               Label__c = :menuItemAdapter.Label.trim()
             AND
               Menu__c = :menuId
             AND
               Parent_Item__c = : previousAdapter.MenuItem.Id 
           ];
       }
       else {
           menuItems = [
           SELECT
               Id, Label__c, Attribution__c, Content__c, Is_Active__c, Parent_Item__c, Last_Modified_Date__c
           FROM
               Menu_Item__c
           WHERE
               Label__c = :menuItemAdapter.Label.trim()
             AND
               Menu__c = :menuId
             AND
               Parent_Item__c = NULL  
           ];
       }
       
      if (menuItems != null && menuItems.size() != 0) {
      	return menuItems.get(0);
      }
      return null;   
    }
    
    // This updates contents of the the menu item from the adapter
    // This does not save the changes yet    
    private static Menu_Item__c updateMenuItemContent(MenuItemAdapter adapter, Menu_Item__c menuItem) {
        menuItem.Label__c = adapter.Label;
        menuItem.Content__c = adapter.Content;
        menuItem.Attribution__c = adapter.Attribution;
        menuItem.Is_Active__c = adapter.IsActive;
        menuItem.Last_Modified_Date__c = adapter.LastModifiedDate; 
        adapter.IsProcessed = true;
        return menuItem;
    }
    
    // factory-like method for creating and saving new menuitems.
    // This sets the menu details and Parent_MenuItem if necessary
    private static Menu_Item__c createAndSaveMenuItem(MenuItemAdapter adapter, Menu__c menu, List<MenuItemAdapter> adapters) {
        Menu_Item__c menuItem = new Menu_Item__c();
        menuItem.Menu__c = menu.Id;
        menuItem.Label__c = adapter.Label;
        menuItem.Content__c = adapter.Content;
        menuItem.Attribution__c = adapter.Attribution;
        menuItem.Is_Active__c = adapter.IsActive;
        menuItem.Last_Modified_Date__c = adapter.LastModifiedDate;
        MenuItemAdapter previousAdapter = findAdapterByPath(adapter.PreviousItemPath, adapters);
        if (previousAdapter != null && previousAdapter.MenuItem != null) {
            menuItem.Parent_Item__c = previousAdapter.MenuItem.Id;
        }        
        adapter.IsProcessed = true;
        database.insert(menuItem);
        return menuItem;
    }
    
    // Find adapter by path, returns null if there is none
    // Note that this is a work around to do linked lists across webservice calls
    private static MenuItemAdapter findAdapterByPath(String path, List<MenuItemAdapter> adapters) {
        path = path.trim();
        if (path == '') {
            return null;
        }
        for (MenuItemAdapter adapter : adapters) {
            if (path == adapter.MenuPath.trim()) {
                return adapter;
            }
        }
        // should never reach this point!
        return null;
    }
   
    /*
    * Adapter class map saleforce Menu_Item__c to backend Keywords
    * Basic implementation of Adapter pattern and
    * Modified version of backward linked-list linked menu path
    */
    global class MenuItemAdapter {
        webservice String Label;
        webservice String Content;
        webservice String Attribution;
        webservice boolean IsActive;
        webservice String MenuPath;
        webservice String PreviousItemPath;
        webservice Menu_Item__c MenuItem;
        webservice boolean IsProcessed;
        webservice DateTime LastModifiedDate;
    }
    
    static testmethod void testAll() {
        Menu__c menu = new Menu__c();
        menu.Label__c = 'CKW Search1';
        database.insert(menu);
        
        System.assert(null != getMenuByLabel('CKW Search1'));
        
        Menu_Item__c menuItem1 = new Menu_Item__c();
        menuItem1.Menu__c = menu.Id;
        menuItem1.Label__c = 'First One1';
        menuItem1.Content__c = 'Content';
        database.insert(menuItem1);

        MenuItemAdapter adapter1 = new MenuItemAdapter();
        adapter1.PreviousItemPath = '';
        adapter1.Label = 'First One1';
        adapter1.Content = 'New stuff';
        adapter1.Attribution = ' billy new';
        adapter1.IsActive = true;
        adapter1.IsProcessed = false;
        adapter1.LastModifiedDate = datetime.now();
        adapter1.MenuPath = 'First_One1';
        
        MenuItemAdapter adapter2 = new MenuItemAdapter();
        adapter1.PreviousItemPath = 'First_One1';
        adapter2.Label = 'Second1';
        adapter2.Content = 'New stuff';
        adapter2.Attribution = ' billy new';
        adapter2.IsActive = false;
        adapter2.IsProcessed = false;
        adapter1.LastModifiedDate = datetime.now();
        adapter2.MenuPath = 'First_One1 Second1';
        
        MenuItemAdapter adapter3 = new MenuItemAdapter();
        adapter1.PreviousItemPath = 'First_One1 Second1';
        adapter3.Label = 'Third';
        adapter3.Content = 'New stuffs';
        adapter3.Attribution = ' billy new';
        adapter3.IsActive = true;
        adapter3.IsProcessed = false;
        adapter1.LastModifiedDate = datetime.now();
        adapter3.MenuPath = 'First_One1 Second1 Third';
        
        // set up doubly-linked list
        adapter1.PreviousItemPath = '';
        adapter2.PreviousItemPath = adapter1.MenuPath;
        adapter3.PreviousItemPath = adapter2.MenuPath;
        
        List<MenuItemAdapter> adapters = new List<MenuItemAdapter>();
        adapters.add(adapter1);
        adapters.add(adapter2);
        adapters.add(adapter3);
        
        boolean done = importBackendKeywords(adapters, 'CKW Search1');
        System.assert(done);        
    }
}