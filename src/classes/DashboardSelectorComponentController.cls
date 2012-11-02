/**
 *  Controller for a dashboard selector.
 *  Controls what is to be displayed on a given selector.
 *  This can be inserted inside a dashboard section to control the display on that section
 */
public with sharing class DashboardSelectorComponentController extends ParentComponentBase {

    private Dashboard_Selector__c selector;
    public Dashboard_Selector__c getSelector() {
        return this.selector;
    }
    public void setSelector(Dashboard_Selector__c value) {
        this.selector = value;
        this.addParameter('DatePeriod' + getSectionKey(), value.Date_Period__c);
        this.addParameter('SelectorId' + getSectionKey(), value.Id);
    }

    public Boolean getShowRegion() {
        return this.selector.Show_Region__c;
    }

    public Boolean getShowDistrict() {
        return this.selector.Show_District__c;
    }

    public Boolean getShowSubcounty() {
        return this.selector.Show_Subcounty__c;
    }

    public Boolean getShowDates() {
        return this.selector.Show_Dates__c;
    }

    public Boolean getShowMetricDates() {
        return this.selector.Show_Metric_Date_Selector__c;
    }

    public Boolean getShowPerson() {
        return this.selector.Show_Person__c;
    }

    public Boolean getShowDataValidator() {
        return this.selector.Show_Data_Validator__c;
    }

    public Boolean getShowMtnChan() {
        return this.selector.Show_MTN_Chan__c;
    }

    public Boolean getShowFieldOfficer() {
        return this.selector.Show_Field_Officer__c;
    }

    public Date getStartDate() {
        return this.selector.Start_Date__c;
    }

    public String getDatePeriod() {
        return this.selector.Date_Period__c;
    }

    public Boolean getShowSubmitButton() {
        return this.selector.Show_Submit_Button__c;
    }

    private String accountName;
    public String getAccountName() {
        return this.accountName;
    }
    public void setAccountName(String value) {
        this.accountName = value;
        addParameter('Organisation' + getSectionKey(), value);
    }

    private Boolean expanded;
    public Boolean getExpanded() {
        return this.expanded;
    }
    public void setExpanded(Boolean value) {
        this.expanded = value;
    }

    public override String getHandle() {
        return 'SELECTOR';
    }

    static testMethod void testStuff() {

        DashboardSelectorComponentController controller = new DashboardSelectorComponentController();

        Account account = new Account();
        account.Name = 'Account';
        account.BillingState = 'CA';
        Database.insert(account);

        Dashboard__c dash = new Dashboard__c();
        dash.Account__c = account.Id;
        dash.Title__c = 'Title';
        dash.Description__c = 'Description';
        Database.insert(dash);

        Dashboard_Section__c section = new Dashboard_Section__c();
        section.Dashboard__c = dash.Id;
        section.Title__c = 'Title';
        Database.insert(section);

        Dashboard_Selector__c selector = new Dashboard_Selector__c();
        selector.Show_Person__c = true;
        selector.Show_Metric_Date_Selector__c = true;
        selector.Show_Dates__c = true;
        selector.Show_Subcounty__c = true;
        selector.Show_District__c = true;
        selector.Dashboard_Section__c = section.id;
        controller.setSelector(selector);

        controller.setAccountName('HELLO');
        controller.getAccountName();
        controller.setExpanded(true);
        controller.getExpanded();
        System.assert(controller.getShowDates());
        System.assert(controller.getShowDistrict());
        System.assert(controller.getShowSubcounty());
        System.assert(controller.getShowMetricDates());
        System.assert(controller.getShowPerson());
    }
}