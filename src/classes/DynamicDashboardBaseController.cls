/**
 *  Virtual class to provide common methods required for all dashboards
 */
public with sharing virtual class DynamicDashboardBaseController {

    private String dashboardName;
    public String getDashboardName() {
        return this.dashboardName;
    }
    public void setDashboardName(String value) {
        this.dashboardName = value;
    }

    // Get the sections for the dashboard to display (Cannot be used until bug in SFDC is fixed!!!)
    // Called by extending class and must be called after setDashboardName is called
    private List<Dashboard_Section__c> sections;
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
                Has_Selector__c
            FROM
                Dashboard_Section__c
            WHERE
                Dashboard__r.Name = :dashboardName
                AND Is_Active__c = true];
        return sectionsToLoad;
    }

    static testMethod void testController() {

        Account account = new Account();
        account.Name = 'Account';
        account.BillingState = 'CA';
        Database.insert(account);

        Dashboard__c dash = new Dashboard__c();
        dash.Account__c = account.Id;
        dash.Title__c = 'Title';
        dash.Description__c = 'Description';
        Database.insert(dash);

        Dashboard__c dash2 = [SELECT Name FROM Dashboard__c WHERE Id = :dash.id];

        Dashboard_Section__c section = new Dashboard_Section__c();
        section.Dashboard__c = dash.Id;
        section.Title__c = 'Title';
        Database.insert(section);

        DynamicDashboardBaseController controller = new DynamicDashboardBaseController();
        controller.setDashboardName(dash.Name);
        controller.getDashboardName();
        controller.setSections(controller.loadSections());
        controller.getSections();
    }
}