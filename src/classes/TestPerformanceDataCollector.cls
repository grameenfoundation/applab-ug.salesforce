/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  Test methods for class PerformanceDataCollector
 **/
@isTest
public class TestPerformanceDataCollector {

    static void insertData(){
        Monthly_Target__c target = new Monthly_Target__c ();
        target.Start_Date__c = date.today().toStartOfMonth();
        target.Search_Target__c = 1;
        target.Survey_Target__c = 0;
        insert target;
        
        Monthly_Target__c ptarget = new Monthly_Target__c ();
        ptarget.Start_Date__c = date.today().addMonths(-1).toStartOfMonth();
        ptarget.Search_Target__c = 1;
        ptarget.Survey_Target__c = 0;
        insert ptarget;
        
        Incentive_Structure__c incentive = new Incentive_Structure__c();
        incentive.Airtime_Compensation__c = 1000;
        incentive.Level_A_Compensation__c = 1;
        incentive.Level_A_Threshold__c = 10;
        incentive.Level_B_Compensation__c = 2;
        incentive.Level_B_Threshold__c = 18;
        incentive.Level_C_Compensation__c = 1;
        incentive.Level_C_Threshold__c = 10;
        incentive.Level_D_Compensation__c = 2;
        incentive.Long_Term_Airtime_Bonus__c = 1000;
        incentive.Long_Term_Cash_Bonus__c = 1000;
        incentive.Medium_Term_Airtime_Bonus__c = 1000;
        incentive.Medium_Term_Cash_Bonus__c = 1000;
        incentive.Short_Term_Airtime_Bonus__c = 1000;
        incentive.Short_Term_Cash_Bonus__c = 1000;
        incentive.Start_Date__c = date.today().toStartOfMonth();
        insert incentive;
        
        Incentive_Structure__c pincentive = new Incentive_Structure__c();
        pincentive.Airtime_Compensation__c = 1000;
        pincentive.Level_A_Compensation__c = 1;
        pincentive.Level_A_Threshold__c = 10;
        pincentive.Level_B_Compensation__c = 2;
        pincentive.Level_B_Threshold__c = 18;
        pincentive.Level_C_Compensation__c = 1;
        pincentive.Level_C_Threshold__c = 10;
        pincentive.Level_D_Compensation__c = 2;
        pincentive.Long_Term_Airtime_Bonus__c = 1000;
        pincentive.Long_Term_Cash_Bonus__c = 1000;
        pincentive.Medium_Term_Airtime_Bonus__c = 1000;
        pincentive.Medium_Term_Cash_Bonus__c = 1000;
        pincentive.Short_Term_Airtime_Bonus__c = 1000;
        pincentive.Short_Term_Cash_Bonus__c = 1000;
        pincentive.Start_Date__c = date.today().addMonths(-1).toStartOfMonth();
        insert pincentive;
        
        Server_Configuration__c config = new Server_Configuration__c ();
        config.URL__c = 'http://test.test.test';
        config.Survey_Database__c = 'survey_db';
        config.Search_Database__c = 'search_db';
        insert config;
    }

    static testMethod void testInitializeServerConstants() {
        insertData();
        
        PerformanceDataCollector dataCollector = new PerformanceDataCollector();
        System.assert(dataCollector.serverUrl != null);
        System.assert(dataCollector.searchDatabase != null);
        System.assert(dataCollector.surveyDatabase != null);
    }

    static testMethod void testValidateReviewObjects() {
        insertData();
        PerformanceDataCollector dataCollector = new PerformanceDataCollector();

        // Create a few CKWs with no performance reviews
        Integer numberOfCkws = 3;
        for(Integer i = 0; i < numberOfCkws; i++) {
            Person__c testPerson = new Person__c();
            testPerson.First_Name__c = 'FirstName' + i;
            testPerson.Last_Name__c = 'LastName' + i;
            database.insert(testPerson);

            CKW__c testCkw = new CKW__c();
            testCkw.Person__c = testPerson.id;

            database.insert(testCkw);
        }

        // Check that there are at least as many CKWs who don't have review objects as the # we just created        
        CKW__c[] ckwsWithNoReview = dataCollector.getCkwsWithNoReviewObject();
        System.assert(ckwsWithNoReview.size() >= numberOfCkws);

        dataCollector.validateCkwPerformanceReviewObjects();

        // Validate that there are no longer any CKWs without review objects
        CKW__c[] updatedCkwsWithNoReview = dataCollector.getCkwsWithNoReviewObject();
        System.assertEquals(updatedCkwsWithNoReview.size(), 0);
    }

