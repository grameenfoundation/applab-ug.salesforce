/**
 * Wrapper class for each metric that is shown on the dashboard page.
 * This class is global so it can implement sorting
 */

global class MetricDataWrapper implements Comparable {

    // Put these since it was throwing errors
    public M_E_Metric_Data__c currentQuarter { get; set; }
    public M_E_Metric_Data__c previousQuarter { get; set; }

    // Colour constants
    private static final String START_COLOUR = '#FF0332';
    private static final String NO_COLOUR = '#CCCCFF';
    private static final String GREEN = '#00CC00';
    private static final String YELLOW = '#FFFF33';
    private static final String RED = '#FF0000';
    private String colour;

    private Decimal orderNumber;
    public Decimal getOrderNumber() {
        return this.orderNumber;
    }
    public void setOrderNumber(Decimal value) {
        this.orderNumber = value;
    }

    public String subArea;
    public String getSubArea() {

        if (this.subArea != null) {
            return this.subArea;
        }
        return 'Sub Area is not set';
    }
    public void setSubArea(String value) {
        this.subArea = value;
    }

    public String label;
    public String getLabel() {

        if (this.label != null) {
            return this.label;
        }
        return 'Label is not set';
    }
    public void setLabel(String value) {
        this.label = value;
    }

    public String comment;
    public String getComment() {

        if (this.comment != null) {
            return this.comment;
        }
        return '';
    }
    public void setComment(String value) {
        this.comment = value;
    }

    public String name;
    public String getName() {
        return this.name;
    }
    public void setName(String value) {
        this.name = value;
    }

    public String metricId;
    public String getMetricId() {
        return this.metricId;
    }
    public void setMetricId(String value) {
        this.metricId = value;
    }

    public Boolean hasCurrent;
    public Boolean getHasCurrent() {
        return this.hasCurrent;
    }
    public void setHasCurrent(Boolean value) {
        this.hasCurrent = value;
    }

    public String sparkUrl { get; set; }

    // Variables for the display string
    public String displayType = '';
    private String displayString;
    public String getDisplayString() {

        String returnValue = '';
        if (displayType.equals('Person')) {
            returnValue = this.personFirstName + ' ' + this.personLastName;
        }
        else if (displayType.equals('District')) {
            returnValue = this.districtName;
        }
        return returnValue;
    }
    private String personFirstName;
    public void setFirstName(String value) {
        this.personFirstName = value;
    }
    private String personLastName;
    public void setLastName(String value) {
        this.personLastName = value;
    }
    private String districtName;
    public void setDistrictName(String value) {
        this.districtName = value;
    }

    // Further information details
    private String furtherLinkText;
    public void setFurtherLinkText(String value) {
        this.furtherLinkText = value;
    }
    public String getFurtherLinkText() {

        if (this.furtherLinkText != null) {
            return this.furtherLinkText;
        }
        return '';
    }
    private String furtherLinkUrl;
    public void setFurtherLinkUrl(String value) {
        this.furtherLinkUrl = value;
    }
    public String getFurtherLinkUrl() {

        if (this.furtherLinkUrl != null) {
            return URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.furtherLinkUrl;
        }
        return '';
    }

    // Values calculations
    // Current
    private Boolean onFly;
    public void setOnFly(Boolean value) {
        this.onFly = value;
    }
    private String calculation;
    public void setCalculation(String value) {
        if (value == null) {
            value = '';
        }
        this.calculation = value;
    }
    private Boolean isAggregate;
    public void setIsAggregate(Boolean value) {
        this.isAggregate = value;
    }
    private Decimal currentRealValue;
    public void setCurrentRealValue(Decimal value) {
        this.currentRealValue = value;
    }
    private Decimal currentTotal;
    public void setCurrentTotal(Decimal value) {
        this.currentTotal = value;
    }
    private Decimal currentTarget;
    public void setCurrentTarget(Decimal value) {
        this.currentTarget = value;
    }
    private Decimal currentNumerator;
    public void setCurrentNumerator(Decimal value) {
        this.currentNumerator = value;
    }
    private Decimal currentDenumerator;
    public void setCurrentDenumerator(Decimal value) {
        this.currentDenumerator = value;
    }
    private String currentId;
    public String getCurrentId() {
        return this.currentId;
    }
    public void setCurrentId(String value) {
        this.currentId = value;
    }

    // Previous
    private Decimal previousRealValue;
    public void setPreviousRealValue(Decimal value) {
        this.previousRealValue = value;
    }
    private Decimal previousTarget;
    public void setPreviousTarget(Decimal value) {
        this.previousTarget = value;
    }
    private Decimal previousNumerator;
    public void setPreviousNumerator(Decimal value) {
        this.previousNumerator = value;
    }
    private Decimal previousDenumerator;
    public void setPreviousDenumerator(Decimal value) {
        this.previousDenumerator = value;
    }
    private String previousId;
    public String getPreviousId() {
        return this.previousId;
    }
    public void setPreviousId(String value) {
        this.previousId = value;
    }

    private Boolean reverseComparison;
    public void setReverseComparison(Boolean value) {
        if (value == null) {
            value = false;
        }
        this.reverseComparison = value;
    }

    public String target { set; }
    public Boolean isHeader { get; set; }
    public String cumulativeValue { get; set; }
    public String updatePeriod { get; set; }

    public String getTarget() {

        if (this.currentTarget == null || this.currentTarget == 0) {
            return 'N/A';
        }
        return this.currentTarget.format();
    }
    
    public void setCurrentTarget(String target) {
        this.target = target;
    }

    public Decimal currentValue {
        get {
            return calculateValue(true);
        }
        set;
    }
    public Decimal previousValue {
        get {
            return calculateValue(false);
        }
        set;
    }

    public String getDistrict() {

        if (this.districtName == null) {
            return 'Total';
        }
        return this.districtName;
    }

    public metricDataWrapper() {
        this.colour = NO_COLOUR;
        this.onFly = false;
        this.calculation = '';
        this.reverseComparison = false;
        this.isAggregate = false;
    }

    public void setSparkUrl(String metricId) {

        sparkUrl = 'http://chart.apis.google.com/chart?chs=55x20&cht=lxy:nda&chco=00FF00,0000FF&chf=bg,s,00000000&chls=2|2';
        M_E_Metric_Data__c[] data = MetricHelpers.loadAllMetricData(metricId);

        String chdActual = ''; // Actual values
        String chdProjected = ''; // Projected values

        // Because we show one less coordinate for the actual graph, we have to do xy graphs, so we need to track the xpoint
        Integer xCount = 0;
        Integer total = data.size();
        String xProjected = '';
        String xActual = ''; 

        for(M_E_Metric_Data__c item : data) {
            if(item.Projected_Value__c  != null) {
                chdProjected += item.Projected_Value__c + ',';
            } else {
                chdProjected += '0,';
            }
            xProjected += (xCount * 100 / Math.max(1, total - 1)) + ',';

            // Only show the actual value for the previous quarters
            if(!MetricHelpers.getCurrentQuarterAsString(0).equals(MetricHelpers.getQuarterAsString(item.Date__c))) {
                if(item.Real_Value__c  != null) {
                    chdActual += item.Real_Value__c + ',';
                } else {
                    chdActual += '0,';
                }
                xActual += (xCount * 100 / Math.max(1,total - 1)) + ',';
            }
            xCount++;
        }

        // Remove the last comma or pipe
        if(chdActual.length() > 1) {
            chdActual = chdActual.substring(0, chdActual.length() -1);
            xActual = xActual.substring(0, xActual.length() - 1);
        }

        if(chdProjected.length() > 1) {
            chdProjected = chdProjected.substring(0, chdProjected.length() -1);
            xProjected = xProjected.substring(0, xProjected.length() -1 );
        }
 
        sparkUrl += '&chd=t:' + xProjected + '|' + chdProjected + '|' + xActual + '|' + chdActual;
    }

    private Decimal calculateValue(Boolean currentQuarter) {

        Decimal realValue = null;
        Decimal numerator = null;
        Decimal denumerator = null;

        System.debug(LoggingLevel.INFO, currentQuarter);
        if (currentQuarter) {
            realValue = this.currentRealValue;
            numerator = this.currentNumerator;
            denumerator = this.currentDenumerator;
        }
        else {
            realValue = this.previousRealValue;
            numerator = this.previousNumerator;
            denumerator = this.previousDenumerator;
        }
        System.debug(LoggingLevel.INFO, 'Values for metric: ' + this.name + ' Real: ' + realValue + ' Num: ' + numerator + ' Denum: ' + denumerator + ' Fly: ' + this.onFly + ' calc: ' + this.calculation + ' agg: ' + this.isAggregate);
        if (this.onFly) {
            if (denumerator == null || denumerator == 0) {
                return denumerator;
            }
            if (this.calculation.equals('Percentage')) {
                return (numerator / denumerator) * 100;
            }
            else if (this.calculation.equals('Average')) {
                return (numerator / denumerator);
            }
            else {
                return denumerator;
            }
        }
        if (this.isAggregate) {
            if (this.calculation.equals('Percentage') || this.calculation.equals('Average')) {
                return this.currentRealValue / this.currentTotal;
            }
        }
        return realValue;
    }

    public String getColour() {

        Decimal value = calculateValue(true);
        Decimal startTarget = this.previousTarget;
        Decimal endTarget = this.currentTarget;
        Date quarterStart = MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0));
        Date quarterEnd = MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0));
        Integer quarterLength = quarterStart.daysBetween(quarterEnd);
        Integer daysGone = quarterStart.daysBetween(date.today());
        Decimal target = startTarget;
        if (endTarget == null && startTarget == null) {
            return NO_COLOUR;
        }

        if (startTarget != null && endTarget != null) {
            if (endTarget < startTarget) {
                target = endTarget;
            }
            else {
                target = startTarget + (((endTarget - startTarget) / quarterLength) * daysGone);
            }
        }
        if (target == null && endTarget != null) {
            target = endTarget;
        }

        // Set the colour that the metric should show
        if (
                value == null ||
                value == 0 ||
                (value == 0 && (this.comment == null || this.comment.equals(''))) ||
                this.currentRealValue == null ||
                this.currentTarget == null ||
                this.currentTarget == 0.00
        ) {

            // Use the previous quarters colour instead if possible.
            if (
                    this.previousRealValue == null ||
                    this.previousTarget == null ||
                    this.previousTarget == 0.00
            ) {
                this.colour = NO_COLOUR;
                return this.colour;
            }
            else {
                value = calculateValue(false);
                target = startTarget;
            }
        }
        if (target == null || value == null) {
            this.colour = NO_COLOUR;
            return this.colour;
        }

        Decimal difference = 0.0;
        if (this.reverseComparison) {
            difference = (value - target) / value;
        }
        else {
            difference = (target - value) / target;
        }

        if (difference <= 0.1) {
            this.colour = GREEN;
        }
        else if (difference <= 0.2) {
            this.colour = YELLOW;
        }
        else if (difference > 0.2) {
            this.colour = RED;
        }
        return this.colour;
    }
    public void setColour(String colour) {
        this.colour = colour;
    }

    /**
     * Sort method. This will return in ascending display order.
     * Tie breaker will be the M_E_Metric.Name 
     */
    global Integer compareTo(Object compareTo) {
        MetricDataWrapper compareToMetric = (MetricDataWrapper)compareTo;
        if (compareToMetric.getOrderNumber() > this.getOrderNumber()) {
            return -1;
        }
        if (this.getOrderNumber() > compareToMetric.getOrderNumber()) {
            return 1;
        }
        return this.getName().compareTo(compareToMetric.getName());
    }
