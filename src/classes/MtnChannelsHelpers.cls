/**
 *  Helper class for the MTN Channels
 */
public with sharing class MtnChannelsHelpers {

    /**
     *  Fill in the MTN_Channels_Activity__c objects for this Channels staff member
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param person     - The Person__c object for the staff member who submitted the form
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the CKW if required.
     */
    public static List<String> processChannelsFFPSSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {

        // Load the TDR
        MTN_Channels_Staff__c mtnChanStaff = loadMtnChanStaff(person);
        if (mtnChanStaff == null) {

            //Send an email saying that an unregistered person is trying to act a TDR

            // Send back the error message
            return new String[] { '0', 'User with handset Id ' + submission.imei + ' is not a MTN Channels Staff Member', 'SUPRESSMSG' };
        }

        MTN_Channels_Activity__c activity = new MTN_Channels_Activity__c();

        // Sort out the start and end times for the survey
        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
        }
        activity.End_Time__c = handsetSubmitTime;
        DateTime submissionStartTime = ProcessSurveySubmission.getTimestamp(submission.submissionStartTime);
        if (submissionStartTime == null) {
            return new String[] { '0', 'No Submission Start Time.', 'SUPRESSMSG' };
        }
        activity.Start_Time__c = submissionStartTime;

        // Sort out the GPS for the submission. Look for the one in the survey. If that does not exist then use the background gps for the survey
        String[] gps = answers.get('q50_0').Answer__c.split(' ');
        String latitude = submission.interviewLatitude;
        String longitude = submission.interviewLongitude;
        if (gps.size() > 2) {
            latitude = gps[0];
            longitude = gps[1];
        }
        activity.Latitude__c = latitude;
        activity.Longitude__c = longitude;

        // Decide upon the type of activity that is being carried out
        String submissionType = getAnswerString(answers.get('q1_0'));
        if (submissionType.equals('3')) {
            activity.Activity_Type__c = 'Promotion';
            activity.Region__c = person.Region__r.Id;
            activity = parsePromotion(answers, activity);
        }
        else {
            activity = processOutletVisit(submissionType, submission, answers, person, activity);
        }
        activity.Person__c = person.Id;

        // Save the activity now
        Database.insert(activity);

        return new List<String> { '1', 'Activity for staff member with IMEI ' + submission.Imei + ' of type ' + translateType(submissionType) + ' has be saved successfully', 'SUPRESSMSG' };
    }

    /**
     * Parse in fill in the activity for a promotional activity
     *
     * @param answers  - A map containing the values for the the outlet visit
     *                      The keys are <binding>_<instance> for compatibility
     * @param activity - The activity object for this visit
     *
     * @return - The activity
     */
    private static MTN_Channels_Activity__c parsePromotion(Map<String, Submission_Answer__c> answers, MTN_Channels_Activity__c activity) {

        String promotionType = translatePromotionType(getAnswerString(answers.get('q40_0')));
        activity.Promotion_Type__c = promotionType;
        activity.Promotion_Type_Other__c = getAnswerString(answers.get('q41_0'));
        activity.Sales_Easy_Load__c = getAnswerNumber(answers.get('q44_0'), 'q44_0', true);
        activity.Sales_Modems__c = getAnswerNumber(answers.get('q45_0'), 'q45_0', true);
        activity.Sales_Phones__c = getAnswerNumber(answers.get('q43_0'), 'q43_0', true);
        activity.Sales_Scratch_Cards__c = getAnswerNumber(answers.get('q42_0'), 'q42_0', true);
        activity.Sales_Sim_Cards__c = getAnswerNumber(answers.get('q46_0'), 'q46_0', true);
        activity.SIM_Registration_New__c = getAnswerNumber(answers.get('q47_0'), 'q47_0', true);
        activity.SIM_Registration_Existing__c = getAnswerNumber(answers.get('q48_0'), 'q48_0', true);
        activity.Comment__c = getAnswerString(answers.get('q49_0'));
        return activity;
    }

    /**
     *Parse and fill in the activity for an outlet visit
     *
     * @param submissionType - Indicates if this is a new or an eixisting outlet
     * @param submission     - The submission object being processed
     * @param answers        - A map containing the values for the the outlet visit
     *                            The keys are <binding>_<instance> for compatibility
     * @param person         - The Person__c object for the staff member who submitted the form
     * @param activity       - The activity object for this visit
     *
     * @return - The activity
     */
    private static MTN_Channels_Activity__c processOutletVisit(
            String submissionType,
            ProcessSurveySubmission.SurveySubmission submission,
            Map<String, Submission_Answer__c> answers,
            Person__c person,
            MTN_Channels_Activity__c activity
    ) {

        if (submissionType.equals('1')) {
            activity.Activity_Type__c = 'Existing Outlet';
        }
        else {
            activity.Activity_Type__c = 'New Outlet';
        }

        activity.Outlet_Name__c = answers.get('q2_0').Answer__c;
        activity.Outlet_Attendants_Name__c = answers.get('q3_0').Answer__c;
        activity.Attendants_Number__c  = answers.get('q4_0').Answer__c;
        activity.Outlet_Type__c  = translateOutletType(answers.get('q5_0').Answer__c);

        // Sort out the dealership this is for. This requires getting the region out from the survey.
        Region__c region = getRegion(getAnswerString(answers.get('q6_0')));
        activity.Dealership__c = getDealership(translateDealerShipName(answers, getAnswerString(answers.get('q6_0'))), region).Id;
        activity.Region__c = region.Id;

        // Pull out the town
        activity.Town__c = answers.get('q13_0').Answer__c;

        // Pull out the stock levels
        activity.AS_Modems__c = getAnswerNumber(answers.get('q14_0'), 'q14_0', true);
        activity.IS_Modems__c = getAnswerNumber(answers.get('q15_0'), 'q15_0', true);
        activity.AS_Phones__c = getAnswerNumber(answers.get('q16_0'), 'q16_0', true);
        activity.IS_Phones__c = getAnswerNumber(answers.get('q17_0'), 'q17_0', true);
        activity.AS_Easy_Load__c = getAnswerNumber(answers.get('q18_0'), 'q18_0', true);
        activity.IS_Easy_Load__c = getAnswerNumber(answers.get('q19_0'), 'q19_0', true);
        activity.AS_Scratch_Cards__c = getAnswerNumber(answers.get('q20_0'), 'q20_0', true);
        activity.IS_Scratch_Cards__c = getAnswerNumber(answers.get('q21_0'), 'q21_0', true);
        activity.AS_Sim_Packs__c = getAnswerNumber(answers.get('q22_0'), 'q22_0', true);
        activity.IS_Sim_Packs__c = getAnswerNumber(answers.get('q23_0'), 'q23_0', true);

        // Sort out the DSD
        activity = parseDsd(getAnswerSet(answers.get('q24_0')), activity);
        activity.DSD__c = getAnswerString(answers.get('q26_0'));

        // Who is stocked
        activity = parseCompany(activity, answers.get('q28_0'), 'Sell', getAnswerSet(answers.get('q27_0')));

        // Sell most of
        activity = parseSellMost(activity, answers);

        // Sell second most of
        activity = parseSellSecondMost(activity, answers);

        // MTN merchandising
        activity = parseMerchandising(activity, getAnswerSet(answers.get('q33_0')), answers.get('q34_0'), 'MTN_Merch');

        // Other companies showing merch
        activity = parseCompany(activity, answers.get('q36_0'), 'Merch', getAnswerSet(answers.get('q35_0')));

        // Other merchandising
        activity = parseMerchandising(activity, getAnswerSet(answers.get('q37_0')), answers.get('q38_0'), 'Merch_Comp');

        // Get the comments
        activity.Comment__c = getAnswerString(answers.get('q39_0'));

        return activity;
    }

    /**
     *  Load a MTN Channels Staff from their Person__c
     *
     *  @param person - The person object for the staff memeber
     */
    private static MTN_Channels_Staff__c loadMtnChanStaff(Person__c person) {

        MTN_Channels_Staff__c[] mtnChanStaff = [
            SELECT 
                Name,
                Id,
                Person__c,
                Person__r.Region__c,
                Person__r.Id,
                Person__r.Name
            FROM
                MTN_Channels_Staff__c
            WHERE
                Person__c = :person.Id];
        if (mtnChanStaff.isEmpty()) {
            System.debug(LoggingLevel.DEBUG, 'No Sales Reps found for person with Name: ' + person.Name);
            return null;
        }
        return mtnChanStaff[0];
    }

    /**
     * Parse the submission to fill in the DSD values
     *
     * @param dsdAnswer - A set of the multiple choice answers to the dsd question
     * @param activity  - The activity that is being created
     *
     * @return - The activity
     */
    public static MTN_Channels_Activity__c parseDsd(Set<String> dsdAnswer, MTN_Channels_Activity__c activity) {

        if (dsdAnswer.contains('1')) {
            activity.Get_Stock_DSD__c = 1.0;
        }
        if (dsdAnswer.contains('2')) {
            activity.Get_Stock_Self__c = 1.0;
        }

        return activity;
    }

    /**
     * Parse the submission to add who is stocked by the outlet
     *
     * @param activity     - The activity object that is being created
     * @param otherAnswer  - The other answers for the submission
     * @param fieldName    - The api name for the field that will be updated
     * @param answer       - Set of the the answers
     *
     * @return - The activity
     */
    public static MTN_Channels_Activity__c parseCompany(
            MTN_Channels_Activity__c activity,
            Submission_Answer__c otherAnswers,
            String fieldName,
            Set<String> answer
    ) {

        if (answer == null) {
            return activity;
        }
        if (answer.contains('None')) {
            activity = addBinary(activity, fieldName + '_None__c');
            return activity;
        }
        for (String company : answer) {
            if (company.equals('Other')) {
                activity.put(fieldName + '_Other_Name__c', getAnswerString(otherAnswers));
            }
            if (!((company.equals('null') || company == null))) {
            	activity = addBinary(activity, fieldName + '_' + company + '__c');
            }
        }
        return activity;
    }

    /**
     * Parse the submission to add what company product is sold the most
     *
     * @param activity - The activity object that is being created
     * @param answers  - The answers for the submission
     *
     * @return - The activity
     */
    private static MTN_Channels_Activity__c parseSellMost(MTN_Channels_Activity__c activity, Map<String, Submission_Answer__c> answers) {

        String companyName = getAnswerString(answers.get('q29_0'));
        if (companyName.equals('Other')) {
            activity.Sell_Most_Other__c = getAnswerString(answers.get('q30_0'));
        }
        activity.Sell_Most__c = companyName;
        return activity;
    }

    /**
     * Parse the submission to add what company product is sold the second most
     *
     * @param activity - The activity object that is being created
     * @param answers  - The answers for the submission
     *
     * @return - The activity
     */
    private static MTN_Channels_Activity__c parseSellSecondMost(MTN_Channels_Activity__c activity, Map<String, Submission_Answer__c> answers) {

        String companyName = getAnswerString(answers.get('q31_0'));
        if (companyName.equals('Other')) {
            activity.Sell_Second_Most__c = getAnswerString(answers.get('q32_0'));
        }
        activity.Sell_Second_Most__c = companyName;
        return activity;
    }

    private static MTN_Channels_Activity__c parseMerchandising(
            MTN_Channels_Activity__c activity,
            Set<String> answer,
            Submission_Answer__c otherAnswer,
            String fieldName
    ) {

        for (String merch : answer) {
            String xlatedAnswer = translateMerchandise(merch);
            if (xlatedAnswer != null && !xlatedAnswer.equals('null')) {
            	activity.put(fieldName + '_' + xlatedAnswer + '__c', 1.0);
            	if (xlatedAnswer.equals('Other')) {
                	activity.put(fieldName + '_' + xlatedAnswer + '_Name__c', getAnswerString(otherAnswer));
            	}
            }
        }
        return activity;
    }

    // Translate the activity type
    private static String translateType(String optionNumber) {

            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Existing Outlet',
                '2' => 'New Outlet',
                '3' => 'Promotional Activity'
            };
            return translationMap.get(optionNumber);
    }

    // Translate promotion type
    private static String translatePromotionType(String optionNumber) {

            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Easy Load',
                '2' => 'SIM Registration',
                '3' => 'War Room',
                '4' => 'Landing Sites',
                '5' => 'Market Day Activation',
                '6' => 'Dealership Activities',
                '7' => 'Other'
            };
            return translationMap.get(optionNumber);
    }

    /**
     * Get the part of the api name for the merch fields that changes
     */
    private static String translateMerchandise(String optionNumber) {

            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Poster',
                '2' => 'Placard',
                '3' => 'SIM',
                '4' => 'Light_Box',
                '5' => 'Co_Brand',
                '6' => 'Wall',
                '7' => 'Dangler',
                '8' => 'Other',
                '9' => 'None'
            };
        return translationMap.get(optionNumber);
    }

    /**
     * Turn a binary field on
     *
     * @param activity  - The activity that is being created
     * @param fieldName - The api name of the field that is being updated
     *
     * @return - The activity
     */
    private static MTN_Channels_Activity__c addBinary(MTN_Channels_Activity__c activity,String fieldName) {

        activity.put(fieldName, 1.0);
        return activity;
    }

    /**
     *  Get the region object that the submission came from
     */
    private static Region__c getRegion(String optionNumber) {

            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'Northern',
                '2' => 'Western',
                '3' => 'Eastern',
                '4' => 'Central',
                '5' => 'South Western',
                '6' => 'Key Channels'
            };
        String displayName = translationMap.get(optionNumber);
        translationMap.clear();
        return [SELECT Id FROM Region__c WHERE Display_Name__c = :displayName AND Country__r.Name = 'Uganda'];
    }

    /**
     *  Get the dealership name out of the survey so we can dig the dealership out of the DB
     *
     *  @param answers - A map containing the values for the the outlet visit
     *
     *  @return - Name of the dealership
     */
    private static String translateDealerShipName(Map<String, Submission_Answer__c> answers, String regionBinding) {

        String dealerName = '';
        if (regionBinding.equals('1')) {

            // Northern
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'OTADA-Lira',
                '2' => 'DEYATALE-Karamoja',
                '3' => 'NILECOM Arua',
                '4' => 'OTADA -Apac',
                '5' => 'LABULE-Gulu',
                '6' => 'LABULE-Kitgum'
            };
            dealerName = translationMap.get(answers.get('q11_0').Answer__c);
        }
        else if (regionBinding.equals('2')) {

            // Western
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'CSL-Masindi',
                '2' => 'C & A Publishing',
                '3' => 'DAJ Fort Portal',
                '4' => 'DAJ Mubende',
                '5' => 'MAJESTIC',
                '6' => 'KENKOM Kibaale',
                '7' => 'LABULE-Mityana',
                '8' => 'DEMBELYO Kiboga',
                '9' => 'NILECOM Luwero'
            };
            dealerName = translationMap.get(answers.get('q9_0').Answer__c);
        }
        else if (regionBinding.equals('3')) {

            // Eastern Region
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'ZEBRA',
                '2' => 'TELEDOT',
                '3' => 'SIMBA EASTERN'
            };
            dealerName = translationMap.get(answers.get('q8_0').Answer__c);
        }
        else if (regionBinding.equals('4')) {

            // Central Region
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'SIMBA-CENTRAL',
                '2' => 'CSL-Kampala',
                '3' => 'NILECOM-Kampala',
                '4' => 'CHIMS ENTERPRISES',
                '5' => 'KENKOM-Kampala',
                '6' => 'MAMBO Entebbe',
                '7' => 'LINKS',
                '8' => 'MAMBO-Kajjansi',
                '9' => 'DDEMBELYO-Kampala',
                '10' => 'TIMCOM',
                '11' => 'CELLKING'
            };
            dealerName = translationMap.get(answers.get('q7_0').Answer__c);
        }
        else if (regionBinding.equals('5')) {

            // South Western
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'RCC Kalangala',
                '2' => 'MARKS',
                '3' => 'TULSI',
                '4' => 'SIMBA - Mbarara',
                '5' => 'SIMBA Kabale',
                '6' => 'KENKOM Lukya/Mbirizi',
                '7' => 'SIMBA-Masaka'
            };
            dealerName = translationMap.get(answers.get('q10_0').Answer__c);
        }
        else if (regionBinding.equals('6')) {

            // Key Channels
            Map<String, String> translationMap = new Map<String, String> {
                '1' => 'RCC-Total stations',
                '2' => 'RCC WEST'
            };
            dealerName = translationMap.get(answers.get('q12_0').Answer__c);
        }
        return dealerName;
    }

    /**
     *  Load the dealership object
     *
     *  @param name   - The display name of the dealership
     *  @param region - The region object for the region the dealership is in
     */
    private static MTN_Channels_Dealership__c getDealership(String name, Region__c region) {

        return [SELECT Id FROM MTN_Channels_Dealership__c WHERE Display_Name__c = :name AND Region__c = :region.Id];
    }


    // Translate the outlet type from the binding number to the text
    private static String translateOutletType(String optionNumber) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'Duka',
            '2' => 'Supermarket',
            '3' => 'Salon',
            '4' => 'Hotel',
            '5' => 'Restaurant',
            '6' => 'Bar',
            '7' => 'Kiosk',
            '8' => 'Fuel Station',
            '9' => 'Pharmacy',
            '10' => 'Vendor',
            '11' => 'Street Vendor',
            '12' => 'Mobile Money Shop'
        };
        return translationMap.get(optionNumber);
    }

    /**
     * Get an optional String answer from a field
     *
     * @param answer - The answer object that we are looking at. May be null
     *
     * return - The answer. null if the answer is blank
     */
    private static String getAnswerString(Submission_Answer__c answer) {

        if (answer == null) {
            return null;
        }
        else {
            return answer.Answer__c;
        }
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
     * Convert an answer into a Set. Useful for multiSelect questions
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

    /**
     * Build the query string to get the regions required.
     *
     * @param countryId - The id of a choosen country
     *
     * @return - The query string to be run
     */
    public static String buildRegionsQueryString() {

        String query =
            'SELECT '              +
                'Id, '             +
                'Name, '           +
                'Display_Name__c ' +
            'FROM '                +
                'Region__c';
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     * Update a summary when an activity is added
     */
    public static void addToSingleSummary(MTN_Channels_Activity__c activity) {

        MTN_Channels_Daily_Sumary__c summary = loadDailySummary(activity.Person__c, activity.Start_Time__c.date());
        if (summary == null) {
            summary = createDailySummary(activity.Person__c, activity.Start_Time__c.date());
        }
        summary = changeSummaryValue(summary, 1.0, activity.Activity_Type__c);
        summary = checkTimes(activity, summary);
        Database.upsert(summary);
    }

    /**
     * Update a summary if an activity is changed
     */
    public static void updateSingleSummary(MTN_Channels_Activity__c oldActivity, MTN_Channels_Activity__c newActivity) {

        List<MTN_Channels_Daily_Sumary__c> summariesToUpdate = new List<MTN_Channels_Daily_Sumary__c>();

        // Check that the activity type has changed
        if (!oldActivity.Activity_Type__c.equals(newActivity.Activity_Type__c)) {
            MTN_Channels_Daily_Sumary__c summary = loadDailySummary(oldActivity.Person__c, oldActivity.Start_Time__c.date());
            summary = changeSummaryValue(summary, -1.0, oldActivity.Activity_Type__c);

            // Check that the summary is different
            String oldId = oldActivity.Person__c;
            String newId = newActivity.Person__c;
            if (!oldActivity.Start_Time__c.isSameDay(newActivity.Start_Time__c) || !newId.equals(oldId)) {
                summariesToUpdate.add(summary);
                MTN_Channels_Daily_Sumary__c newSummary = loadDailySummary(newActivity.Person__c, newActivity.Start_Time__c.date());
                if (newSummary == null) {
                    newSummary = createDailySummary(newActivity.Person__c, newActivity.Start_Time__c.date());
                }
                summariesToUpdate.add(changeSummaryValue(newSummary, 1.0, oldActivity.Activity_Type__c));
            }
            else {
                summariesToUpdate.add(changeSummaryValue(summary, 1.0, newActivity.Activity_Type__c));
                summary = checkTimes(newActivity, summary);
            }
            Database.upsert(summariesToUpdate);
        }
    }

    /**
     * Check the times on the summary to make sure they do not need to be updated
     */
    private static MTN_Channels_Daily_Sumary__c checkTimes(MTN_Channels_Activity__c activity, MTN_Channels_Daily_Sumary__c summary) {

        if (summary.Work_Start_Time__c == null || (summary.Work_Start_Time__c.getTime() > activity.Start_Time__c.getTime())) {
            summary.Work_Start_Time__c = activity.Start_Time__c;
        }
        if (summary.Work_End_Time__c == null || (summary.Work_End_Time__c.getTime() < activity.End_Time__c.getTime())) {
            summary.Work_End_Time__c = activity.End_Time__c;
        }
        return summary;
    }


    /**
     * Update a summary if the activity is deleted
     */
    public static void removeSingleSummary(MTN_Channels_Activity__c activity) {

        MTN_Channels_Daily_Sumary__c summary = loadDailySummary(activity.Person__c, activity.Start_Time__c.date());
        if (summary == null) {
            summary = createDailySummary(activity.Person__c, activity.Start_Time__c.date());
        }
        else {
            summary = changeSummaryValue(summary, -1.0, activity.Activity_Type__c);
        }
        Database.upsert(summary);
        
    }

    /**
     * Update the daily summaries when activities are changed
     *
     * @param staffMembers - A set of the ids of the staff members to be changed
     * @param startDate    - The start date of the range for summaries
     * @param endDate      - The end date of the range for summaries
     */
    public static void updateDailySummaries(Set<String> staffMembers, Date startDate, Date endDate) {

        List<String> ids = new List<String>();
        ids.addAll(staffMembers);
        Map<String, MTN_Channels_Daily_Sumary__c> summaries = loadDailySummaries(ids, startDate, endDate);
        Map<String, MtnChannelsHelpers.ActivitySummary> activities = getSummaryValues(ids, startDate, endDate);

        List<MTN_Channels_Daily_Sumary__c> summariesToUpdate = new List<MTN_Channels_Daily_Sumary__c>();
        for (String key : activities.keySet()) {
            MtnChannelsHelpers.ActivitySummary activity = activities.get(key);
            MTN_Channels_Daily_Sumary__c summary = summaries.get(key);
            if (summary == null) {
                summary = createDailySummary(activity.getPersonId(), activity.getStartDate());
            }
            summary.Existing_Outlet_Visits__c = activity.getNewOutlet();
            summary.New_Outlet_Visits__c = activity.getExistingOutlet();
            summary.Promotional_Activities__c = activity.getPromotionalActivity();
            summary.Work_End_Time__c = activity.getStartTime();
            summary.Work_Start_Time__c = activity.getEndTime();
            summariesToUpdate.add(summary);
            summaries.remove(key);
            activities.remove(key);
        }
        for (String key : summaries.keySet()) {
            MTN_Channels_Daily_Sumary__c summary = summaries.get(key);
            summary = clearSummary(summary);
            summariesToUpdate.add(summary);
        }
        summaries.clear();
        Database.upsert(summariesToUpdate);
    }

    /**
     * Load the daily summary for a given date for a given person
     *
     * @param staffMember - The member of staff who's summary is being fetched
     * @param startDate   - The date of the summary
     *
     * @return - The daily summary or null if not found
     */
    private static MTN_Channels_Daily_Sumary__c loadDailySummary(String staffMember, Date startDate) {

        MTN_Channels_Daily_Sumary__c[] summaries =
            [SELECT
                Id,
                Name,
                Existing_Outlet_Visits__c,
                New_Outlet_Visits__c,
                Promotional_Activities__c,
                Work_End_Time__c,
                Work_Start_Time__c
            FROM
                MTN_Channels_Daily_Sumary__c
            WHERE
                Person__c = :staffMember
                AND Start_Date__c = :startDate
            ];
        if (summaries.size() == 0) {
            return null;
        }
        return summaries[0];
    }

    /**
     * Change a daily summary value
     *
     * @param summary  - The summary to be changed
     * @param amount   - The amount to change it by
     * @param activity - The activity carried out
     */
    public static MTN_Channels_Daily_Sumary__c changeSummaryValue(
            MTN_Channels_Daily_Sumary__c summary,
            Decimal amount,
            String activity
    ) {

        if (activity.equals('New Outlet')) {
            summary.New_Outlet_Visits__c += amount;
        }
        else if (activity.equals('Existing Outlet')) {
            summary.Existing_Outlet_Visits__c += amount;
        }
        else if (activity.equals('Promotion')) {
            summary.Promotional_Activities__c += amount;
        }
        return summary;
    }

    /**
     * Load the daily summary for a staff member on a particular day.
     *
     * @param staffMembers - The members of staff who's summary is being fetched
     * @param startDate    - The start date of the range for summaries
     * @param endDate      - The end date of the range for summaries
     *
     * @return - The daily summaries in map form
     */
    private static Map<String, MTN_Channels_Daily_Sumary__c> loadDailySummaries(List<String> staffMembers, Date startDate, Date endDate) {

        Map<String, MTN_Channels_Daily_Sumary__c> summaryMap = new Map<String, MTN_Channels_Daily_Sumary__c>();

        String query =
            'SELECT ' +
                'Id, ' +
                'Name, ' +
                'Person__c, ' +
                'Start_Date__c, ' +
                'Existing_Outlet_Visits__c, ' +
                'New_Outlet_Visits__c, ' +
                'Outlet_Visit_Target__c, ' +
                'Promotional_Activities__c, ' +
                'Work_End_Time__c, ' +
                'Work_Start_Time__c ' +
            'FROM ' +
                'MTN_Channels_Daily_Sumary__c ' +
            'WHERE ' +
                'Person__c IN (' + MetricHelpers.generateCommaSeperatedString(staffMembers, true) + ')' +
                ' AND Start_Date__c >= :startDate' +
                ' AND Start_Date__c <= :endDate' +
            ' ORDER BY ' +
                'Person__c, ' +
                'Start_Date__c';
        System.debug(LoggingLevel.INFO, query);

        for (MTN_Channels_Daily_Sumary__c[] summaries : Database.query(query)) {
            for (MTN_Channels_Daily_Sumary__c summary : summaries) {
                summaryMap.put(summary.Person__c + '' + summary.Start_Date__c, summary);
            }
        }
        return summaryMap;
    }

    /**
     * Get the values for the summaries
     *
     * @param staffMembers - The members of staff who's summary is being fetched
     * @param startDate    - The start date of the range for summaries
     * @param endDate      - The end date of the range for summaries
     *
     * @return - Map of the aggregate results
     */
    private static Map<String, MtnChannelsHelpers.ActivitySummary> getSummaryValues(List<String> staffMembers, Date startDate, Date endDate) {

        Map<String, MtnChannelsHelpers.ActivitySummary> activityMap = new Map<String, MtnChannelsHelpers.ActivitySummary>();
        String query =
            'SELECT ' +
                'Person__c, ' +
                'Activity_Type__c, ' +
                'Start_Date__c, ' +
                'Start_Time__c, ' +
                'End_Time__c ' +
            'FROM ' +
                'MTN_Channels_Activity__c ' +
            'WHERE ' +
                'Person__c IN (' + MetricHelpers.generateCommaSeperatedString(staffMembers, true) + ')' +
                ' AND Start_Date__c >= :startDate' +
                ' AND Start_Date__c <= :endDate';
        System.debug(LoggingLevel.INFO, query);
        for (MTN_Channels_Activity__c[] activities : Database.query(query)) {
            for(MTN_Channels_Activity__c activity : activities) {
                MtnChannelsHelpers.ActivitySummary act = activityMap.get(activity.Person__c + '' + activity.Start_Time__c.Date());
                if (act == null) {
                    act = new MtnChannelsHelpers.ActivitySummary(activity.Person__c, activity.Start_Time__c.Date(), activity.Start_Time__c, activity.End_Time__c);
                }
                act.addActivity(activity.Activity_Type__c);
                act.compareStartTime(activity.Start_Time__c);
                act.compareEndTime(activity.End_Time__c);
                activityMap.put(activity.Person__c + '' + activity.Start_Time__c.Date(), act);
            }
        }
        return activityMap;
    }

    private class ActivitySummary {

        private String personId;
        private Decimal newOutlet;
        private Decimal existingOutlet;
        private Decimal promotionalActivity;
        private Date startDate;
        private DateTime startTime;
        private DateTime endTime;

        public ActivitySummary(String personId, Date startDate, DateTime startTime, DateTime endTime) {
            this.personId = personId;
            this.startDate = startDate;
            this.startTime = startTime;
            this.endTime = endTime;
            this.newOutlet = 0;
            this.existingOutlet = 0;
            this.promotionalActivity = 0;
        }

        public String getPersonId() {
            return this.personId;
        }

        public Decimal getNewOutlet() {
            return this.newOutlet;
        }

        public Decimal getExistingOutlet() {
            return this.existingOutlet;
        }

        public Decimal getPromotionalActivity() {
            return this.promotionalActivity;
        }

        public Date getStartDate() {
            return this.startDate;
        }

        public DateTime getStartTime() {
            return this.startTime;
        }

        public DateTime getEndTime() {
            return this.endTime;
        }

        public void addActivity(String activity) {

            if (activity.equals('New Outlet')) {
                this.newOutlet++;
            }
            else if (activity.equals('Existing Outlet')) {
                this.existingOutlet++;
            }
            else if (activity.equals('Promotion')) {
                this.promotionalActivity++;
            }
        }

        public void compareStartTime(DateTime startTime) {
            if (this.startTime.getTime() > startTime.getTime()) {
                this.startTime = startTime;
            }
        }

        public void compareEndTime(DateTime endTime) {
            if (this.endTime.getTime() < endTime.getTime()) {
                this.endTime = endTime;
            }
        }
    }

    /**
     * Create a new daily summary for a staff member
     *
     * @param staffMembers - The members of staff who's summary is being fetched
     * @param startDate    - The date of the summary
     *
     * @return - The new daily summary
     */
    private static MTN_Channels_Daily_Sumary__c createDailySummary(String staffMember, Date startDate) {

        MTN_Channels_Daily_Sumary__c summary = new MTN_Channels_Daily_Sumary__c();
        summary.Start_Date__c = startDate;
        summary.Person__c = staffMember;
        summary.Existing_Outlet_Visits__c = 0;
        summary.New_Outlet_Visits__c = 0;
        summary.Promotional_Activities__c = 0;

        // Get the target
        MTN_Channels_Target__c target = getStaffTargets(staffMember);
        if (target != null) {
            summary.Outlet_Visit_Target__c = target.Outlet_Visits__c;
        }
        return summary;
    }

    /**
     * Pull out the targets for a given person
     *
     * @param staffMember - Id for the staff member
     *
     * @return - The target object
     */
    private static MTN_Channels_Target__c getStaffTargets(String staffMember) {

        MTN_Channels_Target__c[] targets = 
            [SELECT
                Outlet_Visits__c
            FROM
                MTN_Channels_Target__c
            WHERE
                Person__c = :staffMember
            ORDER BY 
                Start_Date__c ASC];
        if (targets.size() == 0) {
            return null;
        }
        return targets[0];
    }

    /**
     * Clear a summary for a staff member. This means that the activities in here previously
     * have been removed
     *
     * @param summary - The summary to be cleared
     *
     * @return - The cleared activity
     */
    private static MTN_Channels_Daily_Sumary__c clearSummary(MTN_Channels_Daily_Sumary__c summary) {

        summary.Existing_Outlet_Visits__c = 0;
        summary.New_Outlet_Visits__c = 0;
        summary.Promotional_Activities__c = 0;
        summary.Work_End_Time__c = DateTime.newInstance(summary.Work_End_Time__c.Date(), Time.newInstance(9, 0, 0, 0));
        summary.Work_Start_Time__c = DateTime.newInstance(summary.Work_Start_Time__c.Date(), Time.newInstance(9, 0, 0, 0));
        return summary;
    }

    public static Date convertStringToDate(String dateString) {
        return Date.parse(dateString);
    }

    /**
     * Join together a bunch of where clauses
     */
    public static String joinWhereClause(List<String> clauses, Boolean includeWhere, Boolean startWithAnd) {

        // Build the where clause
        String whereString = '';
        if (clauses.size() == 0) {
            return whereString;
        }
        if (includeWhere) {
            whereString = ' WHERE ';
        }
        else if (startWithAnd) {
            whereString = 'AND ';
        }
        Integer length = clauses.size();
        for (Integer i = 0; i < length; i ++) {
            whereString = whereString + clauses.get(i);
            if (i < length -1) {
                whereString = whereString + ' AND ';
            }
        }
        return whereString;
    }

    // Test methods
    static testMethod void testOutletVisit() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        Database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        Database.insert(region);

        // Create a test TDR
        Person__c person = Utils.createTestPerson(null, 'TestingMTNChan', true, null, 'Female');
        person.Region__c = region.Id;
        Database.insert(person);

        // Creat the MTN Chan Staff
        MTN_Channels_Staff__c staff = new MTN_Channels_Staff__c();
        staff.Person__c = person.Id;
        Database.insert(staff);

        MTN_Channels_Staff__c staff2 = [SELECT Person__c, Name, Id, Person__r.Id, Person__r.Name, Person__r.Region__c FROM MTN_Channels_Staff__c WHERE Id = :staff.Id];

        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(-30).getTime().format().replace(',', '');
        submission.interviewLatitude = '321';
        submission.interviewLongitude = '123';
        submission.imei = '32432443253';
        submission.resultHash = '1';

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q50_0',  Utils.createTestSubmissionAnswer(null, 'q50', '0123 3210 2', null, null, null));
        answers.put('q1_0',  Utils.createTestSubmissionAnswer(null, 'q1', '1', null, null, null));
        answers.put('q2_0',  Utils.createTestSubmissionAnswer(null, 'q2', 'My', null, null, null));
        answers.put('q3_0',  Utils.createTestSubmissionAnswer(null, 'q3', 'Name', null, null, null));
        answers.put('q4_0',  Utils.createTestSubmissionAnswer(null, 'q4', '09876554321', null, null, null));
        answers.put('q5_0',  Utils.createTestSubmissionAnswer(null, 'q5', '3', null, null, null));
        answers.put('q6_0',  Utils.createTestSubmissionAnswer(null, 'q6', '1', null, null, null));
        answers.put('q11_0',  Utils.createTestSubmissionAnswer(null, 'q11', '1', null, null, null));
        answers.put('q13_0',  Utils.createTestSubmissionAnswer(null, 'q13', 'Town', null, null, null));
        answers.put('q14_0',  Utils.createTestSubmissionAnswer(null, 'q14', '1', null, null, null));
        answers.put('q15_0',  Utils.createTestSubmissionAnswer(null, 'q15', '2', null, null, null));
        answers.put('q16_0',  Utils.createTestSubmissionAnswer(null, 'q16', '3', null, null, null));
        answers.put('q17_0',  Utils.createTestSubmissionAnswer(null, 'q17', '4', null, null, null));
        answers.put('q18_0',  Utils.createTestSubmissionAnswer(null, 'q18', '5', null, null, null));
        answers.put('q19_0',  Utils.createTestSubmissionAnswer(null, 'q19', '6', null, null, null));
        answers.put('q20_0',  Utils.createTestSubmissionAnswer(null, 'q20', '7', null, null, null));
        answers.put('q21_0',  Utils.createTestSubmissionAnswer(null, 'q21', '8', null, null, null));
        answers.put('q22_0',  Utils.createTestSubmissionAnswer(null, 'q22', '9', null, null, null));
        answers.put('q23_0',  Utils.createTestSubmissionAnswer(null, 'q23', '10', null, null, null));
        answers.put('q24_0',  Utils.createTestSubmissionAnswer(null, 'q24', '1 2', null, null, null));
        answers.put('q26_0',  Utils.createTestSubmissionAnswer(null, 'q26', 'Bob', null, null, null));
        answers.put('q27_0',  Utils.createTestSubmissionAnswer(null, 'q27', 'Warid UTL Orange Airtel Other', null, null, null));
        answers.put('q28_0',  Utils.createTestSubmissionAnswer(null, 'q28', 'Bobby', null, null, null));
        answers.put('q29_0',  Utils.createTestSubmissionAnswer(null, 'q29', 'Other', null, null, null));
        answers.put('q30_0',  Utils.createTestSubmissionAnswer(null, 'q30', 'Bobby', null, null, null));
        answers.put('q31_0',  Utils.createTestSubmissionAnswer(null, 'q31', 'Other', null, null, null));
        answers.put('q32_0',  Utils.createTestSubmissionAnswer(null, 'q32', 'Bobby', null, null, null));
        answers.put('q33_0',  Utils.createTestSubmissionAnswer(null, 'q33', '1 2 3 4 5 6 7 8', null, null, null));
        answers.put('q34_0',  Utils.createTestSubmissionAnswer(null, 'q34', 'Bobby', null, null, null));
        answers.put('q35_0',  Utils.createTestSubmissionAnswer(null, 'q35', 'Warid UTL Orange Airtel Other', null, null, null));
        answers.put('q36_0',  Utils.createTestSubmissionAnswer(null, 'q36', 'Bobby', null, null, null));
        answers.put('q37_0',  Utils.createTestSubmissionAnswer(null, 'q37', '1 2 3 4 5 6 7 8', null, null, null));
        answers.put('q38_0',  Utils.createTestSubmissionAnswer(null, 'q38', 'Bobby', null, null, null));
        answers.put('q39_0',  Utils.createTestSubmissionAnswer(null, 'q39', 'Bobby is great', null, null, null));

        // Submit the survey
        List<String> returnValues = processChannelsFFPSSurvey(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));
    }

    static testMethod void testPromotionalActivty() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        Database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        Database.insert(region);

        // Create a test TDR
        Person__c person = Utils.createTestPerson(null, 'TestingMTNChan', true, null, 'Female');
        person.Region__c = region.Id;
        Database.insert(person);

        // Creat the MTN Chan Staff
        MTN_Channels_Staff__c staff = new MTN_Channels_Staff__c();
        staff.Person__c = person.Id;
        Database.insert(staff);

        MTN_Channels_Staff__c staff2 = [SELECT Person__c, Name, Id, Person__r.Id, Person__r.Name, Person__r.Region__c FROM MTN_Channels_Staff__c WHERE Id = :staff.Id];

        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(-30).getTime().format().replace(',', '');
        submission.interviewLatitude = '321';
        submission.interviewLongitude = '123';
        submission.imei = '32432443253';
        submission.resultHash = '1';

        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q50_0',  Utils.createTestSubmissionAnswer(null, 'q50', '0123 3210 2', null, null, null));
        answers.put('q1_0',  Utils.createTestSubmissionAnswer(null, 'q1', '3', null, null, null));
        answers.put('q40_0',  Utils.createTestSubmissionAnswer(null, 'q40', '3', null, null, null));
        answers.put('q41_0',  Utils.createTestSubmissionAnswer(null, 'q41', '3', null, null, null));
        answers.put('q44_0',  Utils.createTestSubmissionAnswer(null, 'q44', '3', null, null, null));
        answers.put('q46_0',  Utils.createTestSubmissionAnswer(null, 'q46', '3', null, null, null));
        answers.put('q43_0',  Utils.createTestSubmissionAnswer(null, 'q43', '3', null, null, null));
        answers.put('q42_0',  Utils.createTestSubmissionAnswer(null, 'q42', '3', null, null, null));
        answers.put('q46_0',  Utils.createTestSubmissionAnswer(null, 'q46', '3', null, null, null));
        answers.put('q47_0',  Utils.createTestSubmissionAnswer(null, 'q47', '3', null, null, null));
        answers.put('q48_0',  Utils.createTestSubmissionAnswer(null, 'q48', '3', null, null, null));
        answers.put('q49_0',  Utils.createTestSubmissionAnswer(null, 'q9', 'Bobby is great', null, null, null));

        // Submit the survey
        List<String> returnValues = processChannelsFFPSSurvey(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));
    }
    
    static testmethod void testOthers() {
        Country__c country = new Country__c();
        country.ISO_Standard_Code__c = 'SQ';
        country.Name = 'Molongia';
        database.insert(country);
        
        Region__c region  = new Region__c();
        region.Country__c = country.Id;
        region.Display_Name__c = 'Eastern';
        database.insert(region);
        
        Person__c person = new Person__c();
        person.First_Name__c = 'No body MTN';
        person.Last_Name__c = 'MTN';
        database.insert(person);
        
        MTN_Channels_Target__c target = new MTN_Channels_Target__c();
        target.Person__c = person.Id;
        target.Region__c = region.Id;
        target.Start_Date__c = Date.today();
        target.Outlet_Visits__c = 1;
        
        database.insert(target);
        
        target.Outlet_Visits__c = 0;
        database.update(target);
    }
}