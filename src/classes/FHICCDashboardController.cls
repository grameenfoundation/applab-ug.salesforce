/**
 * Controller for the DataValidator dashboard
 */

public with sharing class FHICCDashboardController extends DynamicDashboardBaseController {

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
                Name IN ('DS0000000054','DS0000000812')
                AND Is_Active__c = true];
    }
}