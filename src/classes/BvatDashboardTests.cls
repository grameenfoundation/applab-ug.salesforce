@isTest
private class BvatDashboardTests {
    static testMethod void shouldTranslateGender() {        
        String result = BvatHelpers.testTranslateGender('2');        
        System.assert(result.equals('Female'));
    }
    
    static testMethod void shouldTranslateFarmingReason() {        
        String result = BvatHelpers.testTranslateFarmingReason('3');        
        System.assert(result.equals('Consumption and Selling'));
    }
    
    static testMethod void shouldTranslateEducationLevel() {        
        String result = BvatHelpers.testTranslateEducationLevel('4');        
        System.assert(result.equals('University'));
    }
    
    static testMethod void shouldTranslateInformationAvenue() {        
        String result = BvatHelpers.testTranslateInformationAvenue('3');        
        System.assert(result.equals('TOF Radio'));
    }
    
    static testMethod void shouldTranslateAreasOfExpertise() {        
        String result = BvatHelpers.testTranslateAreasOfExpertise('3');        
        System.assert(result.equals('Animal Keeping'));
    }
    
    static testMethod void shouldTranslateInformationBenefits() {        
        String result = BvatHelpers.testTranslateInformationBenefits('1');        
        System.assert(result.equals('Improved soil fertility'));
    }
    
    static testMethod void shouldTranslateContentAreasTrained() {        
        String result = BvatHelpers.testTranslateContentAreasTrained('2');        
        System.assert(result.equals('Crop Management'));
    }
    
    static testMethod void shouldTranslateEnvironment() {        
        String result = BvatHelpers.testTranslateEnvironment('3');        
        System.assert(result.equals('Soil management'));
    }
    
    static testMethod void shouldTranslateCropManagement() {        
        String result = BvatHelpers.testTranslateCropManagement('2');        
        System.assert(result.equals('Fodder production'));
    }
    
    static testMethod void shouldTranslateAnimalKeeping() {        
        String result = BvatHelpers.testTranslateAnimalKeeping('4');        
        System.assert(result.equals('Zoonotic diseases'));
    }
    
    static testMethod void shouldTranslateHumanHealth() {        
        String result = BvatHelpers.testTranslateHumanHealth('4');        
        System.assert(result.equals('Hygiene and sanitation'));
    }
    
    static testMethod void shouldTranslateKeyContentAreas() {        
        String result = BvatHelpers.testTranslateKeyContentAreas('4');        
        System.assert(result.equals('Human Health'));
    }
    
    static testMethod void shouldTranslateEnvironmentKeyAreas() {        
        String result = BvatHelpers.testTranslateEnvironmentKeyAreas('5');        
        System.assert(result.equals('Conservation agriculture'));
    }
    
    static testMethod void shouldTranslateCropManagementKeyAreas() {        
        String result = BvatHelpers.testTranslateCropManagementKeyAreas('5');        
        System.assert(result.equals('Cultural practices'));
    }
    
    static testMethod void shouldTranslateHumanHealthKeyAreas() {        
        String result = BvatHelpers.testTranslateHumanHealthKeyAreas('2');        
        System.assert(result.equals('Nutrition related diseases'));
    }
    
    static testMethod void shouldTranslateAnimalKeepingKeyAreas() {        
        String result = BvatHelpers.testTranslateAnimalKeepingKeyAreas('3');        
        System.assert(result.equals('Livestock health and diseases'));
    }
    
    static testMethod void shouldGetTranslatedSetOfContentAreasTrained() {        
        Set<String> result = new Set<String>();
        Boolean retValue = result.addAll(BvatHelpers.testGetTranslatedSetOfContentAreasTrained(new Set<String>{'1','3'}));        
        System.assert(result.size() == 2);
    }  
    
    static testMethod void shouldGenerateCsvFromSetOfContentAreasTrained() {
        Set<String> data = new Set<String> {'1','3','4'};       
        String result = BvatHelpers.testGenerateCsvFromSetOfContentAreasTrained(data);        
        System.assert(result.equals('Environment;Animal Keeping;Human Health'));        
    }
    
