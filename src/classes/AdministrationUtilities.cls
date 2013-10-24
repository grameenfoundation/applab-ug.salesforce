public with sharing class AdministrationUtilities {

     public static void updateSearchLogs(Date startDate, Date endDate, Boolean increase) {


        // Get the count of the search log. Annoyingly cant group by Interviewer__r.Name.
        // This is why we need to go throug the long process below
        Map<Id, CkwDailySearches> logCountId   = new Map<Id, CkwDailySearches>();

        // The sub-query below alows us to only include CKWs in the results. Also take in to account
        // searches from the test farmer.
        if (startDate == null) {
            startDate = date.newInstance(2011, 03, 24);
        }
        if (endDate == null) {
            endDate = date.newInstance(2011, 03, 24);
        }
        datetime startTimestamp = MetricHelpers.convertToStartDate(startDate);
        datetime endTimestamp = MetricHelpers.convertToEndDate(endDate);
        Search_Log__c[] searchLogs = [SELECT
                Interviewer__c,
                Handset_Submit_Time__c
            FROM
                Search_Log__c
            WHERE 
                Server_Entry_Time__c >= :startTimestamp
                AND Server_Entry_Time__c <= :endTimestamp
                AND Interviewer__c != null
                AND Interviewer__c IN (SELECT Person__c FROM CKW__c)];
 
        // Leave this section out until TCH-257 is fixed
        /*
        AND Interviewee__c != null
        AND (NOT Interviewee__r.First_Name__c LIKE 'TEST')];
        */

        // Build up the query to get the Ckw.Name    	
        // Get the list of CKW__c.Person__r.Id's that are returned and use them to search for the CKW__c.Name
        List<String> personIds = new List<String>();	

        for (Search_Log__c searchLog : searchLogs) {
            CkwDailySearches dailySearches;
            if(logCountId.containsKey(searchLog.Interviewer__c)) {
                dailySearches = logCountId.get(searchLog.Interviewer__c);
            } else {
                dailySearches = new CkwDailySearches();
            }

            if(thisMonth(searchLog.Handset_Submit_Time__c.date())) {
                dailySearches.currentMonthSearches++;
            }
            else {
                dailySearches.previousMonthSearches++;
            }

            logCountId.put(searchLog.Interviewer__c, dailySearches);

            personIds.add(searchLog.Interviewer__c);
        }

        // Get the performance records for this month.
        String baseString =
            'SELECT '                                                       +
                'Number_Of_Searches_Running_Total__c, '                     +
                'CKW_c__r.Person__r.Id '                                      +
            'FROM '                                                         +
                'CKW_Performance_Review__c '                                +
            'WHERE '                                                        +
                'CKW_c__r.Person__r.Id IN ('                                  +
                MetricHelpers.generateCommaSeperatedString(personIds, true) +
                ')'                                                         +
                'AND Start_Date__c = ';

        CKW_Performance_Review__c[] thisMonthsReviews = database.query(baseString + 'THIS_MONTH');
        CKW_Performance_Review__c[] lastMonthsReviews = database.query(baseString + 'LAST_MONTH');

        // Generate the maps for the reviews
        Map<String, CKW_Performance_Review__c> thisMonthsReviewsMap = new Map<String, CKW_Performance_Review__c>();
        for (CKW_Performance_Review__c review : thisMonthsReviews) {
            thisMonthsReviewsMap.put(review.CKW_c__r.Person__r.Id, review);
        }
        Map<String, CKW_Performance_Review__c> lastMonthsReviewsMap = new Map<String, CKW_Performance_Review__c>();
        for (CKW_Performance_Review__c review : lastMonthsReviews) {
            lastMonthsReviewsMap.put(review.CKW_c__r.Person__r.Id, review);
        }

        // Loop through the search log map and add to the performanc reviews
        for (String id : logCountId.keySet()) {
            CkwDailySearches searches = logCountId.get(id);
            if (thisMonthsReviewsMap.containsKey(id)) {
                CKW_Performance_Review__c thisMonth = thisMonthsReviewsMap.get(id);
                if (thisMonth != null) {
                    if (increase) {
                        thisMonth.Number_Of_Searches_Running_Total__c = thisMonth.Number_Of_Searches_Running_Total__c + searches.currentMonthSearches;
                    } else {
                        thisMonth.Number_Of_Searches_Running_Total__c = thisMonth.Number_Of_Searches_Running_Total__c - searches.currentMonthSearches;
                    }
                    thisMonthsReviewsMap.put(id, thisMonth);
                }
            }
            if (lastMonthsReviewsMap.containsKey(id)) {
                CKW_Performance_Review__c lastMonth = lastMonthsReviewsMap.get(id);
                if (lastMonth != null) {
                    if (increase) {
                        lastMonth.Number_Of_Searches_Running_Total__c = lastMonth.Number_Of_Searches_Running_Total__c + searches.previousMonthSearches;
                    } else {
                        lastMonth.Number_Of_Searches_Running_Total__c = lastMonth.Number_Of_Searches_Running_Total__c - searches.previousMonthSearches;
                    }
                    lastMonthsReviewsMap.put(id, lastMonth);
                }
            }
        }

        // Loop through the reviews and create a list
        List<CKW_Performance_Review__c> thisMonthsReviewsList = new List<CKW_Performance_Review__c>();
        for (String id : thisMonthsReviewsMap.keySet()) {
            thisMonthsReviewsList.add(thisMonthsReviewsMap.get(id));
        }
        List<CKW_Performance_Review__c> lastMonthsReviewsList = new List<CKW_Performance_Review__c>();
        for (String id : lastMonthsReviewsMap.keySet()) {
            lastMonthsReviewsList.add(lastMonthsReviewsMap.get(id));
        }

        // Update the reviews
        if (thisMonthsReviewsList.size() > 0) {
            database.update(thisMonthsReviewsList);
        }
        if (lastMonthsReviewsList.size() > 0) {
            database.update(lastMonthsReviewsList);
        }
    }

    private static boolean thisMonth(Date testDate) {
        date now = date.today();
        if (testDate.month() == now.month()) {
            return true;
        } 
        return false;
    }

    /*
     * Need this class to keep track of when the searches in the Search_Log__c are for. Since the CKW may synchronize at any time.
     */
    class CkwDailySearches {

        public Integer currentMonthSearches;
        public Integer previousMonthSearches;

        public CkwDailySearches() {
            this.currentMonthSearches = 0;
            this.previousMonthSearches = 0;
        }
    }

    static testMethod void testUpdateSearch() {

        // Set up the dates that are required for this test
        Date searchDate = date.today();
        Date reviewStartDate = searchDate.toStartOfMonth();

        // Create a test CKW and perf review
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        database.insert(testPerson);

        CKW__c testCkw = new CKW__c();
        testCkw.Person__c = testPerson.id;

        database.insert(testCkw);

        // Create a performance review for this CKW
        Monthly_Target__c target = new Monthly_Target__c();
        target.Search_Target__c = 5.0;
        target.Survey_Target__c = 5.0;
        target.Start_Date__c = Date.today();
        database.insert(target);

        Incentive_Structure__c structure = new Incentive_Structure__c();
        structure.Level_A_Compensation__c = 15000.00;
        structure.Level_A_Threshold__c = 100;
        structure.Level_B_Compensation__c = 10000.00;
        structure.Level_B_Threshold__c = 75;
        structure.Level_C_Compensation__c = 5000.00;
        structure.Level_C_Threshold__c = 50;
        structure.Level_D_Compensation__c = 1000.00;
        structure.Airtime_Compensation__c = 2000.00;
        structure.Long_Term_Airtime_Bonus__c = 2000.00;
        structure.Long_Term_Cash_Bonus__c = 2000.00;
        structure.Short_Term_Airtime_Bonus__c = 2000.00;
        structure.Short_Term_Cash_Bonus__c = 2000.00;
        structure.Start_Date__c = date.today().addDays(-10);
        structure.Name = 'My_test';
        structure.Medium_Term_Airtime_Bonus__c = 2000.00;
        structure.Medium_Term_Cash_Bonus__c = 2000.00;
        database.insert(structure); 

        CKW_Performance_Review__c review = new CKW_Performance_Review__c();
        review.Surveys_Approved__c = 3.0;
        review.Number_Of_Searches_Running_Total__c = 3.0;
        review.CKW_c__c = testCkw.id;
        review.Incentive_Structure__c = structure.id;
        review.Monthly_Target__c = target.id;
        review.Start_Date__c = reviewStartDate;
        database.insert(review);

        // Create some searches for this ckw
        Person__c testPerson2 = new Person__c();
        testPerson2.First_Name__c = 'FirstName';
        testPerson2.Last_Name__c = 'LastName';
        testPerson2.Gender__c = 'Male';
        database.insert(testPerson2);
        List<Search_Log__c> logs = new List<Search_Log__c>();
        for (Integer i = 0; i < 10; i++) {
            Search_Log__c log = new Search_Log__c();
            log.Interviewer__c = testPerson.id;
            log.Interviewee__c = testPerson2.Id;
            log.Server_Entry_Time__c = MetricHelpers.convertToStartDate(searchDate).addHours(1);
            log.Handset_Submit_Time__c = MetricHelpers.convertToStartDate(searchDate).addHours(1);
            log.Latitude__c = 0.00;
            log.Longitude__c = 0.00;
            log.Altitude__c = 0.00;
            log.Accuracy__c = 0.00;
            log.Category__c = 'Category';
            log.Query__c = 'Query';
            log.Response__c = 'Content';
            logs.add(log);
        }
        database.insert(logs);

        // Run the update.
        updateSearchLogs(searchDate, searchDate, true);

        // Check that the record has been updated
        CKW_Performance_Review__c[] checkReview = [
            SELECT
                Number_Of_Searches_Running_Total__c
            FROM
                CKW_Performance_Review__c
            WHERE
                Start_Date__c = :reviewStartDate
                AND CKW_c__c = :testCkw.id
            ];
       System.assertEquals(checkReview[0].Number_Of_Searches_Running_Total__c, 13.0);
    }
}