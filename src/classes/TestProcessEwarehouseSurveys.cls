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

    /**
     * A test method for the processEwarehouseFarmerRegistration method
     */
    static testMethod void testProcessEwarehouseHarvestSurvey() {

        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '21232443253';
        submission.resultHash = '1';

        Person__c person = Utils.createTestPerson(null, 'E-FARMER', true, null, 'Male');

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'ABC123', null, null, 0));
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', ' ', null, null, 0));
        answers.put('q4_0', Utils.createTestSubmissionAnswer(null, 'q4', 'Maize', null, null, 0));
        answers.put('q5_0', Utils.createTestSubmissionAnswer(null, 'q5', '30', null, null, 0));
        answers.put('q4_1', Utils.createTestSubmissionAnswer(null, 'q4', 'Beans', null, null, 1));
        answers.put('q5_1', Utils.createTestSubmissionAnswer(null, 'q5', '40', null, null, 1));
        answers.put('q4_2', Utils.createTestSubmissionAnswer(null, 'q4', 'Cow peas', null, null, 2));
        answers.put('q5_2', Utils.createTestSubmissionAnswer(null, 'q5', '30', null, null, 2));
        answers.put('q7_0', Utils.createTestSubmissionAnswer(null, 'q7', 'Maize', null, null, 0));
        answers.put('q8_0', Utils.createTestSubmissionAnswer(null, 'q8', '1', null, null, null));
        answers.put('q7_1', Utils.createTestSubmissionAnswer(null, 'q7', 'Beans', null, null, 1));
        answers.put('q8_1', Utils.createTestSubmissionAnswer(null, 'q8', '2', null, null, null));
        answers.put('q7_2', Utils.createTestSubmissionAnswer(null, 'q7', 'Cow peas', null, null, 2));
        answers.put('q8_2', Utils.createTestSubmissionAnswer(null, 'q8', '1', null, null, null));
        answers.put('q10_0', Utils.createTestSubmissionAnswer(null, 'q10', 'Maize', null, null, 0));
        answers.put('q11_0', Utils.createTestSubmissionAnswer(null, 'q11', '2', null, null, 0));
        answers.put('q10_1', Utils.createTestSubmissionAnswer(null, 'q10', 'Beans', null, null, 1));
        answers.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12', '2', null, null, 0));
        answers.put('q10_2', Utils.createTestSubmissionAnswer(null, 'q10', 'Cow peas', null, null, 2));
        answers.put('q12_1', Utils.createTestSubmissionAnswer(null, 'q12', '2', null, null, 1));
        answers.put('q14_0', Utils.createTestSubmissionAnswer(null, 'q14', 'Maize', null, null, 0));
        answers.put('q15_0', Utils.createTestSubmissionAnswer(null, 'q15', '1', null, null, null));
        answers.put('q14_1', Utils.createTestSubmissionAnswer(null, 'q14', 'Beans', null, null, 1));
        answers.put('q15_1', Utils.createTestSubmissionAnswer(null, 'q15', '2', null, null, null));
        answers.put('q14_2', Utils.createTestSubmissionAnswer(null, 'q14', 'Cow peas', null, null, 2));
        answers.put('q15_2', Utils.createTestSubmissionAnswer(null, 'q15', '1', null, null, null));
        answers.put('q18_0', Utils.createTestSubmissionAnswer(null, 'q18', 'Maize', null, null, 0));
        answers.put('q19_0', Utils.createTestSubmissionAnswer(null, 'q19', '25', null, null, 0));
        answers.put('q20_0', Utils.createTestSubmissionAnswer(null, 'q20', '5', null, null, 0));
        answers.put('q18_1', Utils.createTestSubmissionAnswer(null, 'q18', 'Beans', null, null, 1));
        answers.put('q19_1', Utils.createTestSubmissionAnswer(null, 'q19', '30', null, null, 1));
        answers.put('q20_1', Utils.createTestSubmissionAnswer(null, 'q20', '10', null, null, 1));
        answers.put('q18_2', Utils.createTestSubmissionAnswer(null, 'q18', 'Cow peas', null, null, 2));
        answers.put('q19_2', Utils.createTestSubmissionAnswer(null, 'q19', '20', null, null, 2));
        answers.put('q20_2', Utils.createTestSubmissionAnswer(null, 'q20', '10', null, null, 2));
        answers.put('q29_0', Utils.createTestSubmissionAnswer(null, 'q29', '1234 5678', null, null, null));
        
        List<String> returnValues = new List<String>();
        test.startTest();

        // Test for failure
        returnValues = ProcessEwarehouseSurveys.processEwarehouseHarvestSurvey(submission, answers, person);         
        System.assert(returnValues.get(0).equals('0'));
               
        // Test for success
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', '1 2 5', null, null, 0));
        returnValues = ProcessEwarehouseSurveys.processEwarehouseHarvestSurvey(submission, answers, person);         
        System.assert(returnValues.get(0).equals('1'));
        
        // Test different order of crops entered for moisture content question
        Map<String, Submission_Answer__c> submissionAnswersMap = new Map<String, Submission_Answer__c>();
        submissionAnswersMap.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'ABC123', null, null, 0));
        submissionAnswersMap.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', '1 2 5', null, null, 0));
        submissionAnswersMap.put('q4_0', Utils.createTestSubmissionAnswer(null, 'q4', 'Maize', null, null, 0));
        submissionAnswersMap.put('q5_0', Utils.createTestSubmissionAnswer(null, 'q5', '30', null, null, 0));
        submissionAnswersMap.put('q4_1', Utils.createTestSubmissionAnswer(null, 'q4', 'Beans', null, null, 1));
        submissionAnswersMap.put('q5_1', Utils.createTestSubmissionAnswer(null, 'q5', '40', null, null, 1));
        submissionAnswersMap.put('q4_2', Utils.createTestSubmissionAnswer(null, 'q4', 'Cow peas', null, null, 2));
        submissionAnswersMap.put('q5_2', Utils.createTestSubmissionAnswer(null, 'q5', '30', null, null, 2));
        submissionAnswersMap.put('q7_0', Utils.createTestSubmissionAnswer(null, 'q7', 'Maize', null, null, 0));
        submissionAnswersMap.put('q8_0', Utils.createTestSubmissionAnswer(null, 'q8', '1', null, null, null));
        submissionAnswersMap.put('q7_1', Utils.createTestSubmissionAnswer(null, 'q7', 'Beans', null, null, 1));
        submissionAnswersMap.put('q8_1', Utils.createTestSubmissionAnswer(null, 'q8', '2', null, null, null));
        submissionAnswersMap.put('q7_2', Utils.createTestSubmissionAnswer(null, 'q7', 'Cow peas', null, null, 2));
        submissionAnswersMap.put('q8_2', Utils.createTestSubmissionAnswer(null, 'q8', '1', null, null, null));
        submissionAnswersMap.put('q10_0', Utils.createTestSubmissionAnswer(null, 'q10', 'Cow peas', null, null, 0));
        submissionAnswersMap.put('q11_0', Utils.createTestSubmissionAnswer(null, 'q11', '2', null, null, 0));
        submissionAnswersMap.put('q10_1', Utils.createTestSubmissionAnswer(null, 'q10', 'Maize', null, null, 1));
        submissionAnswersMap.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12', '2', null, null, 0));
        submissionAnswersMap.put('q10_2', Utils.createTestSubmissionAnswer(null, 'q10', 'Beans', null, null, 2));
        submissionAnswersMap.put('q12_1', Utils.createTestSubmissionAnswer(null, 'q12', '2', null, null, 1));
        submissionAnswersMap.put('q14_0', Utils.createTestSubmissionAnswer(null, 'q14', 'Maize', null, null, 0));
        submissionAnswersMap.put('q15_0', Utils.createTestSubmissionAnswer(null, 'q15', '1', null, null, null));
        submissionAnswersMap.put('q14_1', Utils.createTestSubmissionAnswer(null, 'q14', 'Beans', null, null, 1));
        submissionAnswersMap.put('q15_1', Utils.createTestSubmissionAnswer(null, 'q15', '2', null, null, null));
        submissionAnswersMap.put('q14_2', Utils.createTestSubmissionAnswer(null, 'q14', 'Cow peas', null, null, 2));
        submissionAnswersMap.put('q15_2', Utils.createTestSubmissionAnswer(null, 'q15', '1', null, null, null));
        submissionAnswersMap.put('q18_0', Utils.createTestSubmissionAnswer(null, 'q18', 'Maize', null, null, 0));
        submissionAnswersMap.put('q19_0', Utils.createTestSubmissionAnswer(null, 'q19', '25', null, null, 0));
        submissionAnswersMap.put('q20_0', Utils.createTestSubmissionAnswer(null, 'q20', '5', null, null, 0));
        submissionAnswersMap.put('q18_1', Utils.createTestSubmissionAnswer(null, 'q18', 'Beans', null, null, 1));
        submissionAnswersMap.put('q19_1', Utils.createTestSubmissionAnswer(null, 'q19', '30', null, null, 1));
        submissionAnswersMap.put('q20_1', Utils.createTestSubmissionAnswer(null, 'q20', '10', null, null, 1));
        submissionAnswersMap.put('q18_2', Utils.createTestSubmissionAnswer(null, 'q18', 'Cow peas', null, null, 2));
        submissionAnswersMap.put('q19_2', Utils.createTestSubmissionAnswer(null, 'q19', '20', null, null, 2));
        submissionAnswersMap.put('q20_2', Utils.createTestSubmissionAnswer(null, 'q20', '10', null, null, 2));
        submissionAnswersMap.put('q29_0', Utils.createTestSubmissionAnswer(null, 'q29', '1234 5678', null, null, null));
        returnValues = ProcessEwarehouseSurveys.processEwarehouseHarvestSurvey(submission, submissionAnswersMap, person);         
        System.assert(returnValues.get(0).equals('1'));
        test.stopTest();
    }
}