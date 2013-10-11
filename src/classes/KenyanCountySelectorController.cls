/**
 *  Controller for the component that controls the Kenyan County selector.
 *  Should be the child on a DashboardSelectorComponent.
 */
public with sharing class KenyanCountySelectorController extends ChildComponentBase {

    public KenyanCountySelectorController() {
        if (getShowData()) {
            setKenyanCounties(loadKenyanCounties());
        }
    }

    // Override method to return the controllers chosen value.
    public override String getValues() {

        if (this.kenyanCounty== null) {
            return '';
        }
        return getKenyanCounty();
    }

    public override PageReference refreshData() {

        if (getShowData()) {
            setKenyanCounties(loadKenyanCounties());
        }
        return null;
    }

    // Might need to update this to allow for more than one of these components on the page
    // Add a setter so the name can be changed on the fly from the parent comppnent??
    public String getActionFunctionName() {
        return 'kenyanCountyComponentController';
    }

    // Get the available KenyanCounties. This can take into account a country that has been selected
    public String kenyanCounty;
    public String getKenyanCounty() {
        return this.kenyanCounty;
    }
    public void setKenyanCounty(String kenyanCounty) {
        addParameterToParent(kenyanCounty);
        this.kenyanCounty= kenyanCounty;
    }
    public List<SelectOption> kenyanCounties;
    public List<SelectOption> getKenyanCounties() {
        return this.kenyanCounties;
    }
    public void setKenyanCounties(List<SelectOption> options) {
        this.kenyanCounties= options;
    }
    private List<SelectOption> loadKenyanCounties() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Select a County---'));
        Kenyan_County__c[] counties = database.query(buildKenyanCountyQueryString());
        for (Kenyan_County__c county: counties) {
            options.add(new SelectOption(county.Id, county.County_Name__c));
        }
        return options;
    }

    private String buildKenyanCountyQueryString() {

        String query = 'SELECT ' +
                'Name, ' +
                'County_Name__c ' +                
            'FROM ' +
                'Kenyan_County__c ' +
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

    public static String testController() {

        KenyanCountySelectorController controller = new KenyanCountySelectorController();
        controller.setKenyanCounties(controller.loadKenyanCounties());
        controller.getKenyanCounties();
        controller.getActionFunctionName();
        controller.getValues();
        controller.setKenyanCounty('Nairobi');
        return controller.getKenyanCounty();
    }
}