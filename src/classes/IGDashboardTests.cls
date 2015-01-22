/**
 *
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *  This class contains tests for IG/NUSAF Dashboard
 **/
@isTest
private class IGDashboardTests {
    
    static testMethod void testDashboardComponents() {    	
        
        //no metric map markers
        List<MetricMapWrapper> fieldVisits = IGDashboardHelpers.getFieldVisitsMapMarkers('', '', '', '', '', null);
        System.assert(fieldVisits.size() == 0);
        
        IGDashboardController controller = new IGDashboardController();
        
        Account testOrg = new Account();
        testOrg.Name = 'TestCKW';
        testOrg.BillingState = 'CA';
        insert testOrg;
        controller.setOrgName(testOrg.Name);

        Country__c country = new Country__c();
        country.Name = 'TestUganda';
        country.ISO_Standard_Code__c = 'sw';
        insert country;
        controller.setCountry(country.Name);
        
        //test regions listbox		
        IG_Region__c region = new IG_Region__c();
        region.Name = 'acholi';
        insert region;
        
        List<SelectOption> regions = controller.getSubregionsList();
        System.assert(regions.size() == 2);	//including the default --select all		
        controller.setSubregionsList(null);
        
        //test districts list box
        District__c testDistrict = new District__c();
        testDistrict.Name = 'TestMasaka';
        testDistrict.Region__c = 'Central';
        insert testDistrict;

        Organisation_District_Association__c o = new Organisation_District_Association__c();
        o.Organisation__c = testOrg.Id;
        o.District__c = testDistrict.Id;
        insert o;

        IG_Region_District_Association__c rda = new IG_Region_District_Association__c();
        rda.District__c = testDistrict.Id;
        rda.IG_Region__c = region.Id;
        insert rda;
        
        List<SelectOption> districts = controller.getDistrictList();
        System.assert(districts.size() == 2);//including the default --select all		
        controller.setDistrictList(null);
        
        //test subcounty listbox
        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'TestLukaya-TC';
        testSubcounty.District__c = testDistrict.Id;
        insert testSubcounty;      

        List<SelectOption> subs = controller.getSubcountiesList();
        System.assert(subs.size() == 2);//including the default --select all	
        controller.setSubcountiesList(null);
        
        //test CBT listbox
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = '123456789101112';
        testHandset.Serial_Number__c = '123456789101112';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert testHandset;

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'David';
        testPerson.Last_Name__c = 'Mugume' ;
        testPerson.Gender__c = 'Male';
        testPerson.District__c = testDistrict.Id;
        testPerson.Handset__c = testHandset.Id;
        testPerson.Type__c = IGDashboardHelpers.IG_PERSON_TYPE_NAME;
        insert testPerson;

        //test setup
        PageReference resultPage =  new PageReference('/a00/e');
        resultPage.getParameters().put('subregion', String.valueOf(region.Id));
        resultPage.getParameters().put('district', String.valueOf(testDistrict.Id));
        resultPage.getParameters().put('subcounty', String.valueOf(testSubcounty.Id));
        resultPage.getParameters().put('dateFrom', '1987-12-18');
        resultPage.getParameters().put('dateTo', '2013-12-18');
        resultPage.getParameters().put('cbt', String.valueOf(testPerson.Id));
        resultPage.getParameters().put('sfdc.tabName', 'a00');
        controller.setUp(resultPage);
        System.assert(controller.getSubregion() != '');
        System.assert(controller.district != null);
        System.assert(controller.subcounty != null);
        System.assert(controller.dummyObject != null);
        System.assert(controller.getIsRegionalManager() == false);
        System.assert(controller.getIsOversight() == true);

        //test metrics
        Survey__c survey = new Survey__c();
        survey.Account__c = ([select Id from Account where Name = :testOrg.Name])[0].Id;
        survey.Post_Processing_Method__c = 'IG_CBT_VISITS';
        survey.Survey_Name__c = 'SACM acholi';
        survey.Survey_Status__c = 'Published';
        survey.Start_Date__c = Date.valueOf('2013-01-01');
        survey.End_Date__c = Date.valueOf('2015-01-01');
        insert survey;

        IG_Subproject_Target__c v = new IG_Subproject_Target__c();
        v.District__c = ((District__c)[select Id from District__c where Name = :testDistrict.Name]).Id;
        v.LocationMobilization__c = '0.32332 34.445566';
        v.LocationPreliminaryTrainingDay1__c = '0.32332 34.445566';
        v.LocationPreliminaryTrainingDay2__c = '0.32332 34.445566';
        v.LocationPreliminaryTrainingDay3__c = '0.32332 34.445566';
        v.LocationFollowupVisit1__c = '0.32332 34.445566';
        v.LocationFollowupVisit2__c = '0.32332 34.445566';
        v.LocationFollowupVisit3__c = '0.32332 34.445566';      
        v.DateMobilization__c = Date.today();                      
        v.DateFollowupVisit1__c= Date.today();                  
        v.DateFollowupVisit2__c= Date.today();               
        v.DateFollowupVisit3__c= Date.today();             
        v.DatePreliminaryTrainingDay1__c= Date.today();         
        v.DatePreliminaryTrainingDay2__c= Date.today();         
        v.DatePreliminaryTrainingDay3__c= Date.today(); 
        v.Phone_Display_Item_Position__c= 2;
        v.Name = 'Some project name';
        v.Person__c = testPerson.Id;
        v.Subcounty__c = testSubcounty.Id;
        v.IG_Region__c = region.Id;
        insert v;
        
        controller.subcounty = testSubcounty;
        List<SelectOption> cbts = controller.getCommunityBasedTrainers();
        System.assert(cbts.size() == 2);//including the default --select all        
        controller.setCommunityBasedTrainers(null);

        controller.district = testDistrict;
        controller.subregion = region.Id;
        controller.cbt = testPerson;
        //getMetricsData
        //we expect one metric row (for the total of all data)
        List<IGDashboardHelpers.Data> metrics = controller.getRegionalMetricsData();
        System.assert(metrics.size() == 1);

        //changeFilters
        PageReference page = controller.changeFilters();
        System.assert(page != null);

        //listbox events
        PageReference pageRegion = controller.onRegionChanged();
        System.assert(pageRegion == null);
        PageReference pageDistrict = controller.onDistrictChanged();
        System.assert(pageDistrict == null);
        PageReference pageSubc = controller.onSubcountyChanged();
        System.assert(pageSubc == null);

        //getBarChartData
        //we expect metrics for one activity since we registered one survey
        controller.setIsRegionalManager(true);
        List<IGDashboardHelpers.Data> barChartMetrics = controller.getCTMetricsData();
        System.assert(barChartMetrics.size() == 1);
        double percentCompletion = (1 + 3 + 3)/(1 * 1 + 1 *3 + 1 * 3) * 100;
        System.assert(barChartMetrics[0].completion == percentCompletion.round());

        controller.setIsRegionalManager(false);
        List<IGDashboardHelpers.Data> barChartMetricsRegion = controller.getCTMetricsData();
        System.assert(barChartMetricsRegion.size() == 1);

        //metric map markers
        List<MetricMapWrapper> fieldVisits2 = IGDashboardHelpers.getFieldVisitsMapMarkers('', '', '', '', '', null);
        System.assert(fieldVisits2.size() == 1);

        /* Get any profile*/
        Profile p = [SELECT Id FROM profile LIMIT 1];
        //lets run as a regional manager account
        User pu = new User(profileId = p.id, username = 'test_ig@applab.org', email = 'test_ig@applab.com',
                               emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                               languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                               alias='cspu', lastname='acholi');
        insert pu;
        System.runAs(pu){
            System.assert(IGDashboardHelpers.getUserRegion() != null);
            //change data to have  a map marker for each region
            pu.lastname = 'bukedi';
            update pu;
            region.Name = 'bukedi';
            update region;
            System.assert(IGDashboardHelpers.getFieldVisitsMapMarkers('', '', '', '', '', null).size() == 1);

            pu.lastname = 'elgon';
            update pu;
            region.Name = 'elgon';
            update region;
            System.assert(IGDashboardHelpers.getFieldVisitsMapMarkers('', '', '', '', '', null).size() == 1);

            pu.lastname = 'south karamoja';
            update pu;
            region.Name = 'south karamoja';
            update region;
            System.assert(IGDashboardHelpers.getFieldVisitsMapMarkers('', '', '', '', '', null).size() == 1);

            pu.lastname = 'north karamoja';
            update pu;
            region.Name = 'north karamoja';
            update region;
            System.assert(IGDashboardHelpers.getFieldVisitsMapMarkers('', '', '', '', '', null).size() == 1);

            pu.lastname = 'lango';
            update pu;
            region.Name = 'lango';
            update region;
            System.assert(IGDashboardHelpers.getFieldVisitsMapMarkers('', '', '', '', '', null).size() == 1);

            pu.lastname = 'west nile';
            update pu;
            region.Name = 'west nile';
            update region;
            System.assert(IGDashboardHelpers.getFieldVisitsMapMarkers('', '', '', '', '', null).size() == 1);

            pu.lastname = 'un known';
            update pu;
            region.Name = 'un known';
            update region;
            System.assert(IGDashboardHelpers.getFieldVisitsMapMarkers('', '', '', '', '', null).size() == 1);

            //if theres no location, dont createa a marker
            v.LocationMobilization__c = '';
            update v;
            System.assert(IGDashboardHelpers.getFieldVisitsMapMarkers('', '', '', '', '', null).size() == 0);
        }
    }

