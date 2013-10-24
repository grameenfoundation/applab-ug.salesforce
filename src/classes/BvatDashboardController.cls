/**
 *  Controller to load the settings for the BVAT Dashboard
 */

public with sharing class BvatDashboardController extends ParentComponentBase {

    private String dashboardName;
    private List<Dashboard_Section__c> sections;
    private Dashboard_Section__c section;
    
    public BvatDashboardController() {
        setDashboardName('BVAT Dashboard');
        setSections(loadSections());
    }

    public override void rebuildParameters() {

        if (this.getParentMap() != null && this.getParentMap().get('DashboardSelectora1470000001U00Q') != null) {
            this.getParentMap().get('DashboardSelectora1470000001U00Q').rebuildParameters();
            this.setParameters(this.getParentMap().get('DashboardSelectora1470000001U00Q').getParameters());
        }
    }
 
    public String getDashboardName() {
        return this.dashboardName;
    }
    public void setDashboardName(String value) {
        this.dashboardName = value;
    }

    public void setSection(Dashboard_Section__c section) {
        this.section = section;
    }
    
    public Dashboard_Section__c getSection() {
        return this.section;
    }
    public List<Dashboard_Section__c> getSections() {
        return this.sections;
    }
    public void setSections(List<Dashboard_Section__c> values) {
        this.sections = values;
    }
    public List<Dashboard_Section__c> loadSections() {

        List<Dashboard_Section__c> sectionsToLoad = [SELECT
                Name,
                Id,
                Title__c,
                Has_Graphs__c,
                Has_Metrics__c,
                Has_Maps__c,
                Has_Selector__c,
                Dashboard__r.Account__r.Name
            FROM
                Dashboard_Section__c
            WHERE
                Dashboard__r.Name = :dashboardName
                AND Is_Active__c = true
            ORDER BY
                Display_Order__c];
        return sectionsToLoad;
    }
    
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
                Show_Opportunity_Farmer__c,
                Show_Data_Validator__c,
                Show_CKW__c,
                Show_Farmer__c,
                Show_Field_Officer__c,
                Show_MTN_Chan__c,
                Date_Period__c,
                Start_Date__c,
                Show_Submit_Button__c,
                Show_Brac_PA__c,
                Show_Brac_Area__c,
                Show_Kenyan_County__c,
                Show_BVAT_CIW__c
            FROM
                Dashboard_Selector__c
            WHERE
                Is_Active__c = true
                AND Dashboard_Section__r.Name = 'DS0000003855'
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
    
     private List<Map_Parameter__c> ciwMaps;
    public List<Map_Parameter__c> getCiwMaps() {
        this.ciwMaps = [SELECT
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
                Name = 'MP0000001570'];
        return this.ciwMaps;
    }
    public void setCiwMaps(List<Map_Parameter__c> maps) {
        this.ciwMaps = maps;
    }
    
    private List<Metric_Section__c> ciwMetrics;
    public List<Metric_Section__c> getCiwMetrics() {
        this.ciwMetrics = [SELECT
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
                Allow_Update__c,
                View_Mode__c
            FROM
                Metric_Section__c
            WHERE
                Name = 'MS0000000577'];
        return this.ciwMetrics;
    }
    public void setCiwMetrics(List<Metric_Section__c> metrics) {
        this.ciwMetrics = metrics;
    }

    private List<Metric_Section__c> distanceMetrics;
    public List<Metric_Section__c> getDistanceMetrics() {
        this.distanceMetrics = [SELECT
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
                Allow_Update__c,
                View_Mode__c
            FROM
                Metric_Section__c
            WHERE
                Name = 'MS0000000576'];
        return this.distanceMetrics;
    }
    public void setDistanceMetrics(List<Metric_Section__c> metrics) {
        this.distanceMetrics = metrics;
    }
    
    private List<Metric_Section__c> registrationMetrics;
    public List<Metric_Section__c> getRegistrationMetrics() {
        this.registrationMetrics = [SELECT
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
                Allow_Update__c,
                View_Mode__c
            FROM
                Metric_Section__c
            WHERE
                Name = 'MS0000000575'];
        return this.registrationMetrics;
    }
    public void setRegistrationMetrics(List<Metric_Section__c> metrics) {
        this.registrationMetrics = metrics;
    }    
    
    private List<Graph_Parameter__c> regGraphs;
    public List<Graph_Parameter__c> getRegGraphs() {
        this.regGraphs= [SELECT
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
                Name = 'GP0000001739'];
        return this.regGraphs;
    }
    public void setRegGraphs(List<Graph_Parameter__c> graphs) {
        this.regGraphs = graphs;
    }
    
    private Map_Parameter__c farmerMap;
    public Map_Parameter__c getFarmerMap() {
        this.farmerMap = [SELECT
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
                Name = 'MP0000001571' LIMIT 1];
        return this.farmerMap;
    }
    public void setFarmerMap(Map_Parameter__c farmerMap) {
        this.farmerMap = farmerMap;
    }
    
    
    private Metric_Section__c contentMetric;
    public Metric_Section__c getContentMetric() {
        this.contentMetric = [SELECT
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
                Allow_Update__c,
                View_Mode__c
            FROM
                Metric_Section__c
            WHERE
                Name = 'MS0000000578' LIMIT 1];
        return this.contentMetric;
    }
    public void setContentMetric(Metric_Section__c metric) {
        this.contentMetric = metric;
    }   
    
    private Graph_Parameter__c categoriesGraph;
    public Graph_Parameter__c getCategoriesGraph() {
        this.categoriesGraph= [SELECT
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
                Name = 'GP0000001740'];
        return this.categoriesGraph;
    }
    public void setCategoriesGraph(Graph_Parameter__c graph) {
        this.categoriesGraph = graph;
    }     
    
    private Graph_Parameter__c environmentGraph;
    public Graph_Parameter__c getEnvironmentGraph() {
        this.environmentGraph= [SELECT
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
                Name = 'GP0000001741'];
        return this.environmentGraph;
    }
    public void setEnvironmentGraph(Graph_Parameter__c graph) {
        this.environmentGraph = graph;
    }
     private Graph_Parameter__c managementGraph;
    public Graph_Parameter__c getManagementGraph() {
        this.managementGraph= [SELECT
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
                Name = 'GP0000001742'];
        return this.managementGraph;
    }
    public void setManagementGraph(Graph_Parameter__c graph) {
        this.managementGraph = graph;
    }   
    
    private Graph_Parameter__c animalGraph;
    public Graph_Parameter__c getAnimalGraph() {
        this.animalGraph= [SELECT
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
                Name = 'GP0000001743'];
        return this.animalGraph;
    }
    public void setAnimalGraph(Graph_Parameter__c graph) {
        this.animalGraph = graph;
    }   
    
    private Graph_Parameter__c humanGraph;
    public Graph_Parameter__c getHumanGraph() {
        this.humanGraph= [SELECT
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
                Name = 'GP0000001744'];
        return this.humanGraph;
    }
    public void setHumanGraph(Graph_Parameter__c graph) {
        this.humanGraph = graph;
    } 
    
    private Graph_Parameter__c otherGraph;
    public Graph_Parameter__c getOtherGraph() {
        this.otherGraph= [SELECT
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
                Name = 'GP0000001745'];
        return this.otherGraph;
    }
    public void setOtherGraph(Graph_Parameter__c graph) {
        this.otherGraph = graph;
    }                       
}