/*
    public static testMethod void checkConstruction() {

        String quarter = MetricHelpers.getCurrentQuarterAsString(0);
        Date startDate = MetricHelpers.getQuarterFirstDay(quarter);
        Date endDate   = MetricHelpers.getQuarterLastDay(quarter);

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

        MetricDataWrapper mdw = new MetricDataWrapper();
        mdw.previousMetricData = testDataPrevious;
        mdw.currentMetricData = testDataCurrent;
        mdw.getColour();
        mdw.setSparkUrl(testMetric.Name);
        mdw.setComment(mdw.getComment());
        mdw.setLabel(mdw.getLabel());
        mdw.setSubArea(mdw.getSubArea());
        mdw.setName(mdw.getName());
        System.assertEquals(mdw.previousMetricData.Actual_Value__c, 10);
    }

    public static testMethod void testReverseComparison() {

        String quarter = MetricHelpers.getCurrentQuarterAsString(0);
        Date startDate = MetricHelpers.getQuarterFirstDay(quarter);
        Date endDate   = MetricHelpers.getQuarterLastDay(quarter);

        // Create a test M_E_Metric__c and a M_E_Metric_Data__c
        M_E_Metric__c testMetric = new M_E_Metric__c();
        testMetric.Name = 'TEST_THIS_CODE';
        testMetric.Label__c = 'This and that';
        testMetric.M_E_Area__c = 'Impact';
        testMetric.Order__c = 4;
        testMetric.Update_Period__c = 'Daily';
        testMetric.Reverse_Comparison__c = true;
        database.insert(testMetric);

        List<M_E_Metric_Data__c> metricData = new List<M_E_Metric_Data__c>();
        M_E_Metric_Data__c testDataCurrent = new M_E_Metric_Data__c();
        testDataCurrent.M_E_Metric__c = testMetric.Id;
        testDataCurrent.Manual_Value__c = 10;
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

        MetricDataWrapper mdw = new MetricDataWrapper();
        mdw.previousMetricData = testDataPrevious;
        mdw.currentMetricData = testDataCurrent;
        // TODO: Fix this and uncomment
        //System.assertEquals(mdw.getColour(), '#FF0000');
        System.assertEquals(mdw.previousMetricData.Actual_Value__c, 10);
    }

    public static testMethod void testNullValue() {

        String quarter = MetricHelpers.getCurrentQuarterAsString(0);
        Date startDate = MetricHelpers.getQuarterFirstDay(quarter);
        Date endDate   = MetricHelpers.getQuarterLastDay(quarter);

        // Create a test M_E_Metric__c and a M_E_Metric_Data__c
        M_E_Metric__c testMetric = new M_E_Metric__c();
        testMetric.Name = 'TEST_THIS_CODE';
        testMetric.Label__c = 'This and that';
        testMetric.M_E_Area__c = 'Impact';
        testMetric.Order__c = 4;
        testMetric.Update_Period__c = 'Daily';
        testMetric.Reverse_Comparison__c = true;
        database.insert(testMetric);

        List<M_E_Metric_Data__c> metricData = new List<M_E_Metric_Data__c>();
        M_E_Metric_Data__c testDataCurrent = new M_E_Metric_Data__c();
        testDataCurrent.M_E_Metric__c = testMetric.Id;
        testDataCurrent.Projected_Value__c = 15;
        testDataCurrent.Date__c = startDate;
        testDataCurrent.Comment__c = 'This should be this quarters.';
        metricData.add(testDataCurrent);

        M_E_Metric_Data__c testDataPrevious = new M_E_Metric_Data__c();
        testDataPrevious.M_E_Metric__c = testMetric.Id;
        testDataPrevious.Projected_Value__c = 15;
        testDataPrevious.Date__c = startDate.addMonths(-3);
        testDataPrevious.Comment__c = 'This should be last quarters.';
        metricData.add(testDataPrevious);
        database.insert(metricData);

        MetricDataWrapper mdw = new MetricDataWrapper();
        mdw.previousMetricData = testDataPrevious;
        mdw.currentMetricData = testDataCurrent;
        // TODO: Fix this and uncomment
        //System.assertEquals(mdw.getColour(), '#CCCCFF');
        System.assertEquals(mdw.previousMetricData.Actual_Value__c, null);
    }

    public static testMethod void testCurrentNull() {

        String quarter = MetricHelpers.getCurrentQuarterAsString(0);
        Date startDate = MetricHelpers.getQuarterFirstDay(quarter);
        Date endDate   = MetricHelpers.getQuarterLastDay(quarter);

        // Create a test M_E_Metric__c and a M_E_Metric_Data__c
        M_E_Metric__c testMetric = new M_E_Metric__c();
        testMetric.Name = 'TEST_THIS_CODE';
        testMetric.Label__c = 'This and that';
        testMetric.M_E_Area__c = 'Impact';
        testMetric.Order__c = 4;
        testMetric.Update_Period__c = 'Daily';
        testMetric.Reverse_Comparison__c = true;
        database.insert(testMetric);

        List<M_E_Metric_Data__c> metricData = new List<M_E_Metric_Data__c>();

        M_E_Metric_Data__c testDataPrevious = new M_E_Metric_Data__c();
        testDataPrevious.M_E_Metric__c = testMetric.Id;
        testDataPrevious.Projected_Value__c = 15;
        testDataPrevious.Actual_Value__c = 15;
        testDataPrevious.Date__c = startDate.addMonths(-3);
        testDataPrevious.Comment__c = 'This should be last quarters.';
        metricData.add(testDataPrevious);
        database.insert(metricData);

        MetricDataWrapper mdw = new MetricDataWrapper();
        mdw.previousMetricData = testDataPrevious;
        // TODO: Fix this and uncomment
        //System.assertEquals(mdw.getColour(), '#00CC00');
        System.assertEquals(mdw.previousMetricData.Actual_Value__c, 15);
    }
    */
}