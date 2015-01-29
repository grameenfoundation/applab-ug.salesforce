/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  Test methods for class CreateSearchLogEntry
 **/
@isTest
public class TestCreateSearchLogEntry {

    static testMethod void testcreateFarmerObject() {

        // Create the new person
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'testfname';
        testPerson.Last_Name__c = 'testlname';
        testPerson.Raw_Mobile_Number__c = 'testmsisdn';
        insert testPerson;
        CreateSearchLogEntry.FarmerExists(testPerson);
        CreateSearchLogEntry.createFarmerObject(testPerson);
    }

    static testMethod void testGetQuarterIndicator(){
        String testTime1 = '2010-01-01 00:00:00';
        CreateSearchLogEntry.getQuarterIndicator(testTime1);
        String testTime2 = '2010-04-01 00:00:00';
        CreateSearchLogEntry.getQuarterIndicator(testTime2);
        String testTime3 = '2010-07-01 00:00:00';
        CreateSearchLogEntry.getQuarterIndicator(testTime3);
        String testTime4 = '2010-11-01 00:00:00';
        CreateSearchLogEntry.getQuarterIndicator(testTime4);
    }

    static testMethod void testCreateSearchLogEntry() {
    
        Account testOrg = new Account();
        testOrg.Name = 'TestOrg';
        testOrg.BillingState = 'CA';
        insert testOrg;
        
        List<M_E_Metric__c> metrics = new List<M_E_Metric__c>();
        M_E_Metric__c metric = Utils.createTestMetric(testOrg, 'Sum', 'Impact', false, '');
        metric.Name = 'total_complete_interactions_ussd_searches';
        metrics.add(metric);
        
        M_E_Metric__c metric2 = Utils.createTestMetric(testOrg, 'Sum', 'Impact', false, '');
        metric2.Name = 'total_info_services_offered';
        metrics.add(metric2);
        
        insert metrics;
            
        CreateSearchLogEntry.SearchLogEntry entry1 = new CreateSearchLogEntry.SearchLogEntry();
        entry1.handsetId = 'MyTestHandsetId1';
        entry1.serverEntryTime = '2010-01-01 00:00:00';
        entry1.submissionTime = '2010-01-01 00:00:00';
        entry1.farmerId = 'MyTestFarmerId1';
        entry1.latitude = '0.00';
        entry1.longitude = '0.00';
        entry1.altitude = '0.00';
        entry1.accuracy = '0.00';
        entry1.submissionLatitude = '0.00';
        entry1.submissionLongitude = '0.00';
        entry1.submissionAltitude = '0.00';
        entry1.submissionAccuracy = '0.00';
        entry1.submissionGPSTime = '0';
        entry1.category = 'Category1';
        entry1.query = 'Query1';
        entry1.content = 'Content1';
        entry1.msisdn = 'MyMsisdn1';

        CreateSearchLogEntry.SearchLogEntry createdEntry1 = CreateSearchLogEntry.createNewSearchLogEntry(entry1);
        System.assert(createdEntry1.inserted);
        CreateSearchLogEntry.loadTestPerson();

        CreateSearchLogEntry.getInterviewer(entry1);
        CreateSearchLogEntry.createFarmerPersonObject(entry1);

        CreateSearchLogEntry.getFarmerPersonObject(entry1);
        testcreateFarmerObject();

        CreateSearchLogEntry.SearchLogEntry entry2 = new CreateSearchLogEntry.SearchLogEntry();
        entry2.handsetId = 'MyTestHandsetId2';
        entry2.serverEntryTime = '2010-01-01 00:00:00';
        entry2.submissionTime = '2010-01-01 00:00:00';
        entry2.farmerId = 'MyTestFarmerId2';
        entry2.latitude = '0.00';
        entry2.longitude = '0.00';
        entry2.altitude = '0.00';
        entry2.accuracy = '0.00';
        entry2.submissionLatitude = '0.00';
        entry2.submissionLongitude = '0.00';
        entry2.submissionAltitude = '0.00';
        entry2.submissionAccuracy = '0.00';
        entry2.submissionGPSTime = '0';
        entry2.category = 'Category2';
        entry2.query = 'Query2';
        entry2.content = 'Content2';
        entry2.msisdn = 'MyMsisdn2';
        entry2.isUssd = true;
        entry2.isCompleted = true;

        CreateSearchLogEntry.SearchLogEntry createdEntry2 = CreateSearchLogEntry.createNewSearchLogEntry(entry2);
        System.assert(createdEntry2.inserted);
        CreateSearchLogEntry.loadTestPerson();

        CreateSearchLogEntry.getInterviewer(entry2);
        CreateSearchLogEntry.createFarmerPersonObject(entry2);

        CreateSearchLogEntry.getFarmerPersonObject(entry2);
        testcreateFarmerObject();

    }

