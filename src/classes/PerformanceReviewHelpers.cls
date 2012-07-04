/**
 *  Helper file to deal with performance review manipulation
 *
 *  Copyright (c) 2011 AppLab, Grameen Foundation
 */

public with sharing class PerformanceReviewHelpers {

    /**
     *  Re-calculate the searches that a CKW has done for a given month. This will be needed incase
     *  of disputes
     *
     *  @param ckw - The CKW to be updated
     *  @param startDate - The date to start from
     *  @param endDate   - The date to end
     *
     *  @return - A list of three decimals indicating the searches performed
     *              - element1 - Valid Searches
     *              - element2 - Test Searches
     *              - element3 - Invalid Searches
     */
    // Wrapper so can be called with a CKW
    public static List<Decimal> recalculateCkwSearches(CKW__c ckw, Date startDate, Date endDate) {

        // Pull out the Person__c id
        List<String> personIds = new LIst<String>();
        personIds.add((String)ckw.Person__c);
        return recalculateCkwSearches(personIds, startDate, endDate);
    }
    public static List<Decimal> recalculateCkwSearches(List<String> personIds, Date startDate, Date endDate) {

        // Default the dates so the it is for the current month
        if (startDate == null) {
            startDate = Date.today().toStartOfMonth();
        }
        if (endDate == null) {
            endDate = startDate.toStartOfMonth().addMonths(1);
        }

        Decimal validSearches = 0.0;
        Decimal testSearches = 0.0;
        Decimal invalidSearches = 0.0;

        // Get the search logs for the time and people required

        for (Search_Log__c[] searchLogs : Database.query(getSearchLogQuery(personIds, startDate, endDate, false, false))){
            for (Search_Log__c searchLog : searchLogs) {
                if (searchLog.Interviewee__c != null && !searchLog.Interviewee__r.First_Name__c.equalsIgnoreCase('TEST')) {
                    validSearches++;
                }
                else if (searchLog.Interviewee__r.First_Name__c != null && searchLog.Interviewee__r.First_Name__c.equalsIgnoreCase('TEST')) {
                    testSearches++;
                }
                else {
                    invalidSearches++;
                }
            }
        }
        return new Decimal[] { validSearches, testSearches, InvalidSearches };
    }

    /**
     *  Re-calculate the number of farmers that a person has registered in a given time period. Helps to settle disputes
     *
     *  @param personId -
     */

    /**
     *  Load a performance review for a CKW
     *
     *  @param ckwId     - The Id of the CKW that is being updated
     *  @param startDate - The start date of the CKW_Performance_Review__c
     *
     *  @return - The performance review or null if it doesn't exist
     */
    public static CKW_Performance_Review__c loadCkwPerformanceReview(Id ckwId, Date startDate) {

        CKW_Performance_Review__c[] reviews = [
            SELECT
                Id,
                Name,
                Farmers_Registered__c,
                Number_Of_Searches_Running_Total__c,
                Number_Of_Invalid_Searches_Running_Total__c,
                Number_Of_Test_Searches_Running_Total__c,
                Surveys_Approved__c,
                Duplicate_Surveys__c,
                Surveys_Not_Reviewed__c,
                Surveys_Pending__c,
                Surveys_Rejected__c,
                Total_Surveys_Submitted__c,
                Total_Surveys__c,
                Start_Date__c
            FROM
                CKW_Performance_Review__c
            WHERE
                CKW_c__c = :ckwId
                AND Start_Date__c <= :startDate
                AND Start_Date__c >= :startDate.toStartOfMonth()];
        if (reviews.isEmpty()) {
            return null;
        }
        return reviews[0];
    }

    public static String getPerformanceReviewQuery(List<String> personIds, String startDate, String endDate) {

        String query =
            'SELECT '                                           +
                'Id, '                                          +
                'Name, '                                        +
                'CKW_c__r.Person__c, '                          +
                'CKW_c__r.Name, '                               +
                'Farmers_Registered__c, '                       +
                'Total_Searches__c,'                            +
                'Number_Of_Searches_Running_Total__c, '         +
                'Number_Of_Invalid_Searches_Running_Total__c, ' +
                'Number_Of_Test_Searches_Running_Total__c, '    +
                'Surveys_Approved__c, '                         +
                'Duplicate_Surveys__c, '                        +
                'Surveys_Not_Reviewed__c, '                     +
                'Surveys_Pending__c, '                          +
                'Surveys_Rejected__c, '                         +
                'Total_Surveys_Submitted__c, '                  +
                'Total_Surveys__c, '                            +
                'Start_Date__c '                                +
            'FROM '                                             +
                'CKW_Performance_Review__c '                    +
            'WHERE '                                            +
                'Start_Date__c >= ' + startDate + ' '           +
                'AND Start_Date__c < = ' + endDate + ' ';
        if (personIds != null) {
            query += ' AND '+ SoqlHelpers.addInWhereClause('CKW_c__r.Person__c', false, null, personIds, true);
        }
        query += 'ORDER BY CKW_c__r.Person__c, Start_Date__c ';
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *
     */
    public static Map<String, CKW_Performance_Review__c> loadPerformanceReviews(List<String> personIds, Date dateInMonth) {

        // Set the date to the start of the month
        String startDate = MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(dateInMonth.toStartOfMonth()), true);
        String endDate = MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(dateInMonth.toStartOfMonth().addMonths(1)), true);
        Map<String, CKW_Performance_Review__c> reviewMap = new Map<String, CKW_Performance_Review__c>();
        CKW_Performance_Review__c[] reviews = Database.query(getPerformanceReviewQuery(personIds, startDate, endDate));
        if (reviews.isEmpty()) {
            return reviewMap;
        }
        for (CKW_Performance_Review__c review : reviews) {
            reviewMap.put((String)review.CKW_c__r.Person__c, review);
        }
        return reviewMap;
    }
    /**
     *  Create a performance review for a CKW
     *
     *  @param ckw       - The CKW that is being updated
     *  @param startDate - The start date of the CKW_Performance_Review__c
     *
     *  @return - The newly created performance review
     */
    public static CKW_Performance_Review__c createCkwPerformanceReview(
            CKW__c ckw,
            Date startDate,
            Monthly_Target__c monthlyTarget,
            Incentive_Structure__c incentiveStructure
    ) {

        // Create a new CKW Performance Review object for the specified CKW
        CKW_Performance_Review__c review = new CKW_Performance_Review__c();
        review.CKW_c__c = ckw.id;
        review.Start_Date__c = startDate;
        review.Monthly_Target__c = monthlyTarget.id;
        review.Incentive_Structure__c = incentiveStructure.id;

        // Default the counters. I am sure that this should be done by the sObject definition but
        // I have seen erratic SF errors here so I am going to be safe.
        review.Farmers_Registered__c = 0.0;
        review.Number_Of_Searches_Running_Total__c = 0.0;
        review.Number_Of_Invalid_Searches_Running_Total__c = 0.0;
        review.Number_Of_Test_Searches_Running_Total__c = 0.0;
        review.Surveys_Approved__c = 0.0;
        review.Duplicate_Surveys__c = 0.0;
        review.Surveys_Not_Reviewed__c = 0.0;
        review.Surveys_Pending__c = 0.0;
        review.Surveys_Rejected__c = 0.0;
        return review;
    }

    /**
     *  Update a ckws perfomance review.
     *
     *  @param ckw       - The CKW that is being updated
     *  @param startDate - The start date of the CKW_Performance_Review__c
     *  @param field     - Name of the field on CKW_Performance_Review__c that is being updated
     *  @param quantity  - Amount to update the field by
     *  @param overWrite - Overwrite or add to the value
     */
    public static CKW_Performance_Review__c updatePerformanceRecord(
            CKW__c ckw,
            Date startDate,
            String field,
            Decimal quantity,
            Boolean overWrite
    ) {

        CKW_Performance_Review__c review = loadCkwPerformanceReview(ckw.Id, startDate);
        Boolean isNewReview = false;
        if (review == null) {
            review = createCkwPerformanceReview(ckw, startDate, getMonthlyTarget(startDate), getIncentiveStructure(startDate));
            isNewReview = true;
        }
        review = changePerformanceReviewField(review, field, quantity, overWrite);
        database.upsert(review);
        if (isNewReview) {
            database.update(moveToNewReview(ckw, review, null));
        }
        return review;
    }

    /**
     *  Update the performance record for a CKW for a specific record
     *
     *  @param review    - The review to be updated
     *  @param field     - Name of the field on CKW_Performance_Review__c that is being updated
     *  @param quantity  - Amount to update the field by
     *  @param overWrite - Overwrite or add to the value
     *
     *  @return - The update review
     */
    public static CKW_Performance_Review__c changePerformanceReviewField(
            CKW_Performance_Review__c review,
            String field,
            Decimal quantity,
            Boolean overWrite
    ) {

        // Update the field required.
        if (overWrite || review.get(field) == null) {
            review.put(field, quantity);
        }
        else {
            review.put(field, (Decimal)review.get(field) + quantity);
        }
        return review;
    }

    /**
     *  Move a CKW to a new review.
     *
     *  @param ckw           - The CKW that is being updated
     *  @param newReview     - The new performance Review
     *  @param currentReview - The current performance Review
     */
    public static CKW__c moveToNewReview(
            CKW__c ckw,
            CKW_Performance_Review__c newReview,
            CKW_Performance_Review__c currentReview
    ) {

        if (currentReview == null) {
            ckw.Previous_Performance_Review__c = ckw.Current_Performance_Review__c;
        }
        else {
            ckw.Previous_Performance_Review__c = currentReview.Id;
        }
        ckw.Current_Performance_Review__c = newReview.Id;
        return ckw;
    }

    private static Incentive_Structure__c getIncentiveStructure(Date startDate) {

        Incentive_Structure__c structure = [
            SELECT
                id
            FROM
                Incentive_Structure__c
            WHERE
                Start_Date__c <= :startDate
            ORDER BY
                Start_Date__c DESC limit 1];
        return structure;
    }

    private static Monthly_Target__c getMonthlyTarget(Date startDate) {

        Monthly_Target__c target = [
            SELECT
                id
            FROM
                Monthly_Target__c
            WHERE
                Start_Date__c <= :startDate
            ORDER BY
                Start_Date__c DESC limit 1];
        return target;
    }

    /**
     *  Update how many farmers a CKW has registered in a given time.
     *  Start and end dates MUST be in the same month and will default to this month
     *
     *  @param ckwIds            - A list of ckw ids for the interviewer
     *  @param personIds         - A list of person ids for the interviewer
     *  @param startDate         - Date to start looking from.
     *  @param endDate           - Date to end looking from.
     *  @param updatePerformance - Boolean indicating if the Performance Records should actually be updated. Default True
     *                             True = update
     *                             False = dont update send message back
     */
    public static String updateFarmersRegistered(
            List<String> ckwIds,
            List<String> personIds,
            Date startDate,
            Date endDate,
            Boolean updatePerformance
    ) {

        // If the ckwIds are provided then get the personIds for those CKWs
        if (ckwIds != null && personIds == null) {
            personIds = getPersonIds(ckwIds);
        }

        // Set up the defaults if required
        if (startDate == null) {
            startDate = Date.today().toStartOfMonth();
        }
        else {
            startDate = startDate.toStartOfMonth();
        }
        if (endDate == null) {
            endDate = Date.today();
        }
        if (updatePerformance == null) {
            updatePerformance = true;
        }

        // Check that the start and end date are in the same month
        if (startDate.month() != endDate.month()) {

            // Set the end Date to be the end of the month of the startdate
            endDate = startDate.toStartOfMonth().addMonths(1).addDays(-1);
        }

        // Get the number of farmers that have been registered in the time
        AggregateResult[] farmerCounts = database.query(getFarmerCountQuery(personIds, startDate, endDate));
        Map<String, Decimal> numberOfFarmers = new Map<String, Decimal>();
        for (AggregateResult farmerCount : farmerCounts) {
            numberOfFarmers.put((String)farmerCount.get('personId'), (Decimal)farmerCount.get('numberOfFarmers'));
        }

        // Update if required
        String returnValue = 'FAIL';
        if (updatePerformance) {
            if (!updateFarmerReview(numberOfFarmers, personIds, startDate, endDate)) {
                farmerCounts.clear();
                numberOfFarmers.clear();
                return null;
            }
            if (personIds.size() == 1 && numberOfFarmers.get(personIds[0]) != null) {
                returnValue = personIds[0] + '_splitter_' + numberOfFarmers.get(personIds[0]) + '_splitter_';
            }
        }
        else {
            for (String key : numberOfFarmers.keySet()) {
                returnValue += key + '_splitter_' + numberOfFarmers.get(key) + '_splitter_';
            }
        }
        farmerCounts.clear();
        numberOfFarmers.clear();
        return returnValue;
    }

    private static Boolean updateFarmerReview(
        Map<String, Decimal> numberOfFarmers,
        List<String> personIds,
        Date startDate,
        Date endDate
    ) {

        // Set the date to the start of the month
        String startDateString = MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(startDate), true);
        String endDateString = MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(endDate), true);
        Monthly_Target__c target = getMonthlyTarget(endDate);
        Incentive_Structure__c incentive = getIncentiveStructure(endDate);

        // Get the performance records for all the people involved
        CKW_Performance_Review__c[] reviews = Database.query(getPerformanceReviewQuery(personIds, startDateString, endDateString));
        Map<String, CKW_Performance_Review__c> reviewMap = new Map<String, CKW_Performance_Review__c>();
        for (CKW_Performance_Review__c review : reviews) {
            reviewMap.put((String)review.CKW_c__r.Person__c, review);
        }

        // Get a map of the CKWs too as they will need to update their performance records if there are new ones created
        Map<String, CKW__c> ckws = getCkwMap(personIds);

        // Update the reviews
        for (String key : numberOfFarmers.keySet()) {
            CKW_Performance_Review__c review = reviewMap.get(key);
            if (review == null) {
                review = createCkwPerformanceReview(ckws.get(key), startDate, target, incentive);
            }
            review = changePerformanceReviewField(review, 'Farmers_Registered__c', numberOfFarmers.get(key), false);
            reviewMap.put(key, review);
        }

        database.upsert(reviewMap.values());
        reviewMap.clear();
        reviews.clear();
        return true;
    }

    /**
     *  Get the query string to count the number of farmers registered in a given time.
     */
    private static String getFarmerCountQuery(
            List<String> personIds,
            Date startDate,
            Date endDate
    ) {

        String startDateString = MetricHelpers.convertDateTimeToString(startDate, false);
        String endDateString = MetricHelpers.convertDateTimeToString(endDate, false);

        String query =
            'SELECT '                                     +
                'Count(id) numberOfFarmers, '             +
                'Registered_By__c personId '              +
            'FROM '                                       +
                'Farmer__c '                              +
            'WHERE '                                      +
                'CreatedDate >= ' + startDateString + ' ' +
                'AND CreatedDate <= ' + endDateString + ' ';

        // Add the person clause if needed
        if (personIds != null) {
            query += ' AND '+ SoqlHelpers.addInWhereClause('Registered_By__c', false, null, personIds, true);
        }
        query += ' GROUP BY Registered_By__c';
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *  Update the search logs to make searches, that should be valid due to the farmer reg happening after
     *  the search was submitted, valid by adding the interviewee
     *
     *  All parameters are optional - Default is all CKWs for the previous two week and actually update the searches
     *  Dates are based on Server Entry Time.
     *
     *  @param ckwIds     - A list of ckw ids for the interviewer
     *  @param personIds  - A list of person ids for the interviewer
     *  @param startDate  - Date to start looking from.
     *  @param endDate    - Date to end looking from.
     */
    public static String updateInvalidSearches(
            List<String> ckwIds,
            List<String> personIds,
            Date startDate,
            Date endDate,
            Boolean updateRecords
    ) {

        // If the ckwIds are provided then get the personIds for those CKWs
        if (ckwIds != null && personIds == null) {
            personIds = getPersonIds(ckwIds);
            if (personIds.isEmpty()) {
                return 'The are no people that match these ckws. Good effort!';
            }
        }

        // Set up the defaults if required
        if (startDate == null) {
            startDate = Date.today().addDays(-14);
        }
        if (endDate == null) {
            endDate = Date.today();
        }
        if (startDate.daysBetween(endDate) > 30) {
            return 'The dates selected are too far apart';
        }

        // Get the search logs for the period required and pull out the unique invalid farmer ids and the Interviewer Details needed.
        Map<String, Search_Log__c> intervieweDetails = new Map<String, Search_Log__c>();
        Set<String> farmerIds = new Set<String>();

        // This is being put into a collection as it needs to be iterated through twice and the list needs not to change
        Search_Log__c[] logs = Database.query(getSearchLogQuery(personIds, startDate, endDate, true, true));
        if (logs.isEmpty()) {
            return 'There are no search logs for the parameters you have selected';
        }
        for (Search_Log__c log : logs) {
            farmerIds.add(log.Invalid_Farmer_Id__c);
            intervieweDetails.put(log.Name, log);
        }

        // Get the farmer details for all the farmers ids found
        Map<String, Farmer__c> farmerMap = new Map<String, Farmer__c>();
        List<String> farmeIdsList = new List<String>();
        farmeIdsList.addAll(farmerIds);
        for (Farmer__c[] farmers : Database.query(getFarmerQuery(farmeIdsList))) {
            for (Farmer__c farmer : farmers) {
                farmerMap.put(farmer.Name, farmer);
            }
        }
        if (farmerMap.isEmpty()) {
            return 'None of the invalid farmers have been registered yet';
        }

        // Create a map of performance records as they will need to be updated here too.
        // Figure out the months that we could be looking at here
        Boolean isCurrentMonth = false;
        if (Date.today().month() == endDate.month()) {
            isCurrentMonth = true;
        }
        Integer thisMonth = endDate.Month();
        Integer lastMonth = endDate.addMonths(-1).month();
        Map<String, CKW_Performance_Review__c> currentReviews = loadPerformanceReviews(personIds, endDate);
        Map<String, CKW_Performance_Review__c> previousReviews = loadPerformanceReviews(personIds, endDate.addMonths(-1));
        Monthly_Target__c target = getMonthlyTarget(endDate);
        Incentive_Structure__c incentive = getIncentiveStructure(endDate);

        // Get a map of the CKWs too as they will need to update their performance records if there are new ones created
        Map<String, CKW__c> ckws = getCkwMap(personIds);

        // Loop through all the search logs again and update the ones that can be
        Map<String, PerformanceReviewHelpers.UpdatedFarmerStats> stats = new Map<String, PerformanceReviewHelpers.UpdatedFarmerStats>();
        List<Search_Log__c> logsToUpdate = new List<Search_Log__c>();
        for (Search_Log__c log : logs) {

            // Check that the stats map has this interviewer in it
            if (!stats.containsKey((String)log.Interviewer__c)) {
                stats.put(log.Interviewer__c, new PerformanceReviewHelpers.UpdatedFarmerStats(log.Interviewer__c));
            }

            // Check that the farmer now exists
            Farmer__c farmer = farmerMap.get(log.Invalid_Farmer_Id__c);
            if (farmer == null) {
                stats.get(log.Interviewer__c).addToFarmersIgnored(1, false);
            }
            else {
                stats.get(log.Interviewer__c).addToFarmersUpdated(1, false);
                log.Interviewee__c = farmer.Person__c;
                log.Invalid_Farmer_Id__c = null;
                logsToUpdate.add(log);

                // Update the performance record for this person if they have one
                if (updateRecords) {
                    CKW__c ckw = ckws.get(log.Interviewer__c);
                    if (ckw != null) {
                        Boolean isNewReview = false;

                        // Check that this search was recent enough to count for a performance update
                        Integer logMonth = log.Handset_submit_Time__c.date().month();
                        if (logMonth == thisMonth) {

                            CKW_Performance_Review__c ckwReview = currentReviews.get(log.Interviewer__c);

                            // Create a new review if they do not have one
                            if (ckwReview == null) {
                                ckwReview = createCkwPerformanceReview(ckw, log.Handset_submit_Time__c.date(), target, incentive);
                                isNewReview = true;
                            }
                            ckwReview = changePerformanceReviewField(ckwReview, 'Number_Of_Searches_Running_Total__c', 1.0, false);

                            // If this is a new review the up date the CKW so it is pointin at the correct review
                            if (isNewReview && isCurrentMonth) {
                                ckws.put(log.Interviewer__c, moveToNewReview(ckw, ckwReview, null));
                            }
                            currentReviews.put(log.Interviewer__c, ckwReview);
                        }
                        else if (logMonth == lastMonth) {
                            CKW_Performance_Review__c ckwReview = previousReviews.get(log.Interviewer__c);

                            // Create a new review if they do not have one
                            if (ckwReview == null) {
                                ckwReview = createCkwPerformanceReview(ckw, log.Handset_submit_Time__c.date(), target, incentive);
                                isNewReview = true;
                            }
                            ckwReview = changePerformanceReviewField(ckwReview, 'Number_Of_Searches_Running_Total__c', 1.0, false);

                            // If this is a new review the up date the CKW so it is pointin at the correct review
                            if (isNewReview && isCurrentMonth) {
                                ckw.Previous_Performance_Review__c = ckwReview.Id;
                                ckws.put(log.Interviewer__c, ckw);
                            }
                            previousReviews.put(log.Interviewer__c, ckwReview);
                        }
                    }
                }
            }
        }

        logs.clear();

        // Update everything
        String returnString = '';
        if (updateRecords) {
            database.upsert(previousReviews.values());
            database.upsert(currentReviews.values());
            database.update(ckws.values());
            database.update(logsToUpdate);
            returnString =  'SUCCESS';
        }
        else {

            // Build the return string that can be split to show data back to the user
            for (String key : stats.keySet()) {
                returnString += stats.get(key).toOutString() + '_splitter_';
            }
        }
        return returnString;
    }

    /**
     *  Get the review stats for a given ckw
     */
    public static UpdatedReviewFigures getUpdateReviewFigures(
        String personId,
        Date startDate,
        Date endDate,
        Boolean updateRecords
    ) {

        // Get the Performance Reviews for the people and put them into a map
        String startDateString = MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(startDate), true);
        String endDateString = MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(endDate), true);

        // Get the performance records for all the people involved
        CKW_Performance_Review__c[] reviews = Database.query(getPerformanceReviewQuery(new String[] { personId }, startDateString, endDateString));
        CKW_Performance_Review__c review = null;
        if (!reviews.isEmpty()) {
            review = reviews[0];
        }

        UpdatedReviewFigures newFigures = new UpdatedReviewFigures(personId, review);

        // Get the farmers registered
        String farmersRegistered = updateFarmersRegistered(null, new String[] { personId }, startDate, endDate, updateRecords);

        // Get the updated searches once the farmers have been added to the searches.
        String invalidSearches = updateInvalidSearches(null, new String[] { personId } ,startDate, endDate, updateRecords);
        if (!farmersRegistered.equals('FAIL')) {
            newFigures.newFarmersRegistered = Integer.valueOf(farmersRegistered.split('_splitter_').get(1));
        }

        // Get the current searches
        List<Decimal> currentSearches = recalculateCkwSearches(new String[] { personId }, startDate, endDate);
        newFigures.newValidSearches = currentSearches[0].intValue();
        newFigures.newTestSearches = currentSearches[1].intValue();
        newFigures.newInvalidSearches = currentSearches[2].intValue();

        String[] updatedSearches = invalidSearches.split('_splitter_');
        if (updatedSearches.size() > 1) {
            newFigures.newInvalidSearches -= Integer.valueOf(updatedSearches[1]);
            newFigures.newValidSearches += Integer.valueOf(updatedSearches[1]);
        }
        if (updateRecords) {
            CKW__c ckw = Utils.loadCkwFromPersonSalesforceId(personId);
            if (ckw == null) {
                 return newFigures;
            }
            if (review == null) {
                review = createCkwPerformanceReview(ckw, startDate, getMonthlyTarget(startDate), getIncentiveStructure(startDate));
            }
            changePerformanceReviewField(review, 'Farmers_Registered__c', newFigures.newFarmersRegistered, true);
            changePerformanceReviewField(review, 'Number_Of_Test_Searches_Running_Total__c', newFigures.newTestSearches, true);
            changePerformanceReviewField(review, 'Number_Of_Searches_Running_Total__c', newFigures.newValidSearches, true);
            changePerformanceReviewField(review, 'Number_Of_Invalid_Searches_Running_Total__c', newFigures.newInvalidSearches, true);
            database.upsert(review);
            newFigures.currentReview = review;
        }
        return newFigures;
    }

    /**
     *  Get the Person__c for a bunch of CKWs
     */
    private static List<String> getPersonIds(List<String> ckwIds) {

        String query =
            'SELECT '        +
                'Person__c ' +
            'FROM '          +
                'CKW__c '    +
            'WHERE '         +
                SoqlHelpers.addInWhereClause('Id', false, null, ckwIds, true);

        CKW__c[] ckws = Database.query(query);
        List<String> personIds = new List<String>();
        for (CKW__c ckw : ckws) {
            personIds.add(ckw.Person__c);
        }
        return personIds;
    }

    /**
     *  Generate a map for Person__c.Id to CKW__c
     */
    private static Map<String, CKW__c> getCkwMap(List<String> personIds) {

        // Generate the query
        String query =
            'SELECT '                              +
                'Name, '                           +
                'Id, '                             +
                'Current_Performance_Review__c, '  +
                'Previous_Performance_Review__c, ' +
                'Person__c '                       +
            'FROM '                                +
                'CKW__c '                          +
            'WHERE '                               +
                SoqlHelpers.addInWhereClause('Person__c', false, null, personIds, true);

        CKW__c[] ckws = Database.query(query);
        if (ckws.isEmpty()) {
            return null;
        }
        Map<String, CKW__c> ckwMap = new Map<String, CKW__c>();
        for (CKW__c ckw : ckws) {
            ckwMap.put(ckw.Person__c, ckw);
        }
        return ckwMap;
    }

    /**
     *  Build the query to get the search logs
     */
    private static String getSearchLogQuery(List<String> personIds, Date startDate, Date endDate, Boolean ignoreInvalid, Boolean onlyIncludeInvalid) {

        // Convert the start and end dates into strings for the query
        String startTimeString = MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(startDate), false);
        String endTimeString = MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(endDate), false);
        String query =
            'SELECT '                                                 +
                'Id, '                                                +
                'Name, '                                              +
                'Invalid_Farmer_Id__c, '                              +
                'Handset_Submit_Time__c, '                            +
                'Interviewee__c, '                                    +
                'Interviewee__r.Name, '                               +
                'Interviewee__r.First_Name__c, '                      +
                'Interviewee__r.Last_Name__c, '                       +
                'Interviewer__c, '                                    +
                'Interviewer__r.Name, '                               +
                'Interviewer__r.First_Name__c, '                      +
                'Interviewer__r.Last_Name__c '                        +
            'FROM '                                                   +
                'Search_Log__c '                                      +
            'WHERE '                                                  +
                'Server_Entry_Time__c >= ' + startTimeString + ' '    +
                'AND Server_Entry_Time__c <= ' + endTimeString + ' '  +
                'AND From_USSD__c = false ';
        if (onlyIncludeInvalid) {
            query += ' AND Invalid_Farmer_Id__c != null';
        }
        if (ignoreInvalid) {
            query += ' AND Interviewer__c != null';
        }

        // Add the person clause if needed
        if (personIds != null) {
            query += ' AND '+ SoqlHelpers.addInWhereClause('Interviewer__c', false, null, personIds, true);
        }
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *  Build the query string to get the farmer details based on the Farmer__c.Name
     */
    private static String getFarmerQuery(List<String> farmerCardIds) {

        // Build the query
        String query =
            'SELECT '                    +
                'Name, '                 +
                'Person__c, '            +
                'Registered_By__r.Name ' +
            'FROM '                      +
                'Farmer__c '             +
            'WHERE '                     +
                'Registered_By__c != null ';
        query += 'AND '+ SoqlHelpers.addInWhereClause('Name', false, null, farmerCardIds, true);

        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *  Class to hold the stats for the updating of farmers
     */
    public class UpdatedFarmerStats {

        public String personName;
        public Integer farmersUpdated;
        public Integer farmersIgnored;

        public UpdatedFarmerStats(String personName) {
            this.personName = personName;
            this.farmersUpdated = 0;
            this.farmersIgnored = 0;
        }

        // Add a value to the farmers updated
        public void addToFarmersUpdated(Integer newValue, Boolean overWrite) {
            if (overWrite) {
                this.farmersUpdated = newValue;
            }
            else {
                this.farmersUpdated += newValue;
            }
        }

        // Add a value to the farmers ignored
        public void addToFarmersIgnored(Integer newValue, Boolean overWrite) {
            if (overWrite) {
                this.farmersIgnored = newValue;
            }
            else {
                this.farmersIgnored += newValue;
            }
        }

        // Generate a String representation of this object
        public String toOutString() {
            return this.personName + '_splitter_' + this.farmersUpdated + '_splitter_' + this.farmersIgnored;
        }
    }

    // Test Methods
    static testMethod void testCreateAndUpdateReview() {

        Date startDate = Date.today().toStartOfMonth();

        // Create a CKW
        CKW__c testCkw = Utils.createTestCkw(null, 'TEST1', true, null, null);
        database.insert(testCkw);

        // Test the addition to each field
        CKW_Performance_Review__c review = updatePerformanceRecord(testCkw, startDate, 'Farmers_Registered__c', 1.0, false);
        review = changePerformanceReviewField(review, 'Number_Of_Searches_Running_Total__c', 1.0, false);
        review = changePerformanceReviewField(review, 'Number_Of_Invalid_Searches_Running_Total__c', 1.0, false);
        review = changePerformanceReviewField(review, 'Number_Of_Test_Searches_Running_Total__c', 1.0, false);
        review = changePerformanceReviewField(review, 'Surveys_Approved__c', 1.0, false);
        review = changePerformanceReviewField(review, 'Duplicate_Surveys__c', 1.0, false);
        review = changePerformanceReviewField(review, 'Surveys_Not_Reviewed__c', 1.0, false);
        review = changePerformanceReviewField(review, 'Surveys_Pending__c', 1.0, false);
        review = changePerformanceReviewField(review, 'Surveys_Rejected__c', 1.0, false);
        System.assertEquals(1.0, review.Farmers_Registered__c);
        System.assertEquals(1.0, review.Number_Of_Searches_Running_Total__c);
        System.assertEquals(1.0, review.Number_Of_Invalid_Searches_Running_Total__c);
        System.assertEquals(1.0, review.Number_Of_Test_Searches_Running_Total__c);
        System.assertEquals(1.0, review.Surveys_Approved__c);
        System.assertEquals(1.0, review.Duplicate_Surveys__c);
        System.assertEquals(1.0, review.Surveys_Not_Reviewed__c);
        System.assertEquals(1.0, review.Surveys_Pending__c);
        System.assertEquals(1.0, review.Surveys_Rejected__c);

        // Test overwriting
        review = changePerformanceReviewField(review, 'Farmers_Registered__c', 4.0, true);
        review = changePerformanceReviewField(review, 'Number_Of_Searches_Running_Total__c', 4.0, true);
        review = changePerformanceReviewField(review, 'Number_Of_Invalid_Searches_Running_Total__c', 4.0, true);
        review = changePerformanceReviewField(review, 'Number_Of_Test_Searches_Running_Total__c', 4.0, true);
        review = changePerformanceReviewField(review, 'Surveys_Approved__c', 4.0, true);
        review = changePerformanceReviewField(review, 'Duplicate_Surveys__c', 4.0, true);
        review = changePerformanceReviewField(review, 'Surveys_Not_Reviewed__c', 4.0, true);
        review = changePerformanceReviewField(review, 'Surveys_Pending__c', 4.0, true);
        review = changePerformanceReviewField(review, 'Surveys_Rejected__c', 4.0, true);
        System.assertEquals(4.0, review.Farmers_Registered__c);
        System.assertEquals(4.0, review.Number_Of_Searches_Running_Total__c);
        System.assertEquals(4.0, review.Number_Of_Invalid_Searches_Running_Total__c);
        System.assertEquals(4.0, review.Number_Of_Test_Searches_Running_Total__c);
        System.assertEquals(4.0, review.Surveys_Approved__c);
        System.assertEquals(4.0, review.Duplicate_Surveys__c);
        System.assertEquals(4.0, review.Surveys_Not_Reviewed__c);
        System.assertEquals(4.0, review.Surveys_Pending__c);
        System.assertEquals(4.0, review.Surveys_Rejected__c);
    }

    static testMethod void testRecalculateSearches() {

        Date startDate = Date.today().toStartOfMonth();

        // Create a CKW
        CKW__c testCkw = Utils.createTestCkw(null, 'TEST1', true, null, null);
        database.insert(testCkw);

        // Create a test farmer
        Farmer__c testFarmer = Utils.createTestFarmer('OD01234', null, 'OWEN', true, null, null);
        database.insert(testFarmer);

        // Create the test farmer to ensure that he is not being found
        Person__c testPerson3 = new Person__c();
        testPerson3.First_Name__c = 'TeSt';
        testPerson3.Last_Name__c = 'TeSt';
        database.insert(testPerson3);

        Farmer__c testFarmer2 = new Farmer__c();
        testFarmer2.Person__c = testPerson3.Id;
        database.insert(testFarmer2);

        // Generate the various search logs that are needed to test
        List<Search_Log__c> logs = new List<Search_Log__c>();
        Search_Log__c entryThisMonthValid = new Search_Log__c();
        entryThisMonthValid.Server_Entry_Time__c = startDate.addDays(5);
        entryThisMonthValid.Handset_Submit_Time__c = startDate.addDays(4);
        entryThisMonthValid.Interviewer__c = testCkw.Person__c;
        entryThisMonthValid.Interviewee__c = testFarmer.Person__c;
        entryThisMonthValid.Latitude__c = 0.00;
        entryThisMonthValid.Longitude__c = 0.00;
        entryThisMonthValid.Altitude__c = 0.00;
        entryThisMonthValid.Accuracy__c = 0.00;
        entryThisMonthValid.Category__c = 'Category';
        entryThisMonthValid.Query__c = 'Query';
        logs.add(entryThisMonthValid);

        // Crate a Search Log for the test farmer for this month
        Search_Log__c entryThisMonthTest = new Search_Log__c();
        entryThisMonthTest.Server_Entry_Time__c = startDate.addDays(5);
        entryThisMonthTest.Handset_Submit_Time__c = startDate.addDays(4);
        entryThisMonthTest.Interviewer__c = testCkw.Person__c;
        entryThisMonthTest.Interviewee__c = testFarmer2.Person__c;
        entryThisMonthTest.Latitude__c = 0.00;
        entryThisMonthTest.Longitude__c = 0.00;
        entryThisMonthTest.Altitude__c = 0.00;
        entryThisMonthTest.Accuracy__c = 0.00;
        entryThisMonthTest.Category__c = 'Category';
        entryThisMonthTest.Query__c = 'Query';
        logs.add(entryThisMonthTest);

        // Log for this month for an invalid search
        Search_Log__c entryThisMonthInvalid = new Search_Log__c();
        entryThisMonthInvalid.Server_Entry_Time__c = startDate.addDays(5);
        entryThisMonthInvalid.Handset_Submit_Time__c = startDate.addDays(4);
        entryThisMonthInvalid.Interviewer__c = testCkw.Person__c;
        entryThisMonthInvalid.Interviewee__c = null;
        entryThisMonthInvalid.Latitude__c = 0.00;
        entryThisMonthInvalid.Longitude__c = 0.00;
        entryThisMonthInvalid.Altitude__c = 0.00;
        entryThisMonthInvalid.Accuracy__c = 0.00;
        entryThisMonthInvalid.Category__c = 'Category';
        entryThisMonthInvalid.Query__c = 'Query';
        logs.add(entryThisMonthInvalid);
        database.insert(logs);
        Decimal[] values = recalculateCkwSearches(testCkw, startDate, null);
        System.assertEquals(1.0, values[0]);
        System.assertEquals(1.0, values[1]);
        System.assertEquals(1.0, values[2]);
    }

    static testMethod void testUpdateSearchLog() {

        // Create an Interviewer
        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, null, null);
        database.insert(ckw);

        // Create a farmer
        Farmer__c farmer1 = Utils.createTestFarmer('OD99999', null, 'TestFarmer1', true, null, null);
        farmer1.Registered_By__c = ckw.Person__c;
        database.insert(farmer1);

        Date startDate = Date.today();
        Time startTime = Time.newInstance(09, 00, 00, 00);
        DateTime serverEntryTime = DateTime.newInstance(startDate, startTime);
        DateTime lastMonth = DateTime.newInstance(startDate.addMonths(-1), startTime);

        // Create a search log with the farmer as an invalid id for this month
        Search_Log__c validLog = new Search_Log__c();
        validLog.Invalid_Farmer_Id__c = 'OD99999';
        validLog.Interviewer__c = ckw.Person__c;
        validLog.Handset_Submit_Time__c = serverEntryTime;
        validLog.Server_Entry_Time__c = serverEntryTime;
        database.insert(validLog);

        // Create a second valid log so we can check that only the one perf record gets created
        Search_Log__c validLog1 = new Search_Log__c();
        validLog1.Invalid_Farmer_Id__c = 'OD99999';
        validLog1.Interviewer__c = ckw.Person__c;
        validLog1.Handset_Submit_Time__c = serverEntryTime;
        validLog1.Server_Entry_Time__c = serverEntryTime;
        database.insert(validLog1);

        // Create a search log with the farmer as an invalid id for this month
        Search_Log__c validLog2 = new Search_Log__c();
        validLog2.Invalid_Farmer_Id__c = 'OD99999';
        validLog2.Interviewer__c = ckw.Person__c;
        validLog2.Server_Entry_Time__c = serverEntryTime;
        validLog2.Handset_Submit_Time__c = lastMonth;
        database.insert(validLog2);

        // Create a serach log that won't be found
        Search_Log__c invalidLog = new Search_Log__c();
        invalidLog.Invalid_Farmer_Id__c = 'OD99998';
        invalidLog.Interviewer__c = ckw.Person__c;
        invalidLog.Server_Entry_Time__c = serverEntryTime;
        invalidLog.Handset_Submit_Time__c = serverEntryTime;
        database.insert(invalidLog);

        // Test updating
        String result = updateInvalidSearches(null, new String[] { ckw.Person__c }, null, null, true);
        System.assert(result.equals('SUCCESS'));

        // Check that the serach log now has a farmer attached to id
        Search_Log__c log =
            [SELECT
                Interviewee__c,
                Invalid_Farmer_ID__c
            FROM
                Search_Log__c
            WHERE
                id = :validLog.Id];
        System.assert(log.Invalid_Farmer_ID__c == null);
        System.assert(log.Interviewee__c == farmer1.Person__c);

        // Check that this CKW now has two performance reviews
        CKW_Performance_Review__c[] reviews =
            [SELECT
                Start_Date__c,
                Number_Of_Searches_Running_Total__c
             FROM
                CKW_Performance_Review__c
             WHERE
                CKW_c__c = :ckw.Id
             ORDER BY
                Start_Date__c];
        System.assertEquals(reviews.size(), 2);

        // Check that the two performance records created are of the right months and have the right number in them
        System.assertEquals(reviews.get(0).Number_Of_Searches_Running_Total__c, 1);
        System.assertEquals(reviews.get(1).Number_Of_Searches_Running_Total__c, 2);
        System.assertEquals(reviews.get(0).Start_Date__c.month(), Date.today().addMonths(-1).month());
        System.assertEquals(reviews.get(1).Start_Date__c.month(), Date.today().month());

        // Create an Interviewer with no searches
        CKW__c ckw1 = Utils.createTestCkw(null, 'TestCKW2', true, null, null);
        database.insert(ckw1);
        result = updateInvalidSearches(null, new String[] { ckw1.Person__c }, null, null, false);
        System.assert(result.equals('There are no search logs for the parameters you have selected'));
    }

    static testMethod void testUpdatedFarmerStats () {

        PerformanceReviewHelpers.UpdatedFarmerStats stats = new PerformanceReviewHelpers.UpdatedFarmerStats('NAME');
        System.assert(stats.toOutString().equals('NAME_splitter_0_splitter_0'));
        stats.addToFarmersUpdated(1, false);
        stats.addToFarmersIgnored(2, false);
        System.assert(stats.toOutString().equals('NAME_splitter_1_splitter_2'));
        stats.addToFarmersUpdated(3, true);
        stats.addToFarmersIgnored(4, true);
        System.assert(stats.toOutString().equals('NAME_splitter_3_splitter_4'));
    }

    	static testMethod void testUpdateAll() {

        // Create an Interviewer
        CKW__c ckw = Utils.createTestCkw(null, 'TestCKW1', true, null, null);
        database.insert(ckw);

        // Create a farmer
        Farmer__c farmer1 = Utils.createTestFarmer('OD99999', null, 'TestFarmer1', true, null, null);
        farmer1.Registered_By__c = ckw.Person__c;
        database.insert(farmer1);

        Date startDate = Date.today();
        Time startTime = Time.newInstance(09, 00, 00, 00);
        DateTime serverEntryTime = DateTime.newInstance(startDate, startTime);
        DateTime lastMonth = DateTime.newInstance(startDate.addMonths(-1), startTime);

        // Create a search log with the farmer as an invalid id for this month
        Search_Log__c validLog = new Search_Log__c();
        validLog.Invalid_Farmer_Id__c = 'OD99999';
        validLog.Interviewer__c = ckw.Person__c;
        validLog.Handset_Submit_Time__c = serverEntryTime;
        validLog.Server_Entry_Time__c = serverEntryTime;
        database.insert(validLog);

        // Create a second valid log so we can check that only the one perf record gets created
        Search_Log__c validLog1 = new Search_Log__c();
        validLog1.Invalid_Farmer_Id__c = 'OD99999';
        validLog1.Interviewer__c = ckw.Person__c;
        validLog1.Handset_Submit_Time__c = serverEntryTime;
        validLog1.Server_Entry_Time__c = serverEntryTime;
        database.insert(validLog1);

        // Create a search log with the farmer as an invalid id for this month
        Search_Log__c validLog2 = new Search_Log__c();
        validLog2.Invalid_Farmer_Id__c = 'OD99999';
        validLog2.Interviewer__c = ckw.Person__c;
        validLog2.Server_Entry_Time__c = serverEntryTime;
        validLog2.Handset_Submit_Time__c = lastMonth;
        database.insert(validLog2);

        // Create a serach log that won't be found
        Search_Log__c invalidLog = new Search_Log__c();
        invalidLog.Invalid_Farmer_Id__c = 'OD99998';
        invalidLog.Interviewer__c = ckw.Person__c;
        invalidLog.Server_Entry_Time__c = serverEntryTime;
        invalidLog.Handset_Submit_Time__c = serverEntryTime;
        database.insert(invalidLog);

        UpdatedReviewFigures reviewFigures = getUpdateReviewFigures(ckw.Person__c, startDate, startDate, true);
    }
}