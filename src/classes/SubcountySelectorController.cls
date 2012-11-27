/**
 *  Controller for the component that controls the subcounty selector.
 *  Should be the child on a DashboardSelectorComponent.
 */
public with sharing class SubcountySelectorController extends ChildComponentBase {

    private Boolean loaded = false;

    public String getActionFunctionName() {
        return 'subcountySelectorComponentController' + getParentKey();
    }

    // Override method to return the controllers chosen value.
    public override String getValues() {
        return getSubcounty();
    }

    public override PageReference refreshData() {

        if (getShowData()) {
            setSubcounties(loadSubcounties());
        }
        return null;
    }

    // Get the available subcounties. This can take into account a country that has been selected
    public String subcounty;
    public String getSubcounty() {
        return this.subcounty;
    }
    public void setSubcounty(String subcounty) {
        addParameterToParent(subcounty);
        this.subcounty = subcounty;
    }
    public List<SelectOption> subcounties;
    public List<SelectOption> getSubcounties() {
        if (!this.loaded && getShowData()) {
            setSubcounties(loadSubcounties());
        }
        return this.subcounties;
    }
    public void setSubcounties(List<SelectOption> options) {
        this.subcounties = options;
    }
    public List<SelectOption> loadSubcounties() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Please Select a Subcounty---'));
        Subcounty__c[] subcounties = database.query(buildSubcountyQueryString());
        for (Subcounty__c subcounty : subcounties) {
            options.add(new SelectOption(subcounty.Id, subcounty.Display_Name__c));
        }
        this.loaded = true;
        return options;
    }

    private String buildSubcountyQueryString() {
        String query =  'SELECT ' +
                'Id, ' +
                'Display_Name__c ' +
            'FROM ' +
                'Subcounty__c ' +
            buildWhereClause() +
            ' ORDER BY ' +
                'Display_Name__c';

        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    private String buildWhereClause() {

        List<String> clauses = new List<String>();
        if (!getParentValue('District__c').equals('')) {
            clauses.add(' District__c = \'' + getParentValue('District__c') + '\'');
        }
        if (!getParentValue('Organisation').equals('')) {
            clauses.add(' District__c IN (SELECT District__c FROM Organisation_District_Association__c WHERE Organisation__r.Name = \'' + getParentValue('Organisation') + '\') ');
        }
        if (clauses.size() == 0) {
            return '';
        }
        return ' WHERE ' + SoqlHelpers.joinWhereClause(clauses, false);
    }

    static testMethod void testController() {

        SubcountySelectorController controller = new SubcountySelectorController();
        controller.getSubcounties();
        controller.getActionFunctionName();
        controller.getValues();
        controller.refreshData();
    }
}