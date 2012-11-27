/**
 *  Controller for the select region component
 */
public with sharing class RegionSelectorComponentController extends ChildComponentBase {

    private Boolean loaded = false;

    // Set the refresh list for this controller. Should this go to its own sObject to be more configurable.
    public override String getRefreshList() {
        return 'Person__c' + this.getParentComponentController().getSectionKey();
    }

    // Override method to return the controllers chosen value.
    public override String getValues() {

        if (this.region == null) {
            return '';
        }
        return getRegion();
    }

    public override PageReference refreshData() {

        if (getShowData()) {
            setRegions(loadRegions());
        }
        return null;
    }

    // Might need to update this to allow for more than one of these components on the page
    // Add a setter so the name can be changed on the fly from the parent comppnent??
    public String getActionFunctionName() {
        return 'regionSelectorComponentController';
    }

    // Get the available districts. This can take into account a country that has been selected
    public String region;
    public String getRegion() {
        return this.region;
    }
    public void setRegion(String region) {
        addParameterToParent(region);
        this.region = region;
    }
    public List<SelectOption> regions;
    public List<SelectOption> getRegions() {

        if (!loaded && getShowData()) {
            setRegions(loadRegions());
        }
        return this.regions;
    }
    public void setRegions(List<SelectOption> options) {
        this.regions = options;
    }
    private List<SelectOption> loadRegions() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '---Please Select a Region---'));
        options.add(new SelectOption('', '---All Regions---'));
        Region__c[] regions = database.query(buildRegionQueryString());
        for (Region__c region : regions) {
            options.add(new SelectOption(region.Id, region.Display_Name__c));
        }
        loaded = true;
        return options;
    }

    private String buildRegionQueryString() {

        return 'SELECT ' +
                'Name, ' +
                'Display_Name__c, ' +
                'Id ' +
            'FROM ' +
                'Region__c ' +
            'ORDER BY ' +
                'Name';
    }
}