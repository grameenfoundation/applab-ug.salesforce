/**
 *  Controller for the component that controls the district selector.
 *  Should be the child on a DashboardSelectorComponent.
 */
public with sharing class CiwSelectorController extends ChildComponentBase {

    public CiwSelectorController() {
        if (getShowData()) {
            setCiws(loadCiws());
        }
    }

    // Override method to return the controllers chosen value.
    public override String getValues() {

        if (this.ciw== null) {
            return '';
        }
        return getCiw();
    }

    public override PageReference refreshData() {

        if (getShowData()) {
            setCiws(loadCiws());
        }
        return null;
    }

    // Might need to update this to allow for more than one of these components on the page
    // Add a setter so the name can be changed on the fly from the parent comppnent??
    public String getActionFunctionName() {
        return 'ciwComponentController';
    }

    // Get the available CIWs.
    public String ciw;
    public String getCiw() {
        return this.ciw;
    }
    public void setCiw(String ciw) {
        addParameterToParent(ciw);
        this.ciw = ciw;
    }
    public List<SelectOption> ciws;
    public List<SelectOption> getCiws() {
        return this.ciws;
    }
    public void setCiws(List<SelectOption> options) {
        this.ciws= options;
    }
    private List<SelectOption> loadCiws() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--- Select a CIW---'));
        CIW__c[] ciws = database.query(buildCiwQueryString());
        for (CIW__c ciw: ciws) {
            options.add(new SelectOption(ciw.Id, ciw.Person__r.First_Name__c + ' ' + ciw.Person__r.Last_Name__c));
        }
        return options;
    }

    private String buildCiwQueryString() {
        
        String query = 'SELECT ' +
                'Name, ' +
                'Person__r.First_Name__c, ' +   
                'Person__r.Last_Name__c ' +             
            'FROM ' +
                'CIW__c ' +            
            'ORDER BY ' +
                'Person__r.First_Name__c, Person__r.Last_Name__c';
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

        CiwSelectorController controller = new CiwSelectorController();
        controller.setCiws(controller.loadCiws());
        controller.getCiws();
        controller.getActionFunctionName();
        controller.getValues();
        controller.setCiw('Hi');
        return controller.getCiw();        
    }
}