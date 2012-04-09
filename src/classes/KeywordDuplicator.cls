public with sharing class KeywordDuplicator {
    private String searchDatabase;
    private String serverUrl;
    List<String> keywordList = new List<String>();
    private void initializeServerConstants() {

        Server_Configuration__c configuration = [
            SELECT
                URL__c,
                Search_Database__c
            FROM
                Server_Configuration__c LIMIT 1];
                
        this.serverUrl = configuration.URL__c;
        this.searchDatabase = configuration.Search_Database__c; 
    }
    
    public KeywordDuplicator() {
        initializeServerConstants();
        getKeywords();
        
    }
    
    private void getKeywords() {
         String category = 'Weather';
         String keywordQuery = 
         'SELECT '+ 
             'keyword.id, '+ 
             'category.name, ' +
             'keyword.keyword, ' +
             'keyword.content ' +
         'FROM ' +
             this.searchDatabase + '.keyword ' +
         'INNER JOIN ' +
             this.searchDatabase + '.category ' +
         'ON '+
             'keyword.categoryId = category.id ' +
         'WHERE NOT ' + 
             'keyword.isDeleted ' +
         'AND category.name = \'' + category + '\' ';        
        
        system.debug(keywordQuery);
        String requestBody = constructRequestXml('Search', keywordQuery); 
        String queryResult = SqlHelpers.postServletRequest(this.serverUrl, 'select', requestBody);
        system.debug(queryResult);
        parseKeywords(queryResult); 
        loopThruKeywords(keywordList);
    }
    
    private String constructRequestXml(String target, String query) {
        String requestBody = '<?xml version="1.0"?>' +
            '<SelectRequest xmlns="http://schemas.applab.org/2010/07" target="' + target + '">' +
            query + '</SelectRequest>';
        return requestBody;
    }
    
    private void parseKeywords(String keywordXml) {
        system.debug('xml :' +keywordXml);
        XmlStreamReader keywordResultReader = new XmlStreamReader(keywordXml);
        keywordResultReader.next();
        
        while (keywordResultReader.hasNext()) {
            keywordResultReader.next();
            if (keywordResultReader.isStartElement()) {
                parseSearchTableRow(keywordResultReader);
            }
        }
        keywordResultReader.next();
        
    }

    private void parseSearchTableRow(XmlStreamReader keywordResultReader) {
        system.debug('localname = '+keywordResultReader.getLocalName());
        integer count = 0;
        if (keywordResultReader.getLocalName() == 'row') {
            count ++;
            system.debug('we have a row ');
            keywordResultReader.next();
            
            String keywordId = parseElement(keywordResultReader);
            String category = parseElement(keywordResultReader);
            String keyword = parseElement(keywordResultReader);
            String content = parseElement(keywordResultReader);
            
            keyword = category + ' ' + keyword;
            system.debug('final keyword is '+keyword);
            keywordList.add(keyword);
 
        }
        
    }
    
    private void loopThruKeywords(List<String> keywordList) {
        System.debug('we have '+keywordList.size() +  ' keywords to loop thru');
        for (String keyword : keywordList) {
            String[] tokens = keyword.split('\\s');
            boolean menuItemExists = false;
            String parentMenuItemId = null;
            for (integer i = 0; i < tokens.size(); i ++) {
                if (i == 0) {
                    //check whether exists in SF
                    try {
                        menuItemExists = isMenuItemInSalesforce(parentMenuItemId, tokens[i]);
                    } catch (Exception e) {
                        System.debug(e);
                    }
                    if (menuItemExists) {
                        parentMenuItemId = getMenuItemId(parentMenuItemId, tokens[i]);
                    }
                    else {
                        //create the category and its subsequent menu Items
                        parentMenuItemId = createMenuItem(parentMenuItemId, tokens[i]);
                    }
                }
                else {
                    //at this stage parentMenuItem exists, else trouble!!
                    //check whether exists in SF
                    try {
                        menuItemExists = isMenuItemInSalesforce(parentMenuItemId, tokens[i]);
                    } catch (Exception e) {
                        System.debug(e);
                    }
                    if (menuItemExists) {
                        //get its id and assign it to parentMenuItemId
                        parentMenuItemId = getMenuItemId(parentMenuItemId, tokens[i]);
                    }
                    else {
                        //create the category and its subsequent menu Items
                        parentMenuItemId = createMenuItem(parentMenuItemId, tokens[i]);
                    }
                    if (i == tokens.size() - 1) {
                        //add the content
                        //createMenuItemWithContent(parentMenuItemId, tokens[i], keyword.getContent());
                    }
                }
            }
        }
    }   
    
    private String createMenuItem(String parentMenuItemId, String newItem) {
        Menu_Item__c menuItem = new Menu_Item__c();
        menuItem.Label__c = newItem;
        menuItem.Parent_Item__c = parentMenuItemId;
        menuItem.Menu__c = 'a0YV0000000BKgy';
        database.insert(menuItem);
        Menu_Item__c menuiitem = [Select Id FROM Menu_Item__c WHERE Parent_Item__c =:parentMenuItemId AND Label__c =: newItem];
        return menuiitem.Id;
    }
    
    private void createMenuItemWithContent(String parentMenuItemId, String newItem, String content) {
        Menu_Item__c menuItem = new Menu_Item__c();
        menuItem.Label__c = newItem;
        menuItem.Parent_Item__c = parentMenuItemId;
        menuItem.Menu__c = 'a0YV0000000BKgy';
        menuItem.Article_Id__c = content;
    }
    private boolean isMenuItemInSalesforce(String parentMenuItemId, String menuItem) {
        Menu_Item__c[] menuItems = [Select Id FROM Menu_Item__c WHERE Parent_Item__c =:parentMenuItemId AND Label__c =: menuItem];
        if (menuItems.size() > 0) {
            return true;
        }
        return false;
    }

    private String getMenuItemId(String parentMenuItemId, String existingMenuItem) {
        Menu_Item__c menuItem = [Select Id FROM Menu_Item__c WHERE Parent_Item__c =:parentMenuItemId AND Label__c =: existingMenuItem];
        return menuItem.Id;     
    }
    
    private String parseElement(XmlStreamReader reader) {
        reader.next(); // skip the opening <column> tag

        String result = reader.getText();

        reader.next(); // move on to the next element
        reader.next(); // skip the closing </column> tag

        return result;
    }
}