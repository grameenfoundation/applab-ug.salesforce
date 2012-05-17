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
        List<Menu_Group_Association__c> menusAssocs = [
            SELECT
                mg.Menu__r.Id,
                mg.Menu__r.Label__c
            FROM
                Menu_Group_Association__c mg
            WHERE
                mg.Group__c IN (
                    SELECT
                        pg.Group__c
                    FROM
                        Person_Group_Association__c pg
                    WHERE
                        pg.Person__r.Handset__r.IMEI__c = :request.Imei) ];

        // generate LocalMenus from menuAssocs
        List<LocalMenu> menus = new List<LocalMenu>();
        for (Menu_Group_Association__c menuAssoc : menusAssocs) {
             menus.add(new LocalMenu(menuAssoc.Menu__r.Id, menuAssoc.Menu__r.Label__c));
        }
        return menus;
    }

    /**
     * Convenience method to allow testing this method without passing in a json request
     **/
    private static void getNewUpdatedAndDeletedMenuItems(List<LocalMenu> menus, List<LocalMenuItem> items,
                                                      List<ObjectId> deletedMenuItems, JsonRequest request) {
         getNewUpdatedAndDeletedMenuItems(menus, items, deletedMenuItems, request.MenuIds, request.LastUpdatedDate);
    }

    private static void getNewUpdatedAndDeletedMenuItems(List<LocalMenu> menus, List<LocalMenuItem> items,
                                                      List<ObjectId> deletedMenuItems, String[] requestMenuIds, String requestLastUpdatedDate) {

        List<String> allowedMenuIds = new List<String>();
        List<String> updatedMenuIds = new List<String>();
        List<String> newMenuIds = new List<String>();
        // One article can be linked to by many items, so this is a one-to-many map
        Map<String, List<String>> itemToArticleMap = new Map<String, List<String>>();
        Map<String, LocalMenuItem> idToItemMap = new Map<String, LocalMenuItem>();

        // loop through Local Menu to get Menu Ids
        for (LocalMenu menu : menus) {
            allowedMenuIds.add(menu.id);
        }

        if (requestMenuIds == null || requestMenuIds.size() == 0) {
            newMenuIds = allowedMenuIds;
        }
        else {
            Set<String> allMenus = new Set<String>(requestMenuIds);

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
            for (Menu_Item__c menuItem : [
                SELECT
                    Id,
                    Label__c,
                    Parent_Item__c,
                    Menu__c,
                    Article_Id__c,
                    Content__c,
                    Position__c,
                    IsDeleted
                FROM
                    Menu_Item__c
                WHERE
                    Menu__c IN :updatedMenuIds
                AND
                    Last_Modified_Date__c > :datetime.valueOf(requestLastUpdatedDate)
                ALL ROWS]) {

                if (menuItem.IsDeleted) {
                    deletedMenuItems.add(new ObjectId(menuItem.Id));
                }
                else {
                    if (menuItem.Article_Id__c != null) {
                      // Add the menuItem to the article map
                        List<String> menuItemIdList = new List<String>();
                      if(null != itemToArticleMap.get(menuItem.Article_Id__c)) {
                         menuItemIdList = itemToArticleMap.get(menuItem.Article_Id__c);
                      }
                      menuItemIdList.add(menuItem.Id);
                        itemToArticleMap.put(menuItem.Article_Id__c, menuItemIdList);
                    }

                    LocalMenuItem mItem = new LocalMenuItem(menuItem.Label__c, menuItem.Id,
                                                            menuItem.Parent_Item__c, menuItem.Menu__c,
                                                            menuItem.Content__c, menuItem.Position__c);
                    items.add(mItem);
                    idToItemMap.put(menuItem.Id, mItem);
                }
            }
        }

        if (newMenuIds.size() > 0) {

            for (Menu_Item__c menuItem : [
                 SELECT
                     Id,
                     Label__c,
                     Parent_Item__c,
                     Menu__c,
                     Article_Id__c,
                     Content__c,
                     Position__c
                 FROM
                     Menu_Item__c
                 WHERE
                     Menu__c IN :newMenuIds]) {

                 if (menuItem.Article_Id__c != null) {
                    // Add the menuItem to the article map
                     List<String> menuItemIdList = new List<String>();
                     if(null != itemToArticleMap.get(menuItem.Article_Id__c)) {
                        menuItemIdList = itemToArticleMap.get(menuItem.Article_Id__c);

                     }
                     menuItemIdList.add(menuItem.Id);
                     itemToArticleMap.put(menuItem.Article_Id__c, menuItemIdList);
                 }

                 LocalMenuItem mItem = new LocalMenuItem(menuItem.Label__c, menuItem.Id,
                                                            menuItem.Parent_Item__c, menuItem.Menu__c,
                                                            menuItem.Content__c, menuItem.Position__c);
                 items.add(mItem);
                 idToItemMap.put(menuItem.Id, mItem);
            }
        }
        buildSearchContentInMenuItems(idToItemMap, itemToArticleMap);
    }

    // loads content into menu items
    private static void buildSearchContentInMenuItems(Map<String, LocalMenuItem> idToItemMap, Map<String, List<String>> itemToArticleMap) {

        for (KnowledgeArticleVersion article : [
            SELECT
                LastPublishedDate,
                ArticleNumber,
                Summary
            FROM
                KnowledgeArticleVersion
            WHERE
                PublishStatus = 'Online'
            AND
               KnowledgeArticleId IN (
                   SELECT
                       Id
                   FROM
                       KnowledgeArticle
                   WHERE
                       ArticleNumber IN :itemToArticleMap.keySet())]) {

            // Get all items that pointed to this article and update their content
            // Append the content to any existing content for that item
            List<String> itemIds = itemToArticleMap.get(article.ArticleNumber);
            for(String itemId: itemIds) {
              LocalMenuItem item = idToItemMap.get(itemId);
              item.Content = article.Summary    +
                             '\nUpdated: ' +
                             article.LastPublishedDate +
                             '\n'; // Trailing newline helps show last content line with some phones.
            }
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
        for (Attachment attachment : [
            SELECT
                Id,
                ParentId,
                IsDeleted
            FROM
                Attachment
            WHERE
                ParentId IN :menuItemIds
                AND
                LastModifiedDate > :datetime.valueOf(request.LastUpdatedDate)
                AND
                Name LIKE '%.jp%g'
            ALL ROWS]) {

            if (attachment.IsDeleted) {
                deletedImages.add(new ObjectId(attachment.ParentId + '-' + attachment.Id));
            }
            else {
                updatedImages.add(new ObjectId(attachment.ParentId + '-' + attachment.Id));
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
                      String menuId, String content, Decimal position) {
            this.label = name;
            this.id = id;
            this.menu_id = menuId;
            this.parent_id = pId;
            this.position = position;
            this.content = content != NULL ? content : 'No Content';
            this.content += '\n'; // Trailing newline helps show last content line with some phones.
        }
    }

    global class ObjectId {
        String id;

        ObjectId(String objectId) {
            this.id = objectId;
        }
    }

    static testMethod void testArticleLink() {
        // TODO

        // Create a menu and item
        Menu__c menu = new Menu__c();
        menu.Label__c = 'Test Menu89';
        database.insert(menu);

        Menu_Item__c menuItem = new Menu_Item__c();
        menuItem.Label__c = 'Test Menu Item90';
        menuItem.Menu__c = menu.Id;

        KnowledgeArticleVersion[] articleVersion = [SELECT ArticleNumber, Summary
                  FROM KnowledgeArticleVersion
                  WHERE PublishStatus='Online'
                  AND Language = 'en_US' LIMIT 1];
        if(articleVersion.size() > 0) {
            menuItem.Article_Id__c = articleVersion[0].ArticleNumber;
            database.insert(menuItem);

            // Set the allowedMenus variable
            List<LocalMenu> allowedMenus = new List<LocalMenu>();
            allowedMenus.add(new LocalMenu(menu.Id, menu.Label__c));

            // Check that the insertion went well
            List<String> newMenuIds = new List<String>();
            for (LocalMenu menuToAdd : allowedMenus) {
                newMenuIds.add(menuToAdd.id);
            }

            Menu_Item__c[] newMenuItems = [SELECT
                       Id,
                       Label__c,
                       Parent_Item__c,
                       Menu__c,
                       Article_Id__c,
                       Content__c,
                       Position__c
                   FROM
                       Menu_Item__c
                   WHERE
                       Menu__c IN :newMenuIds];
            System.assert(newMenuItems.size() > 0);

            List<LocalMenuItem> items = new List<LocalMenuItem>();
            List<ObjectId> deletedMenuItems = new List<ObjectId>();
            String[] menuIds = new List<String>();
            String lastUpdatedDate = '' + DateTime.Now();

            getNewUpdatedAndDeletedMenuItems(allowedMenus, items, deletedMenuItems, menuIds, lastUpdatedDate);

            // check that items contains at least one item
            System.assert(deletedMenuItems.size() == 0);
            System.assert(items.size() > 0);
            System.assert(items[0].label.equals('Test Menu Item90'));
            System.assert(null != items[0].content); // Content has been set from the article
            System.assert(items[0].content.contains(articleVersion[0].summary));
        }
    }
}