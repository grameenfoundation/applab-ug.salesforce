public with sharing class MetricBreakDownController extends ParentComponentBase {

    public override void rebuildParameters() {
        this.getParentMap().get('DashboardSelectorKey').rebuildParameters();
        this.setParameters(this.getParentMap().get('DashboardSelectorKey').getParameters());
    }

    private Metric_Section__c section;
    private Dashboard_Selector__c selector;
    public Dashboard_Selector__c getSelector() {
        return this.selector;
    }

    private String isRefresh;
    public String getIsRefresh() {
        return 'false';
    }

    private String dateToShow;
    private String metricId;
    private String districtId;
    private String personId;

    private List<MetricDataWrapper> metricDatas;
    public List<MetricDataWrapper> getMetricDatas() {
        return this.metricDatas;
    }
    private String displayString;
    public String getDisplayString() {
        return this.displayString;
    }
    public void setDisplayString(String value) {
        this.displayString = value;
    }
    private Boolean showSelector;
    public Boolean getShowSelector() {
        return this.showSelector;
    }
    public void setShowSelector(Boolean value) {
        this.showSelector = value;
    } 

    public String getAccountName() {
        return section.Dashboard_Section__r.Dashboard__r.Account__r.Name;
    }

    public Boolean getShowComments() {
        return section.Show_Comments__c;
    }

    public Boolean getShowTargets() {
        return section.Show_Targets__c;
    }

    public Boolean getShowPreviousQuarter() {
        return section.Show_Previous_Quarter__c;
    }
    public MetricBreakDownController() {

        PageReference pageRef = ApexPages.currentPage();

        // Get the url params
        this.dateToShow = pageRef.getParameters().get('date');
        
        if (this.dateToShow != null && !this.dateToShow.equals('')) {
            system.debug('Set from parameter : ' + this.dateToShow);
            this.dateToShow = this.dateToShow.replace('sp', ' ');
        }
        else {
            this.dateToShow = MetricHelpers.createDispRollOverString(Date.today(), getRollOverPeriod());
            system.debug('Rollover Period : ' + getRollOverPeriod());
            system.debug('Set from value call : ' + this.dateToShow);
        }
        
        // Pick this from somewhere
        this.metricId = pageRef.getParameters().get('metricId');
        system.debug('Metric Id : ' + this.metricId);
        this.districtId = pageRef.getParameters().get('district');
        this.personId = pageRef.getParameters().get('person');

        // Fetch the set up
        fetchSection(pageRef.getParameters().get('section'));

        fetchSelector(pageRef.getParameters().get('selector'));

        // Get the metrics
        loadMetricDatas();

        // Get the display string
        createDisplayString();
    }

    private void fetchSection(String id) {

        if (id == null || id.equals('')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No metric section exists for the metric passed in. Check that the metric section is still active'));
            setShowSelector(false);
            return;
        }
        Metric_Section__c[] sections = [SELECT
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
                Show_Selector_On_Break_Down__c,
                Allow_Update__c
            FROM
                Metric_Section__c
            WHERE
                Id = :id
                AND Is_Active__c = true
        ];
        if (sections.size() != 1) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No active metric section found for id ' + id + '. Please check your set up. Contact support if this persists'));
            return;
        }
        this.section = sections[0];
    }

    private void fetchSelector(String id) {
        system.debug('Selector Id : ' + id);
        if (id == null || id.equals('') || this.section == null || !this.section.Show_Selector_On_Break_Down__c) {
            setShowSelector(false);
            return;
        }

        List<Dashboard_Selector__c> selectors = 
            [SELECT
                Show_Dates__c,
                Show_Metric_Date_Selector__c,
                Show_Country__c,
                Show_Region__c,
                Show_District__c,
                Show_Subcounty__c,
                Show_Person__c,
                Show_Data_Validator__c,
                Show_CKW__c,
                Show_Farmer__c,
                Show_Field_Officer__c,
                Show_MTN_Chan__c,
                Date_Period__c,
                Start_Date__c
            FROM
                Dashboard_Selector__c
            WHERE
                Is_Active__c = true
                AND Id = :id
            ORDER BY
                CreatedDate DESC];

        if (selectors.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No selector exists for the id passed in. Check that the selector is still active'));
            return;
        }
        this.selector = selectors[0];
    }

    private void loadMetricDatas() {

        List<Date> dates = MetricHelpers.getStartEndDates(this.dateToShow, getRollOverPeriod());
        Date startDate = dates[1];
        Date previousDate = MetricHelpers.decreaseDateRollOver(dates[0], getRollOverPeriod());

        // Check if this is for public consumption or not
        String notForPublicString = '';
        if (UserInfo.getUserType() == 'GUEST') {
            notForPublicString = 'AND M_E_Metric__r.Not_For_Public__c != true ';
        }

        // Check to see if we have a district to check.
        system.debug('Display Type : ' + getDisplayType());
        String clause = '';
        if (getDisplayType().equals('District')) {
            clause = ' AND District__c != null ';
        }
        else if (getDisplayType().equals('Person')) {
            clause = ' AND Person__c != null AND Person__r.District__c = \'' + this.districtId + '\' ';
        }
        else {
            clause = ' AND Person__c = null AND District__c = null ';
        }

        //if (this.showCumulative) {
        //    this.cumulativeMetrics = MetricHelpers.getCumulativeData(organisationString, notForPublicString, districtString, quarterFirstDay, quarterLastDay, '', false);
        //}

        String query =
            'SELECT ' +
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
                'District__r.Name, ' +
                'Person__r.Name, ' +
                'Person__r.First_Name__c, ' + 
                'Person__r.Last_Name__c, ' +
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
                'M_E_Metric_Data__c ' +
            'WHERE ' +
                'Date__c <= :startDate ' +
                'AND Date__c >= :previousDate ' +
                'AND M_E_Metric__c = \'' + this.metricId + '\' ' +
                'AND Is_Cumulative__c = false ' +
                notForPublicString +
                clause +
            'ORDER BY ' +
                'Person__r.Name, ' +
                'District__r.Name, ' +
                'Date__c';

        System.debug(LoggingLevel.INFO, query);

        this.metricDatas = new List<MetricDataWrapper>();
        String splitter = '';
        MetricDataWrapper metricDataWrapper = null;
        for (M_E_Metric_Data__c metric : database.query(query)) {

            String tempSplitter = getSplitter(metric);

            // See if we have a valid metric name and that it is not the same as the next metric in the list.
            // If it isn't then we need to save the metric from the last loop and move on to a new metric
            if (!splitter.equals(tempSplitter)) {

                // Save the previous object to the list
                if (metricDataWrapper != null) {
                    this.metricDatas.add(metricDataWrapper);
                }

                // Create the new object and update the name if the new name is valid
                metricDataWrapper = new MetricDataWrapper();
                if (metric.M_E_Metric__r.Name == null) {
                    metricDataWrapper = null;
                    System.debug(LoggingLevel.INFO, 'No metric__r.Name');
                    continue;
                }
                metricDataWrapper.displayType = getDisplayType();
                System.debug(LoggingLevel.INFO, getDisplayType());
            }

            // Indicate if this is a header or not
            metricDataWrapper.isHeader = metric.M_E_Metric__r.Is_Header__c;
            splitter = tempSplitter;

            // See which quarter the metric is for.
            if (dates[0].dayOfYear() <= metric.Date__c.dayOfYear() && dates[0].year() == metric.Date__c.year()) {

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
                if (metric.District__c != null) {
                    metricDataWrapper.setDistrictName(metric.District__r.Name);
                }
                else if (metric.Person__c != null) {
                    metricDataWrapper.setFirstName(metric.Person__r.First_Name__c);
                    metricDataWrapper.setLastName(metric.Person__r.Last_Name__c);
                }
            }
            else {

                // Previous quarter
                metricDataWrapper.setPreviousId(metric.Id);
                metricDataWrapper.setPreviousRealValue(metric.Real_Value__c);
                metricDataWrapper.setPreviousNumerator(metric.Numerator__c);
                metricDataWrapper.setPreviousDenumerator(metric.Denumerator__c);
                metricDataWrapper.setPreviousTarget(metric.Projected_Value__c);
            }
        }

        // Add the last object
        if (metricDataWrapper != null) {
            this.metricDatas.add(metricDataWrapper);
        }
    }

    /**
     *  Create the display string that is shown at the top of the break down page
     */
    private void createDisplayString() {

        String returnValue = '';

        // Load the metric
        M_E_Metric__c[] metric = [
            SELECT
                Label__c
            FROM
                M_E_Metric__c
            WHERE
                Id = :this.metricId];
        if (metric.size() == 0) {
            returnValue = 'No metric available';
        }
        returnValue = metric[0].Label__c;

        // Decide if this break down in showing district or person wide
        if (this.districtId == null || this.districtId.equals('')) {

            // Showing metric by district
            returnValue += ' District Break Down';
        }
        else if (this.personId == null || this.personId.equals('')) {
            returnValue += ' Person Break Down';
        }
        setDisplayString(returnValue);
    }

    /**
     * Get the splitter used to generate the data list
     */
    private String getSplitter(M_E_Metric_Data__c mData) {

        String returnValue;

        if (this.districtId == null || this.districtId.equals('')) {

            // Showing metric by district
            returnValue = mData.District__r.Name;
        }
        else if (this.personId == null || this.personId.equals('')) {
            returnValue = mData.Person__r.Name;
        }

        // If the return value is null convert to a string
        if (returnValue == null) {
            returnValue = 'null';
        }
        return returnValue;
    }

    /**
     * Get the display type for each row of the metric display
     */
     private String getDisplayType() {

        String returnValue = '';
        if (this.districtId == null || this.districtId.equals('')) {

            // Showing metric by district
            returnValue = 'District';
        }
        else if (this.personId == null || this.personId.equals('')) {
            returnValue = 'Person';
        }
        return returnValue;
     }

    private String getRollOverPeriod() {

        if (this.section == null) {
            return 'Monthly';
        }
        String rollOverPeriod = this.section.RollOver_Time__c;
        if (rollOverPeriod == null || rollOverPeriod.equals('')) {
            rollOverPeriod = 'Monthly';
        }
        return rollOverPeriod;
    }

    public PageReference refreshData() {
        loadMetricDatas();
        return null;
    }
}