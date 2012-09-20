public  class DashboardController {

    public Boolean hideDistrictSelector { get; set; }
    public Boolean hideShowBreakDown { get; set; }

    public String district { get; set; }
    public List<SelectOption> districtList;
    public List<SelectOption> getDistrictList() {

        List<SelectOption> options = new List<SelectOption>();

        District__c[] districts = database.query(SoqlHelpers.getDistricts(orgName));
        options.add(new SelectOption('','-- In All Districts --'));

        //Add all districts to list
        for (District__c district : districts) {
               options.add(new SelectOption(district.Name, district.Name));
        } 
        return options;
    }
    
    public void setDistrictList(List<SelectOption> option) {
        this.districtList = option;
    }

    public String tabName { get; set; }

    public String quarter = null;
    String currentQuarter = null;
    String showPreviousQuarter = 'true';
    Boolean isEditMode = false;

    public String orgName = 'null';
    private Boolean showSparkLine = true;
    private Boolean showCumulative = false;

    Transient Map<String, Map<String, MetricDataWrapper>> metricWrappers;
    Transient Map<String, Map<String, M_E_Metric_Data__c>> cumulativeMetrics;
    Transient Map<String, List<String>> metricWrapperOrder;

    List<MetricDataWrapper> impactData = new List<MetricDataWrapper>();
    List<MetricDataWrapper> sustainabilityData = new List<MetricDataWrapper>();
    List<MetricDataWrapper> qualityData = new List<MetricDataWrapper>();
    List<MetricDataWrapper> scaleData = new List<MetricDataWrapper>();
    List<MetricDataWrapper> technologyData = new List<MetricDataWrapper>();
    List<MetricDataWrapper> servicesData = new List<MetricDataWrapper>();

    public DashboardController() {

        setUpQuarter(ApexPages.currentPage().getParameters().get('quarter'));
        setUp(ApexPages.currentPage());
        this.hideDistrictSelector = false;
        this.hideShowBreakDown = false;
        Profile profile = [SELECT name FROM Profile WHERE id = :UserInfo.getProfileId()];
        if (orgName == 'Farmer Voice Radio') {
            if ((profile.Name != null) && (profile.Name.startsWith('FVR')) && (profile.Name!= 'FVR User')) {
                this.hideDistrictSelector = true;
                this.hideShowBreakDown = true;
                setDistrictForUser(profile.Name);
            }
        }
    }

    private void setDistrictForUser(String profileName) {

        Map<String, String> translationMap = new Map<String, String> {
            'FVR Amuru User' => 'Amuru',
            'FVR Bushenyi User' => 'Bushenyi',
            'FVR Gulu User' => 'Gulu',
            'FVR Kapchorwa User' => 'Kapchorwa',
            'FVR Kasese User' => 'Kasese',
            'FVR Masindi User' => 'Masindi',
            'FVR Mbale User' => 'Mbale',
            'FVR Oyam User' => 'Oyam'
        };
        this.district = translationMap.get(profileName);
    }

    private void setUp(PageReference pageRef) {

        // Find out which organisation this dashboard is for.
        setOrgName(Utils.getOrgName(pageRef.getUrl()));

        if (getOrgName() != null && !getOrgName().equals('null')) {
            this.showSparkLine = false;
            this.showCumulative = true;
        }

        // Try to keep the tab we're on
        String tabName = pageRef.getParameters().get('sfdc.tabName');
        if(tabName != null) {
            this.tabName = tabName;
        }
        this.isEditMode = (pageRef.getParameters().get('editMode') == 'true');
    }

    private void setUpQuarter(String quarter) {

        this.currentQuarter = MetricHelpers.getCurrentQuarterAsString(0);
        if(quarter == null || quarter.length() == 0) {
            setQuarter(this.currentQuarter);
        }
        else {
            setQuarter(quarter);
        }
    }

    public void setShowPreviousQuarter(String input) {

            // Hardcoded I know but sometime you gotta do what you gotta do.
            if (input != null && input.contains('Jul - Sep 2010')) {
                this.showPreviousQuarter = 'false';
            }
            else {
                this.showPreviousQuarter = 'true';
            }
    }

    public String getShowPreviousQuarter() {

        setShowPreviousQuarter(this.quarter);
        return this.showPreviousQuarter;
    }

    public List<SelectOption> getQuarters() {

        List<SelectOption> options = new List<SelectOption>();
        Integer currentYear = Date.today().year();
        Integer currentQuarter = MetricHelpers.getQuarter(Date.today());
        Integer quarter;
        Integer startYear;

        // Data starts in Q3-2010 (using calendar quarters, not fiscal) for grameen.
        // Find out which partner this dashboard is for and generate their quarters. Default to Grameen
        if (getOrgName() != null && getOrgName().equals('NAADS')) {
            startYear = 2011;
            quarter = 3;
        }
        else if (getOrgName() != null && getOrgName().equals('Farmer Voice Radio')) {
            startYear = 2011;
            quarter = 4;
        }
        else {
            startYear = 2010;
            quarter = 3;
        }
        for(Integer year = startYear; year <= currentYear; year++) {
            if(year != startYear) {
                quarter = 1;
            }
            while(quarter <= 4) {
                String quarterString = MetricHelpers.getQuarterStartMonth(quarter) + ' - ' + MetricHelpers.getQuarterEndMonth(quarter) + ' ' + String.valueOf(year);
                SelectOption option = new SelectOption(quarterString, quarterString);
                if(year == currentYear && quarter == currentQuarter && (this.quarter == null || this.quarter.length() == 0)) {
                    this.setQuarter(quarterString);
                }
                options.add(option);
                quarter++;
            }
        }
        return options;
    }

    public String getOrgName() {
        return this.orgName;
    }

    public void setOrgName(String orgName) {
        this.orgName = orgName;
    }

    public String getQuarter() {
        return quarter;
    }

    public void setQuarter(String quarter) {
        this.quarter = quarter;
        setShowPreviousQuarter(this.quarter);
    }

    public String getCurrentQuarter() {
        return currentQuarter;
    }

    public void setCurrentQuarter(String quarter) {
        this.currentQuarter = quarter;
    }

    public MetricDataWrapper[] getImpactData() {
        return getAreaData('Impact');
    }

    public MetricDataWrapper[] getScaleData() {
        return getAreaData('Scale');
    }

    public MetricDataWrapper[] getSustainabilityData() {
        return getAreaData('Sustainability');
    }

    public MetricDataWrapper[] getQualityData() {
        return getAreaData('Quality');
    }

    public MetricDataWrapper[] getTechnologyData() {
        return getAreaData('Technology');
    }

    public MetricDataWrapper[] getServicesData() {
        return getAreaData('Services');
    }

    private MetricDataWrapper[] getAreaData(String area) {

        List<MetricDataWrapper> areaData = new List<MetricDataWrapper>();
        if (this.metricWrappers == null) {
            getData();
        }
        Map<String, MetricDataWrapper> wrappers = this.metricWrappers.get(area);
        if (wrappers == null) {
            System.debug(LoggingLevel.INFO, 'NO wrappers for area ' + area);
        }
        List<String> metricOrder = this.metricWrapperOrder.get(area);
        if (wrappers != null && metricOrder != null) {
            for (String key : metricOrder) {
                MetricDataWrapper wrapper = wrappers.get(key);
                if (wrapper != null) {
                    areaData.add(wrapper);
                }
            }
        }
        System.debug('Found ' + areaData.size() + ' for area ' + area);
        return areaData;
    }

    private void getData() {

        this.metricWrappers = new Map<String, Map<String, MetricDataWrapper>>();
        this.metricWrapperOrder = new Map<String, List<String>>();

        Date quarterFirstDay = MetricHelpers.getQuarterFirstDay(this.quarter);
        Date previousQuarterFirstDay = quarterFirstDay.addMonths(-3);
        Date quarterLastDay = MetricHelpers.getQuarterLastDay(this.quarter);

        // Check if this is for public consumption or not
        String notForPublicString = '';
        if (UserInfo.getUserType() == 'GUEST') {
            notForPublicString = 'AND M_E_Metric__r.Not_For_Public__c != true ';
        }

        // Check to see which organisations this page is for.
        String organisationName = getOrgName();
        if (organisationName != null && !organisationName.equals('null')) {
            if (organisationName == 'Farmer Voice Radio') {
                this.showCumulative = false;
            }
            organisationName = '\'' + organisationName + '\'';
        }
               
        String organisationString = 'AND M_E_Metric__r.Organisation__r.Name = ' + organisationName + ' ';

        // Check to see if we have a district to check.
        String districtNameClause = 'null';
        if (this.district != null && !this.district.equals('')) {
            districtNameClause = '\'' + this.district + '\'';
        }

        String districtString = 'AND District__r.Name = ' + districtNameClause + ' ';

        if (this.showCumulative) {
            this.cumulativeMetrics = MetricHelpers.getCumulativeData(organisationString, notForPublicString, districtString, quarterFirstDay, quarterLastDay, '', false);
        }

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
                'M_E_Metric__r.M_E_Area__c, '           +
                'M_E_Metric__r.Update_Period__c, '      +
                'M_E_Metric__r.Label__c, '              +
                'M_E_Metric__r.Sub_Area__c, '           +
                'M_E_Metric__r.Is_Header__c,'           +
                'M_E_Metric__r.Reverse_Comparison__c '  +
            'FROM '                                     +
                'M_E_Metric_Data__c '                   +
            'WHERE '                                    +
                'Date__c >= :previousQuarterFirstDay '  +
                'AND Date__c <= :quarterLastDay '       +
                'AND Is_Cumulative__c = false '         +
                notForPublicString                      +
                organisationString                      +
                districtString                          +
            'ORDER BY '                                 +
                'M_E_Metric__r.M_E_Area__c, '           +
                'M_E_Metric__r.Order__c ASC, '          +
                'M_E_Metric__r.Name, '                  +
                'District__r.Name, '                    +
                'Date__c ASC ';

        String metricName = '';
        String metricKey = '';
        String districtName = '';
        String areaName = '';
        MetricDataWrapper metricDataWrapper = null;
        List<String> metricOrder = null;
        Map<String, MetricDataWrapper> areaMap = null;
        System.debug(LoggingLevel.INFO, query);
        for (M_E_Metric_Data__c metric : database.query(query)) {

            // See if we have a valid metric name and that it is not the same as the next metric in the list.
            // If it isn't then we need to save the metric from the last loop and move on to a new metric
            if (!metricName.equals(metric.M_E_Metric__r.Name)) {

                // Save the previous object to the list
                if (metricDataWrapper != null) {


                    areaMap = this.metricWrappers.get(areaName);
                    if (areaMap == null) {
                        areaMap = new Map<String, MetricDataWrapper>();
                    }

                    metricOrder = this.metricWrapperOrder.get(areaName);
                    if (metricOrder == null) {
                        metricOrder = new List<String>();
                    }

                    metricKey = metricName;
                    districtName = metric.District__r.Name;
                    if (districtName != null) {
                        metricKey = MetricHelpers.createMetricLabelString(metricName, districtName);
                    }

                    // Add the cumulative calue if required
                    if (this.showCumulative && !metric.M_E_Metric__r.Is_Header__c) {
                        Decimal cumulative = null;
                        M_E_Metric_Data__c cumulativeMetric = cumulativeMetrics.get(areaName).get(metricName);
                        if (cumulativeMetric != null) {
                            cumulative = cumulativeMetric.Real_Value__c;
                        }
                        if (cumulative != null) {
                            metricDataWrapper.cumulativeValue = String.valueOf(cumulative);
                        }
                        else {
                            metricDataWrapper.cumulativeValue = 'N/A';
                        }
                    }
                    areaMap.put(metricKey, metricDataWrapper);
                    metricOrder.add(metricKey);
                    this.metricWrappers.put(areaName, areaMap);
                    this.metricWrapperOrder.put(areaName, metricOrder);
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

            // See if we have moved on to a new area and that the area exists
            areaName = metric.M_E_Metric__r.M_E_Area__c;
            if (areaName == null || areaName.equals('')) {
                metricDataWrapper = null;
                continue;
            }

            if (metric.M_E_Metric__r.Name == null) {
                metricName = '';
                metricDataWrapper = null;
                System.debug(LoggingLevel.INFO, 'No metric__r.Name');
                continue;
            }
            metricDataWrapper.isHeader = metric.M_E_Metric__r.Is_Header__c;

            // See which quarter the metric is for.
            if (quarterFirstDay.dayOfYear() <= metric.Date__c.dayOfYear() && quarterFirstDay.year() == metric.Date__c.year()) {

                // Current quarter
                metricDataWrapper.currentQuarter = metric;
            }
            else {

                // Previous quarter
                metricDataWrapper.previousQuarter = metric;
            }

            // Get sparkLine
            if (this.showSparkLine) {
                metricDataWrapper.setSparkUrl(metric.M_E_Metric__c);
            }
        }

        // Add the last object
        metricKey = metricName;
        if (districtName != null) {
            metricKey = MetricHelpers.createMetricLabelString(metricName, districtName);
        }
        areaMap = this.metricWrappers.get(areaName);
        if (areaMap == null) {
            areaMap = new Map<String, MetricDataWrapper>();
        }

        metricOrder = this.metricWrapperOrder.get(areaName);
        if (metricOrder == null) {
            metricOrder = new List<String>();
        }
        areaMap.put(metricKey, metricDataWrapper);
        this.metricWrappers.put(areaName, areaMap);
        metricOrder.add(metricKey);
        this.metricWrapperOrder.put(areaName, metricOrder);
    }

    public PageReference changeQuarter() {

        MetricHelpers.generateMetrics(MetricHelpers.getQuarterFirstDay(this.quarter), MetricHelpers.getQuarterLastDay(this.quarter), getOrgName());
        PageReference resultPage = ApexPages.currentPage(); 
        resultPage.getParameters().put('quarter', this.quarter);
        resultPage.getParameters().put('sfdc.tabName', this.tabName);
        resultPage.setRedirect(true);
        return resultPage;
    }

    public PageReference loadPage() {

        this.district = Apexpages.currentPage().getParameters().get('districtParam');
        setUpQuarter(Apexpages.currentPage().getParameters().get('quarterParam'));
        setUp(ApexPages.currentPage());
        getData();
        return null;
    }

    public String getIsCurrentQuarter() {

        if (null != this.quarter && this.quarter.equals(this.currentQuarter)) {
            return 'true';
        }
        return 'false';
    }

    // For the moment we always want to return true here as we are updating targets manually
    public String getIsUpdateable() {
        return 'true';
        if (null != this.quarter && null != this.currentQuarter) {
            Date quarter = MetricHelpers.getQuarterFirstDay(this.quarter);
            Date currentQuarter = MetricHelpers.getQuarterFirstDay(this.currentQuarter);
            if (quarter.daysBetween(currentQuarter) <= 0) {
                return 'true';
            }
        }
        return 'false';
    }

    public String getIsEditMode() {
        if(this.isEditMode) {
            return 'true';
        }
        return 'false';
    }

    static testMethod void testDashboardController() {

        DashboardController dashboard = new DashboardController();
        MetricHelpers.getQuarterStartMonth(3);
        MetricHelpers.getQuarterEndMonth(3);
        dashboard.getQuarters();
        dashboard.setQuarter('Jan - Mar 2010');
        System.assertEquals(dashboard.getQuarter(),'Jan - Mar 2010');
        MetricHelpers.getQuarterFirstDay('Jan - Mar 2010');
        MetricHelpers.getQuarterLastDay('Jan - Mar 2010');
        dashboard.setQuarter(MetricHelpers.getCurrentQuarterAsString(0));
        dashboard.getIsCurrentQuarter();
        dashboard.getIsEditMode();
        dashboard.getIsUpdateable();
        dashboard.setCurrentQuarter('Jan - Mar 2010');
        System.assertEquals(dashboard.getCurrentQuarter(),'Jan - Mar 2010');
        dashboard.setShowPreviousQuarter('Jan - Mar 2010');
        System.assertEquals(dashboard.getShowPreviousQuarter(),'true');
        
        System.assertNotEquals(null, dashboard.getQuarter());
        System.assertNotEquals(null, dashboard.getDistrictList());
        System.assertNotEquals(null, dashboard.getImpactData());
        System.assertNotEquals(null, dashboard.getQualityData());
        System.assertNotEquals(null, dashboard.getScaleData());
        System.assertNotEquals(null, dashboard.getSustainabilityData());
        System.assertNotEquals(null, dashboard.getServicesData());
        System.assertNotEquals(null, dashboard.getTechnologyData());
    }
}