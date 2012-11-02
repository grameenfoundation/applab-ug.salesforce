global with sharing class UpdateMetricComponentController {

    public static M_E_Metric_Data__c metricData { get; set; }
    public static String message { get; set; }

    public UpdateMetricComponentController() { }

    @RemoteAction
    global static M_E_Metric_Data__c getMetricData(String id) {
        return loadMetricData(id);
    }

    @RemoteAction
    global static void saveMetricData(String id, String comment, String manualValue, String target) {

        // Note that the validation on the data is done on the client side
        M_E_Metric_Data__c metric = loadMetricData(id);
        if (!comment.equals('')) {
            metric.Comment__c = comment;
        }
        if (!manualValue.equals('')) {
            metric.Manual_Value__c = Double.valueOf(manualValue);
        }
        if (!target.equals('')) {
            metric.Projected_Value__c = Double.valueOf(target);
        }
        Database.update(metric);
    }

    private static M_E_Metric_Data__c loadMetricData(String id) {

        return [SELECT
                Id,
                Name,
                Comment__c,
                Manual_Value__c,
                Actual_Value__c,
                Projected_Value__c,
                M_E_Metric__r.Label__c
            FROM
                M_E_Metric_Data__c
            WHERE
                id = :id];
    }

    static testMethod void testAll() {

        Account testOrg = Utils.createTestOrganisation('We');
        Database.insert(testOrg);

        M_E_Metric__c metric = Utils.createTestMetric(testOrg, 'sum', 'scale', false, 'were');
        Database.insert(metric);

        District__c district = Utils.createTestDistrict('at');
        Database.insert(district);

        M_E_Metric_Data__c metricDataTest = Utils.createTestMetricData(district, metric, 1.0, 1.0, Date.today());
        Database.insert(metricDataTest);

        saveMetricData((String)metricDataTest.Id, 'a', '5.0', '50.0');
        M_E_Metric_Data__c metricData2 = getMetricData(metricDataTest.Id);
        System.assertEquals(metricData2.Manual_Value__c, 5.0);
        System.assert(metricData2.Comment__c.equals('a'));
        System.assertEquals(metricData2.Projected_Value__c, 50.0);

    }
}