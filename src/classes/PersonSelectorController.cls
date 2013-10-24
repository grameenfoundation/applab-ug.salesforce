/**
 *  Controller for the component used to select people
 */

public with sharing class PersonSelectorController extends ChildComponentBase {

    private Boolean loaded = false;

    public PersonSelectorController() {

    }

    public override PageReference refreshData() {

        if (getShowData()) {
            setPersons(loadPersons());
        }
        return null;
    }

    public String getActionFunctionName() {
        return 'personSelectorComponentController';
    }

    // Override method to return the controllers chosen value.
    public override String getValues() {

        if (this.person == null) {
            return '';
        }
        return getPerson();
    }

    public String person;
    public String getPerson() {
        return this.person;
    }
    public void setPerson(String person) {
        addParameterToParent(person);
        this.person = person;
    }
    public List<SelectOption> persons;
    public List<SelectOption> getPersons() {

        if (!loaded && getShowData()) {
            setPersons(loadPersons());
        }
        return this.persons;
    }
    public void setPersons(List<SelectOption> options) {
        this.persons = options;
    }
    private List<SelectOption> loadPersons() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Please Select a district first---'));
        if (getParentValue('District__c').equals('')) {
            return options;
        }
        Person__c[] persons = database.query(buildPersonQueryString());
        for (Person__c person : persons) {
            options.add(new SelectOption(person.Id, person.Name));
        }
        loaded = true;
        return options;
    }

    private String buildPersonQueryString() {

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

//        setDates(getParentValue('datePicker'));
//        if (this.getStartDate(false)) {
//            whereClauses.add();
//        }
        String clause = '';
        if (whereClauses.size() > 0) {
            clause = ' WHERE ' + SoqlHelpers.joinWhereClause(whereClauses, false);
        }
        return clause;
    }
}