/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  This class is a part of the CKW Search 3.0 Bundle
 *  Has tests for SearchGetImagesHelper, SearchGetFarmersHelpers, SearchCreateLogs, SearchController, ScheduledSearchLogsGAPSKnowledgeMining,
 *	SearchLogsGAPSKnowledgeMining
 **/
@isTest
public class SearchServerTests {

    static testMethod void testGetImagesHelper() {
        //Crete test data
        Menu__c menu = new Menu__c();
        menu.Label__c = 'Test menu label';
        insert(menu);
        
        Menu_Item__c menuItem = new Menu_Item__c();
        menuItem.Label__c = 'Test Menu Item';
        menuItem.Menu__c = menu.Id;
        menuItem.Content__c = 'Test Item content';
        insert(menuItem);
        
            
        String jsonRequest = 'Mal-formed JSON';
        String response = SearchGetImagesHelper.getImages(jsonRequest);
        
        //This should return result code 10
        System.assert(response.contains('10'));
        
        //Now test with a valid json request but with no attachment available
        jsonRequest = '{"request":"getImages", "imei":"imei", "imageIds":["000"]}';
        response = SearchGetImagesHelper.getImages(jsonRequest);
        System.assert(response.contains('No Images found'));        
        
        //Create attachment
        Attachment testImageAttachment = new Attachment();
        testImageAttachment.ParentId = menuItem.Id;
        testImageAttachment.Name = 'test.jpeg';
        testImageAttachment.Body = Blob.valueOf('Unit Test Attachment Body');
        insert(testImageAttachment);
        
        //Request with Id of newly inserted image id
        jsonRequest = '{"request":"getImages", "imei":"imei", "imageIds":["' + testImageAttachment.Id + '"]}';
        response = SearchGetImagesHelper.getImages(jsonRequest);
        System.assert(response.contains('Images found'));
        System.assert(response.contains(EncodingUtil.base64Encode(Blob.valueOf('Unit Test Attachment Body')))); 
    }

    //Test method for SearchGetFarmersHelpers
    static testMethod void testSearchGetFarmersHelper() {
        String jsonRequest = 'Mal-formed JSON';
        String response = SearchGetFarmersHelper.getFarmers(jsonRequest);
        
        //This should return result code 10
        System.assert(response.contains('10'));
        
        //Now test with a valid json request but with no attachment available
        jsonRequest = '{"request":"getFarmers", "imei":"imei", "farmersVersion":"2014-01-01 00:00:00:00"}';
        response = SearchGetFarmersHelper.getFarmers(jsonRequest);
        System.assert(response.contains('unknown device'));
        
        //Create test data
        District__c testDistrict = new District__c();
        testDistrict.Name = 'Test District';
        insert(testDistrict);
        
        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'TestSubcounty';
        testSubcounty.District__c = testDistrict.Id;
        insert(testSubcounty);
        
        //Create test data
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = 'TestHandset';
        testHandset.Serial_Number__c = 'TestHandset';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert(testHandset);
        
        Country__c country = new Country__c();
        country.Name = 'Uganda';
        insert country;
        
        Account testOrg = new Account();
        testOrg.Name = 'TestOrg_';
        testOrg.BillingState = 'CA';
        insert testOrg;
        
        Contact contact = new Contact();
        contact.LastName = 'David';
        //contact.Organization = testOrg;
        contact.Country__c = country.Id;
        insert contact;
        
        
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        testPerson.Gender__c = 'Male';
        testPerson.Subcounty__c = testSubcounty.Id;
        testPerson.Handset__c = testHandset.Id;
        testPerson.Contact__c = contact.Id;
        insert(testPerson);
        
        jsonRequest = '{"request":"getFarmers", "imei":"' + testHandset.IMEI__c + 
            '", "farmersVersion":"2014-01-01 00:00:00:00"}';
        response = SearchGetFarmersHelper.getFarmers(jsonRequest);
        System.assert(response.contains('No newer farmers'));
        
        Focus_Farmer__c testFocusFarmer = new Focus_Farmer__c();
        testFocusFarmer.Person__c = testPerson.Id;
        insert(testFocusFarmer);
        
        //a focus farmer follows a record of either banana, maize or coffe farmer
        Maize_Farmer__c mFarmer = new Maize_Farmer__c();
        mFarmer.Focus_Farmer__c = testFocusFarmer.Id;
        mFarmer.Registered_By__c = contact.Id;
        insert mFarmer;
        
        //unknown imei
        jsonRequest = '{"request":"getFarmers", "imei":"imei", "farmersVersion":"2014-01-01 00:00:00:00"}';
        response = SearchGetFarmersHelper.getFarmers(jsonRequest);
        System.assert(response.contains('unknown device')); 
        
        
        jsonRequest = '{"request":"getFarmers", "imei":"' + testHandset.IMEI__c + 
            '", "farmersVersion":"2014-11-03 00:00:00"}';
        response = SearchGetFarmersHelper.getFarmers(jsonRequest);
        System.assert(response.contains(testPerson.First_Name__c));       
    }

