/**
 *  Controller for the component that controls the opportunity farmer selector.
 */
public with sharing class OpportunityFarmerSelectorController extends ChildComponentBase {
    private Boolean loaded = false;

    public override PageReference refreshData() {

        if (getShowData()) {
            setOpportunityFarmers(loadOpportunityFarmers());
        }
        return null;
    }

    // Override method to return the controllers chosen value
    public override String getValues() {

        if (this.opportunityFarmer == null) {
            return '';
        }
        return getOpportunityFarmer();
    }

    public String getActionFunctionName() {
        return 'opportunityFarmerSelectorComponentController';
    }

    public String opportunityFarmer;
    public String getOpportunityFarmer() {
        return this.opportunityFarmer;
    }
    public void setOpportunityFarmer(String opportunityFarmer) {
        addParameterToParent(opportunityFarmer);
        this.opportunityFarmer = opportunityFarmer;
    }
    public List<SelectOption> opportunityFarmers;
    public List<SelectOption> getOpportunityFarmers() {

        if (!loaded && getShowData()) {
            setOpportunityFarmers(loadOpportunityFarmers());
        }
        return this.opportunityFarmers;
    }
    public void setOpportunityFarmers(List<SelectOption> options) {
        this.opportunityFarmers = options;
    }

    /**
     *  Populate select option list with Opportunity Farmer names and Id basing on previous selection
     *
     *  @return - list of opportunity farmer names and ids 
     */
    public List<SelectOption> loadOpportunityFarmers() {

        List<SelectOption> options = new List<SelectOption>();

        Person__c[] opportunityFarmers = database.query(buildOpportunityFarmerQueryString());
        if (opportunityFarmers.size() < 1) {
            options.add(new SelectOption('', '---No Opportunity Farmers available---'));
            return options;   
        }
        else {
            options.add(new SelectOption('', '---Please Select Opportunity Farmer---'));
        }

        for (Person__c opportunityFarmer : opportunityFarmers) {
            options.add(new SelectOption(opportunityFarmer.Id, opportunityFarmer.Name + ' - ' + opportunityFarmer.Last_Name__c + ' ' + opportunityFarmer.First_Name__c));
        }
        loaded = true;
        return options;
    }

    /**
     * Build query to pick Opportunity Farmers for the selected district and subcounty
     *
     *  @return - String query
     */
    private String buildOpportunityFarmerQueryString() {

        String query = 'SELECT ' +
                'Name, ' +
                'Id, ' +
                'First_Name__c, ' +
                'Last_Name__c ' +
            'FROM ' +
                'Person__c ' +
            getWhereClause() +
            ' ORDER BY ' +
                'Last_Name__c, ' +
                'First_Name__c ';
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    /**
     *  Construct 'WHERE' clause to pick Opportunity farmers from the selected District and Subcounty
     *
     *  @return - string 'WHERE' clause
     */
    private String getWhereClause() {

        List<String> whereClauses = new List<String>();
        if (!getParentValue('District__c').equals('')) {
            whereClauses.add(' District__c = \'' + getParentValue('District__c') + '\'');
        }
        if (!getParentValue('Subcounty__c').equals('')) {
            whereClauses.add(' Subcounty__c = \'' + getParentValue('Subcounty__c') + '\'');
        }
        String clause = '';
        if (whereClauses.size() > 0) {
            clause = SoqlHelpers.joinWhereClause(whereClauses, true);
        }
        return ' WHERE Type__c = \'Opportunity Farmer\' ' + clause;
    }
}