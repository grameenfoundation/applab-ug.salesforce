trigger LACFarmerDetailsPPI_UpdateDataCbl2 on LAC_Farmer_PPI_Score__c (after insert) {
List<LAC_Farmer_PPI_Score__c> cbls_ppi= new List<LAC_Farmer_PPI_Score__c>();
    Set<Id> LAC_FD_Ids = new Set<Id>();
    //get a list with attitude rows inserted and other with only the Ids
    for (LAC_Farmer_PPI_Score__c newRow : Trigger.new) {
        cbls_ppi.add(newRow);
        LAC_FD_Ids.add(newRow.LAC_Farmer_Details__c);
  	}
    //get the farmers2 to update only the ppi data
    LIST<CBL2_Farmer__c> farmers = [SELECT Id, ppi_Score__c, LAC_Farmer_Details__c, Submission_PPI__c  
                                    FROM CBL2_Farmer__c WHERE LAC_Farmer_Details__c IN :LAC_FD_Ids];
    for(LAC_Farmer_PPI_Score__c ppi : cbls_ppi){
        for(CBL2_Farmer__c farmer : farmers){
            //update if the coffeeBaseline are the same	
            if(farmer.LAC_Farmer_Details__c== ppi.LAC_Farmer_Details__c){
            	farmer.ppi_Score__c = ppi.Score__c;
                farmer.Submission_PPI__c= ppi.Submission__c; 
            }            
        }
    }
    //update all the farmers with new ppi data
    update farmers;

}