    static testMethod void testGetKeywordHelpers() {    
        Test.startTest();
        //SearchGetKeywordsHelper helper = new SearchGetKeywordsHelper();   
        String jsonRequest = 'Mal-formed JSON';
        String response = SearchGetKeywordsHelper.updateKeywords(jsonRequest);
        
        //This should return result code 10
        System.assert(response.contains('10'));
        
        //Now test with a valid json request but with no attachment available
        jsonRequest = '{"request":"getKeywords", "imei":"imei", "keywordsVersion":"2014-01-01 00:00:00", "ImagesLastUpdatedDate":"2014-01-01 00:00:00"}';
        response = SearchGetKeywordsHelper.updateKeywords(jsonRequest);       
        
        //Create test data
        District__c testDistrict = new District__c();
        testDistrict.Name = 'Test District';
        insert(testDistrict);
        
        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'TestSubcounty';
        testSubcounty.District__c = testDistrict.Id;
        insert(testSubcounty);        
                
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = 'TestHandset';
        testHandset.Serial_Number__c = 'TestHandset';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert(testHandset);
        
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        testPerson.Gender__c = 'Male';
        testPerson.Subcounty__c = testSubcounty.Id;
        testPerson.Handset__c = testHandset.Id;
        insert(testPerson);
        
        //Create test group
        Group__c testGroup = new Group__c();
        testGroup.Name = 'TestGroup';
        insert(testGroup);
        
        //Link person with group
        Person_Group_Association__c pga = new Person_Group_Association__c();
        pga.Person__c = testPerson.Id;
        pga.Group__c = testGroup.Id;
        insert(pga);        
        
        // Create a menu and item
        Menu__c menu = new Menu__c();
        menu.Label__c = 'Test Menu89';
        database.insert(menu);
    
        Menu_Item__c menuItem = new Menu_Item__c();
        menuItem.Label__c = 'Test Menu Item90';
        menuItem.Menu__c = menu.Id;
        database.insert(menuItem);        
        
        //Create attachment
        Attachment testImageAttachment = new Attachment();
        testImageAttachment.ParentId = menuItem.Id;
        testImageAttachment.Name = 'test.jpeg';
        testImageAttachment.Body = Blob.valueOf('Unit Test Attachment Body');
        insert(testImageAttachment);
        
        Menu_Item__c deletedMenuItem = new Menu_Item__c();
        deletedMenuItem.Label__c = 'Test Menu Deleted';
        deletedMenuItem.Menu__c = menu.Id;
        database.insert(deletedMenuItem);
        
        delete(deletedMenuItem);
        
        //Link menu to group
        Menu_Group_Association__c mga = new Menu_Group_Association__c();
        mga.Group__c = testGroup.Id;
        mga.Menu__c = menu.Id;
        insert(mga);
        
        jsonRequest = '{"request":"getKeywords", "imei":"' + testHandset.IMEI__c + 
            '", "keywordsVersion":"2014-01-01 00:00:00", "ImagesLastUpdatedDate":"2014-01-01 00:00:00"}';
        response = SearchGetKeywordsHelper.updateKeywords(jsonRequest);
        System.debug(jsonRequest);
        System.debug(response);
        System.assert(response.contains('Success'));
        
        //unknown imei
        jsonRequest = '{"request":"getKeywords", "imei":"imei", "keywordsVersion":"2014-01-01 00:00:00", "ImagesLastUpdatedDate":"2014-01-01 00:00:00"}';
        response = SearchGetKeywordsHelper.updateKeywords(jsonRequest);
        System.debug(jsonRequest);
        System.debug(response);
        System.assert(response.contains('unknown device'));
        Test.stopTest();
    }

