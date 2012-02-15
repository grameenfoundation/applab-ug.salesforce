global class UpdateKeywords {
    
    global class JsonRequest {
        webservice String Imei; 
        webservice List<String> MenuIds; 
        webservice String LastUpdatedDate;
    }
    
    global class LocalMenu {
        String Name; 
        String Id;
    }
    
    global class LocalMenuItem {
        String Name;
        String Id; 
        String MenuId; 
        String PId; 
        String Content; 
        Integer Position;
    }        
    
    global class ObjectId {
        String Id;
    }    

    /** Returns an Array of 5 Strings of Json.
      * Array[0] = Allowed Menus
      * Array[1] = Updated MenuItems
      * Array[2] = Deleted MenuItems
      * Array[3] = Updated Images
      * Array[4] = Deleted Images
    */
    webservice static String[] getKeywords(JsonRequest request) {
        // required variables
        String[] returnValues = new String[5]; 
        List<LocalMenu> menus = new List<localMenu>();        
        List<LocalMenuItem> menuItems = new List<LocalMenuItem>();      
        List<ObjectId> deletedMenuItems = new List<ObjectId>();
        List<ObjectId> updatedImages = new List<ObjectId>();
        List<ObjectId> deletedImages = new List<ObjectId>();              
 
        // get permitted Menus basing on Person Group | Menu Group associations
        menus = getMenus(request);
                
        // get new, deleted and update Menu Items linked to the person's allowed menus
        getNewUpdatedAndDeletedMenuItems(menus, menuItems, deletedMenuItems, request);
        
        // get updated and deleted images
        //*** Current assumption is that when an attachment is "updated", even the menu item is "updated"
        getUpdatedAndDeletedImages(menuItems, deletedMenuItems, updatedImages, deletedImages, request);
        
        // serialize return values to Json
        returnValues[0] = JSON.serialize(menus);
        returnValues[1] = JSON.serialize(menuItems);
        returnValues[2] = JSON.serialize(deletedMenuItems);
        returnValues[3] = JSON.serialize(updatedImages);
        returnValues[4] = JSON.serialize(deletedImages);
        return returnValues;
    }
    
    private static List<LocalMenu> getMenus(JsonRequest request) {
        // Get relevant Person Group and Menu Group Assciations
        List<Menu_Group_Association__c> menusAssocs = [SELECT mg.Menu__r.Id, mg.Menu__r.Label__c 
                                                       FROM   Menu_Group_Association__c mg
                                                       WHERE mg.Group__c IN 
                                                           (SELECT pg.Group__c FROM Person_Group_Association__c pg
                                                            WHERE  pg.Person__r.Handset__r.IMEI__c = :request.Imei) ];
        // Generate LocalMenus from menuAssocs
        List<LocalMenu> menus = new List<LocalMenu>();
        for (Menu_Group_Association__c menuAssoc : menusAssocs) {
             LocalMenu item = new LocalMenu();
             item.Id = menuAssoc.Menu__r.Id;
             item.Name = menuAssoc.Menu__r.Label__c;
             menus.add(item);    
        }
        return menus;
    }
      
    private static void getNewUpdatedAndDeletedMenuItems(List<LocalMenu> menus, List<LocalMenuItem> items,
                                                      List<ObjectId> deletedMenuItems, JsonRequest request) {
       
        List<String> allowedMenuIds = new List<String>();
        List<String> updatedMenuIds = new List<String>();
        List<String> newMenuIds = new List<String>();
        // Loop through Local Menu to get Menu Ids
        for (LocalMenu menu : menus) {          
            allowedMenuIds.add(menu.Id);
        }
                
        if (request.MenuIds == null || request.MenuIds.size() == 0) {
            newMenuIds = allowedMenuIds; 
        }
        else {
            Set<String> allMenus = new Set<String>(request.MenuIds);           
        
            // Sort the allowed menus into (-those for update) & (-entirely new ones)
            for (String Id : allowedMenuIds) {
                if (allMenus.contains(Id)) {
                    updatedMenuIds.add(Id);
                }
                else {
                    newMenuIds.add(Id);
                }
            }
        }              
        
        if (updatedMenuIds.size() > 0) {
            for (Menu_Item__c menuItem : [SELECT m.Id, m.Label__c, m.Parent_Item__c, m.Menu__c, m.IsDeleted 
                                          FROM   Menu_Item__c m 
                                          WHERE  m.Menu__c IN :updatedMenuIds 
                                          AND m.LastModifiedDate > :DateTime.parse(request.LastUpdatedDate) ALL ROWS]) {
            
                // Loop many times for each menu item to mimic production scenario
                for (Integer index = 0; index < 1; index++) {
                    if (menuItem.IsDeleted) {
                        ObjectId item = new ObjectId();
                        item.Id = menuItem.Id;
                        deletedMenuItems.add(item);
                    }
                    else {
                        LocalMenuItem item = new LocalMenuItem();
                        item.Id = menuItem.Id;
                        item.Name = menuItem.Label__c;
                        item.PId = menuItem.Parent_Item__c;
                        item.MenuId = menuItem.Menu__c;                    
                        items.add(item);
                    }                 
                }
            }
        }
        
        if (newMenuIds.size() > 0) {
            
            for (Menu_Item__c menuItem : [SELECT m.Id, m.Label__c, m.Parent_Item__c, m.Menu__c, m.IsDeleted 
                                          FROM   Menu_Item__c m 
                                          WHERE  m.Menu__c IN :newMenuIds 
                                          AND m.LastModifiedDate > :DateTime.parse(request.LastUpdatedDate) ALL ROWS]) {
                
                 // loop many times to mimic production
                 for (Integer index = 0; index < 1; index++) {
                     LocalMenuItem item = new LocalMenuItem();
                     item.Id = menuItem.Id;
                     item.Name = menuItem.Label__c;
                     item.PId = menuItem.Parent_Item__c;
                     item.MenuId = menuItem.Menu__c;                    
                     items.add(item);
                 }                                          
            }           
        }   
    }
    
    private static void getUpdatedAndDeletedImages(List<LocalMenuItem> menuItems, List<ObjectId> deletedMenuIds,
                                                   List<ObjectId> updatedImages, List<ObjectId> deletedImages, 
                                                   JsonRequest request) {
        
        // loop through menu items to get ids for attachement query
        List<String> menuItemIds = new List<String>();
        for (LocalMenuItem menuItem : menuItems) {
            menuItemIds.add(menuItem.Id);
        }
        // loop through deleted menu item ids so not to forget to delete them
        for (ObjectId deletedMenuId : deletedMenuIds) {
            menuItemIds.add(deletedMenuId.Id);
        }
        
        for (Attachment attachment : [SELECT a.Id, a.IsDeleted
                                      FROM   Attachment a
                                      WHERE  a.parentId IN :menuItemIds
                                      AND LastModifiedDate > :DateTime.parse(request.LastUpdatedDate) ALL ROWS]) {
                                        
            ObjectId obj = new ObjectId();
            obj.Id = attachment.Id;          
          
            if (attachment.IsDeleted) {
                deletedImages.add(obj);
            }
            else {
                updatedImages.add(obj);         
            }           
        }    
    }  
}