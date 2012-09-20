/**
 * Controller for the break down page for the field office dashboard.
 * Decides what type of break down it is and then allow the correct component to load
 */
public with sharing class FieldOfficerBreakDownController extends ParentComponentBase {

    public override void rebuildParameters() {
        this.getParentMap().get('DashboardSelectorKey').rebuildParameters();
        this.setParameters(this.getParentMap().get('DashboardSelectorKey').getParameters());
    }

    public String getAccountName() {
        return 'AppLab Uganda';
    }

    private Dashboard_Selector__c selector;
    public Dashboard_Selector__c getSelector() {
        return this.selector;
    }

    private Boolean showSelector = true;
    public Boolean getShowSelector() {
        return this.showSelector;
    }
    public void setShowSelector(Boolean value) {
        this.showSelector = value;
    }

    private Boolean showGraph = false;
    public Boolean getShowGraph() {
        return this.showGraph;
    }
    public void setShowGraph(Boolean value) {
        this.showGraph = value;
    }

    private Boolean showComment = false;
    public Boolean getShowComment() {
        return this.showComment;
    }
    public void setShowComment(Boolean value) {
        this.showComment = value;
    }

    private String isRefresh;
    public String getIsRefresh() {
        return 'false';
    }

    private String dateToShow;
    public String id { get; set; }
    public String getObjectName()  {
        return '';
    }
    public Integer getRowCount() {
        return 50;
    }

    private String personId;

    public FieldOfficerBreakDownController() {

        PageReference pageRef = ApexPages.currentPage();

        // Get the url params
        this.dateToShow = pageRef.getParameters().get('date');
         if (this.dateToShow != null && !this.dateToShow.equals('')) {
                this.dateToShow = this.dateToShow.replace('sp', ' ');
        }
 
        this.id = pageRef.getParameters().get('id');
        this.personId = pageRef.getParameters().get('foId');

        fetchSelector(pageRef.getParameters().get('selector'));

        // Get the section to display based on what is passed in
        String typeToLoad = pageRef.getParameters().get('type');
        if (typeToLoad != null && typeToLoad.equals('graph')) {
            setShowGraph(true);
        }
        else if (typeToLoad != null && typeToLoad.equals('comment')) {
            setShowComment(true);
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The type of break down you are trying to view does not exist. Please contact support'));
        }
    }

    private void fetchSelector(String id) {

        if (id == null || id.equals('')) {
            setShowSelector(false);
            return;
        }

        List<Dashboard_Selector__c> selectors = 
            [SELECT
                Show_Dates__c,
                Show_Metric_Date_Selector__c,
                Show_Country__c,
                Show_Region__c,
                Show_District__c,
                Show_Subcounty__c,
                Show_Person__c,
                Show_Data_Validator__c,
                Show_CKW__c,
                Show_Farmer__c,
                Show_Field_Officer__c,
                Show_MTN_Chan__c,
                Date_Period__c,
                Start_Date__c,
                Dashboard_Selector__c.Show_Submit_Button__c
            FROM
                Dashboard_Selector__c
            WHERE
                Is_Active__c = true
                AND Id = :id
            ORDER BY
                CreatedDate DESC];

        if (selectors.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No selector exists for the id passed in. Check that the selector is still active'));
            return;
        }
        this.selector = selectors[0];
    }

    public PageReference refreshData() {
        return null;
    }

    static testMethod void testGraphController() {

        // Create the dashboard selector
        Account account = new Account();
        account.Name = 'Account';
        account.BillingState = 'CA';
        Database.insert(account);

        Dashboard__c dash = new Dashboard__c();
        dash.Account__c = account.Id;
        dash.Title__c = 'Title';
        dash.Description__c = 'Description';
        Database.insert(dash);

        Dashboard_Section__c section = new Dashboard_Section__c();
        section.Dashboard__c = dash.Id;
        section.Title__c = 'Title';
        Database.insert(section);

        Dashboard_Selector__c selector = new Dashboard_Selector__c();
        selector.Show_Person__c = true;
        selector.Show_Metric_Date_Selector__c = true;
        selector.Show_Dates__c = true;
        selector.Show_Subcounty__c = true;
        selector.Show_District__c = true;
        selector.Dashboard_Section__c = section.id;
        selector.Start_Date__c = Date.today();
        Database.insert(selector);


        PageReference pageRef = Page.FieldOfficerBreakDown;
        pageRef.getParameters().put('type', 'graph');
        pageRef.getParameters().put('selector', selector.Id);
        Test.setCurrentPageReference(pageRef);
        Test.startTest();

        FieldOfficerBreakDownController controller = new FieldOfficerBreakDownController();
        controller.getAccountName();
        controller.setShowGraph(controller.getShowGraph());
        controller.setShowSelector(controller.getShowSelector());
        controller.setShowComment(controller.getShowComment());
        controller.getRowCount();
        controller.getObjectName();
        controller.getIsRefresh();
    }
}