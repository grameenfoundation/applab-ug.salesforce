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
        subcountyName = isNorth ? getSubcountyMap().get(translateNorthernSubcountyName(answers, districtValue)) : getSubcountyMap().get(translateSouthernSubcountyName(answers, districtValue));
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
            'FHI_CC_number_groups',
            'FHI_CC_number_youth_members',
            'FHI_CC_number_total_group_members',

            'FHI_CC_number_women_and_women_with_men_groups',
            'FHI_CC_number_youth_groups',
            'FHI_CC_number_producer_slash_farmer_groups',
            'FHI_CC_number_other_groups',

            'FHI_CC_percentage_female_members',
            'FHI_percentage_youth_group_members'
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
                AND M_E_Metric__r.Name IN :metricNames
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
            totalNewData = totalNewData == null ? createNewMetric(key, currentDate, subcountyId) : totalNewData;
            system.debug('Actual Value ' + totalNewData.Actual_Value__c);
            
            // Update the metric based on the key
            if (key.equals('FHI_CC_number_groups')) {
                totalNewData.Denumerator__c++;
            }
            else if(key.equals('FHI_CC_number_women_and_women_with_men_groups')){
                if(groupType.equals('Women only') || groupType.equals('Women group with males')){
                    totalNewData.Denumerator__c++;
                }
            }
            else if(key.equals('FHI_CC_number_youth_groups')){
                if(groupType.equals('Youth')){
                    totalNewData.Denumerator__c++;
                }
            }
            else if(key.equals('FHI_CC_number_producer_slash_farmer_groups')){
                if(groupType.equals('Church') || groupType.equals('Elderly') || groupType.equals('Men only') || 
                    groupType.equals('Mixed group') || groupType.equals('PLHIV') || groupType.equals('Farmers group')){
                    totalNewData.Denumerator__c++;
                }
            }
            else if(key.equals('FHI_CC_number_other_groups')){
                if(groupType.equals('Other')){
                    totalNewData.Denumerator__c++;
                }
            }
            else if(key.equals('FHI_CC_number_youth_members')){
                if(groupType.equals('Youth')){
                    totalNewData.Denumerator__c += malesInGroup + femalesInGroup;
                }
            }
            else if(key.equals('FHI_percentage_youth_group_members')){
                if(groupType.equals('Youth')){
                    totalNewData.Numerator__c += malesInGroup + femalesInGroup;
	                totalNewData.Denumerator__c += malesInGroup + femalesInGroup;
                }
                else{
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
        subcountyName = isNorth ? (getSubcountyMap().get(translateNorthernSubcountyNameReg(answers, districtValue))) : 
            (getSubcountyMap().get(translateSouthernSubcountyNameReg(answers, districtValue)));
        System.debug('Subcounty: ' + subcountyName);

        //vulnerable household - begins with VH
        String hhNumber = answers.get('q1_0') != null ? answers.get('q1_0').Answer__c : '';
        boolean isThereAnOvc = hhNumber.toUpperCase().startsWith('VH');

        //does VSLA, the selectio index for vsla is 1, return index of 2 if no answer
        String selectionIndexVSLA = isNorth ? ( answers.containsKey('q84_0') ? answers.get('q84_0').Answer__c : '2' ): ( answers.containsKey('q71_0') ? answers.get('q71_0').Answer__c : '2'); 
        
        boolean isHouseHead = isNorth ?  ProcessSubmissionHelpers.checkIfYes(answers.get('q46_0').Answer__c) : ProcessSubmissionHelpers.checkIfYes(answers.get('q33_0').Answer__c);
        
        // get household member count using a question that must be answered
        Integer numberOfHouseholdMemebers = isNorth ? ProcessSubmissionHelpers.getSingleSelectAnswersByMatchingBindings('q51_', answers).size() : ProcessSubmissionHelpers.getSingleSelectAnswersByMatchingBindings('q38_', answers).size();
        System.debug('Number of household members: ' + numberOfHouseholdMemebers);
        
        Integer numberFemaleHouseHeads = isNorth ? ProcessSubmissionHelpers.getCount(ProcessSubmissionHelpers.getSingleSelectAnswersByMatchingBindings('q50_', answers), '2') : ProcessSubmissionHelpers.getCount(ProcessSubmissionHelpers.getSingleSelectAnswersByMatchingBindings('q37_', answers), '2');
        System.debug('Number female househeads: ' + numberFemaleHouseHeads);

        boolean isHouseHeadFemale = isNorth ? isThereAfemaleHouseHead(answers, 'q33_', 'q37_') : isThereAfemaleHouseHead(answers, 'q46_', 'q50_');
        
        boolean haveCcFruitTrees = true;
        Set<String> cropsSelection = isNorth ? ProcessSubmissionHelpers.getAnswerSet(answers.get('q94_0')) : ProcessSubmissionHelpers.getAnswerSet(answers.get('q82_0'));
        haveCcFruitTrees = checkIfHasFruitTreesInOldSurveys(cropsSelection);

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
                AND M_E_Metric__r.Name IN :metricNames
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
            totalNewData = totalNewData == null ? createNewMetric(key, currentDate, subcountyId) : totalNewData;
            
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
                 totalNewData.Denumerator__c += isConsentGiven ? 1 : 0;
                 totalNewData.Numerator__c += isHouseHeadFemale ? 1 : 0;
            }
            else if (key.equals('FHI_HH_percentage_households_with_cc_fruit_trees_x')) {
                 totalNewData.Denumerator__c += isConsentGiven ? 1 : 0;
                 totalNewData.Numerator__c += haveCcFruitTrees ? 1 : 0;
            }
            system.debug('Actual Value ' + totalNewData.Actual_Value__c);
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
        
        String subcountyName = answers.get('subcounty_0').Answer__c.trim();
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
        //we have a problem with subcounties with the words 'Town Council', their naming is not standardised
        //oh, and the survey captures subcounty from text input by CKW, hence possible mistakes expected
        if(subcounty.isEmpty() && (subcountyName.containsIgnoreCase('town council') || subcountyName.containsIgnoreCase(' TC')) ){
            System.debug(LoggingLevel.INFO, 'subcounty not found. trying variant of *town council');
            subcountyName = subcountyName.containsIgnoreCase('town council') ? subcountyName.toLowerCase().replace('town council', 'TC') :
                subcountyName.toLowerCase().replace(' tc', ' town council');
            subcounty = [
                SELECT
                    Id
                FROM
                    Subcounty__c
                WHERE
                    Display_Name__c = :subcountyName
                LIMIT 1
            ];
        }
        if(subcounty.isEmpty()){
            System.debug(LoggingLevel.INFO, 'subcounty not found. trying wild card at the end');
            subcounty = [
                SELECT
                    Id
                FROM
                    Subcounty__c
                WHERE
                    Display_Name__c LIKE :subcountyName + '%'
                LIMIT 1
            ];
        }

        if(subcounty.isEmpty()){
            return new String[]{ '0', 'The subcounty provided is not in salesforce', 'SUPRESSMSG' };
        }

        String subcountyId = subcounty[0].Id;
        system.debug(LoggingLevel.INFO, 'subcounty id ' + subcountyId);
        
        // Load the metrics for the month that the submission is for
        List<String> metricNames = new List<String> { 
            'FHI_CC_number_groups',
            'FHI_CC_number_youth_members',
            'FHI_CC_number_total_group_members',

            'FHI_CC_number_women_and_women_with_men_groups',
            'FHI_CC_number_youth_groups',
            'FHI_CC_number_producer_slash_farmer_groups',
            'FHI_CC_number_other_groups',

            'FHI_CC_percentage_female_members',
            'FHI_percentage_youth_group_members'
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
                AND M_E_Metric__r.Name IN :metricNames
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
            if (key.equals('FHI_CC_number_groups')) {
                totalNewData.Denumerator__c++;
            }
            else if(key.equals('FHI_CC_number_women_and_women_with_men_groups')){
                if(groupType.equals('Women')){
                    totalNewData.Denumerator__c++;
                }
            }
            else if(key.equals('FHI_CC_number_youth_groups')){
                if(groupType.equals('Youth')){
                    totalNewData.Denumerator__c++;
                }
            }
            else if(key.equals('FHI_CC_number_producer_slash_farmer_groups')){
                if(groupType.equals('Producer/Farmers')){
                    totalNewData.Denumerator__c++;
                }
            }
            else if(key.equals('FHI_CC_number_other_groups')){
                if(groupType.equals('Other')){
                    totalNewData.Denumerator__c++;
                }
            }
            else if(key.equals('FHI_CC_number_youth_members')){
                if(groupType.equals('Youth')){
                    totalNewData.Denumerator__c += malesInGroup + femalesInGroup;
                }
            }
            else if(key.equals('FHI_percentage_youth_group_members')){
                if(groupType.equals('Youth')){
                    totalNewData.Numerator__c += malesInGroup + femalesInGroup;
                    totalNewData.Denumerator__c += malesInGroup + femalesInGroup;
                }
                else{
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
        
        if (surveyName.containsIgnoreCase('North')) {
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

        boolean isThereAnOvc = false;
        String typeOfHH = answers.get('typehh_0') != null ? answers.get('typehh_0').Answer__c : '';
        isThereAnOvc = typeOfHH == '2';
        //in case this question was not asked, revert to answer below
        isThereAnOvc = typeOfHH == '' ? ProcessSubmissionHelpers.checkIfYes(answers.get('ovc_0').Answer__c) : isThereAnOvc;

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
            totalNewData = totalNewData == null ? createNewMetric(key, currentDate, subcountyId) : totalNewData;
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

    /**
     *  Process the CKW monitoring submissions
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
    public static List<String> processCkwMonitoring(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers,  Person__c submitter, String surveyName) {
        boolean isNorth = false;
        boolean isCCO = false;
        if (surveyName.containsIgnoreCase('North')) {
            isNorth = true;
        }
        if (surveyName.startsWithIgnoreCase('CCO')) {
            isCCO = true;
            boolean isCkwPresent = ProcessSubmissionHelpers.checkIfYes(answers.get('ckw_0').Answer__c);
            if(isCkwPresent){
                return new String[] { '1', 'Submission successfull for FHI Dashboard  with IMEI: ' + submission.imei, 'SUPRESSMSG' };
            }
        }

        Date visitDate = Date.valueOf(answers.get('date_0').Answer__c);
        String district_str = '';
        if(isCCO) {
            district_str = isNorth ? translateCkwMonitoringNorthDistricts(answers.get('district_0').Answer__c) : translateMonitoringSouthDistricts(answers.get('district_0').Answer__c);
        }
        else {
            district_str = isNorth ? translateCkwMonitoringNorthDistricts(answers.get('district_0').Answer__c) : translateMonitoringSouthDistricts(answers.get('district_0').Answer__c);
        }
        String encounter = answers.get('encounter_0').Answer__c;
        District__c[] district = [
            SELECT
                Id,
                Name
            FROM
                District__c
            WHERE
                Name = :district_str
            LIMIT 1
        ];
        if(district.isEmpty()){
            return new String[]{ '0', 'The district provided is incorrect', 'SUPRESSMSG' };
        }

        List<String> metricNames = new List<String> {
            'FHI_monitoring_cco_group_visits',
            'FHI_monitoring_number_males_trained_child_nutrition',
            'FHI_monitoring_number_females_trained_child_nutrition',
            'FHI_monitoring_number_males_trained_vsla',
            'FHI_monitoring_number_females_trained_vsla',
            'FHI_monitoring_number_males_trained_agric',
            'FHI_monitoring_number_females_trained_agric',
            'FHI_monitoring_number_community_dialog_meetings',
            'FHI_monitoring_percent_groups_practicing_swap',
            'FHI_monitoring_ckw_group_visits'
        };
        M_E_Metric_Data__c[] datas = [
            SELECT
                Id,
                Name,
                Actual_Value__c,
                Manual_Value__c,
                District__c,
                Denumerator__c,
                Numerator__c,
                M_E_Metric__r.Name
            FROM
                M_E_Metric_Data__c
            WHERE
                (
                    District__c = :district[0].Id
                )
                AND Date__c >= :visitDate
                AND M_E_Metric__r.Name IN :metricNames
        ];
        // Loop through the data and see which ones we have already got. If they are not there already create them
        Map<String, M_E_Metric_Data__c> dataMap = new Map<String, M_E_Metric_Data__c>();
        for (M_E_Metric_Data__c mData : datas) {
             dataMap.put(mData.M_E_Metric__r.Name, mData);
        }
        // Loop through the list of metrics checking if each exists before updating it
        for (String key : metricNames) {
            // Check that the three metrics for each metric name exists
            M_E_Metric_Data__c totalNewData = dataMap.get(key);
            system.debug(LoggingLevel.INFO, 'Checking for metric name: ' + key);
            if (totalNewData == null) {
                totalNewData = createNewMonitoringMetric(key, visitDate, district[0].Id);
            }
            // Update the metric based on the key
            if (key.equals('FHI_monitoring_ckw_group_visits')) {
                if(encounter.equals('1') && !isCCO) {
                    //means encounter is a group for both CCO and CKW surveys
                    totalNewData.Denumerator__c++;
                }
            }
            else if (key.equals('FHI_monitoring_cco_group_visits')) {
            	String decisiont3 = answers.get('decisiont3_0') == null ? '' : answers.get('decisiont3_0').Answer__c;
                if((encounter.equals('1') && isCCO) || (encounter.equals('2') && decisiont3.equals('3') && isCCO )) {
                    //means encounter is a group for both CCO and CKW surveys; OR for CCO, its a learning site in the Field with a group ID
                    totalNewData.Denumerator__c++;
                }
            }
            else if (key.equals('FHI_monitoring_number_males_trained_child_nutrition')) {
                if(isCCO){
                    //encounter for CCO, 1=>Group, 2=>Learning site, 3=>Meeting, 4=>Household monitoring, 5=>Community mobilization
                    if(encounter.equals('2')) {
                        //learning site
                        //decisiont4 1 => Agriculture, 2 => Nutrition, 3 => Combined
                        String decisiont4 = answers.get('decisiont4_0') == null ? '' : answers.get('decisiont4_0').Answer__c;
                        if(decisiont4.equals('2') || decisiont4.equals('3')) {
                            //nutrition = nutrition section + combined section
                            String malesAttending = answers.get('lsmales_0').Answer__c;
                            totalNewData.Denumerator__c += Integer.valueOf(malesAttending);
                        }                        
                    }
                }
                else {
                    //decisiont2 1 => Dialogue, 2 => VSLA, 3 => Learning site
                    String decisiont2 = answers.get('decisiont2_0') == null ? '' : answers.get('decisiont2_0').Answer__c;
                    if(decisiont2.equals('3')) {
                        //learning site
                        //decisiont4 1 => Agriculture, 2 => Nutrition, 3 => Combined
                        String decisiont4 = answers.get('decisiont4_0') == null ? '' : answers.get('decisiont4_0').Answer__c;
                        if(decisiont4.equals('2') || decisiont4.equals('3')) {
                            //nutrition = nutrition section + combined section
                            String malesAttending = answers.get('lsmales_0').Answer__c;
                            totalNewData.Denumerator__c += Integer.valueOf(malesAttending);
                        }
                    }   
                }
            }
            else if (key.equals('FHI_monitoring_number_females_trained_child_nutrition')) {
                if(isCCO){
                    //encounter for CCO, 1=>Group, 2=>Learning site, 3=>Meeting, 4=>Household monitoring, 5=>Community mobilization
                    if(encounter.equals('2')) {
                        //learning site
                        //decisiont4 1 => Agriculture, 2 => Nutrition, 3 => Combined
                        String decisiont4 = answers.get('decisiont4_0') == null ? '' : answers.get('decisiont4_0').Answer__c;
                        if(decisiont4.equals('2') || decisiont4.equals('3')) {
                            //nutrition = nutrition section + combined section
                            String femalesAttending = answers.get('lsfems_0').Answer__c;
                            totalNewData.Denumerator__c += Integer.valueOf(femalesAttending);
                        }                        
                    }
                }
                else {
                    //decisiont2 1 => Dialogue, 2 => VSLA, 3 => Learning site
                    String decisiont2 = answers.get('decisiont2_0') == null ? '' : answers.get('decisiont2_0').Answer__c;
                    if(decisiont2.equals('3')) {
                        //learning site
                        //decisiont4 1 => Agriculture, 2 => Nutrition, 3 => Combined
                        String decisiont4 = answers.get('decisiont4_0') == null ? '' : answers.get('decisiont4_0').Answer__c;
                        if(decisiont4.equals('2') || decisiont4.equals('3')) {
                            //nutrition = nutrition section + combined section
                            String femalesAttending = answers.get('lsfems_0').Answer__c;
                            totalNewData.Denumerator__c += Integer.valueOf(femalesAttending);
                        }
                    }
                } 
            }
            else if (key.equals('FHI_monitoring_number_males_trained_vsla')) {
                //decisiont2 1 => Dialogue, 2 => VSLA[, 3 => Learning site]
                String decisiont2 = answers.get('decisiont2_0') == null ? '' : answers.get('decisiont2_0').Answer__c;
                if(decisiont2.equals('2')) {
                    //vsla
                    String malesAttending = answers.get('vslamales_0').Answer__c;
                    totalNewData.Denumerator__c += Integer.valueOf(malesAttending);
                }
            }
            else if (key.equals('FHI_monitoring_number_females_trained_vsla')) {
                //decisiont2 1 => Disaloge, 2 => VSLA[, 3 => Learning site]
                String decisiont2 = answers.get('decisiont2_0') == null ? '' : answers.get('decisiont2_0').Answer__c;
                if(decisiont2.equals('2')) {
                    //vsla
                    String femalesAttending = answers.get('vslafems_0').Answer__c;
                    totalNewData.Denumerator__c += Integer.valueOf(femalesAttending);
                }
            }
            else if (key.equals('FHI_monitoring_number_males_trained_agric')) {
                if(isCCO) {
                    //encounter for CCO, 1=>Group, 2=>Learning site, 3=>Meeting, 4=>Household monitoring, 5=>Community mobilization
                    if(encounter.equals('2')) {
                        //learning site
                        //decisiont4 1 => Agriculture, 2 => Nutrition, 3 => Combined
                        String decisiont4 = answers.get('decisiont4_0') == null ? '' : answers.get('decisiont4_0').Answer__c;
                        if(decisiont4.equals('1')) {// || decisiont4.equals('3')) { //combined section not added as its not in specs
                            String malesAttendingFirstTime = answers.get('lsfmales_0').Answer__c;
                            totalNewData.Denumerator__c += Integer.valueOf(malesAttendingFirstTime);
                        }                        
                    }                    
                }
                else {
                    //decisiont2 1 => Disaloge, 2 => VSLA, 3 => Learning site
                    String decisiont2 = answers.get('decisiont2_0') == null ? '' : answers.get('decisiont2_0').Answer__c;
                    if(decisiont2.equals('3')) {
                        //learning site
                        //decisiont4 1 => Agriculture, 2 => Nutrition, 3 => Combined
                        String decisiont4 = answers.get('decisiont4_0') == null ? '' : answers.get('decisiont4_0').Answer__c;
                        if(decisiont4.equals('1')) { // || decisiont4.equals('3') //not adding the combined since its not in specs
                            String malesAttendingFirstTime = answers.get('lsfmales_0').Answer__c;
                            totalNewData.Denumerator__c += Integer.valueOf(malesAttendingFirstTime);
                        }
                    }
                } 
            }
            else if (key.equals('FHI_monitoring_number_females_trained_agric')) {
                if(isCCO) {
                    //encounter for CCO, 1=>Group, 2=>Learning site, 3=>Meeting, 4=>Household monitoring, 5=>Community mobilization
                    if(encounter.equals('2')) {
                        //learning site
                        //decisiont4 1 => Agriculture, 2 => Nutrition, 3 => Combined
                        String decisiont4 = answers.get('decisiont4_0') == null ? '' : answers.get('decisiont4_0').Answer__c;
                        if(decisiont4.equals('1')) {// || decisiont4.equals('3')) { //combined section not added as its not in specs
                            String femalesAttendingFirstTime = answers.get('lsffems_0').Answer__c;
                            totalNewData.Denumerator__c += Integer.valueOf(femalesAttendingFirstTime);
                        }                        
                    }                    
                }
                else {
                    //decisiont2 1 => Dialogue, 2 => VSLA, 3 => Learning site
                    String decisiont2 = answers.get('decisiont2_0') == null ? '' : answers.get('decisiont2_0').Answer__c;
                    if(decisiont2.equals('3')) {
                        //learning site
                        //decisiont4 1 => Agriculture, 2 => Nutrition, 3 => Combined
                        String decisiont4 = answers.get('decisiont4_0') == null ? '' : answers.get('decisiont4_0').Answer__c;
                        if(decisiont4.equals('1')) { // || decisiont4.equals('3') //not adding the combined since its not in specs
                            String femalesAttendingFirstTime = answers.get('lsffems_0').Answer__c;
                            totalNewData.Denumerator__c += Integer.valueOf(femalesAttendingFirstTime);
                        }
                    } 
                }
            }
            else if (key.equals('FHI_monitoring_number_community_dialog_meetings')) {
                //decisiont2 1 => Dialogue, 2 => VSLA[, 3 => Learning site]
                String decisiont2 = answers.get('decisiont2_0') == null ? '' : answers.get('decisiont2_0').Answer__c;
                if(decisiont2.equals('1')) {
                    //dialogue
                    totalNewData.Denumerator__c++;
                }
            }
            else if (key.equals('FHI_monitoring_percent_groups_practicing_swap')) {
                 totalNewData.Denumerator__c++;

                //decisiont2 1 => Dialogue, 2 => VSLA[, 3 => Learning site]
                String decisiont2 = answers.get('decisiont2_0') == null ? '' : answers.get('decisiont2_0').Answer__c;
                if(decisiont2.equals('2')) {
                    //vsla
                    Boolean practicesSwap = ProcessSubmissionHelpers.checkIfYes(answers.get('swap_0').Answer__c);
                    if(practicesSwap){
                        totalNewData.Numerator__c++;
                    }
                }
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
    
    /**
     * reads the custom config settings and returns districts in the region specified
     * @param regionName    Name of an FHI region
     * @return List of string district names
     */
    public static List<String> getDistrictsInRegion(String regionName) {
        List<FHI_District_Region__c> districtRegions = regionName == null ? 
            [SELECT Id, FHI_Region__c, Name FROM FHI_District_Region__c ORDER BY Name] :
            [SELECT Id, FHI_Region__c, Name FROM FHI_District_Region__c WHERE FHI_Region__c = :regionName ORDER BY Name];
        List<String> districtNames = new List<String>();
        for(FHI_District_Region__c entry : districtRegions){
            districtNames.add(entry.Name);  
        }
        return districtNames;	
    }

    /**
     *  Find out which district was selected based on the binding
     *
     *  @param districtValue - A map containing the values for the district
     *
     *  @return - District name
     */
    private static String translateCkwMonitoringNorthDistricts(String districtValue) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Masindi',
            '2' => 'Kiryandongo',
            '3' => 'Lira',
            '4' => 'Oyam',
            '5' => 'Kole',
            '6' => 'Dokolo',
            '7' => 'Pader',
            '8' => 'Agago',
            '9' => 'Nebbi'
        };
        return translationMap.get(districtValue);
    }

    /**
     *  Find out which district was selected based on the binding
     *
     *  @param districtValue - A map containing the values for the district
     *
     *  @return - District name
     */
    private static String translateMonitoringSouthDistricts(String districtValue) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Ibanda',
            '2' => 'Kisoro',
            '3' => 'kasese',
            '4' => 'Kanungu',
            '5' => 'Kamwenge',
            '6' => 'Kabale'
        };
        return translationMap.get(districtValue);
    }

    /**
     * Loops through all the members whilst checking to see if there exists a household head whos is female
     *
     * @param answers - a map containing all answers in the submission
     * @param houseHeadBinding - binding for the question whose answer determines whether the member is a house head
     * @param houseHeadSexBinding - binding for the question whose answer determines the sex of the member
     */
    private static boolean isThereAfemaleHouseHead(Map<String, Submission_Answer__c> answers, String houseHeadBinding, String houseHeadSexBinding){
        Integer counter = 0;
        while(answers.containsKey(houseHeadBinding + counter)){
            if(answers.get(houseHeadBinding + counter).Answer__c.equals('1') && answers.get(houseHeadSexBinding + counter).Answer__c.equals('2')){
                return true;
            }
            counter++;
        }
        return false;
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
     *  Create a new metric data for a given district, start date and metric. Assume that the metric is created on the box
     *
     *  @param key       - The M_E_Metric.Name value that is being created
     *  @param startDate - The date that the metric period starts
     *  @param districtId   - The divider that the metric is split by
     *
     *  @return - The newly created M_E_Metric_Data object
     */
    private static M_E_Metric_Data__c createNewMonitoringMetric(String key, Date startDate, Id districtId) {

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
     * selection indeces 1 2 3 and 4 are the required fruits.
     * If all of the fruit indeces appear in the cropSelection, we return true
     * 
     * @param cropsSelection a list of indeces selected by the user
     * 
     * @return <code>true<code> if at least one fruit index is in the cropSelection, false otherwise
     */
    private static boolean checkIfHasFruitTrees(Set<String> cropsSelection){

        if(cropsSelection == null || cropsSelection.isEmpty()) {
            return false;
        }

        Set<String> fruitIndeces = new Set<String>{'1', '2', '3', '4'};
        for(String index: fruitIndeces){
            if(!cropsSelection.contains(index)){
                return false;
            }
        }
        return true;
    }

    /**
     * The user's selection map is;
     *       '1' => 'Amaranth',
     *       '2' => 'Avacado',
     *       '3' => 'Guavas',
     *       '4' => 'Jack fruit',
     *       '5' => 'Mangoes',
     *       '6' => 'Oranges',
     *       '7' => 'Pawpaw',
     *       '8' => 'Pumpkin',
     *       '9' => 'Tree tomatoes',
     *       '10' => 'Other',
     *       '11' => 'None'
     * selection indeces 1 2 7 and 8 are the required fruits.
     * If all of the fruit indeces appear in the cropSelection, we return true
     * 
     * @param cropsSelection a list of indeces selected by the user
     * 
     * @return <code>true<code> if at least one fruit index is in the cropSelection, false otherwise
     */
    private static boolean checkIfHasFruitTreesInOldSurveys(Set<String> cropsSelection){

        if(cropsSelection == null || cropsSelection.isEmpty()) {
            return false;
        }

        Set<String> fruitIndeces = new Set<String>{'1', '2', '7', '8'};
        for(String index: fruitIndeces){
            if(!cropsSelection.contains(index)){
                return false;
            }
        }
        return true;
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

    public static void getRawDataStats(){
        Server_Configuration__c configuration = [
            SELECT
                URL__c,
                Survey_Database__c,
                Search_Database__c
            FROM
                Server_Configuration__c LIMIT 1];

        String extensionToolQuery = 'CALL CountHouseHoldVisitsMadeWithExtensionTool()';
        String requestBody = String.format(
            '<?xml version="1.0"?>' +
            '<SelectRequest xmlns="http://schemas.applab.org/2010/07" target="{0}">{1}</SelectRequest>',
            new List<String>{ 'Surveys', extensionToolQuery } );
        
        String testResult = '<?xml version="1.0"?><SelectResponse xmlns="http://schemas.applab.org/2010/07"><row><FHI_CC_number_extension_tool_HH_visits>54706</FHI_CC_number_extension_tool_HH_visits></row></SelectResponse>';
        String queryResult = Test.isRunningTest() ? testResult : SqlHelpers.postServletRequest(configuration.URL__c, 'select', requestBody);
        System.debug(requestBody);
        System.debug(queryResult);
        
        //callouts have to be before DML, so make next callout
        String submissionsQuery = 'CALL GetFHISurveysSubmissionTotals()';
        requestBody = String.format(
            '<?xml version="1.0"?>' +
            '<SelectRequest xmlns="http://schemas.applab.org/2010/07" target="{0}">{1}</SelectRequest>',
            new List<String>{ 'Surveys', submissionsQuery } );

        testResult = '<?xml version="1.0"?><SelectResponse xmlns="http://schemas.applab.org/2010/07"><row><FHI_HH_number_households_registered_x>500</FHI_HH_number_households_registered_x><FHI_CC_number_groups>20</FHI_CC_number_groups><FHI_CC_number_youth_groups>30</FHI_CC_number_youth_groups><FHI_CC_number_women_and_women_with_men_groups>40</FHI_CC_number_women_and_women_with_men_groups><FHI_CC_number_producer_slash_farmer_groups>60</FHI_CC_number_producer_slash_farmer_groups><FHI_CC_number_other_groups>50</FHI_CC_number_other_groups></row></SelectResponse>';
        String queryResult2 = Test.isRunningTest() ? testResult : SqlHelpers.postServletRequest(configuration.URL__c, 'select', requestBody);
        System.debug(requestBody);        
        processRawDataSubmissionStats(queryResult2);
        
        //create a xml doc for reading data
        DOM.Document doc = new DOM.Document();
        doc.load(queryResult);
        Dom.XmlNode envelope = doc.getRootElement();
        Dom.XmlNode row = envelope.getChildElement('row', 'http://schemas.applab.org/2010/07');
        Dom.XmlNode column = row.getChildElement('FHI_CC_number_extension_tool_HH_visits', 'http://schemas.applab.org/2010/07');

        Integer householdVisits = Integer.valueOf(column.getText());

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
                M_E_Metric__r.Name = 'FHI_CC_number_extension_tool_HH_visits'
            ORDER BY 
                Date__c DESC 
            LIMIT 1];

        M_E_Metric_Data__c datum = datas[0];
        datum.Manual_Value__c = householdVisits;
        update datum;      
    }
    
    public static void processRawDataSubmissionStats(String queryResult){
        List<String> metricNames = new List<String> {
            'FHI_HH_number_households_registered_x',
            'FHI_CC_number_groups',
            'FHI_CC_number_other_groups',
            'FHI_CC_number_producer_slash_farmer_groups',
            'FHI_CC_number_women_and_women_with_men_groups',
            'FHI_CC_number_youth_groups'
        };
        List<M_E_Metric__c> metrics = [SELECT Id, Name, Sub_Area__c FROM M_E_Metric__c WHERE Name IN :metricNames];
        Server_Configuration__c configuration = [
            SELECT
                URL__c,
                Survey_Database__c,
                Search_Database__c
            FROM
                Server_Configuration__c LIMIT 1];

        System.debug(queryResult);
        
        //create a xml doc for reading data
        DOM.Document doc = new DOM.Document();
        doc.load(queryResult);
        Dom.XmlNode envelope = doc.getRootElement();
        Dom.XmlNode row = envelope.getChildElement('row', 'http://schemas.applab.org/2010/07');
        for(Dom.XmlNode column : row.getChildElements()){
            updateMetricDataWithStats(column);
        }
    }
    
    /**
     * reads the name of the xml node as the name of the M&E metric detail to update
     * the value is the text element in the xml node
     *
     * @param column the Dom.XmlNode object with the results
     */
    public static void updateMetricDataWithStats(Dom.XmlNode column){
        String name = column.getName();
        Integer figure = Integer.valueOf(column.getText());
        List<M_E_Metric__c> metrics = [SELECT Id, Name, Sub_Area__c FROM M_E_Metric__c WHERE Name = :name LIMIT 1];
        if(!metrics.isEmpty()){
            M_E_Metric__c metric = metrics.get(0);
            metric.Sub_Area__c = figure.format(); 
            update metric;
        }   
    }
    
    static testmethod void testStatsImport(){
        
        Server_Configuration__c config = new Server_Configuration__c();
        config.URL__c = 'http://some.site';
        config.Search_Database__c = 'some.db';
        config.Survey_Database__c = 'some.other.db';
        insert config;
        
        List<String> metricNames = new List<String> {
            'FHI_HH_number_households_registered_x',
            'FHI_CC_number_groups',
            'FHI_CC_number_other_groups',
            'FHI_CC_number_producer_slash_farmer_groups',
            'FHI_CC_number_women_and_women_with_men_groups',
            'FHI_CC_number_youth_groups',
            'FHI_CC_number_extension_tool_HH_visits'
        };
        Account org = Utils.createTestOrganisation('TestOrg1');
        database.insert(org);
        for(String metricName : metricNames){
            M_E_Metric__c metric = createTestMetric(org, 'None', 'Impact', true, metricName);
            insert metric;            
        }
                
        M_E_Metric_Data__c metric_hh = new M_E_Metric_Data__c();
        metric_hh.Date__c = Date.today();
        metric_hh.M_E_Metric__c = [select Id, Name from M_E_Metric__c where Name = :metricNames.get(6) LIMIT 1].get(0).Id;
        insert metric_hh;
        
        getRawDataStats();
        
        M_E_Metric__c m = [Select Id, Name, Sub_Area__c from M_E_Metric__c where Name = :metricNames.get(0)];
        System.assert(m.Sub_Area__c != null);
        System.assert(m.Sub_Area__c.equals('500'));
        
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
                M_E_Metric__r.Name = 'FHI_CC_number_extension_tool_HH_visits'
            ORDER BY 
                Date__c DESC 
           LIMIT 1];
        M_E_Metric_Data__c data = datas[0];
        System.assert(data.Manual_Value__c == 54706);
    }
    
    public static M_E_Metric__c createTestMetric(Account org, String calculationType, String area, Boolean subDivide,
            String appendCharacters) {

        M_E_Metric__c metric = new M_E_Metric__c();
        metric.Name = appendCharacters;
        metric.Organisation__c = org.Id;
        metric.Calculation_Type__c = calculationType;
        metric.M_E_Area__c = area;
        metric.Sub_Divide__c = subDivide;
        metric.Update_Period__c = 'Daily';
        return metric;
    }
    
    static testmethod void testFhiGroupSurveyProcessing() {
        
        Account testOrg = new Account();
        testOrg.Name = 'TestCKW';
        testOrg.BillingState = 'CA';
        database.SaveResult accountSaveResult = database.insert(testOrg);

        Dashboard__c dash = new Dashboard__c();
        dash.Account__c = accountSaveResult.getId();
        dash.Is_Active__c = true;
        dash.Title__c = 'testing';
        database.SaveResult dashSaveResult = database.insert(dash);

        Dashboard_Section__c dashSection = new Dashboard_Section__c();
        dashSection.Dashboard__c = dashSaveResult.getId();
        dashSection.Is_Active__c = true;
        dashSection.Title__c = 'FHI';
        database.SaveResult dashSectionSaveResult = database.insert(dashSection);

        Metric_Section__c ciwDistanceMetricSection = new Metric_Section__c();
        ciwDistanceMetricSection.Is_Active__c = true;
        ciwDistanceMetricSection.Dashboard_Section__c = dashSectionSaveResult.getId();
        ciwDistanceMetricSection.Title__c = 'test test';
        ciwDistanceMetricSection.Start_Date__c = date.today();
        ciwDistanceMetricSection.Default_Show__c = 1;
        database.SaveResult metricSectionSaveResult = database.insert(ciwDistanceMetricSection);

        // Create the metrics for use
        List<String> metricNames = new List<String> { 
            'FHI_CC_number_groups',
            'FHI_CC_number_youth_members',
            'FHI_CC_number_total_group_members',

            'FHI_CC_number_women_and_women_with_men_groups',
            'FHI_CC_number_youth_groups',
            'FHI_CC_number_producer_slash_farmer_groups',
            'FHI_CC_number_other_groups',

            'FHI_CC_percentage_female_members',
            'FHI_percentage_youth_group_members'
        };
        
        List<M_E_Metric__c> metrics = new List<M_E_Metric__c>();
        for(String name : metricNames){
            M_E_Metric__c metric1 = new M_E_Metric__c();
            metric1.Name = name;
            metric1.Metric_Section__c = metricSectionSaveResult.getId();
            metric1.Organisation__c = accountSaveResult.getId();
            metrics.add(metric1);
        } 
        insert metrics;
        
        Survey__c survey = new Survey__c();
        survey.Account__c = accountSaveResult.getId();
        survey.Post_Processing_Method__c = 'FHI_GROUP_REGISTRATION';
        survey.Survey_Name__c = 'CC group register North';
        survey.Survey_Status__c = 'Published';
        survey.Start_Date__c = Date.valueOf('2013-01-01');
        survey.End_Date__c = Date.today().addYears(2);
        insert survey;

        District__c testDistrict = new District__c();
        testDistrict.Name = 'Pader';
        testDistrict.Region__c = 'North';
        insert testDistrict;
        District__c testDistrict1 = new District__c();
        testDistrict1.Name = 'Kabale';
        testDistrict1.Region__c = 'South';
        insert testDistrict1;
        
        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'Test town council';
        testSubcounty.District__c = [select Id from District__c where Name = :testDistrict.Name].get(0).Id;
        insert testSubcounty;

        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = '123456789101112';
        testHandset.Serial_Number__c = '123456789101112';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert testHandset;

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'David';
        testPerson.Last_Name__c = 'Mugume' ;
        testPerson.Gender__c = 'Male';
        testPerson.District__c = ((District__c)[select Id from District__c where Name = :testDistrict.Name]).Id;
        Phone__c phone = ([select Id from Phone__c where IMEI__c = '123456789101112'])[0];
        testPerson.Handset__c = phone.Id;
        testPerson.Type__c = IGDashboardHelpers.IG_PERSON_TYPE_NAME;
        insert testPerson;
        
        //create submission object
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        //submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '123456789101112';
        submission.resultHash = '2';
        submission.surveyId = [select Id, Name from Survey__c where Id = :survey.Id].Name;

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        List<String> returnValues = new List<String>();
        
        returnValues = FHISurveysHelpers.processGroupRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('No handset submit time in this submission'));
        
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        
        //put answers into our submission
        answers.put('regdate_0', Utils.createTestSubmissionAnswer(null, 'regdate', '2014-06-16', null, null, null));
        answers.put('district_0', Utils.createTestSubmissionAnswer(null, 'district', '1', null, null, null));
        answers.put('subcounty_0', Utils.createTestSubmissionAnswer(null, 'subcounty', 'unknown', null, null, null));
        answers.put('grptype_0', Utils.createTestSubmissionAnswer(null, 'grptype', '1', null, null, null));//farmer/producer group type
        answers.put('num_males_0', Utils.createTestSubmissionAnswer(null, 'num_males', '15', null, null, null));
        answers.put('num_females_0', Utils.createTestSubmissionAnswer(null, 'num_females', '21', null, null, null));

        returnValues = FHISurveysHelpers.processGroupRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('The subcounty provided is not in salesforce'));
        
        answers.put('subcounty_0', Utils.createTestSubmissionAnswer(null, 'subcounty', 'Test tc', null, null, null));
        returnValues = FHISurveysHelpers.processGroupRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('All metric data updated for FHI Dashboard'));
        
        //women group type
        answers.put('grptype_0', Utils.createTestSubmissionAnswer(null, 'grptype', '2', null, null, null));
        returnValues = FHISurveysHelpers.processGroupRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('All metric data updated for FHI Dashboard'));
        
        //youth group type
        answers.put('grptype_0', Utils.createTestSubmissionAnswer(null, 'grptype', '3', null, null, null));
        returnValues = FHISurveysHelpers.processGroupRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('All metric data updated for FHI Dashboard'));
        
        //other group type
        answers.put('grptype_0', Utils.createTestSubmissionAnswer(null, 'grptype', '4', null, null, null));
        returnValues = FHISurveysHelpers.processGroupRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('All metric data updated for FHI Dashboard'));
        
        //NOW FOR OLD SURVEYS        
        survey.Survey_Name__c = 'CC group South';
        update survey;
        
        submission.handsetSubmitTime = null;
        returnValues = FHISurveysHelpers.processGroupRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('No handset submit time in this submission'));
        
        answers = new Map<String, Submission_Answer__c>();
        returnValues = new List<String>();
        
        testSubcounty.Display_Name__c = 'Muko';
        update testSubcounty;
        
        testSubcounty.District__c = [select Id from District__c where Name = :testDistrict1.Name].get(0).Id;
        update testSubcounty;
        
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        
        //put answers into our submission
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', '2014-06-16', null, null, null));
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', '1', null, null, null));
        answers.put('q4_0', Utils.createTestSubmissionAnswer(null, 'q4', '1', null, null, null));
        answers.put('q32_0', Utils.createTestSubmissionAnswer(null, 'q32', '1', null, null, null));//farmer/producer group type
        answers.put('q34_0', Utils.createTestSubmissionAnswer(null, 'q34', '15', null, null, null));
        answers.put('q35_0', Utils.createTestSubmissionAnswer(null, 'q35', '21', null, null, null));
        
        returnValues = FHISurveysHelpers.processGroupRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('All metric data updated for FHI Dashboard'));
        
        //women group type
        answers.put('q32_0', Utils.createTestSubmissionAnswer(null, 'q32', '6', null, null, null));
        returnValues = FHISurveysHelpers.processGroupRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('All metric data updated for FHI Dashboard'));
        
        //youth group type
        answers.put('q32_0', Utils.createTestSubmissionAnswer(null, 'q32', '9', null, null, null));
        returnValues = FHISurveysHelpers.processGroupRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('All metric data updated for FHI Dashboard'));
        
        //other group type
        answers.put('q32_0', Utils.createTestSubmissionAnswer(null, 'q32', '10', null, null, null));
        returnValues = FHISurveysHelpers.processGroupRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('All metric data updated for FHI Dashboard'));
    }
    
    static testmethod void testFhiHouseholdSurveyProcessing() {
        
        Account testOrg = new Account();
        testOrg.Name = 'TestCKW';
        testOrg.BillingState = 'CA';
        database.SaveResult accountSaveResult = database.insert(testOrg);

        Dashboard__c dash = new Dashboard__c();
        dash.Account__c = accountSaveResult.getId();
        dash.Is_Active__c = true;
        dash.Title__c = 'testing';
        database.SaveResult dashSaveResult = database.insert(dash);

        Dashboard_Section__c dashSection = new Dashboard_Section__c();
        dashSection.Dashboard__c = dashSaveResult.getId();
        dashSection.Is_Active__c = true;
        dashSection.Title__c = 'FHI';
        database.SaveResult dashSectionSaveResult = database.insert(dashSection);

        Metric_Section__c ciwDistanceMetricSection = new Metric_Section__c();
        ciwDistanceMetricSection.Is_Active__c = true;
        ciwDistanceMetricSection.Dashboard_Section__c = dashSectionSaveResult.getId();
        ciwDistanceMetricSection.Title__c = 'test test';
        ciwDistanceMetricSection.Start_Date__c = date.today();
        ciwDistanceMetricSection.Default_Show__c = 1;
        database.SaveResult metricSectionSaveResult = database.insert(ciwDistanceMetricSection);

        // Create the metrics for use
        List<String> metricNames = new List<String> { 
            'FHI_HH_number_households_registered_x', 
            'FHI_HH_number_households_vulnerable',
            'FHI_HH_number_households_with_member_in_vsla',
            'FHI_HH_percentage_female_headed_households',
            'FHI_HH_percentage_households_with_cc_fruit_trees_x'
        };
        
        List<M_E_Metric__c> metrics = new List<M_E_Metric__c>();
        for(String name : metricNames){
            M_E_Metric__c metric1 = new M_E_Metric__c();
            metric1.Name = name;
            metric1.Metric_Section__c = metricSectionSaveResult.getId();
            metric1.Organisation__c = accountSaveResult.getId();
            metrics.add(metric1);
        } 
        insert metrics;
        
        Survey__c survey = new Survey__c();
        survey.Account__c = accountSaveResult.getId();
        survey.Post_Processing_Method__c = 'FHI_GROUP_REGISTRATION';
        survey.Survey_Name__c = 'CCHH Register South final';
        survey.Survey_Status__c = 'Published';
        survey.Start_Date__c = Date.valueOf('2013-01-01');
        survey.End_Date__c = Date.today().addYears(2);
        insert survey;

        District__c testDistrict = new District__c();
        testDistrict.Name = 'Pader';
        testDistrict.Region__c = 'North';
        District__c testDistrict1 = new District__c();
        testDistrict1.Name = 'Kamwenge';
        testDistrict1.Region__c = 'South';
        insert new List<District__c>{ testDistrict, testDistrict1 };
        
        Subcounty__c testSubcounty = new Subcounty__c();
        testSubcounty.Display_Name__c = 'Ruhija';
        testSubcounty.District__c = [select Id from District__c where Name = :testDistrict1.Name].get(0).Id;
        Subcounty__c testSubcounty2 = new Subcounty__c();
        testSubcounty2.Display_Name__c = 'Awere';
        testSubcounty2.District__c = [select Id from District__c where Name = :testDistrict.Name].get(0).Id;
        insert new List<Subcounty__c> { testSubcounty, testSubcounty2 };

        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = '123456789101112';
        testHandset.Serial_Number__c = '123456789101112';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert testHandset;

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'David';
        testPerson.Last_Name__c = 'Mugume' ;
        testPerson.Gender__c = 'Male';
        testPerson.District__c = ((District__c)[select Id from District__c where Name = :testDistrict.Name]).Id;
        Phone__c phone = ([select Id from Phone__c where IMEI__c = '123456789101112'])[0];
        testPerson.Handset__c = phone.Id;
        testPerson.Type__c = IGDashboardHelpers.IG_PERSON_TYPE_NAME;
        insert testPerson;
        
        //create submission object
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        //submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '123456789101112';
        submission.resultHash = '2';
        submission.surveyId = [select Id, Name from Survey__c where Id = :survey.Id].Name;

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        List<String> returnValues = new List<String>();
        
        returnValues = FHISurveysHelpers.processHouseholdRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('No handset submit time in this submission'));
        
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        
        //put answers into our submission
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'VH09789', null, null, null));
        answers.put('q2_0', Utils.createTestSubmissionAnswer(null, 'q2', '2014-06-16', null, null, null));
        answers.put('q3_0', Utils.createTestSubmissionAnswer(null, 'q3', '1', null, null, null));
        answers.put('q4_0', Utils.createTestSubmissionAnswer(null, 'q4', '1', null, null, null));
        answers.put('q71_0', Utils.createTestSubmissionAnswer(null, 'q71', '1', null, null, null));
        answers.put('q33_0', Utils.createTestSubmissionAnswer(null, 'q33', '1', null, null, null));
        answers.put('q38_0', Utils.createTestSubmissionAnswer(null, 'q38', '1', null, null, null));
        answers.put('q37_0', Utils.createTestSubmissionAnswer(null, 'q37', '1', null, null, null));

        returnValues = FHISurveysHelpers.processHouseholdRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('All metric data updated for FHI Dashboard'));
                
        //NOW FOR OLD SURVEYS        
        survey.Survey_Name__c = 'HH_registerII_north';
        update survey;
        
        submission.handsetSubmitTime = null;
        returnValues = FHISurveysHelpers.processHouseholdRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('No handset submit time in this submission'));
        
        answers = new Map<String, Submission_Answer__c>();
        returnValues = new List<String>();
        
        testSubcounty.District__c = [select Id from District__c where Name = :testDistrict1.Name].get(0).Id;
        update testSubcounty;
        
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        
        //put answers into our submission
        answers.put('q1_0', Utils.createTestSubmissionAnswer(null, 'q1', 'VH09789', null, null, null));
        answers.put('regdate_0', Utils.createTestSubmissionAnswer(null, 'regdate', '2014-06-16', null, null, null));
        answers.put('district_0', Utils.createTestSubmissionAnswer(null, 'district', '1', null, null, null));
        answers.put('subcounty_0', Utils.createTestSubmissionAnswer(null, 'subcounty', 'unknown', null, null, null));
        answers.put('consent_0', Utils.createTestSubmissionAnswer(null, 'consent', '1', null, null, null));
        answers.put('sexhhh_0', Utils.createTestSubmissionAnswer(null, 'sexhhh', '2', null, null, null));
        answers.put('typehh_0', Utils.createTestSubmissionAnswer(null, 'typehh', '2', null, null, null));
        answers.put('vsla_0', Utils.createTestSubmissionAnswer(null, 'vsla', '1', null, null, null));
        
        answers.put('cc_crops_0', Utils.createTestSubmissionAnswer(null, 'cc_crops', '1', null, null, null));
        answers.put('cc_crops_1', Utils.createTestSubmissionAnswer(null, 'cc_crops', '2', null, null, null));
        answers.put('cc_crops_2', Utils.createTestSubmissionAnswer(null, 'cc_crops', '3', null, null, null));
        answers.put('cc_crops_3', Utils.createTestSubmissionAnswer(null, 'cc_crops', '4', null, null, null));
        
        returnValues = FHISurveysHelpers.processHouseholdRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('The subcounty provided is not in salesforce'));
        
        answers.put('subcounty_0', Utils.createTestSubmissionAnswer(null, 'subcounty', 'Ruhija', null, null, null));
        
        returnValues = FHISurveysHelpers.processHouseholdRegistration(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).contains('All metric data updated for FHI Dashboard'));
    }

    static testmethod void testFhiMonitoringSurveysProcessing() {
        Account testOrg = new Account();
        testOrg.Name = 'TestCKW';
        testOrg.BillingState = 'CA';
        database.SaveResult accountSaveResult = database.insert(testOrg);

        Dashboard__c dash = new Dashboard__c();
        dash.Account__c = accountSaveResult.getId();
        dash.Is_Active__c = true;
        dash.Title__c = 'testing';
        database.SaveResult dashSaveResult = database.insert(dash);

        Dashboard_Section__c dashSection = new Dashboard_Section__c();
        dashSection.Dashboard__c = dashSaveResult.getId();
        dashSection.Is_Active__c = true;
        dashSection.Title__c = 'FHI';
        database.SaveResult dashSectionSaveResult = database.insert(dashSection);

        Metric_Section__c ciwDistanceMetricSection = new Metric_Section__c();
        ciwDistanceMetricSection.Is_Active__c = true;
        ciwDistanceMetricSection.Dashboard_Section__c = dashSectionSaveResult.getId();
        ciwDistanceMetricSection.Title__c = 'test test';
        ciwDistanceMetricSection.Start_Date__c = date.today();
        ciwDistanceMetricSection.Default_Show__c = 1;
        database.SaveResult metricSectionSaveResult = database.insert(ciwDistanceMetricSection);

        // Create the metrics for use
        List<String> metricNames = new List<String> {
            'FHI_monitoring_cco_group_visits',
            'FHI_monitoring_number_males_trained_child_nutrition',
            'FHI_monitoring_number_females_trained_child_nutrition',
            'FHI_monitoring_number_males_trained_vsla',
            'FHI_monitoring_number_females_trained_vsla',
            'FHI_monitoring_number_males_trained_agric',
            'FHI_monitoring_number_females_trained_agric',
            'FHI_monitoring_number_community_dialog_meetings',
            'FHI_monitoring_percent_groups_practicing_swap',
            'FHI_monitoring_ckw_group_visits'
        };
        List<M_E_Metric__c> metrics = new List<M_E_Metric__c>();
        for(String name : metricNames){
            M_E_Metric__c metric1 = new M_E_Metric__c();
            metric1.Name = name;
            metric1.Metric_Section__c = metricSectionSaveResult.getId();
            metric1.Organisation__c = accountSaveResult.getId();
            metrics.add(metric1);
        } 
        insert metrics;

        Survey__c survey = new Survey__c();
        survey.Account__c = accountSaveResult.getId();
        survey.Post_Processing_Method__c = 'FHI_MONITORING';
        survey.Survey_Name__c = 'CKW Monitoring North';
        survey.Survey_Status__c = 'Published';
        survey.Start_Date__c = Date.valueOf('2013-01-01');
        survey.End_Date__c = Date.today().addYears(2);
        insert survey;

        District__c testDistrict = new District__c();
        testDistrict.Name = 'Masindi';
        testDistrict.Region__c = 'Central';
        District__c testDistrict2 = new District__c();
        testDistrict2.Name = 'Ibanda';
        testDistrict2.Region__c = 'Central';
        insert new List<District__c>{ testDistrict, testDistrict2 };

        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = '123456789101112';
        testHandset.Serial_Number__c = '123456789101112';
        testHandset.Purchase_Value_USD__c = 100.00;
        insert testHandset;

        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'David';
        testPerson.Last_Name__c = 'Mugume' ;
        testPerson.Gender__c = 'Male';
        testPerson.District__c = ((District__c)[select Id from District__c where Name = :testDistrict.Name]).Id;
        Phone__c phone = ([select Id from Phone__c where IMEI__c = '123456789101112'])[0];
        testPerson.Handset__c = phone.Id;
        testPerson.Type__c = IGDashboardHelpers.IG_PERSON_TYPE_NAME;
        insert testPerson;

        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '123456789101112';
        submission.resultHash = '1';
        submission.surveyId = [select Id, Name from Survey__c where Id = :survey.Id].Name;

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        List<String> returnValues = new List<String>();

        answers.put('date_0', Utils.createTestSubmissionAnswer(null, 'date', '2014-06-16', null, null, null));
        answers.put('district_0', Utils.createTestSubmissionAnswer(null, 'district', '50', null, null, null));
        answers.put('encounter_0', Utils.createTestSubmissionAnswer(null, 'encounter', '1', null, null, null));

        returnValues = FHISurveysHelpers.processCkwMonitoring(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).contains('The district provided is incorrect'));

        answers.put('district_0', Utils.createTestSubmissionAnswer(null, 'district', '1', null, null, null));
        answers.put('decisiont2_0', Utils.createTestSubmissionAnswer(null, 'decisiont2', '3', null, null, null));
        answers.put('decisiont4_0', Utils.createTestSubmissionAnswer(null, 'decisiont4', '2', null, null, null));
        answers.put('lsmales_0', Utils.createTestSubmissionAnswer(null, 'lsmales', '20', null, null, null));
        answers.put('lsfems_0', Utils.createTestSubmissionAnswer(null, 'lsfems', '20', null, null, null));

        returnValues = FHISurveysHelpers.processCkwMonitoring(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1')); 
        //TODO: add dashboard section, metric section and metrics in order to do tests below
        List<String> metricNames2 = new List<String> {
            'FHI_monitoring_ckw_group_visits',
            'FHI_monitoring_number_males_trained_child_nutrition',
            'FHI_monitoring_number_females_trained_child_nutrition'
        };
        M_E_Metric_Data__c[] datas = [
            SELECT
                Id,
                Name,
                Actual_Value__c,
                Manual_Value__c,
                District__c,
                Denumerator__c,
                Numerator__c,
                M_E_Metric__r.Name
            FROM
                M_E_Metric_Data__c
            WHERE
                (
                    District__c = :testDistrict.Id
                )
                AND Date__c >= :date.valueOf('2014-06-16')
                AND M_E_Metric__r.Name IN :metricNames2
        ];
        for(M_E_Metric_Data__c data : datas){
            if(data.M_E_Metric__r.Name.equals(metricNames2.get(0))){
                System.assert(data.Denumerator__c == 1);
            }
            else if(data.M_E_Metric__r.Name.equals(metricNames2.get(1))){
                System.assert(data.Denumerator__c == 20);
            }
            else if(data.M_E_Metric__r.Name.equals(metricNames2.get(2))){
                System.assert(data.Denumerator__c == 20);
            }
        }
         

        //----------CCO & CKW--------------------- 
        //FHI_monitoring_number_females_trained_vsla
        //FHI_monitoring_number_males_trained_vsla
        answers.put('decisiont2_0', Utils.createTestSubmissionAnswer(null, 'decisiont2', '2', null, null, null));
        answers.put('decisiont4_0', Utils.createTestSubmissionAnswer(null, 'decisiont4', '2', null, null, null));
        answers.put('vslafems_0', Utils.createTestSubmissionAnswer(null, 'vslafems', '5', null, null, null));
        answers.put('vslamales_0', Utils.createTestSubmissionAnswer(null, 'vslamales', '5', null, null, null));
        answers.put('swap_0', Utils.createTestSubmissionAnswer(null, 'swap', '1', null, null, null));

        returnValues = FHISurveysHelpers.processCkwMonitoring(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1')); 

        //-----------CKW---------
        //FHI_monitoring_number_males_trained_agric
        //FHI_monitoring_number_females_trained_agric
        answers.put('decisiont2_0', Utils.createTestSubmissionAnswer(null, 'decisiont2', '3', null, null, null));
        answers.put('decisiont4_0', Utils.createTestSubmissionAnswer(null, 'decisiont4', '1', null, null, null));
        answers.put('lsfmales_0', Utils.createTestSubmissionAnswer(null, 'lsfmales', '30', null, null, null));
        answers.put('lsffems_0', Utils.createTestSubmissionAnswer(null, 'lsffems', '30', null, null, null));

        returnValues = FHISurveysHelpers.processCkwMonitoring(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1')); 

        //-----------CCO & CKW----------------
        //FHI_monitoring_number_community_dialog_meetings
        answers.put('decisiont2_0', Utils.createTestSubmissionAnswer(null, 'decisiont2', '1', null, null, null));

        returnValues = FHISurveysHelpers.processCkwMonitoring(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1')); 

        survey.Survey_Name__c = 'CCO Monitoring South';
        update survey;

        testDistrict.Name = 'Ibanda';
        update testDistrict;

        //-----------CCO---------
        //FHI_monitoring_number_females_trained_child_nutrition
        //FHI_monitoring_number_males_trained_child_nutrition
        answers.put('district_0', Utils.createTestSubmissionAnswer(null, 'district', '1', null, null, null));
        answers.put('encounter_0', Utils.createTestSubmissionAnswer(null, 'encounter', '2', null, null, null));
        answers.put('decisiont3_0', Utils.createTestSubmissionAnswer(null, 'decisiont3', '3', null, null, null));
        answers.put('decisiont4_0', Utils.createTestSubmissionAnswer(null, 'decisiont4', '2', null, null, null));
        answers.put('lsmales_0', Utils.createTestSubmissionAnswer(null, 'lsmales', '60', null, null, null));
        answers.put('lsfems_0', Utils.createTestSubmissionAnswer(null, 'lsfems', '60', null, null, null));
        answers.put('ckw_0', Utils.createTestSubmissionAnswer(null, 'ckw', '2', null, null, null));

        returnValues = FHISurveysHelpers.processCkwMonitoring(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1')); 

        //-----------CCO---------
        //FHI_monitoring_number_males_trained_agric
        //FHI_monitoring_number_females_trained_agric
        answers.put('encounter_0', Utils.createTestSubmissionAnswer(null, 'encounter', '2', null, null, null));
        answers.put('decisiont4_0', Utils.createTestSubmissionAnswer(null, 'decisiont4', '1', null, null, null));
        answers.put('lsffems_0', Utils.createTestSubmissionAnswer(null, 'lsffems', '70', null, null, null));
        answers.put('lsfmales_0', Utils.createTestSubmissionAnswer(null, 'lsfmales', '70', null, null, null));

        returnValues = FHISurveysHelpers.processCkwMonitoring(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1'));  
        
        //if ckw is present, ignores this dataset and returns successful
        answers = new Map<String, Submission_Answer__c>();
        answers.put('ckw_0', Utils.createTestSubmissionAnswer(null, 'ckw', '1', null, null, null));

        returnValues = FHISurveysHelpers.processCkwMonitoring(submission, answers, testPerson, survey.Survey_Name__c);
        System.assert(returnValues.get(0).equals('1'));
    }
 }