    static testMethod void testGetCountryCodeHelper() {   
        Test.startTest();
        String jsonRequest = 'Mal-formed JSON';
        String response = SearchGetCountryCodeHelper.getCountryCode(jsonRequest);
        
        //This should return result code 10
        System.assert(response.contains('10'));
        Country__c testCountry = new Country__c();
        testCountry.ISO_Standard_Code__c ='UG';
        insert(testCountry);        
        
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = 'TestHandset';
        testHandset.Serial_Number__c = 'TestHandset';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert(testHandset);
        
                //Create test data
        District__c testDistrict = new District__c();
        testDistrict.Name = 'Test District';
        insert(testDistrict);
        
        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'TestSubcounty';
        testSubcounty.District__c = testDistrict.Id;
        insert(testSubcounty);
        
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        testPerson.Gender__c = 'Male';
        testPerson.Subcounty__c = testSubcounty.Id;
        testPerson.Handset__c = testHandset.Id;
        testPerson.Country__c = testCountry.Id;
        insert(testPerson);        
        
        jsonRequest = '{"request":"getCountryCode", "imei":"' + testHandset.IMEI__c + '"}';
        response = SearchGetCountryCodeHelper.getCountryCode(jsonRequest);
        System.assert(response.contains('UG'));
        Test.stopTest();
    }

    static testMethod void testCreateSearchLogEntry() {   
        Test.startTest();
        String jsonRequest = 'Mal-formed JSON';
        
        String response = SearchCreateLogs.createSearchLogs(jsonRequest);
        //This should return result code 10
        System.assert(response.contains('10'));
        
        jsonRequest = '{"request":"createLogs", "imei":"UNKNOWN DEVICE", "searchLogs":[]}';
        //Test for unknown device
        response = SearchCreateLogs.createSearchLogs(jsonRequest);
        
        //This should return message about unknown user
        System.assert(response.contains('unknown user'));
        
        //Create test data
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = 'TestHandset';
        testHandset.Serial_Number__c = 'TestHandset';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert(testHandset);
        
                //Create test data
        District__c testDistrict = new District__c();
        testDistrict.Name = 'Test District';
        insert(testDistrict);
        
        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'TestSubcounty';
        testSubcounty.District__c = testDistrict.Id;
        insert(testSubcounty);
        
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        testPerson.Gender__c = 'Male';
        testPerson.Subcounty__c = testSubcounty.Id;
        testPerson.Handset__c = testHandset.Id;
        insert(testPerson);
        
        Person__c testPerson2 = new Person__c();
        testPerson2.First_Name__c = 'FirstName';
        testPerson2.Last_Name__c = 'LastName';
        testPerson2.Gender__c = 'Male';
        testPerson2.Subcounty__c = testSubcounty.Id;        
        insert(testPerson2);
        
        Focus_Farmer__c testFocusFarmer = new Focus_Farmer__c();
        testFocusFarmer.Person__c = testPerson2.Id;
        insert(testFocusFarmer);
        
        // Create a menu and item
        Menu__c menu = new Menu__c();
        menu.Label__c = 'Test Menu89';
        database.insert(menu);

        Menu_Item__c menuItem = new Menu_Item__c();
        menuItem.Label__c = 'Test Menu Item90';
        menuItem.Menu__c = menu.Id;
        database.insert(menuItem);
        
        jsonRequest = '{"request":"createLogs", "imei":"' + testHandset.IMEI__c + 
            '", "searchLogs":[{"id":"1", "menuItemId":"' + menuItem.Id + '", "clientId":"' + 
            testFocusFarmer.Id + '", "gpsLocation":"", "submissionLocation":"", "testLog":false , "dateCreated":"2015-01-22T18:29:11" }]}';
        //Test for unknown device
        response = SearchCreateLogs.createSearchLogs(jsonRequest);
        System.assert(response.contains('Request Successful'));
        Test.stopTest();
    }
    
