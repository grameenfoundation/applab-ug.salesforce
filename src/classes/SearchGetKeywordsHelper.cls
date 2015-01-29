/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  This class is a part of the CKW Search 3.0 Bundle
 *  Tests are in SearchServerTests class
 **/
public class SearchGetKeywordsHelper {

    /** 
     * Given a JSON String with IMEI and keywordsversion
     * return JSON with menus, menuitems and images
     */
    public static String updateKeywords(String JsonRequestString) {
    
        //Create the response wrapper for this request
        KeywordsResponseWrapper responseWrapper = new KeywordsResponseWrapper();
          
        //Build the request object
        KeywordsRequestWrapper request = null;
        try {
            request = (KeywordsRequestWrapper) JSON.deserialize(jsonRequestString, KeywordsRequestWrapper.class);
        } catch(Exception e) {
            responseWrapper.resultCode = '10';
            responseWrapper.resultMessage = 'Request could not be decoded';
            return JSON.serializePretty(responseWrapper);
        }
        Person__c[] people = [
            SELECT
                Name,
                Id,
                Contact__c
            FROM
                Person__c
            WHERE
                Handset__r.IMEI__c = :request.imei
            LIMIT 1];
        if(people.size() == 0) {
            //unknown device
            responseWrapper.resultCode = '10';
            responseWrapper.resultMessage = 'Request from unknown device';
            return JSON.serializePretty(responseWrapper);
        }        
        String newVersion = String.valueOf(Datetime.now());
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
        responseWrapper.resultCode = '0';
        responseWrapper.resultMessage = 'Success';
        responseWrapper.total = String.valueOf(total);
        responseWrapper.menus = menus;
        responseWrapper.menuItems = menuItems;
        responseWrapper.version = newVersion;
        if (deletedMenuItems.size() > 0) {
            responseWrapper.deletedMenuItems = deletedMenuItems;
        }
        if (deletedImages.size() > 0) {
            responseWrapper.deletedImages = deletedImages;
        }
        if (updatedImages.size() > 0) {
            responseWrapper.images = updatedImages;
        }        
            
        return JSON.serializePretty(responseWrapper);
    }

    private static List<LocalMenu> getMenus(KeywordsRequestWrapper request) {
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
                        pg.Person__r.Handset__r.IMEI__c = :request.imei) ];

        // generate LocalMenus from menuAssocs
        List<LocalMenu> menus = new List<LocalMenu>();
        for (Menu_Group_Association__c menuAssoc : menusAssocs) {
             menus.add(new LocalMenu(menuAssoc.Menu__r.Id, menuAssoc.Menu__r.Label__c));
        }
        return menus;
    }

    class KeywordsRequestWrapper {
        String request {get; set;}
        String imei {get; set;}
        String keywordsVersion {get; set;}
        List<String> menuIds {get; set;}
        String ImagesLastUpdatedDate {get; set;}
    }
    
    class KeywordsResponseWrapper {
        String resultCode {get;set;}
        String resultMessage {get;set;}
        String total {get; set;}
        String version {get; set;}
        List<LocalMenu> menus {get; set;}
        List<LocalMenuItem> menuItems {get; set;}
        List<ObjectId> images {get; set;}
        List<ObjectId> deletedMenuItems {get; set;}
        List<ObjectId> deletedImages {get; set;}
    }
    
    class LocalMenu {
        String label;
        String id;

        LocalMenu(String menuId, String name) {
            this.id = menuId;
            this.label= name;
        }
    }

    class LocalMenuItem {
        String label;
        String id;
        String menu_id;
        String parent_id;
        String content;
        Decimal position;

        // constructor excludes content as this is generated differently
        LocalMenuItem(String name, String id, String pId, String menuId,
                      String content, Decimal position, String attribution,
                      Datetime lastUpdatedDate) {
            this.label = name;
            this.id = id;
            this.menu_id = menuId;
            this.parent_id = pId;
            this.position = position;
            this.content = setContent(content, attribution, lastUpdatedDate);
        }
        
        String setContent(String content, String attribution, Datetime lastUpdatedDate) {            
            if (content == null) {
                return 'No Content \n\nLast Updated: \n' + String.valueOf(lastUpdatedDate) + '\n\n';
            }
            if (attribution == null) {
                return content + '\n\nLast Updated: \n' + String.valueOf(lastUpdatedDate) + '\n\n';
            }
            return content + '\n\nAttribution: ' + attribution + '\n\nLast Updated: \n' + String.valueOf(lastUpdatedDate) + '\n\n';            
        }
    }

    class ObjectId {
        String id;

        ObjectId(String objectId) {
            this.id = objectId;
        }
    }
    
    /**
     * Convenience method to allow testing this method without passing in a json request
     **/
    private static void getNewUpdatedAndDeletedMenuItems(List<LocalMenu> menus, List<LocalMenuItem> items,
                                                      List<ObjectId> deletedMenuItems, KeywordsRequestWrapper request) {
         getNewUpdatedAndDeletedMenuItems(menus, items, deletedMenuItems, request.menuIds, request.keywordsVersion);
    }

    private static void getNewUpdatedAndDeletedMenuItems(List<LocalMenu> menus, List<LocalMenuItem> items,
                                                      List<ObjectId> deletedMenuItems, String[] requestMenuIds, 
                                                      String keywordsLastUpdatedDate) {

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
        
            DateTime lastUpdated = datetime.valueOf(keywordsLastUpdatedDate);
            for (Menu_Item__c menuItem : [
                SELECT
                    Id,
                    Label__c,
                    Parent_Item__c,
                    Menu__c,
                    Article_Id__c,
                    Content__c,
                    Position__c,
                    Attribution__c,
                    Last_Modified_Date__c,
                    IsDeleted
                FROM
                    Menu_Item__c
                WHERE
                    Menu__c IN :updatedMenuIds
                AND
                    (
                        Last_Modified_Date__c > :lastUpdated
                      OR                       
                        LastModifiedDate > :lastUpdated
                    )
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
                                                            menuItem.Content__c, menuItem.Position__c,
                                                            menuItem.Attribution__c, menuItem.Last_Modified_Date__c);
                    items.add(mItem);
                    idToItemMap.put(menuItem.Id, mItem);
                }
            }
        }

        if (newMenuIds.size() > 0) {
        LocalMenuItem mItem;
            for (Menu_Item__c menuItem : [
                 SELECT
                     Id,
                     Label__c,
                     Parent_Item__c,
                     Menu__c,
                     Article_Id__c,
                     Content__c,
                     Attribution__c,
                     Last_Modified_Date__c,
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

                 mItem = new LocalMenuItem(menuItem.Label__c, menuItem.Id,
                                                            menuItem.Parent_Item__c, menuItem.Menu__c,
                                                            menuItem.Content__c, menuItem.Position__c,
                                                            menuItem.Attribution__c, menuItem.Last_Modified_Date__c);
                 items.add(mItem);
                 idToItemMap.put(menuItem.Id, mItem);
            }
        }
    }
    
    private static void getNewUpdatedAndDeletedImages(List<LocalMenuItem> menuItems, List<ObjectId> deletedMenuIds,
                                                   List<ObjectId> updatedImages, List<ObjectId> deletedImages,
                                                   KeywordsRequestWrapper request) {

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
                LastModifiedDate > :datetime.valueOf(request.ImagesLastUpdatedDate)
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
}