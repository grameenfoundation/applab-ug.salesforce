/**
 *  Controller to load the settings for the Steven dashboard
 */

public with sharing class StevenDashboardController extends DynamicDashboardBaseController {

    public StevenDashboardController() {
        
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
                Name = 'DS0000000057'
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
                Name = 'DS0000000058'
                AND Is_Active__c = true];
    }
    

    static testMethod void testAll() {

        StevenDashboardController controller = new StevenDashboardController();
        Dashboard_Section__c section = controller.getSection0();
        section = controller.getSection1();
        
    }
}