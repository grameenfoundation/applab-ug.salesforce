@isTest
public class TestAgrowaysFarmerGroupsReached {
    static TestMethod void testCalculateFarmerGroupsReached() {
            M_E_Metric__c metric = new M_E_Metric__c(Name='Agroways Total Farmer Groups Reached');
            insert metric;
            Date startDate = MetricHelpers.getQuarterFirstDay(date.today());
            Test.startTest();
            AgrowaysFarmerGroupsReachedCalculator.calculateFarmerGroupsReached();
            Test.stopTest();
            M_E_Metric_Data__c[] metricDatas = [Select Numerator__c,
                                                        Denumerator__c,
                                                        Actual_Value__c
                                                from 
                                                    M_E_Metric_Data__c 
                                                where 
                                                    Date__c =:startDate
                                                AND 
                                                    M_E_Metric__r.Name ='Agroways Total Farmer Groups Reached' 
                                                order by date__c desc];
            System.assertEquals(metricDatas.size(), 1);
        }
}