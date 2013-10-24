/**
 *  Controller for the component that controls the district selector.
 *  Should be the child on a DashboardSelectorComponent.
 */
public with sharing class BracAreaSelectorController extends ChildComponentBase {

    public BracAreaSelectorController() {
        if (getShowData()) {
            setBracAreas(loadBracAreas());
        }
    }

    // Set the refresh list for this controller. Should this go to its own sObject to be more configurable.
    public override String getRefreshList() {
        return 'Person__c' + this.getParentComponentController().getSectionKey();
    }

    // Override method to return the controllers chosen value.
    public override String getValues() {

        if (this.bracArea== null) {
            return '';
        }
        return getBracArea();
    }

    public override PageReference refreshData() {

        if (getShowData()) {
            setBracAreas(loadBracAreas());
        }
        return null;
    }

    // Might need to update this to allow for more than one of these components on the page
    // Add a setter so the name can be changed on the fly from the parent comppnent??
    public String getActionFunctionName() {
        return 'bracAreaSelectorComponentController';
    }

    // Get the available Brac Areas. This can take into account a country that has been selected
    public String bracArea;
    public String getBracArea() {
        return this.bracArea;
    }
    public void setBracArea(String bracArea) {
        addParameterToParent(bracArea);
        this.bracArea = bracArea;
    }
    public List<SelectOption> bracAreas;
    public List<SelectOption> getBracAreas() {
        return this.bracAreas;
    }
    public void setBracAreas(List<SelectOption> options) {
        this.bracAreas = options;
    }
    private List<SelectOption> loadBracAreas() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Please Select an Area---'));
        Schema.DescribeFieldResult field = Schema.getGlobalDescribe().get('BRAC_PA__c').getDescribe().fields.getMap().get('Area__c').getDescribe();
        String fieldType = String.valueOf(field.getType());
        if (fieldType.equals('MULTIPICKLIST') || fieldType.equals('PICKLIST')) {
            for (Schema.PicklistEntry e : field.getPicklistValues()) {
                options.add(new SelectOption(e.getValue(), e.getLabel()));
            }
        }
        return options;
    }


    static testMethod void testController() {

        BracAreaSelectorController controller = new BracAreaSelectorController();
        controller.setBracAreas(controller.loadBracAreas());
        controller.getBracAreas();
        controller.getActionFunctionName();
        controller.getValues();
        controller.setBracArea('Hi');
        controller.getBracArea();
    }
}