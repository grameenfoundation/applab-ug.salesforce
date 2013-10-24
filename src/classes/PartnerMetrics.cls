global class PartnerMetrics implements Database.Batchable<sObject>, Database.Stateful {

    // The query that gets the people who will be included in the metrics
    global final String partnerQuery;

    // The name of the parter who this run of the batch is for
    global final Account partner;

    // A map of the metric data objects that are to be updated in this batch
    global final Map<String, M_E_Metric_Data__c> currentQuarterMetricDatas;

    // A list of the metrics that the partner has
    global final List<M_E_Metric__c> partnerMetrics;

    // A map of all the metrics that we are to calculate for this partner
    global final Map<String, MetricDataCalculationParameters> metricCalculationParameters;
    global final Map<String, MetricDataCalculationTracker> metricCalculationTracker;

    // The global date values that define the period we are looking at
    global final Date ckwQuarterStartDate;
    global final Date ckwQuarterEndDate;
    global final Date ckwPreviousQuarterStartDate;
    global final Date ckwPreviousQuarterEndDate;
    global final String ckwQuarterString;

    // Some totals that need to be kept track of
    // Search hit totals
    global final Map<String, Integer> searchTotals;

    // Total interactions
    global final Map<String, Integer> totalInteractions;

    // The total submissions for each survey for this partner. Note the key here should be Survey__c.Name
    global final Map<String, Integer> surveyTotals;
    global final Map<String, Survey__c> surveyMap;
    global final List<String> partnerSurveyNames;
    global final Map<String, District__c> districts;

    // The number of CKWs that this partner has active. Should only pass active People to this class.
    global final Map<String, MetricDataCalculationGeneralTracker> generalMetrics;

    global PartnerMetrics (
            String query,
            Account account,
            Map<String, MetricDataCalculationParameters> parameters,
            Map<String, Survey__c> surveyNames
    ) {

        partnerQuery = query;
        partner = account;
        metricCalculationParameters = parameters;
        partnerSurveyNames = new List<String>();
        for (String key : surveyNames.keySet()) {
            partnerSurveyNames.add(surveyNames.get(key).Name);
        }
        surveyMap = surveyNames;
        districts = new Map<String, District__c>();
        searchTotals = new Map<String, Integer>();
        surveyTotals = new Map<String, Integer>();
        totalInteractions = new Map<String, Integer>();

        // We look at the date yesterday as this is run as a scheduled job so we want to look at the previous quarter if we are on the first day of a new quarter
        ckwQuarterString = MetricHelpers.getCurrentQuarterAsString(-1);
        ckwQuarterStartDate = MetricHelpers.getQuarterFirstDay(ckwQuarterString);
        ckwQuarterEndDate = MetricHelpers.getQuarterLastDay(ckwQuarterString);
        ckwPreviousQuarterStartDate = ckwQuarterStartDate.addMonths(-3);
        ckwPreviousQuarterEndDate = ckwQuarterEndDate.addMonths(-3);

        // Get the metrics for the partner
        partnerMetrics = MetricHelpers.getMetrics(null, partner.Name);
        if (partnerMetrics == null) {

            // TODO - Make this throw an exception
            // No metrics assigned to this partner. Don't continue as they have no reason to be here
            return;
        }

        // Initialise the general metric tracker map
        generalMetrics = new Map<String, MetricDataCalculationGeneralTracker>();

        // Get all the metric datas for this quarter and create a map to store them in. Also create the temporary calculation storage
        currentQuarterMetricDatas = new Map<String, M_E_Metric_Data__c>();
        metricCalculationTracker = new Map<String, MetricDataCalculationTracker>();
        for (M_E_Metric_Data__c metricData : MetricHelpers.getMetricDatas(null, ckwQuarterStartDate, ckwQuarterEndDate, partner.Name)) {
            String districtString = null;
            if (metricData.District__r.Name != null) {
                districtString = metricData.District__r.Name;
            }
            String metricDataName = MetricHelpers.createMetricLabelString(metricData.M_E_Metric__r.Name, districtString);
            if (metricData.Is_Cumulative__c != null && metricData.Is_Cumulative__c) {
                metricDataName = metricDataName + '_cumulative';
            }
            currentQuarterMetricDatas.put(metricDataName, metricData);

            // Check the district id so we can create a list of the districts and the create the metric tracker objects
            if (metricData.District__r.Name != null && !districts.containsKey(metricData.District__r.Name)) {
                if (MetricHelpers.checkForOranistationDistrictLink(partner, metricData.District__c, true)) {

                    // Load the District
                    District__c district = database.query(SoqlHelpers.getDistrict(metricData.District__r.Name));
                    districts.put((String)district.Name, district);
                    generalMetrics.put(district.Name, new MetricDataCalculationGeneralTracker());

                    // Make sure that we have the MetricDataCalculationTracker objects created for this district.
                    for (M_E_Metric__c metric : partnerMetrics) {

                        // Only create if this metric is split by something
                        if (metric.Sub_Divide__c)  {
                            String metricTrackerName = MetricHelpers.createMetricLabelString(metric.Name, district.Name);
                            if (!metricCalculationTracker.containsKey(metricTrackerName) && metricCalculationParameters.containsKey(metric.Name)) {
                                metricCalculationTracker.put(metricTrackerName, new MetricDataCalculationTracker(metric.Name, metricCalculationParameters.get(metric.Name).getFunction(), district, metricCalculationParameters.get(metric.Name).getSurvey()));
                            }
                        }

                        // Check that the general metric is there as well
                        if (!metricCalculationTracker.containsKey(metric.Name) && metricCalculationParameters.containsKey(metric.Name)) {
                            metricCalculationTracker.put(metric.Name, new MetricDataCalculationTracker(metric.Name, metricCalculationParameters.get(metric.Name).getFunction(), null, metricCalculationParameters.get(metric.Name).getSurvey()));
                        }
                    }
                }
            }
        }

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(partnerQuery);
    }

    global void execute(Database.BatchableContext BC, List<Person__c> people) {

        // Generate a list of Id for each Person in this batch. Also take the general counters for the CKWs
        List<String> personIds = new List<String>();
        for (Person__c person : people) {

            // The person is invalid if they have no district so we don't count them
            if (person.District__r.Name == null) {
                continue;
            }
            personIds.add((String)person.Id);

            // Check the district id so we can create a list of the districts and the create the metric tracker objects
            if (!districts.containsKey(person.District__r.Name)) {
                if (person.District__c != null && MetricHelpers.checkForOranistationDistrictLink(partner, person.District__c, true)) {

                    // Load the District
                    District__c district = database.query(SoqlHelpers.getDistrict(person.District__r.Name));
                    districts.put((String)district.Name, district);
                    generalMetrics.put(person.District__r.Name, new MetricDataCalculationGeneralTracker());

                    // Make sure that we have the MetricDataCalculationTracker objects created for this district.
                    for (M_E_Metric__c metric : partnerMetrics) {

                        // Only create if this metric is split by something
                        if (metric.Sub_Divide__c)  {
                            String metricDataName = MetricHelpers.createMetricLabelString(metric.Name, person.District__r.Name);
                            if (!metricCalculationTracker.containsKey(metricDataName) && metricCalculationParameters.containsKey(metric.Name)) {
                                metricCalculationTracker.put(metricDataName, new MetricDataCalculationTracker(metric.Name, metricCalculationParameters.get(metric.Name).getFunction(), district, metricCalculationParameters.get(metric.Name).getSurvey()));
                            }
                        }

                        // Check that the general metric is there as well
                        if (!metricCalculationTracker.containsKey(metric.Name) && metricCalculationParameters.containsKey(metric.Name)) {
                            metricCalculationTracker.put(metric.Name, new MetricDataCalculationTracker(metric.Name, metricCalculationParameters.get(metric.Name).getFunction(), null, metricCalculationParameters.get(metric.Name).getSurvey()));
                        }
                    }
                }
            }

            MetricDataCalculationGeneralTracker generalMetric = generalMetrics.get(person.District__r.Name);
            if (generalMetric == null) {
                continue;
            }
            generalMetric.setTotalActivePeople(1.0);
            if (person.Current_Poverty_Scorecard__r.Poverty_Percentage__c != null) {
                generalMetric.setSumPovertyScore(person.Current_Poverty_Scorecard__r.Poverty_Percentage__c);
            }
            if (person.Gender__c != null && person.Gender__c.equalsIgnoreCase('Female')) {
                generalMetric.setTotalFemalePeople(1.0);
            }
            generalMetrics.put(person.District__r.Name, generalMetric);
        }

        if (personIds.isEmpty()) {
            return;
        }

        // Calculate the number of surveys that have been done by these people.
        Map<String, String> variables = new Map<String, String>();
        variables.put('ckws', MetricHelpers.generateCommaSeperatedString(personIds, true));
        variables.put('submissionStartDate', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(this.ckwQuarterStartDate), false));
        variables.put('submissionEndDate', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(this.ckwQuarterEndDate), false));
        variables.put('surveyName', MetricHelpers.generateCommaSeperatedString(this.partnerSurveyNames, true));
        variables.put('dataCollectionStatusNot', 'Rejected');
        variables.put('customerCareStatusNot', 'Rejected');
        SoqlHelpers.countSurveyTotals(variables, this.surveyTotals, 'Interviewer__r.District__r.Name', surveyMap);
        variables.remove('surveyName');

        // Calculate the number of searches for these people
        variables.put('searchStartDate', this.ckwQuarterStartDate.format());
        variables.put('searchEndDate', this.ckwQuarterEndDate.format());
        SoqlHelpers.getSearchTotals(variables, this.searchTotals, 'Interviewer__r.District__r.Name');

        // Loop through the metrics that we are looking to calculate and get the data for these people
        for (MetricDataCalculationParameters metricDataCalculationParameters : this.metricCalculationParameters.values()) {
            variables.put('surveyName', '\'' + metricDataCalculationParameters.getSurvey().Name + '\'');
            variables.put('binding', metricDataCalculationParameters.getBinding());

            String questionType = metricDataCalculationParameters.getQuestionType();
            variables.put('questionType', questionType);
            variables.put('function', metricDataCalculationParameters.getFunction());

            String metricName = metricDataCalculationParameters.getMetricGeneralName();

            // Multiple select questions need to be handled in a slightly different way from the others
            if (questionType.equals('multiSelect')) {
                variables.put('multipleOptions', metricDataCalculationParameters.getSelectOptions());
            }
            else if (questionType.equals('singleSelect')) {
                variables.put('selectOptions', metricDataCalculationParameters.getSelectOptions());
            }
            AggregateResult[] results = database.query(SoqlHelpers.getSurveyStats(variables, metricDataCalculationParameters.getGroupList()));
            for (AggregateResult result : results) {

                // TODO - support grouping by more than one field.
                String groupField = (String)result.get('groupField0');
                Decimal total = (Decimal)result.get('total');
                String metricDataName = MetricHelpers.createMetricLabelString(metricName, groupField);
                if (metricCalculationTracker.get(metricDataName) == null) {
                    System.debug(LoggingLevel.INFO, 'MetricCalclationTracker for ' + metricDataName + ' is missing. Total was ' + total);
                }
                else {
                    metricCalculationTracker.get(metricDataName).setTotal(total);
                }
            }
            variables.remove('surveyName');
            variables.remove('binding');
            variables.remove('questionType');
            variables.remove('function');
            variables.remove('multipleOptions');
            variables.remove('selectOptions');
        }
    }

    global void finish(Database.BatchableContext BC) {


        List<M_E_Metric_Data__c> metricsDatas = new List<M_E_Metric_Data__c>();

        // Go through the general metrics and update the M_E_Metric_Data__c objects. The key here should be the item that
        // We are splitting the data by
        Decimal totalWorkers = 0.0;
        Decimal totalFemaleWorkers = 0.0;
        Decimal totalPoorWorkers = 0.0;
        Decimal totalDistricts = 0.0;

        for (String key : generalMetrics.keySet()) {

            // Check that there are actually people for this district
            MetricDataCalculationGeneralTracker metricDataCalculationGeneralTracker = generalMetrics.get(key);
            if (metricDataCalculationGeneralTracker.getTotalActivePeople() == 0) {
                continue;
            }
            totalDistricts++;

            // Start with the total workers
            String metricDataName = MetricHelpers.createMetricLabelString(partner.Name + '_total_workers', key);
            M_E_Metric_Data__c metric = currentQuarterMetricDatas.get(metricDataName);
            if (metric == null) {

                // Create the metric data if it does not exist
                metric = MetricHelpers.createNewMetric(partner.Name + '_total_workers', ckwQuarterStartDate, metricDataCalculationGeneralTracker.getTotalActivePeople(), null, districts.get(key).Id, partner.Name, false);
            }
            else { 

                // Add the total
                metric.Actual_Value__c = metricDataCalculationGeneralTracker.getTotalActivePeople();
            }
            if (metric != null) {
                metricsDatas.add(metric);
            }
            totalWorkers += metricDataCalculationGeneralTracker.getTotalActivePeople();

            // Then the female workers
            metricDataName = MetricHelpers.createMetricLabelString(partner.Name + '_total_female_workers', key);
            metric = currentQuarterMetricDatas.get(metricDataName);
            Decimal female = 0.0;
            if (metricDataCalculationGeneralTracker.getTotalFemalePeople() != 0) {
                female = (metricDataCalculationGeneralTracker.getTotalFemalePeople() / totalWorkers) * 100;
            }
            if (metric == null) {

                // Create the metric data if it does not exist
                metric = MetricHelpers.createNewMetric(partner.Name + '_total_female_workers', ckwQuarterStartDate, female, null, districts.get(key).Id, partner.Name, false);
            }
            else {

                // Add the total
                metric.Actual_Value__c = female;
            }
            totalFemaleWorkers += female;
            if (metric != null) {
                metricsDatas.add(metric);
            }

            // Then the poor workers
            metricDataName = MetricHelpers.createMetricLabelString(partner.Name + '_total_poor_workers', key);
            metric = currentQuarterMetricDatas.get(metricDataName);
            Decimal poor = metricDataCalculationGeneralTracker.getSumPovertyScore() / totalWorkers;
            if (metric == null) {

                // Create the metric data if it does not exist
                metric = MetricHelpers.createNewMetric(partner.Name + '_total_poor_workers', ckwQuarterStartDate, poor, null, districts.get(key).Id, partner.Name, false);
            }
            else {

                // Add the total
                metric.Actual_Value__c = poor;
            }
            if (metric != null) {
                metricsDatas.add(metric);
            }

            totalPoorWorkers += poor;
        }

        // Go through the calculated metrics and save the results to the DB
        for (String key : metricCalculationTracker.keySet()) {

            MetricDataCalculationTracker tracker = metricCalculationTracker.get(key);

            // Check that some data has been added to the tracker. Otherwise there is no point saving it
            if (tracker == null || tracker.getNoDataAdded()) {
                continue;
            }

            // Perform the calculation required to get the actual value that should be displayed
            Decimal actualValue = MetricHelpers.calculateSurveyTotal(tracker, this.surveyTotals);
            M_E_Metric_Data__c metric = currentQuarterMetricDatas.get(key);
            if (metric == null) {

                // Create the metric
                metric = MetricHelpers.createNewMetric(tracker.getMetricName(), ckwQuarterStartDate, actualValue, null, tracker.getDistrict().Id, partner.Name, false);
            }
            else {

                // Update the existing metric
                metric.Actual_Value__c = actualValue;
            }
            if (metric != null) {
                metricsDatas.add(metric);
            }
        }

        // Go through the search totals and add the metrics. The key should be the district name
        for (String key : this.searchTotals.keySet()) {
            Integer total = this.searchTotals.get(key);
            String districtId = districts.get(key).Id;
            String metricName = partner.Name + '_total_searches';
            M_E_Metric_Data__c metric = currentQuarterMetricDatas.get(metricName + '_' + key);
            if (metric == null) {

                // Create the metric
                metric = MetricHelpers.createNewMetric(metricName, ckwQuarterStartDate, total, null, districtId, partner.Name, false);
            }
            else {

                // Update the existing metric
                metric.Actual_Value__c = total;
            }
            if (metric != null) {
                metricsDatas.add(metric);
            }

            // Also add the search totals to the total interactions
            Integer totalInteraction = this.totalInteractions.get(key);
            if (totalInteraction == null) {
                totalInteraction = 0;
            }
            this.totalInteractions.put(key, totalInteraction + total);
        }

        // Go through the survey totals and sort the total metric datas
        for (String key : this.surveyTotals.keySet()) {

            String[] keys = key.split('_splitter_');
            Integer total = this.surveyTotals.get(key);

            // If only one key then this is the total metric
            M_E_Metric_Data__c metric;
            String metricName = partner.Name + '_' + keys[0] + '_total';
            String districtId = null;
            if (keys.size() == 1) {
                metric = currentQuarterMetricDatas.get(metricName);
            }
            else {
                districtId = districts.get(keys[1]).Id;
                metric = currentQuarterMetricDatas.get(metricName + '_' + keys[1]);
            }
            if (metric == null) {

                // Create the metric
                metric = MetricHelpers.createNewMetric(metricName, ckwQuarterStartDate, total, null, districtId, partner.Name, false);
            }
            else {

                // Update the existing metric
                metric.Actual_Value__c = total;
            }
            if (metric != null) {
                metricsDatas.add(metric);
            }

            // Also add the search totals to the total interactions
            if (keys.size() == 2) {
                Integer totalInteraction = this.totalInteractions.get(keys[1]);
                if (totalInteraction == null) {
                    totalInteraction = 0;
                }
                this.totalInteractions.put(keys[1], totalInteraction + total);
            }
        }

        // Now go through the total interactions and add the metrics. Key is the district name
        for (String key : this.totalInteractions.keySet()) {

            Integer total = this.totalInteractions.get(key);
            String districtId = districts.get(key).Id;
            String metricName = partner.Name + '_total_interactions';
            M_E_Metric_Data__c metric = currentQuarterMetricDatas.get(metricName + '_' + key);
            if (metric == null) {

                // Create the metric
                metric = MetricHelpers.createNewMetric(metricName, ckwQuarterStartDate, total, null, districtId, partner.Name, false);
            }
            else {

                // Update the existing metric
                metric.Actual_Value__c = total;
            }
            if (metric != null) {
                metricsDatas.add(metric);
            }
        }

        // Batch up the metric datas and save to the db
        MetricHelpers.saveMetricDatas(metricsDatas);
        metricsDatas.clear();

        // Calcualte the totals for all the districts
        for (MetricDataCalculationTracker tracker : MetricHelpers.getTotals(partner.Name)) {

            if (tracker.getNoDataAdded()) {
                continue;
            }

            Decimal actualValue = tracker.getTotal();

            M_E_Metric_Data__c metric = currentQuarterMetricDatas.get(tracker.getMetricName());
            if (metric == null) {

                // Create the metric
                metric = MetricHelpers.createNewMetric(tracker.getMetricName(), ckwQuarterStartDate, actualValue, null, null, partner.Name, false);
            }
            else {

                // Update the existing metric
                metric.Actual_Value__c = actualValue;
            }
            if (metric != null) {
                metricsDatas.add(metric);
            }
        }

        // Batch up the metric datas and save to the db
        MetricHelpers.saveMetricDatas(metricsDatas);
        metricsDatas.clear();

        // Now that we have added all the metrics for this partner calculate the cumulative metrics.
        // Must be done here so we include the newest values
        for (MetricDataCalculationTracker tracker : MetricHelpers.getCumulativeValues(partner.Name, districts)) {

            if (tracker.getNoDataAdded()) {
                continue;
            }

            Decimal actualValue = tracker.getTotal();

            String districtName = '';
            Id districtId = null;
            District__c district = tracker.getDistrict();
            if (district != null) {
                districtName = district.Name;
                districtId = district.Id;
            }
            String key = MetricHelpers.createMetricLabelString(tracker.getMetricName(), districtName);
            key = key + '_cumulative';

            M_E_Metric_Data__c metric = currentQuarterMetricDatas.get(key);
            if (metric == null) {

                // Create the metric
                metric = MetricHelpers.createNewMetric(tracker.getMetricName(), ckwQuarterStartDate, actualValue, null, districtId, partner.Name, true);
            }
            else {

                // Update the existing metric
                metric.Actual_Value__c = actualValue;
            }
            if (metric != null) {
                metricsDatas.add(metric);
            }
        }

        MetricHelpers.saveMetricDatas(metricsDatas);
    }

    public static testMethod void testPartnerBatch() {

        Date startDate = MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0));
        Time startTime = time.newInstance(12, 30, 30, 0);
        DateTime submissionDateTime = datetime.newInstance(startDate.addDays(15), startTime);

        // Create a test Organisation
        Account org = Utils.createTestOrganisation('TestOrg1');
        database.insert(org);

        // Create a test survey
        Map<String, Survey__c> surveyMap = new Map<String, Survey__c>();
        Survey__c survey = Utils.createTestSurvey(org, 'Test1');
        survey.Account__c = org.Id;
        database.insert(survey);
        Survey__c surveySaved = [SELECT Name, Id FROM Survey__c WHERE Id = :survey.Id];
        surveyMap.put((String)surveySaved.Id, surveySaved);

        // Create two test districts.
        District__c district1 = Utils.createTestDistrict('Here');
        database.insert(district1);
        District__c district2 = Utils.createTestDistrict('There');
        database.insert(district2);

        //Create two test CKWs
        CKW__c ckw1 = Utils.createTestCkw(null, 'TestCKW1', true, district1.Id, 'Female');
        database.insert(ckw1);
        CKW__c ckw2 = Utils.createTestCkw(null, 'TestCKW2', true,district2.Id, 'Male');
        database.insert(ckw2);

        // Give the CKWs a poverty scorecard
        Poverty_Scorecard__c povertyScorecard1 = Utils.createTestPovertyScorecard('RICH', ckw1.Person__c, false, '');
        database.insert(povertyScorecard1);
        Poverty_Scorecard__c povertyScorecard2 = Utils.createTestPovertyScorecard('VERYPOOR', ckw2.Person__c, false, '');
        database.insert(povertyScorecard2);

        // Link the CKWs to the organisation;
        database.insert(Utils.creatTestPersonOrgLink(ckw1.Person__c, org.Id));
        database.insert(Utils.creatTestPersonOrgLink(ckw2.Person__c, org.Id));

        // Create a farmer or two
        Farmer__c farmer1 = Utils.createTestFarmer('OD99999', null, 'TestFarmer1', true, null, null);
        farmer1.Registered_By__c = ckw1.Person__c;
        database.insert(farmer1);

        Farmer__c farmer2 = Utils.createTestFarmer('OD99998', null, 'TestFarmer2', true, null, null);
        farmer2.Registered_By__c = ckw2.Person__c;
        database.insert(farmer2);

        // Create some test submissions
        Submission_Meta_Data__c sub1 = Utils.createTestSubmission(ckw1.Person__c, farmer1.Person__c, survey.Id, submissionDateTime, 'Sub1');
        database.insert(sub1);
        Submission_Meta_Data__c sub2 = Utils.createTestSubmission(ckw1.Person__c, farmer1.Person__c, survey.Id, submissionDateTime, 'Sub2');
        database.insert(sub2);
        Submission_Meta_Data__c sub3 = Utils.createTestSubmission(ckw2.Person__c, farmer2.Person__c, survey.Id, submissionDateTime, 'Sub3');
        database.insert(sub3);
        Submission_Meta_Data__c sub4 = Utils.createTestSubmission(ckw2.Person__c, farmer2.Person__c, survey.Id, submissionDateTime, 'Sub4');
        database.insert(sub4);

        // Add some answers to submissions
        List<Submission_Answer__c> answers = new List<Submission_Answer__c>();
        Submission_Answer__c answer1 = Utils.createTestSubmissionAnswer(sub1.Id, 'Boolean_Answer__c', 'yes', 'Select1', 'qestion1', 0);
        answers.add(answer1);
        Submission_Answer__c answer2 = Utils.createTestSubmissionAnswer(sub2.Id, 'Boolean_Answer__c', 'no', 'Select1', 'qestion1', 0);
        answers.add(answer2);
        Submission_Answer__c answer3 = Utils.createTestSubmissionAnswer(sub3.Id, 'Boolean_Answer__c', 'yes', 'Select1', 'qestion1', 0);
        answers.add(answer3);
        Submission_Answer__c answer4 = Utils.createTestSubmissionAnswer(sub4.Id, 'Boolean_Answer__c', 'no', 'Select1', 'qestion1', 0);
        answers.add(answer4);

        Submission_Answer__c answer5 = Utils.createTestSubmissionAnswer(sub1.Id, 'Integer_Answer__c', '3', 'Input', 'qestion2', 0);
        answers.add(answer5);
        Submission_Answer__c answer6 = Utils.createTestSubmissionAnswer(sub2.Id, 'Integer_Answer__c', '5', 'Input', 'qestion2', 0);
        answers.add(answer6);
        Submission_Answer__c answer7 = Utils.createTestSubmissionAnswer(sub3.Id, 'Integer_Answer__c', '2', 'Input', 'qestion2', 0);
        answers.add(answer7);
        Submission_Answer__c answer8 = Utils.createTestSubmissionAnswer(sub4.Id, 'Integer_Answer__c', '9', 'Input', 'qestion2', 0);
        answers.add(answer8);
        database.insert(answers);

        // Create some metrics
        List<M_E_Metric__c> metrics = new List<M_E_Metric__c>();
        M_E_Metric__c metric1 = Utils.createTestMetric(org, 'Average', 'Scale', true, 'TestBoolean');
        metrics.add(metric1);
        M_E_Metric__c metric2 = Utils.createTestMetric(org, 'Cumulative', 'Scale', true, 'TestSum');
        metrics.add(metric2);
        M_E_Metric__c metric3 = Utils.createTestMetric(org, 'Cumulative', 'Scale', true, 'total_workers');
        metrics.add(metric3);
        M_E_Metric__c metric4 = Utils.createTestMetric(org, 'Average', 'Scale', true, 'total_female_workers');
        metrics.add(metric4);
        M_E_Metric__c metric5 = Utils.createTestMetric(org, 'Average', 'Scale', true, 'total_poor_workers');
        metrics.add(metric5);
        M_E_Metric__c metric6 = Utils.createTestMetric(org, 'Cumulative', 'Scale', true, 'total_districts');
        metrics.add(metric6);
        database.insert(metrics);

        String query=
            'SELECT '                                                  +
                'Id, '                                                 +
                'District__r.Name, '                                   +
                'Current_Poverty_Scorecard__r.Poverty_Percentage__c, ' +
                'Gender__c '                                           +
            'FROM '                                                    +
                'Person__c '                                           +
            'WHERE '                                                   +
                'Id IN ('                                              +
                    'SELECT '                                          +
                        'Person__c '                                   +
                    'FROM '                                            +
                        'Person_Organisation_Association__c '          +
                    'WHERE '                                           +
                        'Organisation__r.Name = \''                    +
                            'TestOrg_TestOrg1'                         +
                        '\''                                           +
                ')';

        // Generate the metric calculation params
        Map<String, MetricDataCalculationParameters> parameters = new Map<String, MetricDataCalculationParameters>();
        List<String> groupList = new List<String>();
        groupList.add('District__r.Name');
        parameters.put(metric1.Name, new MetricDataCalculationParameters(metric1.Name, 'boolean', 'percentage', 'Boolean_Answer__c', surveySaved, groupList));
        parameters.put(metric2.Name, new MetricDataCalculationParameters(metric2.Name, 'input', 'average', 'Integer_Answer__c', surveySaved, groupList));

        // Run the batch
        Test.StartTest();
        PartnerMetrics partnerMetric = new PartnerMetrics(query, org, parameters, surveyMap);
        ID batchprocessid = Database.executeBatch(partnerMetric);
        Test.StopTest();
    }
}