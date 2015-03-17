/**
 *  Controller for the component that controls the district selector.
 *  Should be the child on a DashboardSelectorComponent.
 */
public with sharing class DistrictSelectorController extends ChildComponentBase {

    public DistrictSelectorController() {
        if (getShowData()) {
            setDistricts(loadDistricts());
        }
    }

    // Set the refresh list for this controller. Should this go to its own sObject to be more configurable.
    public override String getRefreshList() {
        return 'Subcounty__c' + this.getParentComponentController().getSectionKey() +
            ',Person__c' + this.getParentComponentController().getSectionKey();
    }

    // Override method to return the controllers chosen value.
    public override String getValues() {

        if (this.district == null) {
            return '';
        }
        return getDistrict();
    }

    public override PageReference refreshData() {

        if (getShowData()) {
            setDistricts(loadDistricts());
        }
        return null;
    }

    // Might need to update this to allow for more than one of these components on the page
    // Add a setter so the name can be changed on the fly from the parent comppnent??
    public String getActionFunctionName() {
        return 'districtSelectorComponentController';
    }

    // Get the available districts. This can take into account a country that has been selected
    public String district;
    public String getDistrict() {
        return this.district;
    }
    public void setDistrict(String district) {
        addParameterToParent(district);
        this.district = district;
    }
    public List<SelectOption> districts;
    public List<SelectOption> getDistricts() {
        return this.districts;
    }
    public void setDistricts(List<SelectOption> options) {
        this.districts = options;
    }
    private List<SelectOption> loadDistricts() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Please Select a District---'));
        District__c[] districts = database.query(buildDistrictQueryString());
        for (District__c district : districts) {
            options.add(new SelectOption(district.Id, district.Name));
        }
        return options;
    }

    private String buildDistrictQueryString() {

        return 'SELECT ' +
                'Name, ' +
                'Id ' +
            'FROM ' +
                'District__c ' +
                getWhereClause() +
            'ORDER BY ' +
                'Name';
    }

    private String getWhereClause() {

        String value = getParentValue('Organisation');
        if (!value.equals('')) {
            return 'WHERE Id IN (SELECT District__c FROM Organisation_District_Association__c WHERE Organisation__r.Name = \'' + value + '\') ';
        }
        return '';
    }

    static testMethod void testController() {

        DistrictSelectorController controller = new DistrictSelectorController();
        controller.setDistricts(controller.loadDistricts());
        controller.getDistricts();
        controller.getActionFunctionName();
        controller.getValues();
        controller.setDistrict('Hi');
        controller.getDistrict();
    }
}