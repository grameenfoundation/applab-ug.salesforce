/**
 * A test class for the ProcessNaadsSurveys class methods
 */
@isTest
private class TestProcessNaadsSurveys {

    /**
     * Test method for the processNaadsBaseline method
     */
    private static TestMethod void testProcessNaadsBaselineSurvey(){
        Account testAccount = new Account();
        testAccount.BillingState = 'CA';
        testAccount.Name = 'NAADS'; 
        database.SaveResult accountSaveResult = database.insert(testAccount);

        M_E_Metric__c metric1 = new M_E_Metric__c();
        metric1.Name = 'Farmer_group_trainings_meetings_or_attended';
        metric1.Organisation__c = accountSaveResult.getId();
        M_E_Metric__c metric2= new M_E_Metric__c();
        metric2.Name = 'Number_of_farmer_supervisory_visits_conducted';
        metric2.Organisation__c = accountSaveResult.getId();
        M_E_Metric__c metric3= new M_E_Metric__c();
        metric3.Name = 'Number_of_farmers_attending_group_trainings_meetings';
        metric3.Organisation__c = accountSaveResult.getId();
        database.insert(new M_E_Metric__c[] { metric1,  metric2, metric3});

        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '32432443253';
        submission.resultHash = '1';
            
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', '2', null, null, null));
        answers.put('q32_0', Utils.createTestSubmissionAnswer(null, 'q32', '1', null, null, null));
        answers.put('q41_0', Utils.createTestSubmissionAnswer(null, 'q41', '1', null, null, null));
        answers.put('q60_0', Utils.createTestSubmissionAnswer(null, 'q60', '1', null, null, null));
        answers.put('q37_0', Utils.createTestSubmissionAnswer(null, 'q37', '1', null, null, null));
        answers.put('q71_0', Utils.createTestSubmissionAnswer(null, 'q71', '3', null, null, null));
        answers.put('q60_0', Utils.createTestSubmissionAnswer(null, 'q67', '2', null, null, null));
        answers.put('q50_0', Utils.createTestSubmissionAnswer(null, 'q50', '5', null, null, null));

        Person__c person = Utils.createTestPerson(null, 'TestingNAADS', true, null, 'Female');
        District__c district = new District__c();
        district.Name = 'Serere';
        database.SaveResult saveResult = database.insert(district);
        
        // Create subcounty
        Subcounty__c kyere = new Subcounty__c();
        kyere.District__c = saveResult.getId();
        kyere.Display_Name__c = 'Kyere';
        database.insert(kyere);
        List<String> returnValues = new List<String>();
        test.startTest();
        returnValues = ProcessNaadsSurveys.processNaadsBaselineSurvey(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));
        
        // Test failure
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', '4', null, null, null));
        returnValues = ProcessNaadsSurveys.processNaadsBaselineSurvey(submission, answers, person);
        System.assert(returnValues.get(0).equals('0'));
        test.stopTest();
    }

    /**
     * Test method for the processAdvisoryServicesSurvey method
     */    
    private static TestMethod void testProcessAdvisoryServicesSurvey() {
    
        // Create a NAADS ASP
        Person__c person = Utils.createTestPerson(null, 'NAADS', true, null, 'Female');
        person.Type__c = 'ASP';
        database.insert(person);
        District__c district = new District__c();
        district.Name = 'Serere';
        database.SaveResult saveResult = database.insert(district);
        
        // Create subcounty
        Subcounty__c kateta = new Subcounty__c();
        kateta.District__c = saveResult.getId();
        kateta.Display_Name__c = 'Kateta';
        database.insert(kateta);
        Account testAccount = new Account();
        testAccount.BillingState = 'CA';
        testAccount.Name = 'NAADS'; 
        database.SaveResult accountSaveResult = database.insert(testAccount);

        M_E_Metric__c metric1 = new M_E_Metric__c();
        metric1.Name = 'Percentage_of_beneficiaries_satisfied_with_advisory_services';
        metric1.Organisation__c = accountSaveResult.getId();
        M_E_Metric__c metric2= new M_E_Metric__c();
        metric2.Name = 'Percentage_of_farmers_noticing_improvement_in_NAADS_extension_services';
        metric2.Organisation__c = accountSaveResult.getId();
        M_E_Metric__c metric3= new M_E_Metric__c();
        metric3.Name = 'Percentage_of_farmers_reporting_a_feedback_channel_for_NAADS';
        metric3.Organisation__c = accountSaveResult.getId();
        M_E_Metric__c metric4= new M_E_Metric__c();
        metric4.Name = 'Percentage_of_farmers_satisfied_with_feedback_channel_for_NAADS';
        metric4.Organisation__c = accountSaveResult.getId();
        M_E_Metric__c metric5= new M_E_Metric__c();
        metric5.Name = 'Percentage_of_beneficiaries_perceiving_involvement_in_group_decision_making';
        metric5.Organisation__c = accountSaveResult.getId();
        
        database.insert(new M_E_Metric__c[] { metric1,  metric2, metric3, metric4, metric5});
        
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '32432443253';
        submission.resultHash = '1';
        
        // Test Farmer group training
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', '2', null, null, null));
        answers.put('q19_0', Utils.createTestSubmissionAnswer(null, 'q19', '9', null, null, null));
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', '6', null, null, null));
        List<String> returnValues = new List<String>();
        test.startTest();
        returnValues = ProcessNaadsSurveys.processAdvisoryServiceSurvey(submission, answers, person);         
        System.assert(returnValues.get(0).equals('1'));
         
        // Test Supervisory visiting report
        Map<String, Submission_Answer__c> supervisoryAnswers = new Map<String, Submission_Answer__c>();
        supervisoryAnswers .put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', '3', null, null, null));
        supervisoryAnswers .put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', '6', null, null, null));
        returnValues = ProcessNaadsSurveys.processAdvisoryServiceSurvey(submission, supervisoryAnswers, person);         
        System.assert(returnValues.get(0).equals('1'));
        test.stopTest();
    }
}