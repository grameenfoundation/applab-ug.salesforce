/**
 * Test methods for the harvest message scheduling
 *
 * Classes covered:
 *   HarvestMessageSender
 */
@isTest
private class HarvestMessageSenderTest {

    /** 
     * Method to create the test data
     * 
     */
    static void setUpHarvest() {
        //Create a test country
        Country__c country = new Country__c(Name = 'TestCountry', ISO_Standard_Code__c = 'TC', Language__c = 'English');
        insert country;
        
        //Create a person
        Person__c person = new Person__c( Last_Name__c = 'l1', Middle_Name__c = 'm1', First_Name__c = 'f1', Country__c = country.Id, Raw_Mobile_Number__c = '111111111');
        
        //Test organization
        Account account = new Account(Name='CKW');
        account.BillingState='CA';
        insert account;
        
        //Test contact
        Contact contact = new Contact();
        contact.FirstName = 'f1';
        contact.LastName = 'l1';
        contact.AccountId = account.Id;
        insert contact;

        //Test farmer
        Ewarehouse_Farmer__c farmer = new Ewarehouse_Farmer__c (Auto_Generated_Farmer_ID__c = '001', Contact__c = contact.Id, Ewarehouse_Person__c = person.Id, District__c = 'Tigania West', Commercial_Purchase_Groups__c = 'CIWIT', Commercial_Villages__c = 'MAKANDI');
        insert farmer;
        
        //Test harvest
        Ewarehouse_Harvest__c harvestData = new Ewarehouse_Harvest__c (Ewarehouse_Farmer__c = farmer.Id, Notification_Sent__c = false);
        insert harvestData;
        
        //Test crop harvest
        Ewarehouse_Harvest_Crop__c harvestCrop = new Ewarehouse_Harvest_Crop__c ( Maize_Accepted__c = 10, Maize_Rejected__c = 0, Storage_Location__c = 'Granary on ground;Granary off ground', Beans_Accepted__c = 10, Beans_Harvested__c=10, Ewarehouse_Harvest__c = harvestData.Id);
        insert harvestCrop;
        
        //Test market
        Markets__c market = new Markets__c (Name='e-warehouse');
        insert market;
        
        //Test commodity 1 (Maize)
        Commodities__c c1 = new Commodities__c (Name='Maize', Highest_Wholesale_Price__c = 1000, Market__c = market.Id);
        insert c1;
        
        //Test commodity 2 (Beans)
        Commodities__c c2 = new Commodities__c (Name='Beans', Highest_Wholesale_Price__c = 1000, Market__c = market.Id);
        insert c2;
    }
        
    static testMethod void testBatchJob() {
        
        setUpHarvest();
        
        // Schedule the harvest messages
        String queryString = 'SELECT ' +
            'Id,' +
            'Ewarehouse_Farmer__r.Id,' +
            'Ewarehouse_Farmer__r.Auto_Generated_Farmer_ID__c,' +
            'Ewarehouse_Farmer__r.Contact__r.FirstName,' +
            'Ewarehouse_Farmer__r.Contact__r.LastName,' +
            'Ewarehouse_Farmer__r.Contact__r.MobilePhone,' +
            'Ewarehouse_Farmer__r.Ewarehouse_Person__r.Id, ' +
            'Harvest_Date__c, ' +
            'Beans_Harvested__c,' +
            'Maize_Harvested__c,' +
            'Cow_Peas_Harvested__c,' +
            'Black_Beans_Harvested__c, ' +
            'Green_Grams_Harvested__c, ' +
            'Pigeon_Peas_Harvested__c ' +
        'FROM ' +
            ' Ewarehouse_Harvest__c ' +
        ' WHERE ' +
            'Notification_Sent__c = false';

        Test.StartTest();
        ID batchProcessId = Database.executeBatch(new HarvestMessageSender(queryString), 50);
        Test.StopTest();
       
       //Check the number of pending harvests. It should be 0
       System.AssertEquals(database.countquery('SELECT COUNT() FROM Ewarehouse_Harvest__c WHERE Notification_Sent__c = false'), 0);
    }
}