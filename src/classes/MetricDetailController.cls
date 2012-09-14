public class MetricDetailController {

    private String quarter = null;
    private String orgName = 'null';
    private String metricName;
    private String label;
    private Boolean showCumulative = false;
    private Boolean showSubArea = false;
    private Boolean showPreviousQuarter = true;

    public List<MetricDataWrapper> singleMetricData = new List<MetricDataWrapper>();

    public MetricDetailController() {

        PageReference pageRef = ApexPages.currentPage();

        String quarter = pageRef.getParameters().get('quarter');
        if(quarter == null || quarter.length() == 0) {
            setQuarter(MetricHelpers.getCurrentQuarterAsString(0));
        }
        else {
            setQuarter(quarter);
        }

        // Find out which organisation this dashboard is for.
        setOrgName(pageRef.getParameters().get('orgName'));

        if (getOrgName() != null && !getOrgName().equals('null')) {
            if (!getOrgName().equals('\'Farmer Voice Radio\'')) {
                setShowCumulative(true);
            }
            setSubArea(true);
            setShowPreviousQuarter(this.quarter, false);
        }
        setMetricName(pageRef.getParameters().get('metricName'));
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
    }

    public Boolean getShowPreviousQuarter() {
        return this.showPreviousQuarter;
    }

    public void setShowPreviousQuarter(String input, Boolean show) {

        // Hardcoded I know but sometime you gotta do what you gotta do.
        if (input != null && input.contains('Jul - Sep 2010')) {
            this.showPreviousQuarter = false;
        }
        else {
            this.showPreviousQuarter = show;
        }
    }

    public Boolean getShowCumulative() {
        return this.showCumulative;
    }

    public void setShowCumulative(Boolean show) {
        this.showCumulative = show;
    }

    public Boolean getSubArea() {
        return this.showSubArea;
    }

    public void setSubArea(Boolean show) {
        this.showSubArea = show;
    }

    public String getMetricName() {
        return this.metricName;
    }

    public void setMetricName(String metricName) {
        this.metricName = metricName;
    }
    public String getLabel() {
        return this.label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public List<MetricDataWrapper> getSingleMetricData() {

        Date quarterFirstDay = MetricHelpers.getQuarterFirstDay(this.quarter);
        Date previousQuarterFirstDay = quarterFirstDay.addMonths(-3);
        Date quarterLastDay = MetricHelpers.getQuarterLastDay(this.quarter);
        Map<String, Map<String, M_E_Metric_Data__c>> cumulativeMetrics;
        if (this.showCumulative) {
            cumulativeMetrics = MetricHelpers.getCumulativeData('', '', '', quarterFirstDay, quarterLastDay, 'AND M_E_Metric__r.Name = \'' + getMetricName() + '\' ', true);
        }
        String query =
            'SELECT '                                                    +
                'Id, '                                                   +
                'M_E_Metric__c, '                                        +
                'Actual_Value__c, '                                      +
                'Manual_Value__c, '                                      +
                'Projected_Value__c, '                                   +
                'Comment__c, '                                           +
                'Date__c, '                                              +
                'District__r.Name, '                                     +
                'M_E_Metric__r.Name, '                                   +
                'M_E_Metric__r.M_E_Area__c, '                            +
                'M_E_Metric__r.Update_Period__c, '                       +
                'M_E_Metric__r.Label__c, '                               +
                'M_E_Metric__r.Sub_Area__c, '                            +
                'M_E_Metric__r.Reverse_Comparison__c '                   +
            'FROM '                                                      +
                'M_E_Metric_Data__c '                                    +
            'WHERE '                                                     +
                'Date__c >= :previousQuarterFirstDay '                   +
                'AND Date__c <= :quarterLastDay '                        +
                'AND Is_Cumulative__c = false '                          +
                'AND M_E_Metric__r.Name = \'' + getMetricName() + '\' '  +
            'ORDER BY '                                                  +
                'District__r.Name, '                                     +
                'Date__c';


        String metricName = '';
        String districtName = '';
        String areaName = '';
        MetricDataWrapper metricDataWrapper = null;
        System.debug(LoggingLevel.INFO, query);
        for (M_E_Metric_Data__c metric : database.query(query)) {
            areaName = metric.M_E_Metric__r.M_E_Area__c;

            // Save the previous object to the list
            String tempDistrictName = metric.District__r.Name;
            if (tempDistrictName == null) {
                tempDistrictName = 'null';
            }
            if (!districtName.equals(tempDistrictName)) {
                if (metricDataWrapper != null) {

                    // Add the cumulative value if required
                    if (getShowCumulative()) {
                        Decimal cumulative = null;
                        M_E_Metric_Data__c cumulativeMetric = cumulativeMetrics.get(areaName).get(districtName);
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
                    this.singleMetricData.add(metricDataWrapper);
                }
                metricDataWrapper = new MetricDataWrapper();
            }
            districtName = tempDistrictName;

            // See which quarter the metric is for.
            if (quarterFirstDay.dayOfYear() <= metric.Date__c.dayOfYear() && quarterFirstDay.year() == metric.Date__c.year()) {

                // Current quarter
                metricDataWrapper.currentQuarter = metric;
            }
            else {

                // Previous quarter
                metricDataWrapper.previousQuarter = metric;
            }
        }
        if (metricDataWrapper != null) {
            if (getShowCumulative()) {
                Decimal cumulative = null;
                M_E_Metric_Data__c cumulativeMetric = cumulativeMetrics.get(areaName).get(districtName);
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
            setLabel(metricDataWrapper.currentQuarter.M_E_Metric__r.Label__c);
            this.singleMetricData.add(metricDataWrapper);
        }
        return this.singleMetricData;
    }

    static testMethod void testMetricDetailController() {

        // Create a test Organisation
        Account org = Utils.createTestOrganisation('TestOrg1');
        database.insert(org);
        M_E_Metric__c metric = Utils.createTestMetric(org, 'Cumulative', 'Scale', true, 'total_districts');
        database.insert(metric);

        MetricDetailController metricDetailController = new MetricDetailController();
        metricDetailController.setLabel('Word');
        System.assert(metricDetailController.getLabel().equals('Word'));
        metricDetailController.getOrgName();
        metricDetailController.getQuarter();
        metricDetailController.getShowCumulative();
        metricDetailController.getShowPreviousQuarter();
        metricDetailController.getSubArea();
        metricDetailController.setMetricName('total_districts');
        System.assert(metricDetailController.getMetricName().equals('total_districts'));
        metricDetailController.setShowCumulative(true);
        metricDetailController.getSingleMetricData();
    }
}