    //
    // test methods for SearchLogsGAPSKnowledgeMining and related actions
    //
    public static String CRON_EXP = '0 0 1 * * ?'; // run every day at 1am
    
    static testMethod void testScheduleLogsKnowlegeMining() {
    	    			
    	Country__c c = new Country__c();
    	c.Name = 'Uganda';
    	insert c;
    	
        // Create some searches for data mining
        List<String> queries = new List<String>{
        	// banana search logs queries
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_BANANA_MENUITEM + 'GAP 1:Type of fertilizers used',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_BANANA_MENUITEM + 'GAP 2:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_BANANA_MENUITEM + 'GAP 3:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_BANANA_MENUITEM + 'GAP 4:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_BANANA_MENUITEM + 'GAP 5:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_BANANA_MENUITEM + 'GAP 6:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_BANANA_MENUITEM + 'GAP 7:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_BANANA_MENUITEM + 'GAP 8:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_BANANA_MENUITEM + 'GAP 9:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_BANANA_MENUITEM + 'GAP 10:',
        	// banana search logs queries
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_COFFEE_MENUITEM + 'GAP 1:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_COFFEE_MENUITEM + 'GAP 2:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_COFFEE_MENUITEM + 'GAP 3:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_COFFEE_MENUITEM + 'GAP 4:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_COFFEE_MENUITEM + 'GAP 5:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_COFFEE_MENUITEM + 'GAP 6:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_COFFEE_MENUITEM + 'GAP 7:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_COFFEE_MENUITEM + 'GAP 8:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_COFFEE_MENUITEM + 'GAP 9:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_COFFEE_MENUITEM + 'GAP 10:',
        	// banana search logs queries
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_MAIZE_MENUITEM + 'GAP 1:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_MAIZE_MENUITEM + 'GAP 2:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_MAIZE_MENUITEM + 'GAP 3:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_MAIZE_MENUITEM + 'GAP 4:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_MAIZE_MENUITEM + 'GAP 5:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_MAIZE_MENUITEM + 'GAP 6:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_MAIZE_MENUITEM + 'GAP 7:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_MAIZE_MENUITEM + 'GAP 8:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_MAIZE_MENUITEM + 'GAP 9:',
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_MAIZE_MENUITEM + 'GAP 10:',
        	//will be from unprofiled farmer
        	'CKW 3.0 Search ' + SearchLogsGAPSKnowledgeMining.KNOWLEDGE_BANANA_MENUITEM + 'GAP 1:'
        };
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        testPerson.Gender__c = 'Male';
        database.insert(testPerson);
        Person__c testPerson2 = new Person__c();
        testPerson2.First_Name__c = 'FirstName';
        testPerson2.Last_Name__c = 'LastName';
        testPerson2.Gender__c = 'Male';
        database.insert(testPerson2);
        
        //focus famers
        List<Focus_Farmer__c> ffs = new List<Focus_Farmer__c>();
    	Focus_Farmer__c ff = new Focus_Farmer__c();
    	ff.Person__c = testPerson2.Id;
    	ff.Farmer_Type__c = 'Banana';
    	ffs.add(ff);
    	Focus_Farmer__c ff1 = new Focus_Farmer__c();
    	ff1.Person__c = testPerson2.Id;
    	ff1.Farmer_Type__c = 'Coffee';
    	ffs.add(ff1);
    	Focus_Farmer__c ff11 = new Focus_Farmer__c();
    	ff11.Person__c = testPerson2.Id;
    	ff11.Farmer_Type__c = 'Maize';
    	ffs.add(ff11);
    	insert ffs;
    	
        Contact contact = new Contact();
        contact.FirstName = 'pedrito';
        contact.LastName = 'perez';
        insert contact;
        
    	Banana_Farmer__c bf = new Banana_Farmer__c();
    	bf.Focus_Farmer__c = ff.Id;
    	bf.Registered_By__c = contact.Id;
    	insert bf;
    	Coffee_Farmer__c bf1 = new Coffee_Farmer__c();
    	bf1.Focus_Farmer__c = ff1.Id;
    	bf1.Registered_By__c = contact.Id;
    	insert bf1;
    	Maize_Farmer__c bf11 = new Maize_Farmer__c();
    	bf11.Focus_Farmer__c = ff11.Id;
    	bf11.Registered_By__c = contact.Id;
    	insert bf11;
    	
    	Banana_Farmer_GAPs_Selection__c gs = new Banana_Farmer_GAPs_Selection__c();
    	gs.CKW_Contact__c = contact.Id;
    	gs.Banana_Farmer__c = bf.Id;
    	gs.Location__Latitude__s = 3.000;
    	gs.Location__Longitude__s = 0.0000;
    	insert gs;
    	
    	Coffee_Farmer_GAPs_Selection__c gs1 = new Coffee_Farmer_GAPs_Selection__c();
    	gs1.CKW_Contact__c = contact.Id;
    	gs1.Coffee_Farmer__c = bf1.Id;
    	gs1.Location__Latitude__s = 3.000;
    	gs1.Location__Longitude__s = 0.0000;
    	insert gs1;
    	
    	Maize_Farmer_GAPs_Selection__c gs11 = new Maize_Farmer_GAPs_Selection__c();
    	gs11.CKW_Contact__c = contact.Id;
    	gs11.Maize_Farmer__c = bf11.Id;
    	gs11.Location__Latitude__s = 3.000;
    	gs11.Location__Longitude__s = 0.0000;
    	insert gs11;
        
        List<Search_Log__c> logs = new List<Search_Log__c>();
        for (Integer i = 0; i < 31; i++) {
            Search_Log__c log = new Search_Log__c();
            log.Interviewer__c = testPerson2.id;
            log.Interviewee__c = testPerson2.Id;
            log.Server_Entry_Time__c = Datetime.now().addDays(-1);
            log.Handset_Submit_Time__c = Datetime.now().addDays(-1);
            log.Submission_GPS_Timestamp__c = Datetime.now().addDays(-1);
            log.Latitude__c = 0.00;
            log.Longitude__c = 0.00;
            log.Altitude__c = 0.00;
            log.Accuracy__c = 0.00;
            log.Category__c = 'Category';
            log.Query__c = queries.get(i);
            log.Response__c = 'Content';
            if(i == 30) {
            	log.Interviewer__c = testPerson.id;
            	log.Interviewee__c = testPerson.Id;            	
            }
            logs.add(log);
        }
        database.insert(logs);
		  
		Test.startTest();	
  		// Schedule the test job
  		String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP,  new ScheduledSearchLogsGAPSKnowledgeMining());         
		// Verify the scheduled job hasn't run yet.
		Banana_GAPs_Knowledge__c[] bgk = [SELECT Id FROM Banana_GAPs_Knowledge__c WHERE Source__c = 'Search'];
		System.assertEquals(bgk.size(), 0);
		
