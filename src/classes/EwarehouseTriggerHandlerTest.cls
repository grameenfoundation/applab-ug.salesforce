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
private class EwarehouseTriggerHandlerTest {

    static testMethod void testonAfterHarvestInsert() {


        //Setup data for the test
        District__c testDistrict = Utils.createTestDistrict('Ewarehouse');
        insert testDistrict;

        Person__c testPerson = Utils.createTestPerson(null, 'E-FARMER', true, null, 'Female');
        insert testPerson;

        Farmer__c testFarmer = Utils.createTestFarmer('ABC123', testPerson.Id, '', false, testDistrict.Id, 'Male');
        insert testFarmer;

        Integer beforeMessageCount = [SELECT COUNT() FROM Scheduled_Message_Queue__c WHERE Person__c =:testPerson.id];
        Harvest__c testHarvest = new Harvest__c();
        testHarvest.Crop__c = 'Maize';
        testHarvest.Farmer__c = testFarmer.Id;
        testHarvest.Date_Harvested__c = date.today();
        testHarvest.Quantity_Harvested__c = 100;
        testHarvest.Quantity_Accepted__c = 10;
        testHarvest.Quantity_Rejected__c = 90;
        insert testHarvest;

        Integer afterMessageCount  = [SELECT COUNT() FROM Scheduled_Message_Queue__c WHERE Person__c =:testPerson.id];
        //System.assert(afterMessageCount - beforeMessageCount == 1);
    }

    static testMethod void testonAfterSaleRegistrationInsert() {


        //Setup data for the test
        District__c testDistrict = Utils.createTestDistrict('Ewarehouse');
        insert testDistrict;

        Person__c testPerson = Utils.createTestPerson(null, 'E-FARMER2', true, null, 'Female');
        insert testPerson;

        Farmer__c testFarmer = Utils.createTestFarmer('ABC1234', testPerson.Id, '', false, testDistrict.Id, 'Male');
        insert testFarmer;

        Integer beforeMessageCount = [SELECT COUNT() FROM Scheduled_Message_Queue__c WHERE Person__c =:testPerson.id];

        Sale__c saleObject = new Sale__c();
        saleObject.Dolichos_Number_of_90kg_Bags_Sold__c = 5;
        saleObject.Dolichos_Price_Per_90kg_Bag__c = 140;
        saleObject.Beans_Number_of_90kg_Bags_Sold__c = 9;
        saleObject.Beans_Price_Per_90kg_Bag__c = 55;
        saleObject.Cow_Peas_Number_of_90kg_Bags_Sold__c = 4;
        saleObject.Cow_Peas_Price_Per_90kg_Bag__c = 60;
        saleObject.Green_Grams_Number_of_90kg_Bags_Sold__c = 0;
        saleObject.Green_Grams_Price_Per_90kg_Bag__c = 0;
        saleObject.Maize_Number_of_90kg_Bags_Sold__c = 20;
        saleObject.Maize_Price_Per_90kg_Bag__c = 45;
        saleObject.Pigeon_Peas_Number_of_90kg_Bags_Sold__c = 15;
        saleObject.Pigeon_Peas_Price_Per_90kg_Bag__c = 50;
        saleObject.Sale_Date__c = date.today();
        insert saleObject;

        Sale_Farmer_Association__c saleFarmer = new Sale_Farmer_Association__c();
        saleFarmer.Farmer__c = testFarmer.Id;
        saleFarmer.Sale__c = saleObject.Id;
        saleFarmer.Dolichos_Number_of_90kg_Bags_Sold__c = 3;
        saleFarmer.Pigeon_Peas_Number_of_90kg_Bags_Sold__c = 4;
        saleFarmer.Cow_Peas_Number_of_90kg_Bags_Sold__c = 30;
        saleFarmer.Beans_Number_of_90kg_Bags_Sold__c = 7;
        salefarmer.Maize_Number_of_90kg_Bags_Sold__c = 20;
        saleFarmer.Green_Grams_Number_of_90kg_Bags_Sold__c = 14;
        insert saleFarmer;      

        Integer afterMessageCount  = [SELECT COUNT() FROM Scheduled_Message_Queue__c WHERE Person__c =:testPerson.id];
        System.assert(afterMessageCount - beforeMessageCount == 1);
    }
}