    static testMethod void testProcessContentSurvey() {

        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '21232443253';
        submission.resultHash = '1';
        
        Person__c person = Utils.createTestPerson(null, 'E-FARMER', true, null, 'Female');
        database.insert(person);
        CIW__c ciw = new CIW__c();
        ciw.GPS_Location__c = '-0.50000761 36.31579846 1996.4000244140625 5.0';
        ciw.Person__c = person.Id;
        ciw.Joining_Year__c = 2013;
        database.insert(ciw);
        
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', '1 2 3 4 5', null, null, null));
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', '2 3 5', null, null, null));
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', '5 6 7', null, null, null));
        answers.put('q4_0', Utils.createTestSubmissionAnswer(null, 'q4', '2 3 4', null, null, null));
        answers.put('q5_0', Utils.createTestSubmissionAnswer(null, 'q5', '1 3 4', null, null, null));
        answers.put('q6_0', Utils.createTestSubmissionAnswer(null, 'q6', '1 2 3 4 5 6', null, null, null));
        answers.put('q7_0', Utils.createTestSubmissionAnswer(null, 'q7', '2 3 4', null, null, null));
        answers.put('q8_0', Utils.createTestSubmissionAnswer(null, 'q8', '1 2 3', null, null, null));
        answers.put('q9_0', Utils.createTestSubmissionAnswer(null, 'q9', '1 2 3', null, null, null));
        answers.put('q10_0', Utils.createTestSubmissionAnswer(null, 'q10', '2 3', null, null, null));
        answers.put('q11_0', Utils.createTestSubmissionAnswer(null, 'q11', 'Anything', null, null, null));
        answers.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12', '2 3 5', null, null, null));
        answers.put('q13_0', Utils.createTestSubmissionAnswer(null, 'q13', '3', null, null, null));
        answers.put('q14_0', Utils.createTestSubmissionAnswer(null, 'q14', '6 7 8 9', null, null, null));
        answers.put('q15_0', Utils.createTestSubmissionAnswer(null, 'q15', 'Laughter', null, null, null));
        
        List<String> returnValues = new List<String>();
        test.startTest();
        returnValues = BvatHelpers.processContentSurvey(submission, answers, person);       
        System.assert(returnValues.get(0).equals('1'));
        test.stopTest();
    }
    
