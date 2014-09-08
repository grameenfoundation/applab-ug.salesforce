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
}