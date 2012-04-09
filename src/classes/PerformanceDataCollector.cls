public with sharing class PerformanceDataCollector {

    private date currentStartDate;
    private date currentEndDate;
    private date previousStartDate;
    private date previousEndDate;

    private Monthly_Target__c currentMonthlyTarget;
    private Monthly_Target__c previousMonthlyTarget;
    private Incentive_Structure__c currentIncentiveStructure;
    private Incentive_Structure__c previousIncentiveStructure;

    private Map<string,ckwPerformanceData> currentCkwStatistics;
    private Map<string,ckwPerformanceData> previousCkwStatistics;
    private Map<String,Integer> surveyPoints; 

    private String surveyDatabase;
    private String searchDatabase;
    private String serverUrl;

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

    private CKW__c[] getCkwsWithNoReviewObject() {

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

    private void validateCkwPerformanceReviewObjects() {

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

    private List<CKW_Performance_Review__c> createCkwPerformanceReviews(CKW__c ckw, Boolean createPreviousReviewObject) {       

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

    private void getFarmersRegistered(String monthString, Map<string,ckwPerformanceData> ckwStatistics) {

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
                'CreatedDate = ' + monthString + ' '                      +
                'AND Registered_By__c IN (SELECT Person__c FROM CKW__c) ' +
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

    private void getSalesforceSurveys(String monthString, Map<string,ckwPerformanceData> ckwStatistics) {

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

    private void getDailySearchStatistics() {

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

    private void parseSurveyResults(String surveyResultXml, Map<string,ckwPerformanceData> ckwStatistics) {
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

    private String fakeSurveyQuery() {
        String result = '<results>' +
            '<row><ckw>CKW-10-000007</ckw><survey_id>2010070025</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '<row><ckw>CKW-10-000009</ckw><survey_id>2010070025</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '<row><ckw>CKW-10-000115</ckw><survey_id>2010070025</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '<row><ckw>CKW-10-000122</ckw><survey_id>2010070025</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '<row><ckw>CKW-10-000123</ckw><survey_id>2010070025</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '<row><ckw>CKW-10-000250</ckw><survey_id>2010070025</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '<row><ckw>CKW-10-000250</ckw><survey_id>2010070026</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '<row><ckw>CKW-10-000251</ckw><survey_id>2010070025</survey_id><approved>1</approved><rejected>2</rejected>' +
                '<pending>1</pending><not_reviewed>1</not_reviewed><duplicates>1</duplicates></row>' +
            '</results>';
        
        return result;      
    }
        
    private void updateReviewObjects() {
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

    class CkwPerformanceData {
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

    static testMethod void testInitializeServerConstants() {
        PerformanceDataCollector dataCollector = new PerformanceDataCollector();
        System.assert(dataCollector.serverUrl != null);
        System.assert(dataCollector.searchDatabase != null);
        System.assert(dataCollector.surveyDatabase != null);
    }

    static testMethod void testValidateReviewObjects() {
        PerformanceDataCollector dataCollector = new PerformanceDataCollector();

        // Create a few CKWs with no performance reviews
        Integer numberOfCkws = 3;
        for(Integer i = 0; i < numberOfCkws; i++) {
            Person__c testPerson = new Person__c();
            testPerson.First_Name__c = 'FirstName' + i;
            testPerson.Last_Name__c = 'LastName' + i;
            database.insert(testPerson);

            CKW__c testCkw = new CKW__c();
            testCkw.Person__c = testPerson.id;

            database.insert(testCkw);
        }

        // Check that there are at least as many CKWs who don't have review objects as the # we just created        
        CKW__c[] ckwsWithNoReview = dataCollector.getCkwsWithNoReviewObject();
        System.assert(ckwsWithNoReview.size() >= numberOfCkws);

        dataCollector.validateCkwPerformanceReviewObjects();

        // Validate that there are no longer any CKWs without review objects
        CKW__c[] updatedCkwsWithNoReview = dataCollector.getCkwsWithNoReviewObject();
        System.assertEquals(updatedCkwsWithNoReview.size(), 0);
    }

    static testMethod void testSurveyParsing() {
        PerformanceDataCollector dataCollector = new PerformanceDataCollector();
        dataCollector.parseSurveyResults(dataCollector.fakeSurveyQuery(), dataCollector.currentCkwStatistics);
        Set<String> keys = dataCollector.currentCkwStatistics.keySet();
        
        System.debug('Size of CKW survey data set: ' + keys.size() + '\n');
        System.debug('Survey totals: \n');
        for(String key : keys) {
            CkwPerformanceData ckwData = dataCollector.currentCkwStatistics.get(key);
            System.debug(key + ': ' + 
                ckwData.approvedSurveys + ' ' +
                ckwData.rejectedSurveys + ' ' +
                ckwData.notReviewedSurveys + ' ' +
                ckwData.pendingSurveys + ' ' +
                ckwData.duplicateSurveys + '\n');
        }
    }

    static testMethod void testUpdateReviewObjects() {
        PerformanceDataCollector dataCollector = new PerformanceDataCollector();

        // Create a test CKW and perf review
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        database.insert(testPerson);

        CKW__c testCkw = new CKW__c();
        testCkw.Person__c = testPerson.id;

        database.insert(testCkw);

        testCkw = [
            SELECT
                name
            FROM
                CKW__c 
            WHERE
                id =:testCkw.id];
        CKW_Performance_Review__c[] testReviews = dataCollector.createCkwPerformanceReviews(testCkw, true);
        database.insert(testReviews);

        // Create perf review data for the test CKW and insert into the Map
        CkwPerformanceData testCkwData = new ckwPerformanceData();
        testCkwData.totalSearches = 30;
        testCkwData.totalInvalidSearches = 30;
        testCkwData.totalSearchesOldSystem = 30;
        testCkwData.approvedSurveys = 5;
        testCkwData.rejectedSurveys = 1;
        testCkwData.pendingSurveys = 3;
        testCkwData.notReviewedSurveys = 12;
        testCkwData.duplicateSurveys = 2;
        dataCollector.currentCkwStatistics.put(testCkw.name, testCkwData);

        // Create perf review data for a non-existent CKW and insert into the Map.
        // We are testing error fallback behavior with this fake CKW.
        CkwPerformanceData nonExistentCkwData = new ckwPerformanceData();
        dataCollector.currentCkwStatistics.put('CKW-10-999999', nonExistentCkwData);

        // Call updateReviewObjects to update the perf review       
        dataCollector.updateReviewObjects();
        
        // Validate that the expected data was written and pay was calculated
        Ckw_Performance_Review__c updatedReview = [
            SELECT
                Number_Of_Searches__c,
                Number_Of_Searches_Running_Total__c,
                Number_Of_Invalid_Searches_Running_Total__c,
                Number_Of_Test_Searches_Running_Total__c,
                Surveys_Approved__c,
                Surveys_Rejected__c,
                Surveys_Pending__c,
                Surveys_Not_Reviewed__c,
                Duplicate_Surveys__c,
                Performance_Pay__c
            FROM
                CKW_Performance_Review__c
            WHERE 
                id=:testReviews[0].id
            LIMIT 1];

        System.assertEquals(updatedReview.Number_Of_Searches_Running_Total__c, testCkwData.totalSearches);
        System.assertEquals(updatedReview.Number_Of_Test_Searches_Running_Total__c, testCkwData.totalTestSearches);
        System.assertEquals(updatedReview.Number_Of_Invalid_Searches_Running_Total__c, testCkwData.totalInvalidSearches);
        System.assertEquals(updatedReview.Number_Of_Searches__c, testCkwData.totalSearchesOldSystem);
        System.assertEquals(updatedReview.Surveys_Approved__c, testCkwData.approvedSurveys); 
        System.assertEquals(updatedReview.Surveys_Rejected__c, testCkwData.rejectedSurveys);
        System.assertEquals(updatedReview.Surveys_Pending__c, testCkwData.pendingSurveys);
        System.assertEquals(updatedReview.Surveys_Not_Reviewed__c, testCkwData.notReviewedSurveys);
        System.assertEquals(updatedReview.Duplicate_Surveys__c, testCkwData.duplicateSurveys);
        System.debug('Performance Pay: ' + updatedReview.Performance_Pay__c);
    }

    static testMethod void testSearchDataSF() {

        PerformanceDataCollector dataCollector = new PerformanceDataCollector();

        // Create a handset
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = 'TestIMEI';
        testHandset.Serial_Number__c = '325246263253462';
        testHandset.Purchase_Value_USD__c = 0;
        database.insert(testHandset);

        Phone__c testHandset1 = new Phone__c();
        testHandset1.IMEI__c = 'TestIMEI1';
        testHandset1.Serial_Number__c = '325246263253461';
        testHandset1.Purchase_Value_USD__c = 0;
        database.insert(testHandset1);

        // Create a test CKW
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        testPerson.Handset__c = testHandset.Id;
        database.insert(testPerson);

        CKW__c testCkw = new CKW__c();
        testCkw.Person__c = testPerson.id;
        database.insert(testCkw);
        CKW__c testCkw2 = [SELECT name from CKW__c where id =:testCkw.id];  

        // Create a test farmer
        Person__c testPerson1 = new Person__c();
        testPerson1.First_Name__c = 'FirstName';
        testPerson1.Last_Name__c = 'LastName';
        testPerson1.Handset__c = testHandset1.Id;
        database.insert(testPerson1);

        Farmer__c testFarmer = new Farmer__c();
        testFarmer.Person__c = testPerson1.Id;
        database.insert(testFarmer);

        // Create a performance log for the CKW
        CKW_Performance_Review__c testReview = new CKW_Performance_Review__c();
        testReview.CKW_c__c = testCkw.Id;
        testReview.Number_Of_Searches__c = 5;
        testReview.Start_Date__c = date.newInstance(2010, 09, 01);
        database.insert(testReview);

        // Crate a Search Log for this ckw.
        Search_Log__c entry = new Search_Log__c();

        date entryTime = date.today().addDays(-1);
        entry.Server_Entry_Time__c = entryTime;
        entry.Handset_Submit_Time__c = entryTime;
        entry.Interviewer__c = testCkw.Person__c;
        entry.Interviewee__c = testFarmer.Person__c;
        entry.Latitude__c = 0.00;
        entry.Longitude__c = 0.00;
        entry.Altitude__c = 0.00;
        entry.Accuracy__c = 0.00;
        entry.Category__c = 'Category';
        entry.Query__c = 'Query';
        database.insert(entry);

        // Create the test farmer to ensure that he is not being found
        Person__c testPerson3 = new Person__c();
        testPerson3.First_Name__c = 'TeSt';
        testPerson3.Last_Name__c = 'TeSt';
        database.insert(testPerson3);

        Farmer__c testFarmer2 = new Farmer__c();
        testFarmer2.Person__c = testPerson3.Id;
        database.insert(testFarmer2);

        // Crate a Search Log for this test farmer.
        Search_Log__c entry2 = new Search_Log__c();
        entry2.Server_Entry_Time__c = entryTime;
        entry2.Handset_Submit_Time__c = entryTime;
        entry2.Interviewer__c = testCkw.Person__c;
        entry2.Interviewee__c = testFarmer2.Person__c;
        entry2.Latitude__c = 0.00;
        entry2.Longitude__c = 0.00;
        entry2.Altitude__c = 0.00;
        entry2.Accuracy__c = 0.00;
        entry2.Category__c = 'Category';
        entry2.Query__c = 'Query';
        database.insert(entry2);

        // Create the test farmer to ensure that he is not being found
        dataCollector.getDailySearchStatistics();
        CKWPerformanceData test = dataCollector.currentCkwStatistics.get(testCkw2.Name);

        // Make sure that only the new log has been counted and the test farmer ignored
        Date todayDate = date.today();
        Date startOfMonth = date.today().toStartOfMonth();
        
        //TODO: remember to change this back to 1s
        if (todayDate.isSameDay(startOfMonth)) {
            System.assertEquals(1, test.totalSearches);
            System.assertEquals(1, test.totalTestSearches);
        }
        else {
            System.assertEquals(1, test.totalSearches);
            System.assertEquals(1, test.totalTestSearches);
        }
    }

    static testmethod void testSalesforceSurveys() {

        PerformanceDataCollector dataCollector = new PerformanceDataCollector();

        // Create the organisation
        Account org = Utils.createTestOrganisation('Test');
        database.insert(org);

        // Create a survey to attach the attachment to
        Survey__c survey = Utils.createTestSurvey(org, 'survey');
        database.insert(survey);

        CKW__c ckw = Utils.createTestCkw(null, 'TEST1', true, null, null);
        ckw.Status__c = 'Active';
        database.insert(ckw);

        // Create a farmer
        Farmer__c farmer1 = Utils.createTestFarmer('OD99999', null, 'TestFarmer1', true, null, null);
        farmer1.Registered_By__c = ckw.Person__c;
        database.insert(farmer1);

        // Create a submission
        Date startDate = date.today().addDays(-1);
        Time startTime = time.newInstance(12, 30, 30, 0);
        DateTime submissionDateTime = datetime.newInstance(startDate.addDays(1), startTime);
        Submission_Meta_Data__c sub = Utils.createTestSubmission(ckw.Person__c, farmer1.Person__c, survey.Id, submissionDateTime, 'Sub1');
        database.insert(sub);

        // Get the ckw name. Need to do this via a query or it doesn't work
        CKW__c ckwName = [
            SELECT
                Name
            FROM
                CKW__c
            WHERE
                Id = :ckw.Id];

        Map<String, CkwPerformanceData> currentCkwStatistics = new Map<String, CkwPerformanceData>();
        CkwPerformanceData ckwPerformanceData = new CkwPerformanceData();
        currentCkwStatistics.put(ckwName.Name, ckwPerformanceData);
        dataCollector.getSalesforceSurveys('THIS_MONTH', currentCkwStatistics);
        System.assertEquals(currentCkwStatistics.get(ckwName.Name).notReviewedSurveys, 1);
    }

    static testmethod void testFarmersRegistered() {

        PerformanceDataCollector dataCollector = new PerformanceDataCollector();

        CKW__c ckw = Utils.createTestCkw(null, 'TEST1', true, null, null);
        ckw.Status__c = 'Active';
        database.insert(ckw);

        // Create a farmer
        Farmer__c farmer1 = Utils.createTestFarmer('OD99999', null, 'TestFarmer2', true, null, null);
        farmer1.Registered_By__c = ckw.Person__c;
        database.insert(farmer1);

        // Get the ckw name. Need to do this via a query or it doesn't work
        CKW__c ckwName = [
            SELECT
                Name
            FROM
                CKW__c
            WHERE
                Id = :ckw.Id];

        Map<String, CkwPerformanceData> currentCkwStatistics = new Map<String, CkwPerformanceData>();
        CkwPerformanceData ckwPerformanceData = new CkwPerformanceData();
        currentCkwStatistics.put(ckwName.Name, ckwPerformanceData);
        dataCollector.getFarmersRegistered('THIS_MONTH', currentCkwStatistics);
        System.assertEquals(currentCkwStatistics.get(ckwName.Name).farmersRegistered, 1);
    }

    static testMethod void testUpdateSpecificSearchesDate() {

        // Generate dates
        Date thisStartMonthDate = Date.today().toStartOfMonth();
        Date lastStartMonthDate = Date.today().toStartOfMonth().addMonths(-1);

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

        // Create a performance log for the CKW for the last month
        CKW_Performance_Review__c testReview = new CKW_Performance_Review__c();
        testReview.CKW_c__c = testCkw.Id;
        testReview.Number_Of_Invalid_Searches_Running_Total__c = 0.0;
        testReview.Number_Of_Searches_Running_Total__c = 0.0;
        testReview.Number_Of_Test_Searches_Running_Total__c = 0.0;
        testReview.Start_Date__c = lastStartMonthDate;
        database.insert(testReview);

        // Generate the various search logs that are needed to test
        List<Search_Log__c> logs = new List<Search_Log__c>();
        Search_Log__c entryThisMonthValid = new Search_Log__c();
        entryThisMonthValid.Server_Entry_Time__c = thisStartMonthDate.addDays(5);
        entryThisMonthValid.Handset_Submit_Time__c = thisStartMonthDate.addDays(4);
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
        entryThisMonthTest.Server_Entry_Time__c = thisStartMonthDate.addDays(5);
        entryThisMonthTest.Handset_Submit_Time__c = thisStartMonthDate.addDays(4);
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
        entryThisMonthInvalid.Server_Entry_Time__c = thisStartMonthDate.addDays(5);
        entryThisMonthInvalid.Handset_Submit_Time__c = thisStartMonthDate.addDays(4);
        entryThisMonthInvalid.Interviewer__c = testCkw.Person__c;
        entryThisMonthInvalid.Interviewee__c = null;
        entryThisMonthInvalid.Latitude__c = 0.00;
        entryThisMonthInvalid.Longitude__c = 0.00;
        entryThisMonthInvalid.Altitude__c = 0.00;
        entryThisMonthInvalid.Accuracy__c = 0.00;
        entryThisMonthInvalid.Category__c = 'Category';
        entryThisMonthInvalid.Query__c = 'Query';
        logs.add(entryThisMonthInvalid);

        // Generate the various search logs that are needed to test for the last month
        Search_Log__c entryPreviousMonthValid = new Search_Log__c();
        entryPreviousMonthValid.Server_Entry_Time__c = thisStartMonthDate.addDays(5);
        entryPreviousMonthValid.Handset_Submit_Time__c = lastStartMonthDate.addDays(4);
        entryPreviousMonthValid.Interviewer__c = testCkw.Person__c;
        entryPreviousMonthValid.Interviewee__c = testFarmer.Person__c;
        entryPreviousMonthValid.Latitude__c = 0.00;
        entryPreviousMonthValid.Longitude__c = 0.00;
        entryPreviousMonthValid.Altitude__c = 0.00;
        entryThisMonthValid.Accuracy__c = 0.00;
        entryPreviousMonthValid.Category__c = 'Category';
        entryPreviousMonthValid.Query__c = 'Query';
        logs.add(entryPreviousMonthValid);

        // Crate a Search Log for the test farmer for last month
        Search_Log__c entryPreviousMonthTest = new Search_Log__c();
        entryPreviousMonthTest.Server_Entry_Time__c = thisStartMonthDate.addDays(5);
        entryPreviousMonthTest.Handset_Submit_Time__c = lastStartMonthDate.addDays(4);
        entryPreviousMonthTest.Interviewer__c = testCkw.Person__c;
        entryPreviousMonthTest.Interviewee__c = testFarmer2.Person__c;
        entryPreviousMonthTest.Latitude__c = 0.00;
        entryPreviousMonthTest.Longitude__c = 0.00;
        entryPreviousMonthTest.Altitude__c = 0.00;
        entryPreviousMonthTest.Accuracy__c = 0.00;
        entryPreviousMonthTest.Category__c = 'Category';
        entryPreviousMonthTest.Query__c = 'Query';
        logs.add(entryPreviousMonthTest);

        // Log for this month for an invalid search
        Search_Log__c entryPreviousMonthInvalid = new Search_Log__c();
        entryPreviousMonthInvalid.Server_Entry_Time__c = thisStartMonthDate.addDays(5);
        entryPreviousMonthInvalid.Handset_Submit_Time__c = lastStartMonthDate.addDays(4);
        entryPreviousMonthInvalid.Interviewer__c = testCkw.Person__c;
        entryPreviousMonthInvalid.Interviewee__c = null;
        entryPreviousMonthInvalid.Latitude__c = 0.00;
        entryPreviousMonthInvalid.Longitude__c = 0.00;
        entryPreviousMonthInvalid.Altitude__c = 0.00;
        entryPreviousMonthInvalid.Accuracy__c = 0.00;
        entryPreviousMonthInvalid.Category__c = 'Category';
        entryPreviousMonthInvalid.Query__c = 'Query';
        logs.add(entryPreviousMonthInvalid);

        // Insert the logs
        database.insert(logs);

        // Create the performance data collector
        PerformanceDataCollector dataCollector = new PerformanceDataCollector();
        dataCollector.addMissedSearchLogs(thisStartMonthDate.addDays(3), thisStartMonthDate.addDays(5));
        CKW_Performance_Review__c[] reviewsInserted = [
            SELECT
                Number_Of_Invalid_Searches_Running_Total__c,
                Number_Of_Searches_Running_Total__c,
                Number_Of_Test_Searches_Running_Total__c
            FROM
                CKW_Performance_Review__c
            WHERE
                CKW_c__c = :testCkw.Id
            ];
        System.assertEquals(reviewsInserted.size(), 2);
        for (CKW_Performance_Review__c perfReview : reviewsInserted) {
            System.assertEquals(perfReview.Number_Of_Invalid_Searches_Running_Total__c, 1);
            System.assertEquals(perfReview.Number_Of_Searches_Running_Total__c, 1);
            System.assertEquals(perfReview.Number_Of_Test_Searches_Running_Total__c, 1);
        }
    }
}