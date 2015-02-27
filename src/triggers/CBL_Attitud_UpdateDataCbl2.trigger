trigger CBL_Attitud_UpdateDataCbl2 on CBL_Attitude__c (after insert) {
	List<CBL_Attitude__c> cbls_att = new List<CBL_Attitude__c>();
    Set<Id> cbls_Ids = new Set<Id>();
    Set<Id> LAC_FD_Ids = new Set<Id>();
    
    //get a list with Baseline id related to attitude rows inserted
    for (CBL_Attitude__c newRow : Trigger.new) {
        cbls_Ids.add(newRow.Baseline__c);
    }
    //get a list with attitude rows completed (Baseline__r.Farmer__c)
    cbls_att = [SELECT Id, Baseline__c, Baseline__r.Farmer__c, chooseToBeFarmer__c, destinedToBeFarmer__c, discussMethodsWOthers__c, effortInAgriculturePays__c, farmersLifeWillBeBetter__c, futureCoffeePlans__c, happyToBeFarmer__c, limitationsCauses__c, neighborsProductivityLvl__c, payForAgriAdvise__c, productivityImprovmntLimitations__c, productivityTrend5Years__c, takeAdvise__c, wishChildrenBecomeFarmers__c, worthInvestingMoneyTimeAgr__c, Submission__c 
                FROM CBL_Attitude__c WHERE Baseline__c IN: cbls_Ids];
    //get a list with the LAC Farmer Details ids to search the farmer2 in CBL2 model
    for(CBL_Attitude__c cbl_att : cbls_att){
        LAC_FD_Ids.add(cbl_att.Baseline__r.Farmer__c);
    }
    
    //get the farmers2 to update only the attitude data
    LIST<CBL2_Farmer__c> farmers = [SELECT Id, LAC_Farmer_Details__c, attitude_chooseToBeFarmer__c, attitude_destinedToBeFarmer__c, attitude_discussMethodsWOthers__c, attitude_effortInAgriculturePays__c, attitude_farmersLifeWillBeBetter__c, attitude_futureCoffeePlans__c, attitude_happyToBeFarmer__c, attitude_limitationsCauses__c, attitude_neighborsProductivityLvl__c, attitude_payForAgriAdvise__c, attitude_productivityImprovmntLimitation__c, attitude_productivityTrend5Years__c, attitude_takeAdvise__c, attitude_wishChildrenBecomeFarmers__c, attitude_worthInvestingMoneyTimeAgr__c, Submission_Actitud__c  
                                    FROM CBL2_Farmer__c WHERE LAC_Farmer_Details__c IN :LAC_FD_Ids];
    for(CBL_Attitude__c att : cbls_att){
    	for(CBL2_Farmer__c farmer : farmers){
            //update if the LAC_Farmer_Details are the same
            if(farmer.LAC_Farmer_Details__c == att.Baseline__r.Farmer__c){
            	farmer.attitude_chooseToBeFarmer__c = att.chooseToBeFarmer__c;
                farmer.attitude_destinedToBeFarmer__c = att.destinedToBeFarmer__c;
                farmer.attitude_discussMethodsWOthers__c = att.discussMethodsWOthers__c;
                farmer.attitude_effortInAgriculturePays__c = att.effortInAgriculturePays__c;
                farmer.attitude_farmersLifeWillBeBetter__c = att.farmersLifeWillBeBetter__c;
                farmer.attitude_futureCoffeePlans__c = att.futureCoffeePlans__c;
                farmer.attitude_happyToBeFarmer__c = att.happyToBeFarmer__c;
                farmer.attitude_limitationsCauses__c = att.limitationsCauses__c;
                farmer.attitude_neighborsProductivityLvl__c = att.neighborsProductivityLvl__c;
                farmer.attitude_payForAgriAdvise__c = att.payForAgriAdvise__c;
                farmer.attitude_productivityImprovmntLimitation__c = att.productivityImprovmntLimitations__c;
                farmer.attitude_productivityTrend5Years__c = att.productivityTrend5Years__c;
                farmer.attitude_takeAdvise__c = att.takeAdvise__c;
                farmer.attitude_wishChildrenBecomeFarmers__c = att.wishChildrenBecomeFarmers__c;
                farmer.attitude_worthInvestingMoneyTimeAgr__c = att.worthInvestingMoneyTimeAgr__c;    
                farmer.Submission_Actitud__c = att.Submission__c;
            }            
        }
    }    
    //update all the farmers with new attitude data
    try{
        update farmers;
    }
    catch(system.Exception e){
        system.debug (e);
    }
}