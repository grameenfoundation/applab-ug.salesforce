/**
 * A class to deal with NAADs surveys
 */
public with sharing class ProcessNaadsSurveys {
    
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
            'Farmer_group_trainings_meetings_or_attended',
            'Number_of_farmer_supervisory_visits_conducted', 
            'Number_of_farmers_attending_group_trainings_meetings'
        };

        
        Subcounty__c subcounty = [Select Id from Subcounty__c where Display_Name__c = :naadsBaselineSubcountyMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q3_0')))];
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
                Subcounty__c = :subcounty.Id
            AND 
                 Date__c = :currentDate
            AND 
                M_E_Metric__r.Name 
            IN :metricNames
        ];
        if (datas == null) {
        datas = new M_E_Metric_Data__c[]{};
            for (String metricName : metricNames) {
                M_E_Metric_Data__c mData = MetricHelpers.createNewMetric(metricName, currentDate, 0.0, null, null, subcounty.Id, 'NAADS', true);
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
                totalNewData = MetricHelpers.createNewMetric(key, currentDate, 0.0, null, null, subcounty.Id, 'NAADS', true);
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
    
     // Map containing Subcounties of Serere district as they appear in the baseline survey
     private static Map<String, String> naadsBaselineSubcountyMap = new Map<String, String> {

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
             'Percentage_of_beneficiaries_satisfied_with_advisory_services',
             'Percentage_of_farmers_noticing_improvement_in_NAADS_extension_services',
             'Percentage_of_farmers_reporting_a_feedback_channel_for_NAADS',
             'Percentage_of_farmers_satisfied_with_feedback_channel_for_NAADS',
             'Percentage_of_beneficiaries_perceiving_involvement_in_group_decision_making'
         };

         String subcountyName = advisorySubcountyMap.get(ProcessSubmissionHelpers.getAnswerString(answers.get('q3_0')));
         System.debug('subcounty '+subcountyName);
         Decimal farmerCount = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q19_0'), 'q19_0', true);
         String visitType = ProcessSubmissionHelpers.getAnswerString(answers.get('q1_0'));
         Subcounty__c subcounty = [Select Id from Subcounty__c where Display_Name__c =:subcountyName];
         DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
         Date currentDate = handsetSubmitTime.date();
         
         Date visitDate = ProcessSubmissionHelpers.getAnswerDate(answers.get('q6_0'), currentDate);
         Naads_Asp_Daily_Visit_Metric__c naadsMetric = getNaadsAspDailyVisitMetric(visitDate);
         if (naadsMetric == null) {
             naadsMetric = new Naads_Asp_Daily_Visit_Metric__c();
             naadsMetric.Visit_Date__c = currentDate;
             naadsMetric.Person__c = person.Id;
             naadsMetric.Subcounty__c = subcountyName;
             naadsMetric.Supervisory_Visit_Count__c = 0;
             naadsMetric.Group_Trainings_Count__c = 0;
             naadsMetric.Monthly_Visit_Count__c = 0;
             naadsMetric.Attendance_Sheet_Count__c = 0;
         }
         if (visitType == '1') {
             naadsMetric.Monthly_Visit_Count__c += 1;
         }
         else if (visitType == '2') {
             naadsMetric.Group_Trainings_Count__c += 1;
         }
         else if (visitType == '3') {
             naadsMetric.Supervisory_Visit_Count__c += 1;
         }
         else {
             naadsMetric.Attendance_Sheet_Count__c += 1;
         }
         database.upsert(naadsMetric);

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
                 Subcounty__c = :subcounty.Id
             AND 
                 Date__c = :currentDate
             AND 
                 M_E_Metric__r.Name 
             IN :metricNames
        ];
        if (datas == null) {
            datas = new M_E_Metric_Data__c[]{};
            for (String metricName : metricNames) {
                M_E_Metric_Data__c mData = MetricHelpers.createNewMetric(metricName, currentDate, 0.0, null, null, subcounty.Id, 'NAADS', true);
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
                totalNewData = MetricHelpers.createNewMetric(key, currentDate, 0.0, null, null, subcounty.Id, 'NAADS', true);
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
    
    // Map containing Subcounties of Serere district as they appear in the advisory services survey
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
   
    private static Naads_Asp_Daily_Visit_Metric__c getNaadsAspDailyVisitMetric(Date visitDate) {

        Naads_Asp_Daily_Visit_Metric__c[] aspVisitMetrics = [SELECT Id,
                                                                    Person__c,
                                                                    Subcounty__c,
                                                                    Visit_Date__c,
                                                                    Group_Trainings_Count__c,
                                                                    Monthly_Visit_Count__c,
                                                                    Supervisory_Visit_Count__c,
                                                                    Attendance_Sheet_Count__c
                                                            FROM
                                                                    Naads_Asp_Daily_Visit_Metric__c
                                                            WHERE
                                                                    Visit_Date__c = :visitDate];

        if (aspVisitMetrics.isEmpty()) {
            return null;
        }
        else {
            return aspVisitMetrics[0];
        }
    }

}