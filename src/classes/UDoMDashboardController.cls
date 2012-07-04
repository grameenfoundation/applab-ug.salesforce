/**
 *  Controller to load the settings for the UDoM dashboard
 */

public with sharing class UDoMDashboardController extends DynamicDashboardBaseController {

    public UDoMDashboardController() {
        //setDashboardName('UDoM Dashboard');
        //setSections(loadSections());
    }

    // Remove the below and uncomment the above when the bug in SFDC is fixed by them.
    public Dashboard_Section__c getSection0() {
        return [SELECT
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
                Name = 'DS0000000005'
                AND Is_Active__c = true];
    }
    public Dashboard_Section__c getSection1() {
        return [SELECT
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
                Name = 'DS0000000000'
                AND Is_Active__c = true];
    }
    public Dashboard_Section__c getSection2() {
        return [SELECT
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
                Name = 'DS0000000001'
                AND Is_Active__c = true];
    }
    public Dashboard_Section__c getSection3() {
        return [SELECT
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
                Name = 'DS0000000002'
                AND Is_Active__c = true];
    }
    public Dashboard_Section__c getSection4() {
        return [SELECT
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
                Name = 'DS0000000003'
                AND Is_Active__c = true];
    }
    public Dashboard_Section__c getSection5() {
        return [SELECT
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
                Name = 'DS0000000004'
                AND Is_Active__c = true];
    }

    static testMethod void testAll() {

        UDoMDashboardController controller = new UDoMDashboardController();
        Dashboard_Section__c section = controller.getSection0();
        section = controller.getSection1();
        section = controller.getSection2();
        section = controller.getSection3();
        section = controller.getSection4();
        section = controller.getSection5();
    }
}