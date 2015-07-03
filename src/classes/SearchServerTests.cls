/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  This class is a part of the CKW Search 3.0 Bundle
 *  Has tests for SearchGetImagesHelper, SearchGetFarmersHelpers, SearchCreateLogs, SearchController, ScheduledSearchLogsGAPSKnowledgeMining,
 *  SearchLogsGAPSKnowledgeMining
 *  ChangeSearchLogsOwnerShip 
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
        
        OBUL_Coffee_Farmer__c oFarmer = new OBUL_Coffee_Farmer__c();
        oFarmer.Focus_Farmer__c = testFocusFarmer.Id;
        oFarmer.Registered_By__c = contact.Id;
        insert oFarmer;
        
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
            testFocusFarmer.Id + '", "gpsLocation":"", "submissionLocation":"", "testLog":false , "dateCreated":"2015-01-22T18:29:11" , ' +
            '"content": "3. Maize GAPs Gap 6:maize harvesting and post harvest handling Post-harvest handling (Drying, shelling, storage, sorting and grading) Common insect pests of stored grain General Storage Pest control methods How to mix insecticide powder with threshed grain:"}]}';
        //Test for unknown device
        response = SearchCreateLogs.createSearchLogs(jsonRequest);
        System.assert(response.contains('Request Successful'));
        List<Search_Log__c> logs = [SELECT Id, Interviewee__c FROM Search_Log__c];
        System.assert(logs.size() == 1);
        System.assert(logs.get(0).Interviewee__c.equals(testPerson2.Id));
        Test.stopTest();
    }
    
    public static String CRON_EXP = '0 0 1 * * ?'; // run every day at 1am
    
    static testMethod void testChangeSearchLogOwner() {
    
        Person__c testPerson2 = new Person__c();
        testPerson2.First_Name__c = 'FirstName';
        testPerson2.Last_Name__c = 'LastName';
        testPerson2.Gender__c = 'Male';
        database.insert(testPerson2);
                
        Search_Log__c log = new Search_Log__c();
        log.Interviewer__c = testPerson2.id;
        log.Interviewee__c = testPerson2.Id;
        log.Server_Entry_Time__c = Datetime.now();
        log.Handset_Submit_Time__c = Datetime.now();
        log.Submission_GPS_Timestamp__c = Datetime.now();
        insert log;
        
        User user = [select id from user where name = 'Information Services'];
        testPerson2.OwnerId = user.Id;
        update testPerson2;
        
        System.assert(log.OwnerId != user.Id);
        
        Test.startTest();
        String query = 'SELECT Id, OwnerId FROM Person__c';
        Database.executeBatch(new ChangeSearchLogsOwnerShip(query), 7);
        String jobId = System.schedule('ChangeSearchLogsOwnerShip', CRON_EXP, new ScheduledChangeSearchLogsOwnerShip());   
        Test.stopTest();           
        
        //System.assert(log.OwnerId == user.Id);
    }
}