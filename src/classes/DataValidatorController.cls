/**
 * Controller for the component that creates a dop down list of all the available DVs
 */
public with sharing class DataValidatorController extends ChildComponentBase {

    private Boolean loaded = false;

    public override PageReference refreshData() {

        if (getShowData()) {
            setDataValidators(loadDataValidators());
        }
        return null;
    }

    // Override method to return the controllers chosen value.
    public override String getValues() {

        if (this.dataValidator == null) {
            return '';
        }
        return getDataValidator();
    }

    public String getActionFunctionName() {
        return 'dataValidatorSelectorComponentController';
    }

    public String dataValidator;
    public String getDataValidator() {
        return this.dataValidator;
    }
    public void setDataValidator(String dataValidator) {
        addParameterToParent(dataValidator);
        this.dataValidator = dataValidator;
    }
    public List<SelectOption> dataValidators;
    public List<SelectOption> getDataValidators() {

        if (!loaded && getShowData()) {
            setDataValidators(loadDataValidators());
        }
        return this.dataValidators;
    }
    public void setDataValidators(List<SelectOption> options) {
        this.dataValidators = options;
    }
    private List<SelectOption> loadDataValidators() {

        List<SelectOption> options = new List<SelectOption>();
        if (getParentValue('District__c').equals('')) {
            options.add(new SelectOption('', '---Please Select a District first---'));
            return options;
        }

        Person__c[] dataValidators = database.query(buildDataValidatorQueryString());
        if (dataValidators.size() > 1) {
            options.add(new SelectOption('', '---Please Select a Data Validator---'));
        }
        else {
            options.add(new SelectOption('', '---No Data Validators available---'));
            return options;
        }

        for (Person__c dataValidator : dataValidators) {
            options.add(new SelectOption(dataValidator.Id, dataValidator.Name + ' ' + dataValidator.Last_Name__c + ' ' + dataValidator.First_Name__c));
        }
        loaded = true;
        return options;
    }

    private String buildDataValidatorQueryString() {

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
            clause = ' WHERE Type__c = \'Data Validator\' ' + SoqlHelpers.joinWhereClause(whereClauses, true);
        }
        return clause;
    }

    static testMethod void testController() {

        // Create a test district
        District__c district = Utils.createTestDistrict('Test');
        Database.insert(district);

       // Create a test Test Field Officer
        Person__c person1 = Utils.createTestPerson(null, 'TestingDV', true, district.Id, 'Female');
        person1.Type__c = 'Data Validator';
        database.insert(person1);

        Test.startTest();
        DashboardSelectorComponentController parent = new DashboardSelectorComponentController();
        parent.addParameter('District__ckey', district.Id);

        DataValidatorController controller = new DataValidatorController();
        controller.setKey('graph');
        controller.setSectionKey('key');
        controller.setParentComponentController(parent);

        controller.setDataValidators(controller.getDataValidators());
        controller.setShowData(true);
        controller.refreshData();
        controller.getValues();
        controller.setDataValidator('hi');
        controller.getValues();
    }
}