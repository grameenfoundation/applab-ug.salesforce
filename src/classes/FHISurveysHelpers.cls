/**
 *  Class that deals with all FHI 360 surveys processing
*/
public with sharing class FHISurveysHelpers {
    
    private static Map<String, String> subcountyMap = null;
    
    private static Map<String, String> getSubcountyMap() {
        if (null == subcountyMap) {
            subcountyMap = new Map<String, String>();
            subcountyMap.put('Awere', 'Awere');
            subcountyMap.put('Atanga', 'Atanga');
            subcountyMap.put('Puranga', 'Puranga');
            subcountyMap.put('Pakwach', 'Pakwach');
            subcountyMap.put('Kucwiny', 'Kucwiny');
            subcountyMap.put('Parombo', 'Parombo');
            subcountyMap.put('Pakwach Town Council', 'Pakwach TC');
            subcountyMap.put('Okwalogwen', 'Okwalongwen');
            subcountyMap.put('Agwata', 'Agwata');
            subcountyMap.put('Dokolo', 'Dokolo');
            subcountyMap.put('Amiya Pacwa', 'Omiya Pacwa');
            subcountyMap.put('Omiya Pacwa', 'Omiya Pacwa');
            subcountyMap.put('Omiya Pacwa(New, Curved out of Paimol S/C)', 'Omiya Pacwa Paimol');
            subcountyMap.put('Omot', 'Omot');
            subcountyMap.put('Patongo', 'Patongo');
            subcountyMap.put('Loro', 'Loro');
            subcountyMap.put('Abok', 'Abok');
            subcountyMap.put('Aleka', 'Aleka');
            subcountyMap.put('Ruhija', 'Ruhija');
            subcountyMap.put('Muko', 'Muko');
            subcountyMap.put('Nyamweru', 'Nyamweru');
            subcountyMap.put('Nyabwishenya', 'Nyabwishenya');
            subcountyMap.put('Nyundo', 'Nyundo');
            subcountyMap.put('Bukimbiri', 'Bukimbiri');
            subcountyMap.put('Kicuzi', 'Kicuzi');
            subcountyMap.put('Nyamarebe', 'Nyamarebe');
            subcountyMap.put('Kihihi', 'Kihiihi');
            subcountyMap.put('Nyamirama', 'Nyamirama');
            subcountyMap.put('Rugyeyo', 'Rugyeyo');
        }
        return subcountyMap;
    }

    public static Map<String, M_E_Metric__c> metricMap = new Map<String, M_E_Metric__c>();
    
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
        boolean isNewSurvey = false;
        //check if is a new survey and process separately 
        isNewSurvey = surveyName.contains('register')? true : false;
        if(isNewSurvey){
            return processGroupRegistrationForNewSurveys(submission, answers, submitter, surveyName);
        }
        
        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
        }
        
        if (surveyName.contains('South') || surveyName.contains('south')) {
            isNorth = false;
        }
        //Commented out to save space
        //ProcessSubmissionHelpers.createSubmissionMetaData(submission, submitter);

        // Dig out the values that are to be added to the metrics
        String registrationDate = answers.get('q1_0').Answer__c;
        System.debug('Registration date: ' + registrationDate);
        
        String districtValue = answers.get('q3_0').Answer__c;
        String districtName = translateDistrictName(districtValue, isNorth);
        System.debug('District: ' + districtName);
        
        String subcountyName = '';
        if (isNorth) {
            subcountyName = getSubcountyMap().get(translateNorthernSubcountyName(answers, districtValue));
        }
        else {
            subcountyName = getSubcountyMap().get(translateSouthernSubcountyName(answers, districtValue));
        }
        System.debug('Subcounty: ' + subcountyName);
        
        //get group type
        String groupType = isNorth ? translateGroupType(answers, answers.get('q41_0').Answer__c) : translateGroupType(answers, answers.get('q32_0').Answer__c);
        System.debug('Group Type: ' + groupType);
        
        //get males in group
        Decimal malesInGroup = isNorth? ProcessSubmissionHelpers.getAnswerNumber(answers.get('q43_0'), 'q43_0', true) : ProcessSubmissionHelpers.getAnswerNumber(answers.get('q34_0'), 'q34_0', true);
        System.debug('Males in group: ' + String.valueOf(malesInGroup));
        
        //get females in group
        Decimal femalesInGroup = isNorth ? ProcessSubmissionHelpers.getAnswerNumber(answers.get('q44_0'), 'q44_0', true) : ProcessSubmissionHelpers.getAnswerNumber(answers.get('q35_0'), 'q35_0', true);
        System.debug('Females in group: ' + String.valueOf(femalesInGroup));
                
        Subcounty__c subcounty = [
            SELECT
                Id
            FROM
                Subcounty__c
            WHERE
                Display_Name__c = :subcountyName
            LIMIT 1
        ];

        String subcountyId = subcounty.Id;
        system.debug('subcounty id ' + subcountyId);
        
        // Load the metrics for the month that the submission is for
        List<String> metricNames = new List<String> { 
            'FHI_CC_number_producer_slash_farmer_groups',
            'FHI_CC_number_women_groups',
            'FHI_CC_number_youth_members',
            'FHI_CC_number_total_group_members',
            'FHI_CC_percentage_female_members'
        };
        
        Date currentDate = handsetSubmitTime.date();
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
                    Subcounty__c = :subcountyId
                )
                AND Date__c = :currentDate
                AND M_E_Metric__r.Name IN (
                    'FHI_CC_number_producer_slash_farmer_groups',
                    'FHI_CC_number_women_groups',
                    'FHI_CC_number_youth_members',
                    'FHI_CC_number_total_group_members',
                    'FHI_CC_percentage_female_members')
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
                totalNewData = createNewMetric(key, currentDate, subcountyId);
            }
            system.debug('Actual Value ' + totalNewData.Actual_Value__c);
            
            // Update the metric based on the key
            if (key.equals('FHI_CC_number_producer_slash_farmer_groups')) {
                if (!groupType.equals('Other') && !groupType.equals('Youth') && !groupType.equals('Women only')) {
                    totalNewData.Denumerator__c++;
                }  
            }
            else if(key.equals('FHI_CC_number_women_groups')){
                if(groupType.equals('Women only')){
                    totalNewData.Denumerator__c++;
                }
            }
            else if(key.equals('FHI_CC_number_youth_members')){
                if(groupType.equals('Youth')){
                    totalNewData.Denumerator__c += malesInGroup + femalesInGroup;
                }
            }
            else if(key.equals('FHI_CC_number_total_group_members')){
                totalNewData.Denumerator__c += malesInGroup + femalesInGroup;
            }
            else if(key.equals('FHI_CC_percentage_female_members')){
                totalNewData.Numerator__c += femalesInGroup;
                totalNewData.Denumerator__c += femalesInGroup + malesInGroup;
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
            }
        }
        return new String[] { '1', 'All metric data updated for FHI Dashboard  with IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }
    
     /**
     *  Process the household registration survey submission and create the metrics for the data validators
     *  This method processes surveys of the naming "CCHH Register North final" and "CCHH Register South final",
     *  "CCHH Register Northfinal2" and "CCHH Register Southfinal2"
     *  For newer surveys (with names "HH_register*"), a different method is dedicated to that and called as required
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
    public static List<String> processHouseholdRegistration(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers,  Person__c submitter, String surveyName) {
        
        boolean isNorth = true;
        boolean isConsentGiven = true;
        //check if is a new survey and process separately 
        boolean isNewSurvey = surveyName.contains('CCHH')? false : true;
        if(isNewSurvey){
            return processHouseholdRegistrationForNewSurveys(submission, answers, submitter, surveyName);
        }
        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
        }
        
        if (surveyName.contains('South') || surveyName.contains('south')) {
            isNorth = false;
        }
        //Commented out to save space
        //ProcessSubmissionHelpers.createSubmissionMetaData(submission, submitter);

        // Dig out the values that are to be added to the metrics
        String registrationDate = answers.get('q2_0').Answer__c;
        System.debug('Registration date: ' + registrationDate);
        
        String districtValue = answers.get('q3_0').Answer__c;
        String districtName = translateDistrictName(districtValue, isNorth);
        System.debug('District: ' + districtName);
        
        String subcountyName = '';
        if (isNorth) {
            subcountyName = getSubcountyMap().get(translateNorthernSubcountyNameReg(answers, districtValue));
        }
        else {
            subcountyName = getSubcountyMap().get(translateSouthernSubcountyNameReg(answers, districtValue));
        }
        System.debug('Subcounty: ' + subcountyName);

        //vulnerable and opharns
        boolean isThereAnOvc = isNorth ?  ProcessSubmissionHelpers.checkIfYes(answers.get('q70_0').Answer__c) : ProcessSubmissionHelpers.checkIfYes(answers.get('q57_0').Answer__c);

        //does VSLA
        String selectionIndexVSLA = isNorth ? answers.get('q84_0').Answer__c : answers.get('q71_0').Answer__c; 
        
        boolean isHouseHead = isNorth ?  ProcessSubmissionHelpers.checkIfYes(answers.get('q46_0').Answer__c) : ProcessSubmissionHelpers.checkIfYes(answers.get('q33_0').Answer__c);
        
        // get household member count using a question that must be answered
        Integer numberOfHouseholdMemebers = isNorth ? ProcessSubmissionHelpers.getSingleSelectAnswersByMatchingBindings('q51_', answers).size() : ProcessSubmissionHelpers.getSingleSelectAnswersByMatchingBindings('q38_', answers).size();
        System.debug('Number of household members: ' + numberOfHouseholdMemebers);
        
        Integer numberFemaleHouseHeads = isNorth ? ProcessSubmissionHelpers.getCount(ProcessSubmissionHelpers.getSingleSelectAnswersByMatchingBindings('q50_', answers), '2') : ProcessSubmissionHelpers.getCount(ProcessSubmissionHelpers.getSingleSelectAnswersByMatchingBindings('q37_', answers), '2');
        System.debug('Number female househeads: ' + numberFemaleHouseHeads);
        
        boolean haveCcFruitTrees = getValue('q86_0', 'q73_0',answers, isNorth);
        System.debug('Has CC Fruit Tree: ' + haveCcFruitTrees);

        Subcounty__c subcounty = [
            SELECT
                Id
            FROM
                Subcounty__c
            WHERE
                Display_Name__c = :subcountyName
            LIMIT 1
        ];

        String subcountyId = subcounty.Id;
        system.debug('subcounty id ' + subcountyId);
        
        // Load the metrics for the month that the submission is for
        List<String> metricNames = new List<String> { 
            'FHI_HH_number_households_registered_x', 
            'FHI_HH_number_households_vulnerable',
            'FHI_HH_number_households_with_member_in_vsla',
            'FHI_HH_percentage_female_headed_households',
            'FHI_HH_percentage_households_with_cc_fruit_trees_x'
        };
        
        Date currentDate = handsetSubmitTime.date();
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
                    Subcounty__c = :subcountyId
                )
                AND Date__c >= :currentDate
                AND M_E_Metric__r.Name IN (
                    'FHI_HH_number_households_registered_x', 
                    'FHI_HH_number_households_vulnerable',
                    'FHI_HH_number_households_with_member_in_vsla',
                    'FHI_HH_percentage_female_headed_households',
                    'FHI_HH_percentage_households_with_cc_fruit_trees_x')
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
                totalNewData = createNewMetric(key, currentDate, subcountyId);
            }
            // Update the metric based on the key
            if (key.equals('FHI_HH_number_households_registered_x')) {
                totalNewData.Denumerator__c += isConsentGiven ? 1 : 0;
            }
            else if (key.equals('FHI_HH_number_households_vulnerable')) {
                totalNewData.Denumerator__c += isThereAnOvc ? 1 : 0;
            }
            else if (key.equals('FHI_HH_number_households_with_member_in_vsla')) {
                totalNewData.Denumerator__c += selectionIndexVSLA.equals('1') ? 1 : 0;
            }
            else if (key.equals('FHI_HH_percentage_female_headed_households')) {
                 totalNewData.Denumerator__c += numberOfHouseholdMemebers;
                 totalNewData.Numerator__c += numberFemaleHouseHeads; 
            }
            else if (key.equals('FHI_HH_percentage_households_with_cc_fruit_trees_x')) {
                 totalNewData.Denumerator__c += isConsentGiven ? 1 : 0;
                 totalNewData.Numerator__c += haveCcFruitTrees ? 1 : 0;
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
     *  Process the group registration for new surveys submissions and create the metrics for the data validators
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
    private static List<String> processGroupRegistrationForNewSurveys(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers,  Person__c submitter, String surveyName) {
        
        boolean isNorth = false;
        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
        }
        
        if (surveyName.contains('North') || surveyName.contains('north')) {
            isNorth = true;
        }
        //Commented out to save space
        //ProcessSubmissionHelpers.createSubmissionMetaData(submission, submitter);

        // Dig out the values that are to be added to the metrics
        String registrationDate = answers.get('regdate_0').Answer__c;
        System.debug(LoggingLevel.INFO, 'Registration date: ' + registrationDate);
        
        String districtValue = answers.get('district_0').Answer__c;
        String districtName = translateDistrictName(districtValue, isNorth);
        System.debug(LoggingLevel.INFO, 'District: ' + districtName);
        
        String subcountyName = answers.get('subcounty_0').Answer__c;
        System.debug(LoggingLevel.INFO, 'Subcounty: ' + subcountyName);
        
        //get group type
        String groupType = isNorth ? translateNewGroupTypes(answers, answers.get('grptype_0').Answer__c) : translateNewGroupTypes(answers, answers.get('grptype_0').Answer__c);
        System.debug(LoggingLevel.INFO, 'Group Type: ' + groupType);
        
        //total male members
        Decimal malesInGroup = isNorth? ProcessSubmissionHelpers.getAnswerNumber(answers.get('num_males_0'), 'num_males_0', true) : ProcessSubmissionHelpers.getAnswerNumber(answers.get('num_males_0'), 'num_males_0', true);
        System.debug(LoggingLevel.INFO, 'Males in group: ' + String.valueOf(malesInGroup));
        
        //total female members
        Decimal femalesInGroup = isNorth ? ProcessSubmissionHelpers.getAnswerNumber(answers.get('num_females_0'), 'num_females_0', true) : ProcessSubmissionHelpers.getAnswerNumber(answers.get('num_females_0'), 'num_females_0', true);
        System.debug(LoggingLevel.INFO, 'Females in group: ' + String.valueOf(femalesInGroup));
                
        Subcounty__c[] subcounty = [
            SELECT
                Id
            FROM
                Subcounty__c
            WHERE
                Display_Name__c = :subcountyName
            LIMIT 1
        ];
        if(subcounty.isEmpty()){
            return new String[]{ '0', 'The subcounty provided is not in salesforce', 'SUPRESSMSG' };
        }

        String subcountyId = subcounty[0].Id;
        system.debug(LoggingLevel.INFO, 'subcounty id ' + subcountyId);
        
        // Load the metrics for the month that the submission is for
        List<String> metricNames = new List<String> { 
            'FHI_CC_number_producer_slash_farmer_groups',
            'FHI_CC_number_women_groups',
            'FHI_CC_number_youth_members',
            'FHI_CC_number_total_group_members',
            'FHI_CC_percentage_female_members'
            };
        
        Date currentDate = handsetSubmitTime.date();
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
                    Subcounty__c = :subcountyId
                )
                AND Date__c = :currentDate
                AND M_E_Metric__r.Name IN (
                    'FHI_CC_number_producer_slash_farmer_groups',
                    'FHI_CC_number_women_groups',
                    'FHI_CC_number_youth_members',
                    'FHI_CC_number_total_group_members',
                    'FHI_CC_percentage_female_members')
        ];

        // Loop through the data and see which ones we have already got. If they are not there already create them
        Map<String, M_E_Metric_Data__c> dataMap = new Map<String, M_E_Metric_Data__c>();
        for (M_E_Metric_Data__c mData : datas) {
            
             dataMap.put(mData.M_E_Metric__r.Name, mData);system.debug(LoggingLevel.INFO, 'METRIC NAME '+ mData.M_E_Metric__r.Name);
        }

        // Loop through the list of metrics and check that they all exist and then update them
        for (String key : metricNames) {

            // Check that the three metrics for each metric name exists
            M_E_Metric_Data__c totalNewData = dataMap.get(key);
            system.debug(LoggingLevel.INFO, 'Checking for metric name: ' + key);
            if (totalNewData == null) {
                totalNewData = createNewMetric(key, currentDate, subcountyId);
            }
            system.debug(LoggingLevel.INFO, 'Actual Value ' + totalNewData.Actual_Value__c);
            // Update the metric based on the key
            if (key.equals('FHI_CC_number_producer_slash_farmer_groups')) {
                if(groupType.equals('Producer/Farmers')){
                    totalNewData.Denumerator__c++;
                }
            }
            else if(key.equals('FHI_CC_number_women_groups')){
                if(groupType.equals('Women')){
                    totalNewData.Denumerator__c++;
                }
            }
            else if(key.equals('FHI_CC_number_youth_members')){
                if(groupType.equals('Youth')){
                    totalNewData.Denumerator__c += malesInGroup + femalesInGroup;
                }
            }
            else if(key.equals('FHI_CC_number_total_group_members')){
                totalNewData.Denumerator__c += malesInGroup + femalesInGroup;
            }
            else if(key.equals('FHI_CC_percentage_female_members')){
                totalNewData.Numerator__c += femalesInGroup;
                totalNewData.Denumerator__c += femalesInGroup + malesInGroup;
            }
            dataMap.put(key, totalNewData);
        }
        List<Database.upsertResult> uResults = Database.upsert(dataMap.values());
        for(Database.upsertResult result : uResults) {
            if (result.isSuccess()) {
                system.debug(LoggingLevel.INFO, 'succeeded ' + result.getId());
            }
            else {
                for (Database.Error error : result.getErrors()) {
                    system.debug(LoggingLevel.ERROR, 'Error: ' + error.getMessage());
                }
            }
        }
        return new String[] { '1', 'All metric data updated for FHI Dashboard  with IMEI: ' + submission.imei, 'SUPRESSMSG' };
    }
    
    /**
     *  Process the household registrations for new surveys and create the metrics for the data validators
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
    private static List<String> processHouseholdRegistrationForNewSurveys(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers,  Person__c submitter, String surveyName) {

        boolean isNorth = false;
        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
        }
        
        if (surveyName.contains('North') || surveyName.contains('north')) {
            isNorth = true;
        }
        //Commented out to save space
        //ProcessSubmissionHelpers.createSubmissionMetaData(submission, submitter);

        // Dig out the values that are to be added to the metrics
        String registrationDate = answers.get('regdate_0').Answer__c;
        System.debug(LoggingLevel.INFO, 'Registration date: ' + registrationDate);
        
        String districtValue = answers.get('district_0').Answer__c;
        String districtName = translateDistrictNameForNewSurveys(districtValue, isNorth);
        System.debug(LoggingLevel.INFO, 'District: ' + districtName);
        
        String subcountyName = answers.get('subcounty_0').Answer__c;
        System.debug(LoggingLevel.INFO, 'Subcounty: ' + subcountyName);

        boolean isConsentGiven = ProcessSubmissionHelpers.checkIfYes(answers.get('consent_0').Answer__c);

        boolean isHouseHeadFemale = answers.get('sexhhh_0').Answer__c.equals('2');

        boolean isThereAnOvc = ProcessSubmissionHelpers.checkIfYes(answers.get('ovc_0').Answer__c);

        boolean isThereAnyVsla = ProcessSubmissionHelpers.checkIfYes(answers.get('vsla_0').Answer__c);

        boolean growsFruitTrees = true;
        Set<String> cropsSelection = ProcessSubmissionHelpers.getAnswerSet(answers.get('cc_crops_0'));
        growsFruitTrees = checkIfHasFruitTrees(cropsSelection);

        Subcounty__c[] subcounty = [
            SELECT
                Id
            FROM
                Subcounty__c
            WHERE
                Display_Name__c = :subcountyName
            LIMIT 1
        ];
        if(subcounty.isEmpty()){
            return new String[]{ '0', 'The subcounty provided is not in salesforce', 'SUPRESSMSG' };
        }
        String subcountyId = subcounty[0].Id;
        system.debug(LoggingLevel.INFO, 'subcounty id ' + subcountyId);
        
        // Load the metrics for the month that the submission is for
        List<String> metricNames = new List<String> {
            'FHI_HH_number_households_registered_x', 
            'FHI_HH_number_households_vulnerable',//new
            'FHI_HH_number_households_with_member_in_vsla',//new
            'FHI_HH_percentage_female_headed_households',//new
            'FHI_HH_percentage_households_with_cc_fruit_trees_x'
            };
        
        Date currentDate = handsetSubmitTime.date();
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
                    Subcounty__c = :subcountyId
                )
                AND Date__c >= :currentDate
                AND M_E_Metric__r.Name IN (
                    'FHI_HH_number_households_registered_x', 
                    'FHI_HH_number_households_vulnerable',
                    'FHI_HH_number_households_with_member_in_vsla',
                    'FHI_HH_percentage_female_headed_households',
                    'FHI_HH_percentage_households_with_cc_fruit_trees_x')
        ];

        // Loop through the data and see which ones we have already got. If they are not there already create them
        Map<String, M_E_Metric_Data__c> dataMap = new Map<String, M_E_Metric_Data__c>();
        for (M_E_Metric_Data__c mData : datas) {
            
             dataMap.put(mData.M_E_Metric__r.Name, mData);system.debug(LoggingLevel.INFO, 'METRIC NAME '+ mData.M_E_Metric__r.Name);
        }

        // Loop through the list of metrics and check that they all exist and then update them
        for (String key : metricNames) {

            // Check that the three metrics for each metric name exists
            M_E_Metric_Data__c totalNewData = dataMap.get(key);
            system.debug(LoggingLevel.INFO, 'Checking for metric name: ' + key);
            if (totalNewData == null) {
                totalNewData = createNewMetric(key, currentDate, subcountyId);
            }
            // Update the metric based on the key
            if (key.equals('FHI_HH_number_households_registered_x')) {
                totalNewData.Denumerator__c += isConsentGiven ? 1 : 0;
            }
            else if (key.equals('FHI_HH_number_households_vulnerable')) {
                totalNewData.Denumerator__c += (isThereAnOvc && isConsentGiven) ? 1 : 0;
            }
            else if (key.equals('FHI_HH_number_households_with_member_in_vsla')) {
                totalNewData.Denumerator__c += (isThereAnyVsla && isConsentGiven) ? 1 : 0;
            }
            else if (key.equals('FHI_HH_percentage_female_headed_households')) {
                 totalNewData.Denumerator__c += isConsentGiven ? 1 : 0;
                 totalNewData.Numerator__c += (isHouseHeadFemale && isConsentGiven) ? 1 : 0;
            }
            else if (key.equals('FHI_HH_percentage_households_with_cc_fruit_trees_x')) {
                 totalNewData.Denumerator__c += isConsentGiven ? 1 : 0;
                 totalNewData.Numerator__c += (isConsentGiven && growsFruitTrees) ? 1 : 0;
            }
            system.debug(LoggingLevel.INFO, 'Actual Value '+ totalNewData.Actual_Value__c);
            dataMap.put(key, totalNewData);
        }
        List<Database.upsertResult> uResults = Database.upsert(dataMap.values());
        for(Database.upsertResult result : uResults) {
            if (result.isSuccess()) {
                system.debug(LoggingLevel.INFO, 'succeeded ' + result.getId());
            }
            else {
                for (Database.Error error : result.getErrors()) {
                    system.debug(LoggingLevel.ERROR, 'Error: ' + error.getMessage());
                }
            }
        }
        return new String[] { '1', 'All metric data updated for FHI Dashboard  with IMEI: ' + submission.imei, 'SUPRESSMSG' }; 
    }    

    private static boolean getValue(String northBinding, String southBinding, Map<String, Submission_Answer__c> answers, boolean isNorth) {
        try {
            boolean val = isNorth ? ProcessSubmissionHelpers.getAnswerNumber(answers.get(northBinding), northBinding, true) >= 1 :  ProcessSubmissionHelpers.getAnswerNumber(answers.get(southBinding), southBinding, true) >= 1;
            return val;
        }
        catch (Exception ex) {
           return false;
        }
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
    private static M_E_Metric_Data__c createNewMetric(String key, Date startDate, String subcountyId) {

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
     *  Get the district name out of the new surveys
     *
     *  @param districtValue - A map containing the values for the the outlet visit
     *
     *  @return - Name of the district
     */
    private static String translateDistrictNameForNewSurveys(String districtValue, boolean isNorth) {

        Map<String, String> translationMap = null;
        if (isNorth) {
            translationMap = new Map<String, String> {
                '1' => 'Agago',
                '2' => 'Dokolo',
                '3' => 'Kiryandongo',
                '4' => 'Kole',
                '5' => 'Lira',
                '6' => 'Masindi',
                '7' => 'Nebbi',
                '8' => 'Oyam',
                '9' => 'Pader'
            };
        }
        else {
            translationMap = new Map<String, String> {
                '1' => 'Kamwenge',
                '2' => 'kasese',
                '3' => 'Kabale',
                '4' => 'Kanungu',
                '5' => 'Ibanda',
                '6' => 'Kisoro'
             };
        }
        return translationMap.get(districtValue);
    }

    /**
     * The user's selection map is;
     *       '1' => 'Amaranth',
     *       '2' => 'Avacado',
     *       '3' => 'Pawpaw',
     *       '4' => 'Pumpkin',
     *       '5' => 'Tree tomatoes',
     *       '6' => 'Guavas',
     *       '7' => 'Jack fruit',
     *       '8' => 'Mangoes',
     *       '9' => 'Oranges',
     *       '10' => 'None',
     *       '11' => 'Other'
     * selection indeces 2 3 6 7 8 and 9 are fruits.
     * If any of the fruit indeces appear in the cropSelection, we return true
     * 
     * @param cropsSelection a list of indeces selected by the user
     * 
     * @return <code>true<code> if at least one fruit index is in the cropSelection, false otherwise
     */
    private static boolean checkIfHasFruitTrees(Set<String> cropsSelection){

        if(cropsSelection.isEmpty()) {
            return false;
        }

        Set<String> fruitIndeces = new Set<String>{'2', '3', '6', '7', '8', '9'};
        for(String index: cropsSelection){
            if(fruitIndeces.contains(index)){
                return true;
            }
        }
        return false;
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
                '2' => 'Atanga',
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
                '3' => 'Patongo',
                '4' => 'Omiya Pacwa(New, Curved out of Paimol S/C)'
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
                '2' => 'Nyamweru',
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
                '2' => 'Nyamarebe'
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
                '2' => 'Atanga',
                '3' => 'Puranga'
            };
            subcountyName = translationMap.get(answers.get('q4_0').Answer__c);
        }
        else if (districtBinding.equals('2')) {
             // Nebbi
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Pakwach',
                '2' => 'Kucwiny',
                '3' => 'Parombo',
                '4' => 'Pakwach Town Council'
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
                '1' => 'Omiya Pacwa',
                '2' => 'Omiya Pacwa(New, Curved out of Paimol S/C)',
                '3' => 'Omot',
                '4' => 'Patongo'
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
                '1' => 'Ruhija',
                '2' => 'Muko',
                '3' => 'Nyamweru'
            };
            subcountyName = translationMap.get(answers.get('q4_0').Answer__c);
        }
        else if (districtBinding.equals('2')) {
             // Kisoro
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Nyabwishenya',
                '2' => 'Nyundo',
                '3' => 'Bukimbiri'
            };
            subcountyName = translationMap.get(answers.get('q5_0').Answer__c);
        }
         else if (districtBinding.equals('3')) {
             // Ibanda
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Kicuzi',
                '2' => 'Nyamarebe'
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
            '3' => 'Men only',
            '4' => 'Mixed group',
            '5' => 'PLHIV',
            '6' => 'Women only',
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
     *  Get the group type from the new surveys
     *
     *  @param groupValue - A map containing the values for the the outlet visit
     *
     *  @return - Name of the group type
     */
    private static String translateNewGroupTypes(Map<String, Submission_Answer__c> answers, String groupValue) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Producer/Farmers',
            '2' => 'Women',
            '3' => 'Youth',
            '4' => 'Other'
        };
        String groupType = translationMap.get(groupValue);
        
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
    
    static testmethod void testFhiGroupNorthSurveyProcessing() {
        
        // Create Test Org, this is necessary for the creation of metrics
        Account acc =  Utils.createTestOrganisation('test Org');
        database.insert(acc);
        
        //Utils.createTestMetric(acc, calculationType, area, subDivide, appendCharacters)
        
        // Create Server Configuration
        Server_Configuration__c config = new Server_Configuration__c();
        config.Name = 'TestConf';
        config.URL__c = 'http://test.applab.org:8888/services/';
        config.Base_URL__c = 'http://test.applab.org:8888';
        config.Services_Path__c = '/services/';
        config.Survey_Database__c = 'zebra';
        config.Search_Database__c = 'ycppquiz';
        database.insert(config);
        
        // Create test subcounty
        Subcounty__c subcounty = new Subcounty__c();
        subcounty.Display_Name__c = 'Awere';
        database.insert(subcounty);
        
        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, null, 'Female');
        database.insert(ckw);

        // Create a farmer
        Farmer__c farmer1 = Utils.createTestFarmer('OD99999', null, 'TestFarmer1', true, null, null);
        farmer1.Registered_By__c = ckw.Person__c;
        database.insert(farmer1);

        Survey__c survey = new Survey__c();
        survey.Survey_Name__c = 'cc north';
        survey.Post_Processing_Method__c = 'FHI_GROUP_REGISTRATION';
        survey.Save_To_Salesforce__c = false;
        survey.Survey_Status__c = 'Active';
        survey.Start_Date__c = date.today().addMonths(-1);
        database.insert(survey);
        
        Survey__c survey2 = [Select Id, Name from Survey__c where Id = :survey.Id LIMIT 1];
        CKW__c ckw2 = [Select Id, Person__c, Person__r.Handset__c, Person__r.Handset__r.IMEI__c from CKW__c where Id = :ckw.Id LIMIT 1];

        ProcessSurveySubmission.SurveySubmission surveySubmission = new ProcessSurveySubmission.SurveySubmission();
        surveySubmission.imei = ckw2.Person__r.Handset__r.IMEI__c;
        surveySubmission.farmerId = 'OD99999';
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

        surveySubmission.xml = '<?xml version="1.0"?><answers><answer><binding>q59</binding><answerText>1 2 3</answerText><instance>0</instance><questionNumber>59</questionNumber><questionType>Select</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q40</binding><answerText>Test</answerText><instance>0</instance><questionNumber>40</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q64</binding><answerText>1 2 3</answerText><instance>0</instance><questionNumber>64</questionNumber><questionType>Select</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q1</binding><answerText>2012-10-04</answerText><instance>0</instance><questionNumber>1</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q54</binding><answerText>1</answerText><instance>0</instance><questionNumber>54</questionNumber><questionType>Select1</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q44</binding><answerText>4</answerText><instance>0</instance><questionNumber>44</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q58</binding><answerText>0</answerText><instance>0</instance><questionNumber>58</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q49</binding><answerText>Tom</answerText><instance>0</instance><questionNumber>49</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q43</binding><answerText>4</answerText><instance>0</instance><questionNumber>43</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q66</binding><answerText>null</answerText><instance>0</instance><questionNumber>66</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q47</binding><answerText>Tim</answerText><instance>0</instance><questionNumber>47</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q61</binding><answerText>1</answerText><instance>0</instance><questionNumber>61</questionNumber><questionType>Select1</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q46</binding><answerText>2</answerText><instance>0</instance><questionNumber>46</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q45</binding><answerText>2</answerText><instance>0</instance><questionNumber>45</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q2</binding><answerText>T11</answerText><instance>0</instance><questionNumber>2</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q51</binding><answerText>1 2</answerText><instance>0</instance><questionNumber>51</questionNumber><questionType>Select</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q39</binding><answerText>Test</answerText><instance>0</instance><questionNumber>39</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q9</binding><answerText>1</answerText><instance>0</instance><questionNumber>9</questionNumber><questionType>Select1</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q3</binding><answerText>1</answerText><instance>0</instance><questionNumber>3</questionNumber><questionType>Select1</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q57</binding><answerText>1</answerText><instance>0</instance><questionNumber>57</questionNumber><questionType>Select1</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q48</binding><answerText>782445833</answerText><instance>0</instance><questionNumber>48</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q56</binding><answerText>1</answerText><instance>0</instance><questionNumber>56</questionNumber><questionType>Select1</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q62</binding><answerText>1</answerText><instance>0</instance><questionNumber>62</questionNumber><questionType>Select1</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q41</binding><answerText>1</answerText><instance>0</instance><questionNumber>41</questionNumber><questionType>Select1</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q53</binding><answerText>1</answerText><instance>0</instance><questionNumber>53</questionNumber><questionType>Select1</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q4</binding><answerText>1</answerText><instance>0</instance><questionNumber>4</questionNumber><questionType>Select1</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer><answer><binding>q50</binding><answerText>789578578</answerText><instance>0</instance><questionNumber>50</questionNumber><questionType>Input</questionType><parentBinding>null</parentBinding><parentInstance>0</parentInstance></answer></answers>';
        surveySubmission.json = 'none';
        //ProcessSurveySubmission.SurveySubmission resultSurveySubmission = ProcessSurveySubmission.processSurveySubmission(surveySubmission);
        //System.debug(resultSurveySubmission.errorMessage);
        //System.assert(resultSurveySubmission.success);
    }
 }
