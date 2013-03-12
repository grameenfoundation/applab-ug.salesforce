public with sharing class NaadsDashboardController extends DynamicDashboardBaseController {

    /**public Dashboard_Section__c getSection0() {
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
    }**/
        public NaadsDashboardController () {
        setDashboardName('NAADS Dashboard');
        setSections(loadSections());
    }
}