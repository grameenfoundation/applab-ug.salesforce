public with sharing class Test_MultiComponenetController extends DynamicDashboardBaseController {


    public Test_MultiComponenetController() {
        setDashboardName('Demo Dashboard');
        setSections(loadSections());
    }
    private List<Graph_Parameter__c> graphs;
    public List<Graph_Parameter__c> getGraphs() {
        this.graphs = [SELECT Name FROM Graph_Parameter__c WHERE Dashboard_Section__r.Name = 'DS0000000000'];
        return this.graphs;
    }
    public void setGraphs(List<Graph_Parameter__c> graphs) {
        this.graphs = graphs;
    }

    public Dashboard_Section__c getSection1() {
        return [SELECT Name, Id, Title__c, Has_Graphs__c, Has_Maps__c, Has_Selector__c, Has_Metrics__c, Is_Active__c,
                Dashboard__r.Account__r.Name FROM Dashboard_Section__c WHERE Name = 'DS0000000034'];
    }
    public Dashboard_Section__c getSection2() {
        return [SELECT Name, Id, Title__c, Has_Graphs__c, Has_Maps__c, Has_Selector__c, Has_Metrics__c, Is_Active__c,
                Dashboard__r.Account__r.Name FROM Dashboard_Section__c WHERE Name = 'DS0000000035'];
    }
    public Dashboard_Section__c getSection3() {
        return [SELECT Name, Id, Title__c, Has_Graphs__c, Has_Maps__c, Has_Selector__c, Has_Metrics__c, Is_Active__c,
                Dashboard__r.Account__r.Name FROM Dashboard_Section__c WHERE Name = 'DS0000000033'];
    }
}