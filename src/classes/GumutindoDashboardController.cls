/**
 *  Controller to load the settings for the Gumutindo Dashboard
 */

public with sharing class GumutindoDashboardController extends ParentComponentBase {

    private String dashboardName;
    private List<Dashboard_Section__c> sections;
    private Dashboard_Section__c section;
    
    public GumutindoDashboardController() {
        setDashboardName('a13b0000000lZem');
        setSections(loadSections());
    }

    public override void rebuildParameters() {

        if (this.getParentMap() != null && this.getParentMap().get('DashboardSelectora13b0000000lZemAAE') != null) {
            this.getParentMap().get('DashboardSelectora13b0000000lZemAAE').rebuildParameters();
            this.setParameters(this.getParentMap().get('DashboardSelectora13b0000000lZemAAE').getParameters());
        }
    }
 
    public String getDashboardName() {
        return this.dashboardName;
    }
    public void setDashboardName(String value) {
        this.dashboardName = value;
    }

    public void setSection(Dashboard_Section__c section) {
        this.section = section;
    }
    
    public Dashboard_Section__c getSection() {
        return this.section;
    }
    public List<Dashboard_Section__c> getSections() {
        return this.sections;
    }
    public void setSections(List<Dashboard_Section__c> values) {
        this.sections = values;
    }
    public List<Dashboard_Section__c> loadSections() {

        List<Dashboard_Section__c> sectionsToLoad = [SELECT
                Name,
                Id,
                Title__c,
                Has_Graphs__c,
                Has_Metrics__c,
                Has_Maps__c,
                Has_Selector__c,
                Dashboard__r.Account__r.Name
            FROM
                Dashboard_Section__c
            WHERE
                Dashboard__r.Name = :dashboardName
                AND Is_Active__c = true
            ORDER BY
                Display_Order__c];
        return sectionsToLoad;
    }
    
    private Dashboard_Selector__c selector;
    public Dashboard_Selector__c getSelector() {
        List<Dashboard_Selector__c> selectors = 
            [SELECT
                Show_Dates__c,
                Show_Metric_Date_Selector__c,
                Show_Country__c,
                Show_Region__c,
                Show_District__c,
                Show_Subcounty__c,
                Show_Person__c,
                Show_Opportunity_Farmer__c,
                Show_Data_Validator__c,
                Show_CKW__c,
                Show_Farmer__c,
                Show_Field_Officer__c,
                Show_MTN_Chan__c,
                Date_Period__c,
                Start_Date__c,
                Show_Submit_Button__c,
                Show_Brac_PA__c,
                Show_Brac_Area__c,
                Show_Kenyan_County__c,
                Show_BVAT_CIW__c
            FROM
                Dashboard_Selector__c
            WHERE
                Is_Active__c = true
                AND Dashboard_Section__r.Name = 'DS0000003855'
            ORDER BY
                CreatedDate DESC];

        if (selectors.size() == 0) {
            return null;
        }
        return selectors[0];

    }
    public void setSelector(Dashboard_Selector__c value) {
        this.selector = value;
    }
    
     private List<Map_Parameter__c> ciwMaps;
    public List<Map_Parameter__c> getCiwMaps() {
        this.ciwMaps = [SELECT
                Id,
                Name,
                Title__c,
                Latitude__c,
                Longitude__c,
                Type_Of_sObject__c,
                Zoom__c,
                Splitter__c
            FROM
                Map_Parameter__c
            WHERE 
                Name = 'MP0000000000'];
        return this.ciwMaps;
    }
    public void setCiwMaps(List<Map_Parameter__c> maps) {
        this.ciwMaps = maps;
    }
    
    private List<Metric_Section__c> ciwMetrics;
    public List<Metric_Section__c> getCiwMetrics() {
        this.ciwMetrics = [SELECT
                Id,
                Name,
                Title__c,
                Dashboard_Section__r.Dashboard__r.Account__r.Name,
                Description__c,
                RollOver_Time__c,
                Start_Date__c,
                Show_RollOver_Selector__c,
                Show_Targets__c,
                Show_Previous_Quarter__c,
                Show_Comments__c,
                Show_Break_Down__c,
                Show_Spark_Line__c,
                Show_Further_Link__c,
                Default_Show__c,
                Allow_Update__c,
                View_Mode__c
            FROM
                Metric_Section__c
            WHERE
                Name = 'MS0000000577'];
        return this.ciwMetrics;
    }
    public void setCiwMetrics(List<Metric_Section__c> metrics) {
        this.ciwMetrics = metrics;
    }

    
              

    @isTEst
    static testMethod void testGumutindoDashboardController() {

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