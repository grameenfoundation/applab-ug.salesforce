/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  Contains tests for BUCCODEG Dashboard
 *  Classes covered include; BuccodecDashboardController and BuccodecHelpers
 *  
 */
@isTest
private class BuccodecTests {

    static testMethod void buccodegDashboardControllerTest() {
        
        BuccodecDashboardController controller = new BuccodecDashboardController();
        
        // test getters and setters
        controller.tabName = 'Buccodeg';
        System.assert(controller.tabName == 'Buccodeg');
        System.assert(controller.getIsEditMode() == 'false');
        
        String quarter = MetricHelpers.getCurrentQuarterAsString(0);
        controller.setCurrentQuarter(quarter);
        System.assert(quarter == controller.getCurrentQuarter());
        System.assert(controller.getIsCurrentQuarter() == 'true');
        System.assert(quarter == controller.getQuarter());
        
        controller.changeQuarter();
        controller.setIsUpdateable('false');// default was true
        System.assert(controller.getIsUpdateable() == 'false');
        
        System.assert(controller.getIsEditMode() == 'false');   // was not passed as get parameter hence stays false
        System.assert(controller.getQuarters().size() > 1);     // 
        
        // test methods fetching metric datas
        // first create the org and metrics
        Account acc = Utils.createTestOrganisation('test');
        acc.Name = BuccodecHelpers.ORG_NAME;
        insert acc;
        
        Dashboard__c dash = new Dashboard__c();
        dash.Account__c = acc.Id;
        dash.Title__c = 'Title';
        dash.Description__c = 'Description';
        insert dash;

        Dashboard_Section__c section = new Dashboard_Section__c();
        section.Dashboard__c = dash.Id;
        section.Title__c = 'Title';
        insert section;

        Metric_Section__c metricsection = new Metric_Section__c();
        metricsection.Dashboard_Section__c = section.Id;
        metricsection.Is_Active__c = false;
        metricsection.Title__c = 'Scale';
        metricsection.Start_Date__c = Date.today();
        metricsection.Default_Show__c = 1;
        metricsection.Show_Spark_Line__c = true;
        insert metricsection;
        
        // Create a test M_E_Metric__c and a M_E_Metric_Data__c
        List<M_E_Metric__c> metrics = new List<M_E_Metric__c>();
        // summation metric
        M_E_Metric__c testMetric = new M_E_Metric__c();
        testMetric.Name = 'TEST_THIS_CODE';
        testMetric.Label__c = 'This and that';
        testMetric.M_E_Area__c = 'Scale';
        testMetric.Order__c = 4;
        testMetric.On_The_Fly_Calculation_Type__c = 'Sum';
        testMetric.Automated__c = 'True';
        testMetric.Organisation__c = acc.Id;
        testMetric.Metric_Section__c = metricsection.Id;
        metrics.add(testMetric);
        
        // percentage metric
        M_E_Metric__c testMetric1 = new M_E_Metric__c();
        testMetric1.Name = 'TEST_THIS_CODE1';
        testMetric1.Label__c = 'This and that';
        testMetric1.M_E_Area__c = 'Quality';
        testMetric1.Order__c = 3;
        testMetric1.On_The_Fly_Calculation_Type__c = 'Percentage';
        testMetric1.Automated__c = 'True';
        testMetric1.Organisation__c = acc.Id;
        testMetric1.Metric_Section__c = metricsection.Id;
        metrics.add(testMetric1);
        
        // metric without Area
        M_E_Metric__c testMetric11 = new M_E_Metric__c();
        testMetric11.Name = 'TEST_THIS_CODE2';
        testMetric11.Label__c = 'This and that';
        // testMetric11.M_E_Area__c = 'Quality'; // NULL
        testMetric11.Order__c = 2;
        testMetric11.Automated__c = 'True';
        testMetric11.Organisation__c = acc.Id;
        testMetric11.Metric_Section__c = metricsection.Id;
        metrics.add(testMetric11);
        
        // manual metric
        M_E_Metric__c testMetric111 = new M_E_Metric__c();
        testMetric111.Name = 'TEST_THIS_CODE3';
        testMetric111.Label__c = 'This and that';
        testMetric111.M_E_Area__c = 'Sustainability';
        testMetric111.Order__c = 1;
        testMetric111.Automated__c = 'False';
        testMetric111.Organisation__c = acc.Id;
        testMetric111.Metric_Section__c = metricsection.Id;
        metrics.add(testMetric111);
        insert metrics;
        
        List<M_E_Metric_Data__c> metricData = new List<M_E_Metric_Data__c>();
        // sum
        M_E_Metric_Data__c testDataCurrent = new M_E_Metric_Data__c();
        testDataCurrent.M_E_Metric__c = testMetric.Id;
        testDataCurrent.Actual_Value__c = 10;
        testDataCurrent.Projected_Value__c = 15;
        testDataCurrent.Date__c = date.newInstance(date.today().year(), 1, 1);
        testDataCurrent.Comment__c = 'This should be this quarters.';
        testDataCurrent.Numerator__c = 5;
        metricData.add(testDataCurrent);
        
        // percent
        M_E_Metric_Data__c testDataCurrent1 = new M_E_Metric_Data__c();
        testDataCurrent1.M_E_Metric__c = testMetric1.Id;
        testDataCurrent1.Actual_Value__c = 10;
        testDataCurrent1.Projected_Value__c = 15;
        testDataCurrent1.Date__c = date.newInstance(date.today().year(), 1, 1);
        testDataCurrent1.Comment__c = 'This should be this quarters.';
        testDataCurrent1.Numerator__c = 5;
        testDataCurrent1.Denumerator__c = 50;
        metricData.add(testDataCurrent1);
        
        // no area name
        M_E_Metric_Data__c testDataCurrent11 = new M_E_Metric_Data__c();
        testDataCurrent11.M_E_Metric__c = testMetric11.Id;
        testDataCurrent11.Actual_Value__c = 10;
        testDataCurrent11.Projected_Value__c = 15;
        testDataCurrent11.Date__c = date.newInstance(date.today().year(), 1, 1);
        testDataCurrent11.Comment__c = 'This should be this quarters.';
        testDataCurrent11.Numerator__c = 5;
        metricData.add(testDataCurrent11);
        
        // manual metric data
        M_E_Metric_Data__c testDataCurrent111 = new M_E_Metric_Data__c();
        testDataCurrent111.M_E_Metric__c = testMetric111.Id;
        testDataCurrent111.Actual_Value__c = 10;
        testDataCurrent111.Projected_Value__c = 15;
        testDataCurrent111.Date__c = date.newInstance(date.today().year(), 1, 1);
        testDataCurrent111.Comment__c = 'This should be this quarters.';
        testDataCurrent111.Actual_Value__c = 5;
        testDataCurrent111.Manual_Value__c = 50;
        metricData.add(testDataCurrent111);
        insert metricData;
        
        controller = new BuccodecDashboardController();
        controller.setQuarter('Jan - Mar ' + date.today().year());
        BuccodecHelpers.DataWrapper[] data = controller.getScaleData();
        System.assert(data.size() == 1);
        System.assert(data[0].quarter_actual_reached == 5);
        
        System.assert(controller.getImpactData().size() == 0);
        System.assert(controller.getQualityData().size() == 1);
        System.assert(controller.getSustainabilityData().size() == 1);
        
        System.assert(controller.getViewScale() == false);
        System.assert(controller.getViewQuality() == null);
        System.assert(controller.getViewImpact() == null);
        System.assert(controller.getViewSustainability() == null);
        
        controller.setQuarter(null);
        controller.getQuarters();
        System.assert(controller.getQuarter() != null);
        
        // TEST post-processing
        surveysPostProcessingTest(acc, dash, section, metricsection, testMetric, testMetric1, testMetric111);
    }
    
