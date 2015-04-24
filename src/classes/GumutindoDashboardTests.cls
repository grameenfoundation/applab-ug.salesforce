@isTest
public with sharing class GumutindoDashboardTests {
    public GumutindoDashboardTests() {
	}
		
    static testMethod void testGumutindoDashboardController() {
        String quarter = MetricHelpers.getCurrentQuarterAsString(0);
        GumutindoDashboardController dashboard = new GumutindoDashboardController();
        dashboard.setCurrentQuarter(quarter);
        System.assertEquals(quarter, dashboard.getCurrentQuarter());
        System.assert(dashboard.getIsCurrentQuarter() == 'true');
        System.assertEquals(quarter, dashboard.getQuarter());
        //System.assertNotEquals(null, dashboard.getSections());
        
        dashboard.changeQuarter();
        dashboard.setIsUpdateable('false');// default was true
        System.assert(dashboard.getIsUpdateable() == 'false');
        
        System.assert(dashboard.getIsEditMode() == 'false');   // was not passed as get parameter hence stays false
        System.assert(dashboard.getQuarters().size() > 1);
        
        dashboard = new GumutindoDashboardController();
        dashboard.setQuarter('Jan - Mar ' + date.today().year());
        GumutindoHelpers.DataWrapper[] data = dashboard.getScaleData();
        //System.assert(data.size() == 1);
       // System.assert(data[0].quarter_actual_reached == 5);
        
        System.assert(dashboard.getImpactData().size() == 0);
        //System.assert(dashboard.getQualityData().size() == 1);
        //System.assert(dashboard.getSustainabilityData().size() == 1);
        
        //System.assert(dashboard.getViewScale() == false);
        //System.assert(dashboard.getViewQuality() == null);
        //System.assert(dashboard.getViewImpact() == null);
        //System.assert(dashboard.getViewSustainability() == null);
        
        dashboard.setQuarter(null);
        dashboard.getQuarters();
        System.assert(dashboard.getQuarter() != null);
        
    }
    //GCCE Internal Inspection Survey Post-processing
	static testMethod void testGCCEInternalInspectionSurveySubmission()
	{
        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, null, 'Female');
        database.saveResult saveResult = database.insert(ckw);
        String ckwId = saveResult.getId();
        
        Account acc = Utils.createTestOrganisation('test');
        acc.Name = GumutindoHelpers.ORG_NAME;
        insert acc;
        
        Survey__c survey = new Survey__c();
        survey.Account__c = acc.Id;
        survey.Post_Processing_Method__c = 'GUMUTINDO';
        survey.Survey_Name__c = 'GCCE Internal inspection';
        survey.Survey_Status__c = 'Published';
        survey.Start_Date__c = Date.valueOf(date.today().year() + '-01-01');
        survey.End_Date__c = Date.valueOf((date.today().year() + 4) + '-01-01');
        insert survey;
                
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = '123456789101112';
        testHandset.Serial_Number__c = '123456789101112';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert testHandset;
        
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'John';
        testPerson.Last_Name__c = 'Doe' ;
        testPerson.Gender__c = 'Male';
        testPerson.Handset__c = testHandset.Id;
        insert testPerson;
        
        District__c district = new District__c();
        district.Latitude__c = 2;
        district.Longitude__c = 3;
        district.Region__c = 'Western Uganda';
        district.Location_Id__c = 'test location';
        insert district;
        
        Subcounty__c subcounty = new Subcounty__c();
        subcounty.Display_Name__c = 'test Subcounty';
        subcounty.Latitude__c = 2;
        subcounty.Longitude__c = 3;
        subcounty.Location_Id__c = 'test location';
        subcounty.District__c = [SELECT Id FROM District__c Limit 1].Id;
        insert subcounty;
        
        Gumutindo_Primary_Society__c primarySociety = new Gumutindo_Primary_Society__c();
        primarySociety.Subcounty__c = [SELECT Id FROM Subcounty__c LIMIT 1].Id;
        primarySociety.Name_of_PS__c = 'Buginyanya';
        primarySociety.Date__c = Date.valueOf(date.today().year() + '-02-02');
        insert primarySociety;
                
        Gumutindo_Quarterly_Targets__c gumutindoQuarterlyTargets = new Gumutindo_Quarterly_Targets__c();
        gumutindoQuarterlyTargets.Label__c = 'test label 1';
        gumutindoQuarterlyTargets.Quarter_First_Date__c = system.now().date();
        gumutindoQuarterlyTargets.Target__c = 200; 
        
        Gumutindo_Quarterly_Targets__c gumutindoQuarterlyTargets2 = new Gumutindo_Quarterly_Targets__c();
        gumutindoQuarterlyTargets2.Label__c = 'test label 2';
        gumutindoQuarterlyTargets2.Quarter_First_Date__c = system.now().date();
        gumutindoQuarterlyTargets2.Target__c = 200;
        
        Gumutindo_Quarterly_Targets__c gumutindoQuarterlyTargets3 = new Gumutindo_Quarterly_Targets__c();
        gumutindoQuarterlyTargets3.Label__c = 'test label 3';
        gumutindoQuarterlyTargets3.Quarter_First_Date__c = system.now().date();
        gumutindoQuarterlyTargets3.Target__c = 200;
        
        ProcessSurveySubmission.SurveySubmission surveySubmissionF = new ProcessSurveySubmission.SurveySubmission();
        surveySubmissionF.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        surveySubmissionF.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        surveySubmissionF.imei = testHandset.IMEI__c;
        surveySubmissionF.resultHash = '1';
        surveySubmissionF.surveyId = [select Id, Name from Survey__c where Id = :survey.Id].Name;
        
        Map<String, Submission_Answer__c> answersF = new Map<String, Submission_Answer__c>();   
        
        answersF.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', 'test Farmer', null, null, null));
        
        List<String> returnValuesF = new List<String>();
        returnValuesF = GumutindoHelpers.processGCCEInternalInspectionSurvey(surveySubmissionF, answersF, testPerson);
        System.assert(returnValuesF.get(0).equals('0'));
        System.assert(returnValuesF.get(1).contains('FAILED'));  
           
        ProcessSurveySubmission.SurveySubmission surveySubmission = new ProcessSurveySubmission.SurveySubmission();
        surveySubmission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        surveySubmission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        surveySubmission.imei = testHandset.IMEI__c;
        surveySubmission.resultHash = '1';
        surveySubmission.surveyId = [select Id, Name from Survey__c where Id = :survey.Id].Name;
        
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', '1', null, null, null));
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', 'test Farmer', null, null, null));
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', 'test Village', null, null, null));
        answers.put('q5_0', Utils.createTestSubmissionAnswer(null, 'q5', '2', null, null, null));
        answers.put('q6_0', Utils.createTestSubmissionAnswer(null, 'q6', '4', null, null, null));
        answers.put('q7_0', Utils.createTestSubmissionAnswer(null, 'q7', '4', null, null, null));
        answers.put('q8_0', Utils.createTestSubmissionAnswer(null, 'q8', '1', null, null, null));
        answers.put('q22_0', Utils.createTestSubmissionAnswer(null, 'q22', '1', null, null, null));
        answers.put('q24_0', Utils.createTestSubmissionAnswer(null, 'q24', '2', null, null, null));
        answers.put('q25_0', Utils.createTestSubmissionAnswer(null, 'q25', '3', null, null, null));
        answers.put('q26_0', Utils.createTestSubmissionAnswer(null, 'q26', '1', null, null, null));
        answers.put('q27_0', Utils.createTestSubmissionAnswer(null, 'q27', '2', null, null, null));
        answers.put('q23_0', Utils.createTestSubmissionAnswer(null, 'q23', '1', null, null, null));
        answers.put('q9_0', Utils.createTestSubmissionAnswer(null, 'q9', '2', null, null, null));
        answers.put('q44_0', Utils.createTestSubmissionAnswer(null, 'q44', 'test Advice', null, null, null)); 
        
        String psName;
        if(answers.get('q1_0').Answer__c == '1') {
	        psName = 'Buginyanya';
	    }
	    else if(answers.get('q1_0').Answer__c == '2') {
	        psName = 'Kikuyu';
	    }
	    else if(answers.get('q1_0').Answer__c == '3') {
	        psName = 'Bunabudde';
	    }
	    else if(answers.get('q1_0').Answer__c == '4') {
	        psName = 'Nasufwa';
	    }
	    else if(answers.get('q1_0').Answer__c == '5') {
	        psName = 'Masira';
	    }
	    else if(answers.get('q1_0').Answer__c == '6') {
	        psName = 'Demukata';
	    }
	    else if(answers.get('q1_0').Answer__c == '7') {
	        psName = 'Busamaga';
	    }
	    else if(answers.get('q1_0').Answer__c == '8') {
	        psName = 'Nagudi Bwira';
	    }
	    else if(answers.get('q1_0').Answer__c == '9') {
	        psName = 'Lwambogo';
	    }
	    else if(answers.get('q1_0').Answer__c == '10') {
	        psName = 'Konokoyi';
	    }
	    else if(answers.get('q1_0').Answer__c == '11') {
	        psName = 'Bumayoga';
	    }
	    else if(answers.get('q1_0').Answer__c == '12') {
	        psName = 'Buweswa';
	    }
	    else if(answers.get('q1_0').Answer__c == '13') {
	        psName = 'Bumatanda';
	    }
	    else if(answers.get('q1_0').Answer__c == '14') {
	        psName = 'Sipi';
	    }
	    else if(answers.get('q1_0').Answer__c == '15') {
	        psName = 'Bukalasi';
	    }
	    else if(answers.get('q1_0').Answer__c == '16') {
	        psName = 'Buteteya';
	    }
	    else if(answers.get('q1_0').Answer__c == '17') {
	        psName = 'Buwambigwa';
	    }

        List<Gumutindo_Primary_Society__c> primarySocieties = [
	        SELECT
	            Id
	        FROM 
	            Gumutindo_Primary_Society__c
	        WHERE
	            Name_of_PS__c = :psName  
	        ];
	    
        String farmerName = answers.get('q2_0').Answer__c;
        System.assertEquals(farmerName, 'test Farmer');
	    String village = answers.get('q3_0').Answer__c;
	    System.assertEquals(village, 'test Village');
	    Integer numberOftrees = answers.get('q5_0').Answer__c !=null ? Integer.valueOf(answers.get('q5_0').Answer__c) : 0;
	    System.assertEquals(numberOftrees, 2);
	    Integer yieldEstimate = answers.get('q6_0').Answer__c !=null ? Integer.valueOf(answers.get('q6_0').Answer__c) : 0;
	    System.assertEquals(yieldEstimate, 4);
        Integer numberOfCoffeePlots = answers.get('q7_0').Answer__c !=null ? Integer.valueOf(answers.get('q7_0').Answer__c) : 0;
        System.assertEquals(numberOfCoffeePlots, 4);
        String contract = answers.get('q8_0').Answer__c == '1' ? 'Yes' : 'No';
        System.assertEquals(contract, 'Yes');    
        
        String weeding, pruning, shadeTrees, erosionControl, coverCrops;
        //Weeding
        if(answers.get('q22_0').Answer__c == '1'){
            weeding = 'Good';
        }
        else if (answers.get('q22_0').Answer__c == '2'){
            weeding = 'Fair';
        }
        else {
            weeding = 'Poor';
        }
        //Pruning                
        if(answers.get('q24_0').Answer__c == '1') {
            pruning = 'Good';
        }
        else if(answers.get('q24_0').Answer__c == '2') {
            pruning = 'Fair';
        }
        else {
            pruning = 'Poor';
        }  
        //Shade Trees              
        if(answers.get('q25_0').Answer__c == '1'){
            shadeTrees = 'Good';
        }
        else if(answers.get('q25_0').Answer__c == '2') {
            shadeTrees = 'Fair';
        }
        else {
            shadeTrees = 'Poor';
        }
        //Erosion control        
        if(answers.get('q26_0').Answer__c == '1') {
            erosionControl = 'Good';
        }
        else if(answers.get('q26_0').Answer__c == '2'){
            erosionControl = 'Fair';
        }
        else {
            erosionControl = 'Poor';
        }
        //Cover crops
        if(answers.get('q27_0').Answer__c == '1') {
            coverCrops = 'Good';
        }
        else if(answers.get('q27_0').Answer__c == '2') {
            coverCrops = 'Fair';
        }
        else {
            coverCrops = 'Poor';
        }
        System.assertEquals(weeding, 'Good');
        System.assertEquals(pruning, 'Fair');
        System.assertEquals(shadeTrees, 'Poor');
        System.assertEquals(erosionControl, 'Good');
        System.assertEquals(coverCrops, 'Fair');
        String manureApplied = answers.get('q23_0').Answer__c == '1' ? 'Yes' : 'No';
        System.assertEquals(manureApplied, 'Yes');
        String comment = answers.get('q9_0').Answer__c == '1' ? 'Under conversion' : 'Certified fair trade organic';
        System.assertEquals(comment, 'Certified fair trade organic');
        String advice = answers.get('q44_0').Answer__c;
        System.assertEquals(advice, 'test Advice');
        
        Gumutindo_Farmer__c gFarmer = new Gumutindo_Farmer__c();
        gFarmer.Gumutindo_Primary_Society__c  = primarySocieties[0].Id;
        gFarmer.Name_of_Respondent__c = farmerName;
        gFarmer.Village__c = village;
        gFarmer.Number_of_Trees__c = numberOftrees;
        gFarmer.Yield_Estimates__c = yieldEstimate;
        gFarmer.Number_of_Coffee_Plots__c = numberOfCoffeePlots;
        gFarmer.Have_Contract_with_Gumutindo__c = contract;
        gFarmer.Weeding__c = weeding;
        gFarmer.Manure_Applied__c = manureApplied;
        gFarmer.Pruning__c = pruning;
        gFarmer.Shade_Trees__c = shadeTrees;
        gFarmer.Erosion_Control__c = erosionControl;
        gFarmer.Cover_crops__c = coverCrops;
        gFarmer.Comment_on_contract__c = comment;
        gFarmer.New_advice_given__c = advice;
        gFarmer.Date__c = surveySubmission.handsetSubmitTime != null ? 
                        ProcessSurveySubmission.getTimestamp(surveySubmission.handsetSubmitTime).date() : Date.today();
        insert gFarmer;
        
        List<String> returnValues = new List<String>();
        returnValues = GumutindoHelpers.processGCCEInternalInspectionSurvey(surveySubmission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('processed'));    
        
        List<String> returnValues1 = new List<String>();
        returnValues1 = GumutindoHelpers.processActivitySurvey(surveySubmission, answers, testPerson);
        System.assert(returnValues1.get(0).equals('0'));
        System.assert(returnValues1.get(1).contains('irrelevant'));   
        
	}
    //GCCE PS Survey Post-processing
    static testMethod void testGumutindoGCCEPSSurveySubmission()
    {
        Account acc = Utils.createTestOrganisation('test');
        acc.Name = GumutindoHelpers.ORG_NAME;
        insert acc;
        
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = '123456789101112';
        testHandset.Serial_Number__c = '123456789101112';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert testHandset;
        
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'John';
        testPerson.Last_Name__c = 'Doe' ;
        testPerson.Gender__c = 'Male';
        testPerson.Handset__c = testHandset.Id;
        insert testPerson;
            
        Survey__c survey = new Survey__c();
        survey.Account__c = acc.Id;
        survey.Post_Processing_Method__c = 'GUMUTINDO';
        survey.Survey_Name__c = 'GCCE PS';
        survey.Survey_Status__c = 'Published';
        survey.Start_Date__c = Date.valueOf(date.today().year() + '-01-01');
        survey.End_Date__c = Date.valueOf((date.today().year() + 4) + '-01-01');
        insert survey;
        
        District__c district = new District__c();
        district.Latitude__c = 2;
        district.Longitude__c = 3;
        district.Region__c = 'Western Uganda';
        district.Location_Id__c = 'test location';
        insert district;
        
        Subcounty__c subcounty = new Subcounty__c();
        subcounty.Display_Name__c = 'test Subcounty';
        subcounty.Latitude__c = 2;
        subcounty.Longitude__c = 3;
        subcounty.Location_Id__c = 'test location';
        subcounty.District__c = [SELECT Id FROM District__c Limit 1].Id;
        insert subcounty;
        
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = testHandset.IMEI__c;
        submission.resultHash = '1';
        submission.surveyId = [select Id, Name from Survey__c where Id = :survey.Id].Name;
        
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>(); 
          
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', '1', null, null, null));
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', '1', null, null, null));
        answers.put('q4_0', Utils.createTestSubmissionAnswer(null, 'q4', '2', null, null, null));
        answers.put('q5_0', Utils.createTestSubmissionAnswer(null, 'q5', '1', null, null, null));
        
        String establishedPolicy = answers.get('q3_0').Answer__c == '1' ? 'Yes' : 'No';
        System.assertEquals(establishedPolicy, 'Yes');
	    String procureInputs = answers.get('q4_0').Answer__c == '1' ? 'Yes' : 'No';
	    System.assertEquals(procureInputs, 'No');
	    String payForInputs = answers.get('q5_0').Answer__c == '1' ? 'Yes' : 'No';
	    System.assertEquals(payForInputs, 'Yes');
	    
	    Gumutindo_Primary_Society__c gPrimarySocieity = new Gumutindo_Primary_Society__c();
        gPrimarySocieity.Adhere_to_Established_Policies__c = establishedPolicy;
        gPrimarySocieity.Farmers_Procure_Farm_Inputs_Collectively__c = procureInputs;
        gPrimarySocieity.Pay_for_Inputs_Upon_Delivery__c = payForInputs;
        gPrimarySocieity.Subcounty__c = [SELECT Id FROM Subcounty__c LIMIT 1].Id;
        String psName;
	    if(answers.get('q1_0').Answer__c == '1') {
	        psName = 'Buginyanya';
	    }
	    else if(answers.get('q1_0').Answer__c == '2') {
	        psName = 'Kikuyu';
	    }
	    else if(answers.get('q1_0').Answer__c == '3') {
	        psName = 'Bunabudde';
	    }
	    else if(answers.get('q1_0').Answer__c == '4') {
	        psName = 'Nasufwa';
	    }
	    else if(answers.get('q1_0').Answer__c == '5') {
	        psName = 'Masira';
	    }
	    else if(answers.get('q1_0').Answer__c == '6') {
	        psName = 'Demukata';
	    }
	    else if(answers.get('q1_0').Answer__c == '7') {
	        psName = 'Busamaga';
	    }
	    else if(answers.get('q1_0').Answer__c == '8') {
	        psName = 'Nagudi Bwira';
	    }
	    else if(answers.get('q1_0').Answer__c == '9') {
	        psName = 'Lwambogo';
	    }
	    else if(answers.get('q1_0').Answer__c == '10') {
	        psName = 'Konokoyi';
	    }
	    else if(answers.get('q1_0').Answer__c == '11') {
	        psName = 'Bumayoga';
	    }
	    else if(answers.get('q1_0').Answer__c == '12') {
	        psName = 'Buweswa';
	    }
	    else if(answers.get('q1_0').Answer__c == '13') {
	        psName = 'Bumatanda';
	    }
	    else if(answers.get('q1_0').Answer__c == '14') {
	        psName = 'Sipi';
	    }
	    else if(answers.get('q1_0').Answer__c == '15') {
	         psName = 'Bukalasi';
	    }
	    else if(answers.get('q1_0').Answer__c == '16') {
	        psName = 'Buteteya';
	    }
	    else if(answers.get('q1_0').Answer__c == '17') {
	        psName = 'Buwambigwa';
	    }
        gPrimarySocieity.Name_of_PS__c = psName;
        gPrimarySocieity.Date__c = submission.handsetSubmitTime != null ? 
            ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime).date() : Date.today();
        insert gPrimarySocieity;
        
        List<String> returnValues = new List<String>();
        returnValues = GumutindoHelpers.processGCCEPSSurvey(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('processed'));
        
        List<String> returnValues1 = new List<String>();
        returnValues1 = GumutindoHelpers.processActivitySurvey(submission, answers, testPerson);
        System.assert(returnValues1.get(0).equals('0'));
        System.assert(returnValues1.get(1).contains('irrelevant'));

    }
    //Impacts 2015 Survey Post-processing
    static testMethod void testGumutindoImpacts2015SurveySubmission()
    {
        
        Account acc = Utils.createTestOrganisation('test');
        acc.Name = GumutindoHelpers.ORG_NAME;
        insert acc;
        
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = '123456789101112';
        testHandset.Serial_Number__c = '123456789101112';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert testHandset;
        
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'John';
        testPerson.Last_Name__c = 'Doe' ;
        testPerson.Gender__c = 'Male';
        testPerson.Handset__c = testHandset.Id;
        insert testPerson;
            
        Survey__c survey = new Survey__c();
        survey.Account__c = acc.Id;
        survey.Post_Processing_Method__c = 'GUMUTINDO';
        survey.Survey_Name__c = 'Impacts 2015';
        survey.Survey_Status__c = 'Published';
        survey.Start_Date__c = Date.valueOf(date.today().year() + '-01-01');
        survey.End_Date__c = Date.valueOf((date.today().year() + 4) + '-01-01');
        insert survey;
        
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = testHandset.IMEI__c;
        submission.resultHash = '1';
        submission.surveyId = [select Id, Name from Survey__c where Id = :survey.Id].Name;
        
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>(); 
          
        answers.put('q28_0', Utils.createTestSubmissionAnswer(null, 'q28', '1', null, null, null));
        answers.put('q27_0', Utils.createTestSubmissionAnswer(null, 'q27', '2', null, null, null));
        answers.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12', '1', null, null, null));
        answers.put('q26_0', Utils.createTestSubmissionAnswer(null, 'q26', '2', null, null, null));
        answers.put('q30_0', Utils.createTestSubmissionAnswer(null, 'q30', '1 2 3', null, null, null));
        answers.put('q8_0', Utils.createTestSubmissionAnswer(null, 'q8', '3 2 1', null, null, null));
        answers.put('q16_0', Utils.createTestSubmissionAnswer(null, 'q16', '2', null, null, null));
        answers.put('q15_0', Utils.createTestSubmissionAnswer(null, 'q15', '2', null, null, null));
        answers.put('q22_0', Utils.createTestSubmissionAnswer(null, 'q22', '2 1 3', null, null, null));
        answers.put('q21_0', Utils.createTestSubmissionAnswer(null, 'q21', '3 1 2', null, null, null));
        answers.put('q23_0', Utils.createTestSubmissionAnswer(null, 'q23', '2 1', null, null, null));
        answers.put('q24_0', Utils.createTestSubmissionAnswer(null, 'q24', '1 2', null, null, null));
        answers.put('q26_0', Utils.createTestSubmissionAnswer(null, 'q26', '2', null, null, null));
        answers.put('q27_0', Utils.createTestSubmissionAnswer(null, 'q27', '2', null, null, null));
        answers.put('q25_0', Utils.createTestSubmissionAnswer(null, 'q25', '2', null, null, null));
        answers.put('q9_0', Utils.createTestSubmissionAnswer(null, 'q9', '3', null, null, null));
        answers.put('q16_0', Utils.createTestSubmissionAnswer(null, 'q16', '1', null, null, null));
        answers.put('q27_0', Utils.createTestSubmissionAnswer(null, 'q16', '2', null, null, null));
        
        String purchaseThruGcce = answers.get('q28_0').Answer__c == '1' ? 'Yes' : 'No';
	    String purchaseSeedlings = answers.get('q27_0').Answer__c == '1' ? 'Yes' : 'No';
	    String hiQuality = answers.get('q12_0').Answer__c == '1' ? 'Yes' : 'No';
        String loanThruPs = answers.get('q26_0').Answer__c == '1' ? 'Yes' : 'No';
        String financialService = answers.get('q30_0').Answer__c;                
        String satisfaction = answers.get('q8_0').Answer__c;                
        String electronicTransaction = answers.get('q16_0').Answer__c == '1' ? 'Yes' : 'No';                
        String electronicPayment = answers.get('q15_0').Answer__c == '1' ? 'Yes' : 'No';                
        String manageWhether = answers.get('q22_0').Answer__c;
        String citeCause = answers.get('q21_0').Answer__c;
        String soilConservation = answers.get('q23_0').Answer__c;
        String agroPractice = answers.get('q24_0').Answer__c;
        String adaptedVariety = answers.get('q27_0').Answer__c == '1' ? 'Yes' : 'No';
        String energySaving = answers.get('q25_0').Answer__c == '1' ? 'Yes' : 'No';
        String farmInputs = answers.get('q16_0').Answer__c == '1' ? 'Yes' : 'No';
        String organicSeedlings = answers.get('q27_0').Answer__c == '1' ? 'Yes' : 'No';
        
        Integer marks;
        if(answers.get('q9_0').Answer__c == '1'){
            marks = 1;
        }
        else if(answers.get('q9_0').Answer__c == '2'){
            marks = 2;
        }
        else if(answers.get('q9_0').Answer__c == '3'){
            marks = 3;
        }
        else if(answers.get('q9_0').Answer__c == '4'){
            marks = 4;
        }
        else if(answers.get('q9_0').Answer__c == '5'){
            marks = 5;
        }
                
        System.assertEquals(GumutindoHelpers.translateFinancialServices(financialService), 'Bank;Mobile Money;SACCO;');
        System.assertEquals(GumutindoHelpers.translateServicesReceived(satisfaction), 'Provision of weather information;' +
        'Provision of market information;Extension services on coffee farming;');
        System.assertEquals(GumutindoHelpers.translateChange(manageWhether), 'Cover crops;Mulching;Tied ridges;');
        System.assertEquals(GumutindoHelpers.translateReasons(citeCause), 'Burning of trees, fuel, etc;' +
            'Cutting down of trees;Excessive use of fertilizer;');
        System.assertEquals(GumutindoHelpers.translateMethods(soilConservation), 'Mulching;Strip cropping;');
        System.assertEquals(GumutindoHelpers.translatePractices(agroPractice), 'Planting trees within the homestead;Boundary planting/fence;');
                
        Gumutindo_Impacts__c gImpact = new Gumutindo_Impacts__c();
        gImpact.Purchased_Organic_fertilizer_through_GCC__c = purchaseThruGcce;
        gImpact.Ever_purchased_organic_seedlings_at_PS__c = purchaseSeedlings;
        gImpact.Sold_all_your_coffee_to_the_PS__c = hiQuality;
        gImpact.Ever_acquired_an_Agro_input_loan_through__c = loanThruPs;
                
        gImpact.Financial_service_for_the_business__c = GumutindoHelpers.translateFinancialServices(financialService);
        gImpact.Services_received_from_PS__c = GumutindoHelpers.translateServicesReceived(satisfaction);
        gImpact.Practices_that_Address_Climate_Change__c = GumutindoHelpers.translateChange(manageWhether);
        gImpact.Reasons_for_Climate_Change__c = GumutindoHelpers.translateReasons(citeCause);
        gImpact.Methods_of_Soil_and_Water_Conservation_U__c = GumutindoHelpers.translateMethods(soilConservation);
        gImpact.Agro_forestry_Practices_Used__c = GumutindoHelpers.translatePractices(agroPractice);  
        
        gImpact.Ps_Mark__c = marks;
        gImpact.Any_Farm_inputs_from_the_PS__c = farmInputs;
        gImpact.Received_Organic_Seedlings_at_PS__c = organicSeedlings;      
                                
        gImpact.Purchase_Inputs_thru_Elec_Transactions__c = electronicTransaction;
        gImpact.Sold_all_your_coffee_to_the_PS__c = electronicPayment;
        gImpact.Ever_purchased_organic_seedlings_at_PS__c = adaptedVariety;
        gImpact.Using_Energy_Saving_Cooking_Stove__c = energySaving;
        gImpact.Date__c = submission.handsetSubmitTime != null ? 
            ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime).date() : Date.today();
               
        insert gImpact;
        
        List<String> returnValues = new List<String>();
        returnValues = GumutindoHelpers.processImpacts2015Survey(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('processed'));
        
        List<String> returnValues1 = new List<String>();
        returnValues1 = GumutindoHelpers.processActivitySurvey(submission, answers, testPerson);
        System.assert(returnValues1.get(0).equals('0'));
        System.assert(returnValues1.get(1).contains('irrelevant'));

    }
    //Activity Survey Post-processing
    static testMethod void testGumutindoActivitySurveySubmission()
    {    
        Account acc = Utils.createTestOrganisation('test');
        acc.Name = GumutindoHelpers.ORG_NAME;
        insert acc;
        
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = '123456789101112';
        testHandset.Serial_Number__c = '123456789101112';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert testHandset;
        
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'John';
        testPerson.Last_Name__c = 'Doe' ;
        testPerson.Gender__c = 'Male';
        testPerson.Handset__c = testHandset.Id;
        insert testPerson;
            
        Survey__c survey = new Survey__c();
        survey.Account__c = acc.Id;
        survey.Post_Processing_Method__c = 'GUMUTINDO';
        survey.Survey_Name__c = 'Activity Survey';
        survey.Survey_Status__c = 'Published';
        survey.Start_Date__c = Date.valueOf(date.today().year() + '-01-01');
        survey.End_Date__c = Date.valueOf((date.today().year() + 4) + '-01-01');
        insert survey;
        
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = testHandset.IMEI__c;
        submission.resultHash = '1';
        submission.surveyId = [select Id, Name from Survey__c where Id = :survey.Id].Name;
        
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>(); 
        answers.put('q13_0', Utils.createTestSubmissionAnswer(null, 'q13_0', '2', null, null, null));
          
        Integer total = answers.get('q13_0').Answer__c !=null ? Integer.valueOf(answers.get('q13_0').Answer__c) : 0;
         
        Gumutindo_Vsla__c gVlsa = new Gumutindo_Vsla__c();
        gVlsa.Total_Number_of_VSLA_Members__c = total;
        gVlsa.Date__c = submission.handsetSubmitTime != null ? 
            ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime).date() : Date.today();
        insert gVlsa;
        
        List<String> returnValues = new List<String>();
        returnValues = GumutindoHelpers.processActivitySurvey(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('processed'));
        
        List<String> returnValues1 = new List<String>();
        returnValues1 = GumutindoHelpers.processGCCEInternalInspectionSurvey(submission, answers, testPerson);
        System.assert(returnValues1.get(0).equals('0'));
        System.assert(returnValues1.get(1).contains('irrelevant'));
                        

    }

    static testMethod void testGumutindoHelpers()
    {
        District__c district = new District__c();
        district.Latitude__c = 2;
        district.Longitude__c = 3;
        district.Region__c = 'Western Uganda';
        district.Location_Id__c = 'test location';
        insert district;
        
        Subcounty__c subcounty = new Subcounty__c();
        subcounty.Display_Name__c = 'test Subcounty';
        subcounty.Latitude__c = 2;
        subcounty.Longitude__c = 3;
        subcounty.Location_Id__c = 'test location';
        subcounty.District__c = [SELECT Id FROM District__c Limit 1].Id;
        insert subcounty;
        
        Gumutindo_Primary_Society__c primarySociety = new Gumutindo_Primary_Society__c();
        primarySociety.Subcounty__c = [SELECT Id FROM Subcounty__c LIMIT 1].Id;
        primarySociety.Name_of_PS__c = 'Buginyanya';
        primarySociety.Date__c = Date.valueOf(date.today().year() + '-02-02');
        insert primarySociety;
        
        List<Gumutindo_Primary_Society__c> primarySocieties = [
	        SELECT
	            Id
	        FROM 
	            Gumutindo_Primary_Society__c
	        LIMIT 1  
	        ];
        
        Gumutindo_Farmer__c gFarmer = new Gumutindo_Farmer__c();
        gFarmer.Gumutindo_Primary_Society__c  = primarySocieties[0].Id;
        gFarmer.Comment_on_contract__c = 'test coment';
        gFarmer.Cover_crops__c = 'test cover crop';
        gFarmer.Date__c = system.now().date();
        gFarmer.Erosion_Control__c = 'Yes';
        gFarmer.GPS_Location__Longitude__s = 3;
        gFarmer.GPS_Location__Latitude__s = 2;
        gFarmer.Have_Contract_with_Gumutindo__c = 'Yes';
        gFarmer.Manure_Applied__c = 'Yes';
        gFarmer.Name_of_Respondent__c = 'Henry T';
        gFarmer.Number_of_Coffee_Plots__c = 20;
        gFarmer.Number_of_Trees__c = 20;
        gFarmer.Pruning__c = 'Yes';
        gFarmer.Shade_Trees__c = 'Yes';
        gFarmer.Weeding__c = 'Yes';
        gFarmer.Yield_Estimates__c = 20;
        gFarmer.Village__c = 'test Village';
        insert gFarmer;
        
        Gumutindo_Targets__c gTarget = new Gumutindo_Targets__c();
        gTarget.Label__c = GumutindoHelpers.FARMERS_REGISTERED;
        gTarget.Target__c = 50;
        gTarget.Metric_Name__c = GumutindoHelpers.FARMERS_REGISTERED;
        gTarget.Section__c = 'Scale';
        insert gTarget;
        
        Gumutindo_Quarterly_Targets__c gQuarterT = new Gumutindo_Quarterly_Targets__c();
        gQuarterT.Label__c = GumutindoHelpers.FARMERS_REGISTERED;
        gQuarterT.Quarter_First_Date__c = system.now().date();
        gQuarterT.Target__c = 20;
        gQuarterT.Metric_Name__c = GumutindoHelpers.FARMERS_REGISTERED;
        insert gQuarterT;
        
        Gumutindo_Targets__c gTarget1 = new Gumutindo_Targets__c();
        gTarget1.Label__c = GumutindoHelpers.FARMERS_WHO_USE_ATLEAST_ONE_KIND_OF_FINANCIAL_SERVICES;
        gTarget1.Target__c = 50;
        gTarget1.Metric_Name__c = GumutindoHelpers.FARMERS_WHO_USE_ATLEAST_ONE_KIND_OF_FINANCIAL_SERVICES;
        gTarget1.Section__c = 'Impact';
        insert gTarget1;
        
        Gumutindo_Quarterly_Targets__c gQuarterT1 = new Gumutindo_Quarterly_Targets__c();
        gQuarterT1.Label__c = GumutindoHelpers.FARMERS_WHO_USE_ATLEAST_ONE_KIND_OF_FINANCIAL_SERVICES;
        gQuarterT1.Quarter_First_Date__c = system.now().date();
        gQuarterT1.Target__c = 20;
        gQuarterT1.Metric_Name__c = GumutindoHelpers.FARMERS_WHO_USE_ATLEAST_ONE_KIND_OF_FINANCIAL_SERVICES;
        insert gQuarterT1;
        
        District__c testDistrict = new District__c();
        testDistrict.Name = 'TestMasaka';
        testDistrict.Region__c = 'Central';
        insert testDistrict;

        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'TestLukaya-TC';
        testSubcounty.District__c = testDistrict.Id;
        insert testSubcounty;      

        Gumutindo_Primary_Society__c testSociety = new Gumutindo_Primary_Society__c();
        testSociety.Name = 'Test Society';
        testSociety.Latitude__c = 0.4343443;
        testSociety.Longitude__c = 0.444444;
        testSociety.Subcounty__c = testSubcounty.Id;
        testSociety.Adhere_to_Established_Policies__c = 'Yes';
        testSociety.Farmers_Procure_Farm_Inputs_Collectively__c = 'Yes';
        testSociety.Pay_for_Inputs_Upon_Delivery__c = 'Yes';
        //insert(testSociety);

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'John';
        testPerson.Last_Name__c = 'Lu' ;
        testPerson.Gender__c = 'Male';
        testPerson.District__c = testDistrict.Id;
        //testPerson.Handset__c = testHandset.Id;
        testPerson.Type__c = 'CKW';
        insert testPerson;

        CKW__c testCkw = new CKW__c();
        testCkw.Person__c = testPerson.Id;
        insert(testCkw);

        Person__c testFOPerson = new Person__c();
        testFOPerson.First_Name__c = 'John FO';
        testFOPerson.Last_Name__c = 'Lu FO' ;
        testFOPerson.Gender__c = 'Male';
        testFOPerson.District__c = testDistrict.Id;
        //testPerson.Handset__c = testHandset.Id;
        testFOPerson.Type__c = 'CKW';
        insert testFOPerson;

        //Create Gumutindo FO
        Gumutindo_Field_Officer__c gumutindoFO = new Gumutindo_Field_Officer__c();
        gumutindoFO.Person__c = testFOPerson.Id;
        insert(gumutindoFO);

        Gumutindo_CKW__c gumutindoCkw = new Gumutindo_CKW__c();
        gumutindoCkw.Gumutindo_Field_Officer__c = gumutindoFO.Id;
        gumutindoCkw.Person__c = testPerson.Id;
        //gumutindoCkw.Gumutindo_Primary_Society__c = testSociety.Id;
        //insert(gumutindoCkw);

        Group__c testGroup = new Group__c();
        testGroup.Name = 'GCCE';
        insert(testGroup);

        Person_Group_Association__c testPersonGroupAssociation = new Person_Group_Association__c();
        testPersonGroupAssociation.Group__c = testGroup.Id;
        testPersonGroupAssociation.Person__c = testPerson.Id;
        insert(testPersonGroupAssociation);        

        PageReference resultPage =  new PageReference('/a00/e');
        resultPage.getParameters().put('district', String.valueOf(testDistrict.Id));
        resultPage.getParameters().put('subcounty', String.valueOf(testSubcounty.Id));
        resultPage.getParameters().put('cbt', String.valueOf(testPerson.Id));
        resultPage.getParameters().put('sfdc.tabName', 'a00');

        Account testOrg = new Account();
        testOrg.Name = 'GCCE';
        testOrg.BillingState = 'CA';
        insert testOrg;

        Organisation_District_Association__c orgAssocTest = new Organisation_District_Association__c();
        orgAssocTest.District__c = testDistrict.Id;
         orgAssocTest.Organisation__c = testOrg.Id;
        insert(orgAssocTest);

        GumutindoDashboardController controller = new GumutindoDashboardController();
        controller.setOrgName(testOrg.Name);
        controller.setUp(resultPage);

        Test.startTest();
        
        GumutindoDashboardController cont = new GumutindoDashboardController();
        String quarter = MetricHelpers.getCurrentQuarterAsString(0);
        
        String metricName = GumutindoHelpers.FARMERS_REGISTERED;
        //Check this method
        List<Double> results = GumutindoHelpers.getDataInQuarter(quarter, metricName);
        
        GumutindoHelpers.Wrapper wrapper = GumutindoHelpers.getData(quarter);
        Date quarterFirstDay = MetricHelpers.getQuarterFirstDay(quarter);
        Date quarterLastDay = MetricHelpers.getQuarterLastDay(quarter);
        Map<String, GumutindoHelpers.DataWrapper> areaMap = new Map<String, GumutindoHelpers.DataWrapper>();
        Map<String, Map<String, GumutindoHelpers.DataWrapper>> metricWrappers = new Map<String, Map<String, 
            GumutindoHelpers.DataWrapper>>();
        Map<String, List<String>> metricWrapperOrder = new Map<String, List<String>>();
        
        GumutindoHelpers.DataWrapper metricDataWrapper = new GumutindoHelpers.DataWrapper();
        metricDataWrapper.quarter_target = GumutindoHelpers.getQuarterlyTargets(GumutindoHelpers.FARMERS_REGISTERED) == null ? 0 :
            (Integer)GumutindoHelpers.getQuarterlyTargets(GumutindoHelpers.FARMERS_REGISTERED).Target__c;
        System.assertEquals(metricDataWrapper.quarter_target, 20);
        
        metricDataWrapper.name = GumutindoHelpers.FARMERS_REGISTERED;
        metricDataWrapper.quarter_actual_reached = GumutindoHelpers.getDataInQuarter(quarter, GumutindoHelpers.FARMERS_REGISTERED)[0];
        System.assertEquals(metricDataWrapper.quarter_actual_reached, 1);
        
        metricDataWrapper.project_target = GumutindoHelpers.getTargets(GumutindoHelpers.FARMERS_REGISTERED) == null ? 0 : (Integer)GumutindoHelpers.getTargets(GumutindoHelpers.FARMERS_REGISTERED).Target__c;
        System.assertEquals(metricDataWrapper.project_target, 50);
        
        metricDataWrapper.cummulative_actual_reached = GumutindoHelpers.getPreviousDataSum(quarterLastDay, GumutindoHelpers.FARMERS_REGISTERED)[0];
        
        metricDataWrapper.percent_cummulative_actual_reached = metricDataWrapper.project_target != 0 ?
            (metricDataWrapper.cummulative_actual_reached / metricDataWrapper.project_target) * 100 : 0.0;
        System.assertEquals(metricDataWrapper.percent_cummulative_actual_reached, 2);
        
        Decimal percentQuarter = (metricDataWrapper.quarter_actual_reached / metricDataWrapper.quarter_target) * 100;
            
        metricDataWrapper.percent_quarter_actual_reached = percentQuarter;
        System.assertEquals(metricDataWrapper.percent_quarter_actual_reached, 5.0);
        
        System.assertNotEquals(metricDataWrapper, null);
        
        List<String> metricOrder = new List<String>{GumutindoHelpers.FARMERS_REGISTERED};

        String metricKey = metricName;
        
        String areaName = 'Scale';
        
        areaMap.put(metricKey, metricDataWrapper);
        System.assertNotEquals(areaMap, null);
        
        metricWrappers.put(areaName, areaMap);
        
        metricOrder.add(metricKey);
        
        metricWrapperOrder.put(areaName, metricOrder);

        System.assertNotEquals(GumutindoHelpers.getData(quarter), null);

        System.assert(GumutindoHelpers.getGumutindoPrimarySocietyMarkers().size() == 1);
 
        System.assert(GumutindoHelpers.getCKWMapMarkers().size() == 2); //one for ckw and one for fo
        System.assert(controller.district != null);
        System.assert(controller.subcounty != null);
        System.assert(controller.dummyObject != null);
        System.assert(controller.getDistrictMapSection() != null);

        System.assert(controller.loadGumutindoPrimarySocieties().size() == 1);
        
        System.assert(controller.getSubcountiesList().size() == 2);
        
        //System.assert(controller.changeFilters() != null);
        
        System.assert(controller.getMaps().size() ==1);
        System.assert('false'.equals(controller.getIsEditMode()));
        System.assert('true'.equals(controller.getIsUpdateable()));
        
        System.assert(GumutindoHelpers.loadCkw(testPerson) != null);
        
        GumutindoHelpers.GumutindoDistrictCoordinatesProvider districtProvider = new GumutindoHelpers.GumutindoDistrictCoordinatesProvider();
        System.assert(districtProvider.loadMapMarkers(null).size() == 1);
        
        GumutindoHelpers.GumutindoPrimarySocietyCoordinatesProvider societyMarkerProvider = new GumutindoHelpers.GumutindoPrimarySocietyCoordinatesProvider();
        System.assert(societyMarkerProvider.loadMapMarkers(null).size() == 1);
         
        GumutindoHelpers.GumutindoCkwCoordinatesProvider ckwMarkerProvider = new GumutindoHelpers.GumutindoCkwCoordinatesProvider();
        System.assert(ckwMarkerProvider.loadMapMarkers(null).size() == 2);
        
        GumutindoHelpers.GumutindoDistrictMarker gDMarker = new GumutindoHelpers.GumutindoDistrictMarker(testDistrict);
        gDMarker.setParentRegistered('pr');
        System.assert('pr'.equals(gDMarker.getParentRegistered()));
        System.assert(gDMarker.getMarkerInfoContentString() != null);
        
        GumutindoHelpers.GumutindoCkwMarker gCMarker = new GumutindoHelpers.GumutindoCkwMarker(testCkw);
        gCMarker.setParentRegistered('pr');
        gCMarker.generateMarkerName('Gender');
        
        /*gCMarker.ckw.Person__r.Parish__c = 'Test Parish';
        gCMarker.ckw.Person__r.Village__c = 'Test Village';
        gCMarker.ckw.Person__r.Subcounty__r.Display_Name__c = 'Test Sub Display';
        System.assert('pr'.equals(gCMarker.getParentRegistered()));
        System.assert(gCMarker.getMarkerInfoContentString() != null);
        System.assert(gCMarker.getLocation() != null);

        GumutindoHelpers.GumutindoFieldOfficerMarker gFOMarker = new GumutindoHelpers.GumutindoFieldOfficerMarker(testFOPerson);
        gFOMarker.setParentRegistered('pr');
        System.assert('pr'.equals(gFOMarker.getParentRegistered()));
        System.assert(gFOMarker.getMarkerInfoContentString() != null);
        
        GumutindoHelpers.GumutindoPrimarySocietyMarker gPSMarker = new GumutindoHelpers.GumutindoPrimarySocietyMarker(testSociety);
        gPSMarker.setParentRegistered('pr');
        System.assert('pr'.equals(gPSMarker.getParentRegistered()));
        System.assert(gPSMarker.getMarkerInfoContentString() != null);*/
        //System.assert(GumutindoHelpers.gumu().size() == 1);
        Test.stopTest();

    }
}