    static testMethod void testProcessFarmerRegistrationSurvey() {
    
        Account testAccount = new Account();
        testAccount.BillingState = 'CA';
        testAccount.Name = 'Biovision Africa Trust'; 
        database.SaveResult accountSaveResult = database.insert(testAccount);

        Dashboard__c dash = new Dashboard__c();
        dash.Account__c = accountSaveResult.getId();
        dash.Is_Active__c = true;
        dash.Title__c = 'testing';
        database.SaveResult dashSaveResult = database.insert(dash);

    
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '21232443253';
        submission.resultHash = '1';
        submission.interviewLatitude = '345';
        submission.interviewLongitude = '13';
        
        Person__c person = Utils.createTestPerson(null, 'E-FARMER', true, null, 'Female');
        database.insert(person);
        CIW__c ciw = new CIW__c();
        ciw.Person__c = person.Id;
        ciw.Joining_Year__c = 2013;
        ciw.GPS_Location__c = '-0.50000761 36.31579846 1996.4000244140625 5.0';
        database.SaveResult ciwSaveResult = database.insert(ciw);
        CIW__c ciw2 = [Select Id, Name from CIW__c where Id =:ciwSaveResult.getId()];
        
        // Create the metrics for use
        M_E_Metric__c metric1 = new M_E_Metric__c();
        metric1.Name = 'Farmers Registered';
        metric1.Organisation__c = accountSaveResult.getId();
        M_E_Metric__c metric2= new M_E_Metric__c();
        metric2.Name = 'Farmers Reached';
        metric2.Organisation__c = accountSaveResult.getId();
        M_E_Metric__c metric3= new M_E_Metric__c();
        metric3.Name = 'Farmers in Group';
        metric3.Organisation__c = accountSaveResult.getId();
        M_E_Metric__c metric4= new M_E_Metric__c();
        metric4.Name = ciw2.Name;
        metric4.Organisation__c = accountSaveResult.getId();
        database.insert(new M_E_Metric__c[] { metric1,  metric2, metric3, metric4});
        
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'Tom Cruise', null, null, null));
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', '1', null, null, null));
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', '30', null, null, null));
        answers.put('q4_0', Utils.createTestSubmissionAnswer(null, 'q4', '3456', null, null, null));
        answers.put('q5_0', Utils.createTestSubmissionAnswer(null, 'q5', '3', null, null, null));
        answers.put('q6_0', Utils.createTestSubmissionAnswer(null, 'q6', '5', null, null, null));
        answers.put('q7_0', Utils.createTestSubmissionAnswer(null, 'q7', '6', null, null, null));
        answers.put('q8_0', Utils.createTestSubmissionAnswer(null, 'q8', '2', null, null, null));
        answers.put('q9_0', Utils.createTestSubmissionAnswer(null, 'q9', '1', null, null, null));
        answers.put('q10_0', Utils.createTestSubmissionAnswer(null, 'q10', 'Zibulatuude', null, null, null));
        answers.put('q11_0', Utils.createTestSubmissionAnswer(null, 'q11', 'Anything', null, null, null));
        answers.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12', '35', null, null, null));
        answers.put('q14_0', Utils.createTestSubmissionAnswer(null, 'q14', '1234 345 456 67', null, null, null));
        
        
        List<String> returnValues = new List<String>();
        test.startTest();
        returnValues = BvatHelpers.processFarmerRegistrationSurvey(submission, answers, person);       
        System.assert(returnValues.get(0).equals('1'));
        
        // Test for only one name
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'Tom', null, null, null));
        returnValues = BvatHelpers.processFarmerRegistrationSurvey(submission, answers, person);       
        System.assert(returnValues.get(0).equals('1'));
        
        // Test using submission latitude and longitude
        answers.put('q14_0', Utils.createTestSubmissionAnswer(null, 'q14', '1234', null, null, null));
        returnValues = BvatHelpers.processFarmerRegistrationSurvey(submission, answers, person);       
        System.assert(returnValues.get(0).equals('1'));
        test.stopTest();    
    }
    
    static testMethod void testProcessCiwInformationSurvey() {

        Account testAccount = new Account();
        testAccount.BillingState = 'CA';
        testAccount.Name = 'NAADS'; 
        database.SaveResult accountSaveResult = database.insert(testAccount);

        Dashboard__c dash = new Dashboard__c();
        dash.Account__c = accountSaveResult.getId();
        dash.Is_Active__c = true;
        dash.Title__c = 'testing';
        database.SaveResult dashSaveResult = database.insert(dash);

        Dashboard_Section__c dashSection = new Dashboard_Section__c();
        dashSection.Dashboard__c = dashSaveResult.getId();
        dashSection.Is_Active__c = true;
        dashSection.Title__c = 'Biovision Africa Farmer Communication Program';
        database.SaveResult dashSectionSaveResult = database.insert(dashSection);

        Metric_Section__c ciwDistanceMetricSection = new Metric_Section__c();
        ciwDistanceMetricSection.Is_Active__c = true;
        ciwDistanceMetricSection.Dashboard_Section__c = dashSectionSaveResult.getId();
        ciwDistanceMetricSection.Title__c = 'Distance covered by CIW(km)';
        ciwDistanceMetricSection.Start_Date__c = date.today();
        ciwDistanceMetricSection.Default_Show__c = 1;
        database.insert(ciwDistanceMetricSection);

        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '21232443253';
        submission.resultHash = '1';
        
        Kenyan_County__c kenyaCounty = new Kenyan_County__c ();
        kenyaCounty.County_Name__c = 'Baringo County';
        database.insert(kenyaCounty);
        Person__c person = new Person__c();
        person.First_Name__c = 'TestPerson';
        database.insert(person);
        CIW__c ciw = new CIW__c();
        ciw.Person__c = person.Id;
        ciw.Joining_Year__c = 2013;
        database.insert(ciw);
        
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'Tom Cruise', null, null, null));
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', '1', null, null, null));
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', '30', null, null, null));
        answers.put('q4_0', Utils.createTestSubmissionAnswer(null, 'q4', '3', null, null, null));
        answers.put('q5_0', Utils.createTestSubmissionAnswer(null, 'q5', '1 2 3 4', null, null, null));
        answers.put('q6_0', Utils.createTestSubmissionAnswer(null, 'q6', '2012', null, null, null));
        answers.put('q7_0', Utils.createTestSubmissionAnswer(null, 'q7', '234567', null, null, null));
        answers.put('q8_0', Utils.createTestSubmissionAnswer(null, 'q8', '1', null, null, null));
        answers.put('q9_0', Utils.createTestSubmissionAnswer(null, 'q9', 'Municipality', null, null, null));
        answers.put('q10_0', Utils.createTestSubmissionAnswer(null, 'q10', 'Zibulatuude', null, null, null));
        answers.put('q11_0', Utils.createTestSubmissionAnswer(null, 'q11', '1234 345 456 67', null, null, null));

        List<String> returnValues = new List<String>();
        test.startTest();
        returnValues = BvatHelpers.processCiwInformationSurvey(submission, answers, person);       
        System.assert(returnValues.get(0).equals('1'));
        
        // Test with only 1 name
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'Tom', null, null, null));
        returnValues = BvatHelpers.processCiwInformationSurvey(submission, answers, person);       
        System.assert(returnValues.get(0).equals('1'));
        test.stopTest();    
    }
    /**
    * Tests for BvatCiwMapMarker
    */
    
    static CIW__c createTestCiw(String firstName, String lastName, String gender, String phoneNo, String gpsLocation) {
        List<String> returnValues = new List<String>();
        CIW__c ciw = new CIW__c();
        
        Person__c ciwPerson = new Person__c();
        ciwPerson.First_Name__c = firstName;
        ciwPerson.Last_Name__c = lastName;
        ciwPerson.Age__c = 25;
        ciwPerson.Gender__c = gender;
        ciwPerson.Raw_Mobile_Number__c = phoneNo;
        ciwPerson.Type__c = 'BVAT CIW';
        
        //Read the GPS Location
        String[] locationArray = gpsLocation.split(' ');
        if (locationArray != null && locationArray.size() >= 2) {
            ciwPerson.GPS_Location_N__c = locationArray[0];
            ciwPerson.GPS_Location_E__c = locationArray[1];            
        }
        
        // Set a rollback point
        Savepoint sp = Database.setSavepoint();

        // Save the person and get the id back
        String errorMessage;
        Database.SaveResult personSaveResult = Database.insert(ciwPerson);
        Id personId;
        if (!personSaveResult.isSuccess()) {
            returnValues.add('0');
            for (Database.Error error : personSaveResult.getErrors()) {

                // Build up the error message
                errorMessage = errorMessage + error.getMessage() + ' ';
            }
            returnValues.add(errorMessage);
            returnValues.add('Your submission of the CIW Information had an error in it please check the form. If you repeatedly get this message contact support');
            Database.rollback(sp);
            return ciw;
        }
        personId = personSaveResult.getId();
        
        ciw.Person__c = personId;
        ciw.Education_Level__c = 'University';
        
        
        ciw.Areas_Of_Expertise__c = 'Animal Keeping';   
        ciw.Joining_Year__c = 2010;
        ciw.Location_Name__c = 'Test Location';
        ciw.Sub_Location_Name__c = 'Test Sub-Location';
        ciw.GPS_Location__c = gpsLocation;   
        
        // Set a rollback point
        Savepoint spCiw = Database.setSavepoint();

        // Save the CIW and get the id back
        errorMessage = '';
        Database.SaveResult ciwSaveResult = Database.insert(ciw);
        Id ciwId;
        if (!ciwSaveResult.isSuccess()) {
            returnValues.add('0');
            for (Database.Error error : ciwSaveResult.getErrors()) {

                // Build up the error message
                errorMessage = errorMessage + error.getMessage() + ' ';
            }
            returnValues.add(errorMessage);
            returnValues.add('Your submission of the CIW Information had an error in it please check the form. If you repeatedly get this message contact support');
            Database.rollback(spCiw);
            return ciw;
        }
        ciwId = ciwSaveResult.getId();
        
        return ciw;
    
    }    
    
    static testMethod void testBvatCiwMapMarker() {

        CIW__c ciw = createTestCiw('Eliud','Kamau','Male','254723786908','1.53764749 33.44815689 1131.5 5.0');      
        BvatCiwMapMarker marker = new BvatCiwMapMarker(ciw); 
        String markerInfo = marker.getMarkerInfoContentString();
        System.assertEquals(markerInfo.length() > 0,true);
        System.assertEquals(markerInfo.containsAny('Kamau'),true);
    }
    
    static BVAT_Farmer__c createTestBvatFarmer(String firstName, String lastName, String gender, String phoneNo, String gpsLocation) {
        CIW__c ciw = createTestCiw('test', 'ciw', 'Male', '123456', '1234 567');

        
        List<String> returnValues = new List<String>();
        BVAT_Farmer__c farmer = new BVAT_Farmer__c();
        
        Person__c fPerson = new Person__c();
        fPerson.First_Name__c = firstName;
        fPerson.Last_Name__c = lastName;
        fPerson.Age__c = 35;
        fPerson.Gender__c = gender;
        fPerson.Raw_Mobile_Number__c = phoneNo;
                
        // Set a rollback point
        Savepoint sp = Database.setSavepoint();

        // Save the person and get the id back
        String errorMessage;
        Database.SaveResult personSaveResult = Database.insert(fPerson);
        Id personId;
        if (!personSaveResult.isSuccess()) {
            returnValues.add('0');
            for (Database.Error error : personSaveResult.getErrors()) {

                // Build up the error message
                errorMessage = errorMessage + error.getMessage() + ' ';
            }
            returnValues.add(errorMessage);
            returnValues.add('Your submission of the CIW Information had an error in it please check the form. If you repeatedly get this message contact support');
            Database.rollback(sp);
            return farmer;
        }
        personId = personSaveResult.getId();
        
        farmer.Person__c = personId;
        farmer.Education_Level__c = 'University';        
        farmer.Years_Of_Farming__c = 4;
        farmer.Farm_Size__c = 2.0;
        farmer.Farming_Reason__c = 'Consumption';
        farmer.Group_Name__c = 'Jitegemee'; 
        farmer.Group_Activity__c = 'Saving';
        farmer.Group_Size__c = 30;
        farmer.GPS_Location__c = gpsLocation;
        farmer.Registered_By__c = ciw.Id;
        // Set a rollback point
        Savepoint spFarmer = Database.setSavepoint();

        // Save the Farmer and get the id back
        errorMessage = '';
        Database.SaveResult farmerSaveResult = Database.insert(farmer);
        Id farmerId;
        if (!farmerSaveResult.isSuccess()) {
            returnValues.add('0');
            for (Database.Error error : farmerSaveResult.getErrors()) {

                // Build up the error message
                errorMessage = errorMessage + error.getMessage() + ' ';
            }
            returnValues.add(errorMessage);
            returnValues.add('Your submission of the Farmer Registration had an error in it please check the form. If you repeatedly get this message contact support');
            Database.rollback(spFarmer);
            return farmer;
        }
        farmerId = farmerSaveResult.getId();
        
        return farmer;
    }
    
    static testMethod void testBvatFarmerMapMarker() {

        BVAT_Farmer__c farmer = createTestBvatFarmer('Julius','Mbugua','Male','254723786908','1.53764749 33.44815689 1131.5 5.0');      
        BvatFarmerMapMarker marker = new BvatFarmerMapMarker(farmer); 
        String markerInfo = marker.getMarkerInfoContentString();
        System.assertEquals(markerInfo.length() > 0,true);
        System.assertEquals(markerInfo.containsAny('bg'),true);
    }
    
    static testMethod void testCiwSelectorController() {
        String result = CiwSelectorController.testController();
        System.assert(result.equals('Hi'));
    }
    
    static testMethod void testKenyanCountySelectorController() {

        String result = KenyanCountySelectorController.testController();
        System.assert(result.equals('Nairobi'));
    }
}