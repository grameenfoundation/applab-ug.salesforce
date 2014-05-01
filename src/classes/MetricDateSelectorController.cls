/**
 *  Controller to get the metric date chooser
 */
public with sharing class MetricDateSelectorController extends ChildComponentBase {

    // Override method to return the controllers chosen value.
    public override String getValues() {

        if (this.metricDate == null) {
            return '';
        }
        return getMetricDate();
    }

    // Might need to update this to allow for more than one of these components on the page
    // Add a setter so the name can be changed on the fly from the parent comppnent??
    public String getActionFunctionName() {
        return 'metricDateSelectorComponentController';
    }

    // Get the available districts. This can take into account a country that has been selected
    public String metricDate;
    public String getMetricDate() {

        if (this.metricDate == null && getShowData()) {
            this.metricDate = MetricHelpers.createDispRollOverString(Date.today(), getDatePeriod());
        }
        return this.metricDate;
    }
    public void setMetricDate(String metricDate) {
        addParameterToParent(metricDate);
        this.metricDate = metricDate;
    }
    public List<SelectOption> metricDates;
    public List<SelectOption> getMetricDates() {
        if (this.metricDates == null && getShowData()) {
            setMetricDates(loadMetricDateOptions());
        }
        return this.metricDates;
    }
    public void setMetricDates(List<SelectOption> options) {
        this.metricDates = options;
    }

    private Date collectionStartDate;
    public Date getCollectionStartDate() {
        return this.collectionStartDate;
    }
    public void setCollectionStartDate(Date value) {
        this.collectionStartDate = value;
    }

    private String datePeriod;
    public String getDatePeriod() {
        return this.datePeriod;
    }
    public void setDatePeriod(String value) {
        this.datePeriod = value;
    }

    // Each metric section has its own time period selector so each section can be
    // refreshed independantly of the others. This can be overriden by the general selector
    // or hidden completely
    public List<SelectOption> loadMetricDateOptions() {

        List<SelectOption> options = new List<SelectOption>();
        Date startDate = MetricHelpers.getRollOverStartDate(this.collectionStartDate, getDatePeriod());
        Date endDate = MetricHelpers.getRollOverEndDate(Date.today(), getDatePeriod());
        while (startDate.daysBetween(endDate) >= 0) {
            String optionString = MetricHelpers.createDispRollOverString(startDate, getDatePeriod());
            options.add(new SelectOption(optionString, optionString));
            startDate = MetricHelpers.increaseDateRollOver(startDate, getDatePeriod());
        }
        return options;
    }

    static testMethod void testGetRollOverSelectorOptions() {

        MetricDateSelectorController controller = new MetricDateSelectorController();
        controller.setCollectionStartDate(Date.today().addMonths(-6));
        controller.setDatePeriod('Monthly');
        controller.setMetricDates(controller.loadMetricDateOptions());
        System.assertEquals(controller.getMetricDates().size(), 7);
    }
}