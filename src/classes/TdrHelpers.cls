public with sharing class TdrHelpers {

    private static Map<String, Map<String, TDR_Weekly_Report__c>> regionStats;
    private static Map<String, List<String>> regionStaffOrder;
    private static Map<String, Map<String, TDR_Performance__c>> regionPerformanceStats;
    private static Map<String, List<String>> regionPerformanceStaffOrder;
    private static Map<String, Map<String, TDR_Performance__c>> dailyRegionPerformanceStats;
    private static Map<String, List<String>> dailyPerformanceStaffOrder;
    /**
     * A class to deal with MTN TDRs
     */

    /**
     *  Fill in the TDR_Performance_Record objects for this TDR
     *
     *  @param submission - The submission object being processed
     *  @param answers    - A map containing the values for the registration
     *                       The keys are <binding>_<instance> for compatibility
     *  @param person     - The Person__c object for the tdr who submitted the form
     *
     *  @return - A three element list of Strings with the following format
     *              element 1 - Binary indicator of success (0 = fail, 1 = success)
     *              element 2 - Error message if required for the logs and tech team
     *              element 3 - Message body to the CKW if required.
     */
    public static List<String> processAgentVisitSurvey(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {

        // Load the TDR
        TDR__c tdr = loadTdr(person);
        if (tdr == null) {

            //Send an email saying that an unregistered person is trying to act a TDR

            // Send back the error message
            return new String[] { '0', 'User with handset Id ' + submission.imei + ' is not a TDR', 'SUPRESSMSG' };
        }

        // Sort out the GPS location that the activity was carried out. This will need to be split up
        String[] gps = answers.get('q46_0').Answer__c.split(' ');
        String latitude = 'N/A';
        String longitude = 'N/A';
        if (gps.size() > 2) {
            latitude = gps[0];
            longitude = gps[1];
        }

        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
        }
        DateTime submissionStartTime = ProcessSurveySubmission.getTimestamp(submission.submissionStartTime);
        if (submissionStartTime == null) {
            return new String[] { '0', 'No Submission Start Time.', 'SUPRESSMSG' };
        }
        Boolean updateTdr = false;

        // Add the first submission date if this is a first submission for a tdr
        if (tdr.Date_Of_First_Submission__c == null) {
            tdr.Date_Of_First_Submission__c = submissionStartTime;
            updateTdr = true;
        }

        // Update the last submission time of the TDR if needed.
        if (tdr.Date_Of_Last_Submission__c == null || tdr.Date_Of_Last_Submission__c.getTime() < Long.valueOf(submission.handsetSubmitTime)) {
            tdr.Date_Of_Last_Submission__c = handsetSubmitTime;
            updateTdr = true;
        }
        Savepoint sp = Database.setSavepoint();
        if (updateTdr) {
            Database.update(tdr);
        }

        // Scrape the survey for the answers that are required
        String typeOfSubmission = translateSubmissionType(answers.get('q1_0').Answer__c);
        String activityConducted = '';
        if (answers.containsKey('q44_0')) {
            activityConducted = answers.get('q44_0').Answer__c;
        }

        String generalComment = '';
        if (answers.containsKey('q45_0')) {
            generalComment = answers.get('q45_0').Answer__c;
        }

        String contactName = '';
        String companyName = '';
        String specificComment = '';
        String fieldToUpdate = '';
        Decimal eFloat = null;

        // Based on the type of the submission scrape the data out
        if (typeOfSubmission.equals('MM Agent Full Report')) {
            companyName = answers.get('q27_0').Answer__c;
            eFloat = Decimal.valueOf(answers.get('q31_0').Answer__c);
            fieldToUpdate = 'MM_Agent_Full_Report__c';
        }
        else if (typeOfSubmission.equals('MM Agent Short Report')) {
            companyName = answers.get('q2_0').Answer__c;
            eFloat = Decimal.valueOf(answers.get('q3_0').Answer__c);
            fieldToUpdate = 'MM_Agent_Short_Report__c';
        }
        else if (typeOfSubmission.equals('Corporate Sales')) {
            companyName = answers.get('q18_0').Answer__c;
            contactName = answers.get('q19_0').Answer__c;
            fieldToUpdate = 'Corporate_Sales_Calls__c';
        }
        else if (typeOfSubmission.equals('School Sales')) {
            companyName = answers.get('q21_0').Answer__c;
            contactName = answers.get('q22_0').Answer__c;
            fieldToUpdate = 'School_Sales_Calls__c';
        }
        else if (typeOfSubmission.equals('Customer Support')) {
            companyName = answers.get('q14_0').Answer__c;
            contactName = answers.get('q16_0').Answer__c;
            specificComment = answers.get('q15_0').Answer__c;
            fieldToUpdate = 'Customer_Support__c';
        }
        else if (typeOfSubmission.equals('Marketing Event')) {
            specificComment = answers.get('q24_0').Answer__c;
            fieldToUpdate = 'Marketing_Event__c';
        }
        else if (typeOfSubmission.equals('Other')) {
            specificComment = answers.get('q25_0').Answer__c;
            fieldToUpdate = 'Other__c';
        }
        else {

            // Unrecognised type. If we got here someone has monkeyed with the form without updating the code here
            return new String[] { '0', 'Type of submission is unrecognised', 'SUPRESSMSG' };
        }

        // Create blank target map. This allows all the default targets to be taken if required
        Map<String, String> dummyTargetMap = generateDummyTargetMap();

        // Load the TDRs performance objects. There should be four of these.
        //    1. The Daily object
        //    2. The weekly object
        //    3. The monthly object
        //    4. The yearly object.
        List<TDR_Performance__c> performanceRecords = new List<TDR_Performance__c>();
        TDR_Performance__c dailyPerformance = loadTdrPerformanceRecord(tdr, 'DAILY', getDefaultDate('DAILY', handsetSubmitTime.date()));
        if (dailyPerformance == null) {
            dailyPerformance = createNewTdrPerformanceRecord(tdr, 'DAILY', getDefaultDate('DAILY', handsetSubmitTime.date()), dummyTargetMap);
        }
        performanceRecords.add(updateTdrPerformanceObject(dailyPerformance, fieldToUpdate, 1, false, submissionStartTime, handsetSubmitTime));

        TDR_Performance__c weeklyPerformance = loadTdrPerformanceRecord(tdr, 'WEEKLY', getDefaultDate('WEEKLY', handsetSubmitTime.date()));
        if (weeklyPerformance == null) {
            weeklyPerformance = createNewTdrPerformanceRecord(tdr, 'WEEKLY', getDefaultDate('WEEKLY', handsetSubmitTime.date()), dummyTargetMap);
        }
        performanceRecords.add(updateTdrPerformanceObject(weeklyPerformance, fieldToUpdate, 1, false, submissionStartTime, handsetSubmitTime));

        // Sort the monthly performance
        TDR_Performance__c monthlyPerformance = loadTdrPerformanceRecord(tdr, 'MONTHLY', getDefaultDate('MONTHLY', handsetSubmitTime.date()));
        if (monthlyPerformance == null) {
            monthlyPerformance = createNewTdrPerformanceRecord(tdr, 'MONTHLY', getDefaultDate('MONTHLY', handsetSubmitTime.date()), dummyTargetMap);
        }
        performanceRecords.add(updateTdrPerformanceObject(monthlyPerformance, fieldToUpdate, 1, false, submissionStartTime, handsetSubmitTime));

        // Sort the yearly performance
        TDR_Performance__c yearlyPerformance = loadTdrPerformanceRecord(tdr, 'YEARLY', getDefaultDate('YEARLY', handsetSubmitTime.date()));
        if (yearlyPerformance == null) {
            yearlyPerformance = createNewTdrPerformanceRecord(tdr, 'YEARLY', getDefaultDate('YEARLY', handsetSubmitTime.date()), dummyTargetMap);
        }
        performanceRecords.add(updateTdrPerformanceObject(yearlyPerformance, fieldToUpdate, 1, false, submissionStartTime, handsetSubmitTime));

        // Update the DB
        database.upsert(performanceRecords);

        // Create the activity record
        Database.SaveResult activityDataResult = database.insert(createActivityRecord(
            dailyPerformance,
            typeOfSubmission,
            submissionStartTime,
            handsetSubmitTime,
            activityConducted,
            generalComment,
            companyName,
            contactName,
            specificComment,
            latitude,
            longitude,
            eFloat,
            submission.resultHash
        ), false);
        if (!activityDataResult.isSuccess()) {
            System.debug(LoggingLevel.INFO, activityDataResult.getErrors()[0].getMessage());
            Database.rollback(sp);
            if (activityDataResult.getErrors()[0].getMessage().contains('Duplicate_Submission__c duplicates')) {
                return new String[] { '1', 'Duplicate so mark as complete on phone', 'SUPRESSMSG' };
            }
        }

        // Return success
        return new String[] { '1', 'Agent visit processed sucessfully', 'SUPRESSMSG' };
     }

    /**
     *  Translate the type of submission from the single select answer that it could be
     */
    private static String translateSubmissionType(String optionNumber) {

        Map<String, String> translationMap = new Map<String, String> {
            '1' => 'MM Agent Full Report',
            '2' => 'MM Agent Short Report',
            '3' => 'Corporate Sales',
            '4' => 'School Sales',
            '5' => 'Customer Support',
            '6' => 'Marketing Event',
            '7' => 'Other'
        };
        if (!translationMap.containsKey(optionNumber)) {
            return '';
        }
        return translationMap.get(optionNumber);
    }

    /**
     *  Generate the map required to get all the default targets into a new TDR Perfomace object
     */
    private static Map<String, String> generateDummyTargetMap() {

        return new Map<String, String> {
            'Corporate_Sales_Calls' => '',
            'MM_Agent_Full_Report' => '',
            'MM_Agent_Short_Report' => '',
            'School_Sales_Calls' => '',
            'Customer_Support' => '',
            'Marketing_Event' => '',
            'PA_Products' => ''

        };
    }

    /**
     *  Create a daily activity object
     *
     *  @param dailyPerformance    - The TDR_Performance__c record to attach the activity to
     *  @param typeOfSubmission    - The type of activity
     *  @param submissionStartTime - The time the activity was started
     *  @param handsetSubmitTime   - The time the activity was finished
     *  @param activityConducted   - A description of the activity
     *  @param generalComment      - General comment on the activity
     *  @param companyName         - The company name that the activity was carried out with
     *  @param contactName         - The contact name that the activity was carried out with
     *  @param specificComment     - A comment from the TDR for the activity only for certain tasks
     *  @param latitude            - The latitude of the activity
     *  @param longitude           - The longitude of the activity
     *  @param eFloat              - The value of the eFloat. Only used with MM Short Reports
     *  @param duplicateSubmission - Hash to check that this is not a duplicate submission.
     *
     *  @return - The newly created TDR_Activity__c object
     */
    private static TDR_Activity__c createActivityRecord(
            TDR_Performance__c dailyPerformance,
            String typeOfSubmission,
            DateTime submissionStartTime,
            DateTime handsetSubmitTime,
            String activityConducted,
            String generalComment,
            String companyName,
            String contactName,
            String specificComment,
            String latitude,
            String longitude,
            Decimal eFloat,
            String duplicateSubmission
    ) {

        TDR_Activity__c activity = new TDR_Activity__c();
        activity.Additional_Comments__c = generalComment;
        activity.Comment__c = specificComment;
        activity.Activity_Conducted__c = activityConducted;
        activity.Activity_Type__c = typeOfSubmission;
        activity.Company_Name__c = companyName;
        activity.Contact_Name__c = contactName;
        activity.Start_Time__c = submissionStartTime;
        activity.End_Time__c = handsetSubmitTime;

        // Add the latitude and longitude of the activity. Should always be there but just to be sure
        if (latitude != null) {
            activity.Activity_Latitude__c = latitude;
        }
        if (longitude != null) {
            activity.Activity_Longitude__c = longitude;
        }
        activity.eFloat__c = eFloat;
        activity.TDR_Performance_Record__c = dailyPerformance.Id;
        activity.Duplicate_Submission__c = duplicateSubmission;
        return activity;
    }

    /**
     *  Load a TDR from their Person__c
     *
     *  @param person - The person object that needs a TDR
     */
    private static TDR__c loadTdr(Person__c person) {

        TDR__c[] tdr = [
            SELECT 
                Name,
                Id,
                Date_Of_First_Submission__c,
                Date_Of_Last_Submission__c,
                Person__c,
                Person__r.Region__c,
                Person__r.Id,
                Person__r.Name
            FROM
                TDR__c
            WHERE
                Person__c = :person.Id];
        if (tdr.isEmpty()) {
            System.debug(LoggingLevel.DEBUG, 'No Sales Reps found for person with Name: ' + person.Name);
            return null;
        }
        return tdr[0];
    }

    /**
     *  Generic way for loading TDRs
     *
     *  @param parameters    - A map containing the parameters to pick out the required TDRs
     *  @param orderByFields - A list of the fields to order the TDRs by
     *
     *  @return - A list of TDRs
     */
    public static TDR__c[] loadTdrs(Map<String, String> parameters, List<String> orderByFields) {

        String baseQuery =
            'SELECT '                                   +
                'Id, '                                  +
                'Name, '                                +
                'Date_Of_First_Submission__c, '         +
                'Date_Of_Last_Submission__c, '          +
                'Person__r.Id, '                        +
                'Person__r.Name, '                      +
                'Person__r.First_Name__c, '             +
                'Person__r.Last_Name__c, '              +
                'Person__r.Region__r.Display_Name__c, ' +
                'Person__r.Region__c '                  +
            'FROM '                                     +
                'TDR__c';

        // Generate the WHERE clause
        String whereClause = '';
        if (parameters.size() > 0) {
            whereClause = 'WHERE ' + joinWhereClause(generateTdrWhereClause(parameters), false);
        }

        // Generate the Order By clause
        String orderByClause = '';
        if (orderByFields != null && orderByFields.size() > 0) {
            Integer orderByFieldsLength = orderByFields.size();
            orderByClause = 'ORDER BY ';
            for (Integer i = 0; i < orderByFieldsLength; i++) {
                orderByClause += orderByFields.get(i);
                if (i < orderByFieldsLength - 1) {
                    orderByClause += ', ';
                }
            }
        }

        // Combine the query
        String query = baseQuery + ' ' + whereClause + ' ' + orderByClause;
        System.debug(LoggingLevel.INFO, query);

        // Run the query
        TDR__c[] tdrs = database.query(query);
        if (tdrs.isEmpty()) {
            return null;
        }
        return tdrs;
    }

    /**
     *  Get a list ot TDR__c.Person__r.Id for the TDRs that have been selected
     *
     *  @param parameters    - A map containing the parameters to pick out the required TDRs
     *
     *  @return - A list of Strings containing the ids
     */
    public static List<String> getTdrPersonList(Map<String, String> parameters) {

        List<String> personIds = new List<String>();
        TDR__c[] tdrs = loadTdrs(parameters, null);
        if (tdrs != null) {
            for (TDR__c tdr : tdrs) {
                personIds.add((String)tdr.Person__r.Id);
            }
        }
        return personIds;
    }

    /**
     *  Load a specific performace record for a given TDR
     *
     *  @param tdr        - The TDR being processed
     *  @param timePeriod - The time period for the record required WEEKLY|MONTHLY|YEARLY
     *  @param startDate  - The date the performance record should start on
     *
     *  @return - The record required or null if not found
     */
     private static TDR_Performance__c loadTdrPerformanceRecord(TDR__c tdr, String timePeriod, Date startDate) {

        // Default the start date if needed
        if (startDate == null) {
            startDate = getDefaultDate(timePeriod, null);
        }
        TDR_Performance__c[] records = [
            SELECT
                Id,
                Name,
                Person__c,
                Start_Date__c,
                Start_Time__c,
                End_Time__c,
                Type__c,
                Customer_Support__c,
                Marketing_Event__c,
                Other__c,
                Corporate_Sales_Calls__c,
                Corporate_Sales_Calls_Target__c,
                MM_Agent_Full_Report__c,
                MM_Agent_Full_Report_Target__c,
                MM_Agent_Short_Report__c,
                MM_Agent_Short_Report_Target__c,
                School_Sales_Calls__c,
                School_Sales_Calls_Target__c,
                PA_Products__c
            FROM
                TDR_Performance__c
            WHERE
                Person__c = :tdr.Person__r.Id
                AND Type__c = :timePeriod
                AND Start_Date__c = :startDate
                ];
        if (records.isEmpty()) {
            return null;
        }
        return records[0];
     }

    /**
     *  Create a new TDR Performance Record for a given time and type
     *
     *  @param tdr        - The TDR the record is for
     *  @param timePeriod - The type of record that it is
     *  @param startDate  - The start date for the record. Should be the first day of the period the record is for
     *  @param corporateSalesCallTarget - The value of the corporate sales target
     *  @param fullReportTarget         - The value of the full report target
     *  @param shortReportTarget        - The value of the short report call target
     *  @param schoolSalesCallTarget    - The value of the school sales call target
     *
     *  @return - The new record
     */
    private static TDR_Performance__c createNewTdrPerformanceRecord(
            TDR__c tdr,
            String timePeriod,
            Date startDate,
            Map<String, String> newTargets
    ) {

        TDR_Performance__c newRecord = new TDR_Performance__c();
        newRecord.Start_Date__c = startDate;
        newRecord.Type__c = timePeriod;
        newRecord.Person__c = tdr.Person__c;

        // Set the targets for this record. Use the defaults if targets have not been created
        TDR_Default_Target__c defaultTarget = getDefaultTdrPerformanceTarget(tdr, timePeriod, startDate);
        for (String key : newTargets.keySet()) {
            if (newTargets.get(key).equals('')) {
                if (defaultTarget != null && defaultTarget.get(key + '__c') != null) {
                    newRecord.put(key + '_Target__c', defaultTarget.get(key + '__c'));
                }
            }
            else {
                newRecord.put(key + '_Target__c', Decimal.valueOf(newTargets.get(key)));
            }
        }
        return newRecord;
    }

    /**
     *  Get the most recent default targets set for a given region and type
     *
     *  @param tdr        - The TDR the record is for
     *  @param timePeriod - The type of record that it is
     *  @param startDate  - The start date
     */
    private static TDR_Default_Target__c getDefaultTdrPerformanceTarget(TDR__c tdr, String timePeriod, Date startDate) {

        TDR_Default_Target__c[] targets = [
            SELECT
                Name,
                Id,
                Start_Date__c,
                Corporate_Sales_Calls__c,
                MM_Agent_Full_Report__c,
                MM_Agent_Short_Report__c,
                School_Sales_Calls__c,
                Marketing_Event__c,
                Customer_Support__c,
                PA_Products__c
            FROM
                TDR_Default_Target__c
            WHERE
                Region__c = :tdr.Person__r.Region__c
                AND Start_Date__c <= :startDate
                AND Type__c = :timePeriod
            ORDER BY
                Start_Date__c DESC
            LIMIT 1];
        if (targets.isEmpty()) {
            return null;
        }
        return targets[0];
    }

    /**
     *  Update the default targets
     *
     */
    public static String updateDefaultTdrPerformance(Map<String, String> parameters, Map<String, String> newTargets) {

        String timePeriod = parameters.get('type');

        String query =
            'SELECT '                           +
                'Id, '                          +
                'Name, '                        +
                'Corporate_Sales_Calls__c, '    +
                'Customer_Support__c, '         +
                'Marketing_Event__c, '          +
                'MM_Agent_Full_Report__c, '     +
                'MM_Agent_Short_Report__c, '    +
                'PA_Products__c, '              +
                'Other__c, '                    +
                'School_Sales_Calls__c, '       +
                'Region__c, '                   +
                'Start_Date__c, '               +
                'Type__c '                      +
            'FROM '                             +
                'TDR_Default_Target__c '        +
            'WHERE '                            +
                'Type__c = \''                  +
                    parameters.get('type')      +
                '\' '                           +
                'AND Region__c = '              +
                    parameters.get('regions')   +
                ' '                             +
                'AND Start_Date__c >= '         +
                    parameters.get('startDate') +
                ' '                             +
                'AND Start_Date__c <= '         +
                    parameters.get('endDate');

        System.debug(LoggingLevel.INFO, query);
        TDR_Default_Target__c[] targets = database.query(query);

        if (timePeriod.equals('MONTHLY') || timePeriod.equals('YEARLY')) {

            // If this is a monthly or yearly type then we are only expecting one row back
            if (targets.isEmpty()) {

                // Create a new target for this time period
                targets.add(
                        createNewDefaultTarget(
                            timePeriod,
                            parameters.get('regions').substring(1, parameters.get('regions').length() - 1),
                            convertSoqlStringToDate(parameters.get('startDate')),
                            newTargets
                        )
                );
            }
            else {

                TDR_Default_Target__c target = targets[0];
                updateAllDefaultTargetValues(target, newTargets);

                // Clear the current targets list and replace with the new now complete list.
                targets.clear();
                targets.add(target);
            }
        }
        else {

            // For the weekly target need to work a bit harder as the gaps need to be filled in
            Date startDate = convertSoqlStringToDate(parameters.get('startDate'));
            Date endDate = convertSoqlStringToDate(parameters.get('endDate'));
            List<TDR_Default_Target__c> completeTargetList = new List<TDR_Default_Target__c>();
            Integer i = 0;
            Boolean moreDates = true;
            while (moreDates) {

                // If the list is empty then just create a new one for each week
                if (targets.isEmpty()) {
                    completeTargetList.add(
                        createNewDefaultTarget(
                            timePeriod,
                            parameters.get('regions').substring(1, parameters.get('regions').length() - 1),
                            startDate,
                            newTargets
                        )
                    );
                }
                else {
                    TDR_Default_Target__c targetSobject;
                    Boolean updateTarget = false;
                    if (i < targets.size()) {
                        targetSobject= targets.get(i);
                        if (targetSobject.Start_Date__c.isSameDay(startDate)) {
                            updateTarget = true;
                        }
                    }
                    if (updateTarget) {
                        completeTargetList.add(
                            updateAllDefaultTargetValues(
                                targetSobject,
                                newTargets
                            )
                        );
                        i++;
                    }
                    else {
                        completeTargetList.add(
                            createNewDefaultTarget(
                                parameters.get('type'),
                                parameters.get('regions').substring(1, parameters.get('regions').length() - 1),
                                convertSoqlStringToDate(parameters.get('startDate')),
                                newTargets
                            )
                        );
                    }
                }

                // Move on to the next week
                if (timePeriod.equals('WEEKLY')) {
                    startDate = startDate.addDays(7);
                }
                else {
                    startDate = startDate.addDays(1);
                }
                if (startDate.daysBetween(endDate) <= 0) {
                    moreDates = false;
                }
            }

            // Clear the current targets list and replace with the new now complete list.
            targets.clear();
            targets.addAll(completeTargetList);

            // Clear the complete list to keep the heap size down
            completeTargetList.clear();
        }

        // Update the DB
        database.upsert(targets);
        return 'Success';
    }

    /**
     *  Create a new default target object.
     *  Pass in null for any of the targets and the default of 0 is used.
     *
     *  @param timePeriod            - The type of target 
     *  @param regionId              - The region for the target
     *  @param startDate             - The start date for the target
     *  @param newTargets            - A map of the new targets.
     *
     *  @return - The new default target object
     */
    public static TDR_Default_Target__c createNewDefaultTarget(
            String timePeriod,
            String regionId,
            Date startDate,
            Map<String, String> newTargets
    ) {

        TDR_Default_Target__c target = new TDR_Default_Target__c();
        target.Type__c = timePeriod;
        target.Region__c = regionId;
        target.Start_Date__c = startDate;
        return updateAllDefaultTargetValues(target, newTargets);
    }

    /**
     *  Logic to update the targets for a default target
     */
    private static TDR_Default_Target__c updateAllDefaultTargetValues(
            TDR_Default_Target__c target,
            Map<String, String> newTargets
    ) {

        for (String key : newTargets.keySet()) {
            String targetValue = newTargets.get(key);
            if (!targetValue.equals('')) {
                target.put(key + '__c', Decimal.valueOf(targetValue));
            }
        }
        return target;
    }

    /**
     *  Logic to update the targets for a tdr performance
     */
    private static TDR_Performance__c updateTdrTargetValues(
            TDR_Performance__c target,
            Map<String, String> newTargets
    ) {

        for (String key : newTargets.keySet()) {
            String targetValue = newTargets.get(key);
            if (!targetValue.equals('')) {
                target.put(key + '_Target__c', Decimal.valueOf(targetValue));
            }
        }
        return target;
    }

    /**
     *  Update a TDR performance object based on the type of activity that was carried out
     *
     *  @param record    - The performance record to be updated
     *  @param fieldType - The type of field that is being updated
     *  @param newValue  - The value to add to the field
     *  @param overWrite - Should the be an addition to the existing number or an overwrite
     *
     *  @return - The update record
     */
    private static TDR_Performance__c updateTdrPerformanceObject(
            TDR_Performance__c record,
            String fieldType,
            Integer newValue,
            Boolean overWrite,
            DateTime startTime,
            DateTime endTime
    ) {

        if (overWrite || record.get(fieldType) == null) {
                record.put(fieldType, newValue);
        }
        else {
            record.put(fieldType, (Decimal)record.get(fieldType) + newValue);
        }
        if (record.Start_Time__c == null) {
            record.Start_Time__c = startTime;
        }
        record.End_Time__c = endTime;
        return record;
    }

    /**
     *  Update or add new performance targets for TDRs. This will update the existing ones and add
     *  any new ones that are required
     *
     *  @param parameters - The parameter map to decide which TDRs need updating
     */
    public static String updateTdrPerformanceTarget(Map<String, String> parameters, Map<String, String> newTargets) {

        // Load the TDRs and put them into a Map as well
        TDR__c[] tdrList = loadTdrs(parameters, null);
        if (tdrList == null) {
            return 'There are no Sales Reps to update. Please change your selection';
        }
        Map<String, TDR__c> tdrs = new Map<String, TDR__c>();
        for (TDR__c tdr : tdrList) {
            tdrs.put(tdr.Person__r.Name, tdr);
        }

        // Get all the existing performance records
        String query =
            'SELECT '                               +
                'Id, '                              +
                'Name, '                            +
                'Start_Date__c, '                   +
                'MM_Agent_Full_Report_Target__c, '  +
                'MM_Agent_Short_Report_Target__c, ' +
                'Corporate_Sales_Calls_Target__c, ' +
                'School_Sales_Calls_Target__c, '    +
                'Person__r.Name '                   +
            'FROM '                                 +
                'TDR_Performance__c '               +
            'WHERE '                                +
                'Type__c = \''                      +
                    parameters.get('type')          +
                '\' '                               +
                'AND Person__c IN ('                +
                    parameters.get('tdrs')          +
                ') '                                +
                'AND Start_Date__c >= '             +
                    parameters.get('startDate')     +
                ' '                                 +
                'AND Start_Date__c <= '             +
                    parameters.get('endDate');

        System.debug(LoggingLevel.INFO, query);

        // Chuck the performance records into a Map to allow for ease of processing
        Map<String, TDR_Performance__c> performanceMap = new Map<String, TDR_Performance__c>();
        for (TDR_Performance__c[] performances : database.query(query)) {
            for (TDR_Performance__c performance : performances) {
                performanceMap.put(generateKey(performance.Start_Date__c.format(), (String)performance.Person__r.Name), performance);
            }
        }

        String timePeriod = parameters.get('type');
        Date startDate = convertSoqlStringToDate(parameters.get('startDate'));
        Date endDate = convertSoqlStringToDate(parameters.get('endDate'));

        List<TDR_Performance__c> performanceToUpdate = new List<TDR_Performance__c>();
        if (timePeriod.equals('MONTHLY') || timePeriod.equals('YEARLY')) {

            // For this type we should only have one record per person so easy to loop through
            // If the map is empty then just generate them all
            if (performanceMap.isEmpty()) {
                for (String name : tdrs.keySet()) {
                    performanceToUpdate.add(
                        createNewTdrPerformanceRecord(
                            tdrs.get(name),
                            timePeriod,
                            startDate,
                            newTargets
                        )
                    );
                }
            }
            else {

                // We have some existing records but will also have to create any that don't exist
                for (String name : tdrs.keySet()) {
                    TDR_Performance__c record = performanceMap.get(generateKey(startDate.format(), name));
                    if (record == null) {
                        performanceToUpdate.add(
                            createNewTdrPerformanceRecord(
                                tdrs.get(name),
                                timePeriod,
                                startDate,
                                newTargets
                            )
                        );
                    }
                    else {
                        performanceToUpdate.add(
                            updateTdrTargetValues(
                                record,
                                newTargets
                            )
                        );
                    }
                }
            }
        }
        else {
            while (startDate.daysBetween(endDate) >= 0) {

                // If the map is empty then just generate them all
                if (performanceMap.isEmpty()) {
                    for (String name : tdrs.keySet()) {
                        performanceToUpdate.add(
                            createNewTdrPerformanceRecord(
                                tdrs.get(name),
                                timePeriod,
                                startDate,
                                newTargets
                            )
                        );
                    }
                }
                else {

                    // We have some existing records but will also have to create any that don't exist
                    for (String name : tdrs.keySet()) {
                         TDR_Performance__c record = performanceMap.get(generateKey(startDate.format(), name));
                         if (record == null) {
                            performanceToUpdate.add(
                                createNewTdrPerformanceRecord(
                                    tdrs.get(name),
                                    timePeriod,
                                    startDate,
                                    newTargets
                                )
                            );
                         }
                         else {
                            performanceToUpdate.add(
                                updateTdrTargetValues(
                                    record,
                                    newTargets
                                )
                            );
                         }
                    }
                }
                if (timePeriod.equals('DAILY')) {
                    startDate = startDate.addDays(1);
                }
                else {
                    startDate = startDate.addDays(7);
                }
            }
        }
        database.upsert(performanceToUpdate);
        return 'Success';
    }

    /**
     *  Generate a standard key for the 
     *
     *  @param startDate - The formatted String of the startDate for the performance record in the key
     *  @param personId  - The id of the person in this key
     *
     *  @return - The key string
     */
    private static String generateKey(String startDate, String personId) {
        return startDate + '_splitter_' + personId;
    }

    /**
     *  Split a key into an array of its parts
     *
     *  @param key - The key to split
     *
     *  @return - An array of the parts that make up the key
     */
    private static String[] splitKey(String key) {
        return key.split('_splitter_');
    }

    /**
     *  Get the default date for a given type
     *
     *  @param timePeriod - The time period being used
     *  @param startDate  - Optional date to start this default from
     *
     *  @return - The default date
     */
    private static Date getDefaultDate(String timePeriod, Date startDate) {

        Date defaultDate = null;
        if (startDate == null) {
            startDate = Date.today();
        }
        if (timePeriod.equals('YEARLY')) {
            defaultDate = Date.parse('01/01/' + String.valueOf(startDate.year()));
        }
        else if (timePeriod.equals('MONTHLY')) {
            defaultDate = startDate.toStartOfMonth();
        }
        else if (timePeriod.equals('WEEKLY')) {
            defaultDate = startDate.toStartOfWeek();
        }
        else {
            defaultDate = startDate;
        }
        return defaultDate;
    }

    /**
     *  Generate the where clause for the TDR query
     *
     *  @param parameters - A map containing the parameters for the where clause
     *
     *  @return - A list of the clauses
     */
    private static List<String> generateTdrWhereClause(Map<String, String> parameters) {

        List<String> clauses = new List<String>();
        if (parameters.size() == 0) {
            return clauses;
        }

        // If we already have the list of tdr.Person__c then just use this clause to load the details
        if (!getNamedVariable(parameters, 'tdrs').equals('')) {
            clauses.add(addInWhereClause('Person__c', false, getNamedVariable(parameters, 'tdrs'), null, false));
            return clauses;
        }
        if (!getNamedVariable(parameters, 'regions').equals('')) {
            clauses.add(addInWhereClause('Person__r.Region__c', false, getNamedVariable(parameters, 'regions'), null, false));
        }
        if (!getNamedVariable(parameters, 'countries').equals('')) {
            clauses.add(addInWhereClause('Person__r.Region__r.Country__c', false, getNamedVariable(parameters, 'countries'), null, false));
        }
        return clauses;
    }

    /**
     *  Get the query string to run to get the daily activity sumary
     *
     *  @param parameters - A map containing the parameters for the where clause
     *  @param allowAll   - Boolean indicating if the limit should go on. This is needed as dataTable
     *                      only allow 1000 entries
     *
     *  @return - The query to run to get the TDR daily summary
     */
    public static String getDailyTdrSummary(Map<String, String> parameters, Boolean allowAll) {

        String selectClause =
            'SELECT '                                   +
                'Customer_Support__c, '                 +
                'Customer_Support_Target__c, '          +
                'Marketing_Event__c, '                  +
                'Marketing_Event_Target__c, '           +
                'Other__c, '                            +
                'Corporate_Sales_Calls__c, '            +
                'Corporate_Sales_Calls_Target__c, '     +
                'MM_Agent_Full_Report__c, '             +
                'MM_Agent_Full_Report_Target__c, '      +
                'MM_Agent_Short_Report__c, '            +
                'MM_Agent_Short_Report_Target__c, '     +
                'School_Sales_Calls__c, '               +
                'School_Sales_Calls_Target__c, '        +
                'PA_Products__c, '                      +
                'Person__r.Region__r.Display_Name__c, ' +
                'Start_Time__c, '                       +
                'End_Time__c, '                         +
                'Distances__c, '                        +
                'Times__c, '                            +
                'Person__r.First_Name__c, '             +
                'Person__r.Last_Name__c '               +
            'FROM '                                     +
                'TDR_Performance__c '                   +
            'WHERE '                                    +
                'Person__c IN ('                        +
                    parameters.get('tdrs')              +
                ') '                                    +
                'AND Start_Date__c >= '                 +
                    parameters.get('startDate')         +
                ' '                                     +
                'AND Start_Date__c <= '                 +
                    parameters.get('endDate')           +
                ' AND Type__c = \'DAILY\' ';

        if (!getNamedVariable(parameters, 'regions').equals('')) {
            selectClause += ' AND ' + addInWhereClause('Person__r.Region__c', false, getNamedVariable(parameters, 'regions'), null, false);
        }

        String orderByClause =
            'ORDER BY '                     +
                'Person__r.Region__c, '     +
                'Person__r.Last_Name__c, ' +
                'Person__r.First_Name__c, '  +
                'Start_Time__c';

        String query = selectClause + ' ' + orderByClause;
        if (!allowAll) {
            query += ' LIMIT 1000';
        }

        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *  Get the query string to run to get the weekly activity sumary
     *
     *  @param parameters - A map containing the parameters for the where clause
     *  @param allowAll   - Boolean indicating if the limit should go on. This is needed as dataTable
     *                      only allow 1000 entries
     *
     *  @return - The query to run to get the TDR daily summary
     */
    public static String getWeeklyTdrSummary(Map<String, String> parameters, Boolean allowAll) {

        String selectClause =
            'SELECT '                                   +
                'Customer_Support__c, '                 +
                'Customer_Support_Target__c, '          +
                'Marketing_Event__c, '                  +
                'Marketing_Event_Target__c, '           +
                'Other__c, '                            +
                'Other_Target__c, '                     +
                'PA_Products__c,'                       +
                'PA_Products_Target__c,'                +
                'Corporate_Sales_Calls__c, '            +
                'Corporate_Sales_Calls_Target__c, '     +
                'MM_Agent_Full_Report__c, '             +
                'MM_Agent_Full_Report_Target__c, '      +
                'MM_Agent_Short_Report__c, '            +
                'MM_Agent_Short_Report_Target__c, '     +
                'School_Sales_Calls__c, '               +
                'School_Sales_Calls_Target__c, '        +
                'Person__r.Region__r.Display_Name__c, ' +
                'Start_Time__c, '                       +
                'End_Time__c, '                         +
                'Person__r.First_Name__c, '             +
                'Person__r.Last_Name__c '               +
            'FROM '                                     +
                'TDR_Performance__c '                   +
            'WHERE '                                    +
                'Person__c IN ('                        +
                    parameters.get('tdrs')              +
                ') '                                    +
                'AND Start_Date__c >= '                 +
                    parameters.get('startDate')         +
                ' '                                     +
                'AND Start_Date__c <= '                 +
                    parameters.get('endDate')           +
                ' AND Type__c = \'WEEKLY\' ';

        if (!getNamedVariable(parameters, 'regions').equals('')) {
            selectClause += ' AND ' + addInWhereClause('Person__r.Region__c', false, getNamedVariable(parameters, 'regions'), null, false);
        }

        String orderByClause =
            'ORDER BY '                     +
                'Person__r.Region__c, '     +
                'Person__r.Last_Name__c, ' +
                'Person__r.First_Name__c, '  +
                'Start_Time__c';

        String query = selectClause + ' ' + orderByClause;
        if (!allowAll) {
            query += ' LIMIT 1000';
        }

        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *  Get a list of the tdr activities for a set of parameters
     *
     *  @param parameters - A map containing the parameters for the where clause
     *  @param allowAll   - Boolean indicating if the limit should go on. This is needed as dataTable
     *                      only allow 1000 entries
     *
     *  @return - The query to run to get the TDR_Activity__c objects.
     */
    public static String getTdrDailyActivities(Map<String, String> parameters, Boolean allowAll) {

        String selectClause =
            'SELECT '                                                 +
                'Activity_Type__c, '                                  +
                'Activity_Conducted__c, '                             +
                'Additional_Comments__c, '                            +
                'Company_Name__c, '                                   +
                'eFloat__c, '                                         +
                'Activity_Latitude__c, '                              +
                'Activity_Longitude__c, '                             +
                'Contact_Name__c, '                                   +
                'Comment__c, '                                        +
                'Start_Time__c, '                                     +
                'End_Time__c, '                                       +
                'TDR_Performance_Record__r.Start_Date__c, '           +
                'TDR_Performance_Record__r.Start_Time__c, '           +
                'TDR_Performance_Record__r.End_Time__c, '             +
                'TDR_Performance_Record__r.Person__r.First_Name__c, ' +
                'TDR_Performance_Record__r.Person__r.Last_Name__c '   +
            'FROM '                                                   +
                'TDR_Activity__c '                                    +
            'WHERE '                                                  +
                'TDR_Performance_Record__r.Person__c IN ('            +
                    parameters.get('tdrs')                            +
                ') '                                                  +
                'AND TDR_Performance_Record__r.Start_Date__c >= '     +
                    parameters.get('startDate')                       +
                ' '                                                   +
                'AND TDR_Performance_Record__r.Start_Date__c <= '     +
                    parameters.get('endDate');

        // Add the type delimeter if it is in the parameters
        if (!getNamedVariable(parameters, 'activityType').equals('')) {
            selectClause += ' AND ' + addInWhereClause('Activity_Type__c', false, getNamedVariable(parameters, 'activityType'), null, true);
        }
        if (!getNamedVariable(parameters, 'regions').equals('')) {
            selectClause += ' AND ' + addInWhereClause('TDR_Performance_Record__r.Person__r.Region__c', false, getNamedVariable(parameters, 'regions'), null, false);
        }

        String orderByClause =
            'ORDER BY '                                 +
                'TDR_Performance_Record__r.Person__c, ' +
                'Start_Time__c';

        String query = selectClause + ' ' + orderByClause;
        if (!allowAll) {
            query += ' LIMIT 1000';
        }

        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *  Send the daily emails to the MTN people
     */
    public static void sendReportingEmails(Map<String, List<String>> emailAddresses, List<String> personIds, Date reportDate) {

	    Boolean sendAll = false;
	    List<String> regionsToIncludeInAll = new List<String>();
	    if (getDailyReportData(personIds, reportDate)) {
	    	
    		// Create the email for each region specified
            for (String key : emailAddresses.keySet()) {
                if (key.equals('all')) {
                    sendAll = true;
                    continue;
                }
                regionsToIncludeInAll.add(key);

                String html = getSummaryHtml(key, true);

                String subject = 'TDR Daily activities for region ' + key + ' for ' + reportDate;
                Messaging.SingleEmailMessage email = EmailHelpers.createHtmlEmail(emailAddresses.get(key), subject, html);
                EmailHelpers.sendEmails(new Messaging.SingleEmailMessage[] { email });
            }
	    }
        if (sendAll) {
            String html = '';
            for (String key : regionsToIncludeInAll) {
                html += '<div>' + key + '</div>';
                html += getSummaryHtml(key, true);
            }
            String subject = 'report ' + reportDate;
            Messaging.SingleEmailMessage email = EmailHelpers.createHtmlEmail(emailAddresses.get('all'), subject, html);
            EmailHelpers.sendEmails(new Messaging.SingleEmailMessage[] { email });
        }

        // Send out all the personal emails as well
        /*for (String regionKey : regionStats.keySet()) {
            for (String key : regionStats.get(regionKey).keySet()) {
                sendPersonalEmail(regionStats.get(regionKey).get(key), reportDate);
            }
        }*/
        /*String message = getWeeklyReportHtml(parameters, true, true);
        String subject = createSubjectString(parameters);

        // Get the list of email address if needed
        if (emailAddresses == null) {
            emailAddresses = new List<String>();
            //emailAddresses.add('emayanja@grameenfoundation.org');
            emailAddresses.add('snsubuga@grameenfoundation.org');
        }
        Messaging.SingleEmailMessage email = EmailHelpers.createHtmlEmail(emailAddresses, subject, message);
        EmailHelpers.sendEmails(new Messaging.SingleEmailMessage[] { email });*/
    }

    /**
     *  Send the weekly emails to the MTN people
     */
    public static void sendWeeklyEmails(Map<String, List<String>> emailAddresses, List<String> personIds, Date reportDate) {

	    Boolean sendAll = false;
	    List<String> regionsToIncludeInAll = new List<String>();
        if (getWeeklyReportData(personIds, reportDate)) {
        	
    		// Create the email for each region specified
            for (String key : emailAddresses.keySet()) {
                if (key.equals('all')) {
                    sendAll = true;
                    continue;
                }
                regionsToIncludeInAll.add(key);

                String html = getWeeklyPerformanceRegionHtml(key);

                String subject = 'TDR Weekly Activity report for region ' + key + ' between ' + reportDate + ' and ' + reportDate.addDays(7);
                Messaging.SingleEmailMessage email = EmailHelpers.createHtmlEmail(emailAddresses.get(key), subject, html);
                EmailHelpers.sendEmails(new Messaging.SingleEmailMessage[] { email });
            }
        }
        
        if (sendAll) {
            String html = '';
            for (String key : regionsToIncludeInAll) {
                html += '<div>' + key + '</div>';
                html += getWeeklyPerformanceRegionHtml(key);
            }
            String subject = 'report ' + reportDate;
            Messaging.SingleEmailMessage email = EmailHelpers.createHtmlEmail(emailAddresses.get('all'), subject, html);
            EmailHelpers.sendEmails(new Messaging.SingleEmailMessage[] { email });
        }

        // Send out all the personal emails as well
        /*for (String regionKey : regionStats.keySet()) {
            for (String key : regionStats.get(regionKey).keySet()) {
                sendPersonalEmail(regionStats.get(regionKey).get(key), reportDate);
            }
        }*/
        /*String message = getWeeklyReportHtml(parameters, true, true);
        String subject = createSubjectString(parameters);

        // Get the list of email address if needed
        if (emailAddresses == null) {
            emailAddresses = new List<String>();
            //emailAddresses.add('emayanja@grameenfoundation.org');
            emailAddresses.add('snsubuga@grameenfoundation.org');
        }
        Messaging.SingleEmailMessage email = EmailHelpers.createHtmlEmail(emailAddresses, subject, message);
        EmailHelpers.sendEmails(new Messaging.SingleEmailMessage[] { email });*/
    }
    /**
    * Send the weekly email based on the Weekly Report Survey
    */
    public static void sendWeeklyReportEmail(Map<String, List<String>> emailAddresses, List<String> personIds, Datetime reportDate) {
    		
	        Boolean sendAll = false;
	        List<String> regionsToIncludeInAll = new List<String>();
	        if (getWeeklyReportVisitData(personIds, reportDate)) {
	
	            // Create the email for each region specified
	            for (String key : emailAddresses.keySet()) {
	                if (key.equals('all')) {
	                    sendAll = true;
	                    continue;
	                }
	                regionsToIncludeInAll.add(key);
	
	                String html = getRegionHtml(key);
	
	                String subject = 'TDR Weekly Report for region ' + key + ' between ' + reportDate + ' and ' + reportDate.addDays(7);
	                Messaging.SingleEmailMessage email = EmailHelpers.createHtmlEmail(emailAddresses.get(key), subject, html);
	                EmailHelpers.sendEmails(new Messaging.SingleEmailMessage[] { email });
	            }
	        }
	
	        if (sendAll) {
	            String html = '';
	            for (String key : regionsToIncludeInAll) {
	                html += '<div>' + key + '</div>';
	                html += getRegionHtml(key);
	            }
	            String subject = 'TDR Weekly Report for  ' + reportDate;
	            Messaging.SingleEmailMessage email = EmailHelpers.createHtmlEmail(emailAddresses.get('all'), subject, html);
	            EmailHelpers.sendEmails(new Messaging.SingleEmailMessage[] { email });
	        }
	
	        // Send out all the personal emails as well
	        /*for (String regionKey : regionStats.keySet()) {
	            for (String key : regionStats.get(regionKey).keySet()) {
	                sendPersonalEmail(regionStats.get(regionKey).get(key), reportDate);
	            }
	        }*/
    }
    
    private static String getRegionHtml(String region) {
    	
    	// Create the start of the main table
        String mainHtml = '<div style="' + getBackgroundColour() + getFullWidth() + '">' +
            '<div style="' + getTitleStyle() + '">' +
                'Detailed' +
            '</div>' +
            '<table style="' + getTableStyle() + '">'                                                +
                '<tr style="'+ getTableHeaderRowStyle() + '">'                                       +
                    '<td style="padding-left:5px; width: 13%">Sales Rep Name</td>'                   +
                    '<td style="padding-left:5px; width: 10%">Banked Agents</td>'                     +
                    '<td style="padding-left:5px; width: 8%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 7%">%</td>'                                 +
                    '<td style="padding-left:5px; width: 10%">New agents</td>'                        +
                    '<td style="padding-left:5px; width: 8%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 7%">%</td>'                                 +
                    '<td style="padding-left:5px; width: 10%">Active DSTs</td>'                       +
                    '<td style="padding-left:5px; width: 8%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 7%">%</td>'                                 +
                    '<td style="padding-left:5px; width:10%">MM Activations</td>'                    +
                    '<td style="padding-left:5px; width: 8%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 7%">%</td>'                                 +
                    '<td style="padding-left:5px; width: 10%">MM Sub acquisition</td>'                +
                    '<td style="padding-left:5px; width: 8%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 7%">%</td>'                                 +
                    '<td style="padding-left:5px; width: 10%">Simcard registrations</td>'             +
                    '<td style="padding-left:5px; width: 8%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 7%">%</td>'                                 +
                    '<td style="padding-left:5px; width: 10%">Easytalk new locations</td>'            +
                    '<td style="padding-left:5px; width: 8%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 7%">%</td>'                                 +
                    '<td style="padding-left:5px; width: 10%">Easytalk Installations</td>'            +
                    '<td style="padding-left:5px; width: 8%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 7%">%</td>'                                 +
                    '<td style="padding-left:5px; width: 10%">Card sales</td>'                        +
                    '<td style="padding-left:5px; width: 8%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 7%">%</td>'                                 +
                    '<td style="padding-left:5px; width: 12%">Easytalk Activations</td>'              +
                    '<td style="padding-left:5px; width: 8%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 7%">%</td>'                                 +
                    '<td style="padding-left:5px; width: 10%">Easytalk repairs</td>'                  +
                    '<td style="padding-left:5px; width: 8%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 7%">%</td>'                                 +
                    '<td style="padding-left:5px; width: 13%">Payphone repairs/reactivations</td>'    +
                    '<td style="padding-left:5px; width: 8%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 7%">%</td>'                                 +
                    '<td style="padding-left:5px; width: 10%">Active Internet cafes</td>'             +
                    '<td style="padding-left:5px; width: 8%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 7%">%</td>'                                 +
                '</tr>';                                                 
        Boolean hasData = false;
        String tdrCurrentName = '';
        String currentRegion = '';
        Integer currentRow = 0;
        Map<String, TDR_Weekly_Report__c> regionPeople= regionStats.get(region);
        TDR_Weekly_Report__c[] summaryList = regionPeople.values();
            for (TDR_Weekly_Report__c summary : summaryList) {

                Decimal totalReports = 0.0;
                Decimal totalSales = 0.0;
                Decimal totalOther = 0.0;
                Decimal totalTarget = 0.0;

                // If this is a new region the add the row to the table
                if (!summary.Person__r.Region__r.Display_Name__c.equals(currentRegion)) {
                    mainHtml += '<tr style ="'+ getTableRegionRowStyle() + '"><td style="' + getRegionCellStyle() + getMediumFont() + '">' + summary.Person__r.Region__r.Display_Name__c + '</td>'+
                        '<tr><td style="column-span:14; background-color:#FFCC33; alignment-adjust:middle;"></td></tr>';
                    currentRegion = region;
                }

                hasData = true;
                mainHtml += '<tr style ="'+ getTableBodyStyle() +'">';
                if (!generateTdrName(
                        summary.Person__r.First_Name__c,
                        summary.Person__r.Last_Name__c).equals(tdrCurrentName)
                ) {
                    tdrCurrentName = generateTdrName(
                        summary.Person__r.First_Name__c,
                        summary.Person__r.Last_Name__c
                    );
                    mainHtml += '<td style ="padding-left:5px;">' + tdrCurrentName + '</td>';
                }
                else {
                    mainHtml += '<td></td>';
                }
                mainHtml += '<td style ="padding-left:5px;">' + summary.Banked_Agents__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Banked_Agents_Targets__c + '</td>' +
                    '<td style ="padding-left:5px;">' + ((summary.Banked_Agents__c/summary.Banked_Agents_Targets__c) * 100).setscale(0) + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.New_Agents__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.New_Agents_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + ((summary.New_Agents__c/summary.New_Agents_Target__c) * 100).setscale(0) + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Active_DSTs__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Active_DSTs_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + ((summary.Active_DSTs__c/summary.Active_DSTs_Target__c) * 100).setscale(0) + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Mobile_Money_Activations__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Mobile_Money_Activations_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + ((summary.Mobile_Money_Activations__c/summary.Mobile_Money_Activations_Target__c) * 100).setscale(0) + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.MM_Sub_Acquisitions__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.MM_Sub_Acquisitions_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + ((summary.MM_Sub_Acquisitions__c/summary.MM_Sub_Acquisitions_Target__c) * 100).setscale(0) + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Simcard_Registrations__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Simcard_Registrations_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + ((summary.Simcard_Registrations__c/summary.Simcard_Registrations_Target__c) * 100).setscale(0) + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Easytalk_New_Locations__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Easytalk_New_Locations_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + ((summary.Easytalk_New_Locations__c/summary.Easytalk_New_Locations_Target__c) * 100).setscale(0) + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Easytalk_Installations__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Easytalk_Installations_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + ((summary.Easytalk_Installations__c/summary.Easytalk_Installations_Target__c) * 100).setscale(0) + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Card_Sales__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Card_Sales_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + ((summary.Card_Sales__c/summary.Card_Sales_Target__c) * 100).setscale(0) + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Easytalk_Activations__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Easytalk_Activations_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + ((summary.Easytalk_Activations__c/summary.Easytalk_Activations_Target__c) * 100).setscale(0) + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Easytalk_Repairs__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Easytalk_Repairs_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + ((summary.Easytalk_Repairs__c/summary.Easytalk_Repairs_Target__c) * 100).setscale(0) + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Payphone_Repairs__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Payphone_Repairs_Targets__c + '</td>' +
                    '<td style ="padding-left:5px;">' + ((summary.Payphone_Repairs__c/summary.Payphone_Repairs_Targets__c) * 100).setscale(0) + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Active_Internet_Cafes__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Active_Internet_Cafes_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + ((summary.Active_Internet_Cafes__c/summary.Active_Internet_Cafes_Target__c) * 100).setscale(0) + '</td>' +                     
                    '</tr>';
            }
        

        // Put together the parts for the final html.
        String html = '';
        if (!hasData) {
            html = 'EMPTY';
            return html;
        }
        html = mainHtml;
        //html += '</tbody></table>';
        html += '</table>';
        html += '<br></div><div>';
        html += createLinkToDashboard(null);
        html += '</div>';
        return html;
    }
    
    private static String getWeeklyPerformanceRegionHtml(String region) {

        // Create the start of the main table
        String mainHtml = '<div style="' + getBackgroundColour() + getFullWidth() + '">' +
            '<div style="' + getTitleStyle() + '">' +
                'Detailed' +
            '</div>' +
            '<table style="' + getTableStyle() + '">' +
                '<tr style="'+ getTableHeaderRowStyle() + '">'           +
                    '<td style="padding-left:5px; width: 10%">Sales Rep Name</td>'          +
                    '<td style="padding-left:5px; width: 10%">Day Start</td>'               +
                    '<td style="padding-left:5px; width: 10%">Day End</td>'                 +
                    '<td style="padding-left:5px; width: 6%">MM Full Report</td>'          +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                  +
                    '<td style="padding-left:5px; width: 6%">MM Short Report</td>'         +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                  +
                    '<td style="padding-left:5px; width: 6%">Corporate Sales Calls</td>'   +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                  +
                    '<td style="padding-left:5px; width: 6%">School Sales Calls</td>'      +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                  +
                    '<td style="padding-left:5px; width: 6%">Customer Support</td>'        +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                  +
                    '<td style="padding-left:5px; width: 6%">Marketing Event</td>'         +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                  +
                    '<td style="padding-left:5px; width: 6%">Other Activities</td>'        +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                  +
                    '<td style="padding-left:5px; width: 6%">PA Products</td>'             +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                  +
                '</tr>';                                                 
        Boolean hasData = false;
        String tdrCurrentName = '';
        String currentRegion = '';
        Integer currentRow = 0;
        Map<String, TDR_Performance__c> regionPeople = regionPerformanceStats.get(region);
        TDR_Performance__c [] performances = regionPeople.values();
            for (TDR_Performance__c performance : performances) {

                Decimal totalReports = 0.0;
                Decimal totalSales = 0.0;
                Decimal totalOther = 0.0;
                Decimal totalTarget = 0.0;

                // If this is a new region the add the row to the table
                if (!performance.Person__r.Region__r.Display_Name__c.equals(currentRegion)) {
                    mainHtml += '<tr style ="'+ getTableRegionRowStyle() + '"><td style="' + getRegionCellStyle() + getMediumFont() + '">' + performance.Person__r.Region__r.Display_Name__c + '</td>'+
                        '<tr><td style="column-span:14; background-color:#FFCC33; alignment-adjust:middle;"></td></tr>';
                    currentRegion = performance.Person__r.Region__r.Display_Name__c;
                }

                hasData = true;
                mainHtml += '<tr style ="'+ getTableBodyStyle() +'">';

                if (!generateTdrName(
                        performance.Person__r.First_Name__c,
                        performance.Person__r.Last_Name__c).equals(tdrCurrentName)
                ) {
                    tdrCurrentName = generateTdrName(
                        performance.Person__r.First_Name__c,
                        performance.Person__r.Last_Name__c
                    );
                    mainHtml += '<td style ="padding-left:5px;">' + tdrCurrentName + '</td>';
                }
                else {
                    mainHtml += '<td></td>';
                }
                mainHtml += '<td style ="padding-left:5px;">' + performance.Start_Time__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.End_Time__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.MM_Agent_Full_Report__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.MM_Agent_Full_Report_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.MM_Agent_Short_Report__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.MM_Agent_Short_Report_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.Corporate_Sales_Calls__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.Corporate_Sales_Calls_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.School_Sales_Calls__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.School_Sales_Calls_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.Customer_Support__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.Customer_Support_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.Marketing_Event__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.Marketing_Event_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.Other__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.Other_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.PA_Products__c + '</td>' +
                    '<td style ="padding-left:5px;">' + performance.PA_Products_Target__c + '</td>' +
                    '</tr>';
            }

        // Put together the parts for the final html.
        String html = '';
        if (!hasData) {
            html = 'EMPTY';
            return html;
        }

        html = mainHtml;
        //html += '</tbody></table>';
        html += '</table>';
        html += '<br></div><div>';
        html += createLinkToDashboard(null);
        html += '</div>';
        return html;
    }
    
    private static Boolean getDailyReportData(List<String> personIds, Datetime reportDate) {
    	initRegionsForDailyData();
    	Boolean records = false;
    	for (TDR_Performance__c[] dailyPerformances : Database.query(getDailyPerformanceDataQuery(personIds, reportDate))) {
    		records = true;
    		for (TDR_Performance__c dailyPerformance : dailyPerformances) {
    			Map<String, TDR_Performance__c> regionMap = dailyRegionPerformanceStats.get(dailyPerformance.Person__r.Region__r.Display_Name__c);
    			TDR_Performance__c report = regionMap.get(dailyPerformance.Person__c);
    			List<String> reportList = dailyPerformanceStaffOrder.get(dailyPerformance.Person__r.Region__r.Display_Name__c);
    			if (report == null) {
    				report = dailyPerformance;
    				reportList.add(dailyPerformance.Person__c);
    			}
    			dailyPerformanceStaffOrder.put(dailyPerformance.Person__r.Region__r.Display_Name__c, reportList);
    			regionMap.put(dailyPerformance.Person__c, report);
    			dailyRegionPerformanceStats.put(dailyPerformance.Person__r.Region__r.Display_Name__c, regionMap);
    		}
    	}
    	return records;
    }

    private static Boolean getWeeklyReportVisitData(List<String> personIds, Datetime reportDate) {
    	
    	initRegions();
    	Boolean records = false;
    	for (TDR_Weekly_Report__c[] weeklyData : Database.query(getWeeklyReportDataQuery(personIds, reportDate))) {
    		records = true;
    		for (TDR_Weekly_Report__c weeklyDatum : weeklyData) {
    			Map<String, TDR_Weekly_Report__c> regionMap = regionStats.get(weeklyDatum.Person__r.Region__r.Display_Name__c);
    			TDR_Weekly_Report__c report = regionMap.get(weeklyDatum.Person__c);
    			List<String> reportList = regionStaffOrder.get(weeklyDatum.Person__r.Region__r.Display_Name__c);
    			if (report == null) {
                    report = weeklyDatum;
                    reportList.add(weeklyDatum.Person__c);
                }
                regionStaffOrder.put(weeklyDatum.Person__r.Region__r.Display_Name__c, reportList);
                regionMap.put(weeklyDatum.Person__c, report);
                regionStats.put(weeklyDatum.Person__r.Region__r.Display_Name__c, regionMap);
    		}
    	} 
    	return records;                                         
    }
    
    private static Boolean getWeeklyReportData(List<String> personIds, Datetime reportDate) {
    	
    	initRegionsForWeeklyReport();
    	Boolean records = false;
    	for (TDR_Performance__c[] weeklyPerformances : Database.query(getWeeklyPerformanceDataQuery(personIds, reportDate))) {
    		records = true;
    		for (TDR_Performance__c weeklyPerformance : weeklyPerformances) {
    			Map<String, TDR_Performance__c> regionMap = regionPerformanceStats.get(weeklyPerformance.Person__r.Region__r.Display_Name__c);
    			TDR_Performance__c report = regionMap.get(weeklyPerformance.Person__c);
    			List<String> reportList = regionPerformanceStaffOrder.get(weeklyPerformance.Person__r.Region__r.Display_Name__c);
    			if (report == null) {
                    report = weeklyPerformance;
                    reportList.add(weeklyPerformance.Person__c);
                }
                regionPerformanceStaffOrder.put(weeklyPerformance.Person__r.Region__r.Display_Name__c, reportList);
                regionMap.put(weeklyPerformance.Person__c, report);
                regionPerformanceStats.put(weeklyPerformance.Person__r.Region__r.Display_Name__c, regionMap);
    		}
    	} 
    	return records;                                         
    }
    
    private static void initRegions() {
    	
    	regionStats = new Map<String, Map<String, TDR_Weekly_Report__c>>();
        regionStaffOrder = new Map<String, List<String>>();
    	
    	Region__c[] regions =
            [SELECT
                Display_Name__c
            FROM
                Region__c
            WHERE
                Id IN (
                    SELECT
                        Region__c
                    FROM
                        Person__c
                    WHERE
                        Type__c = 'TDR'
                )
        ];
        for (Region__c region : regions) {
            regionStats.put(region.Display_Name__c, new Map<String, TDR_Weekly_Report__c>());
            regionStaffOrder.put(region.Display_Name__c, new List<String>());
        }
    }
    
    private static void initRegionsForWeeklyReport() {
	
		regionPerformanceStats = new Map<String, Map<String, TDR_Performance__c>>();
	    regionPerformanceStaffOrder = new Map<String, List<String>>();
		
		Region__c[] regions =
	        [SELECT
	            Display_Name__c
	        FROM
	            Region__c
	        WHERE
	            Id IN (
	                SELECT
	                    Region__c
	                FROM
	                    Person__c
	                WHERE
	                    Type__c = 'TDR'
	            )
	    ];
	    for (Region__c region : regions) {
	        regionPerformanceStats.put(region.Display_Name__c, new Map<String, TDR_Performance__c>());
	        regionPerformanceStaffOrder.put(region.Display_Name__c, new List<String>());
	    }
    }
    
    private static void initRegionsForDailyData() {
    	
    	dailyRegionPerformanceStats = new Map<String, Map<String, TDR_Performance__c>>();
    	dailyPerformanceStaffOrder = new Map<String, List<String>>();
    	
		Region__c[] regions =
	        [SELECT
	            Display_Name__c
	        FROM
	            Region__c
	        WHERE
	            Id IN (
	                SELECT
	                    Region__c
	                FROM
	                    Person__c
	                WHERE
	                    Type__c = 'TDR'
	            )
	    ];
	    for (Region__c region : regions) {
	        dailyRegionPerformanceStats.put(region.Display_Name__c, new Map<String, TDR_Performance__c>());
	        dailyPerformanceStaffOrder.put(region.Display_Name__c, new List<String>());
	    }
    }

    private static String getWeeklyReportDataQuery(List<String> personIds, Datetime reportDate) {

    	String query = 'SELECT ' +
                'Person__r.Region__r.Display_Name__c, ' +
                'Active_DSTs__c, ' +
                'Active_DSTs_Target__c, ' +
                'Person__c,'              +
                'Person__r.Last_Name__c, ' +
                'Person__r.First_Name__c, ' +
                'Person__r.Email_Address__c, ' +
                'Active_Internet_Cafes__c, ' +
                'Active_Internet_Cafes_Target__c, ' +
                'Banked_Agents__c, ' +
                'Banked_Agents_Targets__c, ' +
                'Card_Sales__c, ' +
                'Card_Sales_Target__c, ' +
                'Easytalk_Activations__c, ' +
                'Easytalk_Activations_Target__c, ' +
                'Easytalk_Installations__c, ' +
                'Easytalk_Installations_Target__c, ' +
                'Easytalk_New_Locations__c, ' +
                'Easytalk_New_Locations_Target__c, ' +
                'Easytalk_Repairs__c, ' +
                'Easytalk_Repairs_Target__c, ' +
                'MM_Sub_Acquisitions__c, ' +
                'MM_Sub_Acquisitions_Target__c, ' +
                'Mobile_Money_Activations__c, ' +
                'Mobile_Money_Activations_Target__c, ' +
                'New_Agents__c, ' +
                'New_Agents_Target__c, ' +
                'Payphone_Repairs__c, ' +
                'Payphone_Repairs_Targets__c, ' +
                'Simcard_Registrations__c, ' +
                'Simcard_Registrations_Target__c ' +
            'FROM ' +
                'TDR_Weekly_Report__c ' +
            'WHERE ' + 
                'CreatedDate >= :reportDate' +
             ' AND ' +
                'Person__c IN (' + MetricHelpers.generateCommaSeperatedString(personIds, true) + ')' +
                ' ORDER BY ' +
                'Person__r.Region__r.Display_Name__c';
         
         System.debug(LoggingLevel.INFO, query);     
         return query;
    }
    
    private static String getWeeklyPerformanceDataQuery(List<String> personIds, Datetime reportDate) {

    	String query = 'SELECT ' +
                'Person__r.Region__r.Display_Name__c, ' +
                'Corporate_Sales_Calls__c, ' +
                'Corporate_Sales_Calls_Target__c, ' +
                'Person__c,'              +
                'Person__r.Last_Name__c, ' +
                'Person__r.First_Name__c, ' +
                'Customer_Support__c, ' +
                'Customer_Support_Target__c, ' +
                'Marketing_Event__c, ' +
                'Marketing_Event_Target__c, ' +
                'MM_Agent_Full_Report__c, ' +
                'MM_Agent_Full_Report_Target__c, ' +
                'MM_Agent_Short_Report__c, ' +
                'MM_Agent_Short_Report_Target__c, ' +
                'Other__c, ' +
                'Other_Target__c, ' +
                'PA_Products__c, ' +
                'PA_Products_Target__c, ' +
                'School_Sales_Calls__c, ' +
                'School_Sales_Calls_Target__c, ' +
                'Start_Date__c, ' +
                'Start_Time__c, ' +
                'End_Time__c '                         +
            'FROM ' +
                'TDR_Performance__c ' +
            'WHERE ' + 
                'Start_Time__c >= :reportDate ' +
             'AND ' +
             'Type__c =\'WEEKLY\' ' +
             ' AND ' +
                'Person__c IN (' + MetricHelpers.generateCommaSeperatedString(personIds, true) + ')' +
                ' ORDER BY ' +
                'Person__r.Region__r.Display_Name__c';
         
         System.debug(LoggingLevel.INFO, query);     
         return query;
    }
    
    private static String getDailyPerformanceDataQuery(List<String> personIds, Datetime reportDate) {
    	
        String query =
            'SELECT '                                   +
                'Customer_Support__c, '                 +
                'Customer_Support_Target__c, '          +
                'Marketing_Event__c, '                  +
                'Marketing_Event_Target__c, '           +
                'Other__c, '                            +
                'Corporate_Sales_Calls__c, '            +
                'Corporate_Sales_Calls_Target__c, '     +
                'MM_Agent_Full_Report__c, '             +
                'MM_Agent_Full_Report_Target__c, '      +
                'MM_Agent_Short_Report__c, '            +
                'MM_Agent_Short_Report_Target__c, '     +
                'School_Sales_Calls__c, '               +
                'School_Sales_Calls_Target__c, '        +
                'PA_Products__c, '                      +
                'Person__r.Region__r.Display_Name__c, ' +
                'Start_Time__c, '                       +
                'End_Time__c, '                         +
                'Distances__c, '                        +
                'Times__c, '                            +
                'Person__r.First_Name__c, '             +
                'Person__r.Last_Name__c '               +
            'FROM '                                     +
                'TDR_Performance__c '                   +
            'WHERE ' + 
                'Start_Time__c >= :reportDate ' +
             'AND ' +
             'Type__c =\'DAILY\' ' +
             ' AND ' +
                'Person__c IN (' + MetricHelpers.generateCommaSeperatedString(personIds, true) + ')' +
                ' ORDER BY ' +
                'Person__r.Region__r.Display_Name__c';
         
         System.debug(LoggingLevel.INFO, query);     
         return query;
    }

    /**
     *  Create the default parameters for the email reports
     */
    private static Map<String, String> generateDefaultEmailParams() {

        Map<String, String> parameters = new Map<String, String>();

        // Load all tdrs in Uganda
        Country__c uganda = [SELECT Name, Id FROM Country__c WHERE Name = 'Uganda'];
        parameters.put('countries', '\'' + uganda.Id + '\'');
        TDR__c[] tdrs = loadTdrs(parameters, null);
        List<String> tdrIds = new List<String>();
        for (TDR__c tdr : tdrs) {
            tdrIds.add((String)tdr.Person__c);
        }
        parameters.put('tdrs', generateCommaSeperatedString(tdrIds, true));
        tdrs.clear();
        tdrIds.clear();

        // Add the dates for yesterday
        Date startDate = Date.today().addDays(-1);
        parameters.put('startDate', convertDateTimeToString(convertToStartDate(startDate), true));
        parameters.put('endDate', convertDateTimeToString(convertToStartDate(startDate), true));
        return parameters;
    }

    /**
     *  Create the subject string for the emailed report
     *
     *  @param parameters - A map containing the parameters for the where clause
     *
     *  @return - The subject string
     */
    private static String createSubjectString(Map<String, String> parameters) {

        String subject = 'TDR Daily activities for ';
        if (!getNamedVariable(parameters, 'startDate').equals('')) {
            subject += ' between ' + getNamedVariable(parameters, 'startDate');
        }
        if (!getNamedVariable(parameters, 'endDate').equals('')) {
            subject += ' and ' + getNamedVariable(parameters, 'endDate');
        }
        subject += getLocationTitle(parameters) + ' ';
        return subject;
    }

    /**
     *  Get the country and region info from the parameters. Need to convert from id to display name
     */
    public static String getLocationTitle(Map<String, String> parameters) {

        Boolean hasCountry = false;
        String title = '';
        if (!getNamedVariable(parameters, 'countries').equals('')) {

            // Get the country name out as we have the id
            Country__c[] country = database.query(
                'SELECT '         +
                    'Name '       +
                'FROM '           +
                    'Country__c ' +
                'WHERE '          +
                    'Id IN (' + getNamedVariable(parameters, 'countries') + ')'
            );
            title += ' in ' + country[0].Name + ' ';
            hasCountry = true;
        }
        if (!getNamedVariable(parameters, 'regions').equals('')) {
            if (hasCountry) {
                title += ' in ';
            }
            Region__c[] regions = database.query(
                'SELECT '              +
                    'Display_Name__c ' +
                'FROM '                +
                    'Region__c '       +
                'WHERE '               +
                    'Id IN (' + getNamedVariable(parameters, 'regions') + ')'
            );
            for (Region__c region : regions) {
                title += ' ' + region.Display_Name__c + ' ';
            }
            title += 'Region';
        }
        return title;
    }

    private static String getBackgroundColour() {
        return 'background-color:#FFFFFF;';
    }
    private static String getTableBackgroundColour() {
        return 'background-color:#FFCC33;';
    }
    private static String getLargeFont() {
        return 'font-size:30pt;';
    }
    private static String getMediumFont() {
        return 'font-weight:bold;';
    }
    private static String getSmallFont() {
        return 'font-size:10pt;';
    }
    private static String getBoldFont() {
        return 'font-weight=bold;';
    }
    private static String getEvenBackgroundColour() {
        return getBackgroundColour();
    }
    private static String getOddBackgroundColour() {
        return 'background-color:#FFCC33;';
    }
    private static String getCenter() {
        return 'vertical-align: center;';
    }
    private static String getTableHeaderRowStyle(){
        return 'border-style:solid; border-color:#FFCC33; text-align:justify; font-size:12px;'+
        'font-family: \'Trebuchet MS\', sans-serif; word-wrap: break-word; background-color:#FFC600; '+
        'font-weight:bold; text-shadow: 0 0 1px rgba(0, 0, 0, 0.1); -webkit-font-smoothing: antialiased; font-smooth: always;';
    }
    private static String getTableBodyRowStyle(){
        return 'border-style:solid; border-color:#FFCC33; text-align:justify; white-space: -moz-pre-wrap; white-space: -pre-wrap; white-space:-o-pre-wrap; white-space: pre-wrap; word-wrap: break-word;font-size:13px; font-family: arial, sans-serif; -webkit-font-smoothing: antialiased; font-smooth: always; background-color:#FFFFFF;';
    }
    private static String getTableRegionRowStyle(){
        return 'border-style:solid; border-color:#FFCC33; text-align:justify; white-space: -moz-pre-wrap; '+
        'white-space: -pre-wrap; white-space:-o-pre-wrap; white-space: pre-wrap; word-wrap: break-word;font-size:13px; '+
        'font-family: arial, sans-serif; -webkit-font-smoothing: antialiased; font-smooth: always;';
    }
    private static String getTdNameWidth() {
        return 'width:25%; padding-left:5px;';
    }
    private static String getTdOtherWidth() {
        return 'width:15%; padding-left:5px;';
    }
    private static String getFullWidth() {
        return 'width:100%;';
    }
    private static String getWideWidth() {
        return 'width:600px;';
    }
    private static String getSumaryWidth() {
        return 'width:96%;';
    }
    private static String getCellAlignment() {
        return 'align="center" valign="middle"';
    }
    private static String getSummaryPadding() {
        return 'padding:0% 2% 2% 2%;';
    }
    private static String getRegionCellStyle() {
        return 'background-color:#FFFFFF; column-span:1; padding-left:5px;font-weight:bold;';
    }
    private static String getTitleStyle() {
        return 'font-size:20pt; font-family: \'Trebuchet MS\', sans-serif; font-weight: bold; padding-bottom: 5px; '+ 
        'text-shadow: 0 0 1px rgba(0, 0, 0, 0.3); -webkit-font-smoothing: subpixel-antialiased; font-smooth: always;';
    }
    private static String getTableStyle(){
        return 'table-layout: fixed; background-color:#FFCC33; width:200%; alignment-adjust:auto; padding:0.2px;';
    }
    private static String getTableHeaderStyle(){
        return 'text-align:justify; font-size:12px; font-family: \'Trebuchet MS\', sans-serif; word-wrap: break-word; background-color:#FFC600;' +
        'font-weight:bold; text-shadow: 0 0 1px rgba(0, 0, 0, 0.1); font-smooth: always;';
    }
    private static String getTableBodyStyle() {
        return 'text-align:justify; white-space: pre-wrap; word-wrap: break-word; font-size:13px; font-family: arial, sans-serif;'+
        'background-color:#FFFFFF; font-smooth: always;';
    }

    /**
     *  Generate and HTML table for the Daily Activities summary
     *
     *  @param parameters - A map containing the parameters for the where clause
     *  @param allowAll   - Boolean indicating if the limit should go on. This is needed as dataTable
     *                      only allow 1000 entries
     *  @param incSummary - Show a smaller summary table
     *
     *  @return - String for the html   
     */
    private static String getSummaryHtml(String region, Boolean incSummary) {

        // Create the summary table if needed
        String summaryHtml = '<div style="' + getBackgroundColour() + getFullWidth() + '">';
        //String summaryHtml;
        if (incSummary) {
            summaryHtml = '<div style="' + getBackgroundColour() +
                getSumaryWidth() +
                getSummaryPadding() +
                '">' +
                '<div style="' + getTitleStyle() + '">' +
                    'Summary' +
                '</div>' +
                '<table style="' + getTableStyle() +'">' +
                        '<tr style="'+ getTableHeaderRowStyle() + '">' +
                            '<td style="' + getTdNameWidth() + '">'  + 'Sales Rep Name</td>'      +
                            '<td style="' + getTdOtherWidth() + '">' + 'Hours worked</td>'        +
                            '<td style="' + getTdOtherWidth() + '">' + 'Sales and Activities</td>' +
                            '<td style="' + getTdOtherWidth() + '">' + 'Total Targets</td>'       +
                            '<td style="' + getTdOtherWidth() + '">' + 'Difference</td>'          +
                        '</tr>';
        }

        // Create the start of the main table
        String mainHtml = '<div style="' + getBackgroundColour() + getFullWidth() + '">' +
            '<div style="' + getTitleStyle() + '">' +
                'Detailed' +
            '</div>' +
            '<table style="' + getTableStyle() + '">' +
                '<tr style="'+ getTableHeaderRowStyle() + '">'           +
                    '<td style="padding-left:5px; width: 10%">Sales Rep Name</td>'         +
                    '<td style="padding-left:5px; width: 10%">Day Start</td>'              +
                    '<td style="padding-left:5px; width: 10%">Day End</td>'                +
                    '<td style="padding-left:5px; width: 6%">MM Full Report</td>'          +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                  +
                    '<td style="padding-left:5px; width: 6%">MM Short Report</td>'         +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                  +
                    '<td style="padding-left:5px; width: 6%">Corporate Sales Calls</td>'   +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                  +
                    '<td style="padding-left:5px; width: 6%">School Sales Calls</td>'      +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                  +
                    '<td style="padding-left:5px; width: 6%">Customer Support</td>'        +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                  +
                    '<td style="padding-left:5px; width: 6%">Marketing Event</td>'         +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                  +
                    '<td style="padding-left:5px; width: 6%">Other Activities</td>'        +
                    '<td style="padding-left:5px; width: 4%">PA Products</td>'             +
                '</tr>';                                                 
        Boolean hasData = false;
        String tdrCurrentName = '';
        String currentRegion = '';
        Integer currentRow = 0;
        Map<String, TDR_Performance__c> regionPeople= dailyRegionPerformanceStats.get(region);
        TDR_Performance__c[] summaryList = regionPeople.values();
            for (TDR_Performance__c summary : summaryList) {

                Decimal totalReports = 0.0;
                Decimal totalSales = 0.0;
                Decimal totalOther = 0.0;
                Decimal totalTarget = 0.0;

                // If this is a new region the add the row to the table
                if (!summary.Person__r.Region__r.Display_Name__c.equals(currentRegion)) {
                    mainHtml += '<tr style ="'+ getTableRegionRowStyle() + '"><td style="' + getRegionCellStyle() + getMediumFont() + '">' + summary.Person__r.Region__r.Display_Name__c + '</td>'+
                        '<tr><td style="column-span:14; background-color:#FFCC33; alignment-adjust:middle;"></td></tr>';
                    if (incSummary) {
                        summaryHtml += '<tr style ="'+ getTableRegionRowStyle() +'"><td style="' + getRegionCellStyle() + getMediumFont() + '">' + summary.Person__r.Region__r.Display_Name__c + '</td>'+
                        '<tr><td style="column-span:6; background-color:#FFCC33; alignment-adjust:middle;"></td></tr>';
                    }
                    currentRegion = summary.Person__r.Region__r.Display_Name__c;
                }

                hasData = true;
                mainHtml += '<tr style ="'+ getTableBodyStyle() +'">';
                if (incSummary) {
                    summaryHtml += '<tr style ="'+ getTableBodyStyle() +'">';
                }
                if (!generateTdrName(
                        summary.Person__r.First_Name__c,
                        summary.Person__r.Last_Name__c).equals(tdrCurrentName)
                ) {
                    tdrCurrentName = generateTdrName(
                        summary.Person__r.First_Name__c,
                        summary.Person__r.Last_Name__c
                    );
                    mainHtml += '<td style ="padding-left:5px;">' + tdrCurrentName + '</td>';
                    if (incSummary) {
                        summaryHtml += '<td style ="padding-left:5px;">' + tdrCurrentName + '</td>';
                    }
                }
                else {
                    mainHtml += '<td></td>';
                    if (incSummary) {
                        summaryHtml += '<td></td>';
                    }
                }
                mainHtml += '<td style ="padding-left:5px;">' + summary.Start_Time__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.End_Time__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.MM_Agent_Full_Report__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.MM_Agent_Full_Report_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.MM_Agent_Short_Report__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.MM_Agent_Short_Report_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Corporate_Sales_Calls__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Corporate_Sales_Calls_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.School_Sales_Calls__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.School_Sales_Calls_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Customer_Support__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Customer_Support_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Marketing_Event__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Marketing_Event_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Other__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.PA_Products__c + '</td>' +
                    '</tr>';
                system.debug('distances '+summary.Distances__c);system.debug('times ' +summary.Times__c);
                //Get the distances covered and their respective times
                List<String> distances = summary.Distances__c.split(',');
                system.debug(distances);
                List<String> times = summary.Times__c.split(',');
                system.debug(times);
                integer count = distances.size();
                system.debug('No of places visited ' + count);
                
                
                mainHtml += '<tr style ="'+ getTableBodyStyle() + '">';
                mainHtml += '<td style ="padding-left:5px;">Distance travelled</td>';
                for (integer location = 1; location <= count; location++) {
                	mainHtml += '<td style="padding-left:5px; width: 10%">' + 'Location' + location + '</td>';
                }
                mainHtml += '</tr>';
                mainHtml += '<tr style ="'+ getTableBodyStyle() + '">';
                mainHtml += '<td style ="padding-left:5px;"/>';
                for (integer location = 0; location < count; location++) {
                	String visitTime = times.get(location);
                	String formattedTime = '';
                	if (visitTime.contains(':')) {
                		List<String> hoursMinutes = visitTime.split(':');
                		formattedTime = hoursMinutes.get(0) + 'hr, ' + hoursMinutes.get(1) + 'min';
                	}
                	else {
                		formattedTime = visitTime + ' min';
                	}
                	mainHtml += '<td style ="padding-left:5px;">' + distances.get(location) + 'm,' + formattedTime + '</td>';
                }
                mainHtml += '</tr>';
                // Calculate the totals for the summary
                if (incSummary) {
                    totalReports = summary.MM_Agent_Full_Report__c +
                        summary.MM_Agent_Short_Report__c;
                    totalSales = summary.Corporate_Sales_Calls__c +
                        summary.School_Sales_Calls__c;
                    totalTarget = summary.MM_Agent_Full_Report_Target__c +
                        summary.MM_Agent_Short_Report_Target__c +
                        summary.Corporate_Sales_Calls_Target__c +
                        summary.School_Sales_Calls_Target__c;
                    totalOther = summary.Customer_Support__c +
                        summary.Marketing_Event__c +
                        summary.Other__c;

                    Decimal timeDifference = 0;
                    Decimal minutesDifference = 0;
                    Decimal hoursDifferent = 0;
                    Decimal minutes = 0;
                    if (summary.End_Time__c != null && summary.Start_Time__c != null) {
                        timeDifference = Decimal.valueOf(summary.End_Time__c.getTime() - summary.Start_Time__c.getTime());
                        minutesDifference = timeDifference.divide(60000, 0, System.RoundingMode.CEILING);
                        hoursDifferent = minutesDifference.divide(60, 0, System.RoundingMode.FLOOR);
                        minutes = minutesDifference - (hoursDifferent * 60);
                    }
                    Decimal difference = (totalReports + totalSales) - totalTarget;
                    summaryHtml += '<td style ="padding-left:5px;">' + hoursDifferent.intValue() + ' ' + minutes + '</td>' +
                        '<td style ="padding-left:5px;">' + (totalSales.intValue() + totalReports.intValue()) + '</td>' +
                        '<td style ="padding-left:5px;">' + totalTarget.intValue() + '</td>' +
                        '<td style ="padding-left:5px;">' + difference.intValue() + '</td>' +
                        '</tr>';
                }
            }


        // Put together the parts for the final html.
        String html = '';
        if (!hasData) {
            html = 'EMPTY';
            return html;
        }
        if (incSummary) {
            html = summaryHtml + '</table></div></div><br /><br />' + mainHtml;
        }
        else {
            html = mainHtml;
        }
        //html += '</tbody></table>';
        html += '</table>';
        html += '<br></div><div>';
        html += createLinkToDashboard(null);
        html += '</div>';
        return html;
    }

    private static String getWeeklyReportHtml(Map<String, String> parameters) {


        // Create the start of the main table
        String mainHtml = '<div style="' + getBackgroundColour() + getFullWidth() + '">' +
            '<div style="' + getTitleStyle() + '">' +
                'Detailed' +
            '</div>' +
            '<table style="' + getTableStyle() + '">' +
                '<tr style="'+ getTableHeaderRowStyle() + '">'                           +
                    '<td style="padding-left:5px; width: 10%">Sales Rep Name</td>'       +
                    '<td style="padding-left:5px; width: 6%">Banked Agents</td>'         +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                +
                    '<td style="padding-left:5px; width: 3%">%</td>'                     +
                    '<td style="padding-left:5px; width: 10%">New agents</td>'           +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                +
                    '<td style="padding-left:5px; width: 3%">%</td>'                     +
                    '<td style="padding-left:5px; width: 6%">Active DSTs</td>'           +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                +
                    '<td style="padding-left:5px; width: 3%">%</td>'                     +
                    '<td style="padding-left:5px; width: 6%">MM Activations</td>'        +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                +
                    '<td style="padding-left:5px; width: 3%">%</td>'                     +
                    '<td style="padding-left:5px; width: 6%">MM Sub acquisition</td>'    +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                +
                    '<td style="padding-left:5px; width: 3%">%</td>'                     +
                    '<td style="padding-left:5px; width: 6%">Simcard registrations</td>' +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                +
                    '<td style="padding-left:5px; width: 3%">%</td>'                     +
                    '<td style="padding-left:5px; width: 6%">Easytalk new locations</td>'+
                    '<td style="padding-left:5px; width: 4%">Target</td>'                +
                    '<td style="padding-left:5px; width: 3%">%</td>'                     +
                    '<td style="padding-left:5px; width: 6%">Easytalk Installations</td>'+
                    '<td style="padding-left:5px; width: 4%">Target</td>'                +
                    '<td style="padding-left:5px; width: 3%">%</td>'                     +
                    '<td style="padding-left:5px; width: 6%">Card sales</td>'            +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                +
                    '<td style="padding-left:5px; width: 3%">%</td>'                     +
                    '<td style="padding-left:5px; width: 6%">Easytalk Activations</td>'  +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 3%">%</td>'                                 +
                    '<td style="padding-left:5px; width: 6%">Easytalk repairs</td>'                  +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 3%">%</td>'                                 +
                    '<td style="padding-left:5px; width: 6%">Payphone repairs/reactivations</td>'    +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 3%">%</td>'                                 +
                    '<td style="padding-left:5px; width: 6%">Active Internet cafes</td>'             +
                    '<td style="padding-left:5px; width: 4%">Target</td>'                            +
                    '<td style="padding-left:5px; width: 3%">%</td>'                                 +
                '</tr>';                                                 
        Boolean hasData = false;
        String tdrCurrentName = '';
        String currentRegion = '';
        Integer currentRow = 0;
        for (TDR_Performance__c[] summaryList : database.query(getWeeklyTdrSummary(parameters, true))) {
            for (TDR_Performance__c summary : summaryList) {

                Decimal totalReports = 0.0;
                Decimal totalSales = 0.0;
                Decimal totalOther = 0.0;
                Decimal totalTarget = 0.0;

                // If this is a new region the add the row to the table
                if (!summary.Person__r.Region__r.Display_Name__c.equals(currentRegion)) {
                    mainHtml += '<tr style ="'+ getTableRegionRowStyle() + '"><td style="' + getRegionCellStyle() + getMediumFont() + '">' + summary.Person__r.Region__r.Display_Name__c + '</td>'+
                        '<tr><td style="column-span:14; background-color:#FFCC33; alignment-adjust:middle;"></td></tr>';
                    currentRegion = summary.Person__r.Region__r.Display_Name__c;
                }

                hasData = true;
                mainHtml += '<tr style ="'+ getTableBodyStyle() +'">';
                if (!generateTdrName(
                        summary.Person__r.First_Name__c,
                        summary.Person__r.Last_Name__c).equals(tdrCurrentName)
                ) {
                    tdrCurrentName = generateTdrName(
                        summary.Person__r.First_Name__c,
                        summary.Person__r.Last_Name__c
                    );
                    mainHtml += '<td style ="padding-left:5px;">' + tdrCurrentName + '</td>';
                }
                else {
                    mainHtml += '<td></td>';
                }
                mainHtml += '<td style ="padding-left:5px;">' + summary.Start_Time__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.End_Time__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.MM_Agent_Full_Report__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.MM_Agent_Full_Report_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.MM_Agent_Short_Report__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.MM_Agent_Short_Report_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Corporate_Sales_Calls__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Corporate_Sales_Calls_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.School_Sales_Calls__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.School_Sales_Calls_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Customer_Support__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Customer_Support_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Marketing_Event__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Marketing_Event_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Other__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.Other_Target__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.PA_Products__c + '</td>' +
                    '<td style ="padding-left:5px;">' + summary.PA_Products_Target__c + '</td>' +
                    '</tr>';
            }
        }

        // Put together the parts for the final html.
        String html = '';
        if (!hasData) {
            html = 'EMPTY';
            return html;
        }
        html = mainHtml;
        //html += '</tbody></table>';
        html += '</table>';
        html += '<br></div><div>';
        html += createLinkToDashboard(null);
        html += '</div>';
        return html;
    }
    /**
     *  Generate an HTML table for all the TDR_Activity__c for a given time period
     *
     *  @param parameters - A map containing the parameters for the where clause
     *  @param allowAll   - Boolean indicating if the limit should go on. This is needed as dataTable
     *                      only allow 1000 entries
     *
     *  @return - String for the html
     */
    private static String getActivitiesHtml(Map<String, String> parameters, Boolean allowAll) {

        String html = '<table border="1">';
        html += '<tr><td>Sales Rep Name</td><td>Activity Type</td><td>Comment</td><td>Contact Name</td><td>Start Time</td><td>End Time</td></tr>';
        Boolean hasData = false;
        String tdrCurrentName = '';
        for (TDR_Activity__c[] activityList : database.query(getTdrDailyActivities(parameters, true))) {
            for (TDR_Activity__c activity : activityList) {
                Boolean isNewName = false;
                hasData = true;
                html += '<tr>';
                if (!generateTdrName(
                        activity.TDR_Performance_Record__r.Person__r.First_Name__c,
                        activity.TDR_Performance_Record__r.Person__r.Last_Name__c).equals(tdrCurrentName)
                ) {
                    isNewName = true;
                    tdrCurrentName = generateTdrName(
                        activity.TDR_Performance_Record__r.Person__r.First_Name__c,
                        activity.TDR_Performance_Record__r.Person__r.Last_Name__c
                    );
                    html += '<td>' + tdrCurrentName + '</td>';
                }
                else {
                    html += '<td></td>';
                }
                html += '<td>' + activity.Activity_Type__c + '</td>' + activity.Comment__c + '<td>' + activity.Contact_Name__c + '</td>' + activity.Start_Time__c.format() + '<td>' + activity.End_Time__c.format() + '</td></tr>';
            }
        }
        if (!hasData) {
            html = 'EMPTY';
            return html;
        }
        html += '</table>';
        html += '<br />';
        html += createLinkToDashboard(parameters);
        return html;
    }

    /**
     *  Create a link to the TDR Dashboard that will show the dash for the email sent out
     *
     *  @param parameters - A map containing the parameters for the where clause
     *
     *  @return - The link
     */
    private static String createLinkToDashboard(Map<String, String> parameters) {

        String link = '<a href="';
        PageReference pageRef = Page.TdrGraph;
        link += System.URL.getSalesforceBaseUrl().toExternalForm();
        link += pageRef.getUrl();
        link += '"';
        link += '>Click Here for Sales Rep Dashboard</a>';
        return link;
    }

    /**
     *  Build the query string to get the regions required.
     *
     *  @param countryId - The id of a choosen country
     *
     *  @return - The query string to be run
     */
    public static String buildRegionsQueryString(String countryId) {

        String query =
            'SELECT '              +
                'Id, '             +
                'Name, '           +
                'Display_Name__c ' +
            'FROM '                +
                'Region__c';
        if (countryId != null && !countryId.equals('')) {
            query = query + ' ' +
                'WHERE '        +
                    'Country__c = \'' + countryId + '\'';
        }
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    public static String generateTdrName (String firstName, String lastName) {
        return lastName + ' ' + firstName;
    }

    /**
     *  Get an Agent Base map for each Region.
     *
     *  TODO - Make this use the actual agents but for now we are not registereing them so we just
     *  use the temporary object for now
     *
     *  @param parameters - A map containing the parameters for the where clause
     *
     *  @return - A map that has the region Id as the key with the agent base as the value
     */
    public static Map<String, Decimal> getAgentBase(Map<String, String> parameters) {

        String query =
            'SELECT '               +
                'Agent_Base__c, '   +
                'Region__c '        +
            'FROM '                 +
                'MM_Agent_Base__c ' +
            'WHERE '                +
                'Region__c IN (' + getNamedVariable(parameters, 'regions') + ')';

        System.debug(LoggingLevel.INFO, query);

        Map<String, Decimal> agentBaseMap = new Map<String, Decimal>();
        MM_Agent_Base__c[] agentBases = database.query(query);
        for (MM_Agent_Base__c agentBase : agentBases) {
            agentBaseMap.put(agentBase.Id, agentBase.Agent_Base__c);
        }
        return agentBaseMap;
    }

    /**
     *  Generate a comma seperated string that is compatible with the SOQL IN clause.
     *
     *  @param values    - A list of strings that needs to be formatted
     *  @param incQuoted - Show the String have the quotes in
     *
     *  @return - The list or an empty string if no input.
     */
    public static String generateCommaSeperatedString(List<String> values, Boolean incQuotes) {

        String out = '';
        if (values == null || values.size() == 0) {
            return '';
        }
        if (values.size() == 1) {
            if (incQuotes) {
                return '\'' + values.get(0) + '\'';
            }
            return values.get(0);
        }
        else {
            for (String value : values) {
                if (incQuotes) {
                    out = out + '\'' + value + '\',';
                }
                else {
                    out = out + value + ',';
                }
            }
            out = out.substring(0, out.length() -1);
        }
        return out;
    }

    // Some helper methods to convert a Date object into a string that is compatable with SOQL
    // Does the start of a day
    public static Datetime convertToStartDate(Date d) {

        return datetime.newInstance(d, time.newInstance(0, 0, 0, 0));
    }

    // Does the end of a day
    public static Datetime convertToEndDate(Date d) {

        return datetime.newInstance(d, time.newInstance(23, 59, 59, 0));
    }

    public static String convertDateTimeToString(Datetime d, Boolean isDate) {

        // Formatting complies with SOQL
        if (isDate) {
            return d.format('yyyy-MM-dd');
        }
        String output = d.format('yyyy-MM-dd HH:mm:ss', 'EAT');
        output = output.replace(' ', 'T');
        output = output + 'Z';
        return output;
    }
    public static String convertDateToNonSoqlString(DateTime d) {
        return d.format('MM/dd/yyyy');

    }

    // Remember that this will only work for dates that are in the same format as the users
    // locale. I hate SF sometimes.
    public static Date convertStringToDate(String dateString) {
        return Date.parse(dateString);
    }
    public static Date convertSoqlStringToDate(String dateString) {
        String[] dateArray = dateString.split('-');
        return convertStringToDate(dateArray[1] + '/' + dateArray[2] + '/' + dateArray[0]);
    }

    public static String getNamedVariable(Map<String, String> variables, String name) {

        String variable = variables.get(name);
        if (variable == null || variable.equals('')) {
            return '';
        }
        return variable;
    }

    /**
     *  Join a list of where clauses
     */
    public static String joinWhereClause(List<String> clauses, Boolean startWithAnd) {

        // Build the where clause
        String whereString = '';
        if (startWithAnd) {
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

    public static List<String> processTdrPaProductsSurvey(ProcessSurveySubmission.SurveySubmission submission, Person__c person) {
    	
    	// Load the TDR
        TDR__c tdr = loadTdr(person);
        if (tdr == null) {

            //Send an email saying that an unregistered person is trying to act a TDR

            // Send back the error message
            return new String[] { '0', 'User is not a TDR', 'SUPRESSMSG' };
        }

        DateTime handsetSubmitTime = ProcessSurveySubmission.getTimestamp(submission.handsetSubmitTime);
        if (handsetSubmitTime == null) {
            return new String[] { '0', 'No handset submit time in this submission', 'SUPRESSMSG' };
        }
        DateTime submissionStartTime = ProcessSurveySubmission.getTimestamp(submission.submissionStartTime);
        if (submissionStartTime == null) {
            return new String[] { '0', 'No Submission Start Time.', 'SUPRESSMSG' };
        }
        // Create blank target map. This allows all the default targets to be taken if required
        Map<String, String> dummyTargetMap = generateDummyTargetMap();

        // Load the TDRs performance objects. There should be four of these.
        //    1. The Daily object
        //    2. The weekly object
        //    3. The monthly object
        //    4. The yearly object.
        List<TDR_Performance__c> performanceRecords = new List<TDR_Performance__c>();
        TDR_Performance__c dailyPerformance = loadTdrPerformanceRecord(tdr, 'DAILY', getDefaultDate('DAILY', handsetSubmitTime.date()));
        if (dailyPerformance == null) {
            dailyPerformance = createNewTdrPerformanceRecord(tdr, 'DAILY', getDefaultDate('DAILY', handsetSubmitTime.date()), dummyTargetMap);
        }
        updateTdrPerformanceObject(dailyPerformance, 'PA_Products__c', 1, false, submissionStartTime, handsetSubmitTime);
        performanceRecords.add(dailyPerformance);

        TDR_Performance__c weeklyPerformance = loadTdrPerformanceRecord(tdr, 'WEEKLY', getDefaultDate('WEEKLY', handsetSubmitTime.date()));
        if (weeklyPerformance == null) {
            weeklyPerformance = createNewTdrPerformanceRecord(tdr, 'WEEKLY', getDefaultDate('WEEKLY', handsetSubmitTime.date()), dummyTargetMap);
        }
        updateTdrPerformanceObject(weeklyPerformance, 'PA_Products__c', 1, false, submissionStartTime, handsetSubmitTime);
        performanceRecords.add(weeklyPerformance);

        // Sort the monthly performance
        TDR_Performance__c monthlyPerformance = loadTdrPerformanceRecord(tdr, 'MONTHLY', getDefaultDate('MONTHLY', handsetSubmitTime.date()));
        if (monthlyPerformance == null) {
            monthlyPerformance = createNewTdrPerformanceRecord(tdr, 'MONTHLY', getDefaultDate('MONTHLY', handsetSubmitTime.date()), dummyTargetMap);
        }
        updateTdrPerformanceObject(monthlyPerformance, 'PA_Products__c', 1, false, submissionStartTime, handsetSubmitTime);
        performanceRecords.add(monthlyPerformance);

        // Sort the yearly performance
        TDR_Performance__c yearlyPerformance = loadTdrPerformanceRecord(tdr, 'YEARLY', getDefaultDate('YEARLY', handsetSubmitTime.date()));
        if (yearlyPerformance == null) {
            yearlyPerformance = createNewTdrPerformanceRecord(tdr, 'YEARLY', getDefaultDate('YEARLY', handsetSubmitTime.date()), dummyTargetMap);
        }
        updateTdrPerformanceObject(yearlyPerformance, 'PA_Products__c', 1, false, submissionStartTime, handsetSubmitTime);
        //yearlyPerformance.PA_Products__c += 1;
        performanceRecords.add(yearlyPerformance);

        // Update the DB
        database.upsert(performanceRecords);
        
        // Return success
        return new String[] { '1', 'PA Products processed sucessfully', 'SUPRESSMSG' };
    }

    public static List<String> processWeeklyReportVisit(ProcessSurveySubmission.SurveySubmission submission, Map<String, Submission_Answer__c> answers, Person__c person) {
    	
    	TDR_Weekly_Target__c weeklyTarget = [Select 
    	                                           Active_DSTs__c,
    	                                           Active_Internet_Cafes__c,
    	                                           Banked_Agents__c,
    	                                           Card_Sales__c,
    	                                           Easytalk_Activations__c,
    	                                           Easytalk_Installations__c,
    	                                           Easytalk_New_Locations__c,
    	                                           Easytalk_Repairs__c,
    	                                           MM_Sub_Acquisitions__c,
    	                                           Mobile_Money_Activations__c,
    	                                           New_Agents__c,
    	                                           Payphone_Repairs__c,
    	                                           Simcard_Registrations__c
    	                                     From
    	                                           TDR_Weekly_Target__c
    	                                     order by 
    	                                           CreatedDate 
    	                                     desc limit 1];

    	TDR_Weekly_Report__c tdrWeekly = new TDR_Weekly_Report__c();
    	tdrWeekly.Banked_Agents__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q1_0'), 'q1', 0.0);
    	tdrWeekly.Banked_Agents_Targets__c = weeklyTarget.Banked_Agents__c;
    	tdrWeekly.New_Agents__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q2_0'), 'q2', 0.0);
    	tdrWeekly.New_Agents_Target__c = weeklyTarget.New_Agents__c;
    	tdrWeekly.Active_DSTs__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q3_0'), 'q3', 0.0);
    	tdrWeekly.Active_DSTs_Target__c = weeklyTarget.Active_DSTs__c;
    	tdrWeekly.Mobile_Money_Activations__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q4_0'), 'q4', 0.0);
    	tdrWeekly.Mobile_Money_Activations_Target__c = weeklyTarget.Mobile_Money_Activations__c;
    	tdrWeekly.MM_Sub_Acquisitions__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q5_0'), 'q5', 0.0);
    	tdrWeekly.MM_Sub_Acquisitions_Target__c = weeklyTarget.MM_Sub_Acquisitions__c;
    	tdrWeekly.Simcard_Registrations__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q6_0'), 'q6', 0.0);
    	tdrWeekly.Simcard_Registrations_Target__c = weeklyTarget.Simcard_Registrations__c;
    	tdrWeekly.Easytalk_New_Locations__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q7_0'), 'q7', 0.0);
    	tdrWeekly.Easytalk_New_Locations_Target__c = weeklyTarget.Easytalk_New_Locations__c;
    	tdrWeekly.Easytalk_Installations__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q8_0'), 'q8', 0.0);
    	tdrWeekly.Easytalk_Installations_Target__c = weeklyTarget.Easytalk_Installations__c;
    	tdrWeekly.Card_Sales__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q9_0'), 'q9', 0.0);
    	tdrWeekly.Card_Sales_Target__c = weeklyTarget.Card_Sales__c;
    	tdrWeekly.Easytalk_Activations__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q10_0'), 'q10', 0.0);
    	tdrWeekly.Easytalk_Activations_Target__c = weeklyTarget.Easytalk_Activations__c;
    	tdrWeekly.Easytalk_Repairs__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q11'), 'q11', 0.0);
    	tdrWeekly.Easytalk_Repairs_Target__c = weeklyTarget.Easytalk_Repairs__c;
    	tdrWeekly.Payphone_Repairs__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q12'), 'q12', 0.0);
    	tdrWeekly.Payphone_Repairs_Targets__c = weeklyTarget.Payphone_Repairs__c;
    	tdrWeekly.Active_Internet_Cafes__c = ProcessSubmissionHelpers.getAnswerNumber(answers.get('q13_0'), 'q13', 0.0);
    	tdrWeekly.Active_Internet_Cafes_Target__c = weeklyTarget.Active_Internet_Cafes__c;
    	tdrWeekly.Person__c = person.Id;
    	
    	database.insert(tdrWeekly);
    	return new String[] { '1', 'Weekly Report processed sucessfully', 'SUPRESSMSG' };
    }

    /**
     *  Create a IN clause for a SOQL statement
     */
    public static String addInWhereClause(String objectName, Boolean negate, String ids, List<String> idList, Boolean incQuotes) {

        String[] values;
        if (ids != null) {
            values = ids.split(',');
        }
        else {
            values = idList;
        }
        String out = '';
        out = objectName + ' ';
        if (values.size() == 1) {
            if (negate) {
                out = out + '!';
            }
            out = out + '= ';
        }
        else {
            if (negate) {
                out = out + 'NOT ';
            }
            out = out + 'IN (';
        }
        out = out + generateCommaSeperatedString(values, incQuotes);
        if (values.size() > 1) {
            out = out + ')';
        }
        return out;
    }
    // Test methods below here
    /**
     *  Test the processing of an agent visit
     */
    static testMethod void testProcessAgentVisitSurvey() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        // Create a test TDR
        Person__c person = Utils.createTestPerson(null, 'TestingTDR', true, null, 'Female');
        person.Type__c = 'TDR';
        person.Region__c = region.Id;
        database.insert(person);

        TDR__c tdr = new TDR__c();
        tdr.Person__c = person.Id;
        database.insert(tdr);

        TDR__c tdr2 = [SELECT Person__c, Name, Id, Person__r.Id, Person__r.Name, Person__r.Region__c FROM TDR__c WHERE Id = :tdr.Id];

        // Create a some default targets
        List<TDR_Default_Target__c> defaultTargets = new List<TDR_Default_Target__c>();
        TDR_Default_Target__c weeklyTarget = new TDR_Default_Target__c();
        weeklyTarget.Type__c = 'WEEKLY';
        weeklyTarget.Region__c = region.Id;
        weeklyTarget.Corporate_Sales_Calls__c = 1.0;
        weeklyTarget.Customer_Support__c = 2.0;
        weeklyTarget.Marketing_Event__c = 3.0;
        weeklyTarget.MM_Agent_Full_Report__c = 4.0;
        weeklyTarget.MM_Agent_Short_Report__c = 5.0;
        weeklyTarget.Other__c = 6.0;
        weeklyTarget.School_Sales_Calls__c = 7.0;
        weeklyTarget.Start_Date__c = Date.today().toStartOfWeek();
        defaultTargets.add(weeklyTarget);

        // Add an old one to make sure the correct target is found
        TDR_Default_Target__c weeklyTarget2 = new TDR_Default_Target__c();
        weeklyTarget2.Type__c = 'WEEKLY';
        weeklyTarget2.Region__c = region.Id;
        weeklyTarget2.Corporate_Sales_Calls__c = 8.0;
        weeklyTarget2.Customer_Support__c = 9.0;
        weeklyTarget2.Marketing_Event__c = 10.0;
        weeklyTarget2.MM_Agent_Full_Report__c = 11.0;
        weeklyTarget2.MM_Agent_Short_Report__c = 12.0;
        weeklyTarget2.Other__c = 13.0;
        weeklyTarget2.School_Sales_Calls__c = 14.0;
        weeklyTarget2.Start_Date__c = Date.today().addDays(-30).toStartOfWeek();
        defaultTargets.add(weeklyTarget2);

        TDR_Default_Target__c monthlyTarget = new TDR_Default_Target__c();
        monthlyTarget.Type__c = 'MONTHLY';
        monthlyTarget.Region__c = region.Id;
        monthlyTarget.Corporate_Sales_Calls__c = 10.0;
        monthlyTarget.Customer_Support__c = 20.0;
        monthlyTarget.Marketing_Event__c = 30.0;
        monthlyTarget.MM_Agent_Full_Report__c = 40.0;
        monthlyTarget.MM_Agent_Short_Report__c = 50.0;
        monthlyTarget.Other__c = 60.0;
        monthlyTarget.School_Sales_Calls__c = 70.0;
        monthlyTarget.Start_Date__c = Date.today().toStartOfMonth();
        defaultTargets.add(monthlyTarget);

        TDR_Default_Target__c yearlyTarget = new TDR_Default_Target__c();
        yearlyTarget.Type__c = 'YEARLY';
        yearlyTarget.Region__c = region.Id;
        yearlyTarget.Corporate_Sales_Calls__c = 100.0;
        yearlyTarget.Customer_Support__c = 200.0;
        yearlyTarget.Marketing_Event__c = 300.0;
        yearlyTarget.MM_Agent_Full_Report__c = 400.0;
        yearlyTarget.MM_Agent_Short_Report__c = 500.0;
        yearlyTarget.Other__c = 600.0;
        yearlyTarget.School_Sales_Calls__c = 700.0;
        yearlyTarget.Start_Date__c = Date.parse('01/01/' + String.valueOf(Date.today().year()));
        defaultTargets.add(yearlyTarget);
        database.insert(defaultTargets);

        // Run a test submission for today for each type of survey
        List<String> returnValues = new List<String>();
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q46_0', Utils.createTestSubmissionAnswer(null, '', '0123 3210', null, null, null));
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '32432443253';
        submission.resultHash = '1';

        // Test for the full report
        answers.put('q1_0',  Utils.createTestSubmissionAnswer(null, 'q1', '1', null, null, null));
        answers.put('q27_0',  Utils.createTestSubmissionAnswer(null, 'q27', 'Agent Name', null, null, null));
        answers.put('q44_0',  Utils.createTestSubmissionAnswer(null, 'q44', 'This one', null, null, null));
        answers.put('q45_0',  Utils.createTestSubmissionAnswer(null, 'q45', 'MM LONG VISIT', null, null, null));
        answers.put('q31_0',  Utils.createTestSubmissionAnswer(null, 'q31', '100', null, null, null));
        processAgentVisitSurvey(submission, answers, person);
        returnValues = processAgentVisitSurvey(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).equals('Agent visit processed sucessfully'));

        // Test for the short report
        answers.clear();
        answers.put('q46_0', Utils.createTestSubmissionAnswer(null, '', '0123 3210', null, null, null));
        answers.put('q1_0',  Utils.createTestSubmissionAnswer(null, 'q1', '2', null, null, null));
        answers.put('q44_0',  Utils.createTestSubmissionAnswer(null, 'q44', 'This one', null, null, null));
        answers.put('q45_0',  Utils.createTestSubmissionAnswer(null, 'q45', 'MM SHORT VISIT', null, null, null));
        answers.put('q2_0',  Utils.createTestSubmissionAnswer(null, 'q2', 'Agent Name', null, null, null));
        answers.put('q3_0',  Utils.createTestSubmissionAnswer(null, 'q3', '100', null, null, null));
        submission.resultHash = '2';
        returnValues = processAgentVisitSurvey(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).equals('Agent visit processed sucessfully'));

        // Test for corporate sales
        answers.clear();
        answers.put('q46_0', Utils.createTestSubmissionAnswer(null, '', '0123 3210', null, null, null));
        answers.put('q1_0',  Utils.createTestSubmissionAnswer(null, 'q1', '3', null, null, null));
        answers.put('q18_0',  Utils.createTestSubmissionAnswer(null, 'q17', 'Corp Sale', null, null, null));
        answers.put('q19_0',  Utils.createTestSubmissionAnswer(null, 'q18', 'Corp Name', null, null, null));
        answers.put('q44_0',  Utils.createTestSubmissionAnswer(null, 'q44', 'This one', null, null, null));
        answers.put('q45_0',  Utils.createTestSubmissionAnswer(null, 'q45', 'CORPORATE SALES CALL', null, null, null));
        submission.resultHash = '3';
        returnValues = processAgentVisitSurvey(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).equals('Agent visit processed sucessfully'));

        // Test for school sales
        answers.clear();
        answers.put('q46_0', Utils.createTestSubmissionAnswer(null, '', '0123 3210', null, null, null));
        answers.put('q1_0',  Utils.createTestSubmissionAnswer(null, 'q1', '4', null, null, null));
        answers.put('q21_0',  Utils.createTestSubmissionAnswer(null, 'q21', 'School Name', null, null, null));
        answers.put('q22_0',  Utils.createTestSubmissionAnswer(null, 'q22', 'School Contact Name', null, null, null));
        answers.put('q44_0',  Utils.createTestSubmissionAnswer(null, 'q44', 'This one', null, null, null));
        answers.put('q45_0',  Utils.createTestSubmissionAnswer(null, 'q45', 'SCHOOL SALES CALL', null, null, null));
        submission.resultHash = '4';
        returnValues = processAgentVisitSurvey(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).equals('Agent visit processed sucessfully'));

        // Test for customer support
        answers.clear();
        answers.put('q46_0', Utils.createTestSubmissionAnswer(null, '', '0123 3210', null, null, null));
        answers.put('q1_0',  Utils.createTestSubmissionAnswer(null, 'q1', '5', null, null, null));
        answers.put('q14_0',  Utils.createTestSubmissionAnswer(null, 'q14', 'Support Customer Name', null, null, null));
        answers.put('q16_0',  Utils.createTestSubmissionAnswer(null, 'q16', 'Support Contact Name', null, null, null));
        answers.put('q15_0',  Utils.createTestSubmissionAnswer(null, 'q15', 'Support Contact Name', null, null, null));
        answers.put('q44_0',  Utils.createTestSubmissionAnswer(null, 'q44', 'This one', null, null, null));
        answers.put('q45_0',  Utils.createTestSubmissionAnswer(null, 'q45', 'CUSTOMER SUPPORT ISSUE', null, null, null));
        submission.resultHash = '5';
        returnValues = processAgentVisitSurvey(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).equals('Agent visit processed sucessfully'));

        // Test for Marketing event
        answers.clear();
        answers.put('q46_0', Utils.createTestSubmissionAnswer(null, '', '0123 3210', null, null, null));
        answers.put('q1_0',  Utils.createTestSubmissionAnswer(null, 'q1', '6', null, null, null));
        answers.put('q24_0',  Utils.createTestSubmissionAnswer(null, 'q24', 'Marketing Description', null, null, null));
        answers.put('q44_0',  Utils.createTestSubmissionAnswer(null, 'q44', 'This one', null, null, null));
        answers.put('q45_0',  Utils.createTestSubmissionAnswer(null, 'q45', 'MARKETING EVENT DESCRIPTION', null, null, null));
        submission.resultHash = '6';
        returnValues = processAgentVisitSurvey(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).equals('Agent visit processed sucessfully'));

        // Test for other activity
        answers.clear();
        answers.put('q46_0', Utils.createTestSubmissionAnswer(null, '', '0123 3210', null, null, null));
        answers.put('q1_0',  Utils.createTestSubmissionAnswer(null, 'q1', '7', null, null, null));
        answers.put('q25_0',  Utils.createTestSubmissionAnswer(null, 'q25', 'Other Description', null, null, null));
        answers.put('q44_0',  Utils.createTestSubmissionAnswer(null, 'q44', 'This one', null, null, null));
        answers.put('q45_0',  Utils.createTestSubmissionAnswer(null, 'q45', 'OTHER DESCRIPTION', null, null, null));
        submission.resultHash = '7';
        returnValues = processAgentVisitSurvey(submission, answers, person);
        System.assert(returnValues.get(0).equals('1'));

        // Test for a unrecognised activity
        answers.clear();
        answers.put('q46_0', Utils.createTestSubmissionAnswer(null, '', '0123 3210', null, null, null));
        answers.put('q1_0',  Utils.createTestSubmissionAnswer(null, 'q1', '8', null, null, null));
        returnValues = processAgentVisitSurvey(submission, answers, person);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).equals('Type of submission is unrecognised'));

       /* // Dig out the performance records for this guy and check that there is one visit in each and that the targets have defaulted.
        TDR_Performance__c dailyPerformance = loadTdrPerformanceRecord(tdr2, 'DAILY', null);

        TDR_Performance__c weeklyPerformance = loadTdrPerformanceRecord(tdr2, 'WEEKLY', null);
        System.assertEquals(weeklyPerformance.Corporate_Sales_Calls__c, 1);
        System.assertEquals(weeklyPerformance.Corporate_Sales_Calls_Target__c, 1);
        System.assertEquals(weeklyPerformance.Customer_Support__c, 1);
        System.assertEquals(weeklyPerformance.Marketing_Event__c, 1);
        System.assertEquals(weeklyPerformance.MM_Agent_Full_Report__c, 1.0);
        System.assertEquals(weeklyPerformance.MM_Agent_Full_Report_Target__c, 4.0);
        System.assertEquals(weeklyPerformance.MM_Agent_Short_Report__c, 1.0);
        System.assertEquals(weeklyPerformance.MM_Agent_Short_Report_Target__c, 5.0);
        System.assertEquals(weeklyPerformance.Other__c, 1.0);
        System.assertEquals(weeklyPerformance.School_Sales_Calls__c, 1.0);
        System.assertEquals(weeklyPerformance.School_Sales_Calls_Target__c, 7.0);

        TDR_Performance__c monthlyPerformance = loadTdrPerformanceRecord(tdr2, 'MONTHLY', null);
        System.assertEquals(monthlyPerformance.MM_Agent_Full_Report__c, 1.0);
        System.assertEquals(monthlyPerformance.MM_Agent_Full_Report_Target__c, 40.0);
        System.assertEquals(monthlyPerformance.MM_Agent_Short_Report__c, 1.0);
        System.assertEquals(monthlyPerformance.MM_Agent_Short_Report_Target__c, 50.0);
        System.assertEquals(monthlyPerformance.Other__c, 1.0);
        System.assertEquals(monthlyPerformance.School_Sales_Calls__c, 1.0);
        System.assertEquals(monthlyPerformance.School_Sales_Calls_Target__c, 70.0);
        System.assertEquals(monthlyPerformance.MM_Agent_Short_Report__c, 1.0);
        System.assertEquals(monthlyPerformance.MM_Agent_Short_Report_Target__c, 50.0);
        System.assertEquals(monthlyPerformance.School_Sales_Calls__c, 1.0);
        System.assertEquals(monthlyPerformance.School_Sales_Calls_Target__c, 70.0);

        TDR_Performance__c yearlyPerformance = loadTdrPerformanceRecord(tdr2, 'YEARLY', null);
        System.assertEquals(yearlyPerformance.Corporate_Sales_Calls__c, 1.0);
        System.assertEquals(yearlyPerformance.Corporate_Sales_Calls_Target__c, 100.0);
        System.assertEquals(yearlyPerformance.Customer_Support__c, 1.0);
        System.assertEquals(yearlyPerformance.Marketing_Event__c, 1.0);
        System.assertEquals(yearlyPerformance.MM_Agent_Full_Report__c, 1.0);
        System.assertEquals(yearlyPerformance.MM_Agent_Full_Report_Target__c, 400.0);
        System.assertEquals(yearlyPerformance.MM_Agent_Short_Report__c, 1.0);
        System.assertEquals(yearlyPerformance.MM_Agent_Short_Report_Target__c, 500.0);
        System.assertEquals(yearlyPerformance.Other__c, 1.0);
        System.assertEquals(yearlyPerformance.School_Sales_Calls__c, 1.0);
        System.assertEquals(yearlyPerformance.School_Sales_Calls_Target__c, 700.0);

        // Check that all the avtivities were created alright
        TDR_Activity__c mmfrActivity = [
            SELECT
                Activity_Type__c,
                Additional_Comments__c
            FROM
                TDR_Activity__c
            WHERE
                TDR_Performance_Record__c = :dailyPerformance.Id
                AND Activity_Type__c = 'MM Agent Full Report'];
        System.assert(mmfrActivity.Activity_Type__c.equals('MM Agent Full Report'));
        System.assert(mmfrActivity.Additional_Comments__c.equals('MM LONG VISIT'));

        TDR_Activity__c mmsrActivity = [
            SELECT
                Activity_Type__c,
                Additional_Comments__c
            FROM
                TDR_Activity__c
            WHERE
                TDR_Performance_Record__c = :dailyPerformance.Id
                AND Activity_Type__c = 'MM Agent Short Report'];
        System.assert(mmsrActivity.Activity_Type__c.equals('MM Agent Short Report'));
        System.assert(mmsrActivity.Additional_Comments__c.equals('MM SHORT VISIT'));

        TDR_Activity__c cscActivity = [
            SELECT
                Activity_Type__c,
                Additional_Comments__c
            FROM
                TDR_Activity__c
            WHERE
                TDR_Performance_Record__c = :dailyPerformance.Id
                AND Activity_Type__c = 'Corporate Sales'];
        System.assert(cscActivity.Activity_Type__c.equals('Corporate Sales'));
        System.assert(cscActivity.Additional_Comments__c.equals('CORPORATE SALES CALL'));

        TDR_Activity__c sscActivity = [
            SELECT
                Activity_Type__c,
                Additional_Comments__c
            FROM
                TDR_Activity__c
            WHERE
                TDR_Performance_Record__c = :dailyPerformance.Id
                AND Activity_Type__c = 'School Sales'];
        System.assert(sscActivity.Activity_Type__c.equals('School Sales'));
        System.assert(sscActivity.Additional_Comments__c.equals('SCHOOL SALES CALL'));

        TDR_Activity__c csActivity = [
            SELECT
                Activity_Type__c,
                Additional_Comments__c
            FROM
                TDR_Activity__c
            WHERE
                TDR_Performance_Record__c = :dailyPerformance.Id
                AND Activity_Type__c = 'Customer Support'];
        System.assert(csActivity.Activity_Type__c.equals('Customer Support'));
        System.assert(csActivity.Additional_Comments__c.equals('CUSTOMER SUPPORT ISSUE'));

        TDR_Activity__c meActivity = [
            SELECT
                Activity_Type__c,
                Additional_Comments__c
            FROM
                TDR_Activity__c
            WHERE
                TDR_Performance_Record__c = :dailyPerformance.Id
                AND Activity_Type__c = 'Marketing Event'];
        System.assert(meActivity.Activity_Type__c.equals('Marketing Event'));
        System.assert(meActivity.Additional_Comments__c.equals('MARKETING EVENT DESCRIPTION'));

        TDR_Activity__c oActivity = [
            SELECT
                Activity_Type__c,
                Additional_Comments__c
            FROM
                TDR_Activity__c
            WHERE
                TDR_Performance_Record__c = :dailyPerformance.Id
                AND Activity_Type__c = 'Other'];
        System.assert(oActivity.Activity_Type__c.equals('Other'));
        System.assert(oActivity.Additional_Comments__c.equals('OTHER DESCRIPTION'));*/

        // Test with a person who is not a TDR
        Person__c nonTdr = new Person__c();
        answers.put('q46_0', Utils.createTestSubmissionAnswer(null, '', '0123 3210', null, null, null));
        returnValues = processAgentVisitSurvey(submission, answers, nonTdr);
        System.assert(returnValues.get(0).equals('0'));

        // Test with no handset submit time
        ProcessSurveySubmission.SurveySubmission noHandset = new ProcessSurveySubmission.SurveySubmission();
        answers.put('q46_0', Utils.createTestSubmissionAnswer(null, '', '0123 3210', null, null, null));
        returnValues = processAgentVisitSurvey(noHandset, answers, person);
        System.assert(returnValues.get(0).equals('0'));
        System.assert(returnValues.get(1).equals('No handset submit time in this submission'));
    }

    /*
     *  Test generation of tdr query string
     */
    static testMethod void testGenerateTdrQuery() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        // Create a second country and region
        Country__c country2 = Utils.createTestCountry('NEW COUNTRY2');
        database.insert(country2);
        Region__c region2 = Utils.createTestRegion('NEW REGION2', country2);
        database.insert(region2);

        // Create a TDR for each region
        Person__c person = Utils.createTestPerson(null, 'TestingTDR', true, null, 'Female');
        person.Region__c = region.Id;
        database.insert(person);
        TDR__c tdr = new TDR__c();
        tdr.Person__c = person.Id;
        database.insert(tdr);

        Person__c person2 = Utils.createTestPerson(null, 'TestingTDR2', true, null, 'Female');
        person2.Region__c = region2.Id;
        database.insert(person2);
        TDR__c tdr2 = new TDR__c();
        tdr2.Person__c = person2.Id;
        database.insert(tdr2);

        // Load the TDR from the first region
        Map<String, String> parameters = new Map<String, String>();
        List<String> countryId = new List<String>();
        countryId.add((String)country.Id);
        List<String> regionId = new List<String>();
        regionId.add((String)region.Id);
        parameters.put('countries', generateCommaSeperatedString(countryId, true));
        parameters.put('regions', generateCommaSeperatedString(regionId, true));
        List<String> orderBy = new List<String>();
        orderBy.add('Name');
        TDR__c[] tdrs = loadTdrs(parameters, orderBy);
        System.assertEquals(1, tdrs.size());
    }

    static testMethod void testUpdateDefaultPerformance() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        // Generate a target map
        Map<String, String> newTargets = new Map<String, String>();
        newTargets.put('MM_Agent_Full_Report', '2.0');
        newTargets.put('Corporate_Sales_Calls', '2.0');
        newTargets.put('MM_Agent_Short_Report', '2.0');
        newTargets.put('School_Sales_Calls', '2.0');

        // Generate the parameters map to test YEARLY
        Date startDate = Date.today();
        Date startOfYear = Date.parse('01/01/' + startDate.year());
        Map<String, String> parameters = new Map<String, String>();
        parameters.put('type', 'YEARLY');
        parameters.put('regions', '\'' + (String)region.Id + '\'');
        parameters.put('startDate', convertDateTimeToString(convertToStartDate(startOfYear), true));
        parameters.put('endDate', convertDateTimeToString(convertToStartDate(startOfYear.addYears(1).addDays(-1)), true));
        updateDefaultTdrPerformance(parameters, newTargets);

        // Update the parameters map to test MONTHLY
        parameters.put('type', 'MONTHLY');
        parameters.put('startDate', convertDateTimeToString(convertToStartDate(startDate.toStartOfMonth()), true));
        parameters.put('endDate', convertDateTimeToString(convertToStartDate(startOfYear.toStartOfMonth().addMonths(1).addDays(-1)), true));
        updateDefaultTdrPerformance(parameters, newTargets);

        // Update the parameters map to test WEEKLY
        parameters.put('type', 'WEEKLY');
        parameters.put('startDate', convertDateTimeToString(convertToStartDate(startDate.toStartOfWeek()), true));
        parameters.put('endDate', convertDateTimeToString(convertToStartDate(startDate.toStartOfWeek().addDays(28)), true));
        updateDefaultTdrPerformance(parameters, newTargets);

        // Test DAILY
        parameters.put('type', 'DAILY');
        parameters.put('startDate', convertDateTimeToString(convertToStartDate(startDate), true));
        parameters.put('endDate', convertDateTimeToString(convertToStartDate(startDate.addDays(2)), true));
        updateDefaultTdrPerformance(parameters, newTargets);

        // Find out how many Defaults we have created
        TDR_Default_Target__c[] targets = [
            SELECT
                Name
            FROM
                TDR_Default_Target__c
            WHERE
                Region__c = :region.Id];
        System.assertEquals(targets.size(), 8);
    }

    static testMethod void testUpdateTdrPerformance() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        // Create a test TDR
        Person__c person = Utils.createTestPerson(null, 'TestingTDR', true, null, 'Female');
        person.Region__c = region.Id;
        database.insert(person);

        TDR__c tdr = new TDR__c();
        tdr.Person__c = person.Id;
        database.insert(tdr);

        // Generate a target map
        Map<String, String> newTargets = new Map<String, String>();
        newTargets.put('MM_Agent_Full_Report', '2.0');
        newTargets.put('Corporate_Sales_Calls', '2.0');
        newTargets.put('MM_Agent_Short_Report', '2.0');
        newTargets.put('School_Sales_Calls', '2.0');

        // Generate parameters
        Date startDate = Date.today();
        Date startOfYear = Date.parse('01/01/' + startDate.year());
        Map<String, String> parameters = new Map<String, String>();
        parameters.put('type', 'YEARLY');
        parameters.put('regions', '\'' + (String)region.Id + '\'');
        parameters.put('startDate', convertDateTimeToString(convertToStartDate(startOfYear), true));
        parameters.put('endDate', convertDateTimeToString(convertToStartDate(startOfYear.addYears(1).addDays(-1)), true));
        updateTdrPerformanceTarget(parameters, newTargets);

        // Update the parameters map to test MONTHLY
        parameters.put('type', 'MONTHLY');
        parameters.put('startDate', convertDateTimeToString(convertToStartDate(startDate.toStartOfMonth()), true));
        parameters.put('endDate', convertDateTimeToString(convertToStartDate(startOfYear.toStartOfMonth().addMonths(1).addDays(-1)), true));
        updateTdrPerformanceTarget(parameters, newTargets);

        // Update the parameters map to test WEEKLY
        parameters.put('type', 'WEEKLY');
        parameters.put('startDate', convertDateTimeToString(convertToStartDate(startDate.toStartOfWeek()), true));
        parameters.put('endDate', convertDateTimeToString(convertToStartDate(startDate.toStartOfWeek().addDays(28)), true));
        updateTdrPerformanceTarget(parameters, newTargets);

        // Test DAILY
        parameters.put('type', 'DAILY');
        parameters.put('startDate', convertDateTimeToString(convertToStartDate(startDate), true));
        parameters.put('endDate', convertDateTimeToString(convertToStartDate(startDate.addDays(2)), true));
        updateTdrPerformanceTarget(parameters, newTargets);

        // Find out how many targets have been set
        TDR_Performance__c[] targets = [
            SELECT
                Name
            FROM
                TDR_Performance__c
            WHERE
                Person__c = :person.Id];
        System.assertEquals(targets.size(), 10);

        // Update daily and monthly to test updating targets
        parameters.put('type', 'MONTHLY');
        parameters.put('startDate', convertDateTimeToString(convertToStartDate(startDate.toStartOfMonth()), true));
        parameters.put('endDate', convertDateTimeToString(convertToStartDate(startOfYear.toStartOfMonth().addMonths(1).addDays(-1)), true));
        updateTdrPerformanceTarget(parameters, newTargets);

        parameters.put('type', 'DAILY');
        parameters.put('startDate', convertDateTimeToString(convertToStartDate(startDate), true));
        parameters.put('endDate', convertDateTimeToString(convertToStartDate(startDate.addDays(2)), true));
        updateTdrPerformanceTarget(parameters, newTargets);

        // Find out how many targets have been set
        targets = [
            SELECT
                Name
            FROM
                TDR_Performance__c
            WHERE
                Person__c = :person.Id];
        System.assertEquals(targets.size(), 14);
    }

    static testMethod void testGetDailyRecords() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        // Create a TDR for each region
        Person__c person = Utils.createTestPerson(null, 'TestingTDR', true, null, 'Female');
        person.Region__c = region.Id;
        person.Type__c = 'TDR';
        database.insert(person);
        TDR__c tdr = new TDR__c();
        tdr.Person__c = person.Id;
        database.insert(tdr);

        // Create a daily TDR Performance Record
        Date now = date.today();
        Time newTime = Time.newInstance(9, 30, 00, 00);
        TDR_Performance__c dailyRecord = new TDR_Performance__c();
        dailyRecord.Person__c = person.Id;
        dailyRecord.Customer_Support__c = 1.0;
        dailyRecord.Customer_Support_Target__c = 4.0;
        dailyRecord.Marketing_Event__c = 3.0;
        dailyRecord.Marketing_Event_Target__c = 2.0;
        dailyRecord.Marketing_Event_Target__c = 1.0;
        dailyRecord.MM_Agent_Full_Report__c = 5.0;
        dailyRecord.MM_Agent_Full_Report_Target__c = 3.0;
        dailyRecord.MM_Agent_Short_Report__c = 5.0;
        dailyRecord.MM_Agent_Short_Report_Target__c = 3.0;
        dailyRecord.Corporate_Sales_Calls__c = 3.0;
        dailyRecord.Corporate_Sales_Calls_Target__c = 2.0;
        dailyRecord.School_Sales_Calls__c = 3.0;
        dailyRecord.School_Sales_Calls_Target__c = 2.0;
        dailyRecord.Other__c = 1.0;
        dailyRecord.Other_Target__c = 3.0;
        dailyRecord.Start_Date__c = now;
        dailyRecord.Start_Time__c = DateTime.newInstance(now, newTime);
        dailyRecord.End_Time__c = DateTime.newInstance(now, newTime.addMinutes(45));
        dailyRecord.Type__c = 'DAILY';
        database.insert(dailyRecord);

        // Create some TDR Activities for the day.
        List<TDR_Activity__c> activities = new List<TDR_Activity__c>();
        TDR_Activity__c activity1 = new TDR_Activity__c();
        activity1.TDR_Performance_Record__c = dailyRecord.Id;
        activity1.Start_Time__c = DateTime.newInstance(now, newTime);
        activity1.End_Time__c = DateTime.newInstance(now, newTime.addMinutes(45));
        activity1.Comment__c = 'Comment 1';
        activity1.Activity_Type__c = 'MM Agent Full Report';
        activity1.Duplicate_Submission__c = 'activity1';
        activities.add(activity1);
        TDR_Activity__c activity2 = new TDR_Activity__c();
        activity2.TDR_Performance_Record__c = dailyRecord.Id;
        activity2.Start_Time__c = DateTime.newInstance(now, newTime.addMinutes(45));
        activity2.End_Time__c = DateTime.newInstance(now, newTime.addMinutes(90));
        activity2.Comment__c = 'Comment 2';
        activity2.Activity_Type__c = 'MM Agent Short Report';
        activity2.Duplicate_Submission__c = 'activity2';
        activities.add(activity2);
        TDR_Activity__c activity3 = new TDR_Activity__c();
        activity3.TDR_Performance_Record__c = dailyRecord.Id;
        activity3.Start_Time__c = DateTime.newInstance(now, newTime.addMinutes(90));
        activity3.End_Time__c = DateTime.newInstance(now, newTime.addMinutes(125));
        activity3.Comment__c = 'Comment 3';
        activity3.Activity_Type__c = 'Corporate Sales';
        activity3.Duplicate_Submission__c = 'activity3';
        activities.add(activity3);
        TDR_Activity__c activity4 = new TDR_Activity__c();
        activity4.TDR_Performance_Record__c = dailyRecord.Id;
        activity4.Start_Time__c = DateTime.newInstance(now, newTime.addMinutes(125));
        activity4.End_Time__c = DateTime.newInstance(now, newTime.addMinutes(160));
        activity4.Comment__c = 'Comment 4';
        activity4.Activity_Type__c = 'Customer Support';
        activity4.Duplicate_Submission__c = 'activity4';
        activities.add(activity4);
        TDR_Activity__c activity5 = new TDR_Activity__c();
        activity5.TDR_Performance_Record__c = dailyRecord.Id;
        activity5.Start_Time__c = DateTime.newInstance(now, newTime.addMinutes(167));
        activity5.End_Time__c = DateTime.newInstance(now, newTime.addMinutes(194));
        activity5.Comment__c = 'Comment 5';
        activity5.Activity_Type__c = 'School Sales';
        activity5.Duplicate_Submission__c = 'activity5';
        activities.add(activity5);
        TDR_Activity__c activity6 = new TDR_Activity__c();
        activity6.TDR_Performance_Record__c = dailyRecord.Id;
        activity6.Start_Time__c = DateTime.newInstance(now, newTime.addMinutes(200));
        activity6.End_Time__c = DateTime.newInstance(now, newTime.addMinutes(206));
        activity6.Comment__c = 'Comment 6';
        activity6.Activity_Type__c = 'Other';
        activity6.Duplicate_Submission__c = 'activity6';
        activities.add(activity6);

        // Create some Activities for yesterday to make sure they are not found
        now = now.addDays(-1);
        TDR_Performance__c dailyRecord2 = new TDR_Performance__c();
        dailyRecord2.Person__c = person.Id;
        dailyRecord2.Customer_Support__c = 1.0;
        dailyRecord2.Customer_Support_Target__c = 4.0;
        dailyRecord2.Marketing_Event__c = 3.0;
        dailyRecord2.Marketing_Event_Target__c = 2.0;
        dailyRecord2.Marketing_Event_Target__c = 1.0;
        dailyRecord2.MM_Agent_Full_Report__c = 5.0;
        dailyRecord2.MM_Agent_Full_Report_Target__c = 3.0;
        dailyRecord2.MM_Agent_Short_Report__c = 5.0;
        dailyRecord2.MM_Agent_Short_Report_Target__c = 3.0;
        dailyRecord2.Corporate_Sales_Calls__c = 3.0;
        dailyRecord2.Corporate_Sales_Calls_Target__c = 2.0;
        dailyRecord2.School_Sales_Calls__c = 3.0;
        dailyRecord2.School_Sales_Calls_Target__c = 2.0;
        dailyRecord2.Other__c = 1.0;
        dailyRecord2.Other_Target__c = 3.0;
        dailyRecord2.Start_Date__c = now;
        dailyRecord2.Type__c = 'DAILY';
        dailyRecord2.Start_Time__c = DateTime.newInstance(now, newTime);
        dailyRecord2.End_Time__c = DateTime.newInstance(now, newTime.addMinutes(45));
        database.insert(dailyRecord2);

        // Create an Activity
        TDR_Activity__c activity7 = new TDR_Activity__c();
        activity7.TDR_Performance_Record__c = dailyRecord2.Id;
        activity7.Start_Time__c = DateTime.newInstance(now, newTime);
        activity7.End_Time__c = DateTime.newInstance(now, newTime.addMinutes(45));
        activity7.Comment__c = 'Comment 7';
        activity7.Activity_Type__c = 'School Sales';
        activity7.Duplicate_Submission__c = 'activity7';
        activities.add(activity7);
        TDR_Activity__c activity8 = new TDR_Activity__c();
        activity8.TDR_Performance_Record__c = dailyRecord2.Id;
        activity8.Start_Time__c = DateTime.newInstance(now, newTime.addMinutes(45));
        activity8.End_Time__c = DateTime.newInstance(now, newTime.addMinutes(90));
        activity8.Comment__c = 'Comment 8';
        activity8.Activity_Type__c = 'MM Agent Full Report';
        activity8.Duplicate_Submission__c = 'activity8';
        activities.add(activity8);
        database.insert(activities);

        now = now.addDays(1);

        // Create the parameters to get this TDRs performance
        Map<String, String> parameters = new Map<String, String>();
        parameters.put('tdrs', '\'' + person.Id + '\'');

        parameters.put('startDate', convertDateTimeToString(convertToStartDate(now), true));
        parameters.put('endDate', convertDateTimeToString(convertToEndDate(now), true));
        getActivitiesHtml(parameters, true);
        List<String> personIds = new List<String>();
        personIds.add(tdr.Person__c);
        getDailyReportData(personIds, now);
        getSummaryHtml('NEW REGION', true);
        TDR_Activity__c[] fetchedActivities = database.query(getTdrDailyActivities(parameters, false));
        System.assertEquals(fetchedActivities.size(), 6);

        // Add in the check for type and pick up yesterdays
        parameters.put('startDate', convertDateTimeToString(convertToStartDate(now.addDays(-1)), true));
        parameters.put('activityType', 'MM Agent Full Report');
        fetchedActivities = database.query(getTdrDailyActivities(parameters, true));
        System.assertEquals(fetchedActivities.size(), 2);
    }
    
    static testMethod void testProcessTdrPaProductsSurvey() {
    	
    	// Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        // Create a test TDR
        Person__c person = Utils.createTestPerson(null, 'TestingTDR', true, null, 'Female');
        person.Region__c = region.Id;
        database.insert(person);

        TDR__c tdr = new TDR__c();
        tdr.Person__c = person.Id;
        database.insert(tdr);

        TDR__c tdr2 = [SELECT Person__c, Name, Id, Person__r.Id, Person__r.Name, Person__r.Region__c FROM TDR__c WHERE Id = :tdr.Id];

        // Create a some default targets
        List<TDR_Default_Target__c> defaultTargets = new List<TDR_Default_Target__c>();
        TDR_Default_Target__c weeklyTarget = new TDR_Default_Target__c();
        weeklyTarget.Type__c = 'WEEKLY';
        weeklyTarget.Region__c = region.Id;
        weeklyTarget.Start_Date__c = Date.today().toStartOfWeek();
        weeklyTarget.PA_Products__c = 5.0;
        defaultTargets.add(weeklyTarget);

        // Add an old one to make sure the correct target is found
        TDR_Default_Target__c weeklyTarget2 = new TDR_Default_Target__c();
        weeklyTarget2.Type__c = 'WEEKLY';
        weeklyTarget2.Region__c = region.Id;
        weeklyTarget2.Start_Date__c = Date.today().addDays(-30).toStartOfWeek();
        weeklyTarget2.PA_Products__c = 8.0;
        defaultTargets.add(weeklyTarget2);

        TDR_Default_Target__c monthlyTarget = new TDR_Default_Target__c();
        monthlyTarget.Type__c = 'MONTHLY';
        monthlyTarget.Region__c = region.Id;
        monthlyTarget.Start_Date__c = Date.today().toStartOfMonth();
        monthlyTarget.PA_Products__c = 40.0;
        defaultTargets.add(monthlyTarget);

        TDR_Default_Target__c yearlyTarget = new TDR_Default_Target__c();
        yearlyTarget.Type__c = 'YEARLY';
        yearlyTarget.Region__c = region.Id;
        yearlyTarget.Start_Date__c = Date.parse('01/01/' + String.valueOf(Date.today().year()));
        yearlyTarget.PA_Products__c = 500.0;
        defaultTargets.add(yearlyTarget);
        database.insert(defaultTargets);

        // Run a test submission for today
        List<String> returnValues = new List<String>();
       
        ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '32432443253';
        submission.resultHash = '1';
        returnValues = processTdrPaProductsSurvey(submission, person);

        // Dig out the performance records for this guy and check that they have a value
        TDR_Performance__c dailyPerformance = loadTdrPerformanceRecord(tdr2, 'DAILY', null);
        System.assertEquals(dailyPerformance.PA_Products__c, 1.0);
        
        TDR_Performance__c weeklyPerformance = loadTdrPerformanceRecord(tdr2, 'WEEKLY', null);
        System.assertEquals(weeklyPerformance.PA_Products__c, 1.0);

        TDR_Performance__c monthlyPerformance = loadTdrPerformanceRecord(tdr2, 'MONTHLY', null);
        System.assertEquals(monthlyPerformance.PA_Products__c, 1.0);

        TDR_Performance__c yearlyPerformance = loadTdrPerformanceRecord(tdr2, 'YEARLY', null);
        System.assertEquals(yearlyPerformance.PA_Products__c, 1.0);

        System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).equals('PA Products processed sucessfully'));
    }
    
    static testMethod void testProcessWeeklyReportVisit() {
    	
    	ProcessSurveySubmission.SurveySubmission submission = new ProcessSurveySubmission.SurveySubmission();
        submission.handsetSubmitTime = Datetime.now().getTime().format().replace(',', '');
        submission.submissionStartTime = Datetime.now().addMinutes(30).getTime().format().replace(',', '');
        submission.imei = '32432443253';
        submission.resultHash = '1';
        
        Map<String, Submission_Answer__c> answers = new Map<String, Submission_Answer__c>();
        answers.put('q1_0',  Utils.createTestSubmissionAnswer(null, 'q1', '4', null, null, null));
        answers.put('q2_0',  Utils.createTestSubmissionAnswer(null, 'q2', '5', null, null, null));
        answers.put('q3_0',  Utils.createTestSubmissionAnswer(null, 'q3', '6', null, null, null));
        answers.put('q4_0',  Utils.createTestSubmissionAnswer(null, 'q4', '7', null, null, null));
        answers.put('q5_0',  Utils.createTestSubmissionAnswer(null, 'q5', '8', null, null, null));
        answers.put('q6_0',  Utils.createTestSubmissionAnswer(null, 'q6', '7', null, null, null));
        answers.put('q7_0',  Utils.createTestSubmissionAnswer(null, 'q7', '6', null, null, null));
        answers.put('q8_0',  Utils.createTestSubmissionAnswer(null, 'q8', '5', null, null, null));
        answers.put('q9_0',  Utils.createTestSubmissionAnswer(null, 'q9', '4', null, null, null));
        answers.put('q10_0',  Utils.createTestSubmissionAnswer(null, 'q10', '5', null, null, null));
        answers.put('q11_0',  Utils.createTestSubmissionAnswer(null, 'q11', '6', null, null, null));
        answers.put('q12_0',  Utils.createTestSubmissionAnswer(null, 'q12', '7', null, null, null));
        answers.put('q13_0',  Utils.createTestSubmissionAnswer(null, 'q13', '8', null, null, null));
        
        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        // Create a test TDR
        Person__c person = Utils.createTestPerson(null, 'TestingTDR', true, null, 'Female');
        person.Region__c = region.Id;
        database.insert(person);
        
        // Create a target for this test TDR
        TDR_Weekly_Target__c tdrWeeklyTarget = new TDR_Weekly_Target__c();
        tdrWeeklyTarget.Active_DSTs__c = 10.0;
        tdrWeeklyTarget.Active_Internet_Cafes__c = 9.0;
        tdrWeeklyTarget.Banked_Agents__c = 8.0;
        tdrWeeklyTarget.Card_Sales__c = 7.0;
        tdrWeeklyTarget.Easytalk_Activations__c = 6.0;
        tdrWeeklyTarget.Easytalk_Installations__c = 7.0;
        tdrWeeklyTarget.Easytalk_New_Locations__c = 6.0;
        tdrWeeklyTarget.Easytalk_Repairs__c = 8.0;
        tdrWeeklyTarget.MM_Sub_Acquisitions__c = 5.0;
        tdrWeeklyTarget.Mobile_Money_Activations__c = 7.0;
        tdrWeeklyTarget.New_Agents__c = 6.0;
        tdrWeeklyTarget.Payphone_Repairs__c = 5.0;
        tdrWeeklyTarget.Simcard_Registrations__c = 8.0;
        database.insert(tdrWeeklyTarget);
        
        List<String> returnValues = processWeeklyReportVisit(submission, answers, person);
    	System.assert(returnValues.get(0).equals('1'));
        System.assert(returnValues.get(1).equals('Weekly Report processed sucessfully'));
    }
}