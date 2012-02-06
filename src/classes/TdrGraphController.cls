public with sharing class TdrGraphController {

    /**
     *  Controller class for the MTN TDR Dashboard Graphs
     */

    /**
     * Variables for the Bar Graph
     */
    public String barGraphData;
    private List<GraphColumnWrapper> barGraphColumns;
    private List<TdrGraphController.TdrGraphRowWrapper> barGraphRows;

    public String getBarGraphData() {
        return this.barGraphData;
    }
    public void setBarGraphData(String values) {
        this.barGraphData = values;
    }
    private String generateBarGraphData() {

        // Generate the bar graph rows and columns
        setBarGraphColumns();
        setBarGraphRows();

        String json = generateJsonDataTable(this.barGraphColumns, this.barGraphRows);
        if (json.equals('FAIL')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There is no general data for the parameters you have selected. Please change the parameters and try again'));
            setShowBarGraph(false);
        }
        return json;
    }


    private void setBarGraphColumns() {

        this.barGraphColumns = new List<GraphColumnWrapper>();
        if (this.tdrSelectorController.getParameter('scope').equals('COUNTRY')) {
            this.barGraphColumns.add(new GraphColumnWrapper('string', 'Region'));
        }
        else {
            this.barGraphColumns.add(new GraphColumnWrapper('string', 'Name'));
        }
        
        // If there is going to be a conflict on the id then need to add specific ones
        this.barGraphColumns.add(new GraphColumnWrapper('number', 'MM Agent Long Survey'));
        GraphColumnWrapper mmlsTarget = new GraphColumnWrapper('number', 'Target');
        mmlsTarget.setId('mmlsTarget');
        this.barGraphColumns.add(mmlsTarget);

        this.barGraphColumns.add(new GraphColumnWrapper('number', 'MM Agent Short Survey'));
        GraphColumnWrapper mmssTarget = new GraphColumnWrapper('number', 'Target');
        mmssTarget.setId('mmssTarget');
        this.barGraphColumns.add(mmssTarget);

        this.barGraphColumns.add(new GraphColumnWrapper('number', 'Corporate Sales Calls'));
        GraphColumnWrapper cscTarget = new GraphColumnWrapper('number', 'Target');
        cscTarget.setId('cscTarget');
        this.barGraphColumns.add(cscTarget);

        this.barGraphColumns.add(new GraphColumnWrapper('number', 'School Sales Calls'));
        GraphColumnWrapper sscTarget = new GraphColumnWrapper('number', 'Target');
        sscTarget.setId('sscTarget');
        this.barGraphColumns.add(sscTarget);

        this.barGraphColumns.add(new GraphColumnWrapper('number', 'Customer Support Calls'));

        this.barGraphColumns.add(new GraphColumnWrapper('number', 'Marketing Events'));

        this.barGraphColumns.add(new GraphColumnWrapper('number', 'Other'));

        // Add the agent base if the scope is COUNTRY
        if (this.tdrSelectorController.getParameter('scope').equals('COUNTRY')) {
            this.barGraphColumns.add(new GraphColumnWrapper('number', 'Agent Base'));
        }
    }
    private void setBarGraphRows() {
        this.barGraphRows = getBarGraphDataWrappers();
    }

    /**
     *  Get the bar graph data.  This gets all the possible data for the data range give. The VF page
     *  deals with choosing what to display
     */
    private List<TdrGraphController.TdrGraphRowWrapper> getBarGraphDataWrappers() {

        String queryBase =
            'SELECT '                                               +
                'sum(MM_Agent_Full_Report__c) mmfrTotal, '          +
                'sum(MM_Agent_Full_Report_Target__c) mmfrTarget, '  +
                'sum(MM_Agent_Short_Report__c) mmsrTotal, '         +
                'sum(MM_Agent_Short_Report_Target__c) mmsrTarget, ' +
                'sum(Customer_Support__c) csTotal, '                +
                'sum(Marketing_Event__c) meTotal, '                 +
                'sum(Corporate_Sales_Calls__c) cscTotal, '          +
                'sum(Corporate_Sales_Calls_Target__c) cscTarget, '  +
                'sum(School_Sales_Calls__c) sscTotal, '             +
                'sum(School_Sales_Calls_Target__c) sscTarget, '     +
                'sum(Other__c) oTotal, ';
        if (this.tdrSelectorController.getParameter('scope').equals('COUNTRY')) {
            queryBase += 'Person__r.Region__r.Display_Name__c region ';
        }
        else {
            queryBase += 'Person__r.First_Name__c firstName, ' +
                'Person__r.Last_Name__c lastName ';
        }
        queryBase +=
            'FROM '                                  +
                'TDR_Performance__c '                +
            'WHERE '                                 +
                'Person__c IN ('                     +
                    this.tdrSelectorController.getParameter('tdrs') +
                ')'                                  +
                ' AND Type__c = \''                  +
                    this.tdrSelectorController.getParameter('type')      +
                '\''                                 +
                ' AND Start_Date__c >= '             +
                    this.tdrSelectorController.getParameter('startDate') +
                ' AND Start_Date__c <= '             +
                    this.tdrSelectorController.getParameter('endDate');

        if (this.tdrSelectorController.getParameter('scope').equals('COUNTRY')) {
            queryBase += ' GROUP BY Person__r.Region__r.Display_Name__c';
        }
        else {
            queryBase += ' GROUP BY  Person__r.Last_Name__c, Person__r.First_Name__c';
        }
        System.debug(LoggingLevel.INFO, queryBase);

        // If this is country wide get the Agent Base.
        Map<String, Decimal> agentBaseMap = new Map<String, Decimal>();
        if (this.tdrSelectorController.getParameter('scope').equals('COUNTRY')) {
            //agentBaseMap = TdrHelpers.getAgentBase(this.parameters);
        }

        List<TdrGraphController.TdrGraphRowWrapper> values = new List<TdrGraphController.TdrGraphRowWrapper>();
        AggregateResult[] performances = database.query(queryBase);
        if (performances.isEmpty()) {
            return values;
        }
        Integer totalMmFullReport = 0;
        Integer totalMmFullReportTarget = 0;
        Integer totalMmShortReport = 0;
        Integer totalMmShortReportTarget = 0;
        Integer totalCustomerSupport = 0;
        Integer totalMarketingEvent = 0;
        Integer totalCorporateSalesCall = 0;
        Integer totalCorporateSalesCallTarget = 0;
        Integer totalSchoolSalesCall = 0;
        Integer totalSchoolSalesCallTarget = 0;
        Integer totalOther = 0;
        Integer totalAgentBase = 0;
        for (AggregateResult performance : performances) {
            String header = '';
            String agentBase = '';
            if (this.tdrSelectorController.getParameter('scope').equals('COUNTRY')) {
                String region = String.valueOf(performance.get('region'));
                //agentBase = String.valueOf(Integer.valueOf(agentBaseMap.get(region)));
                agentBase = String.valueOf(100);
                totalAgentBase += Integer.valueOf(agentBase);
                header = region;
            }
            else {
                header = String.valueOf(performance.get('lastName')) + ' ' + String.valueOf(performance.get('firstName'));
            }
            TdrGraphController.TdrGraphRowWrapper wrapper = new TdrGraphController.TdrGraphRowWrapper(header);
            wrapper.addValue(String.valueOf(Integer.valueOf(performance.get('mmfrTotal'))));
            wrapper.addValue(String.valueOf(Integer.valueOf(performance.get('mmfrTarget'))));
            wrapper.addValue(String.valueOf(Integer.valueOf(performance.get('mmsrTotal'))));
            wrapper.addValue(String.valueOf(Integer.valueOf(performance.get('mmsrTarget'))));
            wrapper.addValue(String.valueOf(Integer.valueOf(performance.get('cscTotal'))));
            wrapper.addValue(String.valueOf(Integer.valueOf(performance.get('cscTarget'))));
            wrapper.addValue(String.valueOf(Integer.valueOf(performance.get('sscTotal'))));
            wrapper.addValue(String.valueOf(Integer.valueOf(performance.get('sscTarget'))));
            wrapper.addValue(String.valueOf(Integer.valueOf(performance.get('csTotal'))));
            wrapper.addValue(String.valueOf(Integer.valueOf(performance.get('meTotal'))));
            wrapper.addValue(String.valueOf(Integer.valueOf(performance.get('oTotal'))));
            if (this.tdrSelectorController.getParameter('scope').equals('COUNTRY')) {
                wrapper.addValue(agentBase);
            }

            // Count the totals
            totalMmFullReport += Integer.valueOf(performance.get('mmfrTotal'));
            totalMmFullReportTarget += Integer.valueOf(performance.get('mmfrTarget'));
            totalMmShortReport += Integer.valueOf(performance.get('mmsrTotal'));
            totalMmShortReportTarget += Integer.valueOf(performance.get('mmsrTarget'));
            totalCorporateSalesCall += Integer.valueOf(performance.get('cscTotal'));
            totalCorporateSalesCallTarget += Integer.valueOf(performance.get('cscTarget'));
            totalSchoolSalesCall += Integer.valueOf(performance.get('sscTotal'));
            totalSchoolSalesCallTarget += Integer.valueOf(performance.get('sscTarget'));
            totalCustomerSupport += Integer.valueOf(performance.get('csTotal'));
            totalMarketingEvent += Integer.valueOf(performance.get('meTotal'));
            totalOther += Integer.valueOf(performance.get('oTotal'));

            // Add the new graph wrapper object to the list
            values.add(wrapper);
        }

        // Add the total
        TdrGraphController.TdrGraphRowWrapper totalWrapper = new TdrGraphController.TdrGraphRowWrapper('Total');
        totalWrapper.addValue(String.valueOf(totalMmFullReport));
        totalWrapper.addValue(String.valueOf(totalMmFullReportTarget));
        totalWrapper.addValue(String.valueOf(totalMmShortReport));
        totalWrapper.addValue(String.valueOf(totalMmShortReportTarget));
        totalWrapper.addValue(String.valueOf(totalCorporateSalesCall));
        totalWrapper.addValue(String.valueOf(totalCorporateSalesCallTarget));
        totalWrapper.addValue(String.valueOf(totalSchoolSalesCall));
        totalWrapper.addValue(String.valueOf(totalSchoolSalesCallTarget));
        totalWrapper.addValue(String.valueOf(totalCustomerSupport));
        totalWrapper.addValue(String.valueOf(totalMarketingEvent));
        totalWrapper.addValue(String.valueOf(totalOther));

        // Add the agent base to the graph if in the right scope
        if (this.tdrSelectorController.getParameter('scope').equals('COUNTRY')) {
            totalWrapper.addValue(String.valueOf(totalAgentBase));
        }
        values.add(totalWrapper);
        return values;
    }

    // Set the title
    public String barChartHeader;
    public String getBarChartHeader() {
        return this.barChartHeader;
    }
    public void setBarChartHeader(String title) {
        this.barChartHeader = title;
    }

    // Control if it is rendered or not
    public Boolean showBarGraph;
    public Boolean getShowBarGraph() {
        return this.showBarGraph;
    }
    public void setShowBarGraph(Boolean bool) {
        this.showBarGraph = bool;
    }

    /**
     *  Variables for the Top Twelve Graph. Note that we can haave more than one top twelve graph
     */
    // General controls
    public Boolean showTopTwelveGraphs;
    public Boolean getShowTopTwelveGraphs() {
        return this.showTopTwelveGraphs;
    }
    public void setShowTopTwelveGraphs(Boolean bool) {
        this.showTopTwelveGraphs = bool;
    }

    public String topTwelveType;
    public String getTopTwelveType() {
        return this.topTwelveType;
    }
    public void setTopTwelveType(String typeString) {
        this.topTwelveType = typeString;
    }

    public Integer biggestTopTwelveNumber;
    public Integer getBiggestTopTwelveNumber() {
        return this.biggestTopTwelveNumber;
    }
    public void setBiggestTopTwelveNumber(Integer value) {
        if (value > this.biggestTopTwelveNumber) {
            this.biggestTopTwelveNumber = value + 1;
        }
    }
    private void clearBiggestTopTwelveNumber() {
        this.biggestTopTwelveNumber = 0;
    }

    // Graph One
    //Header
    public String topTwelveOneHeader;
    public String getTopTwelveOneHeader() {
        return this.topTwelveOneHeader;
    }
    public void setTopTwelveOneHeader(String header) {
        this.topTwelveOneHeader = header;
    }

    public String topTwelveOneDataString;
    public String getTopTwelveOneDataString() {
        return this.topTwelveOneDataString;
    }
    public void setTopTwelveOneDataString(String data) {
        this.topTwelveOneDataString = data;
    }

    //Controls
    public Boolean showTopTwelveGraphOne;
    public Boolean getShowTopTwelveGraphOne() {
        return this.showTopTwelveGraphOne;
    }
    public void setShowTopTwelveGraphOne(Boolean bool) {
        this.showTopTwelveGraphOne = bool;
    }

    public String topTwelveGraphOneTitle;
    public String getTopTwelveGraphOneTitle() {
        return this.topTwelveGraphOneTitle;
    }
    public void setTopTwelveGraphOneTitle(String title) {
        this.topTwelveGraphOneTitle = title;
    }

    // Graph Two
    // Header
    public String topTwelveTwoHeader;
    public String getTopTwelveTwoHeader() {
        return this.topTwelveTwoHeader;
    }
    public void setTopTwelveTwoHeader(String header) {
        this.topTwelveTwoHeader = header;
    }

    // Literal String
    public String topTwelveTwoDataString;
    public String getTopTwelveTwoDataString() {
        return this.topTwelveTwoDataString;
    }
    public void setTopTwelveTwoDataString(String data) {
        this.topTwelveTwoDataString = data;
    }

    //Controls
    public Boolean showTopTwelveGraphTwo;
    public Boolean getShowTopTwelveGraphTwo() {
        return this.showTopTwelveGraphTwo;
    }
    public void setShowTopTwelveGraphTwo(Boolean bool) {
        this.showTopTwelveGraphTwo = bool;
    }

    public String topTwelveGraphTwoTitle;
    public String getTopTwelveGraphTwoTitle() {
        return this.topTwelveGraphTwoTitle;
    }
    public void setTopTwelveGraphTwoTitle(String title) {
        this.topTwelveGraphTwoTitle = title;
    }

    // Generic top twelve methods
    /**
     *  Generate the header for the top twelve graphs
     */
    private String generateTopTwelveHeader(String graphNumber) {

        String header = '';

        String timePeriod = this.tdrSelectorController.getParameter('type');
        if (getShowTopTwelveGraphTwo()) {
            header += 'Showing ' + this.topTwelveFieldMap.get(this.getTopTwelveType()).replace('_', ' ') + ' for ';
            if (timePeriod.equals('DAILY')) {
                header += ' day ';
            }
            else {
                header += ' week ';
            }
            if (graphNumber.equals('TWO')) {
                header += this.tdrSelectorController.getParameter('endDate');
            }
            else {
                header += this.tdrSelectorController.getParameter('startDate');
            }
            header += ' ' + TdrHelpers.getLocationTitle(this.tdrSelectorController.getParameters());
        }
        else {
            header += 'Showing sum of ' + this.topTwelveFieldMap.get(this.getTopTwelveType()).replace('_', ' ') + ' for ' + generateGeneralTitle();
        }
        return header;
    }
    /**
     *  Generate the java script literal String fo the graphs data
     */
    private String generateTopTwelveDataString(List<GraphColumnWrapper> columns, List<TdrGraphController.TdrGraphRowWrapper> rows, String graphNumber) {

        String json = generateJsonDataTable(columns, rows);
        if (json.equals('FAIL')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There is no top twelve data for the parameters you have selected. Please change the parameters and try again'));
            setShowTopTwelveGraphs(false);
            if (graphNumber.equals('TWO')) {
                setShowTopTwelveGraphTwo(false);
            }
            else {
                setShowTopTwelveGraphOne(false);
            }
        }
        return json;
    }

    /**
     *  Get the columns for the top twelve graph
     *
     *  @return - A list of column wrappers
     */
    private List<GraphColumnWrapper> setTopTwelveColumns() {

        List<GraphColumnWrapper> columns = new List<GraphColumnWrapper>();
        columns.add(new GraphColumnWrapper('string', 'Name'));
        columns.add(new GraphColumnWrapper('number', this.topTwelveFieldMap.get(this.getTopTwelveType()).replace('_', ' ')));
        return columns;
    }

    /**
     *  Get the data for the top twelve graphs.
     *
     *  @param graphNumber - Which graph is this for. Options:-
     *                          ONE - uses startDate
     *                          TWO - uses endDate
     *
     *  @return - A list of row wrappers
     */
    private List<TdrGraphController.TdrGraphRowWrapper> setTopTwelveRows(String graphNumber) {

        String dateString;
        if (graphNumber.equals('ONE')) {
            dateString = this.tdrSelectorController.getParameter('startDate');
        }
        else {
            dateString = this.tdrSelectorController.getParameter('endDate');
        }

        // This is a sum if we are not looking at the comparison
        List<TdrGraphController.TdrGraphRowWrapper> rows = new List<TdrGraphController.TdrGraphRowWrapper>();
        String topTwelveField = getTopTwelveString();
        setTopTwelveHAxis('Number of ' + this.topTwelveFieldMap.get(this.getTopTwelveType()).replace('_', ' '));

        if (getShowTopTwelveGraphTwo()) {
            String query =
                'SELECT '                           +
                    'Person__r.First_Name__c, '     +
                    'Person__r.Last_Name__c, '      +
                    topTwelveField + ' '            +
                'FROM '                             +
                    'TDR_Performance__c '           +
                'WHERE '                            +
                    'Person__c IN ('                +
                        this.tdrSelectorController.getParameter('tdrs') +
                    ') '                            +
                    'AND Type__c = \''              +
                        this.tdrSelectorController.getParameter('type') +
                    '\' '                           +
                    'AND Start_Date__c = '          +
                        dateString                  +
                    ' '                             +
                'ORDER BY '                         +
                    topTwelveField + ' DESC '       +
                'LIMIT 12';

            System.debug(LoggingLevel.INFO, query);

            TDR_Performance__c[] performances = database.query(query);
            if (performances.isEmpty()) {
                return rows;
            }

            // Set the first entry to the highest number. Can do this as the query is ordered
            Decimal value = (Decimal)performances[0].get(topTwelveField);
            setBiggestTopTwelveNumber(value.intValue());
            for (TDR_Performance__c performance : performances) {
                TdrGraphController.TdrGraphRowWrapper wrapper = new TdrGraphController.TdrGraphRowWrapper(performance.Person__r.Last_Name__c + ', ' + performance.Person__r.First_Name__c);
                value = (Decimal)performance.get(topTwelveField);
                wrapper.addValue(String.valueOf(value.intValue()));
                rows.add(wrapper);
            }
        }
        else {
            String query =
                'SELECT '                                 +
                    'Person__r.First_Name__c firstName, ' +
                    'Person__r.Last_Name__c lastName, '   +
                    topTwelveField                        +
                    ' value '                             +
                'FROM '                                   +
                    'TDR_Performance__c '                 +
                'WHERE '                                  +
                    'Person__c IN ('                      +
                        this.tdrSelectorController.getParameter('tdrs')       +
                    ') '                                  +
                    'AND Type__c = \''                    +
                        this.tdrSelectorController.getParameter('type')       +
                    '\' '                                 +
                    'AND Start_Date__c >= '               +
                        this.tdrSelectorController.getParameter('startDate')  +
                    ' '                                   +
                    'AND Start_Date__c <= '               +
                        this.tdrSelectorController.getParameter('endDate')    +
                    ' '                                   +
                'GROUP BY '                               +
                    'Person__r.Last_Name__c, '            +
                    'Person__r.First_Name__c '            +
                'ORDER BY '                               +
                    topTwelveField + ' DESC '             +
                'LIMIT 12';

            System.debug(LoggingLevel.INFO, query);

            AggregateResult[] performances = database.query(query);
            if (performances.isEmpty()) {
                return rows;
            }

            // Set the first entry to the highest number. Can do this as the query is ordered
            setBiggestTopTwelveNumber(Integer.valueOf(performances[0].get('value')));
            for (AggregateResult performance : performances) {
                TdrGraphController.TdrGraphRowWrapper wrapper = new TdrGraphController.TdrGraphRowWrapper(performance.get('lastName') + ', ' + performance.get('firstName'));
                wrapper.addValue(String.valueOf(Integer.valueOf(performance.get('value'))));
                rows.add(wrapper);
            }
        }
        return rows;
    }

    /**
     *  Get the field that the top twelve graph is looking at
     */
    private Map<String, String> topTwelveFieldMap;
    private void initTopTweleveFieldMap() {
        this.topTwelveFieldMap = new Map<String, String> {
            '1' => 'MM_Agent_Full_Report',
            '2' => 'MM_Agent_Short_Report',
            '3' => 'Corporate_Sales_Calls',
            '4' => 'School_Sales_Calls',
            '5' => 'Customer_Support',
            '6' => 'Marketing_Event',
            '7' => 'Other'
        };
    }
    private String getTopTwelveString() {

        // Get the name field
        String field = this.topTwelveFieldMap.get(this.getTopTwelveType());
        if (!getShowTopTwelveGraphTwo()) {
            return 'sum(' + field + '__c)';
        }
        return field + '__c';
    }
    public String topTwelveHAxis;
    public String getTopTwelveHAxis() {
        return this.topTwelveHAxis;
    }
    public void setTopTwelveHAxis(String title) {
        this.topTwelveHAxis = title;
    }

    /*
     *  Variables and methods for getting the daily summary. TODO - This if asked
     */



    /*
     *  Variables and methods for the daily reports
     */
    private List<TdrDailyActivityWrapper> dailyReportsFullList;
    public List<TdrDailyActivityWrapper> dailyReports;
    public List<TdrDailyActivityWrapper> getDailyReports() {
        return this.dailyReports;
    }
    public void setDailyReports(List<TdrDailyActivityWrapper> reports) {
        this.dailyReports = reports;
    }

    public Boolean showDailyActivityReport;
    public Boolean getShowDailyActivityReport() {
        return this.showDailyActivityReport;
    }
    public void setShowDailyActivityReport(Boolean bool) {
        this.showDailyActivityReport = bool;
    }

    public String dailyReportTitle;
    public String getDailyReportTitle() {
        return this.dailyReportTitle;
    }
    public void setDailyReportTitle(String title) {
        this.dailyReportTitle = title;
    }

    private List<TdrDailyActivityWrapper> getDailyReportsData() {

        List<TdrDailyActivityWrapper> activityWrappers = new List<TdrDailyActivityWrapper>();
        String tdrCurrentName = '';
        for (TDR_Activity__c[] activityList : database.query(TdrHelpers.getTdrDailyActivities(this.tdrSelectorController.getParameters(), false))) {
            for (TDR_Activity__c activity : activityList) {
                Boolean isNewName = false;
                if (!TdrHelpers.generateTdrName(
                        activity.TDR_Performance_Record__r.Person__r.First_Name__c,
                        activity.TDR_Performance_Record__r.Person__r.Last_Name__c).equals(tdrCurrentName)
                ) {
                    isNewName = true;
                    tdrCurrentName = TdrHelpers.generateTdrName(
                        activity.TDR_Performance_Record__r.Person__r.First_Name__c,
                        activity.TDR_Performance_Record__r.Person__r.Last_Name__c
                    );
                }
                String eFloat = '';
                if (activity.eFloat__c != null) {
                    eFloat = String.valueOf(activity.eFloat__c.intValue());
                }
                TdrDailyActivityWrapper wrapper = new TdrDailyActivityWrapper(
                    tdrCurrentName,
                    activity.Activity_Type__c,
                    activity.Start_Time__c,
                    activity.Comment__c,
                    activity.Company_Name__c,
                    activity.Contact_Name__c,
                    activity.Additional_Comments__c,
                    activity.Activity_Conducted__c,
                    eFloat
                );
                wrapper.changeIsFirstRow(isNewName, false);
                activityWrappers.add(wrapper);
            }
        }
        if (activityWrappers.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The are no Sales Reps Activities for the options you have selected'));
            activityWrappers = null;
            setDailyReportTotalPageNumber(0);
        }
        else {
            setShowDailyActivityReport(true);
            Decimal numberOfPages = (Decimal)activityWrappers.size();
            setDailyReportTotalPageNumber(numberOfPages.divide((Decimal)getNumberOfRowsPerPage(), 0, System.RoundingMode.CEILING).intvalue());
        }
        setPaginationButtons();
        return activityWrappers;
    }

    /**
     *  Using the page numbers select the records that should be shown on that page
     */
    private List<TdrDailyActivityWrapper> selectDailyReportsPage() {

        Integer startPoint = (getDailyReportPageNumber() - 1) * getNumberOfRowsPerPage();
        Integer endPoint = startPoint + getNumberOfRowsPerPage() + 1;
        List<TdrDailyActivityWrapper> wrappersToShow = new List<TdrDailyActivityWrapper>();
        if (this.dailyReportsFullList == null) {
            return null;
        }
        if (endPoint > this.dailyReportsFullList.size()) {
            endPoint = this.dailyReportsFullList.size();
        }

        for (Integer i = startPoint; i < endPoint; i++) {
            this.dailyReportsFullList.get(i).checkIsFromPage();
            wrappersToShow.add(this.dailyReportsFullList.get(i));
        }

        // Make sure that the first object is always showing the name
        this.dailyReportsFullList.get(startPoint).changeIsFirstRow(true, true);
        setPaginationButtons();
        return wrappersToShow;
    }

    public Integer dailyReportPageNumber;
    public Integer getDailyReportPageNumber() {
        return this.dailyReportPageNumber;
    }
    public void setDailyReportPageNumber(Integer newNumber) {
        this.dailyReportPageNumber = newNumber;
    }

    public Integer dailyReportTotalPageNumber;
    public Integer getDailyReportTotalPageNumber() {
        return this.dailyReportTotalPageNumber;
    }
    public void setDailyReportTotalPageNumber(Integer newNumber) {
        this.dailyReportTotalPageNumber = newNumber;
    }

    public Integer numberOfRowsPerPage;
    public Integer getNumberOfRowsPerPage() {
        return this.numberOfRowsPerPage;
    }
    public void setNumberOfRowsPerPage(Integer newNumber) {
        this.numberOfRowsPerPage = newNumber;
    }

    // Pagination contollers
    private void setPaginationButtons() {

        setDisableFirstButton(false);
        setDisableNextButton(false);
        setDisablePreviousButton(false);
        setDisableLastButton(false);
        if (getDailyReportTotalPageNumber() == 1) {
            setDisableFirstButton(true);
            setDisableNextButton(true);
            setDisablePreviousButton(true);
            setDisableLastButton(true);
            return;
        }
        if (getDailyReportPageNumber() == 1) {
            setDisableFirstButton(true);
            setDisablePreviousButton(true);
        }
        else if (getDailyReportPageNumber() == getDailyReportTotalPageNumber()) {
            setDisableNextButton(true);
            setDisableLastButton(true);
        }
    }

    public PageReference goToFirstPage() {

        setDailyReportPageNumber(1);
        setDailyReports(selectDailyReportsPage());
        setPaginationButtons();
        return null; 
    }
    public Boolean disableFirstButton;
    public Boolean getDisableFirstButton() {
        return this.disableFirstButton;
    }
    public void setDisableFirstButton(Boolean bool) {
        this.disableFirstButton = bool;
    }

    public PageReference goToNextPage() {

        setDailyReportPageNumber(getDailyReportPageNumber() + 1);
        setDailyReports(selectDailyReportsPage());
        setPaginationButtons();
        return null; 
    }
    public Boolean disableNextButton;
    public Boolean getDisableNextButton() {
        return this.disableNextButton;
    }
    public void setDisableNextButton(Boolean bool) {
        this.disableNextButton = bool;
    }

    public PageReference goToPreviousPage() {

        setDailyReportPageNumber(getDailyReportPageNumber() - 1);
        setDailyReports(selectDailyReportsPage());
        setPaginationButtons();
        return null; 
    }
    public Boolean disablePreviousButton;
    public Boolean getDisablePreviousButton() {
        return this.disablePreviousButton;
    }
    public void setDisablePreviousButton(Boolean bool) {
        this.disablePreviousButton = bool;
    }

    public PageReference goToLastPage() {

        setDailyReportPageNumber(getDailyReportTotalPageNumber());
        setDailyReports(selectDailyReportsPage());
        setPaginationButtons();
        return null; 
    }
    public Boolean disableLastButton;
    public Boolean getDisableLastButton() {
        return this.disableLastButton;
    }
    public void setDisableLastButton(Boolean bool) {
        this.disableLastButton = bool;
    }

    public List<SelectOption> numberOfRows;
    public List<SelectOption> getNumberOfRows() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('10', '10'));
        options.add(new SelectOption('20', '20'));
        options.add(new SelectOption('50', '50'));
        options.add(new SelectOption('100', '100'));
        options.add(new SelectOption('200', '200'));
        return options;
    }
    public void setNumberOfRows(List<SelectOption> options) {
        this.numberOfRows = options;
    }

    public PageReference changePageNumber() {

        setNumberOfRowsPerPage(Integer.valueOf(Apexpages.currentPage().getParameters().get('pageNumberParam')));
        setDailyReportPageNumber(1);
        setDailyReports(selectDailyReportsPage());
        Decimal numberOfPages = this.dailyReportsFullList.size();
        setDailyReportTotalPageNumber(numberOfPages.divide((Decimal)getNumberOfRowsPerPage(), 0, System.RoundingMode.CEILING).intvalue());
        setPaginationButtons();
        return null;
    }

    private TdrSelectorController tdrSelectorController;

    /**
     *  Constructor for the controller
     */
    public TdrGraphController(TdrSelectorController tdrSelectorController) {

        this.tdrSelectorController = tdrSelectorController;
        setUp();
    }

    /**
     *  Set up the page. This is when the page is loaded and also for a page refresh
     */
    public void setUp() {

        // Default the titles
        this.setBarChartHeader('');
        this.setTopTwelveOneHeader('');
        this.setTopTwelveTwoHeader('');
        this.tdrSelectorController.pageBlockTitle = 'Select Graph Options';

        // Default All display options to off
        this.setShowBarGraph(false);
        this.setShowTopTwelveGraphs(false);
        this.setShowTopTwelveGraphOne(false);
        this.setShowTopTwelveGraphTwo(false);

        // Default the settings for the top twelve graph
        this.initTopTweleveFieldMap();
        this.setTopTwelveType('1');

        // Default all the json strings to nothing
        this.setBarGraphData('NONE');
        this.setTopTwelveOneDataString('NONE');
        this.setTopTwelveTwoDataString('NONE');
        this.setTopTwelveHAxis('NONE');
        this.clearBiggestTopTwelveNumber();

        // Set up the variables for the daily reports
        this.setShowDailyActivityReport(false);
        this.setDailyReports(null);
        this.setNumberOfRowsPerPage(10);
        this.setDailyReportTotalPageNumber(1);
        this.setDailyReportPageNumber(1);
        setPaginationButtons();
    }

    public PageReference submitRequest() {

        // Get the parameters from the extended controller
        List<String> paramResponse = this.tdrSelectorController.getTdrParameters();
        if (paramResponse.get(0).equals('0')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, paramResponse.get(1)));
            return null;
        }

        // Get the params from the check boxes
        this.setShowBarGraph(Boolean.valueOf(Apexpages.currentPage().getParameters().get('showBarGraphParam')));
        this.setShowTopTwelveGraphs(Boolean.valueOf(Apexpages.currentPage().getParameters().get('topTwelveParam')));
        this.setShowTopTwelveGraphOne(Boolean.valueOf(Apexpages.currentPage().getParameters().get('topTwelveParam')));
        this.setShowTopTwelveGraphTwo(Boolean.valueOf(Apexpages.currentPage().getParameters().get('topTwelveComparisonParam')));
        this.setTopTwelveType(String.valueOf(Apexpages.currentPage().getParameters().get('topTwelveTypeParam')));
        this.setShowDailyActivityReport(Boolean.valueOf(Apexpages.currentPage().getParameters().get('showDailyActivityReportParam')));

        // Default all the json strings to nothing
        setBarGraphData('NONE');
        setTopTwelveOneDataString('NONE');
        setTopTwelveTwoDataString('NONE');
        try {
            if (getShowBarGraph()) {
                setBarGraphData(generateBarGraphData());
                setBarChartHeader(generateGeneralTitle());
            }
            if (getShowTopTwelveGraphOne()) {
                this.clearBiggestTopTwelveNumber();
                setTopTwelveOneDataString(generateTopTwelveDataString(setTopTwelveColumns(), setTopTwelveRows('ONE'), 'ONE'));
                setTopTwelveOneHeader(generateTopTwelveHeader('ONE'));
            }
            if (getShowTopTwelveGraphTwo()) {
                setTopTwelveTwoDataString(generateTopTwelveDataString(setTopTwelveColumns(), setTopTwelveRows('TWO'), 'TWO'));
                setTopTwelveTwoHeader(generateTopTwelveHeader('TWO'));
            }
            if (getShowDailyActivityReport()) {
                setShowDailyActivityReport(false);
                setDailyReportPageNumber(1);
                this.dailyReportsFullList = getDailyReportsData();
                setDailyReports(selectDailyReportsPage());
                setPaginationButtons();
            }
        }
        catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occured. Please try again. If the issue persists contact support'));
        }

        // Load the required Graph details
        return null;
    }

    /**
     * Turn a bunch of rows and columns in to a javascript literal string
     */
    private String generateJsonDataTable(List<GraphColumnWrapper> columns, List<TdrGraphController.TdrGraphRowWrapper> rows) {

        // Check that there is actually some data to show. Display a page error if there is not
        Integer numberOfColumns = columns.size();
        Integer numberOfRows = rows.size();
        if (numberOfColumns == 0 || numberOfRows == 0) {
            return 'FAIL';
        }

        // Generate the JSON string for the data table
        String jsonString = '{cols: [';
        Integer i;
        for (i = 0; i < numberOfColumns; i++) {
            jsonString += columns.get(i).toJsonString();
            if (i < numberOfColumns - 1) {
                jsonString += ', ';
            }
        }
        jsonString += '], rows: [';
        for (i = 0; i < numberOfRows; i++) {
            jsonString += rows.get(i).toJsonString();
            if (i < numberOfRows - 1) {
                jsonString += ', ';
            }
        }
        jsonString += ']}';
        System.debug(LoggingLevel.INFO, jsonString);
        return jsonString;
    }

    /**
     *  Generate the general part of the titles
     */
    private String generateGeneralTitle() {

        String title = '';

        // Pick out the date type
        String timePeriod = this.tdrSelectorController.getParameter('type');
        Boolean hasEndDate;
        if (!this.tdrSelectorController.getParameter('endDate').equals('')) { 
            hasEndDate = TdrHelpers.convertSoqlStringToDate(this.tdrSelectorController.getParameter('startDate')).isSameDay(TdrHelpers.convertSoqlStringToDate(this.tdrSelectorController.getParameter('endDate')));
        }
        else {
            hasEndDate = false;
        }
        if (timePeriod.equals('DAILY')) {
            if (hasEndDate) {
                title = 'days between ' +
                    this.tdrSelectorController.getParameter('startDate') +
                    ' and ' +
                    this.tdrSelectorController.getParameter('endDate');
            }
            else {
                title = this.tdrSelectorController.getParameter('startDate');
            }
            
        }
        else if (timePeriod.equals('WEEKLY')) {
            if (hasEndDate) {
                title = 'weeks between ' +
                    this.tdrSelectorController.getParameter('startDate') +
                    ' and ' +
                    this.tdrSelectorController.getParameter('endDate');
            }
            else {
                title = 'week beginning ' +
                    this.tdrSelectorController.getParameter('startDate');
            }
        }
        else if (timePeriod.equals('MONTHLY')) {
            title = this.tdrSelectorController.getParameter('month') + ' ' + this.tdrSelectorController.getParameter('year');
        }
        else {
            title = this.tdrSelectorController.getParameter('year');
        }
        title += ' ' + TdrHelpers.getLocationTitle(this.tdrSelectorController.getParameters());
        return title;
    }

    // test Methods for main class
    static testMethod void testGenerateTitle() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        PageReference pageRef = Page.TdrGraph;
        pageRef.getParameters().put('countryParam', country.Id);
        pageRef.getParameters().put('regionParam', region.Id);
        pageRef.getParameters().put('tdrParam', '');
        pageRef.getParameters().put('yearParam', '2011');
        pageRef.getParameters().put('monthParam', '');
        pageRef.getParameters().put('weeklyRangeStartParam', '');
        pageRef.getParameters().put('weeklyRangeEndParam', '');
        pageRef.getParameters().put('showWeeklyParam', 'false');
        pageRef.getParameters().put('showBarGraphParam', 'true');
        pageRef.getParameters().put('topTwelveParam', 'true');
        pageRef.getParameters().put('topTwelveParam', 'true');
        pageRef.getParameters().put('topTwelveComparisonParam', 'true');
        pageRef.getParameters().put('topTwelveTypeParam', 'true');
        pageRef.getParameters().put('showDailyActivityReportParam', 'true');
        Test.setCurrentPage(pageRef);
        TdrGraphController controller = new TdrGraphController(new TdrSelectorController());
        controller.setTopTwelveType('1');
        controller.tdrSelectorController.getTdrParameters();
        controller.setBarChartHeader(controller.generateGeneralTitle());
        controller.generateTopTwelveHeader('ONE');

        pageRef.getParameters().put('monthParam', '11');
        controller.setTopTwelveType('2');
        controller.tdrSelectorController.getTdrParameters();
        controller.setBarChartHeader(controller.generateGeneralTitle());
        controller.generateTopTwelveHeader('ONE');

        pageRef.getParameters().put('weeklyRangeStartParam', '11/11/2011');
        pageRef.getParameters().put('weeklyRangeEndParam', '11/11/2011');
        pageRef.getParameters().put('showWeeklyParam', 'false');
        controller.setTopTwelveType('3');
        controller.tdrSelectorController.getTdrParameters();
        controller.setBarChartHeader(controller.generateGeneralTitle());
        controller.generateTopTwelveHeader('TWO');

        pageRef.getParameters().put('showWeeklyParam', 'false');
        controller.setTopTwelveType('4');
        controller.tdrSelectorController.getTdrParameters();
        controller.setBarChartHeader(controller.generateGeneralTitle());
        controller.generateTopTwelveHeader('ONE');
    }

    static testMethod void testAllCountryLevelYearly() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        PageReference pageRef = Page.TdrGraph;
        pageRef.getParameters().put('countryParam', country.Id);
        pageRef.getParameters().put('regionParam', '');
        pageRef.getParameters().put('tdrParam', '');
        pageRef.getParameters().put('yearParam', '2011');
        pageRef.getParameters().put('monthParam', '');
        pageRef.getParameters().put('weeklyRangeStartParam', '');
        pageRef.getParameters().put('weeklyRangeEndParam', '');
        pageRef.getParameters().put('showWeeklyParam', 'false');
        pageRef.getParameters().put('showBarGraphParam', 'true');
        pageRef.getParameters().put('topTwelveParam', 'true');
        pageRef.getParameters().put('topTwelveParam', 'true');
        pageRef.getParameters().put('topTwelveComparisonParam', 'true');
        pageRef.getParameters().put('topTwelveTypeParam', 'true');
        pageRef.getParameters().put('showDailyActivityReportParam', 'true');
        Test.setCurrentPage(pageRef);
        TdrGraphController controller = new TdrGraphController(new TdrSelectorController());
        controller.submitRequest();
    }

    static testMethod void testAllMonthly() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        PageReference pageRef = Page.TdrGraph;
        pageRef.getParameters().put('countryParam', country.Id);
        pageRef.getParameters().put('regionParam', region.Id);
        pageRef.getParameters().put('tdrParam', '');
        pageRef.getParameters().put('yearParam', '2011');
        pageRef.getParameters().put('monthParam', '11');
        pageRef.getParameters().put('weeklyRangeStartParam', '');
        pageRef.getParameters().put('weeklyRangeEndParam', '');
        pageRef.getParameters().put('showWeeklyParam', 'false');
        pageRef.getParameters().put('showBarGraphParam', 'true');
        pageRef.getParameters().put('topTwelveParam', 'true');
        pageRef.getParameters().put('topTwelveParam', 'true');
        pageRef.getParameters().put('topTwelveComparisonParam', 'true');
        pageRef.getParameters().put('topTwelveTypeParam', 'true');
        pageRef.getParameters().put('showDailyActivityReportParam', 'true');
        Test.setCurrentPage(pageRef);
        TdrGraphController controller = new TdrGraphController(new TdrSelectorController());
        controller.submitRequest();
    }

    static testMethod void testAllWeekly() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        PageReference pageRef = Page.TdrGraph;
        pageRef.getParameters().put('countryParam', country.Id);
        pageRef.getParameters().put('regionParam', region.Id);
        pageRef.getParameters().put('tdrParam', '');
        pageRef.getParameters().put('yearParam', '2011');
        pageRef.getParameters().put('monthParam', '11');
        pageRef.getParameters().put('weeklyRangeStartParam', '11/28/2011');
        pageRef.getParameters().put('weeklyRangeEndParam', '11/30/2011');
        pageRef.getParameters().put('showWeeklyParam', 'true');
        pageRef.getParameters().put('showBarGraphParam', 'true');
        pageRef.getParameters().put('topTwelveParam', 'true');
        pageRef.getParameters().put('topTwelveParam', 'true');
        pageRef.getParameters().put('topTwelveComparisonParam', 'true');
        pageRef.getParameters().put('topTwelveTypeParam', 'true');
        pageRef.getParameters().put('showDailyActivityReportParam', 'true');
        Test.setCurrentPage(pageRef);
        TdrGraphController controller = new TdrGraphController(new TdrSelectorController());
        controller.submitRequest();
    }

    static testMethod void testAllDaily() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        // Create a TDR for each region
        Person__c person = Utils.createTestPerson(null, 'TestingTDR', true, null, 'Female');
        person.Region__c = region.Id;
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

        PageReference pageRef = Page.TdrGraph;
        pageRef.getParameters().put('countryParam', country.Id);
        pageRef.getParameters().put('regionParam', region.Id);
        pageRef.getParameters().put('tdrParam', person.Id);
        pageRef.getParameters().put('yearParam', '2011');
        pageRef.getParameters().put('monthParam', '11');
        pageRef.getParameters().put('weeklyRangeStartParam', TdrHelpers.convertDateToNonSoqlString(DateTime.newInstance(now, newTime)));
        pageRef.getParameters().put('weeklyRangeEndParam', TdrHelpers.convertDateToNonSoqlString(DateTime.newInstance(now, newTime)));
        pageRef.getParameters().put('showWeeklyParam', 'false');
        pageRef.getParameters().put('showBarGraphParam', 'true');
        pageRef.getParameters().put('topTwelveParam', 'true');
        pageRef.getParameters().put('topTwelveParam', 'true');
        pageRef.getParameters().put('topTwelveComparisonParam', 'true');
        pageRef.getParameters().put('topTwelveTypeParam', 'true');
        pageRef.getParameters().put('showDailyActivityReportParam', 'true');
        Test.setCurrentPage(pageRef);
        TdrGraphController controller = new TdrGraphController(new TdrSelectorController());
        controller.submitRequest();
    }

    static testMethod void testGetDailyActivities() {

        // Create a country
        Country__c country = Utils.createTestCountry('NEW COUNTRY');
        database.insert(country);

        // Create a region
        Region__c region = Utils.createTestRegion('NEW REGION', country);
        database.insert(region);

        // Create a TDR for each region
        Person__c person = Utils.createTestPerson(null, 'TestingTDR', true, null, 'Female');
        person.Region__c = region.Id;
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
        Database.insert(activities);

        PageReference pageRef = Page.TdrGraph;
        pageRef.getParameters().put('countryParam', country.Id);
        pageRef.getParameters().put('regionParam', region.Id);
        pageRef.getParameters().put('tdrParam', person.Id);
        pageRef.getParameters().put('yearParam', '2011');
        pageRef.getParameters().put('monthParam', '11');
        pageRef.getParameters().put('weeklyRangeStartParam', TdrHelpers.convertDateToNonSoqlString(DateTime.newInstance(now, newTime)));
        pageRef.getParameters().put('weeklyRangeEndParam', TdrHelpers.convertDateToNonSoqlString(DateTime.newInstance(now, newTime)));
        pageRef.getParameters().put('showWeeklyParam', 'false');
        pageRef.getParameters().put('showBarGraphParam', 'true');
        pageRef.getParameters().put('topTwelveParam', 'true');
        pageRef.getParameters().put('topTwelveParam', 'true');
        pageRef.getParameters().put('topTwelveComparisonParam', 'true');
        pageRef.getParameters().put('topTwelveTypeParam', 'true');
        pageRef.getParameters().put('showDailyActivityReportParam', 'true');
        pageRef.getParameters().put('pageNumberParam', '100');
        Test.setCurrentPage(pageRef);
        TdrGraphController controller = new TdrGraphController(new TdrSelectorController());
        controller.tdrSelectorController.getTdrParameters();
        controller.setShowDailyActivityReport(false);
        controller.setDailyReportPageNumber(1);
        controller.dailyReportsFullList = controller.getDailyReportsData();
        controller.setDailyReports(controller.selectDailyReportsPage());
        controller.setPaginationButtons();
        controller.setShowDailyActivityReport(true);
        controller.setDisableFirstButton(true);
        controller.setDisableNextButton(true);
        controller.setDisablePreviousButton(true);
        controller.setDisableLastButton(true);
        controller.changePageNumber();
    }

    /**
     *  Public class for the bar graph columns
     */
     public class TdrGraphRowWrapper {

        private String header;
        private List<String> values;

        public TdrGraphRowWrapper(
                String header
        ) {
            this.header = header;
            this.values = new List<String>();
        }

        public void addValue(String value) {
            this.values.add(value);
        }

        public String toJsonString() {

            String jsonString = '{c:[{v:\'' + this.header + '\'}';
            for (Integer i = 0; i < values.size(); i++) {
                jsonString += ', {v: ' + this.values.get(i) + ' }';
            }
            jsonString += ']}';
            return jsonString;
        }
     }

    /**
     *  Wrapper class for the daily summary
     */
    public class TdrSummaryWrapper {

        public String tdrName { get; set; }
        public Integer minutesWorked { get; set; }
        public Integer activitiesCarriedOut { get; set; }
        public Integer targets { get; set; }
        public Integer difference { get; set; }

        // Indicate if this is the first row of a person. This means we do not have to show the name again
        public Boolean isFirstRow { get; set; }
        private Boolean isFromPage;

        public TdrSummaryWrapper(
            String tdrName,
            Integer minutesWorked,
            Integer activitiesCarriedOut,
            Integer targets
        ) {
            this.tdrName = tdrName;
            this.minutesWorked = minutesWorked;
            this.activitiesCarriedOut = activitiesCarriedOut;
            this.targets = targets;
            this.difference = activitiesCarriedOut - targets;

            // Default this to false. It will be updated by the controller if required
            this.isFirstRow = false;
            this.isFromPage = false;
        }

        public void changeIsFirstRow(Boolean isFirst, Boolean isFromPage) {

            // If this object is already the first row due to it being the first object of the day
            // then leave that set and dont set isFromPage
            if (this.isFirstRow) {
                return;
            }
            this.isFirstRow = isFirst;
            this.isFromPage = isFromPage;
        }

        /**
         *  Checkt to see if the show name was set from pagination. If it was then remove the bool value
         */
        public void checkIsFromPage() {

            if (!isFromPage) {
                return;
            }
            if (isFromPage) {
                this.isFirstRow = false;
            }
        }
    }

    static testMethod void testTdrSummaryWrapperAll() {

        TdrGraphController.TdrSummaryWrapper wrapper = new TdrGraphController.TdrSummaryWrapper(
            'Name',
            100,
            2,
            3
        );
        System.assertEquals(wrapper.isFirstRow, false);
        wrapper.changeIsFirstRow(true, true);
        System.assert(wrapper.isFirstRow);
        System.assert(wrapper.isFromPage);
        wrapper.checkIsFromPage();
        System.assertEquals(wrapper.isFirstRow, false);
    }

    /**
     *  Wrapper class for the daily activities
     */
    public class TdrDailyActivityWrapper {

        public String tdrName { get; set; }
        public String activity { get; set; }
        public DateTime startTime { get; set; }
        public String comment { get; set; }
        public String companyName { get; set; }
        public String contactName { get; set; }
        public String generalComment { get; set; }
        public String activityConducted { get; set; }
        public String eFloat { get; set; }

        // Indicate if this is the first row of a person. This means we do not have to show the name again
        public Boolean isFirstRow { get; set; }
        private Boolean isFromPage;

        public TdrDailyActivityWrapper(
                String tdrName,
                String activity,
                DateTime startTime,
                String comment,
                String companyName,
                String contactName,
                String generalComment,
                String activityConducted,
                String eFloat
        ) {
            this.tdrName = tdrName;
            this.activity = activity;
            this.startTime = startTime;
            this.comment = comment;
            this.companyName = companyName;
            this.contactName = contactName;
            this.generalComment = generalComment;
            this.activityConducted = activityConducted;
            this.eFloat = eFloat;

            // Default this to false. It will be updated by the controller if required
            this.isFirstRow = false;
            this.isFromPage = false;
        }

        public void changeIsFirstRow(Boolean isFirst, Boolean isFromPage) {

            // If this object is already the first row due to it being the first object of the day
            // then leave that set and dont set isFromPage
            if (this.isFirstRow) {
                return;
            }
            this.isFirstRow = isFirst;
            this.isFromPage = isFromPage;
        }

        /**
         *  Checkt to see if the show name was set from pagination. If it was then remove the bool value
         */
        public void checkIsFromPage() {

            if (!isFromPage) {
                return;
            }
            if (isFromPage) {
                this.isFirstRow = false;
            }
        }
    }

    static testMethod void testTdrDailyActivityWrapperAll() {

        TdrGraphController.TdrDailyActivityWrapper wrapper = new TdrGraphController.TdrDailyActivityWrapper(
            'Name',
            'Activity',
            DateTime.newInstance(Date.today(), Time.newInstance(10, 10, 10, 10)),
            'Comment',
            'Company',
            'Contact',
            'General Comment',
            'Activity Conducted',
            '1'
        );
        System.assertEquals(wrapper.isFirstRow, false);
        wrapper.changeIsFirstRow(true, true);
        System.assert(wrapper.isFirstRow);
        System.assert(wrapper.isFromPage);
        wrapper.checkIsFromPage();
        System.assertEquals(wrapper.isFirstRow, false);
    }
}