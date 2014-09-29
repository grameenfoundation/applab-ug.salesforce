@isTest
public with sharing class GumutindoDashboardTests {
	public GumutindoDashboardTests() {
         createMetrics();
	}
		
    static testMethod void testGumutindoDashboardController() {

        GumutindoDashboardController dashboard = new GumutindoDashboardController();
        MetricHelpers.getQuarterStartMonth(3);
        MetricHelpers.getQuarterEndMonth(3);
        //System.assertNotEquals(null, dashboard.getSections());
        //createMetrics();

        
        
    }    
	
    public static void createMetrics() {
     //GumutindoHelpers helpers = new GumutindoHelpers();    
      //helpers.getAllMetricDatas(); 
      //GumutindoHelpers.getMetricData(GumutindoHelpers.TARGET_FARMERS_REACHED_IN_YEAR_1);  
      //GumutindoHelpers.getMetricData(GumutindoHelpers.FARMER_GROUPS_WHO_RECEIVE_ADVISORY_SERVICES_FROM_CKW_NETWORK);

    }

	static testMethod void testGumutindoFarmEntranceSurveySubmission()
	{
         
        
        createMetrics();

        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, null, 'Female');
        database.saveResult saveResult = database.insert(ckw);
        String ckwId = saveResult.getId();
       


        Survey__c survey = new Survey__c();
        survey.Survey_Name__c = 'gcce test suvey';
        survey.Post_Processing_Method__c = 'GUMUTINDO_GCCE_FARM_ENTRANCE';
        survey.Save_To_Salesforce__c = false;
        survey.Survey_Status__c = 'Active';
        survey.Start_Date__c = date.today().addMonths(-1);
        saveResult = database.insert(survey);
        String surveyId = saveResult.getId();
        
        Survey__c survey2 = [Select Id, Name from Survey__c where Id = :survey.Id LIMIT 1];
        CKW__c ckw2 = [Select Id, Person__c, Person__r.Handset__c, Person__r.Handset__r.IMEI__c from CKW__c where Id = :ckw.Id LIMIT 1];


		ProcessSurveySubmission.SurveySubmission surveySubmission = new ProcessSurveySubmission.SurveySubmission();
        surveySubmission.imei = ckw2.Person__r.Handset__r.IMEI__c;
        surveySubmission.farmerId = 'GM99999';
        surveySubmission.surveyId = survey2.Name;
        surveySubmission.surveySize = '2345';
        surveySubmission.resultHash = 'cr2EC8B3B70D991F74A8CF10270A28A787CABC28';
        surveySubmission.interviewLatitude = '0.31950';
        surveySubmission.interviewLongitude = '32.58986';
        surveySubmission.interviewAltitude = '55.00000';
        surveySubmission.interviewAccuracy = '0.00000';
        surveySubmission.submissionLatitude = '0.31950';
        surveySubmission.submissionLongitude = '32.58986';
        surveySubmission.submissionAltitude = '55.00000';
        surveySubmission.submissionAccuracy = '0.00000';
        surveySubmission.submissionGPSTimestamp = '1353423873334';
        surveySubmission.interviewGPSTimestamp = '1353423873334';
        surveySubmission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        System.debug('Submit Time: ' + surveySubmission.handsetSubmitTime);


        surveySubmission.xml = '<?xml version=\'1.0\' ?><farm_entrance_form id="farm_entrance_form" name="Farm entrance form"><q1>1</q1><q2>Emmanuel Wandega Gilbert</q2><q3>MR/001</q3><q4>Industrial Area</q4><q5>Mbale</q5><q6>1</q6><q7><q8>A</q8><q9>3.0</q9><q10>Coffee</q10><q11>100</q11><q12>2010-09-26</q12><q13>600</q13><q14>Never</q14><q15>1</q15></q7><q16>1</q16><q17><q18>B</q18><q19>2.0</q19><q20>Beans</q20><q21>1</q21><q22>Yams</q22><q23>2</q23><q24>Beans</q24><q25>1</q25></q17><q17><q18>C</q18><q19>2.0</q19><q20>Maize</q20><q21>1</q21><q22>Beans</q22><q23>1</q23><q24>Yams</q24><q25>1</q25></q17><q27>1</q27><q28><q29>Donkey</q29><q30>3</q30><q31>2 3</q31><q32>The place is good</q32></q28><q33>I have inspected the fields and we can have it registered as organic.</q33><q34>1</q34><q35>1</q35><q36>0.33127721 32.57675719 1207.0 12.0</q36><submission_start_time>2013-09-26T10:30:11.551</submission_start_time><handset_submit_time>2013-09-26T11:15:47.611</handset_submit_time><survey_id>861</survey_id></farm_entrance_form>';
        surveySubmission.json = 'none';

        ProcessSurveySubmission.SurveySubmission resultSurveySubmission = ProcessSurveySubmission.processSurveySubmission(surveySubmission);
        System.debug(resultSurveySubmission.errorMessage);
        System.assert(resultSurveySubmission.success);
	}




    static testMethod void testGumutindoGroupSurveySubmission()
    {
         
        
        //createMetrics();

        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, null, 'Female');
        database.saveResult saveResult = database.insert(ckw);
        String ckwId = saveResult.getId();
       


        Survey__c survey = new Survey__c();
        survey.Survey_Name__c = 'gcce group survey';
        survey.Post_Processing_Method__c = 'GUMUTINDO_GROUP_SURVEY';
        survey.Save_To_Salesforce__c = false;
        survey.Survey_Status__c = 'Active';
        survey.Start_Date__c = date.today().addMonths(-1);
        saveResult = database.insert(survey);
        String surveyId = saveResult.getId();
        
        Survey__c survey2 = [Select Id, Name from Survey__c where Id = :survey.Id LIMIT 1];
        CKW__c ckw2 = [Select Id, Person__c, Person__r.Handset__c, Person__r.Handset__r.IMEI__c from CKW__c where Id = :ckw.Id LIMIT 1];


        ProcessSurveySubmission.SurveySubmission surveySubmission = new ProcessSurveySubmission.SurveySubmission();
        surveySubmission.imei = ckw2.Person__r.Handset__r.IMEI__c;
        surveySubmission.farmerId = 'GM99998';
        surveySubmission.surveyId = survey2.Name;
        surveySubmission.surveySize = '2345';
        surveySubmission.resultHash = 'dr2EC8B3B70D991F74A8CF10270A28A787CABC28';
        surveySubmission.interviewLatitude = '0.31950';
        surveySubmission.interviewLongitude = '32.58986';
        surveySubmission.interviewAltitude = '55.00000';
        surveySubmission.interviewAccuracy = '0.00000';
        surveySubmission.submissionLatitude = '0.31950';
        surveySubmission.submissionLongitude = '32.58986';
        surveySubmission.submissionAltitude = '55.00000';
        surveySubmission.submissionAccuracy = '0.00000';
        surveySubmission.submissionGPSTimestamp = '1353423873334';
        surveySubmission.interviewGPSTimestamp = '1353423873334';
        surveySubmission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        System.debug('Submit Time: ' + surveySubmission.handsetSubmitTime);


        //surveySubmission.xml = '<?xml version=\'1.0\' ?><group_survey id="group_survey" name="Group Survey"><q11>1 2</q11><submission_start_time>2013-09-26T10:30:11.551</submission_start_time><handset_submit_time>2013-09-26T11:15:47.611</handset_submit_time><survey_id>861</survey_id></group_survey>';
        surveySubmission.xml = '<?xml version=\'1.0\' ?><group_survey id="group_survey" name="Group Survey"><answer><binding>q11</binding><answerText>1 2</answerText><instance>0</instance></answer><submission_start_time>2013-09-26T10:30:11.551</submission_start_time><handset_submit_time>2013-09-26T11:15:47.611</handset_submit_time><survey_id>861</survey_id></group_survey>';
        surveySubmission.json = 'none';

        ProcessSurveySubmission.SurveySubmission resultSurveySubmission = ProcessSurveySubmission.processSurveySubmission(surveySubmission);
        System.debug(resultSurveySubmission.errorMessage);
        System.assert(resultSurveySubmission.success);


        //Check metric data value
        M_E_Metric_Data__c metricData = GumutindoHelpers.getMetricData('Gumutindo_farmer_groups_who_receive_support_from_ckw_network');
        System.assert(metricData.Denumerator__c == 1);
        System.assert(metricData.Numerator__c == 1);











        //Test farmer assessment survey
        survey = new Survey__c();
        survey.Survey_Name__c = 'gcce farmer assessment';
        survey.Post_Processing_Method__c = 'GCCE_FARMER_GROUP_ASSESSMENT';
        survey.Save_To_Salesforce__c = false;
        survey.Survey_Status__c = 'Active';
        survey.Start_Date__c = date.today().addMonths(-1);
        saveResult = database.insert(survey);
        surveyId = saveResult.getId();
        
        survey2 = [Select Id, Name from Survey__c where Id = :survey.Id LIMIT 1];
        

        surveySubmission = new ProcessSurveySubmission.SurveySubmission();
        surveySubmission.imei = ckw2.Person__r.Handset__r.IMEI__c;
        surveySubmission.surveyId = survey2.Name;


        surveySubmission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        System.debug('Submit Time: ' + surveySubmission.handsetSubmitTime);


        //surveySubmission.xml = '<?xml version=\'1.0\' ?><group_survey id="group_survey" name="Group Survey"><q11>1 2</q11><submission_start_time>2013-09-26T10:30:11.551</submission_start_time><handset_submit_time>2013-09-26T11:15:47.611</handset_submit_time><survey_id>861</survey_id></group_survey>';
        surveySubmission.xml = '<?xml version=\'1.0\' ?><group_farmer_member_assessment id="group_farmer_member_assessment" name="group_farmer_member_assessment"><answer><binding>q13</binding><answerText>1 2 3</answerText><instance>0</instance></answer><answer><binding>q11</binding><answerText>1 2 3</answerText><instance>0</instance></answer><submission_start_time>2013-09-26T10:30:11.551</submission_start_time><handset_submit_time>2013-09-26T11:15:47.611</handset_submit_time><survey_id>861</survey_id></group_farmer_member_assessment>';
        surveySubmission.json = 'none';

        resultSurveySubmission = ProcessSurveySubmission.processSurveySubmission(surveySubmission);
        System.debug(resultSurveySubmission.errorMessage);
        System.assert(resultSurveySubmission.success);


        //Check metric data value
        metricData = GumutindoHelpers.getMetricData('Gumutindo_target_farmers_using_at_least_three_of_recommended_agroc_practices');
        System.debug(metricData);
        System.assert(metricData.Denumerator__c == 1);
        System.assert(metricData.Numerator__c == 1);


        metricData = GumutindoHelpers.getMetricData('Gumutindo_farmers_who_receive_advisory_services_from_ckw_network');
        System.debug(metricData);
        System.assert(metricData.Denumerator__c == 1);
        System.assert(metricData.Numerator__c == 1);

        
    }


    static testMethod void testGumutindoHelpers()
    {
        M_E_Metric_Data__c testMetricData = GumutindoHelpers.getMetricData('Gumutindo_test_metric');
        
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
        insert(testSociety);

        



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
        gumutindoCkw.Gumutindo_Primary_Society__c = testSociety.Id;
        insert(gumutindoCkw);




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
        resultPage.getParameters().put('dateFrom', '1987-12-18');
        resultPage.getParameters().put('dateTo', '2013-12-18');
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


        GumutindoHelpers.getMetricDataMap(); //Attempt to create metric datas
        Test.startTest();
        
        List<MetricDataWrapper> getFarmersReachedData = controller.getFarmersReachedData();

        List<MetricDataWrapper> getAdvisoryServicesData = controller.getAdvisoryServicesData();



        List<MetricDataWrapper> getGcceMetricsData = controller.getGcceMetricsData();
        List<MetricDataWrapper> getVslaServicesData = controller.getVslaServicesData();
        List<GumutindoHelpers.FinancialServicesUsageData> getFinancialServicesChartData = controller.getFinancialServicesChartData();
        List<SelectOption> getDistrictList = controller.getDistrictList();
        System.assert(testMetricData != null);
        System.assert(GumutindoHelpers.getAllMetrics().size() != 0);
        System.assert(GumutindoHelpers.getGumutindoPrimarySocietyMarkers().size() == 1);

        System.assert(GumutindoHelpers.getCKWMapMarkers().size() == 2); //one for ckw and one for fo
        System.assert(controller.district != null);
        System.assert(controller.subcounty != null);
        System.assert(controller.dummyObject != null);
        System.assert(controller.getDistrictMapSection() != null);

        System.assert(controller.loadGumutindoPrimarySocieties().size() == 1);
        System.assert(getFarmersReachedData.size() == 3);

        System.assert(getAdvisoryServicesData.size() == 4);
        System.assert(getGcceMetricsData.size() == 8);
        System.assert(getVslaServicesData.size() == 5);
        System.assert(getFinancialServicesChartData.size() == 3);
        System.assert(getDistrictList.size() == 2);
        System.assert(controller.getSubcountiesList().size() == 2);

        System.assert(controller.changeFilters() != null);
        

        System.assert(controller.getMaps().size() ==1);
        System.assert('false'.equals(controller.getIsEditMode()));
        System.assert('true'.equals(controller.getIsUpdateable()));

        System.assert(GumutindoHelpers.loadCkw(testPerson) != null);

        System.assert('1'.equals(GumutindoHelpers.getMumutindoProjectYear(Date.valueOf('2014-01-01'))));
        System.assert('2'.equals(GumutindoHelpers.getMumutindoProjectYear(Date.valueOf('2015-01-01'))));
        System.assert('3'.equals(GumutindoHelpers.getMumutindoProjectYear(Date.valueOf('2016-01-01'))));

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
         //gCMarker.ckw.Person__r.Parish__c = 'Test Parish';
         //gCMarker.ckw.Person__r.Village__c = 'Test Village';
         //gCMarker.ckw.Person__r.Subcounty__r.Display_Name__c = 'Test Sub Display';
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
         System.assert(gPSMarker.getMarkerInfoContentString() != null);
        //System.assert(GumutindoHelpers.gumu().size() == 1);
        Test.stopTest();


    }
}