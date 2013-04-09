/**
 *  A test class for OpportunityProfileSurveyHelpers
 */
@isTest
public with sharing class TestOpportunityProfileSurveyHelpers {

    /**
     *  Test method for the processClientProfileSurvey method
     */
    private static TestMethod void testProcessClientAndMapSurvey(){
        Account testAccount = new Account();
        testAccount.BillingState = 'CA';
        testAccount.Name = 'Opportunity International'; 
        database.SaveResult accountSaveResult = database.insert(testAccount);

        // Create test Opportunity Farmer
        Opportunity_Farmer__c testOpportunityFarmer = Utils.createTestOpportunityFarmer(null, 'TestOppFarmer1', true, null, null);
        database.insert(testOpportunityFarmer);

        // Create test FarmerLand
        FarmerLand__c testFarmerLand = Utils.createTestFarmerLand('TestFarmerland', testOpportunityFarmer.Id);
        database.insert(testFarmerLand);

        // Create test submissions 
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q6_0', Utils.createTestSubmissionAnswer(null, 'q6', 'TestFirstName', '', '', 0));
        answers.put('q7_0', Utils.createTestSubmissionAnswer(null, 'q7', 'TestLastName', '', '', 0));
        answers.put('q8_0', Utils.createTestSubmissionAnswer(null, 'q8', 'TestMiddleName', '', '', 0));
        answers.put('q45_0', Utils.createTestSubmissionAnswer(null, 'q45', 'TestParish', '', '', 0));
        answers.put('q30_0', Utils.createTestSubmissionAnswer(null, 'q30', '1', '', '', 0));
        answers.put('q31_0', Utils.createTestSubmissionAnswer(null, 'q31', '1', '', '', 0));
        answers.put('q25_0', Utils.createTestSubmissionAnswer(null, 'q25', 'TestGender', '', '', 0));
        answers.put('q26_0', Utils.createTestSubmissionAnswer(null, 'q26', '2013-03-01', '', '', 0));
        
        // Test Submissions for mapping question
        answers.put('q87_0', Utils.createTestSubmissionAnswer(null, 'q87_0', '32.5 2.0', '', '', 0));
        answers.put('q87_1', Utils.createTestSubmissionAnswer(null, 'q87_1', '32.7 5.0', '', '', 0));

        // Test success
        List<String> result1 = OpportunityProfileSurveyHelpers.processClientProfileSurvey(answers, testOpportunityFarmer.Person__c);
        System.debug(LoggingLevel.INFO, result1.get(0) + ' ' + result1.get(1));
        System.assert(result1.get(0).equals('1'));

        // Test failure due to non existent subcounty
        answers.put('q31_0', Utils.createTestSubmissionAnswer(null, 'q31', 'testSub', '', '', 0));
        List<String> result0 = OpportunityProfileSurveyHelpers.processClientProfileSurvey(answers, testOpportunityFarmer.Person__c);
        System.debug(LoggingLevel.INFO, result0.get(0) + ' ' + result0.get(1));
        System.assert(result0.get(0).equals('0'));

        // Test failure due to non existent District
        answers.put('q30_0', Utils.createTestSubmissionAnswer(null, 'q30', 'testDist', '', '', 0));
        List<String> result2 = OpportunityProfileSurveyHelpers.processClientProfileSurvey(answers, testOpportunityFarmer.Person__c);
        System.debug(LoggingLevel.INFO, result0.get(0) + ' ' + result2.get(1));
        System.assert(result2.get(0).equals('0'));
    }
}