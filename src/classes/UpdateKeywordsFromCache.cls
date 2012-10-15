global class UpdateKeywordsFromCache {    
    /**
    * Get keywords as document cache
    */
    webservice static String getCachedKeywords(String imei) {
        
        String menuName = getAllowedMenuByImei(imei);
        
        if (null == menuName) {
        	return '';
        }
        menuName = menuName.trim().remove(' ');
        
        Document doc = 
            [
             SELECT 
                 Id,
                 Body
             FROM 
                 Document
             WHERE
                 Name = :menuName
             LIMIT 1
             ];
         return doc.Body.toString();
    }
    
    // For now this takes the top most menu
    private static String getAllowedMenuByImei(String imei) {
    	
    	Person__c person = Utils.loadPersonImei(imei);
    	List<Id> groupIds = new List<Id>(); 
    	
    	// select groups in which person belongs
    	for (Person_Group_Association__c association : [
    		SELECT
    		  	Group__c 
    		FROM
    		  	Person_Group_Association__c
    		WHERE
    		  	Person__c = :person.Id
    	]) {
    		groupIds.add(association.Group__c);
    	}
    	
    	// Select one menu group association and get relevant Menu label
    	List<Menu__c> menus = [
    		SELECT
    			Id,
    			Label__c
    		FROM
    			Menu__c
    		WHERE
    			Id
    		  IN (
    		  		SELECT
    		  			Menu__c
    		  		FROM
    		  			Menu_Group_Association__c
    		  		WHERE
    		  			Group__c
    		  		  IN :(groupIds) 
    		  	)
    		];
    	
		if (null == menus || menus.size() == 0) {
			return null;
		}
    	return menus[0].Label__c;
    }
    
    static testmethod void testAll() {    	
    	// create test people
    	Person__c testPerson = Utils.createTestPerson(null, '234342', true, null, null);
    	database.insert(testPerson);
    	
    	Person__c testPerson2 = Utils.createTestPerson(null, '22222', true, null, null);
    	database.insert(testPerson2);
    	
    	// create Menu
    	Menu__c testMenu = new Menu__c();
    	testMenu.Label__c = 'Test Menu';
    	database.insert(testMenu);
    	
    	// create test group
    	Group__c testGroup = new Group__c();
    	testGroup.Name = 'test Group';
    	testGroup.Active__c = true;
    	database.insert(testGroup);
    	
    	// create menu group association
    	Menu_Group_Association__c mgAssoc = new Menu_Group_Association__c();
    	mgAssoc.Group__c = testGroup.Id;
    	mgAssoc.Menu__c = testMenu.Id;
    	database.insert(mgAssoc);
    	
    	// create person group association
    	Person_Group_Association__c pgAssoc = new Person_Group_Association__c();
    	pgAssoc.Person__c = testPerson.Id;
    	pgAssoc.Group__c = testGroup.Id;
    	database.insert(pgAssoc);
    	
    	// create document and save
    	Document doc = new Document();
        doc.Name = testMenu.Label__c.remove(' ');
        doc.Body = Blob.valueOf('representative data for search, this would be Json');
        doc.ContentType = 'text/plain';
        Folder f = [Select Id from Folder where Name = 'Search' LIMIT 1];
        doc.FolderId= f.Id;
        doc.Type = 'txt';
        insert doc;
    	
    	// test cases when there is a related menu and where there isnt 
    	system.assert(getCachedKeywords('234342') != '');
    	system.assert(getCachedkeywords('22222') ==  '');   	
    }
}