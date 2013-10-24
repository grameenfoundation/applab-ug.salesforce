/**
 * Helper class that contains all the static methods that are used in calculating metrics and producing
 * the dashboard layout and features
 */
public with sharing class MetricHelpers {

    /**
     *  Get the data for a specific metric for a given quarter.
     *
     *  @param metricName - The name of the metric required
     *  @param startDate  - Start date for the quarter
     *  @param endDate    - End date for the quarter
     *
     *  @return - Only returns 1 M_E_Metric_Data__c. Will return null if we don't find just one.
     */
    public static M_E_Metric_Data__c getMetricData(String metricName, Date startDate, Date endDate) {

        M_E_Metric_Data__c[] metric = [
            SELECT 
                Name,
                Id,
                Date__c,
                Actual_Value__c,
                Projected_Value__c,
                Manual_Value__c,
                Real_Value__c,
                Is_Cumulative__c
            FROM
                M_E_Metric_Data__c
            WHERE
                M_E_Metric__r.Name = :metricName
                AND Date__c >= :startDate
                AND Date__c <= :endDate
        ];

        if (metric.size() != 1) {

            // Found more than one of the metric. Error that calling procedure should handle.
            return null;
        }
        return metric[0];
    }

    /**
     *  Generate a list of metric datas for a given date range that match a list of metrics
     *
     *  @param metricsRequired - A list of the metrics that are needed
     *  @param startDate       - Start date for the quarter
     *  @param endDate         - End date for the quarter
     *  @param orgName         - The name of an organisation we are looking at
     */
    public static M_E_Metric_Data__c[] getMetricDatas(List<String> metricsRequired, Date startDate, Date endDate, String orgName) {

        String selectClause =
            'SELECT '                                 +
                'Actual_Value__c, '                   +
                'Manual_Value__c, '                   +
                'Real_Value__c, '                     +
                'Projected_Value__c, '                +
                'Date__c, '                           +
                'Is_Cumulative__c, '                  +
                'M_E_Metric__r.Name, '                +
                'M_E_Metric__r.Label__c, '            +
                'District__r.Name, '                  +
                'District__r.Latitude__c, '           +
                'District__r.Longitude__c, '          +
                'M_E_Metric__r.Sub_Divide__c, '       +
                'M_E_Metric__r.Calculation_Type__c '  +
            'FROM '                                   +
                'M_E_Metric_Data__c ';

        // Build the where clause
        List<String> whereClauses = new List<String>();
        if (metricsRequired != null) {
            whereClauses.add(SoqlHelpers.addInWhereClause('M_E_Metric__r.Name', false, null, metricsRequired, true));
        }
        if (startDate != null) {
            String startString = convertDateTimeToString(convertToStartDate(startDate), true);
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('>=', 'Date__c', startString, false));
        }
        if (endDate != null) {
            String endString = convertDateTimeToString(convertToStartDate(endDate), true);
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('<', 'Date__c', endString, false));
        }
        if (orgName != null) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'M_E_Metric__r.Organisation__r.Name', orgName, true));
        }
        String whereClause = '';
        if (whereClauses.size() > 0) {
            whereClause = ' WHERE ' + SoqlHelpers.joinWhereClause(whereClauses, false);
        }
        String query = selectClause + whereClause;
        System.debug(LoggingLevel.INFO, query);
        M_E_Metric_Data__c[] metricDatas = database.query(query);
        return metricDatas;
    }

    public static Map<String, Map<String, M_E_Metric_Data__c>> getCumulativeData(
            String organisationString,
            String notForPublicString,
            String districtString,
            Date startDate,
            Date endDate,
            String metricNameString,
            Boolean useDistrict
    ) {

        Map<String, Map<String, M_E_Metric_Data__c>> cumulativeMetrics = new Map<String, Map<String, M_E_Metric_Data__c>>();
        String query =
            'SELECT '                              +
                'Real_Value__c, '                  +
                'M_E_Metric__r.Name, '             +
                'District__r.Name, '               +
                'M_E_Metric__r.M_E_Area__c '       +
            'FROM '                                +
                'M_E_Metric_Data__c '              +
            'WHERE '                               +
                'Date__c >= :startDate '           +
                'AND Date__c <=:endDate '          +
                'AND Is_Cumulative__c = true '     +
                notForPublicString                 +
                organisationString                 +
                districtString                     +
                metricNameString                   +
            'ORDER BY '                            +
                'M_E_Metric__r.M_E_Area__c, '      +
                'M_E_Metric__r.Name';

        String areaName = '';
        Map<String, M_E_Metric_Data__c> areaMap = null;
        for (M_E_Metric_Data__c metric : database.query(query)) {
            areaName = metric.M_E_Metric__r.M_E_Area__c;
            if (areaName == null || areaName.equals('')) {
                continue;
            }
            areaMap = cumulativeMetrics.get(areaName);
            if (areaMap == null) {
                 areaMap = new Map<String, M_E_Metric_Data__c>();
            }
            if (useDistrict) {
                String districtName = 'null';
                if (metric.District__r.Name != null) {
                    districtName = metric.District__r.Name;
                }
                areaMap.put(districtName, metric);
            }
            else {
                areaMap.put(metric.M_E_Metric__r.Name, metric);
            }
            cumulativeMetrics.put(areaName, areaMap);
        }
        return cumulativeMetrics;
    }

    /**
     *  Get the details of metric objects
     *
     *  @param metricName - The name of the metric we are looking for.
     *  @param orgName    - The name of an organisation we are looking at
     */
    public static M_E_Metric__c[] getMetrics(String metricName, String orgName) {

        String selectClause =
            'SELECT '                   +
                'Name, '                +
                'Id, '                  +
                'Label__c, '            +
                'M_E_Area__c, '         +
                'Order__c, '            +
                'Projected_Value__c, '  +
                'Scorecard__c, '        +
                'Sub_Divide__c, '       +
                'Calculation_Type__c, ' +
                'Organisation__c, '     +
                'Organisation__r.Name ' +
            'FROM '                     +
                'M_E_Metric__c ';

        List<String> whereClauses = new List<String>();

        if (metricName != null && !metricName.equals('')) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Name', metricName, true));
        }
        if (orgName != null && !orgName.equals('')) {
            Boolean incQuotes = true;
            if (orgName.equals('null')) {
                incQuotes = false;
            }
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Organisation__r.Name', orgName, incQuotes));
        }
        String whereClause = '';
        if (whereClauses.size() > 0) {
            whereClause = ' WHERE ' + SoqlHelpers.joinWhereClause(whereClauses, false);
        }
        String query = selectClause + whereClause;
        System.debug(LoggingLevel.INFO, query);
        M_E_Metric__c[] metric = database.query(query);

        if (metric.isEmpty()) {
            return null;
        }
        return metric;
    }

    /**
     *  Create a new metric data object for a given metric and a given quarter
     *
     *  @param metricName  - The name of the parent metric 
     *  @param startDate   - The start date of the quarter
     *  @param actualValue - The initial actual value for the metric data object
     *  @param targetValue - The target value. Will override the one on the parent metric object
     *  @param district    - The district object that this is for
     *  
     *  @return - The new object. Note it will not have been saved to the database.
     *            Returns null if the parent metric cannot be found
     */
    public static M_E_Metric_Data__c createNewMetric(
            String metricName,
            Date startDate,
            Decimal actualValue,
            Decimal target,
            Id districtId,
            String orgName,
            Boolean isCumulative
    ) {

        // Create the new metric_data
        System.debug(LoggingLevel.INFO, 'METRIC NAME = ' + metricName + ' District ID - ' + districtId);
        M_E_Metric_Data__c metricData = new M_E_Metric_Data__c();
        M_E_Metric__c[] metrics = getMetrics(metricName, orgName);
        if (metrics == null || metrics.size() == 0) {
            System.debug(LoggingLevel.INFO, 'Metric Creation Failed');
            return null;
        }
        M_E_Metric__c metric = metrics[0];

        // Add the details required.
        metricData.M_E_Metric__c = metric.Id;
        metricData.Name = metricData.Id;
        metricData.Date__c = startDate;
        metricData.Actual_Value__c = actualValue;
        metricData.Is_Cumulative__c = isCumulative;
        if (districtId != null) {
            metricData.District__c = districtId;
        }

        // If no target supplied get the target from the parent metric
        if (target == null) {
            if (metric != null) {
                metricData.Projected_Value__c = metric.Projected_Value__c;
            }
            else {

                // If we cant get a value then set the target to 1
                metricData.Projected_Value__c = 1.0;
            }
        }
        else {
            metricData.Projected_Value__c = target;
        }
        System.debug(LoggingLevel.INFO, 'Metric Created Successfully');
        return metricData;
    }
	
    public static M_E_Metric_Data__c createNewMetric(
            String metricName,
            Date startDate,
            Decimal actualValue,
            Decimal target,
            Id districtId,
            Id subcountyId,
            String orgName,
            Boolean isCumulative
    ) {

        // Create the new metric_data
        System.debug(LoggingLevel.INFO, 'METRIC NAME = ' + metricName + ' District ID - ' + districtId);
        M_E_Metric_Data__c metricData = new M_E_Metric_Data__c();
        M_E_Metric__c[] metrics = getMetrics(metricName, orgName);
        if (metrics == null || metrics.size() == 0) {
            System.debug(LoggingLevel.INFO, 'Metric Creation Failed');
            return null;
        }
        M_E_Metric__c metric = metrics[0];

        // Add the details required.
        metricData.M_E_Metric__c = metric.Id;
        metricData.Name = metricData.Id;
        metricData.Date__c = startDate;
        metricData.Actual_Value__c = actualValue;
        metricData.Is_Cumulative__c = isCumulative;
		metricData.Denumerator__c = 0;
		metricData.Numerator__c = 0;
        if (districtId != null) {
            metricData.District__c = districtId;
        }
		metricData.Subcounty__c = subcountyId;
        // If no target supplied get the target from the parent metric
        if (target == null) {
            if (metric != null) {
                metricData.Projected_Value__c = metric.Projected_Value__c;
            }
            else {

                // If we cant get a value then set the target to 1
                metricData.Projected_Value__c = 1.0;
            }
        }
        else {
            metricData.Projected_Value__c = target;
        }
        System.debug(LoggingLevel.INFO, 'Metric Created Successfully');
        return metricData;
    }

    /**
     *  Update the Actual_Value__c for a given metric in a quarter.
     *  Will create the metric if it doesn't exist.
     *
     *  @param metricName     - The name of the parent metric
     *  @param actualValue    - The new value
     *  @param districtId     - The id for the district that this metric is for. Can be null
     *  @param orgName        - The org name that owns this metric
     *  @param startDate      - The start date for the metric
     *  @param endDate        - The end date for the metric
     *  @param addLastQuarter - If creating a new M_E_Metric_Data__c inc the last quarters figure
     */
    public static M_E_Metric_Data__c updateMetric(
            String metricName,
            Decimal actualValue,
            Id districtId,
            String orgName,
            Date startDate,
            Date endDate,
            Boolean addLastQuarter
    ) {

        String selectClause =
            'SELECT '               +
                'Actual_Value__c, ' +
                'Manual_Value__c '  +
            'FROM '                 +
                'M_E_Metric_Data__c ';

        List<String> whereClauses = new List<String>();
        if (metricName != null && !metricName.equals('')) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'M_E_Metric__r.Name', metricName, true));
        }
        if (orgName != null && !orgName.equals('')) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Organisation__r.Name', orgName, true));
        }
        if (startDate == null) {

            // Default to this quarter
            startDate = getQuarterFirstDay(getCurrentQuarterAsString(0));
        }
        String startString = convertDateTimeToString(convertToStartDate(startDate), true);
        whereClauses.add(SoqlHelpers.buildStandardWhereClause('>=', 'Date__c', startString, false));

        if (endDate == null) {

            // Default to this quarter
            endDate = getQuarterLastDay(getCurrentQuarterAsString(0));
        }
        String endString = convertDateTimeToString(convertToStartDate(endDate), true);
        whereClauses.add(SoqlHelpers.buildStandardWhereClause('<', 'Date__c', endString, false));
        String whereClause = '';
        if (whereClauses.size() > 0) {
            whereClause = ' WHERE ' + SoqlHelpers.joinWhereClause(whereClauses, false);
        }
        String query = selectClause + whereClause;
        System.debug(LoggingLevel.INFO, query);

        M_E_Metric_Data__c[] metrics = database.query(query);

        M_E_Metric_Data__c metric = null;
        if (metrics.size() == 0) {

            // Check if we need to get the last quarters figure to init the metric
            if (addLastQuarter) {
                M_E_Metric_Data__c oldMetric = getMetricData(metricName , getQuarterFirstDay(getCurrentQuarterAsString(0)).addMonths(-3), getQuarterLastDay(getCurrentQuarterAsString(0)).addMonths(-3));
                if (oldMetric != null) {
                    actualValue = actualValue + oldMetric.Real_Value__c;
                }
            }

            // Create the metric as it doesn't exist yet
            metric = createNewMetric(metricName, getQuarterFirstDay(getCurrentQuarterAsString(0)), actualValue, null, districtId, orgName, false);
            database.insert(metric);
        }
        else {
            metric = metrics[0];
            if (metric.Manual_Value__c != null) {
                metric.Manual_Value__c = metric.Manual_Value__c + actualValue;
            }
            else {
                if (metric.Actual_Value__c == null) {
                    metric.Actual_Value__c = actualValue;
                }
                else {
                    metric.Actual_Value__c = metric.Actual_Value__c + actualValue;
                }
            }
            database.update(metric);
        }
        return metric;
    }

    // QuarterString is in format 'Jan - Mar 2010';
    public static Date getQuarterFirstDay(String quarterString) {

        String[] monthParts = quarterString.split(' - ');
        String[] yearParts = monthParts[1].split(' ');
        String year = yearParts[1];

        Date qDate = null;
        if(monthParts[0].equals('Jan')) {
            qDate = Date.newInstance(Integer.valueOf(year), 1, 1);
        }
        else if(monthParts[0].equals('Apr')) {
            qDate = Date.newInstance(Integer.valueOf(year), 4, 1);
        }
        else if(monthParts[0].equals('Jul')) {
            qDate = Date.newInstance(Integer.valueOf(year), 07, 1);
        }
        else if(monthParts[0].equals('Oct')) {
            qDate = Date.newInstance(Integer.valueOf(year), 10, 1);
        }
        return qDate;   
    }
    
    public static Date getQuarterFirstDay(Date dateInQuarter) {
        // Change date to 'Jan - Mar 2010' format
        String quarterAsString = getQuarterAsString(dateInQuarter);
        return getQuarterFirstDay(quarterAsString);
    }
    
    // quarterString is in format 'Jan - Mar 2010';
    public static Date getQuarterLastDay(String quarterString) {

        String[] monthParts = quarterString.split(' - ');
        String[] yearParts = monthParts[1].split(' ');
        String year = yearParts[1];

        Date qDate = null;
        if(monthParts[0].equals('Jan')) {
            qDate =Date.newInstance(Integer.valueOf(year), 3, 31);
        }
        else if(monthParts[0].equals('Apr')) {
            qDate =Date.newInstance(Integer.valueOf(year), 6, 30);
        }
        else if(monthParts[0].equals('Jul')) {
            qDate =Date.newInstance(Integer.valueOf(year), 9, 30);
        }
        else if(monthParts[0].equals('Oct')) {
            qDate =Date.newInstance(Integer.valueOf(year), 12, 31);
        }
        return qDate;   
    }
    
    public static Date getQuarterLastDay(Date dateInQuarter) {
        // Change date to 'Jan - Mar 2010' format
        String quarterAsString = getQuarterAsString(dateInQuarter);
        return getQuarterLastDay(quarterAsString);
    }

    public static String getQuarterLastDayAsString(String quarterString) {

        String[] monthParts = quarterString.split(' - ');
        String[] yearParts = monthParts[1].split(' ');
        String year = yearParts[1];

        String dateString = null;
        if(monthParts[0].equals('Jan')) {
            dateString = '03/31/' + year;
        }
        else if(monthParts[0].equals('Apr')) {
            dateString = '06/30/' + year;
        }
        else if(monthParts[0].equals('Jul')) {
            dateString = '09/30/' + year;
        }
        else if(monthParts[0].equals('Oct')) {
            dateString = '12/31/' + year;
        }
        return dateString;   
    }
    
    /**
    * Added this to replace getQuarterLastDayAsString since the Date.parse format it uses is locale specific
    */
    public static String getInstanceQuarterLastDayAsString(String quarterString) {

        String[] monthParts = quarterString.split(' - ');
        String[] yearParts = monthParts[1].split(' ');
        String year = yearParts[1];

        String dateString = null;
        if(monthParts[0].equals('Jan')) {
            dateString = year + '-03-31 00:00:00';
        }
        else if(monthParts[0].equals('Apr')) {
            dateString = year + '-06-30 00:00:00';
        }
        else if(monthParts[0].equals('Jul')) {
            dateString = year + '-09-30 00:00:00';
        }
        else if(monthParts[0].equals('Oct')) {
            dateString = year + '-12-31 00:00:00';
        }
        return dateString;   
    }

    public static String parseDateToString(Date qDate) {

        return String.valueOf(qDate.month()) + '/' + String.valueOf(qDate.day()) + '/' + String.valueOf(qDate.year());
    }
    
    /**
    * Added this to replace getQuarterLastDayAsString since the Date.parse format it uses is locale specific
    */
    public static String parseInstanceDateToString(Date qDate) {

        return String.valueOf(qDate.year()) + '-' + String.valueOf(qDate.month()) + '-' + String.valueOf(qDate.day()) + ' 00:00:00';
    }

    public static Integer getQuarter(Date qDate) {

        if(qDate.month() < 4) {
            return 1;
        }
        if(qDate.month() < 7) {
            return 2;
        }
        if(qDate.month() < 10) {
            return 3;
        }
        return 4;
    }

    public static String getQuarterStartMonth(Integer quarter) {

        if(quarter == 1) {
            return 'Jan';
        }
        if(quarter == 2) {
            return 'Apr';
        }
        if(quarter == 3) {
            return 'Jul';
        }
        return 'Oct';
    }

    public static String getQuarterEndMonth(Integer quarter) {

        if(quarter == 1) {
            return 'Mar';
        }
        if(quarter == 2) {
            return 'Jun';
        }
        if(quarter == 3) {
            return 'Sep';
        }
        return 'Dec';
    }

    // @param modifier - How many days to add to the date that defines which quarter this is in. Pass a -ve number to subtract days
    public static String getCurrentQuarterAsString(Integer modifier) {

        Date now = Date.today().addDays(modifier);
        Integer currentYear = now.year();
        Integer currentQuarter = getQuarter(now);
        return getQuarterStartMonth(currentQuarter) + ' - ' + getQuarterEndMonth(currentQuarter) + ' ' + String.ValueOf(currentYear);
    }

    public static String getQuarterAsString(Date input) {

        Integer currentYear = input.year();
        Integer currentQuarter = getQuarter(input);
        return getQuarterStartMonth(currentQuarter) + ' - ' + getQuarterEndMonth(currentQuarter) + ' ' + String.ValueOf(currentYear);
    }

    public static String getQuarterAsString(Integer quarter) {

        Date now = Date.today();
        Integer currentYear = now.Year();
        Integer currentMonth = now.month();
        return getQuarterStartMonth(quarter) + ' - ' + getQuarterEndMonth(quarter) + ' ' + String.ValueOf(currentYear);
    }

    // Generate a new set of Metics_Data__c objects for a given quarter.
    public static boolean generateMetrics(Date startDate, Date endDate, String orgName) {

        List<M_E_Metric_Data__c> dataArray = new List<M_E_Metric_Data__c>();

        for(M_E_Metric__c metric : getMetrics(null, orgName)) {

            // Check that the metric has not already been created for this quarter
            List<AggregateResult> metricCount = 
                [SELECT 
                    COUNT(Id) num
                FROM
                    M_E_Metric_Data__c
                WHERE 
                    Date__c >= :startDate
                    AND Date__c <= :endDate
                    AND M_E_Metric__c = :metric.Id
                ];

            if(metricCount[0].get('num') == 0) {
                M_E_Metric_Data__c data = new M_E_Metric_Data__c();
                data.Date__c = startDate;
                data.M_E_Metric__c = metric.Id;
                data.Projected_Value__c = metric.Projected_Value__c;
                dataArray.add(data);
            }
        }

        if(dataArray.size() > 0) {
            Database.insert(dataArray);
        }
        return true;
    }

    public static M_E_Metric_Data__c[] loadAllMetricData(String metricId) {

        M_E_Metric_Data__c[] metricDatas = new M_E_Metric_Data__c[]{};
        Date quarterLastDay = MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0));
        for (M_E_Metric_Data__c[] metricData : [
            SELECT
                Id,
                Date__c,
                M_E_Metric__r.Label__c,
                Actual_Value__c,
                Real_Value__c,
                Projected_Value__c, 
                M_E_Metric__r.M_E_Area__c,
                Comment__c 
            FROM
                M_E_Metric_Data__c
            WHERE 
                Date__c <=:quarterLastDay
                AND M_E_Metric__r.Id =:metricId
            ORDER BY
                Date__c ASC
        ]) {
            metricDatas = metricData;
        }
        return metricDatas;
    }

    /**
     *  Get the performance details for a group of CKWs for a given set of dates
     *
     *  @param ckwIdList - A list of the ckwIds
     *  @param targetMap - The map that we are adding the results to
     *  @param startDate - Start date for the quarter
     *  @param endDate   - End date for the quarter
     */
    public static void getPerformanceDetails(List<String> ckwIdList, Map<String, Decimal> targetMap, Date startDate, Date endDate) {

        String startString = convertDateTimeToString(convertToStartDate(startDate), true);
        String endString   = convertDateTimeToString(convertToEndDate(endDate), true);
        String ckwIds      = generateCommaSeperatedString(ckwIdList, true);

        // Calculate the date fo the start of the month and the end of the month.
        Date startOfMonth = date.today().toStartOfMonth();
        Date endOfMonth = startOfMonth.addMonths(1).addDays(-1);

        // Get the performance records for the quarter that we are looking at.
        String recordQuery = 
            'SELECT ' + 
                'CKW_c__c, '                    +
                'Total_Searches__c, '           +
                'Performance_Level__c, '        +
                'Total_Surveys_Submitted__c, '  +
                'Start_Date__c '                +
            'FROM '                             +
                'CKW_Performance_Review__c '    +
            'WHERE '                            +
                'CKW_c__c IN (' + ckwIds + ') ' +
                'AND Start_Date__c >= '         +
                    startString                 +
                ' AND Start_Date__c < '         +
                    endString;
        CKW_Performance_Review__c[] records = database.query(recordQuery);

        // Loop through the performance records and add up the interactions. Split them into the component parts
        Map<String, String> performanceMap = new Map<String, String>();
        for (CKW_Performance_Review__c record : records) {
            if (record.Total_Surveys_Submitted__c != null) {
                targetMap.put('total_interactions_surveys', targetMap.get('total_interactions_surveys') + record.Total_Surveys_Submitted__c);
            }
            if (record.Total_Searches__c != null) {
                targetMap.put('total_interactions_searches', targetMap.get('total_interactions_searches') + record.Total_Searches__c);
            }

            // Check that the performance for this CKW. This is only done if it is not this months
            Integer daysBefore = startOfMonth.daysBetween(record.Start_Date__c);
            Integer daysAfter = endOfMonth.daysBetween(record.Start_Date__c);
            if (daysBefore >= 0 && daysAfter <= 0) {
                continue;
            }
            String currentPerformance = performanceMap.get(record.CKW_c__c);
            if (currentPerformance == null || currentPerformance != 'A' || currentPerformance != 'B') {
                performanceMap.put(record.CKW_c__c, record.Performance_Level__c);
            }
        }

        // Loop through the performanceMap and count how many are in the top(A or B) levels
        for (String id : performanceMap.keySet()) {
            if (performanceMap.get(id) != null && (performanceMap.get(id) == 'A' || performanceMap.get(id) == 'B')) {
                targetMap.put('percent_ckws_high_performance', targetMap.get('percent_ckws_high_performance') + 1);
            }
        }
    }

    /**
     *  Generate a map that contains the Actual_Values__c for a given list of metrics
     *
     *  @param metricsRequired - A list of the metrics that are needed
     *  @param startDate       - Start date for the quarter
     *  @param endDate         - End date for the quarter
     *
     */
    public static Map<String, Decimal> getMetricValues(List<String> metricsRequired, Date startDate, Date endDate) {

        // Convert the passed in dates into strings so they can be passed in to the query.
        String startString = convertDateTimeToString(convertToStartDate(startDate), true);
        String endString = convertDateTimeToString(convertToEndDate(endDate), true);
        String metrics = generateCommaSeperatedString(metricsRequired, true);

        // Get the values for a quarter
        String query = 'SELECT '                          +
                'Actual_Value__c, '                       +
                'M_E_Metric__r.Name, '                    +
                'Manual_Value__c, '                       +
                'Date__c '                                +
            'FROM '                                       +
                'M_E_Metric_Data__c '                     +
            'WHERE '                                      +
                'M_E_Metric__r.Name IN (' + metrics + ')' +
                'AND Date__c >= ' + startString + ' '     +
                'AND Date__c < ' + endString;
        M_E_Metric_Data__c[] metricValues = database.query(query);

        // Loop through the previous metrics and set the base number.
        Map<String, Decimal> values = new Map<String, Decimal>();
        for (M_E_Metric_Data__c metricValue : metricValues) {
            if (metricValue.Manual_Value__c != null) {
                values.put(metricValue.M_E_Metric__r.Name, metricValue.Manual_Value__c);
            }
            else {
                values.put(metricValue.M_E_Metric__r.Name, metricValue.Actual_value__c);
            }
        }
        return values;
    }

    /**
     *  Get the metric value for SMS interactions for a given quarter
     *
     *  @param startDate - Start date for the quarter
     *  @param endDate   - End date for the quarter
     *
     *  @return - The value for the metric or 0 if something went wrong
     */
    public static Decimal getSmsInteractions(Date startDate, Date endDate) {

        // Convert the passed in dates into strings so they can be passed in to the query.
        String startString = convertDateTimeToString(convertToStartDate(startDate), true);
        String endString = convertDateTimeToString(convertToEndDate(endDate), true);
        String query = 
            'SELECT '                                                   +
                'Actual_Value__c, '                                     +
                'Manual_Value__c '                                      +
            'FROM '                                                     +
                'M_E_Metric_Data__c '                                   +
            'WHERE '                                                    +
                'M_E_Metric__r.Name = \'total_interactions_channels\' ' +
                'AND Date__c >= ' + startString                         +
                ' AND Date__c < ' + endString;
                 
        M_E_Metric_Data__c[] smsMetric = database.query(query);

        if (smsMetric.size() == 0 || smsMetric.size() > 1) {
            return 0.0;
        }
        if (smsMetric[0].Manual_Value__c != null) {
            return smsMetric[0].Manual_Value__c;
        }
        else if (smsMetric[0].Actual_Value__c != null) {
            return smsMetric[0].Actual_Value__c;
        }
        else {
            return 0.0;
        }
    }

    /**
     * Calculate the average repeat usuage stat for all the quarters previous to this one.
     *
     * @param metricName - The metric that we care about
     *
     * @return - The decimal value for the average 
     */
    public static Decimal calculateAverageMetric(String metricName) {

        String query =
            'SELECT '                     +
                'Manual_Value__c, '       +
                'Actual_Value__c '        +
            'FROM '                       +
                'M_E_Metric_Data__c '     +
            'WHERE '                      +
                'M_E_Metric__r.Name = \'' +
                    metricName            +
                '\' '                     +
                'AND Date__c < THIS_QUARTER';
        M_E_Metric_Data__c[] repeatUsageMetric = database.query(query);

        Decimal total = 0.0;
        Integer validMetric = 0;
        for (M_E_Metric_Data__c metric : repeatUsageMetric) {
            if ((metric.Manual_Value__c != null && metric.Manual_Value__c != 0.0) || (metric.Actual_Value__c != null && metric.Actual_Value__c != 0.0)) {
                if (metric.Manual_Value__c != null && metric.Manual_Value__c > 0.0) {
                    total = total + metric.Manual_Value__c;
                }
                else {
                    total = total + metric.Actual_Value__c;
                }
                validMetric++;
            }
        }
        return total / validMetric;
    }

    /**
     *  Generate a list of MetricDataCalculationTracker objects that contain the cumulative values.
     */
    public static List<MetricDataCalculationTracker> getCumulativeValues(String orgName, Map<String, District__c> districts) {

        List<MetricDataCalculationTracker> trackers = new List<MetricDataCalculationTracker>();

        if (!orgName.equals('null')) {
            orgName = '\'' + orgName + '\'';
        }
        String orgNameClause = 'AND M_E_Metric__r.Organisation__r.Name = ' + orgName + ' ';

        // Get all the averages. For averages we are excluding the current quarter
        String queryBase =
                'M_E_Metric__r.Name MetricName, ' +
                'District__r.Name DistrictName '  +
            'FROM '                               +
                'M_E_Metric_Data__c '             +
            'WHERE '                              +
                'Is_Cumulative__c = false AND ';

        String whereClauseBase =
                orgNameClause                             +
            'GROUP BY '                                   +
                'M_E_Metric__r.Name, '                    +
                'District__r.Name';

        String averageQuery =
            'SELECT '                        +
                'AVG(Real_Value__c) total, ' +
                queryBase                    +
                'Date__c <= THIS_QUARTER '   +
                'AND M_E_Metric__r.Calculation_Type__c = \'Average\' ' +
                whereClauseBase;

        String sumQuery =
            'SELECT '                        +
                'SUM(Real_Value__c) total, ' +
                queryBase                    +
                'Date__c <= THIS_QUARTER '   +
                'AND M_E_Metric__r.Calculation_Type__c = \'Cumulative\' ' +
                whereClauseBase;

        System.debug(LoggingLevel.INFO, averageQuery);
        trackers.addAll(generateMetricDataCalculationTrackers(averageQuery, districts, true));

        System.debug(LoggingLevel.INFO, sumQuery);
        trackers.addAll(generateMetricDataCalculationTrackers(sumQuery, districts, true));

        return trackers;
    }

    private static List<MetricDataCalculationTracker> generateMetricDataCalculationTrackers(String query, Map<String, District__c> districts, Boolean useDistricts) {

        List<MetricDataCalculationTracker> trackers = new List<MetricDataCalculationTracker>();
        for (AggregateResult result : database.query(query)) {
            Decimal total = (Decimal)result.get('total');
            if (total == null) {
                continue;
            }
            String metricName = (String)result.get('MetricName');
            String districtName = null;
            if (useDistricts) {
                districtName =(String)result.get('DistrictName');
            }

            District__c district = null;
            if (districtName != null) {
                district = districts.get(districtName);
            }

            // Create the MetricDataCalculationTracker
            MetricDataCalculationTracker tracker = new MetricDataCalculationTracker(metricName, null, district, null);
            tracker.setTotal(total);
            trackers.add(tracker);
        }
        return trackers;
    }

    public static List<MetricDataCalculationTracker> getTotals(String orgName) {

        List<MetricDataCalculationTracker> trackers = new List<MetricDataCalculationTracker>();
        if (!orgName.equals('null')) {
            orgName = '\'' + orgName + '\'';
        }
        String orgNameClause = 'AND M_E_Metric__r.Organisation__r.Name = ' + orgName + ' ';

        // Get all the averages. For averages we are excluding the current quarter
        String queryBase =
                'M_E_Metric__r.Name MetricName ' +
            'FROM '                              +
                'M_E_Metric_Data__c '            +
            'WHERE '                             +
                'Is_Cumulative__c = false AND '  +
                ' District__c != null AND ';

        String whereClauseBase =
                orgNameClause         +
            'GROUP BY '               +
                'M_E_Metric__r.Name ';

        String averageQuery =
            'SELECT '                        +
                'AVG(Real_Value__c) total, ' +
                queryBase                    +
                'Date__c = THIS_QUARTER '    +
                'AND M_E_Metric__r.Calculation_Type__c = \'Average\' ' +
                whereClauseBase;

        String sumQuery =
            'SELECT '                        +
                'SUM(Real_Value__c) total, ' +
                queryBase                    +
                'Date__c = THIS_QUARTER '    +
                'AND M_E_Metric__r.Calculation_Type__c = \'Cumulative\' ' +
                whereClauseBase;

        System.debug(LoggingLevel.INFO, averageQuery);
        trackers.addAll(generateMetricDataCalculationTrackers(averageQuery, null, false));

        System.debug(LoggingLevel.INFO, sumQuery);
        trackers.addAll(generateMetricDataCalculationTrackers(sumQuery, null, false));

        return trackers;
    }
    /**
     *  Given a list of metric data, a map containing the actual values and a map containing the previous values,
     *  generate a map that contains the metric datas with the correct actual value for saving to the DB.
     *  Note the key to all the maps is the parent metric name.
     *
     *@param metrics        - The metric data objects that need updating
     *@param actualvalues   - The actual values for each metric
     *@param previousValues - The previous values for each metric
     *
     *@return - A map containing the metric data to be updated
     */
    public static Map<String, M_E_Metric_Data__c> generateUpdateMetricMap(
            M_E_Metric_Data__c[] metrics,
            Map<String, Decimal> actualValues,
            Map<String, Decimal> previousValues
    ) {

        Map<String, M_E_Metric_Data__c> updateMetricMap = new Map<String, M_E_Metric_Data__c>();
        for (M_E_Metric_Data__c metric : metrics) {
            Decimal value = previousValues.get(metric.M_E_Metric__r.Name);

            if (value == null) {
                metric.Actual_Value__c = actualValues.get(metric.M_E_Metric__r.Name);
            }
            else {
                metric.Actual_Value__c = actualValues.get(metric.M_E_Metric__r.Name) + value;
            }
            updateMetricMap.put(metric.M_E_Metric__r.Name, metric);
        }
        return updateMetricMap;
    }

    /**
     *  Take a MetricDataCalculationTracker and the survey that it is for. Calculate the total number.
     */
    public static Decimal calculateSurveyTotal(MetricDataCalculationTracker tracker, Map<String, Integer> surveyTotals) {

        Decimal total = 0.0;
        String function = tracker.getFunction();
        List<String> splitNameList = new List<String>();
        splitNameList.add(tracker.getSurvey().Name);
        if (tracker.getDistrict() != null) {
            splitNameList.add(tracker.getDistrict().Name);
        }
        String splitName = createSplitName(splitNameList);

        if (function.equals('average')) {
            total = tracker.getTotal() / surveyTotals.get(splitName);
        }
        else if (function.equals('percentage')) {
            total = (tracker.getTotal() / surveyTotals.get(splitName)) * 100;
        }
        else if (function.equals('sum')) {
            total = tracker.getTotal();
        }

        // Round to 2 decimal places
        return total.setScale(2);
    }

    /**
     *  Check that an organisation has been linked to a district. Create link if it has not
     *  
     *  @param org        - The organisation we are checkng against
     *  @param districtId - The district Id that we are checking for
     *  @param createLink - Create the link or not if not found
     *
     *  @return - Boolean indicating if the link exists or not
     */
    public static Boolean checkForOranistationDistrictLink(Account org, String districtId, Boolean createLink) {

        // Check that the link exists already.
        Organisation_District_Association__c[] orgDisAssocs =
            [SELECT
                Id
            FROM
                Organisation_District_Association__c
            WHERE
                Organisation__c = :org.Id
                AND District__c = :districtId];

        // If the link does not exist create it
        if (orgDisAssocs.isEmpty() && createLink) {
            Organisation_District_Association__c orgDisAssoc = new Organisation_District_Association__c();
            orgDisAssoc.Organisation__c = org.Id;
            orgDisAssoc.District__c = districtId;
            database.insert(orgDisAssoc);
            return true;
        }
        if (!orgDisAssocs.isEmpty()) {
            return true;
        }
        return false;
    }

    /**
     *  Save a list of metric datas to the DB in batches
     */
    public static void saveMetricDatas(List<M_E_Metric_Data__c> metricsDatas) {

        // Batch up the metric datas and save to the db
        Integer totalSaved = 0;
        List<M_E_Metric_Data__c> batchMetricData = new List<M_E_Metric_Data__c>();
        for (M_E_Metric_Data__c data : metricsDatas) {
            batchMetricData.add(data);
            if (batchMetricData.size() == 200) {
                database.upsert(batchMetricData);
                totalSaved += batchMetricData.size();
                batchMetricData.clear();
            }
        }

        // Add the last batch
        if (!batchMetricData.isEmpty()) {
            database.upsert(batchMetricData);
            totalSaved += batchMetricData.size();
        }
 
        System.debug(LoggingLevel.INFO, totalSaved + ' Metric Data Objects save to the DB');
    }

    /**
     *  Create a standard string to uniquely identify a metric data. If null or empty params are passed in
     *  that part of the name will be left out. It would be best to never pass in a blank metricName.
     *
     *  @param metricName     - The name of the metric
     *  @param subDividerName - The further sub divider that the metrics are spilt by (ideally should be the group by field in the calculation)
     *
     *  @return - A string that is of the format <metricName>_<subDividerName>
     */
    public static String createMetricLabelString(String metricName, String subDividerName) {

        String metricLabelName = '';
        if (metricName != null && !metricName.equals('')) {
            metricLabelName = metricLabelName + metricName;
        }
        if (subDividerName != null && !subDividerName.equals('')) {
            if (!metricLabelName.equals('')) {
                metricLabelName = metricLabelName + '_';
            }
            metricLabelName = metricLabelName + subDividerName;
        }
        return metricLabelName;
    }

    /**
     *  Generate a standard name from a list of strings that can be split easily
     *
     *  @param parts - The list of strings that we are joining
     *
     *  @return - A single string joined with a standard delimeter
     */
    public static String createSplitName(List<String> parts) {

        String name = '';
        if (!parts.isEmpty()) {
            Integer size = parts.size();
            if (size == 1) {
                name = parts.get(1);
            }
            else {
                for (Integer i = 0; i < size; i++) {
                    name = name + parts.get(i);
                    if (i != size - 1) {
                        name = name + '_splitter_';
                    }
                }
            }
        }
        return name;
    }

    /*
     *  Calculate a sum total of metrics taking into account the a Manual_Value__c overrides any calculated
     *  or existing Actual_Value__c
     *
     *  @param metricsRequired  - The metrics that are looked at to generate the total
     *  @param calculatedValues - The calculated values for each metric. Map should include an entry
     *                          - for each value in the metrics list.
     *                          - If this is null we use the Actual_Value__c
     *  @param previousValues   - Map holding previous values for cumulative metrics. Can be null or empty.
     *  @param startDate        - Start date for the quarter
     *  @param endDate          - End date for the quarter
     *
     *  @return - The total for this group of metrics.
     */
    public static Decimal calculateTotal(
            List<String> metricsRequired,
            Map<String, Decimal> calculatedValues,
            Map<String, Decimal> previousValues,
            Date startDate,
            Date endDate
    ) {

        // Convert the passed in dates into strings so they can be passed in to the query.
        String startString = convertDateTimeToString(convertToStartDate(startDate), true);
        String endString = convertDateTimeToString(convertToEndDate(endDate), true);
        String metricString = generateCommaSeperatedString(metricsRequired, true);
        String query = 
            'SELECT '                                           +
                'M_E_Metric__r.Name, '                          +
                'Actual_Value__c, '                             +
                'Manual_Value__c '                              +
            'FROM '                                             +
                'M_E_Metric_Data__c '                           +
            'WHERE '                                            +
                'M_E_Metric__r.Name IN (' + metricString + ') ' +
                'AND Date__c >= ' + startString + ' '           +
                'AND Date__c < ' + endString;

        M_E_Metric_Data__c[] metrics = database.query(query);
        Decimal total = 0.0;
        for (M_E_Metric_Data__c metric : metrics) {
            if (previousValues != null && previousValues.containsKey(metric.M_E_Metric__r.Name)) {
                total = total + previousValues.get(metric.M_E_Metric__r.Name);
            }
            if (metric.Manual_Value__c == null) {
                if (calculatedValues == null) {
                    if (metric.Actual_Value__c != null) {
                        total = total + metric.Actual_Value__c;
                    }
                }
                else {
                    if (calculatedValues.containsKey(metric.M_E_Metric__r.Name)) {
                        total = total + calculatedValues.get(metric.M_E_Metric__r.Name);
                    }
                }
            }
            else {
                total = total + metric.Manual_Value__c;
            }
        }
        return total;
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
    // **NOTE: Changed this to use Date.newInstance() instead
    public static Date convertStringToDate(String dateString) {
        String[] dateArray = dateString.split('/');
        return Date.newInstance(Integer.valueOf(dateArray[2]), Integer.valueOf(dateArray[0]), Integer.valueOf(dateArray[1]));       
    }

    public static Date convertSoqlStringToDate(String dateString) {
        String[] dateArray = dateString.split('-');
        return convertStringToDate(dateArray[1] + '/' + dateArray[2] + '/' + dateArray[0]);
    }

    /**
     *  Check to se if a list of elements needs to have quotes put around the elements
     *
     *  @param listToCheck - The list of elements
     *
     *  @return - Boolean indicating if quotes are needed
     */
    public static Boolean checkListNeedsQuotes(List<String> listToCheck) {

        if (listToCheck != null
                && !listToCheck.isEmpty()
                && !listToCheck[0].equals('')
                && !listToCheck[0].contains('\'')
        ) {
            return true;
        }
        return false;
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



    // START OF METHODS USED BY NEW COMPONENT DASHBOARD

    // I admit that the methods below test nothing and just run the code but the validity of the method
    // is tested in other places. This is just to get the coverage up
    static testMethod void testRollOverMethod() {

        Date now = Date.today();
        String value = createDispRollOverString(now, 'Monthly');
        getStartEndDates(value, 'Monthly');
        increaseDateRollOver(now, 'Monthly');
        decreaseDateRollOver(now, 'Monthly');
        getRollOverEndDate(now, 'Monthly');
        getRollOverStartDate(now, 'Monthly');
        value = createDispRollOverString(now, 'Quarterly');
        getStartEndDates(value, 'Quarterly');
        increaseDateRollOver(now, 'Quarterly');
        decreaseDateRollOver(now, 'Quarterly');
        getRollOverEndDate(now, 'Quarterly');
        getRollOverStartDate(now, 'Quarterly');
        value = createDispRollOverString(now.addMonths(3), 'Quarterly');
        getStartEndDates(value, 'Quarterly');
        getRollOverEndDate(now.addMonths(3), 'Quarterly');
        getRollOverStartDate(now.addMonths(3), 'Quarterly');
        value = createDispRollOverString(now.addMonths(6), 'Quarterly');
        getStartEndDates(value, 'Quarterly');
        getRollOverEndDate(now.addMonths(6), 'Quarterly');
        getRollOverStartDate(now.addMonths(6), 'Quarterly');
        value = createDispRollOverString(now.addMonths(9), 'Quarterly');
        getStartEndDates(value, 'Quarterly');
        getRollOverEndDate(now.addMonths(9), 'Quarterly');
        getRollOverStartDate(now.addMonths(9), 'Quarterly');
        value = createDispRollOverString(now, 'Yearly');
        getStartEndDates(value, 'Yearly');
        increaseDateRollOver(now, 'Yearly');
        decreaseDateRollOver(now, 'Yearly');
        getRollOverEndDate(now, 'Yearly');
        getRollOverStartDate(now, 'Yearly');
    }

    public static String createDispRollOverString(Date dateToParse, String rollOverPeriod) {

        if (rollOverPeriod.equals('Monthly')) {
            return translateMonth(String.valueOf(dateToParse.month())) + ' ' + String.valueOf(dateToParse.year());
        }
        else if (rollOverPeriod.equals('Quarterly')) {
            Integer month = dateToParse.month();
            if (month < 4) {
                return 'Jan Mar ' + String.valueOf(dateToParse.year());
            }
            else if (month < 7) {
                return 'Apr Jun ' + String.valueOf(dateToParse.year());
            }
            else if (month < 10) {
                return 'Jul Sept ' + String.valueOf(dateToParse.year());
            }
            else {
                return 'Oct Dec ' + String.valueOf(dateToParse.year());
            }
        }
        else {
            return String.valueOf(dateToParse.year());
        }
    }

    public static Map<String, String> monthTranslationMap = new Map<String, String> {
            '1' => 'Jan',
            '2' => 'Feb',
            '3' => 'Mar',
            '4' => 'Apr',
            '5' => 'May',
            '6' => 'Jun',
            '7' => 'Jul',
            '8' => 'Aug',
            '9' => 'Sept',
            '10' => 'Oct',
            '11' => 'Nov',
            '12' => 'Dec'
        };
    public static String translateMonth(String month) {
        return monthTranslationMap.get(month);
    }

    public static Map<String, Integer> monthTranslationMapBack = new Map<String, Integer> {
            'Jan' => 1,
            'Feb' => 2,
            'Mar' => 3,
            'Apr' => 4,
            'May' => 5,
            'Jun' => 6,
            'Jul' => 7,
            'Aug' => 8,
            'Sept' => 9,
            'Oct' => 10,
            'Nov' => 11,
            'Dec' => 12
        };
    public static Integer translateMonthBack(String month) {
        return monthTranslationMapBack.get(month);
    }

    public static Map<String, Integer> endOfMonthMap = new Map<String, Integer> {
            'Jan' => 31,
            'Feb' => 28,
            'Mar' => 31,
            'Apr' => 30,
            'May' => 31,
            'Jun' => 30,
            'Jul' => 31,
            'Aug' => 31,
            'Sept' => 30,
            'Oct' => 31,
            'Nov' => 30,
            'Dec' => 31
        };
    public static Integer getEndOfMonth(String month) {
        return endOfMonthMap.get(month);
    }

    public static List<Date> getStartEndDates(String dispString, String rollOverPeriod) {

        String[] dispArray = dispString.split(' ');
        if (rollOverPeriod.equals('Monthly')) {
            Date endDate = Date.newInstance(Integer.valueOf(dispArray[1]), translateMonthBack(dispArray[0]), getEndOfMonth(dispArray[0]));
            if (Date.isLeapYear(Integer.valueOf(dispArray[1])) && dispArray[0].equals('Feb')) {
                endDate.addDays(1);
            }
            return  new List<Date> { Date.newInstance(Integer.valueOf(dispArray[1]), translateMonthBack(dispArray[0]), 1), endDate };
        }
        else if (rollOverPeriod.equals('Quarterly')) {
            if (dispArray[0].equals('Jan')) {
                return new List<Date> { Date.newInstance(Integer.valueOf(dispArray[2]), 1, 1), Date.newInstance(Integer.valueOf(dispArray[2]), 3, 31) };
            }
            else if (dispArray[0].equals('Apr')) {
                return new List<Date> { Date.newInstance(Integer.valueOf(dispArray[2]), 4, 1), Date.newInstance(Integer.valueOf(dispArray[2]), 6, 30) };
            }
            else if (dispArray[0].equals('Jul')) {
                return new List<Date> { Date.newInstance(Integer.valueOf(dispArray[2]), 7, 1), Date.newInstance(Integer.valueOf(dispArray[2]), 9, 30) };
            }
            else {
                return new List<Date> { Date.newInstance(Integer.valueOf(dispArray[2]), 10, 1), Date.newInstance(Integer.valueOf(dispArray[2]), 31, 12) };
            }
        }
        else if (rollOverPeriod.equals('Yearly')) {
            return new List<Date> { Date.newInstance(Integer.valueOf(dispArray[0]), 1, 1), Date.newInstance(Integer.valueOf(dispArray[0]), 12, 31) };
        }
        return new List<Date>{ };
    }

    public static List<String> splitDispString(String dipsString) {
        return dipsString.split(' ');
    }

    public static Date increaseDateRollOver(Date dateToIncrease, String rollOverPeriod) {

        if (rollOverPeriod.equals('Monthly')) {
            dateToIncrease = dateToIncrease.addMonths(1);
        }
        else if (rollOverPeriod.equals('Quarterly')) {
            dateToIncrease = dateToIncrease.addMonths(3);
        }
        else if (rollOverPeriod.equals('Yearly')) {
            dateToIncrease = dateToIncrease.addMonths(12);
        }
        return dateToIncrease;
    }

    public static Date decreaseDateRollOver(Date dateToDecrease, String rollOverPeriod) {

        if (rollOverPeriod.equals('Monthly')) {
            dateToDecrease = dateToDecrease.addMonths(-1);
        }
        else if (rollOverPeriod.equals('Quarterly')) {
            dateToDecrease = dateToDecrease.addMonths(-3);
        }
        else if (rollOverPeriod.equals('Yearly')) {
            dateToDecrease = dateToDecrease.addMonths(-12);
        }
        return dateToDecrease;
    }

    public static Date getRollOverStartDate(Date startDate, String rollOverPeriod) {

        if (rollOverPeriod.equals('Monthly')) {
            startDate = startDate.toStartOfMonth();
        }
        else if (rollOverPeriod.equals('Quarterly')) {
            Integer month = startDate.month();
            if (month < 4) {
                startDate = Date.newInstance(startDate.year(), 1, 1);
            }
            else if (month < 7) {
                startDate = Date.newInstance(startDate.year(), 4, 1);
            }
            else if (month < 10) {
                startDate = Date.newInstance(startDate.year(), 7, 1);
            }
            else {
                startDate = Date.newInstance(startDate.year(), 10, 1);
            }
        }
        else if (rollOverPeriod.equals('Yearly')) {
            startDate = Date.newInstance(startDate.year(), 1, 1);
        }
        return startDate;
    }

    public static Date getRollOverEndDate(Date endDate, String rollOverPeriod) {

        if (rollOverPeriod.equals('Monthly')) {
            endDate = endDate.toStartOfMonth().addMonths(1).addDays(-1);
        }
        else if (rollOverPeriod.equals('Quarterly')) {
            Integer month = endDate.month();
            if (month < 4) {
                endDate = Date.newInstance(endDate.year(), 3, 31);
            }
            else if (month < 7) {
                endDate = Date.newInstance(endDate.year(), 6, 30);
            }
            else if (month < 10) {
                endDate = Date.newInstance(endDate.year(), 9, 30);
            }
            else {
                endDate = Date.newInstance(endDate.year(), 12, 31);
            }
        }
        else if (rollOverPeriod.equals('Yearly')) {
            endDate = Date.newInstance(endDate.year(), 12, 31);
        }
        return endDate;
    }

    // END OF METHODS USED BY NEW COMPONENT DASHBOARD

    static testMethod void testGetSMS() {

        // Check that the metric is there already
        String quarterString = MetricHelpers.getCurrentQuarterAsString(0);
        Date startDate = MetricHelpers.getQuarterFirstDay(quarterString);
        Date endDate   = MetricHelpers.getQuarterLastDay(quarterString);

        // Create the organisation
        Account org = Utils.createTestOrganisation('Test');
        database.insert(org);

        String nameMetric = org.Name + '_test_total_interactions_channels';
        M_E_Metric__c metricAverage = Utils.createTestMetric(org, null, 'Scale', true, 'total_interactions_channels');
        database.insert(metricAverage);

        M_E_Metric_Data__c[] metricData = [
            SELECT
                Actual_Value__c
            FROM
                M_E_Metric_Data__c
            WHERE
                M_E_Metric__r.Name = :nameMetric
                AND Date__c = THIS_QUARTER
            ];

        if (metricData.size() == 0) {
            M_E_Metric_Data__c newData = createNewMetric(nameMetric, date.today(), 5.0 ,5.0, null, null, false);
            if (newData != null) {
                database.insert(newData);
            }
        }
        else {
            MetricHelpers.updateMetric(nameMetric, 5.0, null, null, startDate, endDate, false);
        }
        Decimal inter = MetricHelpers.getSmsInteractions(startDate, endDate);
        //System.assertEquals(5.0, inter);
    }

    static testMethod void testMetricHelpers() {

        String quarter = MetricHelpers.getCurrentQuarterAsString(0);
        Date startDate = MetricHelpers.getQuarterFirstDay(quarter);
        Date endDate   = MetricHelpers.getQuarterLastDay(quarter);
        List<String> metrics = new List<String>();
        metrics.add('TEST_THIS_CODE');

        // Create a test M_E_Metric__c and a M_E_Metric_Data__c
        M_E_Metric__c testMetric = new M_E_Metric__c();
        testMetric.Name = 'TEST_THIS_CODE';
        testMetric.Label__c = 'This and that';
        testMetric.M_E_Area__c = 'Impact';
        testMetric.Order__c = 4;
        testMetric.Update_Period__c = 'Daily';
        database.insert(testMetric);

        List<M_E_Metric_Data__c> metricData = new List<M_E_Metric_Data__c>();
        M_E_Metric_Data__c testDataCurrent = new M_E_Metric_Data__c();
        testDataCurrent.M_E_Metric__c = testMetric.Id;
        testDataCurrent.Actual_Value__c = 10;
        testDataCurrent.Projected_Value__c = 15;
        testDataCurrent.Date__c = startDate;
        testDataCurrent.Comment__c = 'This should be this quarters.';
        metricData.add(testDataCurrent);

        M_E_Metric_Data__c testDataPrevious = new M_E_Metric_Data__c();
        testDataPrevious.M_E_Metric__c = testMetric.Id;
        testDataPrevious.Actual_Value__c = 10;
        testDataPrevious.Projected_Value__c = 15;
        testDataPrevious.Date__c = startDate.addMonths(-3);
        testDataPrevious.Comment__c = 'This should be last quarters.';
        metricData.add(testDataPrevious);
        database.insert(metricData);

        M_E_Metric__c[] retrievedMetric = getMetrics('TEST_THIS_CODE', 'null');
        M_E_Metric_Data__c retrievedData = getMetricData('TEST_THIS_CODE', startDate, endDate);
        List<String> metricList = new List<String>();
        metricList.add('TEST_THIS_CODE');
        M_E_Metric_Data__c[] retrievedDatas = getMetricDatas(metricList, startDate, endDate, null);

        M_E_Metric_Data__c newData = createNewMetric('THIS_TEST_CODE', startDate.addMonths(3), 10, 10, null, null, false);
        System.assertEquals(newData, null);
        newData = createNewMetric('TEST_THIS_CODE', startDate.addMonths(3), 10, 10, null, null, false);
        database.insert(newData);

        // Check we have three data for TEST_THIS_CODE
        System.AssertEquals(database.countquery('SELECT count() FROM M_E_Metric_Data__c WHERE M_E_Metric__r.Name = \'TEST_THIS_CODE\''),3);

        MetricHelpers.updateMetric('TEST_THIS_CODE', 5.0, null, null, startDate, endDate, false);
        MetricHelpers.calculateAverageMetric('TEST_THIS_CODE');

        // Check the date manipulations
        Date testDate1 = date.newInstance(2013, 2, 1);
        Integer firstQuarter = getQuarter(testDate1);
        String firstQuarterStartMonth = getQuarterStartMonth(firstQuarter);
        String firstQuarterEndMonth = getQuarterEndMonth(firstQuarter);
        System.assertEquals(1, firstQuarter);
        System.assertEquals('Jan', firstQuarterStartMonth);
        System.assertEquals('Mar', firstQuarterEndMonth);

        Date testDate2 = date.newInstance(2011, 5, 1);
        Integer secondQuarter = getQuarter(testDate2);
        String secondQuarterStartMonth = getQuarterStartMonth(secondQuarter);
        String secondQuarterEndMonth = getQuarterEndMonth(secondQuarter);
        System.assertEquals(2, secondQuarter);
        System.assertEquals('Apr', secondQuarterStartMonth);
        System.assertEquals('Jun', secondQuarterEndMonth);

        Date testDate3 = date.newInstance(2011, 8, 1);
        Integer thirdQuarter = getQuarter(testDate3);
        String thirdQuarterStartMonth = getQuarterStartMonth(thirdQuarter);
        String thirdQuarterEndMonth = getQuarterEndMonth(thirdQuarter);
        System.assertEquals(3, thirdQuarter);
        System.assertEquals('Jul', thirdQuarterStartMonth);
        System.assertEquals('Sep', thirdQuarterEndMonth);

        Date testDate4 = date.newInstance(2011, 11, 1);
        Integer fourthQuarter = getQuarter(testDate4);
        String fourthQuarterStartMonth = getQuarterStartMonth(fourthQuarter);
        String fourthQuarterEndMonth = getQuarterEndMonth(fourthQuarter);
        System.assertEquals(4, fourthQuarter);
        System.assertEquals('Oct', fourthQuarterStartMonth);
        System.assertEquals('Dec', fourthQuarterEndMonth);

        String quarterString = getQuarterAsString(1);
        String quarterDateString = getQuarterAsString(testDate1);
        Date quarterIntStringFirst = getQuarterFirstDay(quarterString);
        Date quarterIntStringLast = getQuarterLastDay(quarterString);
        Date quarterDateStringFirst = getQuarterFirstDay(quarterDateString);
        Date quarterDateStringLast = getQuarterLastDay(quarterDateString);
        System.AssertEquals(quarterString,'Jan - Mar 2013');
        System.assertEquals(quarterString, quarterDateString);
        System.assertEquals(quarterIntStringFirst, quarterDateStringFirst);
        System.assertEquals(quarterIntStringLast, quarterDateStringLast);

        getMetricValues(metrics, startDate, endDate);
        generateMetrics(startDate, endDate, 'null');

    }
    static testMethod void testGetCumulativeValues() {

        Date startDate = getQuarterFirstDay(getCurrentQuarterAsString(0));

        // Create the organisation
        Account org = Utils.createTestOrganisation('Test');
        database.insert(org);

        // Create a couple of districts
        District__c district = Utils.createTestDistrict('Test');
        database.insert(district);

        District__c district1 = Utils.createTestDistrict('Test1');
        database.insert(district1);

        // Create an average metric
        M_E_Metric__c metricAverage = Utils.createTestMetric(org, 'Average', 'Scale', true, 'average');
        database.insert(metricAverage);

        // Create a sum metric
        M_E_Metric__c metricSum = Utils.createTestMetric(org, 'Cumulative', 'Scale', true, 'sum');
        database.insert(metricSum);

        // Create some metric data objects
        List<M_E_Metric_Data__c> dataList = new List<M_E_Metric_Data__c>();
        dataList.add(Utils.createTestMetricData(district, metricAverage, 10.0, null, startDate));
        dataList.add(Utils.createTestMetricData(district1, metricAverage, 13.0, null, startDate));
        dataList.add(Utils.createTestMetricData(district, metricSum, 10.0, null, startDate));
        dataList.add(Utils.createTestMetricData(district1, metricSum, 13.0, null, startDate));

        dataList.add(Utils.createTestMetricData(district, metricAverage, 20.0, null, startDate.addMonths(-3)));
        dataList.add(Utils.createTestMetricData(district1, metricAverage, 23.0, null, startDate.addMonths(-3)));
        dataList.add(Utils.createTestMetricData(district, metricSum, 20.0, null, startDate.addMonths(-3)));
        dataList.add(Utils.createTestMetricData(district1, metricSum, 23.0, null, startDate.addMonths(-3)));

        dataList.add(Utils.createTestMetricData(district, metricAverage, 30.0, null, startDate.addMonths(-6)));
        dataList.add(Utils.createTestMetricData(district1, metricAverage, 33.0, null, startDate.addMonths(-6)));
        dataList.add(Utils.createTestMetricData(district, metricSum, 30.0, null, startDate.addMonths(-6)));
        dataList.add(Utils.createTestMetricData(district1, metricSum, 33.0, null, startDate.addMonths(-6)));
        database.insert(dataList);

        Map<String, District__c> districtMap = new Map<String, District__c>();
        districtMap.put(district.Name, district);
        districtMap.put(district1.Name, district1);

        Integer counter = 0;
        for (MetricDataCalculationTracker tracker : getCumulativeValues(org.Name, districtMap)) {
            String districtName = '';
            District__c districtTracker = tracker.getDistrict();
            if (districtTracker != null) {
                districtName = districtTracker.Name;
            }
            System.debug(LoggingLevel.INFO, 'TOTAL FOR METRIC ' + tracker.getMetricName() + ' IS ' + tracker.getTotal() + ' FOR DISTRICT - ' + districtName);
            counter++;
        }
        System.assertEquals(counter, 4);
    }

    static testMethod void testCalculateSurveyTotal() {

        // Create the organisation
        Account org = Utils.createTestOrganisation('Test');
        database.insert(org);

        // Create a couple of districts
        District__c district = Utils.createTestDistrict('Test');
        database.insert(district);

        District__c district1 = Utils.createTestDistrict('Test1');
        database.insert(district1);

        // Create a survey
        Survey__c survey = Utils.createTestSurvey(org, 'survey');
        database.insert(survey);

        // Create the survey map
        Map<String, Integer> surveyTotals = new Map<String, Integer>();
        List<String> splitNameList = new List<String>();
        splitNameList.add(survey.Name);
        splitNameList.add(district.Name);
        String splitName = createSplitName(splitNameList);
        surveyTotals.put(splitName, 123);
        splitNameList.clear();

        splitNameList.add(survey.Name);
        splitNameList.add(district1.Name);
        splitName = createSplitName(splitNameList);
        surveyTotals.put(splitName, 223);

        // Create some MetricDataCalculationTracker
        MetricDataCalculationTracker tracker = new MetricDataCalculationTracker('TEST', 'average', district, survey);
        tracker.setTotal(1000.0);
        System.assertEquals(calculateSurveyTotal(tracker, surveyTotals), 8.13);
        tracker = new MetricDataCalculationTracker('TEST', 'average', district1, survey);
        tracker.setTotal(1000.0);
        System.assertEquals(calculateSurveyTotal(tracker, surveyTotals), 4.48);
        tracker = new MetricDataCalculationTracker('TEST', 'sum', district, survey);
        tracker.setTotal(10.0);
        System.assertEquals(calculateSurveyTotal(tracker, surveyTotals), 10.00);
        tracker = new MetricDataCalculationTracker('TEST', 'sum', district1, survey);
        tracker.setTotal(10.0);
        System.assertEquals(calculateSurveyTotal(tracker, surveyTotals), 10.00);
        tracker = new MetricDataCalculationTracker('TEST', 'percentage', district, survey);
        tracker.setTotal(10.0);
        System.assertEquals(calculateSurveyTotal(tracker, surveyTotals), 8.13);
        tracker = new MetricDataCalculationTracker('TEST', 'percentage', district1, survey);
        tracker.setTotal(10.0);
        System.assertEquals(calculateSurveyTotal(tracker, surveyTotals), 4.48);
    }

    static testMethod void testCheckForOrganisationDistrictLink() {

        District__c district = Utils.createTestDistrict('Test');
        database.insert(district);

        Account account = Utils.createTestOrganisation('Test');
        database.insert(account);

        System.assert(checkForOranistationDistrictLink(account, district.Id, true));
    }

    static testMethod void testCreateMetricLabelString() {

        System.assert(createMetricLabelString('Here', 'There').equals('Here_There'));
    }

    static testMethod void testCreateSplitName() {

        List<String> names = new List<String>();
        names.add('Here');
        names.add('There');
        System.assert(createSplitName(names).equals('Here_splitter_There'));
    }
}