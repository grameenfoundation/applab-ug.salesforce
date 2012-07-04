/**
 *  Controller for a dashboard selector.
 *  Controls what is to be displayed on a given selector.
 *  This can be inserted inside a dashboard section to control the display on that section
 */
public with sharing class DashboardSelectorComponentController extends ParentComponentBase {

    private Boolean showDistrict = false;
    public Boolean getShowDistrict() {
        return this.showDistrict;
    }
    public void setShowDistrict(Boolean show) {
        this.showDistrict = show;
    }

    private Boolean showSubcounty = true;
    public Boolean getShowSubcounty() {
        return this.showSubcounty;
    }
    public void setShowSubcounty(Boolean show) {
        this.showSubcounty = show;
    }

    private Boolean showDates = true;
    public Boolean getShowDates() {
        if (!this.expanded) {
            return false;
        }
        return this.showDates;
    }
    public void setShowDates(Boolean show) {
        this.showDates = show;
    }

    private String accountName;
    public String getAccountName() {
        return this.accountName;
    }
    public void setAccountName(String value) {
        this.accountName = value;
        addParameter('Organisation' + getSectionKey(), value);
    }

    private Boolean expanded;
    public Boolean getExpanded() {
        return this.expanded;
    }
    public void setExpanded(Boolean value) {
        this.expanded = value;
    }

    static testMethod void testStuff() {

        DashboardSelectorComponentController controller = new DashboardSelectorComponentController();

        controller.setAccountName('HELLO');
        controller.getAccountName();
        controller.setExpanded(true);
        controller.getExpanded();
        controller.setShowDates(controller.getShowDates());
        controller.setShowDistrict(controller.getShowDistrict());
        controller.setShowSubcounty(controller.getShowSubcounty());
    }
}