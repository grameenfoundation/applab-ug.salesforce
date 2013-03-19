/**
* A test class for the ProcessNaadsSurveys class methods
*/
@isTest
private class TestProcessEwarehouseSurveys {
    /**
     * A test method for the processEwarehouseFarmerRegistration method
     */
    static testMethod void testProcessEwarehouseFarmerRegistration() {
    
        Account testAccount = new Account();
        testAccount.BillingState = 'CA';
        testAccount.Name = 'USAID'; 
        database.SaveResult accountSaveResult = database.insert(testAccount);
        
        Country__c country = Utils.createTestCountry('Kenya');
        database.insert(country);
        
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '21232443253';
        submission.resultHash = '1';
        
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q31_0', Utils.createTestSubmissionAnswer(null, 'q31', '1', null, null, null));
        answers.put('q32_0', Utils.createTestSubmissionAnswer(null, 'q32', '1', null, null, null));
        answers.put('q33_0', Utils.createTestSubmissionAnswer(null, 'q33', '1', null, null, null));
        answers.put('q34_0', Utils.createTestSubmissionAnswer(null, 'q34', '1', null, null, null));
        answers.put('q35_0', Utils.createTestSubmissionAnswer(null, 'q35', '1', null, null, null));
        answers.put('q36_0', Utils.createTestSubmissionAnswer(null, 'q36', '1', null, null, null));
        answers.put('q37_0', Utils.createTestSubmissionAnswer(null, 'q37', '1', null, null, null));
        answers.put('q38_0', Utils.createTestSubmissionAnswer(null, 'q38', '1', null, null, null));
        answers.put('q39_0', Utils.createTestSubmissionAnswer(null, 'q39', '1', null, null, null));
        answers.put('q40_0', Utils.createTestSubmissionAnswer(null, 'q40', '1', null, null, null));
        answers.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12', '1test', null, null, null));
        answers.put('q29_0', Utils.createTestSubmissionAnswer(null, 'q29', '1 2 3', null, null, null));
        answers.put('q75_0', Utils.createTestSubmissionAnswer(null, 'q75', '2 3 4', null, null, null));
        answers.put('q41_0', Utils.createTestSubmissionAnswer(null, 'q41', '1', null, null, null));
        answers.put('q60_0', Utils.createTestSubmissionAnswer(null, 'q60', '1', null, null, null));
        answers.put('q37_0', Utils.createTestSubmissionAnswer(null, 'q37', '1', null, null, null));
        answers.put('q71_0', Utils.createTestSubmissionAnswer(null, 'q71', '3', null, null, null));
        answers.put('q60_0', Utils.createTestSubmissionAnswer(null, 'q67', '2', null, null, null));
        answers.put('q50_0', Utils.createTestSubmissionAnswer(null, 'q50', '5', null, null, null));
        
        Person__c person = Utils.createTestPerson(null, 'E-FARMER', true, null, 'Female');
        List<String> returnValues = new List<String>();
        test.startTest();
        // Test for failure
        returnValues = ProcessEwarehouseSurveys.processEwarehouseFarmerRegistration(submission, answers, person);         
        System.assert(returnValues.get(0).equals('0'));
        // With wrong input
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', '', null, null, null));
        System.assert(returnValues.get(0).equals('0'));
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'Bob', null, null, null));
        System.assert(returnValues.get(0).equals('0'));
        // Test for success
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'Mario, Jardel', null, null, null));
        returnValues = ProcessEwarehouseSurveys.processEwarehouseFarmerRegistration(submission, answers, person);         
        System.assert(returnValues.get(0).equals('1'));
        test.stopTest();
        
    }
}