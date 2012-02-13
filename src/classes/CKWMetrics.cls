global class CKWMetrics implements Database.Batchable<sObject>, Database.Stateful {

    /**
     *  The class implements Database.Stateful as that allows us to remember the global variables accross
     *  each time this class is run as a batch job.
     *  As this class implements Database.Batchable<sObject> all methods and variables must be public as this
     *  is a requirement of batched apex.
     *
     */
    global final String ckwQuery;
    global final List<String> ckwMetricsList;

    global final Date ckwQuarterStartDate;
    global final Date ckwQuarterEndDate;
    global final Date ckwPreviousQuarterStartDate;
    global final Date ckwPreviousQuarterEndDate;
    global final Date ckwPrevious2QuarterStartDate;
    global final Date ckwPrevious2QuarterEndDate;
    global final String ckwQuarterString;

    // Global variables to update the current quarters metrics
    global final Map<String, Decimal> ckwMetricValues;

    // The global variables needed to tidy up the previous quarters data    
    global final Boolean updateLastQuarter;
    global final Map<String, Decimal> ckwPreviousMetricValues;

    // The name of the parter who this run of the batch is for
    global final Account partner;

    global CKWMetrics (
            String query,
            List<String> metricsList,
            Boolean forcePreviousUpdate,
            Account account
    ) {

        ckwQuery = query;
        ckwMetricsList = metricsList;
        partner = account;
        ckwMetricValues = new Map<String, Decimal>();
        for (String metric : metricsList) {
            ckwMetricValues.put(metric, 0.0);
        }

        // We look at the date yesterday as this is run as a scheduled job so we want to look at the previous quarter if we are on the first day of a new quarter
        ckwQuarterString = MetricHelpers.getCurrentQuarterAsString(-1);
        ckwQuarterStartDate = MetricHelpers.getQuarterFirstDay(ckwQuarterString);
        ckwQuarterEndDate = MetricHelpers.getQuarterLastDay(ckwQuarterString);
        ckwPreviousQuarterStartDate = ckwQuarterStartDate.addMonths(-3);
        ckwPreviousQuarterEndDate = ckwQuarterEndDate.addMonths(-3);

        // Decide if we want to clean up the previous quarters data
        Integer gap = ckwQuarterStartDate.daysBetween(Date.today());
        if ((gap > 1 && gap < 15) || forcePreviousUpdate) {
            updateLastQuarter = true;
            ckwPreviousMetricValues = new Map<String, Decimal>();
            for (String metric : metricsList) {
                ckwPreviousMetricValues.put(metric, 0.0);
            }

            // Get the dates for the previous quarter but 1     
            ckwPrevious2QuarterStartDate = ckwQuarterStartDate.addMonths(-6);
            ckwPrevious2QuarterEndDate = ckwQuarterEndDate.addMonths(-6);
        }
        else {
            updateLastQuarter = false;
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(ckwQuery);
    }

    global void execute(Database.BatchableContext BC, List<CKW__c> ckws){

        // Loop through the CWKs and dig out the IDs so we can get the performance records
        List<String> ckwIds = new List<String>();
        List<String> previousCkwIds = new List<String>();
        List<String> personIds = new List<String>();
        List<String> previousPersonIds = new List<String>();
        Map<string, String> variables = new Map<String, String>();
        for (CKW__c ckw : ckws) {
            if (ckw.Status__c != null && ckw.Status__c.equals('Active')) {
                ckwMetricValues.put('total_ckws', ckwMetricValues.get('total_ckws') + 1);
                personIds.add(ckw.Person__c);
            }
            ckwIds.add(ckw.Id);
            if (updateLastQuarter && ckw.Active_Date__c != null && ckwQuarterStartDate.daysBetween(ckw.Active_Date__c) < 0) {
                ckwPreviousMetricValues.put('total_ckws', ckwPreviousMetricValues.get('total_ckws') + 1);
                previousCkwIds.add(ckw.Id);
                previousPersonIds.add(ckw.Person__c);
            }
        }
        if (ckwIds.size() > 0) {
            MetricHelpers.getPerformanceDetails(ckwIds, ckwMetricValues, ckwQuarterStartDate, ckwQuarterEndDate);
            variables.put('persons', MetricHelpers.generateCommaSeperatedString(personIds, true));
            variables.put('gender', 'Female');
            ckwMetricValues.put('percent_woman_ckws', ckwMetricValues.get('percent_woman_ckws')  + SoqlHelpers.getNumberOfPeople(variables, true));
            ckwMetricValues.put('percent_poor_ckws', ckwMetricValues.get('percent_poor_ckws') + SoqlHelpers.getSumOfPeople('Current_Poverty_Scorecard__r.Poverty_Percentage__c', variables, true));
        }
        if (updateLastQuarter && previousCkwIds.size() > 0) {
            MetricHelpers.getPerformanceDetails(previousCkwIds, ckwPreviousMetricValues, ckwPreviousQuarterStartDate, ckwPreviousQuarterEndDate);
            variables.put('persons', MetricHelpers.generateCommaSeperatedString(previousPersonIds, true));
            variables.put('gender', 'Female');
            ckwPreviousMetricValues.put('percent_woman_ckws', ckwPreviousMetricValues.get('percent_woman_ckws')  + SoqlHelpers.getNumberOfPeople(variables, true));
            ckwPreviousMetricValues.put('percent_poor_ckws', ckwPreviousMetricValues.get('percent_poor_ckws') + SoqlHelpers.getSumOfPeople('Current_Poverty_Scorecard__r.Poverty_Percentage__c', variables, true));
        }
    }

    global void finish(Database.BatchableContext BC) {

        if (ckwMetricValues.get('total_ckws') == 0.0) {
            return;
        }

        // List of cumulative metrics that require us to look at last quarter to get the results
        List<String> previousMetricsRequired = new List<String>();
        previousMetricsRequired.add('total_interactions_surveys');
        previousMetricsRequired.add('total_interactions_searches');
        previousMetricsRequired.add('total_complete_interactions_ussd_searches');
        previousMetricsRequired.add('total_complete_interactions_call_center');        

        // List of the metric names that are used to calculate the total info services
        List<String> totalMetrics = new List<String>();
        totalMetrics.add('total_interactions_surveys');
        totalMetrics.add('total_interactions_searches');
        totalMetrics.add('total_complete_interactions_ussd_searches');
        totalMetrics.add('total_complete_interactions_call_center');
        totalMetrics.add('total_interactions_channels');
        
        // Lists to store the metric data for the DML actions
        List<M_E_Metric_Data__c> updateMetrics = new List<M_E_Metric_Data__c>();
        List<M_E_Metric_Data__c> newMetrics = new List<M_E_Metric_Data__c>();

        // If required update the previous quarter
        if (updateLastQuarter) {

            // Get the SMS interactions
            ckwPreviousMetricValues.put('total_interactions_channels', MetricHelpers.getSmsInteractions(ckwPreviousQuarterStartDate, ckwPreviousQuarterEndDate));

            // Calculate the remaining metrics
            // Convert to a %
            ckwPreviousMetricValues.put('percent_ckws_high_performance', (ckwPreviousMetricValues.get('percent_ckws_high_performance')/ckwPreviousMetricValues.get('total_ckws'))*100);
            ckwPreviousMetricValues.put('percent_poor_ckws', ckwPreviousMetricValues.get('percent_poor_ckws')/ckwPreviousMetricValues.get('total_ckws'));
            ckwPreviousMetricValues.put('percent_woman_ckws', (ckwPreviousMetricValues.get('percent_woman_ckws')/ckwPreviousMetricValues.get('total_ckws'))*100);

            // Get the baseline numbers from the previous quarter if required.
            Map<String, Decimal> previous2Totals = MetricHelpers.getMetricValues(previousMetricsRequired, ckwPrevious2QuarterStartDate, ckwPrevious2QuarterEndDate);
            ckwPreviousMetricValues.put('total_info_services_offered', MetricHelpers.calculateTotal(totalMetrics, ckwPreviousMetricValues, previous2Totals, ckwPreviousQuarterStartDate, ckwPreviousQuarterEndDate));

            // Check that we have the M_E_Metric_Data__c object created already
            M_E_Metric_Data__c[] previousMetrics = MetricHelpers.getMetricDatas(ckwMetricsList, ckwPreviousQuarterStartDate, ckwPreviousQuarterEndDate, null);

            // Generate the metrics that need to be updated
            Map<String, M_E_Metric_Data__c> updatePreviousMetricMap = MetricHelpers.generateUpdateMetricMap(previousMetrics, ckwPreviousMetricValues, previous2Totals);

            // Generate any new metric if required
            Map<String, M_E_Metric_Data__c> newPreviousMetricMap = new Map<String, M_E_Metric_Data__c>();
            for (String id : ckwMetricsList) {
                M_E_Metric_Data__c metric = updatePreviousMetricMap.get(id);
                if (metric == null) {
                    Decimal prevValue = previous2Totals.get(id);
                    Decimal value = ckwPreviousMetricValues.get(id);
                    if (prevValue != null) {
                        value = value + prevValue;
                    }
                    M_E_Metric_Data__c newMetric = MetricHelpers.createNewMetric(id, ckwPreviousQuarterStartDate, value, 0.0, null, null, false);
                    if (newMetric != null) {
                        newPreviousMetricMap.put(id, newMetric);
                    }
                }
            }
            for (String id : updatePreviousMetricMap.keySet()) {
                updateMetrics.add(updatePreviousMetricMap.get(id));
            }
            for (String id : newPreviousMetricMap.keySet()) {
                newMetrics.add(newPreviousMetricMap.get(id));
            }

            // Save previous quarters data. Must do here so that the calculations for the next quarter
            // pick up the changes.
            if (updateMetrics.size() > 0) {
                update updateMetrics;
            }
            if (newMetrics.size() > 0) {
                insert newMetrics;
            }
        }

        // Sort out the current quarters data
        // Clear the DML lists
        updateMetrics.clear();
        newMetrics.clear();

        // Get the SMS interactions
        ckwMetricValues.put('total_interactions_channels', MetricHelpers.getSmsInteractions(ckwQuarterStartDate, ckwQuarterEndDate));

        // Convert to a %
        ckwMetricValues.put('percent_ckws_high_performance', (ckwMetricValues.get('percent_ckws_high_performance')/ckwMetricValues.get('total_ckws'))*100);
        ckwMetricValues.put('percent_poor_ckws', ckwMetricValues.get('percent_poor_ckws')/ckwMetricValues.get('total_ckws'));
        ckwMetricValues.put('percent_woman_ckws', (ckwMetricValues.get('percent_woman_ckws')/ckwMetricValues.get('total_ckws'))*100);

        // Get the baseline numbers from the previous quarter if the metric is cumulative since the start
        // of the project
        Map<String, Decimal> previousTotals = MetricHelpers.getMetricValues(previousMetricsRequired, ckwPreviousQuarterStartDate, ckwQuarterStartDate);

        // Check that we have the M_E_Metric_Data__c object created already
        M_E_Metric_Data__c[] metrics = MetricHelpers.getMetricDatas(ckwMetricsList, ckwQuarterStartDate, ckwQuarterEndDate, null);

        // Calculate the total interactions.
        ckwMetricValues.put('total_info_services_offered', MetricHelpers.calculateTotal(totalMetrics, ckwMetricValues, previousTotals, ckwQuarterStartDate, ckwQuarterEndDate));

        // Generate the metrics that need to be updated
        Map<String, M_E_Metric_Data__c> updateMetricMap = MetricHelpers.generateUpdateMetricMap(metrics, ckwMetricValues, previousTotals);

        // Generate any new metric if required
        Map<String, M_E_Metric_Data__c> newMetricMap = new Map<String, M_E_Metric_Data__c>();
        for (String id : ckwMetricsList) {
            M_E_Metric_Data__c metric = updateMetricMap.get(id);
            if (metric == null) {
                Decimal prevValue = previousTotals.get(id);
                Decimal value = ckwMetricValues.get(id);
                if (prevValue != null) {
                    value = value + prevValue;
                }
                M_E_Metric_Data__c newMetric = MetricHelpers.createNewMetric(id, ckwQuarterStartDate, value, 0.0, null, null, false);
                if (newMetric != null) {
                    newMetricMap.put(id, newMetric);
                }
            }
        }

        // Add the metrics to the correct list
        for (String id : updateMetricMap.keySet()) {
            updateMetrics.add(updateMetricMap.get(id));
        }
        for (String id : newMetricMap.keySet()) {
            newMetrics.add(newMetricMap.get(id));
        }

        // Save the new details to the database
        if (updateMetrics.size() > 0) {
            update updateMetrics;
        }
        if (newMetrics.size() > 0) {
            insert newMetrics;
        }
    }

    public static testMethod void testCKWBatch() {

        // Generate the dates required
        Date thisMonth = Date.today();
        thisMonth = thisMonth.toStartOfMonth();
        Date month1 = thisMonth.addMonths(-1);
        Date month2 = thisMonth.addMonths(-2);
        Date month3 = thisMonth.addMonths(-3);
        Date month4 = thisMonth.addMonths(-4);
        Date month5 = thisMonth.addMonths(-5);
        List<Date> dates = new List<Date>();
        dates.add(thisMonth);
        dates.add(month1);
        dates.add(month2);
        dates.add(month3);
        dates.add(month4);
        dates.add(month5);

        // Create a handset
        Phone__c testHandset = new Phone__c();
        testHandset.IMEI__c = 'TestIMEI';
        testHandset.Serial_Number__c = '325246263253462';
        testHandset.Purchase_Value_USD__c = 100.00;
        database.insert(testHandset);

        // Create a test CKW
        Person__c testPerson = new Person__c();
        testPerson.First_Name__c = 'FirstName';
        testPerson.Last_Name__c = 'LastName';
        testPerson.Handset__c = testHandset.Id;
        database.insert(testPerson);

        CKW__c testCkw = new CKW__c();
        testCkw.Person__c = testPerson.id;
        testCkw.Status__c = 'Active';
        testCkw.Active_Date__c = date.today().addMonths(-3);
        database.insert(testCkw);
        CKW__c testCkw2 = [SELECT name from CKW__c where id =:testCkw.id];

        List<CKW_Performance_Review__c> reviews = new List<CKW_Performance_Review__c>();

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

        // Create some performance records for this CKW
        for (Integer i = 0; i < 6; i++) {
            CKW_Performance_Review__c review = new CKW_Performance_Review__c();
            review.Surveys_Approved__c = 3.0;
            review.Number_Of_Searches_Running_Total__c = 3.0;
            review.CKW_c__c = testCkw2.id;
            review.Incentive_Structure__c = structure.id;
            review.Monthly_Target__c = target.id;
            review.Start_Date__c = dates.get(i);
            reviews.add(review);
        }

        // Create a handset
        Phone__c testHandset2 = new Phone__c();
        testHandset2.IMEI__c = 'TestIMEI2';
        testHandset2.Serial_Number__c = '322246263253462';
        testHandset2.Purchase_Value_USD__c = 100.00;
        database.insert(testHandset2);

        // Create a 2nd CKW
        Person__c testPerson2 = new Person__c();
        testPerson2.First_Name__c = 'FirstName';
        testPerson2.Last_Name__c = 'LastName';
        testPerson2.Handset__c = testHandset2.Id;
        database.insert(testPerson2);

        CKW__c testCkw3 = new CKW__c();
        testCkw3.Status__c = 'Active';
        testCkw3.Active_Date__c = date.today().addMonths(-3);
        testCkw3.Person__c = testPerson2.id;
        database.insert(testCkw3);
        CKW__c testCkw4 = [SELECT name from CKW__c where id =:testCkw3.id];

        // Create some performance records for this CKW
        CKW_Performance_Review__c goodRev = new CKW_Performance_Review__c();
        goodRev.Surveys_Approved__c = 5.0;
        goodRev.Number_Of_Searches_Running_Total__c = 5.0;
        goodRev.Incentive_Structure__c = structure.Id;
        goodRev.Monthly_Target__c = target.id;
        goodRev.CKW_c__c = testCkw4.id;
        goodRev.Start_Date__c = dates.get(0);
        reviews.add(goodRev);
        for (Integer i = 1; i < 6; i++) {
            CKW_Performance_Review__c review = new CKW_Performance_Review__c();
            review.Surveys_Approved__c = 3.0;
            review.Number_Of_Searches_Running_Total__c = 3.0;
            review.CKW_c__c = testCkw4.id;
            review.Incentive_Structure__c = structure.id;
            review.Monthly_Target__c = target.id;
            review.Start_Date__c = dates.get(i);
            reviews.add(review);
        }

        // Save the reviews
        database.insert(reviews);

        // Run the batch
        Test.StartTest();
        String query = 'SELECT Id, Status__c, Active_Date__c, Person__c  FROM CKW__c WHERE id IN (\'' + testCkw.id + '\', \'' + testCkw3.id + '\')';
        List<String> metricList = new List<String>();
        metricList.add('total_interactions_surveys');
        metricList.add('total_interactions_searches');
        metricList.add('total_interactions_channels');
        metricList.add('total_complete_interactions_ussd_searches');
        metricList.add('percent_ckws_high_performance');
        metricList.add('total_info_services_offered');
        metricList.add('total_ckws');
        metricList.add('percent_poor_ckws');
        metricList.add('percent_woman_ckws');

        // Get the organisation
        Account partner = [
            SELECT
                Name
            FROM
                Account
            WHERE
                Name = 'Grameen Foundation'
            ];
        CKWMetrics ckwMetric = new CKWMetrics(query, metricList, true, partner);
        ID batchprocessid = Database.executeBatch(ckwMetric);
        Test.StopTest();
        System.Assert(database.countquery('SELECT count() FROM M_E_Metric_Data__c WHERE M_E_Metric__r.Name IN (\'percent_ckws_high_performance\', \'total_interactions_searches\', \'total_interactions_surveys\', \'total_info_services_offered\', \'total_interactions_channels\', \'total_ckws\') AND Date__c = THIS_QUARTER') >= 6);
    }
}