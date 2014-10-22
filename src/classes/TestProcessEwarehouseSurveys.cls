/**
* A test class for the ProcessEwarehouseSurveys class methods
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
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', 'www.google.co.ug', null, null, null));
        answers.put('q8_0', Utils.createTestSubmissionAnswer(null, 'q8', '5', null, null, null));
        answers.put('q11_0', Utils.createTestSubmissionAnswer(null, 'q11', '12345', null, null, null));
        answers.put('q13_0', Utils.createTestSubmissionAnswer(null, 'q13', '0', null, null, null));
        answers.put('q14_0', Utils.createTestSubmissionAnswer(null, 'q14', '12345', null, null, null));
        answers.put('q17_0', Utils.createTestSubmissionAnswer(null, 'q17', '2', null, null, null));
        answers.put('q18_0', Utils.createTestSubmissionAnswer(null, 'q18', 'Sophia Jones', null, null, null));
        answers.put('q19_0', Utils.createTestSubmissionAnswer(null, 'q19', '2123123', null, null, null));
        answers.put('q26_0', Utils.createTestSubmissionAnswer(null, 'q26', '1', null, null, null));
        answers.put('q28_0', Utils.createTestSubmissionAnswer(null, 'q28', '20', null, null, null));
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
        answers.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12', '14/4de/rf/452', null, null, null));
        answers.put('q29_0', Utils.createTestSubmissionAnswer(null, 'q29', '1 2 3', null, null, null));
        answers.put('q75_0', Utils.createTestSubmissionAnswer(null, 'q75', '2 3 4', null, null, null));
        answers.put('q41_0', Utils.createTestSubmissionAnswer(null, 'q41', '1', null, null, null));
        answers.put('q60_0', Utils.createTestSubmissionAnswer(null, 'q60', '1', null, null, null));
        answers.put('q37_0', Utils.createTestSubmissionAnswer(null, 'q37', '1', null, null, null));
        answers.put('q71_0', Utils.createTestSubmissionAnswer(null, 'q71', '3', null, null, null));
        answers.put('q60_0', Utils.createTestSubmissionAnswer(null, 'q67', '2', null, null, null));
        answers.put('q50_0', Utils.createTestSubmissionAnswer(null, 'q50', '5', null, null, null));
        answers.put('q62_0', Utils.createTestSubmissionAnswer(null, 'q62', '1 2 3', null, null, null));
        answers.put('q63_0', Utils.createTestSubmissionAnswer(null, 'q63', '1 2 3', null, null, null));
        answers.put('q64_0', Utils.createTestSubmissionAnswer(null, 'q64', '1', null, null, null));
        answers.put('q56_0', Utils.createTestSubmissionAnswer(null, 'q56', '1', null, null, null));
        
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
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'Mario Jardel Golazo', null, null, null));
        returnValues = ProcessEwarehouseSurveys.processEwarehouseFarmerRegistration(submission, answers, person);         
        System.assert(returnValues.get(0).equals('1'));

        // Test for person without a middle name and single marital status
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'Mario Jardel', null, null, null));
        answers.put('q11_0', Utils.createTestSubmissionAnswer(null, 'q11', '133332', null, null, null));
        answers.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12', '54/32/3/45', null, null, null));
        answers.put('q17_0', Utils.createTestSubmissionAnswer(null, 'q17', '1', null, null, null));
        answers.put('q13_0', Utils.createTestSubmissionAnswer(null, 'q13', '12345678', null, null, null));
        returnValues = ProcessEwarehouseSurveys.processEwarehouseFarmerRegistration(submission, answers, person);         
        System.assert(returnValues.get(0).equals('1'));

        // Test for person with only 1 name
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'Mario', null, null, null));
        answers.put('q11_0', Utils.createTestSubmissionAnswer(null, 'q11', '53452342', null, null, null));
        answers.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12', '3443523', null, null, null));
        returnValues = ProcessEwarehouseSurveys.processEwarehouseFarmerRegistration(submission, answers, person);         
        System.assert(returnValues.get(0).equals('0'));
        
       /** // Test for already used farmer id
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'Mario Goetze', null, null, null));
        answers.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12', '54/32/3/45', null, null, null));
        returnValues = ProcessEwarehouseSurveys.processEwarehouseFarmerRegistration(submission, answers, person);
        System.assert(returnValues.get(0).equals('0'));**/
        
        // Test for Other in the group name question
		answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'Mario Goetze', null, null, null));
        answers.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12', 'as/xd3/49/523', null, null, null));
        answers.put('q8_0', Utils.createTestSubmissionAnswer(null, 'q8', '151', null, null, null));
        answers.put('q9_0', Utils.createTestSubmissionAnswer(null, 'q9', 'Makerere', null, null, null));
        returnValues = ProcessEwarehouseSurveys.processEwarehouseFarmerRegistration(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));
        test.stopTest();
    }

    /**
     * A test method for the processEwarehouseHarvestRegistration method
     */
    static testMethod void testProcessEwarehouseHarvestSurvey() {

		District__c testDistrict = Utils.createTestDistrict('ew');
		Person__c testPerson = Utils.createTestPerson(null, 'E-FARMER', true, null, 'Female');
		insert testPerson;
		insert testDistrict;
		Farmer__c testFarmer = Utils.createTestFarmer('ABC123', testPerson.Id, '', false, testDistrict.Id, 'Male');
		insert testFarmer;
		
		Markets__c ewarehseMarket = new Markets__c();
		ewarehseMarket.Name = 'e-warehouse';
		insert ewarehseMarket;
		
		Commodities__c beans = new Commodities__c(Name = 'Beans', Market__c = ewarehseMarket.Id, Highest_Wholesale_Price__c = 1000);
		Commodities__c maize = new Commodities__c(Name = 'Maize', Market__c = ewarehseMarket.Id, Highest_Wholesale_Price__c = 2000);
		Commodities__c cowPeas = new Commodities__c(Name = 'Cow peas', Market__c = ewarehseMarket.Id, Highest_Wholesale_Price__c = 3000);
		Commodities__c pigeonPeas = new Commodities__c(Name = 'Pigeon peas', Market__c = ewarehseMarket.Id, Highest_Wholesale_Price__c = 4000);
		Commodities__c dolichos = new Commodities__c(Name = 'Black beans(Dolichos)', Market__c = ewarehseMarket.Id, Highest_Wholesale_Price__c = 5000);
		Commodities__c greenGrams = new Commodities__c(Name = 'Green grams', Market__c = ewarehseMarket.Id, Highest_Wholesale_Price__c = 6000);
		insert beans;
		insert maize;
		insert cowPeas;
		insert pigeonPeas;
		insert dolichos;
		insert greenGrams;
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '21232443253';
        submission.resultHash = '1';

        Person__c person = Utils.createTestPerson(null, 'E-FARMER2', true, null, 'Male');

		// Test for failure when no crop is selected
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'ABC123', null, null, 0));
        answers.put('q6_0', Utils.createTestSubmissionAnswer(null, 'q6', ' ', null, null, 0));
        answers.put('q8_0', Utils.createTestSubmissionAnswer(null, 'q8', 'Maize', null, null, 0));
        answers.put('q9_0', Utils.createTestSubmissionAnswer(null, 'q9', '30', null, null, 0));
        answers.put('q8_1', Utils.createTestSubmissionAnswer(null, 'q8', 'Beans', null, null, 1));
        answers.put('q9_1', Utils.createTestSubmissionAnswer(null, 'q9', '40', null, null, 1));
        answers.put('q8_2', Utils.createTestSubmissionAnswer(null, 'q8', 'Pigeonpeas', null, null, 2));
        answers.put('q9_2', Utils.createTestSubmissionAnswer(null, 'q9', '30', null, null, 2));
        answers.put('q11_0', Utils.createTestSubmissionAnswer(null, 'q11', 'Maize', null, null, 0));
        answers.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12', '2', null, null, 0));
        answers.put('q11_1', Utils.createTestSubmissionAnswer(null, 'q11', 'Beans', null, null, 1));
        answers.put('q13_0', Utils.createTestSubmissionAnswer(null, 'q13', '2', null, null, 0));
        answers.put('q11_2', Utils.createTestSubmissionAnswer(null, 'q11', 'Pigeonpeas', null, null, 2));
        answers.put('q13_1', Utils.createTestSubmissionAnswer(null, 'q13', '2', null, null, 1));
        answers.put('q19_0', Utils.createTestSubmissionAnswer(null, 'q19', 'Maize', null, null, 0));
        answers.put('q20_0', Utils.createTestSubmissionAnswer(null, 'q20', '25', null, null, 0));
        answers.put('q21_0', Utils.createTestSubmissionAnswer(null, 'q21', '5', null, null, 0));
        answers.put('q19_1', Utils.createTestSubmissionAnswer(null, 'q19', 'Beans', null, null, 1));
        answers.put('q20_1', Utils.createTestSubmissionAnswer(null, 'q20', '30', null, null, 1));
        answers.put('q21_1', Utils.createTestSubmissionAnswer(null, 'q21', '10', null, null, 1));
        answers.put('q19_2', Utils.createTestSubmissionAnswer(null, 'q19', 'Pigeonpeas', null, null, 2));
        answers.put('q20_2', Utils.createTestSubmissionAnswer(null, 'q20', '20', null, null, 2));
        answers.put('q21_2', Utils.createTestSubmissionAnswer(null, 'q21', '10', null, null, 2));
        answers.put('q22_0', Utils.createTestSubmissionAnswer(null, 'q22', '0', null, null, 0));
        answers.put('q30_0', Utils.createTestSubmissionAnswer(null, 'q30', '1234 5678', null, null, null));

        Map<String, Submission_Answer__c> nonMaizeAnswers = new Map<String, Submission_Answer__c>();
        nonMaizeAnswers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'ABC123', null, null, 0));
        nonMaizeAnswers.put('q6_0', Utils.createTestSubmissionAnswer(null, 'q6', ' ', null, null, 0));
        nonMaizeAnswers.put('q8_0', Utils.createTestSubmissionAnswer(null, 'q8', 'Blackbeans', null, null, 0));
        nonMaizeAnswers.put('q9_0', Utils.createTestSubmissionAnswer(null, 'q9', '30', null, null, 0));
        nonMaizeAnswers.put('q8_1', Utils.createTestSubmissionAnswer(null, 'q8', 'Beans', null, null, 1));
        nonMaizeAnswers.put('q9_1', Utils.createTestSubmissionAnswer(null, 'q9', '40', null, null, 1));
        nonMaizeAnswers.put('q8_2', Utils.createTestSubmissionAnswer(null, 'q8', 'Pigeonpeas', null, null, 2));
        nonMaizeAnswers.put('q9_2', Utils.createTestSubmissionAnswer(null, 'q9', '30', null, null, 2));
        nonMaizeAnswers.put('q11_0', Utils.createTestSubmissionAnswer(null, 'q11', 'Blackbeans', null, null, 0));
        nonMaizeAnswers.put('q13_0', Utils.createTestSubmissionAnswer(null, 'q13', '2', null, null, 0));
        nonMaizeAnswers.put('q11_1', Utils.createTestSubmissionAnswer(null, 'q11', 'Beans', null, null, 1));
        nonMaizeAnswers.put('q13_1', Utils.createTestSubmissionAnswer(null, 'q13', '2', null, null, 1));
        nonMaizeAnswers.put('q11_2', Utils.createTestSubmissionAnswer(null, 'q11', 'Pigeonpeas', null, null, 2));
        nonMaizeAnswers.put('q13_2', Utils.createTestSubmissionAnswer(null, 'q13', '2', null, null, 2));
        nonMaizeAnswers.put('q19_0', Utils.createTestSubmissionAnswer(null, 'q19', 'Blackbeans', null, null, 0));
        nonMaizeAnswers.put('q20_0', Utils.createTestSubmissionAnswer(null, 'q20', '25', null, null, 0));
        nonMaizeAnswers.put('q21_0', Utils.createTestSubmissionAnswer(null, 'q21', '5', null, null, 0));
        nonMaizeAnswers.put('q19_1', Utils.createTestSubmissionAnswer(null, 'q19', 'Beans', null, null, 1));
        nonMaizeAnswers.put('q20_1', Utils.createTestSubmissionAnswer(null, 'q20', '30', null, null, 1));
        nonMaizeAnswers.put('q21_1', Utils.createTestSubmissionAnswer(null, 'q21', '10', null, null, 1));
        nonMaizeAnswers.put('q19_2', Utils.createTestSubmissionAnswer(null, 'q19', 'Pigeonpeas', null, null, 2));
        nonMaizeAnswers.put('q20_2', Utils.createTestSubmissionAnswer(null, 'q20', '20', null, null, 2));
        nonMaizeAnswers.put('q21_2', Utils.createTestSubmissionAnswer(null, 'q21', '10', null, null, 2));
        nonMaizeAnswers.put('q22_0', Utils.createTestSubmissionAnswer(null, 'q22', '0', null, null, 0));
        nonMaizeAnswers.put('q30_0', Utils.createTestSubmissionAnswer(null, 'q30', '1234 5678', null, null, null));
		nonMaizeAnswers.put('q6_0', Utils.createTestSubmissionAnswer(null, 'q6', 'Blackbeans Beans Pigeonpeas', null, null, 0));

        Map<String, Submission_Answer__c> maizeAnswers = new Map<String, Submission_Answer__c>();
        maizeAnswers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'ABC123', null, null, 0));
        maizeAnswers.put('q8_0', Utils.createTestSubmissionAnswer(null, 'q8', 'Blackbeans', null, null, 0));
        maizeAnswers.put('q9_0', Utils.createTestSubmissionAnswer(null, 'q9', '30', null, null, 0));
        maizeAnswers.put('q8_1', Utils.createTestSubmissionAnswer(null, 'q8', 'Maize', null, null, 1));
        maizeAnswers.put('q9_1', Utils.createTestSubmissionAnswer(null, 'q9', '40', null, null, 1));
        maizeAnswers.put('q8_2', Utils.createTestSubmissionAnswer(null, 'q8', 'Pigeonpeas', null, null, 2));
        maizeAnswers.put('q9_2', Utils.createTestSubmissionAnswer(null, 'q9', '30', null, null, 2));
        maizeAnswers.put('q11_0', Utils.createTestSubmissionAnswer(null, 'q11', 'Blackbeans', null, null, 0));
        maizeAnswers.put('q13_0', Utils.createTestSubmissionAnswer(null, 'q13', '2', null, null, 0));
        maizeAnswers.put('q11_1', Utils.createTestSubmissionAnswer(null, 'q11', 'Maize', null, null, 1));
        maizeAnswers.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12', '2', null, null, 0));
        maizeAnswers.put('q11_2', Utils.createTestSubmissionAnswer(null, 'q11', 'Pigeonpeas', null, null, 2));
        maizeAnswers.put('q13_1', Utils.createTestSubmissionAnswer(null, 'q13', '2', null, null, 1));
        maizeAnswers.put('q19_0', Utils.createTestSubmissionAnswer(null, 'q19', 'Blackbeans', null, null, 0));
        maizeAnswers.put('q20_0', Utils.createTestSubmissionAnswer(null, 'q20', '25', null, null, 0));
        maizeAnswers.put('q21_0', Utils.createTestSubmissionAnswer(null, 'q21', '5', null, null, 0));
        maizeAnswers.put('q19_1', Utils.createTestSubmissionAnswer(null, 'q19', 'Maize', null, null, 1));
        maizeAnswers.put('q20_1', Utils.createTestSubmissionAnswer(null, 'q20', '30', null, null, 1));
        maizeAnswers.put('q21_1', Utils.createTestSubmissionAnswer(null, 'q21', '10', null, null, 1));
        maizeAnswers.put('q19_2', Utils.createTestSubmissionAnswer(null, 'q19', 'Pigeonpeas', null, null, 2));
        maizeAnswers.put('q20_2', Utils.createTestSubmissionAnswer(null, 'q20', '20', null, null, 2));
        maizeAnswers.put('q21_2', Utils.createTestSubmissionAnswer(null, 'q21', '10', null, null, 2));
        maizeAnswers.put('q22_0', Utils.createTestSubmissionAnswer(null, 'q22', '0', null, null, 0));
        maizeAnswers.put('q30_0', Utils.createTestSubmissionAnswer(null, 'q30', '1234 5678', null, null, null));
		maizeAnswers.put('q6_0', Utils.createTestSubmissionAnswer(null, 'q6', 'Blackbeans Maize Pigeonpeas', null, null, 0));

        List<String> returnValues = new List<String>();
        test.startTest();

        //Test for failure
        returnValues = ProcessEwarehouseSurveys.processEwarehouseHarvestSurvey(submission, answers, person);         
        System.assert(returnValues.get(0).equals('0'));
               
        // Test for success
        answers.put('q6_0', Utils.createTestSubmissionAnswer(null, 'q6', 'Maize Beans Pigeonpeas', null, null, 0));
        returnValues = ProcessEwarehouseSurveys.processEwarehouseHarvestSurvey(submission, answers, person);         
        System.assert(returnValues.get(0).equals('1'));
        
        // Test for when a loan has been applied for
        answers.put('q22_0', Utils.createTestSubmissionAnswer(null, 'q22', '1', null, null, 0));
        answers.put('q25_0', Utils.createTestSubmissionAnswer(null, 'q25', '5000', null, null, 0));
        returnValues = ProcessEwarehouseSurveys.processEwarehouseHarvestSurvey(submission, answers, person);      
        System.assert(returnValues.get(0).equals('1'));
        
        // Test for when maize is not included among the crops harvested
        returnValues = ProcessEwarehouseSurveys.processEwarehouseHarvestSurvey(submission, nonMaizeAnswers, person);       
        System.assert(returnValues.get(0).equals('1'));
        
        returnValues = ProcessEwarehouseSurveys.processEwarehouseHarvestSurvey(submission, maizeAnswers, person);      
        System.assert(returnValues.get(0).equals('1'));
        
        // Test for non-existent farmer id
        maizeAnswers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'ABC123X', null, null, 0));
        returnValues = ProcessEwarehouseSurveys.processEwarehouseHarvestSurvey(submission, maizeAnswers, person);      
        System.assert(returnValues.get(0).equals('0'));
        test.stopTest();
    }

    /**
     * A test method for the processSaleRegistration method
     */
    static testMethod void testProcessSaleRegistration() {
    	
    	District__c testDistrict = Utils.createTestDistrict('ew');
		Person__c testPerson = Utils.createTestPerson(null, 'E-FARMER', true, null, 'Female');
		insert testPerson;
		insert testDistrict;
		Farmer__c testFarmer = Utils.createTestFarmer('ABC123', testPerson.Id, '', false, testDistrict.Id, 'Male');
		insert testFarmer;

		Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'ABC123', null, null, 0));
        answers.put('q15_0', Utils.createTestSubmissionAnswer(null, 'q15', 'xyz123', null, null, 0));
        answers.put('q5_0', Utils.createTestSubmissionAnswer(null, 'q5', 'Maize', null, null, 0));
        answers.put('q6_0', Utils.createTestSubmissionAnswer(null, 'q6', '2', null, null, 0));
        answers.put('q7_0', Utils.createTestSubmissionAnswer(null, 'q7', '30', null, null, 0));
        answers.put('q5_1', Utils.createTestSubmissionAnswer(null, 'q5', 'Beans', null, null, 1));
        answers.put('q6_1', Utils.createTestSubmissionAnswer(null, 'q6', '3', null, null, 1));
        answers.put('q7_1', Utils.createTestSubmissionAnswer(null, 'q7', '40', null, null, 1));
        answers.put('q5_2', Utils.createTestSubmissionAnswer(null, 'q5', 'Pigeonpeas', null, null, 2));
        answers.put('q6_2', Utils.createTestSubmissionAnswer(null, 'q6', '5', null, null, 2));
        answers.put('q7_2', Utils.createTestSubmissionAnswer(null, 'q7', '60', null, null, 2));
        answers.put('q5_3', Utils.createTestSubmissionAnswer(null, 'q5', 'Blackbeans', null, null, 3));
        answers.put('q6_3', Utils.createTestSubmissionAnswer(null, 'q6', '2', null, null, 3));
        answers.put('q7_3', Utils.createTestSubmissionAnswer(null, 'q7', '30', null, null, 3));
        answers.put('q5_4', Utils.createTestSubmissionAnswer(null, 'q5', 'Cowpeas', null, null, 4));
        answers.put('q6_4', Utils.createTestSubmissionAnswer(null, 'q6', '3', null, null, 4));
        answers.put('q7_4', Utils.createTestSubmissionAnswer(null, 'q7', '40', null, null, 4));
        answers.put('q5_5', Utils.createTestSubmissionAnswer(null, 'q5', 'Greengrams', null, null, 5));
        answers.put('q6_5', Utils.createTestSubmissionAnswer(null, 'q6', '5', null, null, 5));
        answers.put('q7_5', Utils.createTestSubmissionAnswer(null, 'q7', '60', null, null, 5));
        

        List<String> returnValues = new List<String>();
        test.startTest();
        returnValues = ProcessEwarehouseSurveys.processSaleRegistration(answers);
        System.assert(returnValues.get(0).equals('1'));
        
        // Test when farmer does not exist
        answers.remove('q1_0');
        returnValues = ProcessEwarehouseSurveys.processSaleRegistration(answers);
        System.assert(returnValues.get(0).equals('0'));
        test.stopTest();
    }
    
    static testMethod void myScheduledClass() {

        Test.startTest();
        
        String CRON_EXP = '0 0 0 1 1 ? 2035';  
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new ScheduledMarketPriceSender());

        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2035-01-01 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
}