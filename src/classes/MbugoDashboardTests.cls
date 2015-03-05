@isTest
public with sharing class MbugoDashboardTests {
    public MbugoDashboardTests() {

    }

    static testMethod void testController() {
        
        District__c testDistrict = new District__c();
        testDistrict.Name = 'TestMasaka';
        testDistrict.Region__c = 'Central';
        insert testDistrict;

        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'TestLukaya-TC';
        testSubcounty.District__c = testDistrict.Id;
        insert testSubcounty;      

        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = '123456789101112';
        testHandset.Serial_Number__c = '123456789101112';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert testHandset;

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'John';
        testPerson.Last_Name__c = 'Lu' ;
        testPerson.Gender__c = 'Male';
        testPerson.District__c = testDistrict.Id;
        //testPerson.Handset__c = testHandset.Id;
        testPerson.Type__c = 'CKW';
        testPerson.Handset__c = testHandset.Id;
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
        
        
            
        //Create FO
        Mbugo_Field_Officer__c mbugoFO = new Mbugo_Field_Officer__c();
        mbugoFO.Person__c = testFOPerson.Id;
        insert(mbugoFO);

        Mbugo_CKW__c mbugoCkw = new Mbugo_CKW__c();
        mbugoCkw.Mbugo_Field_Officer__c = mbugoFO.Id;
        mbugoCkw.Person__c = testPerson.Id;        
        insert(mbugoCkw);

        Group__c testGroup = new Group__c();
        testGroup.Name = 'Mbugo CKWs';
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
        testOrg.Name = MbugoHelpers.ORG_NAME;
        testOrg.BillingState = 'CA';
        insert testOrg;

        Organisation_District_Association__c orgAssocTest = new Organisation_District_Association__c();
        orgAssocTest.District__c = testDistrict.Id;
        orgAssocTest.Organisation__c = testOrg.Id;
        insert(orgAssocTest);
        
        MbugoDashboardController controller = new MbugoDashboardController();
        //controller.setOrgName(testOrg.Name);
        controller.setUp(resultPage);
        controller.setIsUpdateable('true');

        //Create test surveys
        Survey__c acesurvey = new Survey__c();
        acesurvey.Post_Processing_Method__c = 'MBUGO';
        acesurvey.Survey_Name__c = 'Mbugo ACE';
        acesurvey.Survey_Status__c = 'Published';
        acesurvey.Start_Date__c = Date.valueOf(date.today().year() + '-01-01');
        acesurvey.End_Date__c = Date.valueOf((date.today().year() + 4) + '-01-01');
        insert acesurvey;

        //Create test surveys
        Survey__c vslasurvey = new Survey__c();
        vslasurvey.Post_Processing_Method__c = 'MBUGO';
        vslasurvey.Survey_Name__c = 'Mbugo VSLA';
        vslasurvey.Survey_Status__c = 'Published';
        vslasurvey.Start_Date__c = Date.valueOf(date.today().year() + '-01-01');
        vslasurvey.End_Date__c = Date.valueOf((date.today().year() + 4) + '-01-01');
        insert vslasurvey;

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        List<String> returnValues = new List<String>();
                
        Test.startTest();
        
        List<MetricDataWrapper> wrappers = controller.getFarmersReachedData();
        System.assert(wrappers != null);

        wrappers = controller.getFarmerGroupsData();
        System.assert(wrappers.size() == 4);

        wrappers = controller.getCooperativeGroupsData();
        System.assert(wrappers.size() == 2);
        System.assert(controller.getDistrictList() != null);

        System.assert(controller.getCkwPerfomanceData() != null);
        System.assert(controller.getIsUpdateable().equals('true'));
        System.assert(controller.getSubcountiesList() != null);
        System.assert(controller.changeFilters() != null);

        System.assert(MbugoHelpers.getCKWMapMarkers().size() == 1);
        System.assert(MbugoHelpers.getFOMapMarkers().size() == 1);

        //Test survey post processing
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = testHandset.IMEI__c;
        submission.resultHash = '1';
        submission.surveyId = [select Id, Name from Survey__c where Id = :acesurvey.Id].Name;
        answers.put('q12_0', Utils.createTestSubmissionAnswer(null, 'q12', '3 4', null, null, null));
        
        M_E_Metric_Data__c metricdata = new M_E_Metric_Data__C();
        List < M_E_Metric__C > metr = [select Id, Label__c from M_E_Metric__C where Name = : MbugoHelpers.NUMBER_OF_COOPERATIVES_REGISTERED];
        System.assert(metr.size() == 0);
        M_E_Metric__C tempMetric;
        //If parent metric is not found, attempt to a create it
        System.debug('Mbugo metric ' + MbugoHelpers.NUMBER_OF_COOPERATIVES_REGISTERED + ' not found, create metric');
        tempMetric = new M_E_Metric__C();
        tempMetric.Name = MbugoHelpers.NUMBER_OF_COOPERATIVES_REGISTERED;
        tempMetric.Label__c = MbugoHelpers.NUMBER_OF_COOPERATIVES_REGISTERED.replace('_', ' ');
        insert(tempMetric);
        metricdata.M_E_Metric__c = tempMetric.Id;
        metricdata.Comment__c = tempMetric.Label__c;
        metricdata.Date__c = MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0));
        metricdata.Numerator__c = 0;
        metricdata.Denumerator__c = 0;
        metricdata.Projected_Value__c = 0;
        metricdata.Manual_Value__c = 1;
        insert(metricdata);
        List < M_E_Metric__C > mTest = [select Id, Label__c from M_E_Metric__C where Name = : MbugoHelpers.NUMBER_OF_COOPERATIVES_REGISTERED];
        System.assert(mTest.size() !=0 );
        
        returnValues = MbugoHelpers.surveysPostProcessing(submission, answers, testPerson);   
        System.assert(mTest.size() ==1 );
       // System.assert(returnValues.get(0).equals('0'));
       // System.assert(returnValues.get(1).contains('successful'));
        System.assert(MbugoHelpers.getMetricData(MbugoHelpers.NUMBER_OF_COOPERATIVES_REGISTERED).Manual_Value__c != 0);
        
        M_E_Metric_Data__C metricdata1 = new M_E_Metric_Data__C();
        List < M_E_Metric__C > metr1 = [select Id, Label__c from M_E_Metric__C where Name = : MbugoHelpers.PERCENTAGE_OF_FARMERS_PURCHASING_INPUTS_FROM_MBUGO_ACE];
        System.assert(metr1.size() == 1);
        M_E_Metric__C tempMetric1;
        //If parent metric is not found, attempt to a create it
        System.debug('Mbugo metric ' + MbugoHelpers.PERCENTAGE_OF_FARMERS_PURCHASING_INPUTS_FROM_MBUGO_ACE + ' not found, create metric');
        tempMetric1 = new M_E_Metric__C();
        tempMetric1.Name = MbugoHelpers.PERCENTAGE_OF_FARMERS_PURCHASING_INPUTS_FROM_MBUGO_ACE;
        tempMetric1.Label__c = MbugoHelpers.PERCENTAGE_OF_FARMERS_PURCHASING_INPUTS_FROM_MBUGO_ACE.replace('_', ' ');
        insert(tempMetric1);
        metricdata1.M_E_Metric__c = tempMetric.Id;
        metricdata1.Comment__c = tempMetric.Label__c;
        metricdata1.Date__c = MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0));
        metricdata1.Numerator__c = 0;
        metricdata1.Denumerator__c = 0;
        metricdata1.Projected_Value__c = 0;
        metricdata1.Manual_Value__c = 1;
        insert(metricdata1);
        mTest = [select Id, Label__c from M_E_Metric__C where Name = : MbugoHelpers.PERCENTAGE_OF_FARMERS_PURCHASING_INPUTS_FROM_MBUGO_ACE];
        System.assert(mTest.size() !=0 );
        
        System.assert(MbugoHelpers.getMetricData(MbugoHelpers.PERCENTAGE_OF_FARMERS_PURCHASING_INPUTS_FROM_MBUGO_ACE).Manual_Value__c == 1);
        
        returnValues = MbugoHelpers.surveysPostProcessing(submission, answers, testPerson);        
       // System.assert(returnValues.get(0).equals('1'));
        //System.assert(returnValues.get(1).contains('successful'));
        
        submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = testHandset.IMEI__c;
        submission.resultHash = '1';
        submission.surveyId = [select Id, Name from Survey__c where Id = :vslasurvey.Id].Name;
        answers.put('q24_0', Utils.createTestSubmissionAnswer(null, 'q24', '90', null, null, null));
        answers.put('q22_0', Utils.createTestSubmissionAnswer(null, 'q22', '40', null, null, null));
        answers.put('q23_0', Utils.createTestSubmissionAnswer(null, 'q23', '50', null, null, null));
        
        metricdata = new M_E_Metric_Data__C();
        metr = [select Id, Label__c from M_E_Metric__C where Name = : MbugoHelpers.NUMBER_OF_VSLAS_REGISTERED];
        System.assert(metr.size() == 0);
        //M_E_Metric__C tempMetric;
        //If parent metric is not found, attempt to a create it
        System.debug('Gumutindo metric ' + MbugoHelpers.NUMBER_OF_VSLAS_REGISTERED + ' not found, create metric');
        tempMetric = new M_E_Metric__C();
        tempMetric.Name = MbugoHelpers.NUMBER_OF_VSLAS_REGISTERED;
        tempMetric.Label__c = MbugoHelpers.NUMBER_OF_VSLAS_REGISTERED.replace('_', ' ');
        insert(tempMetric);
        metricdata.M_E_Metric__c = tempMetric.Id;
        metricdata.Comment__c = tempMetric.Label__c;
        metricdata.Date__c = MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0));
        metricdata.Numerator__c = 0;
        metricdata.Denumerator__c = 0;
        metricdata.Projected_Value__c = 0;
        metricdata.Manual_Value__c = 1;
        insert(metricdata);
        mTest = [select Id, Label__c from M_E_Metric__C where Name = : MbugoHelpers.NUMBER_OF_VSLAS_REGISTERED];
        System.assert(mTest.size() !=0 );
        
        System.assert(MbugoHelpers.getMetricData(MbugoHelpers.NUMBER_OF_VSLAS_REGISTERED).Manual_Value__c == 1);
        
        metricdata = new M_E_Metric_Data__C();
        metr = [select Id, Label__c from M_E_Metric__C where Name = : MbugoHelpers.TOTAL_NUMBER_OF_FARMERS_IN_VSLAS];
        System.assert(metr.size() == 0);
        //M_E_Metric__C tempMetric;
        //If parent metric is not found, attempt to a create it
        System.debug('Gumutindo metric ' + MbugoHelpers.TOTAL_NUMBER_OF_FARMERS_IN_VSLAS + ' not found, create metric');
        tempMetric = new M_E_Metric__C();
        tempMetric.Name = MbugoHelpers.TOTAL_NUMBER_OF_FARMERS_IN_VSLAS;
        tempMetric.Label__c = MbugoHelpers.TOTAL_NUMBER_OF_FARMERS_IN_VSLAS.replace('_', ' ');
        insert(tempMetric);
        metricdata.M_E_Metric__c = tempMetric.Id;
        metricdata.Comment__c = tempMetric.Label__c;
        metricdata.Date__c = MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0));
        metricdata.Numerator__c = 0;
        metricdata.Denumerator__c = 0;
        metricdata.Projected_Value__c = 0;
        metricdata.Manual_Value__c = 90;
        insert(metricdata);
        mTest = [select Id, Label__c from M_E_Metric__C where Name = : MbugoHelpers.TOTAL_NUMBER_OF_FARMERS_IN_VSLAS];
        System.assert(mTest.size() !=0 );
        
        System.assert(MbugoHelpers.getMetricData(MbugoHelpers.TOTAL_NUMBER_OF_FARMERS_IN_VSLAS).Manual_Value__c == 90);
        
        metricdata = new M_E_Metric_Data__C();
        metr = [select Id, Label__c from M_E_Metric__C where Name = : MbugoHelpers.TOTAL_NUMBER_OF_MALE_FARMERS_IN_VSLAS];
        System.assert(metr.size() == 0);
        //M_E_Metric__C tempMetric;
        //If parent metric is not found, attempt to a create it
        System.debug('Gumutindo metric ' + MbugoHelpers.TOTAL_NUMBER_OF_MALE_FARMERS_IN_VSLAS + ' not found, create metric');
        tempMetric = new M_E_Metric__C();
        tempMetric.Name = MbugoHelpers.TOTAL_NUMBER_OF_MALE_FARMERS_IN_VSLAS;
        tempMetric.Label__c = MbugoHelpers.TOTAL_NUMBER_OF_MALE_FARMERS_IN_VSLAS.replace('_', ' ');
        insert(tempMetric);
        metricdata.M_E_Metric__c = tempMetric.Id;
        metricdata.Comment__c = tempMetric.Label__c;
        metricdata.Date__c = MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0));
        metricdata.Numerator__c = 0;
        metricdata.Denumerator__c = 0;
        metricdata.Projected_Value__c = 0;
        metricdata.Manual_Value__c = 40;
        insert(metricdata);
        mTest = [select Id, Label__c from M_E_Metric__C where Name = : MbugoHelpers.TOTAL_NUMBER_OF_MALE_FARMERS_IN_VSLAS];
        System.assert(mTest.size() !=0 );
        
        System.assert(MbugoHelpers.getMetricData(MbugoHelpers.TOTAL_NUMBER_OF_MALE_FARMERS_IN_VSLAS).Manual_Value__c == 40);
        
        metricdata = new M_E_Metric_Data__C();
        metr = [select Id, Label__c from M_E_Metric__C where Name = : MbugoHelpers.TOTAL_NUMBER_OF_FEMALE_FARMERS_IN_VSLAS];
        System.assert(metr.size() == 0);
        //M_E_Metric__C tempMetric;
        //If parent metric is not found, attempt to a create it
        System.debug('Gumutindo metric ' + MbugoHelpers.TOTAL_NUMBER_OF_FEMALE_FARMERS_IN_VSLAS + ' not found, create metric');
        tempMetric = new M_E_Metric__C();
        tempMetric.Name = MbugoHelpers.TOTAL_NUMBER_OF_FEMALE_FARMERS_IN_VSLAS;
        tempMetric.Label__c = MbugoHelpers.TOTAL_NUMBER_OF_FEMALE_FARMERS_IN_VSLAS.replace('_', ' ');
        insert(tempMetric);
        metricdata.M_E_Metric__c = tempMetric.Id;
        metricdata.Comment__c = tempMetric.Label__c;
        metricdata.Date__c = MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0));
        metricdata.Numerator__c = 0;
        metricdata.Denumerator__c = 0;
        metricdata.Projected_Value__c = 0;
        metricdata.Manual_Value__c = 50;
        insert(metricdata);
        mTest = [select Id, Label__c from M_E_Metric__C where Name = : MbugoHelpers.TOTAL_NUMBER_OF_FEMALE_FARMERS_IN_VSLAS];
        System.assert(mTest.size() !=0 );
        
        System.assert(MbugoHelpers.getMetricData(MbugoHelpers.TOTAL_NUMBER_OF_FEMALE_FARMERS_IN_VSLAS).Manual_Value__c == 50);
        
        Test.stopTest();
    }
   

}