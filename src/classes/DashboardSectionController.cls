public with sharing class DashboardSectionController extends ParentComponentBase {

    private Dashboard_Section__c dashboardSection;
    public Dashboard_Section__c getDashboardSection() {
        return dashboardSection;
    }
    public void setDashboardSection(Dashboard_Section__c value) {
        this.dashboardSection = value;
    }

    public String getAccountName() {
        return dashboardSection.Dashboard__r.Account__r.Name;
    }

    public override void rebuildParameters() {
        if (this.getParentMap() != null && this.getParentMap().get('DashboardSelector' + dashboardSection.Id) != null) {
            this.getParentMap().get('DashboardSelector' + dashboardSection.Id).rebuildParameters();
            this.setParameters(this.getParentMap().get('DashboardSelector' + dashboardSection.Id).getParameters());
        }
    }

    private List<Graph_Parameter__c> graphs;
    public List<Graph_Parameter__c> getGraphs() {
        this.graphs= [SELECT
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
                Dashboard_Section__r.Dashboard__r.Account__r.Name
            FROM 
                Graph_Parameter__c
            WHERE
                Dashboard_Section__r.Name = :dashboardSection.Name];
        return this.graphs;
    }
    public void setGraphs(List<Graph_Parameter__c> graphs) {
        this.graphs = graphs;
    }

    private List<Map_Parameter__c> maps;
    public List<Map_Parameter__c> getMaps() {
        this.maps = [SELECT
                Id,
                Name,
                Title__c,
                Latitude__c,
                Longitude__c,
                Type_Of_sObject__c,
                Zoom__c,
                Splitter__c
            FROM
                Map_Parameter__c
            WHERE 
                Dashboard_Section__r.Name = :dashboardSection.Name];
        return this.maps;
    }
    public void setMaps(List<Map_Parameter__c> maps) {
        this.maps = maps;
    }

    private List<Metric_Section__c> metrics;
    public List<Metric_Section__c> getMetrics() {
        this.metrics = [SELECT
                Id,
                Name,
                Title__c,
                Dashboard_Section__r.Dashboard__r.Account__r.Name,
                Description__c,
                RollOver_Time__c,
                Start_Date__c,
                Show_RollOver_Selector__c,
                Show_Targets__c,
                Show_Previous_Quarter__c,
                Show_Comments__c,
                Show_Break_Down__c,
                Show_Spark_Line__c,
                Show_Further_Link__c,
                Default_Show__c,
                Allow_Update__c
            FROM
                Metric_Section__c
            WHERE
                Dashboard_Section__r.Name = :dashboardSection.Name];
        return this.metrics;
    }
    public void setMetrics(List<Metric_Section__c> metrics) {
        this.metrics = metrics;
    }

    // Should only every be one selector per section. Therefore will use the most recent active one for the section
    private Dashboard_Selector__c selector;
    public Dashboard_Selector__c getSelector() {

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
                Show_Submit_Button__c,
                Show_Brac_PA__c,
                Show_Brac_Area__c
            FROM
                Dashboard_Selector__c
            WHERE
                Is_Active__c = true
                AND Dashboard_Section__r.Name = :dashboardSection.Name
            ORDER BY
                CreatedDate DESC];

        if (selectors.size() == 0) {
            return null;
        }
        return selectors[0];
    }
    public void setSelector(Dashboard_Selector__c value) {
        this.selector = value;
    }

    public override String getHandle() {
        return 'SECTION';
    }

    static testMethod void testAll() {

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

        DashboardSectionController controller = new DashboardSectionController();
        controller.setDashboardSection(section);
        controller.getAccountName();
        controller.getHandle();
        controller.setGraphs(controller.getGraphs());
        controller.setMaps(controller.getMaps());
        controller.setMetrics(controller.getMetrics());
    }
}