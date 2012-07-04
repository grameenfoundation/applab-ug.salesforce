global class ScheduledDailyMetricsUpdate implements Schedulable {

    // CronExpression = Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    public static String cronExpression = '0 0 2 * * ?'; // run every day at 2am

    global void execute(SchedulableContext sc) {

        // Get the organisation
        Account partner = [
            SELECT
                Name
            FROM
                Account
            WHERE
                Name = 'Grameen Foundation'
            ];

        // Start Batch Apex job to update the farmer metrics.
        List<String> farmerMetricList = new List<String>();

        // The following metrics should only be calculated if this is not the first month of the quarter
        Boolean calculateRepeats = false;
        Integer month = date.today().month();
        if (month != 1 && month != 4 && month != 7 && month != 10) {
            calculateRepeats = true;
            farmerMetricList.add('percent_repeat_farmers');
            farmerMetricList.add('percent_repeat_farmers_female');
            farmerMetricList.add('percent_repeat_farmers_poor');
        }
        farmerMetricList.add('total_poor_farmers_reached');
        farmerMetricList.add('total_farmers_reached');
        farmerMetricList.add('total_female_farmers_reached');
        farmerMetricList.add('total_villages');
        farmerMetricList.add('average_quarterly_total_repeat_usage');
        farmerMetricList.add('average_quarterly_poor_repeat_usage');
        farmerMetricList.add('average_quarterly_woman_repeat_usage');
        String farmerQuery =
            'SELECT '                   +
                'Name, '                +
                'Id, '                  +
                'Person__c, '           +
                'Person__r.Gender__c, ' +
                'Person__r.Village__c ' +
            'FROM '                     +
                'Farmer__c '            +
            'WHERE '                    +
                'Name LIKE \'UA%\' '    +
                'OR Name LIKE \'UB%\'';
        ID batchprocessid = Database.executeBatch(new FarmerMetrics(farmerQuery, farmerMetricList, calculateRepeats, partner));

        // Start the Batch Apex for the CKW metrics
        String ckwQuery = 
            'SELECT '                                  +
                'Id, '                                 +
                'Active_Date__c, '                     +
                'Status__c, '                          +
                'Person__c '                           +
            'FROM '                                    +
                'CKW__c '                              +
            'WHERE '                                   +
                'Person__c NOT IN ('                   +
                    'SELECT '                          +
                        'Person__c '                   +
                    'FROM '                            +
                        'Person_Group_Association__c ' +
                    'WHERE '                           +
                        'Group__r.Name = \''           +
                            'Applab Staff'             +
                        '\''                           +
                ')';
        List<String> metricList = new List<String>();
        metricList.add('total_interactions_surveys');
        metricList.add('total_interactions_searches');
        metricList.add('total_interactions_channels');
        metricList.add('percent_ckws_high_performance');
        metricList.add('total_info_services_offered');
        metricList.add('total_ckws');
        metricList.add('percent_poor_ckws');
        metricList.add('percent_woman_ckws');
        ID ckwBatchProcessId = Database.executeBatch(new CKWMetrics(ckwQuery, metricList, false, partner));

        Account naads = [
            SELECT
                Name
            FROM
                Account
            WHERE
                Name = 'NAADS'
            ];

        String naadsQuery = 
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
                            'NAADS'                                    +
                        '\''                                           +
                ') '                                                   +
                'AND Id NOT IN (SELECT Person__c FROM Farmer__c)';

        Map<String, Survey__c> surveyMap = new Map<String, Survey__c>();
        Survey__c[] surveys = [
            SELECT
                Id,
                Name
            FROM
                Survey__c
            WHERE
                Account__r.Name = 'NAADS'];
        for (Survey__c survey : surveys ) {
            surveyMap.put(survey.Id, survey);
        }
        ID naadsBatchProcessId = Database.executeBatch(new PartnerMetrics(naadsQuery, naads, NaadsMAndEDashboardParameters.getParameters(false), surveyMap));
    }
}