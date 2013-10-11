/**
 *  Controller for the component that controls the district selector.
 *  Should be the child on a DashboardSelectorComponent.
 */
public with sharing class BracPaSelectorController extends ChildComponentBase {

    public BracPaSelectorController() {
        if (getShowData()) {
            setBracPas(loadBracPas());
        }
    }

    // Override method to return the controllers chosen value.
    public override String getValues() {

        if (this.bracPa == null) {
            return '';
        }
        return getBracPa();
    }

    public override PageReference refreshData() {

        if (getShowData()) {
            setBracPas(loadBracPas());
        }
        return null;
    }

    // Might need to update this to allow for more than one of these components on the page
    // Add a setter so the name can be changed on the fly from the parent comppnent??
    public String getActionFunctionName() {
        return 'bracPaComponentController';
    }

    // Get the available BracPas. This can take into account a country that has been selected
    public String bracPa;
    public String getBracPa() {
        return this.bracPa;
    }
    public void setBracPa(String bracPa) {
        addParameterToParent(bracPa);
        this.bracPa = bracPa;
    }
    public List<SelectOption> bracPas;
    public List<SelectOption> getBracPas() {
        return this.bracPas;
    }
    public void setBracPas(List<SelectOption> options) {
        this.BracPas = options;
    }
    private List<SelectOption> loadBracPas() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Please Select a PA---'));
        Person__c[] bracPas = database.query(buildBracPaQueryString());
        for (Person__c bracPa : bracPas) {
            options.add(new SelectOption(bracPa.Id, bracPa.First_Name__c + ' '  + bracPa.Last_Name__c));
        }
        return options;
    }

    private String buildBracPaQueryString() {

        String query = 'SELECT ' +
                'Name, ' +
                'First_Name__c, ' +
                'Last_Name__c, ' +
                'Id ' +
            'FROM ' +
                'Person__c ' +
            'WHERE ' +
                getWhereClause() +
                ' Type__c = \'BRAC PA\' ' +
            'ORDER BY ' +
                'Name';
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    private String getWhereClause() {

        String value = getParentValue('Village__c');
        if (!value.equals('')) {
            return ' Village__c = \'' + value + '\' AND ';
        }
        return '';
    }

    static testMethod void testController() {

        BracPaSelectorController controller = new BracPaSelectorController();
        controller.setBracPas(controller.loadBracPas());
        controller.getBracPas();
        controller.getActionFunctionName();
        controller.getValues();
        controller.setBracPa('Hi');
        System.assert(controller.getBracPa().equals('Hi'));
    }
}