    static void surveysPostProcessingTest(Account acc, Dashboard__c dash, Dashboard_Section__c section,
            Metric_Section__c metricsection, M_E_Metric__c testMetric, M_E_Metric__c testMetric1, 
            M_E_Metric__c testMetric111){
        
        Country__c country = Utils.createTestCountry('Kenya');
        insert country;
        
        //test CBT listbox
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

        // Create the metrics for use
        List<String> metricNames = new List<String> {
            'BUCCODEC_total_farmers_reached',
            'BUCCODEC_percent_male_farmers_reached',
            'BUCCODEC_percent_female_farmers_reached'
        };
        List<M_E_Metric__c> metrics = new List<M_E_Metric__c>();
        for(String name : metricNames){
            M_E_Metric__c metric1 = new M_E_Metric__c();
            metric1.Name = name;
            metric1.Metric_Section__c = metricsection.Id;
            metric1.Organisation__c = acc.Id;
            metrics.add(metric1);
        } 
        insert metrics;

        //test metrics
        Survey__c survey = new Survey__c();
        survey.Account__c = acc.Id;
        survey.Post_Processing_Method__c = 'BUCCODEG';
        survey.Survey_Name__c = 'Buccodeg Farmer Reg';
        survey.Survey_Status__c = 'Published';
        survey.Start_Date__c = Date.valueOf(date.today().year() + '-01-01');
        survey.End_Date__c = Date.valueOf((date.today().year() + 4) + '-01-01');
        insert survey;
        
        User mike = new User();
        mike.Username= 'bungoma@applab.org';
        mike.Email = 'mike.white@company.com';
        mike.Lastname = BuccodecHelpers.USER_NAME;
        mike.Firstname = 'white';
        mike.Alias = 'mwhite';
        mike.CommunityNickname = 'mwhite01';
        //mike.CurrencyIsoCode = 'USD';
        mike.TimeZoneSidKey = 'GMT';
        mike.LocaleSidKey = 'en_US';
        mike.EmailEncodingKey = 'ISO-8859-1';
        mike.LanguageLocaleKey = 'en_US';
        mike.UserPermissionsMobileUser = false;
        mike.UserRoleId = UserInfo.getUserRoleId();
        mike.ProfileId = UserInfo.getProfileId();
        insert mike;
        
        // FARMER REGISTRATION
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = testHandset.IMEI__c;
        submission.resultHash = '1';
        submission.surveyId = [select Id, Name from Survey__c where Id = :survey.Id].Name;
            
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'BU1234', null, null, null));
        List<String> returnValues = new List<String>();
        // with imcomplete data
        returnValues = BuccodecHelpers.surveysPostProcessing(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('FAILED'));
        
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', 'John Doe', null, null, null));
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', 'Foo', null, null, null));
        answers.put('q4_0', Utils.createTestSubmissionAnswer(null, 'q4', 'Bar', null, null, null));
        answers.put('q5_0', Utils.createTestSubmissionAnswer(null, 'q5', '2', null, null, null));
        answers.put('q6_0', Utils.createTestSubmissionAnswer(null, 'q6', '4', null, null, null));
        answers.put('q7_0', Utils.createTestSubmissionAnswer(null, 'q7', '1 2 3', null, null, null));
        answers.put('q21_0', Utils.createTestSubmissionAnswer(null, 'q21', '1 2 3', null, null, null));
        
        // complete data
        returnValues = BuccodecHelpers.surveysPostProcessing(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('success'));
        
        // farmer id already ised
        returnValues = BuccodecHelpers.surveysPostProcessing(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('already used'));
        
        // male farmer 
        answers.put('q5_0', Utils.createTestSubmissionAnswer(null, 'q5', '1', null, null, null));
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'UB40', null, null, null));
        returnValues = BuccodecHelpers.surveysPostProcessing(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('success'));
        
        Date currentDate = MetricHelpers.getQuarterFirstDay(date.today());
        M_E_Metric_Data__c[] datas = [
            SELECT
                Id,
                Name,
                Actual_Value__c,
                Manual_Value__c,
                District__c,
                Denumerator__c,
                Numerator__c,
                Subcounty__c,
                M_E_Metric__r.Name
            FROM
                M_E_Metric_Data__c
            WHERE
                Date__c = :currentDate//TODO: what if there is already an indicator for next quarter?
                AND M_E_Metric__r.Name IN :metricNames
        ];
        System.assert(datas.size() == 3); // males, females and total
        
        // CKW MONOTORING
        survey.Survey_Name__c = 'CKW Monitoring';
        update survey;
        metricNames = new List<String> { 
            'BUCCODEC_total_FFS_held',
            'BUCCODEC_total_VSLA_held'
        };
        metrics = new List<M_E_Metric__c>();
        for(String name : metricNames){
            M_E_Metric__c metric1 = new M_E_Metric__c();
            metric1.Name = name;
            metric1.Metric_Section__c = metricsection.Id;
            metric1.Organisation__c = acc.Id;
            metrics.add(metric1);
        } 
        insert metrics;
        
        answers = new Map<String, Submission_Answer__c>();
        returnValues = new List<String>();
        answers.put('q7_0', Utils.createTestSubmissionAnswer(null, 'q7', '3', null, null, null));

        // lets create a previous quarter datum to cover some code that will look it up
        M_E_Metric_Data__c testDataCurrent = new M_E_Metric_Data__c();
        testDataCurrent.M_E_Metric__c = metrics[0].Id;
        testDataCurrent.Actual_Value__c = 10;
        testDataCurrent.Projected_Value__c = 15;
        testDataCurrent.Manual_Value__c = 15;
        testDataCurrent.Date__c = MetricHelpers.getQuarterFirstDay(currentDate.addMonths(-1));
        testDataCurrent.Comment__c = 'This should be this quarters.';
        testDataCurrent.Numerator__c = 5;
        insert testDataCurrent;
        
        // encounter as FFS session
        returnValues = BuccodecHelpers.surveysPostProcessing(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('success'));
        
        answers.put('q7_0', Utils.createTestSubmissionAnswer(null, 'q7', '1', null, null, null));
        
        // encounter as VSLA session
        returnValues = BuccodecHelpers.surveysPostProcessing(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('success'));
        
        datas = [
            SELECT
                Id,
                Name,
                Actual_Value__c,
                Manual_Value__c,
                District__c,
                Denumerator__c,
                Numerator__c,
                Subcounty__c,
                M_E_Metric__r.Name
            FROM
                M_E_Metric_Data__c
            WHERE
                Date__c = :currentDate//TODO: what if there is already an indicator for next quarter?
                AND M_E_Metric__r.Name IN :metricNames
        ];
        System.assert(datas.size() == 2); // males, females and total + FFS and VSLA sessions
        
        // STRAY SUBMISSION
        survey.Survey_Name__c = 'Foo Bar';
        update survey;
        returnValues = BuccodecHelpers.surveysPostProcessing(submission, answers, testPerson);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('irrelevant'));
    }
    
    static testMethod void checkMetricGraph() {
        
        Date startDate = date.newInstance(2011, 1, 1);  
        Date endDate = date.newInstance(2011, 3, 31);
        
        // Create a test M_E_Metric__c and a M_E_Metric_Data__c
        M_E_Metric__c testMetric = new M_E_Metric__c();
        testMetric.Name = 'TEST_THIS_CODE';
        testMetric.Label__c = 'This and that';
        testMetric.M_E_Area__c = 'Impact';
        testMetric.Order__c = 4;
        testMetric.Update_Period__c = 'Daily';
        testMetric.On_The_Fly_Calculation_Type__c = 'Sum';
        testMetric.Automated__c = 'True';
        database.insert(testMetric);

        List<M_E_Metric_Data__c> metricData = new List<M_E_Metric_Data__c>();
        M_E_Metric_Data__c testDataCurrent = new M_E_Metric_Data__c();
        testDataCurrent.M_E_Metric__c = testMetric.Id;
        testDataCurrent.Actual_Value__c = 10;
        testDataCurrent.Projected_Value__c = 15;
        testDataCurrent.Date__c = startDate;
        testDataCurrent.Comment__c = 'This should be this quarters.';
        testDataCurrent.Numerator__c = 5;
        metricData.add(testDataCurrent);

        M_E_Metric_Data__c testDataPrevious = new M_E_Metric_Data__c();
        testDataPrevious.M_E_Metric__c = testMetric.Id;
        testDataPrevious.Actual_Value__c = 10;
        testDataPrevious.Projected_Value__c = 15;
        testDataPrevious.Date__c = startDate.addMonths(-3);
        testDataPrevious.Comment__c = 'This should be last quarters.';
        testDataCurrent.Numerator__c = 50;
        metricData.add(testDataPrevious);
        database.insert(metricData);
        
        BuccodecMetricGraphController metricGraph = new BuccodecMetricGraphController();
        metricGraph.metricId = String.valueOf(testMetric.Id);
        metricGraph.setChartData();
        
        System.assert(metricGraph.getChartData().length() > 162);
        System.assert(metricGraph.getChartTitle().equals(testMetric.M_E_Area__c + ': ' + testMetric.Label__c));
        
        // %ge indicator
        testMetric.On_The_Fly_Calculation_Type__c = 'Percentage';
        update testMetric; 
        testDataCurrent.Denumerator__c = 10;
        update testDataCurrent;
        delete testDataPrevious;
        metricGraph.setChartData();
        
        // manual indicator
        testMetric.Automated__c = 'False';
        update testMetric;
        metricGraph.setChartData();
        
        // lower the absoulute mean
        testDataCurrent.Projected_Value__c = -5;
        testDataCurrent.Numerator__c = -10;
        update testDataCurrent;
        metricGraph.setChartData();
    }
    
    static testmethod void testStatsImport(){
        
        Server_Configuration__c config = new Server_Configuration__c();
        config.URL__c = 'http://some.site';
        config.Search_Database__c = 'some.db';
        config.Survey_Database__c = 'some.other.db';
        insert config;
        
        Account org = Utils.createTestOrganisation('TestOrg1');
        database.insert(org);
        
        String name = 'BUCCODEC_percent_quality_surveys';
        M_E_Metric__c metric = FHISurveysHelpers.createTestMetric(org, 'None', 'Impact', true, name);
        insert metric;
        
        Date currentDate = MetricHelpers.getQuarterFirstDay(date.today());
        M_E_Metric_Data__c mdata = BuccodecHelpers.createNewMetric(name, currentDate);
        insert mdata;
        
        BuccodecHelpers.getRawDataStats();
        
        M_E_Metric_Data__c[] datas = [
            SELECT
                Id,
                Name,
                Actual_Value__c,
                Manual_Value__c,
                Denumerator__c,
                Numerator__c,
                M_E_Metric__r.Name
            FROM
                M_E_Metric_Data__c
            WHERE
                Date__c = :currentDate
                AND M_E_Metric__r.Name = :name];
        M_E_Metric_Data__c m = datas[0];
        System.assert(m.Numerator__c == 123);
        System.assert(m.Denumerator__c == 456);
    }
}