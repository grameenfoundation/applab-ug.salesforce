/**
 *  Controller for the component that controls the field officer selector.
 *  Should be the child on a DashboardSelectorComponent.
 */
public with sharing class FieldOfficerSelectorController extends ChildComponentBase {
    private Boolean loaded = false;

    public override PageReference refreshData() {

        if (getShowData()) {
            setFieldOfficers(loadFieldOfficers());
        }
        return null;
    }

    // Override method to return the controllers chosen value.
    public override String getValues() {

        if (this.fieldOfficer == null) {
            return '';
        }
        return getFieldOfficer();
    }

    public String getActionFunctionName() {
        return 'fieldOfficerSelectorComponentController';
    }

    public String fieldOfficer;
    public String getFieldOfficer() {
        return this.fieldOfficer;
    }
    public void setFieldOfficer(String fieldOfficer) {
        addParameterToParent(fieldOfficer);
        this.fieldOfficer = fieldOfficer;
    }
    public List<SelectOption> fieldOfficers;
    public List<SelectOption> getFieldOfficers() {

        if (!loaded && getShowData()) {
            setFieldOfficers(loadFieldOfficers());
        }
        return this.fieldOfficers;
    }
    public void setFieldOfficers(List<SelectOption> options) {
        this.fieldOfficers = options;
    }
    private List<SelectOption> loadFieldOfficers() {

        List<SelectOption> options = new List<SelectOption>();

        Person__c[] fieldOfficers = database.query(buildFieldOfficerQueryString());
        if (fieldOfficers.size() > 1) {
            options.add(new SelectOption('All', '---All Field Officer---'));
        }
        else {
            options.add(new SelectOption('', '---No Field Officer available---'));
            return options;
        }

        for (Person__c fieldOfficer : fieldOfficers) {
            options.add(new SelectOption(fieldOfficer.Id, fieldOfficer.Name + ' - ' + fieldOfficer.Last_Name__c + ' ' + fieldOfficer.First_Name__c));
        }
        loaded = true;
        return options;
    }

    private String buildFieldOfficerQueryString() {

        String query = 'SELECT ' +
                'Name, ' +
                'id, ' +
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
        return ' WHERE Type__c = \'Field Officer\' ' + clause;
    }
    
    static testMethod void testFieldOfficerSelectorController() {
    	FieldOfficerSelectorController fieldOfficerSelectorController = new FieldOfficerSelectorController();
    	fieldOfficerSelectorController.getFieldOfficers();
    	fieldOfficerSelectorController.refreshData();
    	fieldOfficerSelectorController.getValues();
    	fieldOfficerSelectorController.getActionFunctionName();
    }

}