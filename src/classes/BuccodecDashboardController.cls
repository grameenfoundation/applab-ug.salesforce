/**
 *
 * Copyright (c) 2014 AppLab, Grameen Foundation
 *
 *  Controller class for BuccodecDashboard page
 *  Its test methods are in the BuccodecTests class 
 **/
public class BuccodecDashboardController {

    private Boolean isEditMode = false;
    private String currentQuarter = null;
    private String showPreviousQuarter = 'true';
    private List<BuccodecHelpers.DataWrapper> scaleData = new List<BuccodecHelpers.DataWrapper>();
    private List<BuccodecHelpers.DataWrapper> impactData = new List<BuccodecHelpers.DataWrapper>();
    private List<BuccodecHelpers.DataWrapper> qualityData = new List<BuccodecHelpers.DataWrapper>();
    private List<BuccodecHelpers.DataWrapper> sustainabilityData = new List<BuccodecHelpers.DataWrapper>();
    private Transient Map<String, Map<String, BuccodecHelpers.DataWrapper>> metricWrappers;
    private Transient Map<String, List<String>> metricWrapperOrder;
    private Map<String, Boolean> viewSectionsMap = new Map<String, Boolean>();
    
    public String quarter = null;
    public String isUpdateable = 'true';

    public BuccodecDashboardController(){
        setUpQuarter(ApexPages.currentPage().getParameters().get('quarter'));
        setUp(ApexPages.currentPage());
    }
    
    public String tabName { get; set; }
    
    private void setUp(PageReference pageRef) {

        // Try to keep the tab we're on
        String tabName = pageRef.getParameters().get('sfdc.tabName');
        this.tabName = tabName != null ? tabName : tabName;
        this.isEditMode = (pageRef.getParameters().get('editMode') == 'true');
        
        List<Metric_Section__c> values = [
            SELECT
                Title__c,
                Is_Active__c
            FROM
                Metric_Section__c
            WHERE
                Dashboard_Section__r.Dashboard__r.Account__r.Name = :BuccodecHelpers.ORG_NAME
        ];
        for(Metric_Section__c section : values) {
            viewSectionsMap.put(section.Title__c, section.Is_Active__c);
        }
    }

    public List<SelectOption> getQuarters() {

        List<SelectOption> options = new List<SelectOption>();
        Integer currentYear = Date.today().year();
        Integer currentQuarter = MetricHelpers.getQuarter(Date.today());
        Integer quarter;
        Integer startYear;

        // Data starts in Q3-2014 (using calendar quarters, not fiscal) for grameen.
        startYear = 2014;
        quarter = 3;
        for(Integer year = startYear; year <= currentYear; year++) {
            quarter = year != startYear ? 1 : quarter;
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
    
    public String getQuarter() {
        return quarter;
    }
    
    public void setQuarter(String quarter) {
        this.quarter = quarter;
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
    
    public String getCurrentQuarter() {
        return currentQuarter;
    }

    public void setCurrentQuarter(String quarter) {
        this.currentQuarter = quarter;
    }
    
    public PageReference changeQuarter() {

        //MetricHelpers.generateMetrics(MetricHelpers.getQuarterFirstDay(this.quarter), MetricHelpers.getQuarterLastDay(this.quarter), getOrgName());
        PageReference resultPage = ApexPages.currentPage(); 
        resultPage.getParameters().put('quarter', this.quarter);
        resultPage.getParameters().put('sfdc.tabName', this.tabName);
        resultPage.setRedirect(true);
        return resultPage;
    }
    
    public String getIsCurrentQuarter() {
        String isCurrent = 'false';
        isCurrent = (null != this.quarter && this.quarter.equals(this.currentQuarter)) ? 'true' : 'false';
        return isCurrent;
    }
    
    // For the moment we always want to return true here as we are updating targets manually
    public String getIsUpdateable() {
        return this.isUpdateable;
    }
    public void setIsUpdateable(String value) {
        this.isUpdateable = value;
    }
        
    public String getIsEditMode() {
        String isEditing = 'false';
        isEditing = this.isEditMode ? 'true' : 'false';
        return isEditing;
    }

    public BuccodecHelpers.DataWrapper[] getScaleData() {
        return getAreaData('Scale');
    }
    
    public BuccodecHelpers.DataWrapper[] getImpactData() {
        return getAreaData('Impact');
    }

    public BuccodecHelpers.DataWrapper[] getQualityData() {
        return getAreaData('Quality');
    }

    public BuccodecHelpers.DataWrapper[] getSustainabilityData() {
        return getAreaData('Sustainability');
    }

    private BuccodecHelpers.DataWrapper[] getAreaData(String area) {

        List<BuccodecHelpers.DataWrapper> areaData = new List<BuccodecHelpers.DataWrapper>();
        if (this.metricWrappers == null) {
            BuccodecHelpers.Wrapper wrapper = BuccodecHelpers.getData(this.quarter);
            this.metricWrappers = wrapper.dataWrapper;
            this.metricWrapperOrder = wrapper.dataWrapperOrder;
        }
        Map<String, BuccodecHelpers.DataWrapper> wrappers = this.metricWrappers.get(area);
        List<String> metricOrder = this.metricWrapperOrder.get(area);
        if (wrappers != null && metricOrder != null) {
            for (String key : metricOrder) {
                BuccodecHelpers.DataWrapper wrapper = wrappers.get(key);
                if (wrapper != null) {
                    areaData.add(wrapper);
                }
            }
        }
        return areaData;
    }
    
    public Boolean getViewQuality(){
        return viewSectionsMap.get('Quality');
    }
    public Boolean getViewScale(){
        return viewSectionsMap.get('Scale');
    }
    public Boolean getViewImpact(){
        return viewSectionsMap.get('Impact');
    }
    public Boolean getViewSustainability(){
        return viewSectionsMap.get('Sustainability');
    }
}