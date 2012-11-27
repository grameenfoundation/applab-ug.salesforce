/**
 * Controller for the mtn channels staff selector component
 */
public with sharing class MtnChannelStaffComponentController extends ChildComponentBase {

    private Boolean loaded = false;

    public override PageReference refreshData() {

        if (getShowData()) {
            setMtnChanStaffs(loadMtnChanStaffs());
        }
        return null;
    }

    public String getActionFunctionName() {
        return 'mtnChanStaffSelectorComponentController';
    }

    // Override method to return the controllers chosen value.
    public override String getValues() {

        if (this.mtnChanStaff == null) {
            return '';
        }
        return getMtnChanStaff();
    }

    public String mtnChanStaff;
    public String getMtnChanStaff() {
        return this.mtnChanStaff;
    }
    public void setMtnChanStaff(String mtnChanStaff) {
        addParameterToParent(mtnChanStaff);
        this.mtnChanStaff = mtnChanStaff;
    }
    public List<SelectOption> mtnChanStaffs;
    public List<SelectOption> getMtnChanStaffs() {

        if (!loaded && getShowData()) {
            setMtnChanStaffs(loadMtnChanStaffs());
        }
        return this.mtnChanStaffs;
    }
    public void setMtnChanStaffs(List<SelectOption> options) {
        this.mtnChanStaffs = options;
    }
    private List<SelectOption> loadMtnChanStaffs() {

        List<SelectOption> options = new List<SelectOption>();
        if (getParentValue('Region__c').equals('')) {
            options.add(new SelectOption('', '---Please Select a region first---'));
            return options;
        }
        else {
            options.add(new SelectOption('', '---Please select a staff member---'));
            options.add(new SelectOption('', '---All staff members for chosen region---'));
        }
        MTN_Channels_Staff__c[] staffs = database.query(buildStaffQueryString());
        for (MTN_Channels_Staff__c staff : staffs) {
            options.add(new SelectOption(staff.Person__c, staff.Person__r.Last_Name__c + ' ' + staff.Person__r.First_Name__c));
        }
        loaded = true;
        return options;
    }

    private String buildStaffQueryString() {

        String query = 'SELECT ' +
                'Name, ' +
                'id, ' +
                'Person__c, ' +
                'Person__r.First_Name__c, ' +
                'Person__r.Last_Name__c ' +
            'FROM ' +
                'MTN_Channels_Staff__c ' +
            getWhereClause() +
            ' ORDER BY ' +
                'Person__r.Last_Name__c, ' +
                'Person__r.First_Name__c ';
        System.debug(LoggingLevel.INFO, query);
        return query;
    }

    private String getWhereClause() {

        List<String> whereClauses = new List<String>();
        if (!getParentValue('Region__c').equals('')) {
            whereClauses.add(' Person__r.Region__c = \'' + getParentValue('Region__c') + '\'');
        }

        String clause = '';
        if (whereClauses.size() > 0) {
            clause = ' WHERE ' + SoqlHelpers.joinWhereClause(whereClauses, false);
        }
        return clause;
    }
}