    static testMethod void testSurveyParsing() {
        insertData();
        PerformanceDataCollector dataCollector = new PerformanceDataCollector();
        dataCollector.parseSurveyResults(fakeSurveyQuery(), dataCollector.currentCkwStatistics);
        Set<String> keys = dataCollector.currentCkwStatistics.keySet();
        
        System.debug('Size of CKW survey data set: ' + keys.size() + '\n');
        System.debug('Survey totals: \n');
        for(String key : keys) {
            PerformanceDataCollector.CkwPerformanceData ckwData = dataCollector.currentCkwStatistics.get(key);
            System.debug(key + ': ' + 
                ckwData.approvedSurveys + ' ' +
                ckwData.rejectedSurveys + ' ' +
                ckwData.notReviewedSurveys + ' ' +
                ckwData.pendingSurveys + ' ' +
                ckwData.duplicateSurveys + '\n');
        }
    }

    static testMethod void testUpdateReviewObjects() {
        insertData();
        PerformanceDataCollector dataCollector = new PerformanceDataCollector();

        // Create a test CKW and perf review
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        database.insert(testPerson);

        CKW__c testCkw = new CKW__c();
        testCkw.Person__c = testPerson.id;

        database.insert(testCkw);

        testCkw = [
            SELECT
                name
            FROM
                CKW__c 
            WHERE
                id =:testCkw.id];
        CKW_Performance_Review__c[] testReviews = dataCollector.createCkwPerformanceReviews(testCkw, true);
        database.insert(testReviews);

        // Create perf review data for the test CKW and insert into the Map
        PerformanceDataCollector.CkwPerformanceData testCkwData = new PerformanceDataCollector.ckwPerformanceData();
        testCkwData.totalSearches = 30;
        testCkwData.totalInvalidSearches = 30;
        testCkwData.totalSearchesOldSystem = 30;
        testCkwData.approvedSurveys = 5;
        testCkwData.rejectedSurveys = 1;
        testCkwData.pendingSurveys = 3;
        testCkwData.notReviewedSurveys = 12;
        testCkwData.duplicateSurveys = 2;
        dataCollector.currentCkwStatistics.put(testCkw.name, testCkwData);

        // Create perf review data for a non-existent CKW and insert into the Map.
        // We are testing error fallback behavior with this fake CKW.
        PerformanceDataCollector.CkwPerformanceData nonExistentCkwData = new PerformanceDataCollector.ckwPerformanceData();
        dataCollector.currentCkwStatistics.put('CKW-10-999999', nonExistentCkwData);

        // Call updateReviewObjects to update the perf review       
        dataCollector.updateReviewObjects();
        
        // Validate that the expected data was written and pay was calculated
        Ckw_Performance_Review__c updatedReview = [
            SELECT
                Number_Of_Searches__c,
                Number_Of_Searches_Running_Total__c,
                Number_Of_Invalid_Searches_Running_Total__c,
                Number_Of_Test_Searches_Running_Total__c,
                Surveys_Approved__c,
                Surveys_Rejected__c,
                Surveys_Pending__c,
                Surveys_Not_Reviewed__c,
                Duplicate_Surveys__c,
                Performance_Pay__c
            FROM
                CKW_Performance_Review__c
            WHERE 
                id=:testReviews[0].id
            LIMIT 1];

        System.assertEquals(updatedReview.Number_Of_Searches_Running_Total__c, testCkwData.totalSearches);
        System.assertEquals(updatedReview.Number_Of_Test_Searches_Running_Total__c, testCkwData.totalTestSearches);
        System.assertEquals(updatedReview.Number_Of_Invalid_Searches_Running_Total__c, testCkwData.totalInvalidSearches);
        System.assertEquals(updatedReview.Number_Of_Searches__c, testCkwData.totalSearchesOldSystem);
        System.assertEquals(updatedReview.Surveys_Approved__c, testCkwData.approvedSurveys); 
        System.assertEquals(updatedReview.Surveys_Rejected__c, testCkwData.rejectedSurveys);
        System.assertEquals(updatedReview.Surveys_Pending__c, testCkwData.pendingSurveys);
        System.assertEquals(updatedReview.Surveys_Not_Reviewed__c, testCkwData.notReviewedSurveys);
        System.assertEquals(updatedReview.Duplicate_Surveys__c, testCkwData.duplicateSurveys);
        System.debug('Performance Pay: ' + updatedReview.Performance_Pay__c);
    }

