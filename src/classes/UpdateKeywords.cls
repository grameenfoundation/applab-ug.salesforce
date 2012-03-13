global class UpdateKeywords {   
   
    /** Returns an Array of 6 Strings of Json & plain text Total
      * Array[0] = Total
      * Array[1] = Allowed Menus
      * Array[2] = Updated MenuItems
      * Array[3] = Deleted MenuItems
      * Array[4] = Updated Images
      * Array[5] = Deleted Images
    */
    webservice static String[] getKeywords(JsonRequest request) {
        // required variables
        String[] returnValues = new String[6];
        Integer total = 0;
        List<LocalMenu> menus = new List<localMenu>();        
        List<LocalMenuItem> menuItems = new List<LocalMenuItem>();      
        List<ObjectId> deletedMenuItems = new List<ObjectId>();
        List<ObjectId> updatedImages = new List<ObjectId>();
        List<ObjectId> deletedImages = new List<ObjectId>();              
        
        // get permitted Menus basing on Person Group | Menu Group associations
        menus = getMenus(request);
                
        // get new, deleted and update Menu Items linked to the person's allowed menus
        getNewUpdatedAndDeletedMenuItems(menus, menuItems, deletedMenuItems, request);
        
        // get new, updated and deleted images
        // *** Current assumption is that when an attachment is "updated", even the menu item is "updated"
        getNewUpdatedAndDeletedImages(menuItems, deletedMenuItems, updatedImages, deletedImages, request);
        
        // compute totals
        total = menus.size() + menuItems.size() + deletedMenuItems.size() + updatedImages.size() + deletedImages.size(); 
                
        // serialize return values to Json
        returnValues[0] = String.valueOf(total);
        returnValues[1] = JSON.serialize(menus);
        returnValues[2] = JSON.serialize(menuItems);
        returnValues[3] = JSON.serialize(deletedMenuItems);
        returnValues[4] = JSON.serialize(updatedImages);
        returnValues[5] = JSON.serialize(deletedImages);
        
        return returnValues;
    }
    
    private static List<LocalMenu> getMenus(JsonRequest request) {
        // get relevant Person Group and Menu Group Assciations
        List<Menu_Group_Association__c> menusAssocs = [SELECT mg.Menu__r.Id, mg.Menu__r.Label__c 
                                                       FROM   Menu_Group_Association__c mg
                                                       WHERE mg.Group__c IN 
                                                           (SELECT pg.Group__c FROM Person_Group_Association__c pg
                                                            WHERE  pg.Person__r.Handset__r.IMEI__c = :request.Imei) ];
        // generate LocalMenus from menuAssocs
        List<LocalMenu> menus = new List<LocalMenu>();
        for (Menu_Group_Association__c menuAssoc : menusAssocs) {
             menus.add(new LocalMenu(menuAssoc.Menu__r.Id, menuAssoc.Menu__r.Label__c));    
        }
        return menus;
    }
      
    private static void getNewUpdatedAndDeletedMenuItems(List<LocalMenu> menus, List<LocalMenuItem> items,
                                                      List<ObjectId> deletedMenuItems, JsonRequest request) {
       
        List<String> allowedMenuIds = new List<String>();
        List<String> updatedMenuIds = new List<String>();
        List<String> newMenuIds = new List<String>();
        Map<String, String> itemToArticleMap = new Map<String, String>();
        Map<String, LocalMenuItem> idToItemMap = new Map<String, LocalMenuItem>();
        
        // loop through Local Menu to get Menu Ids
        for (LocalMenu menu : menus) {          
            allowedMenuIds.add(menu.Id);
        }
                
        if (request.MenuIds == null || request.MenuIds.size() == 0) {
            newMenuIds = allowedMenuIds; 
        }
        else {
            Set<String> allMenus = new Set<String>(request.MenuIds);           
        
            // sort the allowed menus into (-those for update) & (-entirely new ones)
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
            for (Menu_Item__c menuItem : [SELECT Id, Label__c, Parent_Item__c, Menu__c, Article_Id__c, Position__c, IsDeleted 
                                          FROM   Menu_Item__c  
                                          WHERE  Menu__c IN :updatedMenuIds 
                                          AND Last_Modified_Date__c > :DateTime.parse(request.LastUpdatedDate) ALL ROWS]) {
            
                // loop many times for each menu item to mimic production scenario
                for (Integer index = 0; index < 1; index++) {
                    if (menuItem.IsDeleted) {
                        deletedMenuItems.add(new ObjectId(menuItem.Id));
                    }
                    else {
                        if (menuItem.Article_Id__c != null) {
                            itemToArticleMap.put(menuItem.Article_Id__c, menuItem.Id);
                        }
                      
                        LocalMenuItem mItem = new LocalMenuItem(menuItem.Label__c, menuItem.Id, 
                                                                menuItem.Parent_Item__c, menuItem.Menu__c,
                                                                menuItem.Position__c);
                        items.add(mItem );
                        idToItemMap.put(menuItem.Id, mItem);                        
                    }                 
                }
            }
        }
        
        if (newMenuIds.size() > 0) {
            
            for (Menu_Item__c menuItem : [SELECT Id, Label__c, Parent_Item__c, Menu__c, Article_Id__c, Position__c
                                          FROM   Menu_Item__c  
                                          WHERE  Menu__c IN :newMenuIds]) {
                
                 // loop many times to mimic production
                 for (Integer index = 0; index < 1; index++) {
                    
                     if (menuItem.Article_Id__c != null) {
                         itemToArticleMap.put(menuItem.Article_Id__c, menuItem.Id);   
                     }
                     
                     LocalMenuItem mItem = new LocalMenuItem(menuItem.Label__c, menuItem.Id, 
                                                                menuItem.Parent_Item__c, menuItem.Menu__c,
                                                                menuItem.Position__c);
                     items.add(mItem );
                     idToItemMap.put(menuItem.Id, mItem);  
                 }                                          
            }           
        }  
        buildSearchContentInMenuItems(idToItemMap, itemToArticleMap);
    }
    
    // loads content into menu items
    private static void buildSearchContentInMenuItems(Map<String, LocalMenuItem> idToItemMap, Map<String, String> itemToArticleMap) {
       
        for (Mobile_Article__kav article : [SELECT Id, CKW_Search_Content__c
                                                FROM   Mobile_Article__kav
                                                WHERE  Id IN :itemToArticleMap.values()
                                                AND    PublishStatus = 'Online']) {
            
            LocalMenuItem item = idToItemMap.get(itemToArticleMap.get(article.Id));
            item.Content = 'Last Modified: '             +
                           DateTime.Now()                +
                           '\n Content: '                +
                           article.CKW_Search_Content__c;
        }
        
    }
    
    private static void getNewUpdatedAndDeletedImages(List<LocalMenuItem> menuItems, List<ObjectId> deletedMenuIds,
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
        // this will work for both updated and new menus items (and their attachements)
        // since LastModifiedDate is set to CreatedDate on creation of attachment
        for (Attachment attachment : [SELECT Id, IsDeleted
                                      FROM   Attachment 
                                      WHERE  ParentId IN :menuItemIds
                                      AND    LastModifiedDate > :DateTime.parse(request.LastUpdatedDate)
                                      AND    Name LIKE '%.jp%g' ALL ROWS]) {                    
          
            if (attachment.IsDeleted) {
                deletedImages.add(new ObjectId(attachment.Id)); 
            }
            else {
                updatedImages.add(new ObjectId(attachment.Id));         
            }           
        }    
    }   
    
    // Helper classes
     global class JsonRequest {
        webservice String Imei; 
        webservice List<String> MenuIds; 
        webservice String LastUpdatedDate;
    }
    
     global class LocalMenu {
        String label; 
        String id;
        
        LocalMenu(String menuId, String name) {
            this.id = menuId;
            this.label= name;
        }
    }
    
    global class LocalMenuItem {
        String label;
        String id; 
        String menu_id; 
        String parent_id; 
        String content; 
        Decimal position;
        
        // constructor excludes content as this is generated differently
        LocalMenuItem(String name, String id, String pId, 
                      String menuId, Decimal position) {
            this.label = name;
            this.id = id;
            this.menu_id = menuId;
            this.parent_id = pId;
            this.position = position; 
            this.content = 'No Content';       
        }
    }        
    
    global class ObjectId {
        String id;
        
        ObjectId(String objectId) {
            this.id = objectId;
        }
    }         
}