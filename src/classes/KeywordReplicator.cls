public with sharing class KeywordReplicator {
    private String searchDatabase;
    private String serverUrl;
    private Map<String, String> categoryIdNameMap = new Map<String, String>();
    
    public KeywordReplicator() {
     initializeServerConstants();
     getKeywords();
    }
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
    private void getKeywords() {
    //String category = 'Crops';
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
             'keyword.deleted' ; 
     
        String requestBody = constructRequestXml('Search', keywordQuery); 
        String queryResult = SqlHelpers.postServletRequest(this.serverUrl, 'select', requestBody);
        parseKeywords(queryResult);      
    }
    
    private String constructRequestXml(String target, String query) {
        String requestBody = '<?xml version="1.0"?>' +
            '<SelectRequest xmlns="http://schemas.applab.org/2010/07" target="' + target + '">' +
            query + '</SelectRequest>';
        return requestBody;
    }
    
    private void parseKeywords(String keywordXml) {
        XmlStreamReader keywordResultReader = new XmlStreamReader(keywordXml);
        keywordResultReader.next();
        
        while (keywordResultReader.hasNext()) {
            if (keywordResultReader.isStartElement()) {
                parseSearchTableRow(keywordResultReader);
            }
        }
    }
    
    private void parseSearchTableRow(XmlStreamReader keywordResultReader) {
        if (keywordResultReader.getLocalName() == 'row') {
            keywordResultReader.next();
            
            String keywordId = parseElement(keywordResultReader);
            String category = parseElement(keywordResultReader);
            String keyword = parseElement(keywordResultReader);
            String content = parseElement(keywordResultReader);
            
            //Map<String, String> categoryList
            //List<Menu_Item__c> categoryMenuItems = new List<Menu_Item__c>();
            if (!doesCategoryExist(category, 'a0YV0000000BKgyMAG')) {
                Menu_Item__c categoryMenuItem = new Menu_Item__c();
                categoryMenuItem.Label__c = category;
                categoryMenuItem.Menu__c = 'a0YV0000000BKgyMAG';
                categoryMenuItem.Parent_Item__c = 'a0YV0000000BKgyMAG';
                database.insert(categoryMenuItem);
                //Menu_Item__c menu = [SELECT Id, Label__c FROM Menu_Item__c WHERE Label__c =:category ];
            }
            else {// get the category id from SF
            
            }
            //move to the keyword column
            parseKeyword(null ,'a0YV0000000BKgyMAG', keyword);
        }
    }
    
    private String parseElement(XmlStreamReader reader) {
        reader.next(); // skip the opening <column> tag

        String result = reader.getText();

        reader.next(); // move on to the next element
        reader.next(); // skip the closing </column> tag
        System.debug('parsing ...' + result);
        return result;
    }
    
    private void parseKeyword (String parentItem, String category, String keyword) {
        String[] keywordItems = keyword.split('\\s');
        String parentMenuItem = '';
        for (integer i = 0; i < keywordItems.size(); i ++) {
        
            if (!doesMenuItemExist((parentItem == null ? category : parentItem), keywordItems[i])) {
                Menu_Item__c menuItem = new Menu_Item__c();
                menuItem.Parent_Item__c =  parentMenuItem == '' ? category : parentMenuItem;
                menuItem.Menu__c = 'a0YV0000000BKgyMAG';
                menuItem.Label__c = keywordItems[i];
                database.insert(menuItem);
                //get its id, then create all the rest in keyword items array
            }
            else {//it exists, get its id
                //Menu_Item__c menu = [Select Id, Label__c FROM Menu_Item__c WHERE Label__c = :keywordItems[i]];
                //parentMenuItem = menu.Id;
                //check subsequent keyword items in array
            }
        }
    }
    
    private boolean doesMenuItemExist(String parentItem, String keyword) {
        List <Menu_Item__c> menus = database.query('SELECT Label__c FROM Menu_Item__c WHERE Label__c = ' + keyword +' AND Parent_Item__c = '+ parentItem  );
        if (menus.size() > 0) {
            return true;
        }
        else {
            return false;
        }   
    }
    private boolean doesCategoryExist(String category, String search) {
        List <Menu_Item__c> menus = database.query('SELECT Label__c FROM Menu_Item__c WHERE Label__c = '+category +' AND Parent__c = '+search );
        if (menus.size() > 0) {
            return true;
        }
        else {
            return false;
        }  
    }
}