    static testMethod void testSearchDataSF() {
        insertData();
        PerformanceDataCollector dataCollector = new PerformanceDataCollector();

        // Create a handset
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = 'TestIMEI';
        testHandset.Serial_Number__c = '325246263253462';
        testHandset.Purchase_Value_USD__c = 0;
        database.insert(testHandset);

        Phone__c testHandset1 = new Phone__c();
        testHandset1.IMEI__c = 'TestIMEI1';
        testHandset1.Serial_Number__c = '325246263253461';
        testHandset1.Purchase_Value_USD__c = 0;
        database.insert(testHandset1);

        // Create a test CKW
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        testPerson.Handset__c = testHandset.Id;
        database.insert(testPerson);

        CKW__c testCkw = new CKW__c();
        testCkw.Person__c = testPerson.id;
        database.insert(testCkw);
        CKW__c testCkw2 = [SELECT name from CKW__c where id =:testCkw.id];  

        // Create a test farmer
        Person__c testPerson1 = new Person__c();
        testPerson1.First_Name__c = 'FirstName';
        testPerson1.Last_Name__c = 'LastName';
        testPerson1.Handset__c = testHandset1.Id;
        database.insert(testPerson1);

        Farmer__c testFarmer = new Farmer__c();
        testFarmer.Person__c = testPerson1.Id;
        database.insert(testFarmer);

        // Create a performance log for the CKW
        CKW_Performance_Review__c testReview = new CKW_Performance_Review__c();
        testReview.CKW_c__c = testCkw.Id;
        testReview.Number_Of_Searches__c = 5;
        testReview.Start_Date__c = date.newInstance(2010, 09, 01);
        database.insert(testReview);

        // Crate a Search Log for this ckw.
        Search_Log__c entry = new Search_Log__c();

        date entryTime = date.today().addDays(-1);
        entry.Server_Entry_Time__c = entryTime;
        entry.Handset_Submit_Time__c = entryTime;
        entry.Interviewer__c = testCkw.Person__c;
        entry.Interviewee__c = testFarmer.Person__c;
        entry.Latitude__c = 0.00;
        entry.Longitude__c = 0.00;
        entry.Altitude__c = 0.00;
        entry.Accuracy__c = 0.00;
        entry.Category__c = 'Category';
        entry.Query__c = 'Query';
        database.insert(entry);

        // Create the test farmer to ensure that he is not being found
        Person__c testPerson3 = new Person__c();
        testPerson3.First_Name__c = 'TeSt';
        testPerson3.Last_Name__c = 'TeSt';
        database.insert(testPerson3);

        Farmer__c testFarmer2 = new Farmer__c();
        testFarmer2.Person__c = testPerson3.Id;
        database.insert(testFarmer2);

        // Crate a Search Log for this test farmer.
        Search_Log__c entry2 = new Search_Log__c();
        entry2.Server_Entry_Time__c = entryTime;
        entry2.Handset_Submit_Time__c = entryTime;
        entry2.Interviewer__c = testCkw.Person__c;
        entry2.Interviewee__c = testFarmer2.Person__c;
        entry2.Latitude__c = 0.00;
        entry2.Longitude__c = 0.00;
        entry2.Altitude__c = 0.00;
        entry2.Accuracy__c = 0.00;
        entry2.Category__c = 'Category';
        entry2.Query__c = 'Query';
        database.insert(entry2);

        // Create the test farmer to ensure that he is not being found
        dataCollector.getDailySearchStatistics();
        PerformanceDataCollector.CKWPerformanceData test = dataCollector.currentCkwStatistics.get(testCkw2.Name);

        // Make sure that only the new log has been counted and the test farmer ignored
        Date todayDate = date.today();
        Date startOfMonth = date.today().toStartOfMonth();
        
        //TODO: remember to change this back to 1s
        if (todayDate.isSameDay(startOfMonth) && (todayDate.month() == entryTime.month())) {
            System.assertEquals(1, test.totalSearches);
            System.assertEquals(1, test.totalTestSearches);
        }
        else if (todayDate.isSameDay(startOfMonth) && (todayDate.month() != entryTime.month())) {
            System.assertEquals(0, test.totalSearches);
            System.assertEquals(0, test.totalTestSearches);
        }
        else {
            System.assertEquals(1, test.totalSearches);
            System.assertEquals(1, test.totalTestSearches);
        }
    }

