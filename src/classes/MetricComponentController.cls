public with sharing class MetricComponentController extends ChildComponentBase {

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
        this.currentDate = value;
    }

    private Boolean loaded = false;

    private List<String> metricIds;
    public List<String> getMetricIds() {
        if (!loaded) {
            if (this.fieldMap == null) {
                initFieldMap('Metric_Section__c');
                setCurrentDate(MetricHelpers.createDispRollOverString(Date.today(), getFieldValue('rollover_time__c')));
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
                setCurrentDate(MetricHelpers.createDispRollOverString(Date.today(), getFieldValue('rollover_time__c')));
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

        List<Date> dates = MetricHelpers.getStartEndDates(getCurrentDate(), getFieldValue('rollover_time__c'));
        Date startDate = dates[1];
        Date previousDate = MetricHelpers.decreaseDateRollOver(dates[0], getFieldValue('rollover_time__c'));

        // Check if this is for public consumption or not
        String notForPublicString = '';
        if (UserInfo.getUserType() == 'GUEST') {
            notForPublicString = 'AND M_E_Metric__r.Not_For_Public__c != true ';
        }

        // Check to see if we have a district to check.
        String districtNameClause = 'null';
        if (!this.getParentValue('District__c').equals('')) {
            districtNameClause = '\'' + this.getParentValue('District__c') + '\'';
        }

        String districtString = 'AND District__r.Name = ' + districtNameClause + ' ';

        //if (this.showCumulative) {
        //    this.cumulativeMetrics = MetricHelpers.getCumulativeData(organisationString, notForPublicString, districtString, quarterFirstDay, quarterLastDay, '', false);
        //}

        String query =
            'SELECT '                                   +
                'Id, '                                  +
                'M_E_Metric__c, '                       +
                'Actual_Value__c, '                     +
                'Manual_Value__c, '                     +
                'Projected_Value__c, '                  +
                'Comment__c, '                          +
                'Date__c, '                             +
                'District__r.Name, '                    +
                'M_E_Metric__r.Name, '                  +
                'M_E_Metric__r.Update_Period__c, '      +
                'M_E_Metric__r.Label__c, '              +
                'M_E_Metric__r.Sub_Area__c, '           +
                'M_E_Metric__r.Is_Header__c,'           +
                'M_E_Metric__r.Further_Link_Url__c, '   +
                'M_E_Metric__r.Further_Link_Text__c, '  +
                'M_E_Metric__r.Reverse_Comparison__c '  +
            'FROM '                                     +
                'M_E_Metric_Data__c '                   +
            'WHERE '                                    +
                'Date__c <= :startDate '                +
                'AND Date__c >= :previousDate '         +
                'AND M_E_Metric__r.Metric_Section__r.Name = \'' + getFieldValue('Name') + '\' ' +
                'AND Is_Cumulative__c = false '         +
                notForPublicString                      +
                districtString                          +
            'ORDER BY '                                 +
                'M_E_Metric__r.Order__c ASC, '          +
                'M_E_Metric__r.Name, '                  +
                'District__r.Name, '                    +
                'Date__c ASC ';

        System.debug(LoggingLevel.INFO, query);

        Map<String, MetricDataWrapper> metricDataMap = new Map<String, MetricDataWrapper>();
        this.metricDatas = new List<MetricDataWrapper>();
        this.metricIds = new List<String>();

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

            // See which quarter the metric is for.
            if (dates[0].dayOfYear() <= metric.Date__c.dayOfYear() && dates[0].year() == metric.Date__c.year()) {

                // Current quarter
                metricDataWrapper.currentQuarter = metric;
                this.metricIds.add(metric.Id);
            }
            else {

                // Previous quarter
                metricDataWrapper.previousQuarter = metric;
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

    public override PageReference refreshData() {

        loadMetricDatas();
        return null;
    }

    // Each metric section has its own time period selector so each section can be
    // refreshed independantly of the others. This can be overriden by the general selector
    // or hidden completely
    public List<SelectOption> getRollOverSelectorOptions() {

        List<SelectOption> options = new List<SelectOption>();
        String[] startDateArray = getFieldValue('start_date__c').split('==');
        if (startDateArray.size() != 3) {
            return options;
        }
        String rollOverTime = getFieldValue('rollover_time__c');
        Date startDate = MetricHelpers.getRollOverStartDate(Date.newInstance(Integer.valueOf(startDateArray[0]), Integer.valueOf(startDateArray[1]), Integer.valueOf(startDateArray[2])), rollOverTime);
        Date endDate = MetricHelpers.getRollOverEndDate(Date.today(), rollOverTime);
        while (startDate.daysBetween(endDate) >= 0) {
            String optionString = MetricHelpers.createDispRollOverString(startDate, rollOverTime);
            options.add(new SelectOption(optionString, optionString));
            startDate = MetricHelpers.increaseDateRollOver(startDate, rollOverTime);
        }
        return options;
    }

    static testMethod void testGetRollOverSelectorOptions() {

        Account account = new Account();
        account.Name = 'party';
        account.BillingState = 'CA';
        Database.insert(account);

        Dashboard__c dash = new Dashboard__c();
        dash.Account__c = account.Id;
        dash.Title__c = 'His';
        dash.Description__c = 'ear';
        Database.insert(dash);

        Dashboard_Section__c section = new Dashboard_Section__c();
        section.Dashboard__c = dash.Id;
        section.Title__c = 'lobe';
        section.Display_Order__c = 1;
        section.Has_Graphs__c = false;
        section.Has_Maps__c = false;
        section.Has_Metrics__c = false;
        section.Has_Selector__c = false;
        section.Is_Active__c = false;
        Database.insert(section);

        Metric_Section__c mSection = new Metric_Section__c();
        mSection.Dashboard_Section__c = section.Id;
        mSection.Title__c = 'fell';
        mSection.Description__c = 'in';
        mSection.RollOver_Time__c = 'Quarterly';
        mSection.Start_Date__c = Date.today().addMonths(-12);
        mSection.Show_RollOver_Selector__c = true;
        Database.insert(mSection);

        MetricComponentController controller = new MetricComponentController();
        controller.setsObjectRecord((sObject)mSection);
        controller.initFieldMap('Metric_Section__c');
        System.debug(controller.getRollOverSelectorOptions().size());
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
        mSection.RollOver_Time__c = 'Quarterly';
        mSection.Start_Date__c = Date.today().addMonths(-12);
        mSection.Show_RollOver_Selector__c = true;
        Database.insert(mSection);

        M_E_Metric__c metric = Utils.createTestMetric(account, 'sum', 'scale', false, 'grabbed');
        metric.Metric_Section__c = mSection.Id;
        Database.insert(metric);

        M_E_Metric_Data__c metricDataTest = Utils.createTestMetricData(null, metric, 1.0, 1.0, Date.today());
        Database.insert(metricDataTest);

        MetricComponentController controller = new MetricComponentController();
        controller.setsObjectRecord((sObject)mSection);
        controller.initFieldMap('Metric_Section__c');
        controller.setCurrentDate(MetricHelpers.createDispRollOverString(Date.today(), controller.getFieldValue('rollover_time__c')));

        System.assert(controller.loadMetricSection());
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
    }
}