    static testMethod void testCreateSearchLogEntries() {
        
        Account testOrg = new Account();
        testOrg.Name = 'TestOrg';
        testOrg.BillingState = 'CA';
        insert testOrg;
        
        List<M_E_Metric__c> metrics = new List<M_E_Metric__c>();
        M_E_Metric__c metric = Utils.createTestMetric(testOrg, 'Sum', 'Impact', false, '');
        metric.Name = 'total_complete_interactions_ussd_searches';
        metrics.add(metric);
        
        M_E_Metric__c metric2 = Utils.createTestMetric(testOrg, 'Sum', 'Impact', false, '');
        metric2.Name = 'total_info_services_offered';
        metrics.add(metric2);
        
        M_E_Metric__c metric3 = Utils.createTestMetric(testOrg, 'Sum', 'Impact', false, '');
        metric3.Name = 'total_incomplete_interactions_ussd_searches';
        metrics.add(metric3);
        
        insert metrics;
        
        List<CreateSearchLogEntry.SearchLogEntry> searchLogs = new List<CreateSearchLogEntry.SearchLogEntry>();

        CreateSearchLogEntry.SearchLogEntry entry1 = new CreateSearchLogEntry.SearchLogEntry();
        entry1.handsetId = 'MyTestHandsetId1';
        entry1.serverEntryTime = '2010-01-01 00:00:00';
        entry1.submissionTime = '2010-01-01 00:00:00';
        entry1.farmerId = 'MyTestFarmerId1';
        entry1.latitude = '0.00';
        entry1.longitude = '0.00';
        entry1.altitude = '0.00';
        entry1.accuracy = '0.00';
        entry1.submissionLatitude = '0.00';
        entry1.submissionLongitude = '0.00';
        entry1.submissionAltitude = '0.00';
        entry1.submissionAccuracy = '0.00';
        entry1.submissionGPSTime = '0';
        entry1.category = 'Category';
        entry1.query = 'Query';
        entry1.content = 'Content';
        entry1.msisdn = 'MyMsisdn1';
        searchLogs.add(entry1);

        CreateSearchLogEntry.SearchLogEntry entry2 = new CreateSearchLogEntry.SearchLogEntry();
        entry2.handsetId = 'MyTestHandsetId2';
        entry2.serverEntryTime = '2010-01-01 00:00:00';
        entry2.submissionTime = '2010-01-01 00:00:00';
        entry2.farmerId = 'MyTestFarmerId2';
        entry2.latitude = '0.00';
        entry2.longitude = '0.00';
        entry2.altitude = '0.00';
        entry2.accuracy = '0.00';
        entry2.submissionLatitude = '0.00';
        entry2.submissionLongitude = '0.00';
        entry2.submissionAltitude = '0.00';
        entry2.submissionAccuracy = '0.00';
        entry2.submissionGPSTime = '0';
        entry2.category = 'Category';
        entry2.query = 'Query';
        entry2.content = 'Content';
        entry2.msisdn = 'MyMsisdn2';
        searchLogs.add(entry2);

        CreateSearchLogEntry.getFarmerPersonObjects(searchLogs);
        System.assert(CreateSearchLogEntry.createNewSearchLogEntries(searchLogs));

    }    
}