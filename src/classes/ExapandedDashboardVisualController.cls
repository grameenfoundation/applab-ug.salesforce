public with sharing class ExapandedDashboardVisualController extends ParentComponentBase {

    public String id { get; set; }
    public String currentDate { get; set; }

    public Dashboard_Selector__c selector { get; set; }
    private Boolean showSelector = true;
    private String sectionId;
    public Boolean getShowSelector() {
        return this.showSelector;
    }
    public void setShowSelector(Boolean value) {
        this.showSelector = value;
    }

    public override void rebuildParameters() {
        this.getParentMap().get('DashboardSelectorKey').rebuildParameters();
        this.setParameters(this.getParentMap().get('DashboardSelectorKey').getParameters());
    }

    public sObject metric { get; set; }
    public Boolean showMetric { get; set; }

    public sObject mapParameter { get; set; }
    public Boolean showMap { get; set; }

    public sObject graphParameter { get; set; }
    public Boolean showGraph { get; set; }

    private String accountName;
    public String getAccountName() {
        return this.accountName;
    }
    private void setAccountName(String value) {
        this.accountName = value;
    }

    public ExapandedDashboardVisualController() {
        PageReference pageRef = ApexPages.currentPage();
        this.id = pageRef.getParameters().get('id');
        String typeOfPage = pageRef.getParameters().get('type');

        if (this.id == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An id has not been provided so cannot display a visual'));
            System.debug(LoggingLevel.INFO, 'No id provided so cannot continue');
        }
        else {

            if (typeOfPage.equals('graph')) {
                loadGraph();
            }
            else if (typeOfPage.equals('map')) {
                loadMap();
            }
            else {
                System.debug(LoggingLevel.INFO, 'Unrecognised type: ' + typeOfPage);
            }
        }
        if (getShowSelector()) {
            loadSelector();
        }
    }

    private void loadMap() {

        Map_Parameter__c loadedMapParameter = [SELECT
                Id,
                Name,
                Title__c,
                Latitude__c,
                Longitude__c,
                Type_Of_sObject__c,
                Zoom__c,
                Splitter__c,
                Dashboard_Section__r.Dashboard__r.Account__r.Name,
                Dashboard_Section__r.Has_Selector__c,
                Dashboard_Section__c
            FROM
                Map_Parameter__c
            WHERE
                id = :this.id];
        this.accountName = loadedMapParameter.Dashboard_Section__r.Dashboard__r.Account__r.Name;
        this.mapParameter = loadedMapParameter;
        setShowSelector(loadedMapParameter.Dashboard_Section__r.Has_Selector__c);
        this.sectionId = loadedMapParameter.Dashboard_Section__c;
        this.showMap = true;
    }

    private void loadGraph() {

        Graph_Parameter__c loadedGraphParameter = [SELECT
                Id,
                Name,
                Title__c,
                Title_Color__c,
                Legend_Color__c,
                Type_Of_Graph__c,
                xAxis_Series__c,
                xAxis_Title__c,
                xAxis_Color__c,
                yAxis_Color__c,
                yAxis_Title__c,
                Date_Period__c,
                Default_Show__c,
                Show_Data_Inline__c,
                Dashboard_Section__r.Has_Selector__c,
                Dashboard_Section__c,
                Dashboard_Section__r.Dashboard__r.Account__r.Name
            FROM 
                Graph_Parameter__c
            WHERE
                id = :this.id];
        this.accountName = loadedGraphParameter.Dashboard_Section__r.Dashboard__r.Account__r.Name;
        this.graphParameter = loadedGraphParameter;
        setShowSelector(loadedGraphParameter.Dashboard_Section__r.Has_Selector__c);
        this.sectionId = loadedGraphParameter.Dashboard_Section__c;
        this.showGraph = true;
    }

    private void loadSelector() {

        Dashboard_Selector__c[] selectors = [
            SELECT
                Name,
                Id,
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
                Show_Submit_Button__c,
                Start_Date__c
            FROM
                Dashboard_Selector__c
            WHERE
                Dashboard_Section__c = :this.sectionId];

        if (selectors.size() == 0) {
            setShowSelector(false);
        }
        else {
            this.selector = selectors[0];
        }
    }

    static testMethod void testGetMap() {

        Account testOrg = Utils.createTestOrganisation('Rock');
        Database.insert(testOrg);   

        Dashboard__c dashboard = new Dashboard__c();
        dashboard.Description__c = 'Lobster';
        dashboard.Title__c = 'Rock';
        dashboard.Account__c = testOrg.Id;
        Database.insert(dashboard);

        Dashboard_Section__c section = new Dashboard_Section__c();
        section.Dashboard__c = dashboard.Id;
        section.Title__c = 'Lobster';
        section.Display_Order__c = 0;
        Database.insert(section);

        Map_Parameter__c testMap = new Map_Parameter__c();
        testMap.Dashboard_Section__c = section.Id;
        testMap.Keyword__c = '';
        testMap.Latitude__c = '1';
        testMap.Longitude__c = '2';
        testMap.Splitter__c = 'Gender';
        testMap.Title__c = 'We';
        testMap.Type_Of_sObject__c = 'CKW';
        testMap.Zoom__c = 8;
        Database.insert(testMap);


        PageReference pageRef = Page.ExpandedDashboardVisual;
        pageRef.getParameters().put('id', testMap.id);
        pageRef.getParameters().put('type', 'map');
        Test.setCurrentPageReference(pageRef);
        Test.startTest();
        ExapandedDashboardVisualController controller = new ExapandedDashboardVisualController();
    }

    static testMethod void testFailNoId() {

        PageReference pageRef = Page.ExpandedDashboardVisual;
        Test.setCurrentPageReference(pageRef);
        Test.startTest();
        ExapandedDashboardVisualController controller = new ExapandedDashboardVisualController();
    }

    static testMethod void testMetric() {

        PageReference pageRef = Page.ExpandedDashboardVisual;
        pageRef.getParameters().put('id', '');
        pageRef.getParameters().put('type', 'metric');
        Test.setCurrentPageReference(pageRef);
        Test.startTest();
        ExapandedDashboardVisualController controller = new ExapandedDashboardVisualController();
    }

    static testMethod void testBadType() {

        PageReference pageRef = Page.ExpandedDashboardVisual;
        pageRef.getParameters().put('id', '');
        pageRef.getParameters().put('type', 'NOPE');
        Test.setCurrentPageReference(pageRef);
        Test.startTest();
        ExapandedDashboardVisualController controller = new ExapandedDashboardVisualController();
    }

    static testMethod void testGraph() {

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

        String title = 'New Graph';
        Graph_Parameter__c graph = new Graph_Parameter__c();
        graph.Dashboard_Section__c = section.Id;
        graph.Title__c = title;
        graph.Type_Of_Graph__c = 'Trend';
        graph.Is_Active__c = true;
        graph.Date_Period__c = 'Day';
        graph.xAxis_Series__c = 'Date';
        graph.xAxis_Title__c = 'Hi';
        Database.insert(graph);

        PageReference pageRef = Page.ExpandedDashboardVisual;
        pageRef.getParameters().put('id', graph.id);
        pageRef.getParameters().put('type', 'graph');
        Test.setCurrentPageReference(pageRef);
        Test.startTest();
        ExapandedDashboardVisualController controller = new ExapandedDashboardVisualController();
    }
}