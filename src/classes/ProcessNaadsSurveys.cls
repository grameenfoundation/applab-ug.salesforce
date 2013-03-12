public with sharing class ProcessNaadsSurveys {

    /**
     * A class to deal with NAADs surveys
     */
     
     /**
     *  Fill in the Naads_Baseline_Info objects for this ASP
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param person     - The Person__c object who submitted the form
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the CKW if required.
     */
     public static List<String>  processNaadsBaselineSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {

         List<String> metricNames = new List<String> {
         'Percentage_of_beneficiaries_satisfied_with_advisory_services',
         'Percentage_of_farmers_noticing_improvement_in_NAADS_extension_services',
         'Percentage_of_farmers_reporting_a_feedback_channel_for_NAADS',
         'Percentage_of_farmers_satisfied_with_feedback_channel_for_NAADS',
         'Percentage_of_beneficiaries_perceiving_involvement_in_group_decision_making'
         };     

         Subcounty__c subcounty = [Select Id from Subcounty__c where Display_Name__c =:subcountyMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q3_0')))];
         String subcountyId = subcounty.Id;

         boolean satisfiedWithReportingFeedback = false;
         boolean voiceTakenIntoAccount = false;
         boolean belongsToNaadsFarmerGroup = ProcessSubmissionHelpers.checkIfYes(ProcessSubmissionHelpers.getAnswerString(answers.get('q32_0')));
         boolean attendsTraining = ProcessSubmissionHelpers.checkIfYes(ProcessSubmissionHelpers.getAnswerString(answers.get('q41_0')));
         boolean hasSomewhereToReport = ProcessSubmissionHelpers.checkIfYes(ProcessSubmissionHelpers.getAnswerString(answers.get('q60_0')));
         boolean isNAADSBeneficiary = ProcessSubmissionHelpers.checkIfYes(ProcessSubmissionHelpers.getAnswerString(answers.get('q37_0')));
         boolean satisfiedWithNaadsServices = servicesSatisfactionMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q71_0')));
         if (hasSomewhereToReport) {
             satisfiedWithReportingFeedback = servicesSatisfactionMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q67_0')));
         }
         if (belongsToNaadsFarmerGroup ) {
             voiceTakenIntoAccount = servicesSatisfactionMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q50_0')));
         }

         DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
         Date currentDate = handsetSubmitTime.date();

         M_E_Metric_Data__c[] datas = [
             SELECT
                 Id,
                 Name,
                 Real_Value__c,
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
                 (
                     Subcounty__c = :subcounty.Id
                 )
             AND Date__c >= :currentDate
             AND M_E_Metric__r.Name IN :metricNames
        ];
        if (datas == null || datas.isEmpty()) {
            for (String metricName : metricNames) {
                M_E_Metric_Data__c mData = createNewMetricData(metricName, currentDate, subcounty.Id);
                datas.add(mdata);
            }
        }

        // Loop through the data and see which ones we have already got. If they are not there already create them
        Map<String, M_E_Metric_Data__c> dataMap = new Map<String, M_E_Metric_Data__c>();
        for (M_E_Metric_Data__c mData : datas) {  
             dataMap.put(mData.M_E_Metric__r.Name, mData);
        }

        // Loop through the list of metrics and check that they all exist and then update them
        for (String key : metricNames) {

            // Check that the three metrics for each metric name exists
            M_E_Metric_Data__c totalNewData = dataMap.get(key);
            system.debug('Checking for metric name: ' + key);
            if (totalNewData == null) {
                totalNewData = createNewMetricData(key, currentDate, subcounty.Id);
            }
            Decimal farmerCount = 0.0;

            // Update the metric based on the key
            if (key.equals('Percentage_of_beneficiaries_perceiving_involvement_in_group_decision_making') ) {
                 totalNewData.Denumerator__c += 1;
                 if (voiceTakenIntoAccount) {
                     totalNewData.Numerator__c += 1;
                 }
                 totalNewData.Actual_Value__c = 100*(totalNewData.Numerator__c/totalNewData.Denumerator__c);
            }
            else if (key.equals('Percentage_of_beneficiaries_satisfied_with_advisory_services')) {
                 totalNewData.Denumerator__c += 1;
                 if (satisfiedWithNaadsServices) {
                     totalNewData.Numerator__c += 1;
                 }
                 totalNewData.Actual_Value__c = 100*(totalNewData.Numerator__c/totalNewData.Denumerator__c);
            }
            else if (key.equals('Percentage_of_farmers_noticing_improvement_in_NAADS_extension_services')) {
                 totalNewData.Denumerator__c += 1;
                 if (satisfiedWithNaadsServices) {
                     totalNewData.Numerator__c += 1;
                 }
                 totalNewData.Actual_Value__c = 100*(totalNewData.Numerator__c/totalNewData.Denumerator__c);
            }
            else if (key.equals('Percentage_of_farmers_reporting_a_feedback_channel_for_NAADS')) {
                 totalNewData.Denumerator__c+= 1;
                 if (hasSomewhereToReport) {
                     totalNewData.Numerator__c += 1;
                 }
                 totalNewData.Actual_Value__c = 100*(totalNewData.Numerator__c/totalNewData.Denumerator__c);
            }
            else if (key.equals('Percentage_of_farmers_satisfied_with_feedback_channel_for_NAADS')) {
                 totalNewData.Denumerator__c+= 1;
                 if (satisfiedWithReportingFeedback) {
                     totalNewData.Numerator__c += 1;
                 }
                 totalNewData.Actual_Value__c = 100*(totalNewData.Numerator__c/totalNewData.Denumerator__c);
            }
            dataMap.put(key, totalNewData);
        }
        List<Database.upsertResult> uResults = Database.upsert(dataMap.values());
        for(Database.upsertResult result : uResults) {
            if (result.isSuccess()) {
                system.debug('succeeded ' + result.getId());
            }
            else {
                for (Database.Error error : result.getErrors()) {
                    system.debug('Error: ' + error.getMessage()); 
                }
                return new String[] { '0', 'Error in submission', 'SUPRESSMSG' };
            }
        }
        return new String[] { '1', 'Naads baseline visit processed successfully', 'SUPRESSMSG' };
     }
     
     private static Map<String, String> subcountyMap = new Map<String, String> {
     
        '1' => 'Kateta',
        '2' => 'Kyere',
        '3' => 'Olio',
        '4' => 'Bugondo',
        '5' => 'Pingire',
        '6' => 'Kadungulu',
        '7' => 'Atiira',
        '8' => 'Labori',
        '9' => 'Serere Town Council',
        '10' => 'Kasilo Town council'     
     };
     
     private static Map<String, Boolean> servicesSatisfactionMap = new Map<String, Boolean> {
     
        '1' => true,
        '2' => true,
        '3' => true,
        '4' => false,
        '5' => false,
        '6' => false     
     };
     
     private static Map<String, String> voiceConsideredMap = new Map<String, String> {
     
        '1' => 'Strongly agree',
        '2' => 'Agree',
        '3' => 'Somewhat agree',
        '4' => 'Somewhat disagree',
        '5' => 'Disagree',
        '6' => 'Strongly disagree' 
     };

     /**
     *  Fill in the Naads_Baseline_Info objects for this ASP
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param person     - The Person__c object who submitted the form
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the CKW if required.
     */
     public static List<String> processAdvisoryServiceSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {        
         
         List<String> metricNames = new List<String> {
         'Farmer_group_trainings_meetings_or_attended',
         'Number_of_farmer_supervisory_visits_conducted', 
         'Number_of_farmers_attending_group_trainings_meetings'
         };

         String subcountyName = advisorySubcountyMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q3_0')));
         System.debug('subcounty '+subcountyName);
         Decimal farmerCount = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q19_0'), 'q19_0', true);
         String visitType = ProcessSubmissionHelpers.getAnswerString(answers.get('q1_0'));
         Subcounty__c subcounty = [Select Id from Subcounty__c where Display_Name__c =:subcountyName];
         DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
         Date currentDate = handsetSubmitTime.date();
         
         Naads_Advisory_Form_Metrics__c naadsMetric = new Naads_Advisory_Form_Metrics__c();
         naadsMetric.Subcounty__c = subcountyName;
         naadsMetric.Person__c = person.Id;
         naadsMetric.Type__c = visitType;
         naadsMetric.Visit_Date__c = ProcessSubmissionHelpers.getAnswerDate(answers.get('q6_0'), currentDate);
         database.insert(naadsMetric);

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
                 (
                     Subcounty__c = :subcounty.Id
                 )
             AND Date__c >= :currentDate
             AND M_E_Metric__r.Name IN (
                     'Farmer_group_trainings_meetings_or_attended',
                     'Number_of_farmer_supervisory_visits_conducted',
                     'Number_of_farmers_attending_group_trainings_meetings')
        ];
        if (datas == null || datas.isEmpty()) {
            for (String metricName : metricNames) {
                M_E_Metric_Data__c mData = createNewMetricData(metricName, currentDate, subcounty.Id);
                datas.add(mdata);
            }
        }
        
        // Loop through the data and see which ones we have already got. If they are not there already create them
        Map<String, M_E_Metric_Data__c> dataMap = new Map<String, M_E_Metric_Data__c>();
        for (M_E_Metric_Data__c mData : datas) {
             dataMap.put(mData.M_E_Metric__r.Name, mData);
        }

        // Loop through the list of metrics and check that they all exist and then update them
        for (String key : metricNames) {

            // Check that the three metrics for each metric name exists
            M_E_Metric_Data__c totalNewData = dataMap.get(key);
            system.debug('Checking for metric name: ' + key);
            if (totalNewData == null) {
                totalNewData = createNewMetricData(key, currentDate, subcounty.Id);
            }

            // Update the metric based on the key
            if (key.equals('Farmer_group_trainings_meetings_or_attended') && visitType == '2') {
                 totalNewData.Denumerator__c += 1;
                 totalNewData.Actual_Value__c = totalNewData.Denumerator__c;
            }
            else if (key.equals('Number_of_farmer_supervisory_visits_conducted') && visitType == '3') {
                 totalNewData.Denumerator__c+= 1;
                 totalNewData.Actual_Value__c = totalNewData.Denumerator__c;
            }
            else if (key.equals('Number_of_farmers_attending_group_trainings_meetings') && visitType == '2') {
                 totalNewData.Denumerator__c += farmerCount;
                 totalNewData.Actual_Value__c = totalNewData.Denumerator__c;
            }
            dataMap.put(key, totalNewData);
        }
        List<Database.upsertResult> uResults = Database.upsert(dataMap.values());
        for(Database.upsertResult result : uResults) {
            if (result.isSuccess()) {
                system.debug('succeeded ' + result.getId());
            }
            else {
                for (Database.Error error : result.getErrors()) {
                    system.debug('Error: ' + error.getMessage());
                }
                return new String[] { '0', 'Error in submission', 'SUPRESSMSG' };
            }
        }
        return new String[] { '1', 'Naads baseline visit processed successfully', 'SUPRESSMSG' };
     }

     private static Map<String, String> advisorySubcountyMap = new Map<String, String> {
     
        '1' => 'Atiira',
        '2' => 'Kadungulu',
        '3' => 'Pingire',
        '4' => 'Olio',
        '5' => 'Bugondo',
        '6' => 'Kateta',
        '7' => 'Kyere',
        '8' => 'Labori',
        '9' => 'Serere Town Council',
        '10' => 'Kasilo Town council'     
     };
     
    /**
     *  Create a new metric data for a given person, start date and metric. Assume that the metric is created on the box
     *
     *  @param key       - The M_E_Metric.Name value that is being created
     *  @param startDate - The date that the metric period starts
     *  @param subcountyId   - The divider that the metric is split by
     *
     *  @return - The newly created M_E_Metric_Data object
     */
     private static M_E_Metric_Data__c createNewMetricData(String key, Date startDate, String subcountyId) {

         M_E_Metric__c[] metrics = MetricHelpers.getMetrics(key, null);
         M_E_Metric__c metric = metrics[0];

         M_E_Metric_Data__c mData = new M_E_Metric_Data__c();
         mData.Subcounty__c = subcountyId;

         mData.Numerator__c = 0.0;
         mData.Denumerator__c = 0.0;
         mData.Manual_Value__c = 0.0;
         mData.Is_Cumulative__c = false;
         mData.Date__c = startDate;
         mData.M_E_Metric__c = metric.Id;
         mData.Projected_Value__c = metric.Projected_Value__c;
         return mData;
     }
    
     static testMethod void testProcessNaadsBaselineSurvey() {

        Account testAccount = new Account();
        testAccount.BillingState = 'CA';
        testAccount.Name = 'TestOrg'; 
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
            
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q6_0', Utils.createTestSubmissionAnswer(null, 'q6', 'Suker', null, null, null));
        answers.put('q5_0', Utils.createTestSubmissionAnswer(null, 'q5', 'Parish', null, null, null));
        answers.put('q4_0', Utils.createTestSubmissionAnswer(null, 'q4', 'Village', null, null, null));
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
        returnValues = processNaadsBaselineSurvey(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));
     }
     
     static testMethod void testProcessAdvisoryServiceSurvey() {
     
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
        testAccount.Name = 'TestOrg'; 
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
        
        // Test Farmer group training
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', '2', null, null, null));
        answers.put('q19_0', Utils.createTestSubmissionAnswer(null, 'q19', '9', null, null, null));
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', '6', null, null, null));
        List<String> returnValues = new List<String>();
        returnValues = processAdvisoryServiceSurvey(submission, answers, person);         
        System.assert(returnValues.get(0).equals('1'));
         
        // Test Supervisory visiting report
        Map<String, Submission_Answer__c> supervisoryAnswers = new Map<String, Submission_Answer__c>();
        supervisoryAnswers .put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', '3', null, null, null));
        supervisoryAnswers .put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', '6', null, null, null));
        returnValues = processAdvisoryServiceSurvey(submission, supervisoryAnswers, person);         
        System.assert(returnValues.get(0).equals('1'));
     }
}