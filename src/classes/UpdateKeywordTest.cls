/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class UpdateKeywordTest {

    static testMethod void TestGetKeywords() {
        
        // Create a person with a phone, assign him to a group, assign content to that group
        Phone__c phone = Utils.createTestHandset('12345');
        insert phone;
        District__c district = Utils.createTestDistrict('12345');
        insert district;
        Person__c person = Utils.createTestPerson(phone.Id, '12345', false, district.Id, 'Male');
        insert person;
        Group__c grp = new Group__c(Name='Test Group');
        insert grp;
        Person_Group_Association__c pga = new Person_Group_Association__c(Group__c = grp.Id, Person__c = person.Id);
        insert pga;
        // create content
        Menu__c menu = new Menu__c(Label__c = 'Test Menu');
        insert menu;
        Menu_Item__c topLevelItem = new Menu_Item__c(Menu__c = menu.Id, Label__c = 'Top Level');
        insert topLevelItem;
        Menu_Item__c content = new Menu_Item__c(Menu__c = menu.Id, Label__c = 'Content item', Parent_Item__c=topLevelItem.Id, Content__c='test content');
        insert content;
        Menu_Group_Association__c mga = new Menu_Group_Association__c(Menu__c = menu.Id, Group__c = grp.Id);
        insert mga;
        
        UpdateKeywords.JsonRequest jsonRequest = new UpdateKeywords.JsonRequest();
        jsonRequest.Imei = '12345';
        jsonRequest.KeywordsLastUpdatedDate = '2014-01-01 00:00:00';
        jsonRequest.ImagesLastUpdatedDate = '2014-01-01 00:00:00';
        Test.startTest();
        System.assert(UpdateKeywords.getKeywords(jsonRequest).size() > 0);
        UpdateKeywords.saveMenuItemsToStaticResource('Test Menu', 'fileMe');
        Test.stopTest();
    }
}