    static testmethod void testSalesforceSurveys() {
        insertData();
        PerformanceDataCollector dataCollector = new PerformanceDataCollector();

        // Create the organisation
        Account org = Utils.createTestOrganisation('Test');
        database.insert(org);

        // Create a survey to attach the attachment to
        Survey__c survey = Utils.createTestSurvey(org, 'survey');
        database.insert(survey);

        CKW__c ckw = Utils.createTestCkw(null, 'TEST1', true, null, null);
        ckw.Status__c = 'Active';
        database.insert(ckw);

        // Create a farmer
        Farmer__c farmer1 = Utils.createTestFarmer('OD99999', null, 'TestFarmer1', true, null, null);
        farmer1.Registered_By__c = ckw.Person__c;
        database.insert(farmer1);

        // Create a submission
        Date startDate = date.today().addDays(-1);
        Time startTime = time.newInstance(12, 30, 30, 0);
        DateTime submissionDateTime = datetime.newInstance(startDate.addDays(1), startTime);
        Submission_Meta_Data__c sub = Utils.createTestSubmission(ckw.Person__c, farmer1.Person__c, survey.Id, submissionDateTime, 'Sub1');
        database.insert(sub);

        // Get the ckw name. Need to do this via a query or it doesn't work
        CKW__c ckwName = [
            SELECT
                Name
            FROM
                CKW__c
            WHERE
                Id = :ckw.Id];

        Map<String, PerformanceDataCollector.CkwPerformanceData> currentCkwStatistics = 
            new Map<String, PerformanceDataCollector.CkwPerformanceData>();
        PerformanceDataCollector.CkwPerformanceData ckwPerformanceData = new PerformanceDataCollector.CkwPerformanceData();
        currentCkwStatistics.put(ckwName.Name, ckwPerformanceData);
        dataCollector.getSalesforceSurveys('THIS_MONTH', currentCkwStatistics);
        System.assertEquals(currentCkwStatistics.get(ckwName.Name).notReviewedSurveys, 1);
    }

    static testmethod void testFarmersRegistered() {
        insertData();
        PerformanceDataCollector dataCollector = new PerformanceDataCollector();

        CKW__c ckw = Utils.createTestCkw(null, 'TEST1', true, null, null);
        ckw.Status__c = 'Active';
        database.insert(ckw);

        // Create a farmer
        Farmer__c farmer1 = Utils.createTestFarmer('OD99999', null, 'TestFarmer2', true, null, null);
        farmer1.Registered_By__c = ckw.Person__c;
        database.insert(farmer1);

        // Get the ckw name. Need to do this via a query or it doesn't work
        CKW__c ckwName = [
            SELECT
                Name
            FROM
                CKW__c
            WHERE
                Id = :ckw.Id];

        Map<String, PerformanceDataCollector.CkwPerformanceData> currentCkwStatistics = 
            new Map<String, PerformanceDataCollector.CkwPerformanceData>();
        PerformanceDataCollector.CkwPerformanceData ckwPerformanceData = new PerformanceDataCollector.CkwPerformanceData();
        currentCkwStatistics.put(ckwName.Name, ckwPerformanceData);
        dataCollector.getFarmersRegistered('THIS_MONTH', currentCkwStatistics);
        System.assertEquals(currentCkwStatistics.get(ckwName.Name).farmersRegistered, 1);
    }

