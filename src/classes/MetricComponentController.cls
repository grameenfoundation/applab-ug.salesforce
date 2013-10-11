public with sharing class MetricComponentController extends ChildComponentBase {

    private String isRefresh;
    public String getIsRefresh() {
        if (isRefresh == null) {
            isRefresh = 'false';
        }
        return this.isRefresh;
    }
    public void setIsRefresh(String value) {
        this.isRefresh = value;
    }

    public override sObject getsObjectRecord() {
        if (this.sObjectRecord == null) {
            if(!loadMetricSection()) {
                return null;
            }
        }
        return this.sObjectRecord;
    }
    public override void setsObjectRecord(sObject value) {
        this.sObjectName = 'Metric_Section__c';
        this.sObjectId = value.Id;
        this.sObjectRecord = value;
        this.setDatePeriodField('RollOver_Time__c');
    }
    private Boolean loadMetricSection() {

        if (this.sObjectId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No metric section identifier provided. Cannot load metric section'));
            return false;
        }
        Metric_Section__c[] section = [SELECT
                Id,
                Name,
                Title__c,
                Dashboard_Section__r.Dashboard__r.Account__r.Name,
                Description__c,
                RollOver_Time__c,
                Start_Date__c,
                Show_Spark_Line__c,
                Show_RollOver_Selector__c,
                Show_Targets__c,
                Show_Previous_Quarter__c,
                Show_Comments__c,
                Show_Break_Down__c,
                Show_Further_Link__c,
                Default_Show__c,
                Allow_Update__c
            FROM
                Metric_Section__c
            WHERE
                Id = :this.sObjectId
                AND Is_Active__c = true
        ];
        if (section.size() != 1) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No active metric section found for id ' + this.sObjectId + '. Please check your set up. Contact support if this persists'));
            return false;
        }
        setsObjectRecord((sObject)section[0]);
        return true;
    }

    // Getters for field values needed by component
    public String getTitle() {
        return getFieldValue('title__c');
    }

    public String getDescription() {
        return getFieldValue('description__c');
    }

    public String getRollOverTime() {
        return getFieldValue('rollover_time__c');
    }

    public Boolean getShowTargets() {
        return Boolean.valueOf(getFieldValue('show_targets__c'));
    }

    public Boolean getShowPreviousQuarter() {
        return Boolean.valueOf(getFieldValue('show_previous_quarter__c'));
    }

    public Boolean getShowComments() {
        return Boolean.valueOf(getFieldValue('show_comments__c'));
    }

    public Boolean getShowBreakDown() {
        return Boolean.valueOf(getFieldValue('show_break_down__c'));
    }

    public Boolean getShowSparkLine() {
        return Boolean.valueOf(getFieldValue('show_spark_line__c'));
    }

    public Boolean getShowFurtherLink() {
        return Boolean.valueOf(getFieldValue('show_further_link__c'));
    }

    public Boolean getAllowUpdate() {
        return Boolean.valueOf(getFieldValue('allow_update__c'));
    }

    private Boolean isEditMode = false;
    public Boolean getIsEditMode() {
        if(getAllowUpdate() && this.isEditMode) {
            return true;
        }
        return false;
    }
    public void setIsEditMode(Boolean value) {
        this.isEditMode = value;
    }

    private String currentDate;
    public String getCurrentDate() {
        return this.currentDate;
    }
    public void setCurrentDate(String value) {
        if (value.equals('')) {
            value = MetricHelpers.createDispRollOverString(Date.today(), getRollOverPeriod());
        }
        this.currentDate = value;
    }

    private Boolean loaded = false;

    private List<String> metricIds;
    public List<String> getMetricIds() {
        if (!loaded) {
            if (this.fieldMap == null) {
                initFieldMap('Metric_Section__c');
            }
            loadMetricDatas();
        }
        loaded = true;
        return this.metricIds;
    }
    public void setMetricIds(List<String> values) {
        this.metricIds = values;
    }

    private List<MetricDataWrapper> metricDatas;
    public List<MetricDataWrapper> getMetricDatas() {
        if (!loaded) {
            if (this.fieldMap == null) {
                initFieldMap('Metric_Section__c');
            }
            loadMetricDatas();
        }
        loaded = true;
        return this.metricDatas;
    }
    public void setMetricDatas(List<MetricDataWrapper> values) {
        this.metricDatas = values;
    }
    private Boolean loadMetricDatas() {

        if (this.sObjectRecord == null) {
            if (!loadMetricSection()) {
                return false;
            }
        }

        if (this.getParentComponentController() != null) {
           this.getParentComponentController().rebuildParameters();
        }

        this.metricDatas = new List<MetricDataWrapper>();
        this.metricIds = new List<String>();       

         if ((String.valueOf(getFieldValue('View_Mode__c')).equalsIgnoreCase('Aggregated')) && !(Boolean.valueOf(getIsRefresh()))) {
            String[] startDateArray = getFieldValue('Start_Date__c').split('==');
            setStartDate((DateTime.newInstance(integer.valueOf(startDateArray[0]), integer.valueOf(startDateArray[1]), integer.valueOf(startDateArray[2]))).date());
            setEndDate((datetime.now()).date());
            return loadAggregateMetrics();
        } 
         else if (setDates()) {
            return loadAggregateMetrics();
        }
        else {
            setStartDate(MetricHelpers.decreaseDateRollOver(getStartDate(), getRollOverPeriod()));
            return loadStandardMetrics();
        }
    }

    /**
     * Load metrics in a date range. This will aggregate all the metrics that were created in the given time
     * period. Does not at the moment allow for targets to be set and will not allow to show previous time periods
     * as that makes no sense.
     *
     * @return - Boolean indicating success
     */
    private Boolean loadAggregateMetrics() {

        String query =
            'SELECT ' +
                'SUM(Numerator__c) num, ' +
                'SUM(Denumerator__c) denum, ' +
                'SUM(Real_Value__c) realValue, ' +
                'COUNT(Id) total, ' +
                'M_E_Metric__c metricId ' +
            'FROM ' +
                'M_E_Metric_Data__c ' +
            generateWhereClause() +
            ' GROUP BY ' +
                'M_E_Metric__c';
        System.debug(LoggingLevel.INFO, query);

        // Add the aggregate results to the map
        Map<String, MetricDataWrapper> wrappers = new Map<String, MetricDataWrapper>();
        for (AggregateResult res : Database.query(query)) {
            MetricDataWrapper wrapper = new MetricDataWrapper();
            wrapper.setCurrentTotal((Decimal)res.get('total'));
            wrapper.setCurrentRealValue((Decimal)res.get('realValue'));
            wrapper.setCurrentNumerator((Decimal)res.get('num'));
            wrapper.setCurrentDenumerator((Decimal)res.get('denum'));
            wrapper.setIsAggregate(true);
            wrapper.setHasCurrent(true);
            wrappers.put(String.valueOf(res.get('metricId')), wrapper);
        }
        if (wrappers.size() == 0) {
            return false;
        }

        // Get the M_E_Metric__c that are needed. Add the details to the wrapper objects
        for (M_E_Metric__c metric : [
                SELECT
                    Id,
                    Name,
                    Update_Period__c,
                    Label__c,
                    Sub_Area__c,
                    Is_Header__c,
                    Further_Link_Url__c,
                    Further_Link_Text__c,
                    Is_On_Fly__c,
                    On_The_Fly_Calculation_Type__c
                FROM
                    M_E_Metric__c
                WHERE
                    Id IN :wrappers.keySet()
        ]) {
            MetricDataWrapper wrapper = wrappers.get(metric.Id);
            if (wrapper == null) {
                continue;
            }
            wrapper.isHeader = metric.Is_Header__c;
            wrapper.updatePeriod = metric.Update_Period__c;
            wrapper.setLabel(metric.Label__c);
            wrapper.setSubArea(metric.Sub_Area__c);
            wrapper.setFurtherLinkUrl(metric.Further_Link_Url__c);
            wrapper.setFurtherLinkText(metric.Further_Link_Text__c);
            wrapper.setOnFly(metric.Is_On_Fly__c);
            wrapper.setCalculation(metric.On_The_Fly_Calculation_Type__c);
            wrapper.setName(metric.Name);
        }
        this.metricDatas.addAll(wrappers.values());
        this.metricDatas.sort();
        wrappers.clear();
        return true;
    }

    /**
     * Load metrics in the standard method. This will load the metric that the is for the date chosen
     * by the metric date selector. The previous date period metric will be loaded as well
     *
     * @return - Boolean indicating success
     */
    private Boolean loadStandardMetrics() {

        String query =
            getSelectClause() +
            generateLegacyWhereClause() +
            ' ORDER BY ' +
                'M_E_Metric__r.Order__c ASC, ' +
                'M_E_Metric__r.Name, ' +
                'District__r.Name, ' +
                'Subcounty__r.Display_Name__c, ' +
                'Date__c ASC ';

        System.debug(LoggingLevel.INFO, query);

        String metricName = '';
        MetricDataWrapper metricDataWrapper = null;
        for (M_E_Metric_Data__c metric : database.query(query)) {

            // See if we have a valid metric name and that it is not the same as the next metric in the list.
            // If it isn't then we need to save the metric from the last loop and move on to a new metric
            if (!metricName.equals(metric.M_E_Metric__r.Name)) {

                // Save the previous object to the list
                if (metricDataWrapper != null) {
                    this.metricDatas.add(metricDataWrapper);
                }

                // Create the new object and update the name if the new name is valid
                metricDataWrapper = new MetricDataWrapper();
                if (metric.M_E_Metric__r.Name == null) {
                    metricName = '';
                    metricDataWrapper = null;
                    System.debug(LoggingLevel.INFO, 'No metric__r.Name');
                    continue;
                }
                metricName = metric.M_E_Metric__r.Name;
            }

            // Indicate if this is a header or not
            metricDataWrapper.isHeader = metric.M_E_Metric__r.Is_Header__c;
            if (metric.Person__c != null) {
                metricDataWrapper.setFirstName(metric.Person__r.First_Name__c);
                metricDataWrapper.setLastName(metric.Person__r.Last_Name__c);
            }
            if (metric.District__c != null) {
                metricDataWrapper.setDistrictName(metric.District__r.Name);
            }
            metricDataWrapper.setSubArea(metric.M_E_Metric__r.Sub_Area__c);
            metricDataWrapper.setLabel(metric.M_E_Metric__r.Label__c);
            metricDataWrapper.setName(metricName);
            metricDataWrapper.isHeader = metric.M_E_Metric__r.Is_Header__c;
            metricDataWrapper.updatePeriod = metric.M_E_Metric__r.Update_Period__c;
            metricDataWrapper.setMetricId(metric.M_E_Metric__r.Id);

            // See which quarter the metric is for.
            if (getStartDate().dayOfYear() <= metric.Date__c.dayOfYear() && getStartDate().year() == metric.Date__c.year()) {

                // Current quarter
                metricDataWrapper.setHasCurrent(true);
                metricDataWrapper.setCurrentId(metric.Id);
                metricDataWrapper.setCurrentRealValue(metric.Real_Value__c);
                metricDataWrapper.setCurrentNumerator(metric.Numerator__c);
                metricDataWrapper.setCurrentDenumerator(metric.Denumerator__c);
                metricDataWrapper.setCurrentTarget(metric.Projected_Value__c);
                metricDataWrapper.setFurtherLinkText(metric.M_E_Metric__r.Further_Link_Text__c);
                metricDataWrapper.setFurtherLinkUrl(metric.M_E_Metric__r.Further_Link_Url__c);
                metricDataWrapper.setReverseComparison(metric.M_E_Metric__r.Reverse_Comparison__c);
                metricDataWrapper.setComment(metric.Comment__c);
                metricDataWrapper.setOnFly(metric.M_E_Metric__r.Is_On_Fly__c);
                metricDataWrapper.setCalculation(metric.M_E_Metric__r.On_The_Fly_Calculation_Type__c);
                this.metricIds.add(metric.Id);
            }
            else {

                // Previous quarter
                metricDataWrapper.setPreviousId(metric.Id);
                metricDataWrapper.setPreviousRealValue(metric.Real_Value__c);
                metricDataWrapper.setPreviousNumerator(metric.Numerator__c);
                metricDataWrapper.setPreviousDenumerator(metric.Denumerator__c);
                metricDataWrapper.setPreviousTarget(metric.Projected_Value__c);
            }

            // Get sparkLine
            if (getShowSparkLine()) {
                metricDataWrapper.setSparkUrl(metric.M_E_Metric__c);
            }
        }

        // Add the last object
        if (metricDataWrapper != null) {
            this.metricDatas.add(metricDataWrapper);
        }
        return true;
    }

    /**
     * Get the basic select clause
     *
     * @return - The base select string for the metric query
     */
    private String getSelectClause() {

        return 'SELECT ' +
                'Id, ' +
                'M_E_Metric__c, ' +
                'Actual_Value__c, ' +
                'Manual_Value__c, ' +
                'Real_Value__c, ' +
                'Projected_Value__c, ' +
                'Comment__c, ' +
                'Date__c, ' +
                'Numerator__c, ' +
                'Denumerator__c, ' +
                'Person__c, ' +
                'Person__r.First_Name__c, ' +
                'Person__r.Last_Name__c, ' +
                'District__c, ' +
                'District__r.Name, ' +
                'M_E_Metric__r.Name, ' +
                'M_E_Metric__r.Update_Period__c, ' +
                'M_E_Metric__r.Label__c, ' +
                'M_E_Metric__r.Sub_Area__c, ' +
                'M_E_Metric__r.Is_Header__c,' +
                'M_E_Metric__r.Further_Link_Url__c, ' +
                'M_E_Metric__r.Further_Link_Text__c, ' +
                'M_E_Metric__r.Calculation_Type__c, ' +
                'M_E_Metric__r.Is_On_Fly__c, ' +
                'M_E_Metric__r.On_The_Fly_Calculation_Type__c, ' +
                'M_E_Metric__r.Reverse_Comparison__c ' +
            'FROM ' +
                'M_E_Metric_Data__c ';
    }

    /**
     * Generate the where clause. The legacy one is for the old style location drill down
     *
     * @return - The where clauses with the WHERE at the start
     */
    private String generateWhereClause() {

        String whereClause = '';
        List<String> whereClauses = getStandardWhereClause();

        if (!getParentValue('Region__c').equals('')) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Subcounty__r.District__r.Region__c', getParentValue('Region__c'), true));
        }
        if (!getParentValue('District__c').equals('')) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Subcounty__r.District__c', getParentValue('District__c'), true));
        }
        if (!getParentValue('Subcounty__c').equals('')) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Subcounty__c', getParentValue('Subcounty__c'), true));
        }

        // Add a person clause if required
        if (!getParentValue('Person__c').equals('')) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Person__c', getParentValue('Person__c'), true));
        }
        else {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Person__c', 'null', false));
        }
        
                // Add a CIW clause if required
        if (!getParentValue('CIW__c').equals('')) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'BVAT_CIW__c', getParentValue('CIW__c'), true));
        }
        
        //Add a Kenyan county if required
        if (!getParentValue('Kenyan_County__c').equals('')) {
            whereClauses.add('BVAT_CIW__c IN (SELECT CIW__c FROM CIW_County_Association__c WHERE Kenyan_County__c =\'' + getParentValue('Kenyan_County__c') + '\')');
        }

        whereClause = ' WHERE ' + SoqlHelpers.joinWhereClause(whereClauses, false);
        return whereClause;
    }
    private String generateLegacyWhereClause() {

        String whereClause = '';
        List<String> whereClauses = getStandardWhereClause();

        // Check to see if we have a district to check.
        if (!getParentValue('District__c').equals('') && getParentValue('Person__c').equals('')) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'District__c', getParentValue('District__c'), true));
        }
        else {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'District__c', 'null', false));
        }

        // Add a person clause if required
        if (!getParentValue('Person__c').equals('')) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Person__c', getParentValue('Person__c'), true));
        }
        else {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Person__c', 'null', false));
        }
        
        // Add a CIW clause if required
        if (!getParentValue('CIW__c').equals('')) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'BVAT_CIW__c', getParentValue('CIW__c'), true));
        }
        
        //Add a Kenyan county if required
        if (!getParentValue('Kenyan_County__c').equals('')) {
            whereClauses.add('BVAT_CIW__c IN (SELECT CIW__c FROM CIW_County_Association__c WHERE Kenyan_County__c =\'' + getParentValue('Kenyan_County__c') + '\')');
        }
        whereClause = ' WHERE ' + SoqlHelpers.joinWhereClause(whereClauses, false);
        return whereClause;
    }
    private List<String> getStandardWhereClause() {

        List<String> whereClauses = new List<String>();
        if (UserInfo.getUserType() == 'GUEST') {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('!=', 'M_E_Metric__r.Not_For_Public__c', 'true', false));
        }

        // Distinguish by dates
        if (getStartDate(false) != null) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('>=', 'Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToStartDate(getStartDate(false)), true), false));
        }
        if (getEndDate(false) != null) {
            whereClauses.add(SoqlHelpers.buildStandardWhereClause('<=', 'Date__c', MetricHelpers.convertDateTimeToString(MetricHelpers.convertToEndDate(getEndDate(false)), true), false));
        }

        // Add the standard clauses
        whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'M_E_Metric__r.Metric_Section__r.Name', getFieldValue('Name'), true));
        whereClauses.add(SoqlHelpers.buildStandardWhereClause('=', 'Is_Cumulative__c', 'false', false));
        return whereClauses;
    }


    /**
     * Get the display type for each row of the metric display
     */
     public String getUpdateType() {

        String returnValue = 'Country';
        if (!getParentValue('Person__c').equals('')) {

            // Showing metric by district
            returnValue = 'Person';
        }
        else if (!getParentValue('District__c').equals('')) {
            returnValue = 'District';
        }
        return returnValue;
     }

    public override PageReference refreshData() {

        try {
            setIsRefresh('true');
            loadMetricDatas();
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occured whilst refreshing the data. If the problem persists please contact support'));
            System.debug(LoggingLevel.INFO, e.getMessage());
        }
        return null;
    }

    // Get a person who is being looked at so we can just see their breakdown
    public String getPerson() {
        return getParentValue('Person__c');
    }

    // Get the district id for the breakdown
    public String getDistrict() {
        return getParentValue('District__c');
    }

    public String getSectionId() {
        return getFieldValue('id');
    }

    public String getSelectorId() {
        return getParentValue('SelectorId');
    }

    private String getRollOverPeriod() {
        String rollOverPeriod = getParentValue('DatePeriod');
        if (rollOverPeriod.equals('')) {
            rollOverPeriod = 'Yearly';
        }
        return rollOverPeriod;
    }

    static testMethod void testController() {

        Account account = new Account();
        account.Name = 'the';
        account.BillingState = 'CA';
        Database.insert(account);

        Dashboard__c dash = new Dashboard__c();
        dash.Account__c = account.Id;
        dash.Title__c = 'deep';
        dash.Description__c = 'Someone';
        Database.insert(dash);

        Dashboard_Section__c section = new Dashboard_Section__c();
        section.Dashboard__c = dash.Id;
        section.Title__c = 'reached';
        section.Display_Order__c = 1;
        section.Has_Graphs__c = false;
        section.Has_Maps__c = false;
        section.Has_Metrics__c = false; 
        section.Has_Selector__c = false;
        section.Is_Active__c = false;
        Database.insert(section);

        Metric_Section__c mSection = new Metric_Section__c();
        mSection.Dashboard_Section__c = section.Id;
        mSection.Title__c = 'in';
        mSection.Description__c = 'and';
        mSection.Default_Show__c = 0;
        mSection.RollOver_Time__c = 'Quarterly';
        mSection.Start_Date__c = Date.today().addMonths(-12);
        mSection.Show_RollOver_Selector__c = true;
        mSection.View_Mode__c = 'Disaggregated';
        Database.insert(mSection);

        M_E_Metric__c metric = Utils.createTestMetric(account, 'sum', 'scale', false, 'grabbed');
        metric.Metric_Section__c = mSection.Id;
        Database.insert(metric);

        M_E_Metric_Data__c metricDataTest = Utils.createTestMetricData(null, metric, 1.0, 1.0, Date.today());
        Database.insert(metricDataTest);

        DashboardSectionController parent = new DashboardSectionController();
        parent.setDashboardSection(section);

        MetricComponentController controller = new MetricComponentController();
        controller.setsObjectRecord((sObject)mSection);
        controller.initFieldMap('Metric_Section__c');
        controller.setParentComponentController(parent);
        controller.setSectionKey('key');

        DateTime startDate = DateTime.newInstance(Date.today().addDays(-1), Time.newInstance(18, 30, 2, 20));
        DateTime endDate = DateTime.newInstance(Date.today().addDays(-1), Time.newInstance(18, 30, 2, 20));
        parent.setSectionKey('key');
        parent.setParameters(new Map<String, String>());
        parent.addParameter('datePickerkey', 'start_date_int_' + startDate.getTime() + '_ext_end_date_int_' + endDate.getTime());

        controller.getMetricDatas();

/*        System.assert(controller.loadMetricSection());
        Metric_Section__c checkLoaded = (Metric_Section__c)controller.getsObjectRecord();
        System.assertEquals(mSection.Id, checkLoaded.Id);

        controller.loadMetricDatas();
        controller.getAllowUpdate();
        controller.getCurrentDate();
        controller.getDescription();
        controller.getIsEditMode();
        controller.getRollOverTime();
        controller.getShowBreakDown();
        controller.getShowComments();
        controller.getShowFurtherLink();
        controller.getShowPreviousQuarter();
        controller.getShowSparkLine();
        controller.getShowTargets();
        System.assertEquals(controller.getMetricDatas().size(), 1);
*/
    }
}