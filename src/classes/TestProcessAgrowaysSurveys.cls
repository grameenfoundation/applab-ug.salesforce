@isTest
public class TestProcessAgrowaysSurveys {

    @isTest static void TestProcessAgrowaysFarmerRegistration() {
        Account testAccount = new Account();
        testAccount.BillingState = 'CA';
        testAccount.Name = 'AgroWays USAID CARANA'; 
        database.SaveResult accountSaveResult = database.insert(testAccount);
        
        Country__c country = Utils.createTestCountry('Uganda');
        database.insert(country);
        District__c district = new District__c(Name='Kamuli');
        insert district;
        Subcounty__c subcounty = new Subcounty__c(Display_Name__c='Kidera', District__c=district.Id);
        insert subcounty;
        Person__c ckwPerson = Utils.createTestPerson(null, 'E-Farmer', true, null, 'Female');
        insert ckwPerson;
        Farmer__c testFarmer = Utils.createTestFarmer('AG1234', ckwPerson.Id, 'ee', false, '', '');
        insert testFarmer;

        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '21232443253';
        submission.resultHash = '1';

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'AG1234', null, null, null));
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', 'Test Farmer', null, null, null));
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', '1234567', null, null, null));
        answers.put('q4_0', Utils.createTestSubmissionAnswer(null, 'q4', 'Kafeero', null, null, null));
        answers.put('q5_0', Utils.createTestSubmissionAnswer(null, 'q5', '2', null, null, null));
        answers.put('q6_0', Utils.createTestSubmissionAnswer(null, 'q6', 'Kidera', null, null, null));
        answers.put('q7_0', Utils.createTestSubmissionAnswer(null, 'q7', 'Sophia Jones', null, null, null));
        answers.put('q8_0', Utils.createTestSubmissionAnswer(null, 'q8', '1', null, null, null));
        answers.put('q9_0', Utils.createTestSubmissionAnswer(null, 'q9', '1', null, null, null));
        answers.put('q10_0', Utils.createTestSubmissionAnswer(null, 'q10', '5', null, null, null));
        answers.put('q11_0', Utils.createTestSubmissionAnswer(null, 'q11', '6 7 8', null, null, null));
        answers.put('q13_0', Utils.createTestSubmissionAnswer(null, 'q13', '7 8 9', null, null, null));
        answers.put('q15_0', Utils.createTestSubmissionAnswer(null, 'q15', '3', null, null, null));
        answers.put('q16_0', Utils.createTestSubmissionAnswer(null, 'q16', '3', null, null, null));
        answers.put('q17_0', Utils.createTestSubmissionAnswer(null, 'q17', '4', null, null, null));
        answers.put('q18_0', Utils.createTestSubmissionAnswer(null, 'q18', '2', null, null, null));
        answers.put('q19_0', Utils.createTestSubmissionAnswer(null, 'q19', '2', null, null, null));
        answers.put('q20_0', Utils.createTestSubmissionAnswer(null, 'q20', '2', null, null, null));
        answers.put('q21_0', Utils.createTestSubmissionAnswer(null, 'q21', '2', null, null, null));
        answers.put('q22_0', Utils.createTestSubmissionAnswer(null, 'q22', '1', null, null, null));
        answers.put('q23_0', Utils.createTestSubmissionAnswer(null, 'q23', '2', null, null, null));
        answers.put('q24_0', Utils.createTestSubmissionAnswer(null, 'q24', '1', null, null, null));

        Person__c person = Utils.createTestPerson(null, 'E-CKW', true, null, 'Female');
        insert person;
        List<String> returnValues = new List<String>();
        test.startTest();

        // Test for failure due to already used farmer id
        returnValues = ProcessAgrowaysSurveys.processAgrowaysFarmerRegistration(submission, answers, person);
        System.assert(returnValues.get(0).equals('0'));

        // Now test for success if the farmer id is unique
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'AG1235', null, null, null));
        returnValues = ProcessAgrowaysSurveys.processAgrowaysFarmerRegistration(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));
        test.stopTest();
    }

    @isTest static void TestProcessAgrowaysFarmerGroupRegistration() {

        District__c district = new District__c(Name='Kamuli');
        insert district;
        Person__c person = Utils.createTestPerson(null, 'Agroways-CKW', true, null, 'Female');
        insert person;

        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '21232443253';
        submission.resultHash = '1';
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', 'Agroways Guy', null, null, null));
        answers.put('q5_0', Utils.createTestSubmissionAnswer(null, 'q5', '2', null, null, null));
        answers.put('q9_0', Utils.createTestSubmissionAnswer(null, 'q9', 'Kwetarana', null, null, null));
        answers.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12', '1', null, null, null));
        answers.put('q13_0', Utils.createTestSubmissionAnswer(null, 'q13', '3', null, null, null));
        answers.put('q14_0', Utils.createTestSubmissionAnswer(null, 'q14', '2012', null, null, null));
        answers.put('q15_0', Utils.createTestSubmissionAnswer(null, 'q15', '14', null, null, null));
        answers.put('q17_0', Utils.createTestSubmissionAnswer(null, 'q17', '5', null, null, null));
        answers.put('q19_0', Utils.createTestSubmissionAnswer(null, 'q19', '6', null, null, null));
        answers.put('q21_0', Utils.createTestSubmissionAnswer(null, 'q21', '2 4 6', null, null, null));
        answers.put('q23_0', Utils.createTestSubmissionAnswer(null, 'q23', '2', null, null, null));

        test.startTest();
        List<String>returnValues = ProcessAgrowaysSurveys.processFarmerGroupRegistration(submission, answers, person);
        test.stopTest();
        System.assert(returnValues.get(0).equals('1'));
    }
}