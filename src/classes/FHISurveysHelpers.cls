public with sharing class FHISurveysHelpers {

    public static Map<String, M_E_Metric__c> metricMap = new Map<String, M_E_Metric__c>();

    /**
     *  Class that deals with all FHI 360 surveys processing
     */

    /**
     *  Process the group registration survey submission and create the metrics for the data validators
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                          The keys are <binding>_<instance> for compatibility
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the submitter if required.
     */

    public static List<String> processGroupRegistration(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers,  Person__c submitter, String surveyName) {
        
        boolean isNorth = true;
        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
        }
        
        if (surveyName.contains('South') || surveyName.contains('south')) {
            isNorth = false;
        }
        //Commented out to save space
        //createSubmissionMetaData(submission, submitter);

        // Dig out the values that are to be added to the metrics
        String registrationDate = answers.get('q1_0').Answer__c;
        System.debug('Registration date: ' + registrationDate);
        
        String districtValue = answers.get('q3_0').Answer__c;
        String districtName = translateDistrictName(districtValue, isNorth);
        System.debug('District: ' + districtName);
        
        String subcountyName = '';
        if (isNorth) {
            subcountyName = translateNorthernSubcountyName(answers, districtValue);
        }
        else {
            subcountyName = translateSouthernSubcountyName(answers, districtValue);
        }
        System.debug('Subcounty: ' + subcountyName);
        
        String groupType = isNorth ? translateGroupType(answers, answers.get('q41_0').Answer__c) : translateGroupType(answers, answers.get('q32_0').Answer__c);
        System.debug('Group Type: ' + groupType);
        
        Decimal malesInGroup = isNorth? getAnswerNumber(answers.get('q43_0'), 'q43_0', true) : getAnswerNumber(answers.get('q34_0'), 'q34_0', true);
        System.debug('Males in group: ' + String.valueOf(malesInGroup));
        
        Decimal femalesInGroup = isNorth ? getAnswerNumber(answers.get('q44_0'), 'q44_0', true) : getAnswerNumber(answers.get('q35_0'), 'q35_0', true);
        System.debug('Females in group: ' + String.valueOf(femalesInGroup));
        
        Decimal malesInLeadership = isNorth ? getAnswerNumber(answers.get('q45_0'), 'q45_0', true) : getAnswerNumber(answers.get('q36_0'), 'q36_0', true);
        System.debug('Males in leadership: ' + String.valueOf(malesInLeadership));
        
        Decimal femalesInLeadership = isNorth ? getAnswerNumber(answers.get('q46_0'), 'q46_0', true) : getAnswerNumber(answers.get('q37_0'), 'q37_0', true);
        System.debug('Females in leadership: ' + String.valueOf(femalesInLeadership));
        
        String hasBankAccount = isNorth ? translateHasBankAccount(answers.get('q53_0').Answer__c) : translateHasBankAccount(answers.get('q44_0').Answer__c);
        System.debug('Bank Account: ' + hasBankAccount);
        
        Set<String> groupActivities = isNorth ? getGroupActivities(answers, getAnswerSet(answers.get('q64_0'))) : getGroupActivities(answers, getAnswerSet(answers.get('q50_0')));
        for(String activity : groupActivities) {
            System.debug('group activities: ' + activity);
        }
        
        District__c district = [
            SELECT
                Id
            FROM
                District__c
            WHERE
                Name = :districtName
            LIMIT 1
        ];
        
        Subcounty__c subcounty = [
            SELECT
                Id
            FROM
                Subcounty__c
            WHERE
                Display_Name__c = :subcountyName
            LIMIT 1
        ];
        
        String districtId = district.Id;
        system.debug('district id ' + districtId);
        String subcountyId = subcounty.Id;
        system.debug('subcounty id ' + subcountyId);
        
        // Load the metrics for the month that the submission is for
        List<String> metricNames = new List<String> { 
            'FHI_CC_groups_activity_agriculture', 
            'FHI_CC_groups_activity_food_security', 
            'FHI_CC_groups_activity_functional_literacy', 
            'FHI_CC_groups_activity_hiv',
            'FHI_CC_groups_activity_merry',
            'FHI_CC_groups_activity_nutrition',
            'FHI_CC_groups_activity_other',
            'FHI_CC_groups_activity_savings',
            'FHI_CC_groups_with_bank_accounts',
            'FHI_CC_number_elderly_groups',
            'FHI_CC_number_groups_registered',
            'FHI_CC_number_hiv_groups',
            'FHI_CC_number_men_groups',
            'FHI_CC_number_mixed_groups',
            'FHI_CC_number_women_groups',
            'FHI_CC_number_youth_groups',
            'FHI_CC_percentage_female_in_groups',
            'FHI_CC_percentage_female_leadership'
            };
        
        Date startDate = handsetSubmitTime.date().toStartOfMonth();
        Date endDate = handsetSubmitTime.date().toStartOfMonth().addMonths(1).addDays(-1);
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
                    District__c = :districtId
                    AND Subcounty__c = :subcountyId
                )
                AND Date__c >= :startDate
                AND Date__c <= :endDate
                AND M_E_Metric__r.Name IN (
                    'FHI_CC_groups_activity_agriculture', 
                    'FHI_CC_groups_activity_food_security', 
                    'FHI_CC_groups_activity_functional_literacy', 
                    'FHI_CC_groups_activity_hiv',
                    'FHI_CC_groups_activity_merry',
                    'FHI_CC_groups_activity_nutrition',
                    'FHI_CC_groups_activity_other',
                    'FHI_CC_groups_activity_savings',
                    'FHI_CC_groups_with_bank_accounts',
                    'FHI_CC_number_elderly_groups',
                    'FHI_CC_number_groups_registered',
                    'FHI_CC_number_hiv_groups',
                    'FHI_CC_number_men_groups',
                    'FHI_CC_number_mixed_groups',
                    'FHI_CC_number_women_groups',
                    'FHI_CC_number_youth_groups',
                    'FHI_CC_percentage_female_in_groups',
                    'FHI_CC_percentage_female_leadership')
        ];

        // Loop through the data and see which ones we have already got. If they are not there already create them
        Map<String, M_E_Metric_Data__c> dataMap = new Map<String, M_E_Metric_Data__c>();
        for (M_E_Metric_Data__c mData : datas) {
            
             dataMap.put(mData.M_E_Metric__r.Name, mData);system.debug('METRIC NAME '+ mData.M_E_Metric__r.Name);
        }

        // Loop through the list of metrics and check that they all exist and then update them
        for (String key : metricNames) {

            // Check that the three metrics for each metric name exists
            M_E_Metric_Data__c totalNewData = dataMap.get(key);
            system.debug('Checking for metric name: ' + key);
            if (totalNewData == null) {
                totalNewData = createNewMetric(key, startDate, subcountyId, districtId);
            }
            system.debug('Actual Value ' + totalNewData.Actual_Value__c);
            // Update the metric based on the key
            if (key.equals('FHI_CC_number_groups_registered')) {
                    totalNewData.Denumerator__c = 100;
                    totalNewData.Numerator__c++;          
            }
            else if (key.equals('FHI_CC_groups_activity_agriculture')) {
                if (groupActivities.contains('Animal production')  || groupActivities.contains('Crop production')) {
                     totalNewData.Denumerator__c = 100;
                    totalNewData.Numerator__c++;
                }               
            }
            else if (key.equals('FHI_CC_groups_activity_food_security')) {
                if (groupActivities.contains('Food security')) {
                     totalNewData.Denumerator__c = 100;
                    totalNewData.Numerator__c++;
                }            
            }
            else if (key.equals('FHI_CC_groups_activity_functional_literacy')) {
                if (groupActivities.contains('Functional Adult Literacy')) {
                    totalNewData.Denumerator__c = 100;
                    totalNewData.Numerator__c++;
                }               
            }
            else if (key.equals('FHI_CC_groups_activity_hiv')) {
                 if (groupActivities.contains('HIV/AIDS activities')) {
                     totalNewData.Denumerator__c = 100;
                     totalNewData.Numerator__c++;
                }                
            }
            else if (key.equals('FHI_CC_groups_activity_merry')) {
                if (groupActivities.contains('Merry go-round')) {
                     totalNewData.Denumerator__c = 100;
                     totalNewData.Numerator__c++;
                }                 
            }
            else if (key.equals('FHI_CC_groups_activity_nutrition')) {
                 if (groupActivities.contains('Nutrition')) {
                     totalNewData.Actual_Value__c++;
                }                
            }
            else if (key.equals('FHI_CC_groups_activity_other')) {
               if (groupActivities.contains('Other')) {
                     totalNewData.Denumerator__c = 100;
                     totalNewData.Numerator__c++;
                }                
            }
            else if (key.equals('FHI_CC_groups_activity_savings')) {
                if (groupActivities.contains('Savings/VSLA')) {
                     totalNewData.Denumerator__c = 100;
                     totalNewData.Numerator__c++;
                }               
            }
            else if (key.equals('FHI_CC_groups_with_bank_accounts')) {
                if (hasBankAccount.equals('Yes')) {
                     totalNewData.Denumerator__c = 100;
                     totalNewData.Numerator__c++;
                }
                totalNewData.Denumerator__c++;
            }
            else if (key.equals('FHI_CC_number_elderly_groups')) {
                if (groupType.equals('Elderly')) {
                     totalNewData.Denumerator__c = 100;
                     totalNewData.Numerator__c++;
                }               
            }
            else if (key.equals('FHI_CC_number_hiv_groups')) {
                if (groupType.equals('PLHIV')) {
                     totalNewData.Denumerator__c = 100;
                     totalNewData.Numerator__c++;
                }               
            }
             else if (key.equals('FHI_CC_number_men_groups')) {
                if (groupType.equals('Men Only')) {
                     totalNewData.Actual_Value__c++;
                }               
            }
             else if (key.equals('FHI_CC_number_mixed_groups')) {
                if (groupType.equals('Mixed Group')) {
                     totalNewData.Denumerator__c = 100;
                     totalNewData.Numerator__c++;
                }              
            }
             else if (key.equals('FHI_CC_number_women_groups')) {
                if (groupType.equals('Women Only') || groupType.equals('Women group with males')) {
                     totalNewData.Denumerator__c = 100;
                     totalNewData.Numerator__c++;
                }            
            }
            else if (key.equals('FHI_CC_number_youth_groups')) {
                if (groupType.equals('Youth')) {
                     totalNewData.Denumerator__c = 100;
                     totalNewData.Numerator__c++;
                }               
            }
            else if (key.equals('FHI_CC_percentage_female_in_groups')) {
                    totalNewData.Numerator__c += femalesInGroup;
                     totalNewData.Denumerator__c += femalesInGroup + malesInGroup;
            }
            else if (key.equals('FHI_CC_percentage_female_leadership')) {
                    totalNewData.Numerator__c += femalesInLeadership;
                    totalNewData.Denumerator__c += femalesInLeadership + malesInLeadership;           
            }
            system.debug('Actual Value '+ totalNewData.Actual_Value__c);
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
            }
        }
        return new String[] { '1', 'All metric data updated for FHI Dashboard  with IMEI: ' + submission.imei, 'SUPRESSMSG' };
        //return new List<String>();
    }
    
    public static List<String> processHouseholdRegistration(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers,  Person__c submitter, String surveyName) {
        
        boolean isNorth = true;
        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
        }
        
        if (surveyName.contains('South') || surveyName.contains('south')) {
            isNorth = false;
        }
        //Commented out to save space
        //createSubmissionMetaData(submission, submitter);

        // Dig out the values that are to be added to the metrics
        String registrationDate = answers.get('q1_0').Answer__c;
        System.debug('Registration date: ' + registrationDate);
        
        String districtValue = answers.get('q3_0').Answer__c;
        String districtName = translateDistrictName(districtValue, isNorth);
        System.debug('District: ' + districtName);
        
        String subcountyName = '';
        if (isNorth) {
            subcountyName = translateNorthernSubcountyNameReg(answers, districtValue);
        }
        else {
            subcountyName = translateSouthernSubcountyNameReg(answers, districtValue);
        }
        System.debug('Subcounty: ' + subcountyName);
        
        /*String groupType = isNorth ? translateGroupType(answers, answers.get('q41_0').Answer__c) : translateGroupType(answers, answers.get('q32_0').Answer__c);
        System.debug('Group Type: ' + groupType);
        
        Decimal malesInGroup = isNorth? getAnswerNumber(answers.get('q43_0'), 'q43_0', true) : getAnswerNumber(answers.get('q34_0'), 'q34_0', true);
        System.debug('Males in group: ' + String.valueOf(malesInGroup));
        
        Decimal femalesInGroup = isNorth ? getAnswerNumber(answers.get('q44_0'), 'q44_0', true) : getAnswerNumber(answers.get('q35_0'), 'q35_0', true);
        System.debug('Females in group: ' + String.valueOf(femalesInGroup));
        
        Decimal malesInLeadership = isNorth ? getAnswerNumber(answers.get('q45_0'), 'q45_0', true) : getAnswerNumber(answers.get('q36_0'), 'q36_0', true);
        System.debug('Males in leadership: ' + String.valueOf(malesInLeadership));
        
        Decimal femalesInLeadership = isNorth ? getAnswerNumber(answers.get('q46_0'), 'q46_0', true) : getAnswerNumber(answers.get('q37_0'), 'q37_0', true);
        System.debug('Females in leadership: ' + String.valueOf(femalesInLeadership));
        
        String hasBankAccount = isNorth ? translateHasBankAccount(answers.get('q53_0').Answer__c) : translateHasBankAccount(answers.get('q44_0').Answer__c);
        System.debug('Bank Account: ' + hasBankAccount);
        
        Set<String> groupActivities = isNorth ? getGroupActivities(answers, getAnswerSet(answers.get('q64_0'))) : getGroupActivities(answers, getAnswerSet(answers.get('q50_0')));
        for(String activity : groupActivities) {
            System.debug('group activities: ' + activity);
        } */
        
        District__c district = [
            SELECT
                Id
            FROM
                District__c
            WHERE
                Name = :districtName
            LIMIT 1
        ];
        
        Subcounty__c subcounty = [
            SELECT
                Id
            FROM
                Subcounty__c
            WHERE
                Display_Name__c = :subcountyName
            LIMIT 1
        ];
        
        String districtId = district.Id;
        system.debug('district id ' + districtId);
        String subcountyId = subcounty.Id;
        system.debug('subcounty id ' + subcountyId);
        
        // Load the metrics for the month that the submission is for
        List<String> metricNames = new List<String> { 
            'FHI_HH_number_children_under_five',
            'FHI_HH_number_households_registered',
            'FHI_HH_number_pregnant_women',
            'FHI_HH_number_women_family_planning',
            'FHI_HH_percentage_access_credit',
            'FHI_HH_percentage_access_toilet',
            'FHI_HH_percentage_belong_group',
            'FHI_HH_percentage_children_under_five',
            'FHI_HH_percentage_pregnant_women',
            'FHI_HH_percentage_with_disabled'
            };
        
        Date startDate = handsetSubmitTime.date().toStartOfMonth();
        Date endDate = handsetSubmitTime.date().toStartOfMonth().addMonths(1).addDays(-1);
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
                    District__c = :districtId
                    AND Subcounty__c = :subcountyId
                )
                AND Date__c >= :startDate
                AND Date__c <= :endDate
                AND M_E_Metric__r.Name IN (
                      'FHI_HH_number_children_under_five',
                      'FHI_HH_number_households_registered',
                      'FHI_HH_number_pregnant_women',
                      'FHI_HH_number_women_family_planning',
                      'FHI_HH_percentage_access_credit',
                      'FHI_HH_percentage_access_toilet',
                      'FHI_HH_percentage_belong_group',
                      'FHI_HH_percentage_children_under_five',
                      'FHI_HH_percentage_pregnant_women',
                      'FHI_HH_percentage_with_disabled')
        ];

        // Loop through the data and see which ones we have already got. If they are not there already create them
        Map<String, M_E_Metric_Data__c> dataMap = new Map<String, M_E_Metric_Data__c>();
        for (M_E_Metric_Data__c mData : datas) {
            
             dataMap.put(mData.M_E_Metric__r.Name, mData);system.debug('METRIC NAME '+ mData.M_E_Metric__r.Name);
        }

        // Loop through the list of metrics and check that they all exist and then update them
        for (String key : metricNames) {

            // Check that the three metrics for each metric name exists
            M_E_Metric_Data__c totalNewData = dataMap.get(key);
            system.debug('Checking for metric name: ' + key);
            if (totalNewData == null) {
                totalNewData = createNewMetric(key, startDate, subcountyId, districtId);
            }
            system.debug('Actual Value ' + totalNewData.Actual_Value__c);
            // Update the metric based on the key
            if (key.equals('FHI_HH_number_children_under_five')) {
                 totalNewData.Denumerator__c = 100;
                 totalNewData.Numerator__c = totalNewData.Numerator__c + 3;          
            }
            else if (key.equals('FHI_HH_number_households_registered')) {
                 totalNewData.Denumerator__c = 100;
                 totalNewData.Numerator__c++;               
            }
            else if (key.equals('FHI_HH_number_pregnant_women')) {
                 totalNewData.Denumerator__c = 100;
                 totalNewData.Numerator__c++;            
            }
            else if (key.equals('FHI_HH_number_women_family_planning')) {
                 totalNewData.Denumerator__c = 100;
                 totalNewData.Numerator__c++;               
            }
            else if (key.equals('FHI_HH_percentage_access_credit')) {
                 totalNewData.Denumerator__c = 1;
                 totalNewData.Numerator__c = 0.3;                
            }
            else if (key.equals('FHI_HH_percentage_access_toilet')) {
                 totalNewData.Denumerator__c = 1;
                 totalNewData.Numerator__c = 0.25;                   
            }
            else if (key.equals('FHI_HH_percentage_belong_group')) {
                 totalNewData.Denumerator__c = 1;
                 totalNewData.Numerator__c = 0.33;                
            }
            else if (key.equals('FHI_HH_percentage_children_under_five')) {
                 totalNewData.Denumerator__c = 1;
                 totalNewData.Numerator__c = 0.4;                
            }
            else if (key.equals('FHI_HH_percentage_pregnant_women')) {
                 totalNewData.Denumerator__c = 1;
                 totalNewData.Numerator__c = 0.4;             
            }
            else if (key.equals('FHI_HH_percentage_with_disabled')) {
                 totalNewData.Denumerator__c = 1;
                 totalNewData.Numerator__c = totalNewData.Numerator__c + 0.07; 
            }
            system.debug('Actual Value '+ totalNewData.Actual_Value__c);
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
            }
        }
        return new String[] { '1', 'All metric data updated for FHI Dashboard  with IMEI: ' + submission.imei, 'SUPRESSMSG' }; 
    }
    
    /**
     *  Create a new metric data for a given person, start date and metric. Assume that the metric is created on the box
     *
     *  @param key       - The M_E_Metric.Name value that is being created
     *  @param startDate - The date that the metric period starts
     *  @param subcountyId   - The divider that the metric is split by
     *
     *  @return - The newly created M_E_Metric_Data object
     */
    private static M_E_Metric_Data__c createNewMetric(String key, Date startDate, String subcountyId, String districtId) {

        system.debug('Key ' + key);
        M_E_Metric__c metric = metricMap.get(key);
        
        if (metric == null) {
            system.debug('Cannot find metric! ....');
            M_E_Metric__c[] metrics = MetricHelpers.getMetrics(key, null);
            metric = metrics[0];
            system.debug('Metric found ' + metric.Name);
            metricMap.put(key, metric);
        }

        M_E_Metric_Data__c mData = new M_E_Metric_Data__c();
        mData.Subcounty__c = subcountyId;
        mData.District__c = districtId;

        mData.Numerator__c = 0.0;
        mData.Denumerator__c = 0.0;
        mData.Manual_Value__c = 0.0;
        mData.Is_Cumulative__c = false;
        mData.Date__c = startDate;
        mData.M_E_Metric__c = metric.Id;
        return mData;
    }
    
    /**
     *  Create a submission meta data object. This will allow the submissions to be mapped
     */
    private static Boolean createSubmissionMetaData(ProcessSurveySubmission.SurveySubmission surveySubmission, Person__c submitter) {

        // Load the survey
        Survey__c survey = Utils.loadSurvey(surveySubmission.surveyId);
        if (survey == null) {
            return false;
        }

        Submission_Meta_Data__c meta = new Submission_Meta_Data__c();
        meta.Interviewer__c = submitter.Id;
        meta.Survey__c = survey.Id;
        meta.Interview_Latitude__c = Decimal.valueOf(surveySubmission.interviewLatitude);
        meta.Interview_Longitude__c = Decimal.valueOf(surveySubmission.interviewLongitude);
        meta.Interview_Altitude__c = Decimal.valueOf(surveySubmission.interviewAltitude);
        meta.Interview_Accuracy__c = Decimal.valueOf(surveySubmission.interviewAccuracy);
        meta.Interview_GPS_Timestamp__c = ProcessSurveySubmission.getTimestamp(surveySubmission.interviewGPSTimestamp);
        meta.Handset_Submit_Time__c = ProcessSurveySubmission.getTimestamp(surveySubmission.handsetSubmitTime);

        meta.Submission_Latitude__c = Decimal.valueOf(surveySubmission.submissionLatitude);
        meta.Submission_Longitude__c = Decimal.valueOf(surveySubmission.submissionLongitude);
        meta.Submission_Altitude__c = Decimal.valueOf(surveySubmission.submissionAltitude);
        meta.Submission_Accuracy__c = Decimal.valueOf(surveySubmission.submissionAccuracy);
        meta.Submission_GPS_Timestamp__c = ProcessSurveySubmission.getTimestamp(surveySubmission.submissionGPSTimestamp);

        meta.Submission_Size__c = Decimal.valueOf(surveySubmission.surveySize);
        meta.Result_Hash__c = surveySubmission.resultHash;

        Database.SaveResult submissionMetaDataResult = Database.insert(meta, false);
        if (!submissionMetaDataResult.isSuccess()) {
            System.debug(LoggingLevel.INFO, submissionMetaDataResult.getErrors()[0].getMessage());
            if (submissionMetaDataResult.getErrors()[0].getMessage().contains('Result_Hash__c duplicates')) {
                System.debug(LoggingLevel.INFO, 'Duplicate submission so allow to save: ' + submissionMetaDataResult.getErrors()[0].getMessage());
                return true;
            }
            else {
                System.debug(LoggingLevel.INFO, 'Failed to save submissionMetaData object: ' + submissionMetaDataResult.getErrors()[0].getMessage());
                return false;
            }
        }
        return true;
    }
    
    /**
     *  Get the district name out of the survey
     *
     *  @param districtValue - A map containing the values for the the outlet visit
     *
     *  @return - Name of the district
     */
    private static String translateDistrictName(String districtValue, boolean isNorth) {

        Map<String, String> translationMap = null;
        if (isNorth) {
            translationMap = new Map<String, String> {
            '1' => 'Pader',
            '2' => 'Nebbi',
            '3' => 'Dokolo',
            '4' => 'Agago',
            '5' => 'Oyam'
            };
        }
        else {
            translationMap = new Map<String, String> {
            '1' => 'Kabale',
            '2' => 'Kisoro',
            '3' => 'Ibanda',
            '4' => 'Kanungu'
             };
        }
        return translationMap.get(districtValue);
    }
    
      /**
     *  Get the subcounty from northern region name basing on the binding and value of the ditrict
     *
     *  @param answers - A map containing the values for the the outlet visit
     *
     *  @return - Name of the subcounty
     */
    private static String translateNorthernSubcountyName(Map<String, Submission_Answer__c> answers, String districtBinding) {

        String subcountyName = '';
        if (districtBinding.equals('1')) {        
            // Pader
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Awere',
                '2' => 'Atenga',
                '3' => 'Puranga'
            };
            subcountyName = translationMap.get(answers.get('q4_0').Answer__c);
        }
        else if (districtBinding.equals('2')) {
             // Nebbi
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Pakwach',
                '2' => 'Kucwiny',
                '3' => 'Parombo'
            };
            subcountyName = translationMap.get(answers.get('q5_0').Answer__c);
        }
         else if (districtBinding.equals('3')) {
             // Dokolo
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Okwalogwen',
                '2' => 'Agwata',
                '3' => 'Dokolo'
            };
            subcountyName = translationMap.get(answers.get('q6_0').Answer__c);
        }
         else if (districtBinding.equals('4')) {
             // Agago
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Amiya Pacwa',
                '2' => 'Omot',
                '3' => 'Patongo'
            };
            subcountyName = translationMap.get(answers.get('q7_0').Answer__c);
        }
         else if (districtBinding.equals('5')) {
             // Oyam
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Loro',
                '2' => 'Abok',
                '3' => 'Aleka'
            };
            subcountyName = translationMap.get(answers.get('q8_0').Answer__c);
        }
        return subcountyName;
    }
    
     /**
     *  Get the subcounty from southern region name basing on the binding and value of the ditrict
     *
     *  @param answers - A map containing the values for the the outlet visit
     *
     *  @return - Name of the subcounty
     */
    private static String translateSouthernSubcountyName(Map<String, Submission_Answer__c> answers, String districtBinding) {

        String subcountyName = '';
        if (districtBinding.equals('1')) {        
            // Kabale
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Muko',
                '2' => 'Nyawmeru',
                '3' => 'Ruhija'
            };
            subcountyName = translationMap.get(answers.get('q4_0').Answer__c);
        }
        else if (districtBinding.equals('2')) {
             // Kisoro
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Bukimbiri',
                '2' => 'Nyabwishenya',
                '3' => 'Nyundo'
            };
            subcountyName = translationMap.get(answers.get('q5_0').Answer__c);
        }
         else if (districtBinding.equals('3')) {
             // Ibanda
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Kicuzi',
                '2' => 'Nyamrebe'
            };
            subcountyName = translationMap.get(answers.get('q6_0').Answer__c);
        }
         else if (districtBinding.equals('4')) {
             // Kanungu
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Kihihi',
                '2' => 'Nyamirama',
                '3' => 'Rugyeyo'
            };
            subcountyName = translationMap.get(answers.get('q7_0').Answer__c);
        }
        return subcountyName;
    }
    
     /**
     *  Get the subcounty from northern region name basing on the binding and value of the ditrict
     *
     *  @param answers - A map containing the values for the the outlet visit
     *
     *  @return - Name of the subcounty
     */
    private static String translateNorthernSubcountyNameReg(Map<String, Submission_Answer__c> answers, String districtBinding) {

        String subcountyName = '';
        if (districtBinding.equals('1')) {        
            // Pader
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Awere',
                '2' => 'Atenga',
                '3' => 'Puranga'
            };
            subcountyName = translationMap.get(answers.get('q4_0').Answer__c);
        }
        else if (districtBinding.equals('2')) {
             // Nebbi
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Pakwach',
                '2' => 'Kucwiny',
                '3' => 'Parombo'
            };
            subcountyName = translationMap.get(answers.get('q11_0').Answer__c);
        }
         else if (districtBinding.equals('3')) {
             // Dokolo
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Okwalogwen',
                '2' => 'Agwata',
                '3' => 'Dokolo'
            };
            subcountyName = translationMap.get(answers.get('q20_0').Answer__c);
        }
         else if (districtBinding.equals('4')) {
             // Agago
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Amiya Pacwa',
                '2' => 'Omot',
                '3' => 'Patongo'
            };
            subcountyName = translationMap.get(answers.get('q27_0').Answer__c);
        }
         else if (districtBinding.equals('5')) {
             // Oyam
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Loro',
                '2' => 'Abok',
                '3' => 'Aleka'
            };
            subcountyName = translationMap.get(answers.get('q36_0').Answer__c);
        }
        return subcountyName;
    }
    
     /**
     *  Get the subcounty from southern region name basing on the binding and value of the ditrict
     *
     *  @param answers - A map containing the values for the the outlet visit
     *
     *  @return - Name of the subcounty
     */
    private static String translateSouthernSubcountyNameReg(Map<String, Submission_Answer__c> answers, String districtBinding) {

        String subcountyName = '';
        if (districtBinding.equals('1')) {        
            // Kabale
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Muko',
                '2' => 'Nyawmeru',
                '3' => 'Ruhija'
            };
            subcountyName = translationMap.get(answers.get('q4_0').Answer__c);
        }
        else if (districtBinding.equals('2')) {
             // Kisoro
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Bukimbiri',
                '2' => 'Nyabwishenya',
                '3' => 'Nyundo'
            };
            subcountyName = translationMap.get(answers.get('q5_0').Answer__c);
        }
         else if (districtBinding.equals('3')) {
             // Ibanda
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Kicuzi',
                '2' => 'Nyamrebe'
            };
            subcountyName = translationMap.get(answers.get('q6_0').Answer__c);
        }
         else if (districtBinding.equals('4')) {
             // Kanungu
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Kihihi',
                '2' => 'Nyamirama',
                '3' => 'Rugyeyo'
            };
            subcountyName = translationMap.get(answers.get('q7_0').Answer__c);
        }
        return subcountyName;
    }
    
    /**
     *  Get the group type from survey
     *
     *  @param groupValue - A map containing the values for the the outlet visit
     *
     *  @return - Name of the group type
     */
    private static String translateGroupType(Map<String, Submission_Answer__c> answers, String groupValue) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Church',
            '2' => 'Elderly',
            '3' => 'Men Only',
            '4' => 'Mixed Group',
            '5' => 'PLHIV',
            '6' => 'Women Only',
            '7' => 'Women group with males',
            '8' => 'Farmers group',
            '9' => 'Youth',
            '10' => 'Other'
        };
        String groupType = translationMap.get(groupValue);
        
      /*  if (groupType.equals('Other')) {
            return answers.get('q42_0').Answer__c;
        } */
        return groupType;
    }
    
    /**
     *  Find out wether group has bank account from the survey
     *
     *  @param accountValue - A map containing the values for the the outlet visit
     *
     *  @return - Has Bank Account
     */
    private static String translateHasBankAccount(String accountValue) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Yes',
            '2' => 'No',
            '3' => 'Dont Know'
        };
        return translationMap.get(accountValue);
    }
    
    /**
     *  Get group activities account from the survey
     *
     *  @param accountValue - A map containing the values for the the outlet visit
     *
     *  @return - Has Bank Account
     */
    private static Set<String> getGroupActivities(Map<String, Submission_Answer__c> answers, Set<String> activityValues) {

        Set<String> activities = new Set<String>();
        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Animal production',
            '2' => 'Crop production',
            '3' => 'Burial support',
            '4' => 'Food security',
            '5' => 'Functional Adult Literacy',
            '6' => 'HIV/AIDS activities',
            '7' => 'Orphans and Vulnerable Children',
            '8' => 'Merry go-round',
            '9' => 'Nutrition',
            '10' => 'Savings/VSLA',
            '11' => 'Other'
        };
        
        for (String activityValue : activityValues) {
            activities.add(translationMap.get(activityValue));
            /*if (activityValue.equals('11')) {
                activities.add(answers.get('q65_0').Answer__c);
            }
            else {
                activities.add(translationMap.get(activityValue));
            }*/
        }
        return activities;
    }
    
     /**
     * Get an optional number answer from a field
     *
     * @param answer  - The answer object that we are looking at. May be null
     * @param binding - The key for the answer. So an error can be identified
     *
     * return - The answer. null if the answer is blank
     */
    private static Decimal getAnswerNumber(Submission_Answer__c answer, String binding, Boolean disallowNull) {

        if (answer == null) {
            if (disallowNull) {
                return 0.0;
            }
            return null;
        }
        else {
            Decimal returnValue;
            if (disallowNull) {
                returnValue = 0.0;
            }
            try {
                returnValue = Decimal.valueOf(answer.Answer__c);
            }
            catch (Exception e) {
                System.debug(LoggingLevel.INFO, 'Number passed in for answer with binding ' + binding + ' caused an error: ' + e.getMessage());
            }
            return returnValue;
        }
    }

    /**
     * Convert an answer into a Set for multiSelect questions
     *
     * @param answer - The answer being turned to a set
     *
     * @return - A set with all the answer bindings in
     */
    private static Set<String> getAnswerSet(Submission_Answer__c answer) {

        Set<String> returnValue = new Set<String>();
        if (answer != null) {
            String answerValue = answer.Answer__c;
            if (answerValue != null) {
                returnValue.addAll(answer.Answer__c.split(' '));
            }
        }
        return returnValue;
    }
 }