        String query = 
		'SELECT '								+
			'Id, '								+
			'Interviewer__c, '					+
			'Interviewee__c, '					+
			'Submission_GPS_Timestamp__c, '		+
			'Interviewee__r.Name, '				+
			'Query__c '							+
		'FROM '									+
			'Search_Log__c '					+
		'WHERE '								+
			'Server_Entry_Time__c = YESTERDAY';

		System.assert(Database.query(query).size() > 0);
		ID batchprocessid = Database.executeBatch(new SearchLogsGAPSKnowledgeMining(query), 50);//only one batch in a test method
		
		Test.stopTest();

		Banana_GAPs_Knowledge__c[] bgka = [SELECT Id FROM Banana_GAPs_Knowledge__c WHERE Source__c = 'Search'];
      	System.assert(bgka.size() == 10);
      	
      	Banana_GAPs_Knowledge__c[] knowledgeDtails = [
      		SELECT 
      			Id 
  			FROM 
  				Banana_GAPs_Knowledge__c 
  			WHERE 
  				Discussed_Soil_Fertility_Management__c = 'Yes' AND 
  				Soil_Fertility_Management_Topics__c = 'Type of fertilizers used' AND
  				Source__c = 'Search'
  		];
      	System.assert(knowledgeDtails.size() == 1);
    }
}