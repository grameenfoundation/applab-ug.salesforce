global class ImportBackendKeywordsNew {
  /*
    Takes in adapter which is a "linked" list (by path) and menu Label which should be 'CKW Search 3.0'
    returns true if successful, false otherwise
   */
  webservice static boolean importBackendKeywords(List<MenuItemAdapter> menuItemAdapters, String menuLabel) {
    if (menuItemAdapters == null || menuItemAdapters.size() == 0) {
      return false;
    }
    Menu__c menu = getMenuByLabel(menuLabel);
    List<Menu_Item__c> updateMenuItems = new List<Menu_Item__c>();
    List<Menu_Item__c> insertMenuItems = new List<Menu_Item__c>();
    for (MenuItemAdapter currentAdapter : menuItemAdapters) {
      // Skip adapter if it has already been processed.
      if (currentAdapter.IsProcessed) {
        continue;
      }
      Menu_Item__c foundItem = getRelatedMenuItem(currentAdapter, menuItemAdapters, menu.Id);
      // check if the menu item has been found if yes update, if no, create menu item, add it to list then continue
      if (null != foundItem) {
        currentAdapter.MenuItem = updateMenuItemContent(currentAdapter, foundItem);
        // Work around so as to not add duplicates in the list
        // Better alternative compared to iterating over list each time
        // which would exponetially increase script statements
        try {
          updateMenuItems.add(currentAdapter.MenuItem);
        } catch (ListException e) {
          // Empty catch intentional!
        }
        continue;
      }
      currentAdapter.MenuItem = createAndSaveMenuItem(currentAdapter, menu, menuItemAdapters);
      insertMenuItems.add(currentAdapter.MenuItem);
    }
    System.debug(Logginglevel.DEBUG, 'Count of menu items to update is ' + updateMenuItems.size());
    System.debug(Logginglevel.DEBUG, 'Count of menu items to insert is ' + insertMenuItems.size());
    if (updateMenuItems.size() > 0) {
      // update List of items to be updated
      database.update(updateMenuItems);
    }
    return true;
  }

  // get menu item by
  public static Menu__c getMenuByLabel(String label) {
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
    } else {
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

}