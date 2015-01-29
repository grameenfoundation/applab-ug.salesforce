/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  Test methods in class TestPerformanceDataCollector
 **/
public with sharing class PerformanceDataCollector {

    private date currentStartDate;
    private date currentEndDate;
    private date previousStartDate;
    private date previousEndDate;

    private Monthly_Target__c currentMonthlyTarget;
    private Monthly_Target__c previousMonthlyTarget;
    private Incentive_Structure__c currentIncentiveStructure;
    private Incentive_Structure__c previousIncentiveStructure;

    public Map<string,ckwPerformanceData> currentCkwStatistics {get; set;}
    private Map<string,ckwPerformanceData> previousCkwStatistics;
    private Map<String,Integer> surveyPoints; 

    public String surveyDatabase {get; set;}
    public String searchDatabase {get; set;}
    public String serverUrl {get; set;}

    public PerformanceDataCollector() {

        // For now, we will assume that we always want to deal with data for two pay
        // periods, and that pay periods start on the first day and end on the last
        // day of the month. In future, we may want an object in Salesforce to specify 
        // date ranges, especially if we think it will be common to start campaigns 
        // mid-month and/or support variable-length pay periods. 
        this.currentStartDate = date.today().toStartOfMonth();
        this.currentEndDate = this.currentStartDate.addMonths(1);
        this.previousStartDate = this.currentStartDate.addMonths(-1);
        this.previousEndDate = this.currentEndDate.addMonths(-1);

        // Now that search log is in salesforce we need to be careful of the limits imposed
        // upon us by the system.  Therefore we are running the query for the previous day and
        // adding the results to the monthly total.
        this.currentMonthlyTarget = initializeMonthlyTarget(this.currentStartDate);
        this.previousMonthlyTarget = initializeMonthlyTarget(this.previousStartDate);

        this.currentIncentiveStructure = initializeIncentiveStructure(this.currentStartDate);
        this.previousIncentiveStructure = initializeIncentiveStructure(this.previousStartDate);

        this.currentCkwStatistics = new Map<string,ckwPerformanceData>();
        this.previousCkwStatistics = new Map<string,ckwPerformanceData>();
        initializeSurveyPoints();
        initializeServerConstants();
    }

    @future(callout=true)
    public static void collectAndUpdateCkwData() {

            PerformanceDataCollector dataCollector = new PerformanceDataCollector();

            // Query for search and survey performance statistics. We *must* make all of our
            // web service callouts before our DML operations, otherwise Salesforce will complain.
            // We can't encapsulate these in the PerformanceDataCollector constructor because
            // they must be called from a method with the @future attribute.
            dataCollector.getCurrentSurveyStatistics();
            dataCollector.getPreviousSurveyStatistics();

            // Get the searches conducted. Comment out for the moment and delete soon if the real time update works
            //dataCollector.getDailySearchStatistics();

            // Get the farmers registered
            dataCollector.getFarmersRegistered('THIS_MONTH', dataCollector.currentCkwStatistics);
            dataCollector.getFarmersRegistered('LAST_MONTH', dataCollector.previousCkwStatistics);

            // Get the surveys from Salesforce
            dataCollector.getSalesforceSurveys('THIS_MONTH', dataCollector.currentCkwStatistics);
            dataCollector.getSalesforceSurveys('LAST_MONTH', dataCollector.previousCkwStatistics);

            // Make sure all CKWs have a performance review objects for the current and previous
            // pay periods
            dataCollector.validateCkwPerformanceReviewObjects(); 

            // Make sure performance review objects are linked to the correct monthly target
            // object, in case new ones have been added since the review was created
            dataCollector.validateMonthlyTargetLinks();

            // Update CKW performance review objects with performance data
            dataCollector.updateReviewObjects();

            // Send out an email to confirm that we have run this process
            String[] toAddress = new String[]{};
            toAddress.add(EmailHelpers.getTechEmailAddress());
            String subject = 'Performance Data Collector Run Complete on ' + DateTime.now().format();
            String message = 'The performance data collector has run';
            Messaging.SingleEmailMessage[] mail = new Messaging.SingleEmailMessage[] { EmailHelpers.createEmail(toAddress, subject, message) };
            EmailHelpers.sendEmails(mail);
    }

    private Monthly_Target__c initializeMonthlyTarget(date startDate) {

        Monthly_Target__c target = [
            SELECT
                id
            FROM
                Monthly_Target__c
            WHERE
                Start_Date__c <= :startDate 
            ORDER BY
                Start_Date__c DESC limit 1];
        System.debug('Monthly Target ID: ' + target.id);
        return target;
    }

    private Incentive_Structure__c initializeIncentiveStructure(date startDate) {

        Incentive_Structure__c structure = [
            SELECT
                id
            FROM
                Incentive_Structure__c
            WHERE
                Start_Date__c <= :startDate 
            ORDER BY
                Start_Date__c DESC limit 1];
        System.debug('Incentive Structure ID: ' + structure.id);
        return structure;
    }

    private void initializeSurveyPoints() {

        this.surveyPoints = new Map<String,Integer>();

        Survey__c[] surveys = [
            SELECT
                Point_Value__c,
                Name
            FROM
                Survey__c];
        for (Survey__c survey : surveys) {
            surveyPoints.put(survey.Name, survey.Point_Value__c.intValue());
        }
    }

    private void initializeServerConstants() {

        Server_Configuration__c configuration = [
            SELECT
                URL__c,
                Survey_Database__c,
                Search_Database__c
            FROM
                Server_Configuration__c LIMIT 1];
        this.serverUrl = configuration.URL__c;
        this.surveyDatabase = configuration.Survey_Database__c;
        this.searchDatabase = configuration.Search_Database__c; 
    }

    public CKW__c[] getCkwsWithNoReviewObject() {

        CKW__c[] ckwsWithoutReviews = [
            SELECT
                id,
                Current_Performance_Review__c,
                Previous_Performance_Review__c 
            FROM
                CKW__c
            WHERE
                id NOT IN (
                    SELECT
                        CKW_c__c
                    FROM
                        CKW_Performance_Review__c
                    WHERE
                        Start_Date__c =:this.currentStartDate
                )];
        System.debug('# of CKWs with no review: ' + ckwsWithoutReviews.size());
        return ckwsWithoutReviews;
    }

    private CKW__c[] getCkwsWithNoPreviousReviewObject() {
        CKW__c[] ckwsWithoutPreviousReviews = [
            SELECT
                id
            FROM
                CKW__c
            WHERE
                id NOT IN (
                    SELECT
                        CKW_c__c
                    FROM
                        CKW_Performance_Review__c
                    WHERE
                        Start_Date__c = :this.previousStartDate)];
        System.debug(LoggingLevel.DEBUG, '# of CKWs with no review: ' + ckwsWithoutPreviousReviews.size());
        return ckwsWithoutPreviousReviews;
    }

    public void validateCkwPerformanceReviewObjects() {

        CKW__c[] ckwsWithoutReviews = getCkwsWithNoReviewObject();
        CKW__c[] ckwsWithoutPreviousReviews = getCkwsWithNoPreviousReviewObject();

        Set<String> ckwIdsWithoutPreviousReviews = new Set<String>();
        for (CKW__c ckw : ckwsWithoutPreviousReviews ) {
            ckwIdsWithoutPreviousReviews.add(ckw.id);
        }

        List<CKW_Performance_Review__c> createdReviewObjects = new List<CKW_Performance_Review__c>();
        Map<CKW__c,List<CKW_Performance_Review__c>> ckwReviewMapping = new Map<CKW__c,List<CKW_Performance_Review__c>>(); 

        for (CKW__c ckw : ckwsWithoutReviews) {
            List<CKW_Performance_Review__c> reviews = createCkwPerformanceReviews(ckw, ckwIdsWithoutPreviousReviews.contains(ckw.id)); 
            ckwReviewMapping.put(ckw, reviews);
            for (CKW_Performance_Review__c review : reviews) {
                createdReviewObjects.add(review);
            }
        }
        Database.SaveResult[] insertResults = Database.insert(createdReviewObjects);
        for (Database.SaveResult result : insertResults) {
            if (!result.isSuccess()) {
                ErrorLog.writeLater('PerformanceDataCollector', 'validateCkwPerformanceReviewObjects', 
                    'Failed to create performance review object: ' + result.getId(), 2);
            }
        }

        // Set links on the CKW object to point to the current and previous performance reviews.
        // We can't do this in the above loop because the review objects need to be inserted in
        // the database before they will have valid IDs.
        for (CKW__c ckw : ckwsWithoutReviews) {
            List<CKW_Performance_Review__c> reviews = ckwReviewMapping.get(ckw);

            // The previous month's review already existed
            if(reviews.size() == 1) {
                ckw.Previous_Performance_Review__c = ckw.Current_Performance_Review__c;
                ckw.Current_Performance_Review__c = reviews[0].id;
            } else if (reviews.size() == 2) {

                // We created the previous month's review
                ckw.Previous_Performance_Review__c = reviews[1].id;
                ckw.Current_Performance_Review__c = reviews[0].id;
            } else {
                System.debug(LoggingLevel.DEBUG, 'Empty CKW review set for CKW ' + ckw.id);
            }
        }

        Database.SaveResult[] updateResults = Database.update(ckwsWithoutReviews);
        for (Database.SaveResult result : updateResults) {
            if (!result.isSuccess()) {
                ErrorLog.writeLater('PerformanceDataCollector', 'validateCkwPerformanceReviewObjects', 
                    'Failed to update CKW object: ' + result.getId(), 2);
            }
        }
    }

    public List<CKW_Performance_Review__c> createCkwPerformanceReviews(CKW__c ckw, Boolean createPreviousReviewObject) {       

        List<CKW_Performance_Review__c> createdReviews = new List<CKW_Performance_Review__c>();

        CKW_Performance_Review__c currentReview = createCkwPerformanceReview(ckw, this.currentStartDate,
            this.currentMonthlyTarget, this.currentIncentiveStructure);
        createdReviews.add(currentReview);

        if(createPreviousReviewObject) {
            CKW_Performance_Review__c previousReview = createCkwPerformanceReview(ckw, this.previousStartDate,
                this.previousMonthlyTarget, this.previousIncentiveStructure);
            createdReviews.add(previousReview);
        }

        return createdReviews;
    }

    private CKW_Performance_Review__c createCkwPerformanceReview(CKW__c ckw, date startDate, 
        Monthly_Target__c monthlyTarget, Incentive_Structure__c incentiveStructure) {

        // Create a new CKW Performance Review object for the specified CKW
        CKW_Performance_Review__c review = new CKW_Performance_Review__c();
        review.CKW_c__c = ckw.id;
        review.Start_Date__c = startDate;
        review.Monthly_Target__c = monthlyTarget.id;
        review.Incentive_Structure__c = incentiveStructure.id;

        // Needs to be defaulted as we are doing a += now not just an =
        review.Number_Of_Searches__c = 0.0;
        review.Number_Of_Searches_Running_Total__c = 0.0;
        review.Number_Of_Test_Searches_Running_Total__c = 0.0;
        review.Number_Of_Invalid_Searches_Running_Total__c = 0.0;
        return review;
    }

    private void validateMonthlyTargetLinks() {
        updateIncorrectMonthlyTargets(this.currentStartDate, this.currentMonthlyTarget);
        updateIncorrectMonthlyTargets(this.previousStartDate, this.previousMonthlyTarget);
    }

    private void updateIncorrectMonthlyTargets(date startDate, Monthly_Target__c target) {

        CKW_Performance_Review__c[] reviews = [
            SELECT
                id,
                Monthly_Target__c
            FROM
                CKW_Performance_Review__c 
            WHERE
                Start_Date__c = :startDate
                AND Monthly_Target__c != :target.id];
        System.debug(LoggingLevel.DEBUG, '# of reviews with incorrect target: ' + reviews.size());

        for(CKW_Performance_Review__c review : reviews) {
            review.Monthly_Target__c = this.currentMonthlyTarget.id;
        }

        Database.update(reviews);
    }

    private void getCurrentSurveyStatistics() {

        if(this.currentStartDate != null && this.currentEndDate != null) {
            getSurveyStatistics(this.currentStartDate, this.currentEndDate, this.currentCkwStatistics);
        }
    }

    private void getPreviousSurveyStatistics() {
        if(this.previousStartDate != null && this.previousEndDate != null) {
            getSurveyStatistics(this.previousStartDate, this.previousEndDate, this.previousCkwStatistics);
        }
    }

    private void getSurveyStatistics(date startDate, date endDate, Map<string,ckwPerformanceData> ckwStatistics) {
        String surveyQuery =
            'SELECT ' +
                'submissions.interviewer_id, ' +
                'surveys.survey_id, ' +
                'sum(case when submissions.survey_status=\'Approved\' then 1 else 0 end) as Approved, ' +
                'sum(case when submissions.survey_status=\'Rejected\' then 1 else 0 end) as Rejected, ' +
                'sum(case when submissions.survey_status=\'Pending\' then 1 else 0 end) as Pending, ' +
                'sum(case when submissions.survey_status=\'Not Reviewed\' then 1 else 0 end) as NotReviewed, ' +
                'sum(case when submissions.survey_status=\'Duplicate\' then 1 else 0 end) as Duplicates ' +
            'FROM ' + 
                this.surveyDatabase + '.zebrasurveysubmissions submissions INNER JOIN ' +
                this.surveyDatabase + '.zebrasurvey surveys ' + 
                'ON submissions.survey_id = surveys.id ' +
            'WHERE ' +
                'submissions.handset_submit_time &gt;= \'' + SqlHelpers.formatDate(startDate) + '\' ' + 
                'AND submissions.handset_submit_time &lt; \'' + SqlHelpers.formatDate(endDate) + '\' ' +
                'AND submissions.interviewer_id != \'\' ' +
            'GROUP BY ' +
                'submissions.interviewer_id, submissions.survey_id';

        String requestBody = constructRequestXml('Surveys', surveyQuery); 
        String queryResult = SqlHelpers.postServletRequest(this.serverUrl, 'select', requestBody);

        parseSurveyResults(queryResult, ckwStatistics);
    }

    public void getFarmersRegistered(String monthString, Map<string,ckwPerformanceData> ckwStatistics) {

        Map<Id, Integer> farmerPersonId = new Map<Id, Integer>();
        List<String> personIds = new List<String>();
        Map<String, Integer> farmerCkwName = new Map<String, Integer>();
        String query =
            'SELECT '                                                     +
                'count(Id) total, '                                       +
                'Registered_By__c Id '                                    +
            'FROM '                                                       +
                'Farmer__c '                                              +
            'WHERE '                                                      +
                'Performance_Date__c = ' + monthString + ' '              +
                'AND Registered_By__c IN (SELECT Person__c FROM CKW__c) ' +
                'AND Person__r.First_Name__c != \'Not Registered\' '      +
            'GROUP BY '                                                   +
                'Registered_By__c';

        AggregateResult[] farmersRegistered = database.query(query);
        for (AggregateResult farmerRegistered: farmersRegistered) {
            farmerPersonId.put((Id)farmerRegistered.get('id'), (Integer)farmerRegistered.get('total'));
            personIds.add((String)farmerRegistered.get('id'));
        }
        Map<String, String> variables = new Map<String, String>();
        variables.put('ckws', MetricHelpers.generateCommaSeperatedString(personIds, true));
        CKW__c[] ckws = database.query(SoqlHelpers.getCkws(variables, false));

        // Now create the Map the uses the CKW__c.name as its key to keep in line with what we used before.
        for (CKW__c ckw : ckws) {
            String ckwName = String.valueOf(ckw.Name);
            if (ckwStatistics.containsKey(ckwName)) {
                ckwStatistics.get(ckwName).farmersRegistered = farmerPersonId.get(ckw.Person__c);
            }
            else {
                CkwPerformanceData ckwData = new CkwPerformanceData();
                ckwData.farmersRegistered = farmerPersonId.get(ckw.Person__c);
                ckwStatistics.put(ckwName, ckwData);
            }
        }
    }

    public void getSalesforceSurveys(String monthString, Map<string,ckwPerformanceData> ckwStatistics) {

        Map<String, CkwSalesforceSurveys> submissionNameMap = new Map<String, CkwSalesforceSurveys>();
        Set<String> personIdsSet = new Set<String>();

        String query =
            'SELECT '                               +
                'Survey__r.Point_Value__c, '        +
                'Interviewer__r.Id, '               +
                'Handset_Submit_Time__c, '          +
                'Data_Collection_Review_Status__c ' +
            'FROM '                                 +
                'Submission_Meta_Data__c '          +
            'WHERE '                                +
                'Interviewer__c != null '           +
                'AND Handset_Submit_Time__c = ' + monthString;

        for (Submission_Meta_Data__c[] submissions :  database.query(query)){
            for (Submission_Meta_Data__c submission : submissions) {
                String personId = (String)submission.Interviewer__r.Id;
                CkwSalesforceSurveys ckwSalesforceSurveys = submissionNameMap.get(personId);
                personIdsSet.add(personId);

                if (ckwSalesforceSurveys == null) {
                    ckwSalesforceSurveys = new CkwSalesforceSurveys();
                }

                // Find which type of submission status this survey has and add it to the correct field
                String status = submission.Data_Collection_Review_Status__c;
                Integer pointValue = 1;
                if (submission.Survey__r.Point_Value__c != null) {
                    pointValue = submission.Survey__r.Point_Value__c.intValue();
                }
                if (status.equals('Not Reviewed')) {
                    ckwSalesforceSurveys.notReviewedSurveys += 1 * pointValue;
                }
                else if (status.equals('Pending')) {
                    ckwSalesforceSurveys.pendingSurveys += 1 * pointValue;
                }
                else if (status.equals('Rejected')) {
                    ckwSalesforceSurveys.rejectedSurveys += 1 * pointValue;
                }
                else if (status.equals('Approved')) {
                    ckwSalesforceSurveys.approvedSurveys += 1 * pointValue;
                }
                else if (status.equals('Flagged')) {
                    ckwSalesforceSurveys.pendingSurveys += 1 * pointValue;
                }
                submissionNameMap.put(personId, ckwSalesforceSurveys);
            }
        }

        if(submissionNameMap.size() > 0){
            List<String> personIds = new List<String>();
            personIds.addAll(personIdsSet);
            Map<String, String> variables = new Map<String, String>();
            variables.put('ckws', MetricHelpers.generateCommaSeperatedString(personIds, true));

            // Save the data to the ckwStats object
            for(CKW__c[] ckws : database.query(SoqlHelpers.getCkws(variables, false))){
                for (CKW__c ckw : ckws) {
                    String ckwName = String.valueOf(ckw.Name);
                    if(ckwStatistics.containsKey(ckwName)) {
                        ckwStatistics.get(ckwName).pendingSurveys += submissionNameMap.get(ckw.Person__c).pendingSurveys;
                        ckwStatistics.get(ckwName).approvedSurveys += submissionNameMap.get(ckw.Person__c).approvedSurveys;
                        ckwStatistics.get(ckwName).rejectedSurveys += submissionNameMap.get(ckw.Person__c).rejectedSurveys;
                        ckwStatistics.get(ckwName).notReviewedSurveys += submissionNameMap.get(ckw.Person__c).notReviewedSurveys;
                    }
                    else {
                        CkwPerformanceData ckwData = new CkwPerformanceData();
                        ckwData.pendingSurveys = submissionNameMap.get(ckw.Person__c).pendingSurveys;
                        ckwData.approvedSurveys = submissionNameMap.get(ckw.Person__c).approvedSurveys;
                        ckwData.rejectedSurveys = submissionNameMap.get(ckw.Person__c).rejectedSurveys;
                        ckwData.notReviewedSurveys = submissionNameMap.get(ckw.Person__c).notReviewedSurveys;
                        ckwStatistics.put(ckwName, ckwData);
                    }
                }
            }
        }
    }

    public void getDailySearchStatistics() {

        // Get the count of the search log. Annoyingly cant group by Interviewer__r.Name.
        // This is why we need to go throug the long process below
        Map<Id, CkwDailySearches> logCountId   = new Map<Id, CkwDailySearches>();
        Map<String, CkwDailySearches> logCountName = new Map<String, CkwDailySearches>();

        Set<Id> ckwPersonIds = new Set<Id>();
        for(CKW__c[] ckws: [
            SELECT
                Id, 
                Person__c 
            FROM 
                CKW__c]
        ){
            for(CKW__c ckw: ckws) {
                ckwPersonIds.add(ckw.Person__c);
            }
        }

        // Build up the query to get the Ckw.Name
        // Get the list of CKW__c.Person__r.Id's that are returned and use them to search for the CKW__c.Name
        String listId = '';

        for (Search_Log__c[] searchLogs : [
            SELECT
                Interviewer__c,
                Handset_Submit_Time__c,
                Interviewee__c,
                Interviewee__r.First_Name__c
            FROM
                Search_Log__c
            WHERE
                Server_Entry_Time__c = YESTERDAY
                AND Interviewer__c != null
                AND Interviewer__c 
                IN : ckwPersonIds
        ]){

            for (Search_Log__c searchLog : searchLogs) {
                CkwDailySearches dailySearches;
                    if (logCountId.containsKey(searchLog.Interviewer__c)) {
                        dailySearches = logCountId.get(searchLog.Interviewer__c);
                    }
                    else {
                        dailySearches = new CkwDailySearches();
                    }

                if (thisMonth(searchLog.Handset_Submit_Time__c.date())) {
                    if (searchLog.Interviewee__c != null && !searchLog.Interviewee__r.First_Name__c.equalsIgnoreCase('TEST')) {
                        dailySearches.currentMonthSearches++;
                    }
                    else if (searchLog.Interviewee__r.First_Name__c != null && searchLog.Interviewee__r.First_Name__c.equalsIgnoreCase('TEST')) {
                        dailySearches.currentMonthTestSearches++;
                    }
                    else {
                        dailySearches.currentMonthInvalidSearches++;
                    }
                }
                else {
                    if (searchLog.Interviewee__c != null && !searchLog.Interviewee__r.First_Name__c.equalsIgnoreCase('TEST')) {
                        dailySearches.previousMonthSearches++;
                    }
                    else if (searchLog.Interviewee__r.First_Name__c != null && searchLog.Interviewee__r.First_Name__c.equalsIgnoreCase('TEST')) {
                        dailySearches.previousMonthTestSearches++;
                    }
                    else {
                        dailySearches.previousMonthInvalidSearches++;
                    }
                }

                logCountId.put(searchLog.Interviewer__c, dailySearches);

                listId = listId + '\'' + searchLog.Interviewer__c + '\', ';
            }
        }
        if (listId != ''){

            // Need to trim of the last ,
            Integer stringEnd = listId.length() -2;
            listId = listId.substring(0, stringEnd);

            String query = 'SELECT Person__c, Name FROM CKW__c WHERE Person__c IN (' + listId + ')';

            CKW__c[] ckws = database.query(query);

            // Now create the Map the uses the CKW__c.name as its key to keep in line with what we used before.
            for (CKW__c ckw : ckws) {
                logCountName.put(String.valueOf(ckw.Name), logCountId.get(ckw.Person__c));
            }

            for (String ckwId: logCountName.keySet()) {
                storeNewSearchCount(ckwId, logCountName.get(ckwId));
            }
        }
    }

    private boolean thisMonth(Date testDate) {

        date now = date.today();
        if (testDate.month() == now.month()) {
            return true;
        }
        return false;
    }

    private void storeNewSearchCount (String ckwId, CkwDailySearches dailySearches) {

        if(this.currentCkwStatistics.containsKey(ckwId)) {
            this.currentCkwStatistics.get(ckwId).totalSearches = dailySearches.currentMonthSearches;
            this.currentCkwStatistics.get(ckwId).totalInvalidSearches = dailySearches.currentMonthInvalidSearches;
            this.currentCkwStatistics.get(ckwId).totalTestSearches = dailySearches.currentMonthTestSearches;
        } else {
            CkwPerformanceData ckwData = new CkwPerformanceData();
            ckwData.totalSearches = dailySearches.currentMonthSearches;
            ckwData.totalInvalidSearches = dailySearches.currentMonthInvalidSearches;
            ckwData.totalTestSearches = dailySearches.currentMonthTestSearches;
            this.currentCkwStatistics.put(ckwId, ckwData);
        }

        if(this.previousCkwStatistics.containsKey(ckwId)) {
            this.previousCkwStatistics.get(ckwId).totalSearches = dailySearches.previousMonthSearches;
            this.previousCkwStatistics.get(ckwId).totalInvalidSearches = dailySearches.previousMonthInvalidSearches;
            this.previousCkwStatistics.get(ckwId).totalTestSearches = dailySearches.previousMonthTestSearches;
        } else {
            CkwPerformanceData ckwData = new CkwPerformanceData();
            ckwData.totalSearches = dailySearches.previousMonthSearches;
            ckwData.totalInvalidSearches = dailySearches.previousMonthInvalidSearches;
            ckwData.totalTestSearches = dailySearches.previousMonthTestSearches;
            this.previousCkwStatistics.put(ckwId, ckwData);
        }
    }

    private String constructRequestXml(String target, String query) {
        String requestBody = '<?xml version="1.0"?>' +
            '<SelectRequest xmlns="http://schemas.applab.org/2010/07" target="' + target + '">' +
            query + '</SelectRequest>';
        return requestBody;
    }

    public void parseSurveyResults(String surveyResultXml, Map<string,ckwPerformanceData> ckwStatistics) {
        XmlStreamReader surveyResultReader = new XmlStreamReader(surveyResultXml);
        surveyResultReader.next(); // skip the opening <results> tag
                
        while(surveyResultReader.hasNext()) {
            if(surveyResultReader.isStartElement()) {
                parseCkwSurveyRow(surveyResultReader, ckwStatistics);
            }
            surveyResultReader.next();
        }
    }

    private void parseCkwSurveyRow(XmlStreamReader surveyResultReader, Map<string,ckwPerformanceData> ckwStatistics) {
        if(surveyResultReader.getLocalName() == 'row') {
            surveyResultReader.next(); // skip the <row> tag

            String ckwId = parseElement(surveyResultReader);
            String surveyId = parseElement(surveyResultReader);
            Integer approvedSurveys = Integer.valueOf(parseElement(surveyResultReader));
            Integer rejectedSurveys = Integer.valueOf(parseElement(surveyResultReader));
            Integer pendingSurveys = Integer.valueOf(parseElement(surveyResultReader));
            Integer notReviewedSurveys = Integer.valueOf(parseElement(surveyResultReader));
            Integer duplicateSurveys = Integer.valueOf(parseElement(surveyResultReader));

            Integer surveyPoints = getSurveyPoints(surveyId);

            if(ckwStatistics.containsKey(ckwId)) {
                CkwPerformanceData ckwData = ckwStatistics.get(ckwId);
                ckwData.approvedSurveys += surveyPoints * approvedSurveys;
                ckwData.rejectedSurveys += surveyPoints * rejectedSurveys;
                ckwData.pendingSurveys += surveyPoints * pendingSurveys;
                ckwData.notReviewedSurveys += surveyPoints * notReviewedSurveys;
                ckwData.duplicateSurveys += duplicateSurveys;
            } else {
                CkwPerformanceData ckwData = new CkwPerformanceData();
                ckwData.approvedSurveys = surveyPoints * approvedSurveys;
                ckwData.rejectedSurveys = surveyPoints * rejectedSurveys;
                ckwData.pendingSurveys = surveyPoints * pendingSurveys;
                ckwData.notReviewedSurveys = surveyPoints * notReviewedSurveys;
                ckwData.duplicateSurveys = duplicateSurveys;
                ckwStatistics.put(ckwId, ckwData);
            }
        }
    }

    private String parseElement(XmlStreamReader reader) {
        reader.next(); // skip the opening <column> tag

        String result = reader.getText();

        reader.next(); // move on to the next element
        reader.next(); // skip the closing </column> tag

        return result;
    }

    private Integer getSurveyPoints(String surveyId) {  
        Integer points = this.surveyPoints.get(surveyId);

        if(points == null) {

            // If the survey isn't found, assume it is worth 1 point and log error
            ErrorLog.writeLater('PerformanceDataCollector', 'getSurveyPoints', 
                'Attempting to look up points for non-existent survey ' + surveyId, 2);
            return 1;
        } else {
            return points;
        }
    }
        
    public void updateReviewObjects() {
        List<CKW_Performance_Review__c> updatedPerformanceReviews = new List<CKW_Performance_Review__c>();

        CKW_Performance_Review__c[] performanceReviews =
            [SELECT
                CKW_c__r.Name,
                Start_Date__c,
                Number_Of_Searches__c,
                Number_Of_Searches_Running_Total__c,
                Number_Of_Invalid_Searches_Running_Total__c,
                Number_Of_Test_Searches_Running_Total__c,
                Surveys_Approved__c,
                Surveys_Rejected__c,
                Surveys_Pending__c,
                Surveys_Not_Reviewed__c,
                Duplicate_Surveys__c,
                Farmers_Registered__c,
                Name
            FROM
                CKW_Performance_Review__c
            WHERE
                Start_Date__c =:this.currentStartDate
                OR Start_Date__c =:this.previousStartDate];

        for(CKW_Performance_Review__c review : performanceReviews) {
            CkwPerformanceData ckwData;
            
            if(review.Start_Date__c == this.currentStartDate) {
                ckwData = this.currentCkwStatistics.get(review.CKW_c__r.Name);

            } else if(review.Start_Date__c == this.previousStartDate){
                ckwData = this.previousCkwStatistics.get(review.CKW_c__r.Name);
            } else {
                System.debug('No start date on CKW Performance Review ' + review.Name);
            }
            
            if(ckwData != null) {
                updateReviewObject(review, ckwData);
                updatedPerformanceReviews.add(review);
            }
        }
        
        Database.SaveResult[] updateResults = Database.update(updatedPerformanceReviews);
        for(Database.SaveResult result : updateResults) {
            if(!result.isSuccess()) {
                ErrorLog.writeLater('PerformanceDataCollector', 'updateReviewObjects', 
                    'Failed to update review object: ' + result.getId(), 2);
            }
        }
    }

    private void updateReviewObject(CKW_Performance_Review__c review, CkwPerformanceData ckwData) {
        System.debug('Updating performance review: ' + review.Name + '\n'); 

        review.Number_Of_Searches__c = ckwData.totalSearchesOldSystem;
        review.Surveys_Approved__c = ckwData.approvedSurveys;
        review.Surveys_Rejected__c = ckwData.rejectedSurveys;
        review.Surveys_Pending__c = ckwData.pendingSurveys;
        review.Surveys_Not_Reviewed__c = ckwData.notReviewedSurveys;
        review.Duplicate_Surveys__c = ckwData.duplicateSurveys;

        // As the search stats are now got daily this is an addition not a replacement
        if (review.Number_Of_Searches_Running_Total__c != null) {
           review.Number_Of_Searches_Running_Total__c += ckwData.totalSearches;
        }
        else {
            review.Number_Of_Searches_Running_Total__c = ckwData.totalSearches;
        }
        if (review.Number_Of_Invalid_Searches_Running_Total__c != null) {
            review.Number_Of_Invalid_Searches_Running_Total__c += ckwData.totalInvalidSearches;
        }
        else {
            review.Number_Of_Invalid_Searches_Running_Total__c = ckwData.totalInvalidSearches;
        }
        if (review.Number_Of_Test_Searches_Running_Total__c != null) {
            review.Number_Of_Test_Searches_Running_Total__c += ckwData.totalTestSearches;
        }
        else {
            review.Number_Of_Test_Searches_Running_Total__c = ckwData.totalTestSearches;
        }
        review.Farmers_Registered__c = ckwData.farmersRegistered;
    }

    /**
     *  Method to update search count for a particular date range. Needed because if SF fails to run the
     *  Job the search logs will not be caught up. Don't need to run anything else as that is caluculated
     *  fresh each day.
     *
     *  @param startDate - The Date that the search logs start from.
     *  @param endDate   - The Date that the search logs end on.
     */
    public Boolean addMissedSearchLogs(Date startDate, Date endDate) {

        Boolean success = true;
        DateTime startDateTime = DateTime.newInstance(startDate, Time.newInstance(0,0,0,0));
        DateTime endDateTime = DateTime.newInstance(endDate, Time.newInstance(23,59,59,0));

        // Get the incentive structure and the monthly targets
        Monthly_Target__c currentTarget = initializeMonthlyTarget(startDate.toStartOfMonth());
        Incentive_Structure__c currentIncetive = initializeIncentiveStructure(startDate.toStartOfMonth());
        Monthly_Target__c previousTarget = initializeMonthlyTarget(startDate.toStartOfMonth().addMonths(-1));
        Incentive_Structure__c previousIncetive = initializeIncentiveStructure(startDate.toStartOfMonth().addMonths(-1));

        // Get this months performance records and put in to map
        Map<Id, CKW_Performance_Review__c> currentPerformanceReviewsMap = new Map<Id, CKW_Performance_Review__c>();
        CKW_Performance_Review__c[] currentPerformanceReviews =
            [SELECT
                CKW_c__c,
                CKW_c__r.Name,
                CKW_c__r.Person__c,
                Start_Date__c,
                Number_Of_Searches__c,
                Number_Of_Searches_Running_Total__c,
                Number_Of_Invalid_Searches_Running_Total__c,
                Number_Of_Test_Searches_Running_Total__c,
                Surveys_Approved__c,
                Surveys_Rejected__c,
                Surveys_Pending__c,
                Surveys_Not_Reviewed__c,
                Duplicate_Surveys__c,
                Farmers_Registered__c,
                Name
            FROM
                CKW_Performance_Review__c
            WHERE
                Start_Date__c = THIS_MONTH];
        for (CKW_Performance_Review__c review : currentPerformanceReviews) {
            currentPerformanceReviewsMap.put(review.CKW_c__r.Person__c, review);
        }

        // Get last months performance records and put in to map
        Map<Id, CKW_Performance_Review__c> previousPerformanceReviewsMap = new Map<Id, CKW_Performance_Review__c>();
        CKW_Performance_Review__c[] previousPerformanceReviews =
            [SELECT
                CKW_c__c,
                CKW_c__r.Name,
                CKW_c__r.Person__c,
                Start_Date__c,
                Number_Of_Searches__c,
                Number_Of_Searches_Running_Total__c,
                Number_Of_Invalid_Searches_Running_Total__c,
                Number_Of_Test_Searches_Running_Total__c,
                Surveys_Approved__c,
                Surveys_Rejected__c,
                Surveys_Pending__c,
                Surveys_Not_Reviewed__c,
                Duplicate_Surveys__c,
                Farmers_Registered__c,
                Name
            FROM
                CKW_Performance_Review__c
            WHERE
                Start_Date__c = LAST_MONTH];
        for (CKW_Performance_Review__c review : previousPerformanceReviews) {
            previousPerformanceReviewsMap.put(review.CKW_c__r.Person__c, review);
        }

        // Get the available CKWs
        Set<Id> ckwPersonIds = new Set<Id>();
        Map<Id, CKW__c> ckwPersonIdMap = new Map<Id, CKW__c>();
        for (CKW__c[] ckws: [
            SELECT
                Id,
                Person__c,
                Person__r.Id
            FROM
                CKW__c]
        ){
            for(CKW__c ckw: ckws) {
                ckwPersonIds.add(ckw.Person__r.Id); 
                ckwPersonIdMap.put(ckw.Person__r.Id, ckw);
            }
        }

        // Get the search logs for the period we missed
        // Loop through the logs and test the month and test the type
        // If the CKW does not have a record then create one and add to the Map
        for (Search_Log__c[] searchLogs : [
            SELECT
                Interviewer__c,
                Handset_Submit_Time__c,
                Interviewee__c,
                Interviewee__r.First_Name__c
            FROM
                Search_Log__c
            WHERE
                Server_Entry_Time__c >= :startDateTime
                AND Server_Entry_Time__c <= :endDateTime
                AND Interviewer__c != null
                AND Interviewer__c 
                IN :ckwPersonIds
        ]){

            for (Search_Log__c searchLog : searchLogs) {
                if (thisMonth(searchLog.Handset_Submit_Time__c.date())) {
                    CKW_Performance_Review__c review = currentPerformanceReviewsMap.get(searchLog.Interviewer__c);

                    if (review == null) {
                        review = createCkwPerformanceReview(ckwPersonIdMap.get(searchLog.Interviewer__c), startDate.toStartOfMonth(), currentTarget, currentIncetive);
                    }
                    if (searchLog.Interviewee__c != null && !searchLog.Interviewee__r.First_Name__c.equalsIgnoreCase('TEST')) {
                        review.Number_Of_Searches_Running_Total__c++;
                    }
                    else if (searchLog.Interviewee__r.First_Name__c != null && searchLog.Interviewee__r.First_Name__c.equalsIgnoreCase('TEST')) {
                        review.Number_Of_Test_Searches_Running_Total__c++;
                    }
                    else {
                        review.Number_Of_Invalid_Searches_Running_Total__c++;
                    }
                    currentPerformanceReviewsMap.put(searchLog.Interviewer__c, review);
                }
                else {
                    CKW_Performance_Review__c review = previousPerformanceReviewsMap.get(searchLog.Interviewer__c);
                    if (review == null) {
                        review = createCkwPerformanceReview(ckwPersonIdMap.get(searchLog.Interviewer__c), startDate.toStartOfMonth().addMonths(-1), previousTarget, previousIncetive);
                    }
                    if (searchLog.Interviewee__c != null && !searchLog.Interviewee__r.First_Name__c.equalsIgnoreCase('TEST')) {
                        review.Number_Of_Searches_Running_Total__c++;
                    }
                    else if (searchLog.Interviewee__r.First_Name__c != null && searchLog.Interviewee__r.First_Name__c.equalsIgnoreCase('TEST')) {
                        review.Number_Of_Test_Searches_Running_Total__c++;
                    }
                    else {
                        review.Number_Of_Invalid_Searches_Running_Total__c++;
                    }
                    previousPerformanceReviewsMap.put(searchLog.Interviewer__c, review);
                }
            }
        }


        // update the Db with the values from both maps
        database.upsert(currentPerformanceReviewsMap.values());
        database.upsert(previousPerformanceReviewsMap.values());
        return success;
    }

    /*
     * Need this class to keep track of when the searches in the Search_Log__c are for. Since the CKW may synchronize at any time.
     */
    class CkwDailySearches {
        public Integer currentMonthSearches;
        public Integer currentMonthInvalidSearches;
        public Integer currentMonthTestSearches;
        public Integer previousMonthSearches;
        public Integer previousMonthInvalidSearches;
        public Integer previousMonthTestSearches;

        public CkwDailySearches() {
            this.currentMonthSearches = 0;
            this.currentMonthInvalidSearches = 0;
            this.currentMonthTestSearches = 0;
            this.previousMonthSearches = 0;
            this.previousMonthInvalidSearches = 0;
            this.previousMonthTestSearches = 0;
        }
    }

    /**
     *  Class to store the surveys that are stored in SF.
     */
    class CkwSalesforceSurveys {
        public Integer approvedSurveys;
        public Integer rejectedSurveys;
        public Integer pendingSurveys;
        public Integer notReviewedSurveys;
        public Integer duplicateSurveys;

        public CkwSalesforceSurveys() {
            this.approvedSurveys = 0;
            this.rejectedSurveys = 0;
            this.pendingSurveys = 0;
            this.notReviewedSurveys = 0;
            this.duplicateSurveys = 0;
        }
    }

    public class CkwPerformanceData {
        public Integer totalSearches;
        public Integer totalTestSearches;
        public Integer totalInvalidSearches;
        public Integer totalSearchesOldSystem;
        public Integer approvedSurveys;
        public Integer rejectedSurveys;
        public Integer pendingSurveys;
        public Integer notReviewedSurveys;
        public Integer duplicateSurveys;
        public Integer farmersRegistered;

        public CkwPerformanceData() {
            this.totalSearches = 0;
            this.totalTestSearches = 0;
            this.totalInvalidSearches = 0;
            this.totalSearchesOldSystem = 0;
            this.approvedSurveys = 0;
            this.rejectedSurveys = 0;
            this.pendingSurveys = 0;
            this.notReviewedSurveys = 0;
            this.duplicateSurveys = 0;
            this.farmersRegistered = 0;
        }
    }
}