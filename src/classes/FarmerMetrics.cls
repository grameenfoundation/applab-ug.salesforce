global class FarmerMetrics implements Database.Batchable<sObject>, Database.Stateful {

    global final String farmerQuery;
    global final List<String> farmerMetricsList;

    global final Date quarterStartDate;
    global final Date quarterEndDate;
    global final String quarterString;
    global final Boolean calculateRepeats;

    global Set<String> villages;

    // Global variables to update the current quarters metrics
    global final Map<String, Decimal> farmerMetricValues;

    // The global variables needed to tidy up the previous quarters data    
    global final Boolean updateFarmerLastQuarter;
    global final Map<String, Decimal> farmerPreviousMetricValues;

    // The name of the parter who this run of the batch is for
    global final Account partner;

    global FarmerMetrics (
            String query,
            List<String> metricsList, 
            Boolean calcRepeats,
            Account account
    ) {


        partner = account;
        farmerQuery = query;
        farmerMetricsList = metricsList;
        farmerMetricValues = new Map<String, Decimal>();
        for (String metric : metricsList) {
            farmerMetricValues.put(metric, 0.0);
        }
        villages = new Set<String>();
        calculateRepeats = calcRepeats;


        // We look at the date yesterday as this is run as a scheduled job so we want to look at the previous quarter if we are on the first day of a new quarter
        quarterString = MetricHelpers.getCurrentQuarterAsString(-1);
        quarterStartDate = MetricHelpers.getQuarterFirstDay(quarterString);
        quarterEndDate = MetricHelpers.getQuarterLastDay(quarterString);

    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(farmerQuery);
    }

    global void execute(Database.BatchableContext BC, List<Farmer__c> farmers) {

        // Loop through the batch and record details we need
        List<String> personIds = new List<String>();
        for (Farmer__c farmer : farmers) {
            farmerMetricValues.put('total_farmers_reached', farmerMetricValues.get('total_farmers_reached') + 1);
            personIds.add(farmer.Person__c);
            if (farmer.Person__r.Gender__c == 'Female') {
                farmerMetricValues.put('total_female_farmers_reached', farmerMetricValues.get('total_female_farmers_reached') + 1);
            }
            String village = farmer.Person__r.Village__c;
            if (village != null) {
                village = village.trim();
                village = village.toLowerCase();
                if (!villages.contains(village)) {
                    villages.add(village);
                }
            }
        }

        // Cannot group by a formula field. Shit I know but that is the case. Hence the complicated work around.
        // Going to hit a limit here at some point in the future (when we have an average of more than 200 poverty_scorecards__c)
        // but I hope that the issue mentioned above will be sorted by then.
        String q = 'SELECT Date__c, Person__c, Poverty_Percentage__c FROM Poverty_Scorecard__c WHERE Person__c IN (' + MetricHelpers.generateCommaSeperatedString(personIds, true) + ') ORDER BY Date__c ASC';
        Poverty_Scorecard__c[] poorCounts = database.query(q);
        Map<String, Decimal> scorecardScore = new Map<String, Decimal>();

        // Loop through the results to end up with the most recent date in the Map
        for (Poverty_Scorecard__c poorCount : poorCounts) {
            scorecardScore.put(poorCount.Person__c, poorCount.Poverty_Percentage__c);
        }

        // Loop through all the Scores and record how many are poor
        for (String id : scorecardScore.keySet()) {
            farmerMetricValues.put('total_poor_farmers_reached', farmerMetricValues.get('total_poor_farmers_reached') + scorecardScore.get(id));
        }

        // We don't want to calculate the repeat farmers metric in the first month of the quarter
        if (calculateRepeats) {

            // The list of things you cannot do in Salesforce is huge. Cant pass a date as a String to a query.
            // Therefore need to work out if we are running this query for this or the last quarter.
            String startQuarterLiteral = 'THIS_QUARTER';
            if (quarterString != MetricHelpers.getCurrentQuarterAsString(0)) {
                startQuarterLiteral = 'LAST_QUARTER';
            }

            // Run aggregate query to get the farmer details that we need to record
            q = ' SELECT Interviewee__c inter, Interviewee__r.Gender__c gender, count(Interviewee__r.id) total ' +  
                ' FROM Search_Log__c' +
                ' WHERE Interviewee__c IN (' + MetricHelpers.generateCommaSeperatedString(personIds, true) + ')'  +
                ' AND Server_Entry_Time__c  >= ' + startQuarterLiteral +
                ' AND Server_Entry_Time__c  <= YESTERDAY' +
                ' AND Interviewer__c != null' +
                ' AND Interviewer__c IN (SELECT Person__c FROM CKW__c)' +
                ' AND Interviewee__c != null' +
                ' AND (NOT Interviewee__r.First_Name__c LIKE \'TEST\')' +
                ' GROUP BY Interviewee__c, Interviewee__r.Gender__c';

            AggregateResult[] counts = database.query(q);	

            // Loop through the aggregate result and store the details required for this calcualtion. Also generate a list of Person ids
            personIds.clear();
            for (AggregateResult count : counts) {
                Integer total = (Integer)count.get('total');
                if (total > 1) {
                    farmerMetricValues.put('percent_repeat_farmers', farmerMetricValues.get('percent_repeat_farmers') + 1);
                    String gender = String.valueOf(count.get('gender'));
                    if (gender == 'Female') {
                        farmerMetricValues.put('percent_repeat_farmers_female', farmerMetricValues.get('percent_repeat_farmers_female') + 1);
                    }
                    personIds.add(String.valueOf(count.get('inter')));
                }
            }

            if (personIds.size() > 0){

                q = 'SELECT Date__c, Person__c, Poverty_Percentage__c FROM Poverty_Scorecard__c WHERE Person__c IN (' + MetricHelpers.generateCommaSeperatedString(personIds, true) + ') ORDER BY Date__c ASC';
                Poverty_Scorecard__c[] poorRepeatCounts = database.query(q);
                Map<String, Decimal> scorecardRepeatScore = new Map<String, Decimal>();

                // Loop through the results to end up with the moes recent date in the Map
                for (Poverty_Scorecard__c poorRepeatCount : poorRepeatCounts) {
                    scorecardRepeatScore.put(poorRepeatCount.Person__c, poorRepeatCount.Poverty_Percentage__c);
                }

                // Loop through all the Scores and record how many are poor
                for (String id : scorecardRepeatScore.keySet()) {
                    farmerMetricValues.put('percent_repeat_farmers_poor', farmerMetricValues.get('percent_repeat_farmers_poor') + scorecardRepeatScore.get(id));
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC){

        // Do any calculations that are required
        Decimal total = farmerMetricValues.get('total_farmers_reached');
        Decimal fiveOrMoreTotal = farmerMetricValues.get('percent_repeat_farmers');

        if (total != null && total > 0) {
            Decimal totalWomen = farmerMetricValues.get('total_female_farmers_reached');
            Decimal totalPoor = farmerMetricValues.get('total_poor_farmers_reached');
            if (totalWomen != null && totalWomen > 0) {
                farmerMetricValues.put('total_female_farmers_reached', (totalWomen/total) * 100);
            }
            if (totalPoor != null && totalPoor > 0) {
                farmerMetricValues.put('total_poor_farmers_reached', (totalPoor/total));
            }

            if (fiveOrMoreTotal != null && fiveOrMoreTotal > 0) {
                farmerMetricValues.put('percent_repeat_farmers', (fiveOrMoreTotal/total) * 100);
                Decimal fiveOrMoreWomen = farmerMetricValues.get('percent_repeat_farmers_female');
                if (fiveOrMoreWomen != null && fiveOrMoreWomen > 0) {
                    farmerMetricValues.put('percent_repeat_farmers_female', (fiveOrMoreWomen/totalWomen) * 100);
                }
                Decimal fiveOrMorePoor  = farmerMetricValues.get('percent_repeat_farmers_poor');
                if (fiveOrMorePoor != null && fiveOrMorePoor > 0) {
                    farmerMetricValues.put('percent_repeat_farmers_poor', (fiveOrMorePoor/totalPoor) * 100);
                }
            }
        }
        
        farmerMetricValues.put('total_villages', villages.size());
        farmerMetricValues.put('average_quarterly_total_repeat_usage', MetricHelpers.calculateAverageMetric('percent_repeat_farmers'));
        farmerMetricValues.put('average_quarterly_poor_repeat_usage', MetricHelpers.calculateAverageMetric('percent_repeat_farmers_female'));
        farmerMetricValues.put('average_quarterly_woman_repeat_usage', MetricHelpers.calculateAverageMetric('percent_repeat_farmers_poor'));

        List<M_E_Metric_Data__c> updateMetrics = new List<M_E_Metric_Data__c>();
        List<M_E_Metric_Data__c> newMetrics = new List<M_E_Metric_Data__c>();
        Map<String, M_E_Metric_Data__c> updateMetricMap = new Map<String, M_E_Metric_Data__c>();
        Map<String, M_E_Metric_Data__c> newMetricMap = new Map<String, M_E_Metric_Data__c>();

        // Check that we have the M_E_Metric_Data__c object created already
        M_E_Metric_Data__c[] metrics = MetricHelpers.getMetricDatas(farmerMetricsList, quarterStartDate, quarterEndDate, null);
        for (M_E_Metric_Data__c metric : metrics) {
            metric.Actual_Value__c = farmerMetricValues.get(metric.M_E_Metric__r.Name);
            updateMetricMap.put(metric.M_E_Metric__r.Name, metric);
        }

        // Generate any new metric if required
        for (String id : farmerMetricsList) {
            M_E_Metric_Data__c metric = updateMetricMap.get(id);
            if (metric == null) {
                M_E_Metric_Data__c newMetric = MetricHelpers.createNewMetric(id, quarterStartDate, farmerMetricValues.get(id), 0.0, null, null, false);
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

    public static testMethod void testFarmerBatch() {

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
        database.insert(testCkw);
        CKW__c testCkw2 = [SELECT name from CKW__c where id =:testCkw.id];  

        // Create 2 test farmers
        Person__c testPerson1 = new Person__c();
        testPerson1.First_Name__c = 'FirstName';
        testPerson1.Last_Name__c = 'LastName';
        testPerson1.Gender__c = 'Female';
        database.insert(testPerson1);

        Farmer__c testFarmer1 = new Farmer__c();
        testFarmer1.Person__c = testPerson1.Id;
        database.insert(testFarmer1);

        Person__c testPerson2 = new Person__c();
        testPerson2.First_Name__c = 'FirstName';
        testPerson2.Last_Name__c = 'LastName';
        testPerson1.Gender__c = 'Male';
        database.insert(testPerson2);

        Farmer__c testFarmer2 = new Farmer__c();
        testFarmer2.Person__c = testPerson2.Id;
        database.insert(testFarmer2);

        // Create some search logs for the first farmer that are in this quarter
        List<Search_Log__c> logs = new List<Search_Log__c>();
        for (integer i = 0; i < 7; i++) {
            Search_Log__c log = new Search_Log__c();
            log.Interviewer__c = testPerson.id;
            log.Interviewee__c = testPerson1.Id;
            log.Server_Entry_Time__c = Datetime.valueOf('2011-01-01 00:00:00');
            log.Handset_Submit_Time__c = Datetime.valueOf('2011-01-01 00:00:00');
            log.Latitude__c = 0.00;
            log.Longitude__c = 0.00;
            log.Altitude__c = 0.00;
            log.Accuracy__c = 0.00;
            log.Category__c = 'Category';
            log.Query__c = 'Query';
            log.Response__c = 'Content';
            logs.add(log);
        }

        // Create some search logs for the first farmer that are in the last quarter
        for (integer i = 0; i < 7; i++) {
            Search_Log__c log = new Search_Log__c();
            log.Interviewer__c = testPerson.id;
            log.Interviewee__c = testPerson1.Id;
            log.Server_Entry_Time__c = Datetime.valueOf('2010-12-01 00:00:00');
            log.Handset_Submit_Time__c = Datetime.valueOf('2010-12-01 00:00:00');
            log.Latitude__c = 0.00;
            log.Longitude__c = 0.00;
            log.Altitude__c = 0.00;
            log.Accuracy__c = 0.00;
            log.Category__c = 'Category';
            log.Query__c = 'Query';
            log.Response__c = 'Content';
            logs.add(log);
        }

        // Create some search logs for the second farmer that are in this quarter
        for (integer i = 0; i < 7; i++) {
            Search_Log__c log = new Search_Log__c();
            log.Interviewer__c = testPerson.id;
            log.Interviewee__c = testPerson2.Id;
            log.Server_Entry_Time__c = Datetime.valueOf('2011-01-01 00:00:00');
            log.Handset_Submit_Time__c = Datetime.valueOf('2011-01-01 00:00:00');
            log.Latitude__c = 0.00;
            log.Longitude__c = 0.00;
            log.Altitude__c = 0.00;
            log.Accuracy__c = 0.00;
            log.Category__c = 'Category';
            log.Query__c = 'Query';
            log.Response__c = 'Content';
            logs.add(log);
        }

        // Create some search logs for the second farmer that are the last quarter
        for (integer i = 0; i < 7; i++) {
            Search_Log__c log = new Search_Log__c();
            log.Interviewer__c = testPerson.id;
            log.Interviewee__c = testPerson2.Id;
            log.Server_Entry_Time__c = Datetime.valueOf('2010-12-01 00:00:00');
            log.Handset_Submit_Time__c = Datetime.valueOf('2010-12-01 00:00:00');
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

        // Create some poverty scorecards for the farmers
        List<Poverty_Scorecard__c> cards = new List<Poverty_Scorecard__c>();
        Poverty_Scorecard__c ps = new Poverty_Scorecard__c();
        ps.Children_Under_Eleven__c = 2.0;
        ps.Cooking_Fuel__c = 'Firewood';
        ps.Date__c = Datetime.valueOf('2010-12-01 00:00:00');
        ps.Education_Level__c = 'Graduate';
        ps.Household_Members_Have_Clothes__c = true;
        ps.Household_Members_Have_Shoes__c = true;
        ps.Owns_Jewelry_Watch__c = false;
        ps.Owns_Mosquito_Net__c = false;
        ps.Owns_TV_Radio_Cassette__c = false;
        ps.Person__c = testPerson1.id;
        ps.Roof_Material__c = 'Iron sheet/tin';
        ps.Wall_Material__c = 'Cement/other';
        cards.add(ps);

        Poverty_Scorecard__c ps1 = new Poverty_Scorecard__c();
        ps1.Children_Under_Eleven__c = 5.0;
        ps1.Cooking_Fuel__c = 'Firewood';
        ps1.Date__c = Datetime.valueOf('2010-11-01 00:00:00');
        ps1.Education_Level__c = 'O level';
        ps1.Household_Members_Have_Clothes__c = true;
        ps1.Household_Members_Have_Shoes__c = true;
        ps1.Owns_Jewelry_Watch__c = false;
        ps1.Owns_Mosquito_Net__c = false;
        ps1.Owns_TV_Radio_Cassette__c = false;
        ps1.Person__c = testPerson1.id;
        ps1.Roof_Material__c = 'Iron sheet/tin';
        ps1.Wall_Material__c = 'Cement/other';
        cards.add(ps1);

        Poverty_Scorecard__c ps2 = new Poverty_Scorecard__c();
        ps2.Children_Under_Eleven__c = 2.0;
        ps2.Cooking_Fuel__c = 'Firewood';
        ps2.Date__c = Datetime.valueOf('2010-12-01 00:00:00');
        ps2.Education_Level__c = 'O level';
        ps2.Household_Members_Have_Clothes__c = true;
        ps2.Household_Members_Have_Shoes__c = true;
        ps2.Owns_Jewelry_Watch__c = false;
        ps2.Owns_Mosquito_Net__c = false;
        ps2.Owns_TV_Radio_Cassette__c = false;
        ps2.Person__c = testPerson2.id;
        ps2.Roof_Material__c = 'Iron sheet/tin';
        ps2.Wall_Material__c = 'Cement/other';
        cards.add(ps2);

        database.insert(cards);

        // Run the batch
        Test.StartTest();
        String query = 'SELECT Name, Id, Person__c, Person__r.Gender__c, Person__r.Village__c  FROM Farmer__c WHERE id IN (\'' + testFarmer1.id + '\', \'' + testFarmer2.id + '\')';
        List<String> farmerMetricList = new List<String>();
        farmerMetricList.add('percent_repeat_farmers');
        farmerMetricList.add('percent_repeat_farmers_female');
        farmerMetricList.add('percent_repeat_farmers_poor');
        farmerMetricList.add('total_poor_farmers_reached');
        farmerMetricList.add('total_farmers_reached');
        farmerMetricList.add('total_female_farmers_reached');
        farmerMetricList.add('total_villages');

        // Get the organisation
        Account partner = [
            SELECT
                Name
            FROM
                Account
            WHERE
                Name = 'Grameen Foundation'
            ];
        FarmerMetrics farmerMetrics = new FarmerMetrics(query, farmerMetricList, true, partner);
        ID batchprocessid = Database.executeBatch(farmerMetrics);
        Test.StopTest();
        //System.AssertEquals(database.countquery('SELECT count() FROM M_E_Metric_Data__c WHERE M_E_Metric__r.Name IN (\'percent_repeat_farmers\', \'percent_repeat_farmers_female\', \'percent_repeat_farmers_poor\', \'total_poor_farmers_reached\', \'total_farmers_reached\', \'total_female_farmers_reached\')'), 6);
    }
}