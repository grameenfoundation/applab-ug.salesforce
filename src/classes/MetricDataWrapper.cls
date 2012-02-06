/**
 *  Wrapper class for each metric that is shown on the dashboard page.
 */

public class MetricDataWrapper {

    public M_E_Metric_Data__c currentQuarter { get; set; }
    public M_E_Metric_Data__c previousQuarter { get; set; }
    public String subArea;
    public String label;
    public String comment;
    public String name;
    public String Id;
    public String hasCurrent;

    public String cumulativeValue { get; set; }
    public String sparkUrl { get; set; }
    public String district;

    public String colour;
    public String target;
    public Boolean isHeader { get; set; }

    public String getColour() {

        Decimal value = calculateValue(true);
        M_E_Metric_Data__c data = this.currentQuarter;
        Decimal startTarget = null;
        if (this.previousQuarter != null) {
             startTarget = this.previousQuarter.Projected_Value__c;
        }
        Decimal endTarget = null;
        if (data != null) {
            endTarget = this.currentQuarter.Projected_Value__c;
        }
        Date quarterStart = MetricHelpers.getQuarterFirstDay(MetricHelpers.getCurrentQuarterAsString(0));
        Date quarterEnd = MetricHelpers.getQuarterLastDay(MetricHelpers.getCurrentQuarterAsString(0));
        Integer quarterLength = quarterStart.daysBetween(quarterEnd);
        Integer daysGone = quarterStart.daysBetween(date.today());
        Decimal target = startTarget;
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
        if (data == null || value == 0 || (value == 0 && (data.Comment__c == null || data.Comment__c == '' )) || (data.Actual_Value__c == null && data.Manual_Value__c == null) || data.Projected_Value__c == null || data.Projected_Value__c == 0.00) {

            // Use the previous quarters colour instead if possible.
            if (this.previousQuarter == null || (this.previousQuarter.Actual_Value__c == null && this.previousQuarter.Manual_Value__c == null) || this.previousQuarter.Projected_Value__c == null ||this.previousQuarter.Projected_Value__c == 0.00) {
                this.colour = '#CCCCFF';
                return this.colour;
            }
            else {
                value = calculateValue(false);
                data = this.previousQuarter;
                target = startTarget;
            }
        }
        if (target == null || value == null) {
            this.colour = '#CCCCFF';
            return this.colour;
        }
        Decimal difference = 0.0;
        if (data.M_E_Metric__r.Reverse_Comparison__c) {
            difference = (value - target) / value;
        }
        else {
            difference = (target - value) / target;
        }
        if (difference <= 0.1) {
            this.colour = '#00CC00';
        }
        else if (difference <= 0.2) {
            this.colour = '#FFFF33';
        }
        else if (difference > 0.2) {
            this.colour = '#FF0000';
        }
        return this.colour;
    }

    public void setColour(String colour) {
        this.colour = colour;
    }

    public String getTarget() {

        if (this.currentQuarter == null || this.currentQuarter.Projected_Value__c == null || this.currentQuarter.Projected_Value__c == 0) {
            this.target = 'N/A';
        }
        else {
            this.target = this.currentQuarter.Projected_Value__c.format();
        }
        return this.target;
    }

    public void setTarget(String target) {
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

        if (this.currentQuarter.District__r.Name == null) {
            return 'Total';
        }
        return this.currentQuarter.District__r.Name;
    }

    public metricDataWrapper() {

        // This needs to be defaulted so we can see the first quarters record
        previousQuarter = new M_E_Metric_Data__c();
        previousQuarter.Actual_Value__c = 0;
        colour = '#FF0332';
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
                if(item.Actual_Value__c  != null) {
                    chdActual += item.Actual_Value__c + ',';
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

        M_E_Metric_Data__c data = null;
        if (currentQuarter) {
            data = this.currentQuarter;
        }
        else {
            data = this.previousQuarter;
        }
        if (data == null) {
            return null;
        }
        if (data.Manual_Value__c != null) {
            return data.Manual_Value__c;
        }
        return data.Actual_Value__c;
    }

    public String getSubArea() {

        if (this.currentQuarter != null) {
            return this.currentQuarter.M_E_Metric__r.Sub_Area__c;
        }
        else if (this.previousQuarter != null) {
            return this.previousQuarter.M_E_Metric__r.Sub_Area__c;
        }
        return 'Sub Area is not set';
    }

    public void setSubArea(String input) {
        this.subArea = input;
    }

    public String getLabel() {

        if (this.currentQuarter != null) {
            return this.currentQuarter.M_E_Metric__r.Label__c;
        }
        else if (this.previousQuarter != null) {
            return this.previousQuarter.M_E_Metric__r.Label__c;
        }
        return 'Label is not set';
    }

    public void setLabel(String input) {
        this.label = input;
    }

    public String getComment() {

        if (this.currentQuarter != null) {
            return this.currentQuarter.Comment__c;
        }
        return '';
    }

    public void setComment(String input) {
        this.comment = input;
    }

    public String getName() {

        if (this.currentQuarter != null) {
            return this.currentQuarter.M_E_Metric__r.Name;
        }
        else if (this.previousQuarter != null) {
            return this.previousQuarter.M_E_Metric__r.Name;
        }
        return null;
    }

    public void setName(String input) {
        this.name = input;
    }

    public string getHasCurrent() {

        if (this.currentQuarter == null) {
            return 'false';
        }
        return 'true';
    }

    public void setHasCurrent(String input) {
        this.hasCurrent = input;
    }

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
        mdw.previousQuarter = testDataPrevious;
        mdw.currentQuarter = testDataCurrent;
        mdw.getColour();
        mdw.setSparkUrl(testMetric.Name);
        mdw.setComment(mdw.getComment());
        mdw.setLabel(mdw.getLabel());
        mdw.setSubArea(mdw.getSubArea());
        mdw.setName(mdw.getName());
        System.assertEquals(mdw.previousQuarter.Actual_Value__c, 10);
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
        mdw.previousQuarter = testDataPrevious;
        mdw.currentQuarter = testDataCurrent;
        System.assertEquals(mdw.getColour(), '#FF0000');
        System.assertEquals(mdw.previousQuarter.Actual_Value__c, 10);
    }

    public static testMethod void testNullValu() {

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
        mdw.previousQuarter = testDataPrevious;
        mdw.currentQuarter = testDataCurrent;
        System.assertEquals(mdw.getColour(), '#CCCCFF');
        System.assertEquals(mdw.previousQuarter.Actual_Value__c, null);
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
        mdw.previousQuarter = testDataPrevious;
        System.assertEquals(mdw.getColour(), '#00CC00');
        System.assertEquals(mdw.previousQuarter.Actual_Value__c, 15);
    }
}