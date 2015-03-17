/**
 *  According to management,in a given month an active CKW is one who
 *  does at least 5 searches and submits at least 1
 *  survey that month.
 */
public class ActivePerformingCkwCalculator {

    public static void calculateMonthlyRepeatUsage() {
    	List<CKW__c> currentPerformances = [Select Id, 
									Current_Performance_Review__c,
									Current_Performance_Review__r.Number_Of_Searches_Running_Total__c,
									Current_Performance_Review__r.Total_Surveys_Submitted__c 
									from CKW__c where Status__c = 'Active' 
									and 
									Current_Performance_Review__r.Start_Date__c = THIS_MONTH
									and 
									Person__r.Country__r.Name = 'Uganda'
									and 
									Person__c NOT IN 
										(Select 
											Person__c 
										from 
											Person_Group_Association__c 
										where 
											Group__r.Name = 'Applab Staff')];
		Integer count = 0;
		for (CKW__c ckw : currentPerformances) {
			if (ckw.Current_Performance_Review__r.Number_Of_Searches_Running_Total__c >= 5
				 && ckw.Current_Performance_Review__r.Total_Surveys_Submitted__c >= 1) {
				count ++;
			}
		}
    	M_E_Metric_Data__c metricData = new M_E_Metric_Data__c();
    	M_E_Metric_Data__c[] metricDatas = [Select Id, 
												Date__c,
    											Actual_Value__c, 
    											Denumerator__c, 
    											Numerator__c
											from 
												M_E_Metric_Data__c
											where 
												M_E_Metric__r.Name = 'Active CKWs by Performance'
											and 
												Date__c = THIS_MONTH];
		if (metricDatas.size() < 1) {
			metricData.Date__c = Date.today().toStartOfMonth();
		}
		else {
			metricData = metricDatas[0];
		}
		metricData.Numerator__c = count;
		metricData.Denumerator__c = currentPerformances.size();
		metricData.Actual_Value__c = (count * 100)/metricData.Denumerator__c;
		upsert metricData;
    }
}