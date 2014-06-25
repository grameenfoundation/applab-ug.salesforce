public class ActivePerformingCkwCalculator {

	public List<PieWedgeData> getPieData() {

		List<PieWedgeData> data = new List<PieWedgeData>();
		List<CKW__c> currentPerformances = [Select Id, 
														Current_Performance_Review__c,
														Current_Performance_Review__r.Number_Of_Searches_Running_Total__c,
														Current_Performance_Review__r.Total_Surveys_Submitted__c 
														from CKW__c where Status__c = 'Active' 
														and 
														Current_Performance_Review__r.Start_Date__c = THIS_MONTH];
		Integer count = 0;
		for (CKW__c ckw : currentPerformances) {
			if (ckw.Current_Performance_Review__r.Number_Of_Searches_Running_Total__c >= 5
				 && ckw.Current_Performance_Review__r.Total_Surveys_Submitted__c >= 1) {
				count ++;
			}
		}
		data.add(new PieWedgeData('Active CKWs', count));
		data.add(new PieWedgeData('Inactive CKWs', currentPerformances.size() - count));
		return data;
	}
	public class PieWedgeData {  
        public String name { get; set; }  
        public Integer data { get; set; }  
        
        public PieWedgeData(String name, Integer data) {  
            this.name = name;  
            this.data = data;  
        }  
    }
}