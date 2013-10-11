global with sharing class UpdateMetricComponentController {

    public static M_E_Metric_Data__c metricData { get; set; }
    public static String message { get; set; }

    public UpdateMetricComponentController() { }

    @RemoteAction
    global static M_E_Metric_Data__c getMetricData(String id) {
        return loadMetricData(id);
    }

    @RemoteAction
    global static void saveMetricData(String id, String comment, String manualValue, String target, String updateType) {

        // Note that the validation on the data is done on the client side
        M_E_Metric_Data__c mData = loadMetricData(id);
        if (!comment.equals('')) {
            mData.Comment__c = comment;
        }
        if (!manualValue.equals('')) {
            mData.Manual_Value__c = Double.valueOf(manualValue);
        }
        if (!target.equals('')) {
            mData.Projected_Value__c = Double.valueOf(target);

            // Propagate any targets up the ladder to the the metrics above
            if (mData.M_E_Metric__r.Propagate_Targets__c && !updateType.equals('Country')) {
                List<Date> dates = MetricHelpers.getStartEndDates(MetricHelpers.createDispRollOverString(mData.Date__c, mData.M_E_Metric__r.Metric_Section__r.RollOver_Time__c), mData.M_E_Metric__r.Metric_Section__r.RollOver_Time__c);
                propagateTargets(mData, updateType, dates[0], dates[1]);
                return;
            }
        }
        Database.update(mData);
    }

    private static void propagateTargets(M_E_Metric_Data__c mData, String updateType, Date startDate, Date endDate) {

        Database.update(mData);
        if (updateType.equals('Person')) {
            mData = updateDistrictMetric(mData, startDate, endDate);
        }
        updateGlobalMetric(mData, startDate, endDate);
    }

    private static M_E_Metric_Data__c updateGlobalMetric(M_E_Metric_Data__c mData, Date startDate, Date endDate) {

        // Get the sum of all the people in the given district
        AggregateResult metricSum = [
            SELECT
                SUM(Projected_Value__c) totalTarget
            FROM
                M_E_Metric_Data__c
            WHERE
                M_E_Metric__r.Name = :mData.M_E_Metric__r.Name
                AND District__c != null
                AND Person__c = null
                AND Date__c >= :startDate
                AND Date__c <= :endDate];


        // Get the metric data that needs updating out of the db
        M_E_Metric_Data__c dataToUpdate = [
            SELECT
                Id,
                Name,
                Projected_Value__c
            FROM
                M_E_Metric_Data__c
            WHERE
                M_E_Metric__r.Name = :mData.M_E_Metric__r.Name
                AND District__c = null
                AND Person__c = null
                AND Date__c >= :startDate
                AND Date__c <= :endDate];

        // Update the data to the new value
        dataToUpdate.Projected_Value__c = (Decimal)metricSum.get('totalTarget');
        Database.update(dataToUpdate);
        return dataToUpdate;
    }

    private static M_E_Metric_Data__c updateDistrictMetric(M_E_Metric_Data__c mData, Date startDate, Date endDate) {

        // Get the sum of all the people in the given district
        AggregateResult metricSum = [
            SELECT
                SUM(Projected_Value__c) totalTarget
            FROM
                M_E_Metric_Data__c
            WHERE
                M_E_Metric__r.Name = :mData.M_E_Metric__r.Name
                AND Person__r.District__c = :mData.Person__r.District__c
                AND Date__c >= :startDate
                AND Date__c <= :endDate];


        // Get the metric data that needs updating out of the db
        M_E_Metric_Data__c dataToUpdate = [
            SELECT
                Id,
                Name,
                M_E_Metric__r.Name,
                Projected_Value__c
            FROM
                M_E_Metric_Data__c
            WHERE
                M_E_Metric__r.Name = :mData.M_E_Metric__r.Name
                AND District__c = :mData.Person__r.District__c
                AND Person__c = null
                AND Date__c >= :startDate
                AND Date__c <= :endDate];

        // Update the data to the new value
        dataToUpdate.Projected_Value__c = (Decimal)metricSum.get('totalTarget');
        Database.update(dataToUpdate);
        return dataToUpdate;
    }

    private static M_E_Metric_Data__c loadMetricData(String id) {

        return [SELECT
                Id,
                Name,
                Comment__c,
                Manual_Value__c,
                Actual_Value__c,
                Projected_Value__c,
                Date__c,
                Person__c,
                Person__r.District__c,
                District__c,
                M_E_Metric__r.Label__c,
                M_E_Metric__r.Name,
                M_E_Metric__r.Propagate_Targets__c,
                M_E_Metric__r.Metric_Section__r.RollOver_Time__c
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

        saveMetricData((String)metricDataTest.Id, 'a', '5.0', '50.0', 'District');
        M_E_Metric_Data__c metricData2 = getMetricData(metricDataTest.Id);
        System.assertEquals(metricData2.Manual_Value__c, 5.0);
        System.assert(metricData2.Comment__c.equals('a'));
        System.assertEquals(metricData2.Projected_Value__c, 50.0);

    }
}