    static testMethod void testSACMSurveySubmissions() {    
        Account testOrg = new Account();
        testOrg.Name = 'TestCKW';
        testOrg.BillingState = 'CA';
        insert testOrg;

        Country__c country = new Country__c();
        country.Name = 'TestUganda';
        country.ISO_Standard_Code__c = 'sw';
        insert country;
        
        //test regions listbox      
        IG_Region__c region = new IG_Region__c();
        region.Name = 'acholi';
        insert region;
        
        //test districts list box
        District__c testDistrict = new District__c();
        testDistrict.Name = 'TestMasaka';
        testDistrict.Region__c = 'Central';
        insert testDistrict;

        Organisation_District_Association__c o = new Organisation_District_Association__c();
        o.Organisation__c = testOrg.Id;
        o.District__c = testDistrict.Id;
        insert o;

        IG_Region_District_Association__c rda = new IG_Region_District_Association__c();
        rda.District__c = testDistrict.Id;
        rda.IG_Region__c = region.Id;
        insert rda;
        
        //test subcounty listbox
        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'TestLukaya-TC';
        testSubcounty.District__c = testDistrict.Id;
        insert testSubcounty;      
        
        //test CBT listbox
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = '123456789101112';
        testHandset.Serial_Number__c = '123456789101112';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert testHandset;

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'David';
        testPerson.Last_Name__c = 'Mugume' ;
        testPerson.Gender__c = 'Male';
        testPerson.District__c = testDistrict.Id;
        testPerson.Handset__c = testHandset.Id;
        testPerson.Type__c = IGDashboardHelpers.IG_PERSON_TYPE_NAME;
        insert testPerson;

        //test metrics
        Survey__c survey = new Survey__c();
        survey.Account__c = testOrg.Id;
        survey.Post_Processing_Method__c = 'IG_CBT_VISITS';
        survey.Survey_Name__c = 'SACM acholi';
        survey.Survey_Status__c = 'Published';
        survey.Start_Date__c = Date.valueOf('2013-01-01');
        survey.End_Date__c = Date.valueOf('2015-01-01');
        insert survey;

        IG_Subproject_Target__c v = new IG_Subproject_Target__c();
        v.District__c = testDistrict.Id;
        v.LocationMobilization__c = '0.32332 34.445566';
        v.LocationPreliminaryTrainingDay1__c = '0.32332 34.445566';
        v.LocationPreliminaryTrainingDay2__c = '0.32332 34.445566';
        v.LocationPreliminaryTrainingDay3__c = '0.32332 34.445566';
        v.LocationFollowupVisit1__c = '0.32332 34.445566';
        v.LocationFollowupVisit2__c = '0.32332 34.445566';
        v.LocationFollowupVisit3__c = '0.32332 34.445566';      
        v.DateMobilization__c = Date.today();                      
        v.DateFollowupVisit1__c= Date.today();                  
        v.DateFollowupVisit2__c= Date.today();               
        v.DateFollowupVisit3__c= Date.today();             
        v.DatePreliminaryTrainingDay1__c= Date.today();         
        v.DatePreliminaryTrainingDay2__c= Date.today();         
        v.DatePreliminaryTrainingDay3__c= Date.today(); 
        v.Phone_Display_Item_Position__c= 2;
        v.Name = 'Some project name';
        v.Person__c = testPerson.Id;
        v.Subcounty__c = testSubcounty.Id;
        v.IG_Region__c = region.Id;
        insert v;
                
        //test processNUSAFSurveys class.
        //SACM submission
        List<IG_Region__c> other_regions = new List<IG_Region__c>();
        IG_Region__c region1 = new IG_Region__c();
        region1.Name = 'bukedi';
        other_regions.add(region1);

        IG_Region__c region11 = new IG_Region__c();
        region11.Name = 'elgon';
        other_regions.add(region11);

        IG_Region__c region111 = new IG_Region__c();
        region111.Name = 'south karamoja';
        other_regions.add(region111);

        IG_Region__c region1111 = new IG_Region__c();
        region1111.Name = 'north karamoja';
        other_regions.add(region1111);

        IG_Region__c region11111 = new IG_Region__c();
        region11111.Name = 'lango';
        other_regions.add(region11111);

        IG_Region__c region12 = new IG_Region__c();
        region12.Name = 'west nile';
        other_regions.add(region12);

        insert other_regions;

        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = testHandset.IMEI__c;
        submission.resultHash = '1';
        submission.surveyId = [select Id, Name from Survey__c where Id = :survey.Id].Name;
            
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('activity_type_0', Utils.createTestSubmissionAnswer(null, 'activity_type', 'meetings', null, null, null));
        List<String> returnValues = new List<String>();
        //a submission not meant for subproject monitoring
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        Test.startTest();
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('Please download the new version of forms'));
        survey.Survey_Name__c = 'SACM acholi_v2';
        update survey;
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('non-monitoring'));

        answers.clear();
        answers.put('activity_type_0', Utils.createTestSubmissionAnswer(null, 'activity_type', 'project', null, null, null));
        answers.put('district_0', Utils.createTestSubmissionAnswer(null, 'district', 'un known', null, null, null));

        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('district'));

        answers.clear();
        answers.put('activity_type_0', Utils.createTestSubmissionAnswer(null, 'activity_type', 'project', null, null, null));
        answers.put('district_0', Utils.createTestSubmissionAnswer(null, 'district', 'testmasaka', null, null, null));
        answers.put('testmasaka_subs_0', Utils.createTestSubmissionAnswer(null, 'testmasaka_subs', 'unknown', null, null, null));
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('subcounty'));

        answers.put('testmasaka_subs_0', Utils.createTestSubmissionAnswer(null, 'testmasaka_subs', 'testlukaya_tc', null, null, null));
        answers.put('testlukaya_tc_subprojects_0', Utils.createTestSubmissionAnswer(null, 'testlukaya_tc_subprojects', '1_something_something_subproject', null, null, null));
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('not assigned this target'));

        answers.put('testlukaya_tc_subprojects_0', Utils.createTestSubmissionAnswer(null, 'testlukaya_tc_subprojects', '2_bla_bla_subroject', null, null, null));
        answers.put('date_0', Utils.createTestSubmissionAnswer(null, 'date', '2014-05-14', null, null, null));
        //answers.put('gps_0', Utils.createTestSubmissionAnswer(null, 'gps', '0.32332 34.445566 10 2', null, null, null));
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('did not record the location of your visit'));

        answers.put('gps_0', Utils.createTestSubmissionAnswer(null, 'gps', '0.32332 34.445566 10 2', null, null, null));
        //answers.put('meeting_type_0', Utils.createTestSubmissionAnswer(null, 'meeting_type', 'testlukaya_tc', null, null, null));
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('activity of the day is missing'));

        answers.put('meeting_type_0', Utils.createTestSubmissionAnswer(null, 'meeting_type', 'training_day_1', null, null, null));
        answers.put('project_status_0', Utils.createTestSubmissionAnswer(null, 'project_status', 'completed', null, null, null));
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('submission successful'));
        System.assert(returnValues.get(2).equals('SUPRESSMSG'));

        //now training day 2
        survey.Survey_Name__c = 'SACM elgon_v2';
        update survey;
        v.IG_Region__c = region11.Id;
        update v;
        answers.put('meeting_type_0', Utils.createTestSubmissionAnswer(null, 'meeting_type', 'training_day_2', null, null, null));
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('submission successful'));
        System.assert(returnValues.get(2).equals('SUPRESSMSG'));
        //now training day 3
        survey.Survey_Name__c = 'SACM south karamoja_v2';
        update survey;
        v.IG_Region__c = region111.Id;
        update v;
        answers.put('meeting_type_0', Utils.createTestSubmissionAnswer(null, 'meeting_type', 'training_day_3', null, null, null));
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('submission successful'));
        System.assert(returnValues.get(2).equals('SUPRESSMSG'));
        //now followup visit 1
        survey.Survey_Name__c = 'SACM north karamoja_v2';
        update survey;
        v.IG_Region__c = region1111.Id;
        update v;
        answers.put('meeting_type_0', Utils.createTestSubmissionAnswer(null, 'meeting_type', 'followup_visit_1', null, null, null));
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('submission successful'));
        System.assert(returnValues.get(2).equals('SUPRESSMSG'));
        //now followup visit 2
        survey.Survey_Name__c = 'SACM lango_v2';
        update survey;
        v.IG_Region__c = region11111.Id;
        update v;
        answers.put('meeting_type_0', Utils.createTestSubmissionAnswer(null, 'meeting_type', 'followup_visit_2', null, null, null));
        //add repeat
        answers.put('q9_0', Utils.createTestSubmissionAnswer(null, 'q9', 'null', null, null, null));
        answers.put('q9_1', Utils.createTestSubmissionAnswer(null, 'q9', 'null', null, null, null));
        answers.put('district_1', Utils.createTestSubmissionAnswer(null, 'district', 'testmasaka', null, null, null));
        answers.put('testmasaka_subs_1', Utils.createTestSubmissionAnswer(null, 'testmasaka_subs', 'testlukaya_tc', null, null, null));
        answers.put('testlukaya_tc_subprojects_1', Utils.createTestSubmissionAnswer(null, 'testlukaya_tc_subprojects', '3_pit_latrine_subproject', null, null, null));
        
        IG_Subproject_Target__c v2 = new IG_Subproject_Target__c();
        v2.District__c = testDistrict.Id;
        v2.Name = 'another project';
        v2.Person__c = testPerson.Id;
        v2.Subcounty__c = testSubcounty.Id;
        v2.IG_Region__c = region11111.Id;
        v2.Phone_Display_Item_Position__c = 3;
        insert v2;

        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('submission successful'));
        //check that there are multiple success messages since we used a repeat
        System.assert(returnValues.get(1).indexOfIgnoreCase('successful') != returnValues.get(1).lastIndexOfIgnoreCase('successful'));
        System.assert(returnValues.get(2).equals('SUPRESSMSG'));
        //too many soql query, split to new test method below
        Test.stopTest();
    }

    static testMethod void testSACMSurveySubmissionsFollowupVisit3() {    
        Account testOrg = new Account();
        testOrg.Name = 'TestCKW';
        testOrg.BillingState = 'CA';
        insert testOrg;

        Country__c country = new Country__c();
        country.Name = 'TestUganda';
        country.ISO_Standard_Code__c = 'sw';
        insert country;
        
        //test regions listbox      
        IG_Region__c region = new IG_Region__c();
        region.Name = 'west nile';
        insert region;
        
        //test districts list box
        District__c testDistrict = new District__c();
        testDistrict.Name = 'TestMasaka';
        testDistrict.Region__c = 'Central';
        insert testDistrict;

        Organisation_District_Association__c o = new Organisation_District_Association__c();
        o.Organisation__c = testOrg.Id;
        o.District__c = testDistrict.Id;
        insert o;

        IG_Region_District_Association__c rda = new IG_Region_District_Association__c();
        rda.District__c = testDistrict.Id;
        rda.IG_Region__c = region.Id;
        insert rda;
        
        //test subcounty listbox
        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'TestLukaya';
        testSubcounty.District__c = testDistrict.Id;
        insert testSubcounty;      
        
        //test CBT listbox
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = '123456789101112';
        testHandset.Serial_Number__c = '123456789101112';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert testHandset;

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'David';
        testPerson.Last_Name__c = 'Mugume' ;
        testPerson.Gender__c = 'Male';
        testPerson.District__c = testDistrict.Id;
        testPerson.Handset__c = testHandset.Id;
        testPerson.Type__c = IGDashboardHelpers.REGIONAL_MANAGER;
        insert testPerson;

        //test metrics
        Survey__c survey = new Survey__c();
        survey.Account__c = testOrg.Id;
        survey.Post_Processing_Method__c = 'IG_CBT_VISITS';
        survey.Survey_Name__c = 'SACM west nile';
        survey.Survey_Status__c = 'Published';
        survey.Start_Date__c = Date.valueOf('2013-01-01');
        survey.End_Date__c = Date.valueOf('2015-01-01');
        insert survey;

        IG_Subproject_Target__c v = new IG_Subproject_Target__c();
        v.District__c = testDistrict.Id;
        v.LocationMobilization__c = '0.32332 34.445566';
        v.LocationPreliminaryTrainingDay1__c = '0.32332 34.445566';
        v.LocationPreliminaryTrainingDay2__c = '0.32332 34.445566';
        v.LocationPreliminaryTrainingDay3__c = '0.32332 34.445566';
        v.LocationFollowupVisit1__c = '0.32332 34.445566';
        v.LocationFollowupVisit2__c = '0.32332 34.445566';
        v.LocationFollowupVisit3__c = '0.32332 34.445566';
        v.DateMobilization__c = Date.today();
        v.DateFollowupVisit1__c= Date.today();
        v.DateFollowupVisit2__c= Date.today();
        v.DateFollowupVisit3__c= Date.today();
        v.DatePreliminaryTrainingDay1__c= Date.today();
        v.DatePreliminaryTrainingDay2__c= Date.today();
        v.DatePreliminaryTrainingDay3__c= Date.today(); 
        //v.Phone_Display_Item_Position__c = 1;
        v.Name = 'Some project name';
        //not assigned but regional manager should update it
        //v.Person__c = ([select Id from Person__c where First_Name__c = :testPerson.First_Name__c])[0].Id;
        v.Subcounty__c = testSubcounty.Id;
        v.IG_Region__c = region.Id;
        insert v;
        
        //test processNUSAFSurveys class.
        //SACM submission
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '123456789101112';
        submission.resultHash = '1';
        submission.surveyId = [select Id, Name from Survey__c where Id = :survey.Id].Name;
            
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('activity_type_0', Utils.createTestSubmissionAnswer(null, 'activity_type', 'meetings', null, null, null));
        List<String> returnValues = new List<String>();
        //a submission not meant for subproject monitoring
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        //Test.startTest();
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('Please download the new version of forms'));
        survey.Survey_Name__c = 'SACM west nile_v2';
        update survey;
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('non-monitoring'));

        answers.clear();
        answers.put('date_0', Utils.createTestSubmissionAnswer(null, 'date', '2014-05-14', null, null, null));
        answers.put('gps_0', Utils.createTestSubmissionAnswer(null, 'gps', '0.32332 34.445566 10 2', null, null, null));
        answers.put('activity_type_0', Utils.createTestSubmissionAnswer(null, 'activity_type', 'project', null, null, null));
        answers.put('district_0', Utils.createTestSubmissionAnswer(null, 'district', 'testmasaka', null, null, null));
        answers.put('testmasaka_subs_0', Utils.createTestSubmissionAnswer(null, 'testmasaka_subs', 'testlukaya', null, null, null));
        answers.put('testlukaya_subprojects_0', Utils.createTestSubmissionAnswer(null, 'testlukaya_subprojects', '1_tree_planting_subproject', null, null, null));

        //now followup visit 3
        //fails even for a regional manager since subproject position is not set
        answers.put('meeting_type_0', Utils.createTestSubmissionAnswer(null, 'meeting_type', 'followup_visit_3', null, null, null));
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('Could not find the specified subproject'));

        //set position and try again
        v.Phone_Display_Item_Position__c = 1;
        update v;
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('submission successful'));
        System.assert(returnValues.get(2).equals('SUPRESSMSG'));

        //if there's a binding naming bug, response is request for support
        answers.remove('testlukaya_subprojects_0');
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('incorrect data'));
        System.assert(returnValues.get(2).equals('PULSE'));
        //Test.stopTest();
    }

    static testMethod void testEnrollmentSurveySubmissions() {    
        Account testOrg = new Account();
        testOrg.Name = 'TestCKW';
        testOrg.BillingState = 'CA';
        insert testOrg;

        Country__c country = new Country__c();
        country.Name = 'TestUganda';
        country.ISO_Standard_Code__c = 'sw';
        insert country;
        
        //test regions listbox      
        IG_Region__c region = new IG_Region__c();
        region.Name = 'acholi';
        insert region;
        
        //test districts list box
        District__c testDistrict = new District__c();
        testDistrict.Name = 'TestMasaka';
        testDistrict.Region__c = 'Central';
        insert testDistrict;

        Organisation_District_Association__c o = new Organisation_District_Association__c();
        o.Organisation__c = testOrg.Id;
        o.District__c = testDistrict.Id;
        insert o;

        IG_Region_District_Association__c rda = new IG_Region_District_Association__c();
        rda.District__c = testDistrict.Id;
        rda.IG_Region__c = region.Id;
        insert rda;
        
        //test subcounty listbox
        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'TestLukaya-TC';
        testSubcounty.District__c = testDistrict.Id;
        insert testSubcounty;      
        
        //test CBT listbox
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = '123456789101112';
        testHandset.Serial_Number__c = '123456789101112';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert testHandset;

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'David';
        testPerson.Last_Name__c = 'Mugume' ;
        testPerson.Gender__c = 'Male';
        testPerson.District__c = testDistrict.Id;
        testPerson.Handset__c = testHandset.Id;
        testPerson.Type__c = IGDashboardHelpers.IG_PERSON_TYPE_NAME;
        insert testPerson;

        //test metrics
        Survey__c survey = new Survey__c();
        survey.Account__c = testOrg.Id;
        survey.Post_Processing_Method__c = 'IG_CBT_VISITS';
        survey.Survey_Name__c = 'SACM acholi';
        survey.Survey_Status__c = 'Published';
        survey.Start_Date__c = Date.valueOf('2013-01-01');
        survey.End_Date__c = Date.valueOf('2015-01-01');
        insert survey;

        IG_Subproject_Target__c v = new IG_Subproject_Target__c();
        v.District__c = testDistrict.Id;
        v.LocationMobilization__c = '0.32332 34.445566';
        v.LocationPreliminaryTrainingDay1__c = '0.32332 34.445566';
        v.LocationPreliminaryTrainingDay2__c = '0.32332 34.445566';
        v.LocationPreliminaryTrainingDay3__c = '0.32332 34.445566';
        v.LocationFollowupVisit1__c = '0.32332 34.445566';
        v.LocationFollowupVisit2__c = '0.32332 34.445566';
        v.LocationFollowupVisit3__c = '0.32332 34.445566';      
        v.DateMobilization__c = Date.today();                      
        v.DateFollowupVisit1__c= Date.today();                  
        v.DateFollowupVisit2__c= Date.today();               
        v.DateFollowupVisit3__c= Date.today();             
        v.DatePreliminaryTrainingDay1__c= Date.today();         
        v.DatePreliminaryTrainingDay2__c= Date.today();         
        v.DatePreliminaryTrainingDay3__c= Date.today(); 
        v.Phone_Display_Item_Position__c= 2;
        v.Name = 'Some project name';
        v.Person__c = testPerson.Id;
        v.Subcounty__c = testSubcounty.Id;
        v.IG_Region__c = region.Id;
        insert v;
        
        region.Name = 'acholi';
        update region;

        List<IG_Region__c> other_regions = new List<IG_Region__c>();
        IG_Region__c region1 = new IG_Region__c();
        region1.Name = 'bukedi';
        other_regions.add(region1);

        IG_Region__c region11 = new IG_Region__c();
        region11.Name = 'elgon';
        other_regions.add(region11);

        IG_Region__c region111 = new IG_Region__c();
        region111.Name = 'south karamoja';
        other_regions.add(region111);

        IG_Region__c region1111 = new IG_Region__c();
        region1111.Name = 'north karamoja';
        other_regions.add(region1111);

        IG_Region__c region11111 = new IG_Region__c();
        region11111.Name = 'lango';
        other_regions.add(region11111);

        IG_Region__c region12 = new IG_Region__c();
        region12.Name = 'west nile';
        other_regions.add(region12);

        insert other_regions;

        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '123456789101112';
        submission.resultHash = '1';
        submission.surveyId = [select Id, Name from Survey__c where Id = :survey.Id].Name;

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        List<String> returnValues = new List<String>();
            
        //now for astray submissions
        //
        //
        survey.Survey_Name__c = 'Non conforming name';
        update survey;
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        Test.startTest();
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('post-processing irrelevant'));
        survey.Survey_Name__c = 'IG Enrollment Bukedi';
        update survey;
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('Please download the new version of forms'));

        //now for enrollment submissions
        //
        //
        survey.Survey_Name__c = 'IG Enrollment Bukedi_v2';
        update survey;
        //associate our test district to bukedi region
        IG_Region_District_Association__c rda1 = new IG_Region_District_Association__c();
        rda1.District__c = testDistrict.Id;
        rda1.IG_Region__c = region1.Id;
        insert rda1;
        //make sure our subproject is in bukedi
        v.IG_Region__c = region1.Id;
        update v;

        answers.clear();
        answers.put('activity_type_0', Utils.createTestSubmissionAnswer(null, 'activity_type', 'project', null, null, null));
        answers.put('district_0', Utils.createTestSubmissionAnswer(null, 'district', 'testmasaka', null, null, null));
        answers.put('testmasaka_subs_0', Utils.createTestSubmissionAnswer(null, 'testmasaka_subs', 'testlukaya_tc', null, null, null));
        answers.put('testlukaya_tc_subprojects_0', Utils.createTestSubmissionAnswer(null, 'testlukaya_tc_subprojects', '2_lopeduru_subproject', null, null, null));
        answers.put('date_0', Utils.createTestSubmissionAnswer(null, 'date', '2014-05-14', null, null, null));
        answers.put('gps_0', Utils.createTestSubmissionAnswer(null, 'gps', '0.32332 34.445566 10 2', null, null, null));
        answers.put('completed_0', Utils.createTestSubmissionAnswer(null, 'completed', '2', null, null, null));
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('training was marked as Not-Completed'));

        answers.put('completed_0', Utils.createTestSubmissionAnswer(null, 'completed', '1', null, null, null));
        returnValues = ProcessNUSAFSurveys.registerNusafActivityVisit(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('submission successful'));
        Test.stopTest();       
    }
}