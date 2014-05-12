/**
 *  Controller to load the settings for the Gumutindo Dashboard
 */

public with sharing class GumutindoDashboardController extends ParentComponentBase {

    private String dashboardName;
    private List<Dashboard_Section__c> sections;
    private Dashboard_Section__c section;
    
    public GumutindoDashboardController() {
        //setDashboardName('a13b0000000lZem');
        setDashboardName('Gumutindo Dashboard');
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
    
    
    
    
     
     
                 
}