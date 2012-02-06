global class MetricDataCalculationTracker {

    private String metricName;
    private Decimal total;
    private String function;
    private District__c district;
    private Survey__c survey;
    private Boolean noDataAdded;

    global MetricDataCalculationTracker(
            String metricName,
            String function,
            District__c district,
            Survey__c survey
    ) {

        this.metricName = metricName;
        this.function = function;
        this.district = district;
        this.survey = survey;
        this.total = 0.0;
        this.noDataAdded = true;
    }

    public String getMetricName() {
        return this.metricName;
    }

    public Decimal getTotal() {
        return this.total;
    }

    public void setTotal(Decimal total) {
        this.noDataAdded = false;
        this.total += total;
    }

    public String getFunction() {
        return this.function;
    }

    public District__c getDistrict() {
        return this.district;
    }

    public Survey__c getSurvey() {
        return this.survey;
    }

    public Boolean getNoDataAdded() {
        return this.noDataAdded;
    }

    static testMethod void testConstruction() {

        District__c district = new District__c();
        district.Name = 'Test';
        database.insert(district);
        Survey__c survey = new Survey__c();
        survey.Survey_Name__c = 'hello';
        database.insert(survey);

        MetricDataCalculationTracker metricDataCalculationTracker = new MetricDataCalculationTracker('Me', 'You', district, survey);
        System.assert(metricDataCalculationTracker.getMetricName().equals('Me'));
        System.assert(metricDataCalculationTracker.getFunction().equals('You'));
        System.assertEquals(metricDataCalculationTracker.getTotal(), 0.0);
        System.assert(metricDataCalculationTracker.getNoDataAdded());
        System.assert(metricDataCalculationTracker.getDistrict().Name.equals('Test'));
        System.assert(metricDataCalculationTracker.getSurvey().Survey_Name__c.equals('hello'));
        metricDataCalculationTracker.setTotal(3.0);
        System.assertEquals(metricDataCalculationTracker.getNoDataAdded(), false);
        System.assertEquals(metricDataCalculationTracker.getTotal(), 3.0);
    }
}