    static testMethod void testUpdateSpecificSearchesDate() {
        insertData();
        // Generate dates
        Date thisStartMonthDate = Date.today().toStartOfMonth();
        Date lastStartMonthDate = Date.today().toStartOfMonth().addMonths(-1);

        CKW__c testCkw = Utils.createTestCkw(null, 'TEST1', true, null, null);
        database.insert(testCkw);

        // Create a test farmer
        Farmer__c testFarmer = Utils.createTestFarmer('OD01234', null, 'OWEN', true, null, null);
        database.insert(testFarmer);

        // Create the test farmer to ensure that he is not being found
        Person__c testPerson3 = new Person__c();
        testPerson3.First_Name__c = 'TeSt';
        testPerson3.Last_Name__c = 'TeSt';
        database.insert(testPerson3);

        Farmer__c testFarmer2 = new Farmer__c();
        testFarmer2.Person__c = testPerson3.Id;
        database.insert(testFarmer2);

        // Create a performance log for the CKW for the last month
        CKW_Performance_Review__c testReview = new CKW_Performance_Review__c();
        testReview.CKW_c__c = testCkw.Id;
        testReview.Number_Of_Invalid_Searches_Running_Total__c = 0.0;
        testReview.Number_Of_Searches_Running_Total__c = 0.0;
        testReview.Number_Of_Test_Searches_Running_Total__c = 0.0;
        testReview.Start_Date__c = lastStartMonthDate;
        database.insert(testReview);

        // Generate the various search logs that are needed to test
        List<Search_Log__c> logs = new List<Search_Log__c>();
        Search_Log__c entryThisMonthValid = new Search_Log__c();
        entryThisMonthValid.Server_Entry_Time__c = thisStartMonthDate.addDays(5);
        entryThisMonthValid.Handset_Submit_Time__c = thisStartMonthDate.addDays(4);
        entryThisMonthValid.Interviewer__c = testCkw.Person__c;
        entryThisMonthValid.Interviewee__c = testFarmer.Person__c;
        entryThisMonthValid.Latitude__c = 0.00;
        entryThisMonthValid.Longitude__c = 0.00;
        entryThisMonthValid.Altitude__c = 0.00;
        entryThisMonthValid.Accuracy__c = 0.00;
        entryThisMonthValid.Category__c = 'Category';
        entryThisMonthValid.Query__c = 'Query';
        logs.add(entryThisMonthValid);

        // Crate a Search Log for the test farmer for this month
        Search_Log__c entryThisMonthTest = new Search_Log__c();
        entryThisMonthTest.Server_Entry_Time__c = thisStartMonthDate.addDays(5);
        entryThisMonthTest.Handset_Submit_Time__c = thisStartMonthDate.addDays(4);
        entryThisMonthTest.Interviewer__c = testCkw.Person__c;
        entryThisMonthTest.Interviewee__c = testFarmer2.Person__c;
        entryThisMonthTest.Latitude__c = 0.00;
        entryThisMonthTest.Longitude__c = 0.00;
        entryThisMonthTest.Altitude__c = 0.00;
        entryThisMonthTest.Accuracy__c = 0.00;
        entryThisMonthTest.Category__c = 'Category';
        entryThisMonthTest.Query__c = 'Query';
        logs.add(entryThisMonthTest);

        // Log for this month for an invalid search
        Search_Log__c entryThisMonthInvalid = new Search_Log__c();
        entryThisMonthInvalid.Server_Entry_Time__c = thisStartMonthDate.addDays(5);
        entryThisMonthInvalid.Handset_Submit_Time__c = thisStartMonthDate.addDays(4);
        entryThisMonthInvalid.Interviewer__c = testCkw.Person__c;
        entryThisMonthInvalid.Interviewee__c = null;
        entryThisMonthInvalid.Latitude__c = 0.00;
        entryThisMonthInvalid.Longitude__c = 0.00;
        entryThisMonthInvalid.Altitude__c = 0.00;
        entryThisMonthInvalid.Accuracy__c = 0.00;
        entryThisMonthInvalid.Category__c = 'Category';
        entryThisMonthInvalid.Query__c = 'Query';
        logs.add(entryThisMonthInvalid);

        // Generate the various search logs that are needed to test for the last month
        Search_Log__c entryPreviousMonthValid = new Search_Log__c();
        entryPreviousMonthValid.Server_Entry_Time__c = thisStartMonthDate.addDays(5);
        entryPreviousMonthValid.Handset_Submit_Time__c = lastStartMonthDate.addDays(4);
        entryPreviousMonthValid.Interviewer__c = testCkw.Person__c;
        entryPreviousMonthValid.Interviewee__c = testFarmer.Person__c;
        entryPreviousMonthValid.Latitude__c = 0.00;
        entryPreviousMonthValid.Longitude__c = 0.00;
        entryPreviousMonthValid.Altitude__c = 0.00;
        entryThisMonthValid.Accuracy__c = 0.00;
        entryPreviousMonthValid.Category__c = 'Category';
        entryPreviousMonthValid.Query__c = 'Query';
        logs.add(entryPreviousMonthValid);

        // Crate a Search Log for the test farmer for last month
        Search_Log__c entryPreviousMonthTest = new Search_Log__c();
        entryPreviousMonthTest.Server_Entry_Time__c = thisStartMonthDate.addDays(5);
        entryPreviousMonthTest.Handset_Submit_Time__c = lastStartMonthDate.addDays(4);
        entryPreviousMonthTest.Interviewer__c = testCkw.Person__c;
        entryPreviousMonthTest.Interviewee__c = testFarmer2.Person__c;
        entryPreviousMonthTest.Latitude__c = 0.00;
        entryPreviousMonthTest.Longitude__c = 0.00;
        entryPreviousMonthTest.Altitude__c = 0.00;
        entryPreviousMonthTest.Accuracy__c = 0.00;
        entryPreviousMonthTest.Category__c = 'Category';
        entryPreviousMonthTest.Query__c = 'Query';
        logs.add(entryPreviousMonthTest);

        // Log for this month for an invalid search
        Search_Log__c entryPreviousMonthInvalid = new Search_Log__c();
        entryPreviousMonthInvalid.Server_Entry_Time__c = thisStartMonthDate.addDays(5);
        entryPreviousMonthInvalid.Handset_Submit_Time__c = lastStartMonthDate.addDays(4);
        entryPreviousMonthInvalid.Interviewer__c = testCkw.Person__c;
        entryPreviousMonthInvalid.Interviewee__c = null;
        entryPreviousMonthInvalid.Latitude__c = 0.00;
        entryPreviousMonthInvalid.Longitude__c = 0.00;
        entryPreviousMonthInvalid.Altitude__c = 0.00;
        entryPreviousMonthInvalid.Accuracy__c = 0.00;
        entryPreviousMonthInvalid.Category__c = 'Category';
        entryPreviousMonthInvalid.Query__c = 'Query';
        logs.add(entryPreviousMonthInvalid);

        // Insert the logs
        database.insert(logs);

        // Create the performance data collector
        PerformanceDataCollector dataCollector = new PerformanceDataCollector();
        dataCollector.addMissedSearchLogs(thisStartMonthDate.addDays(3), thisStartMonthDate.addDays(5));
        CKW_Performance_Review__c[] reviewsInserted = [
            SELECT
                Number_Of_Invalid_Searches_Running_Total__c,
                Number_Of_Searches_Running_Total__c,
                Number_Of_Test_Searches_Running_Total__c
            FROM
                CKW_Performance_Review__c
            WHERE
                CKW_c__c = :testCkw.Id
            ];
        System.assertEquals(reviewsInserted.size(), 2);
        for (CKW_Performance_Review__c perfReview : reviewsInserted) {
            System.assertEquals(perfReview.Number_Of_Invalid_Searches_Running_Total__c, 1);
            System.assertEquals(perfReview.Number_Of_Searches_Running_Total__c, 1);
            System.assertEquals(perfReview.Number_Of_Test_Searches_Running_Total__c, 1);
        }
    }    

    private static String fakeSurveyQuery() {
        String result = '<results>' +
            '<row><ckw>CKW-10-000007</ckw><survey_id>2010070025</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '<row><ckw>CKW-10-000009</ckw><survey_id>2010070025</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '<row><ckw>CKW-10-000115</ckw><survey_id>2010070025</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '<row><ckw>CKW-10-000122</ckw><survey_id>2010070025</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '<row><ckw>CKW-10-000123</ckw><survey_id>2010070025</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '<row><ckw>CKW-10-000250</ckw><survey_id>2010070025</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '<row><ckw>CKW-10-000250</ckw><survey_id>2010070026</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '<row><ckw>CKW-10-000251</ckw><survey_id>2010070025</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '</results>';
        
        return result;      
    }    
}