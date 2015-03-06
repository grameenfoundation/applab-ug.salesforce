trigger CBL_UpdateDataCbl2 on CBL_CoffeeBaseline__c (after insert) {
	List<CBL_CoffeeBaseline__c> cbl_Ids = new List<CBL_CoffeeBaseline__c>();
    List<CBL2_Farmer__c> farmers2ToInsert = new List<CBL2_Farmer__c>();
    Set<Id> LAC_FD_Ids = new Set<Id>();
    boolean farmerExists = false;
    
    //get a list with cbls rows inserted and its LAC Farmer Details ids
  	for (CBL_CoffeeBaseline__c newRows : Trigger.new) {
        cbl_Ids.add(newRows);
        LAC_FD_Ids.add(newRows.Farmer__c);
  	}
    
    //get the farmers that already exists in model CBL2
    for(List<CBL2_Farmer__c> ExistingFarmers : [SELECT Id, LAC_Farmer_Details__c from CBL2_Farmer__c WHERE LAC_Farmer_Details__c IN : LAC_FD_Ids]){
        for(CBL_CoffeeBaseline__c cbl : cbl_Ids){
            farmerExists = false;
            for(CBL2_Farmer__c farmer: ExistingFarmers){
                if(cbl.Farmer__c == farmer.LAC_Farmer_Details__c){
                    farmerExists = true;                
                }
            }
            //if the farmer doesn't exists then create a new farmer2
            if(!farmerExists){
                CBL2_Farmer__c newFarmer = new CBL2_Farmer__c();
                newFarmer.LAC_Farmer_Details__c = cbl.Farmer__c;
                farmers2ToInsert.add(newFarmer);
            }
        }
    }
    try{
        if(farmers2ToInsert.size() > 0)
            insert farmers2ToInsert;    
    }
    catch (system.Exception e){
        system.debug (e);
    }    
}