trigger CBL_Commercialization_UpdateDataCbl2 on CBL_Commercialization__c (after insert) {
    Set<Id> commer_Ids = new Set<Id>();
    Set<Id> cbl_Ids = new Set<Id>();
    
    //get a list with Baseline id related to commercialization rows inserted
    for (CBL_Commercialization__c newRow : Trigger.new) {
        commer_Ids.add(newRow.Id);
        cbl_Ids.add(newRow.Baseline__c);
    }

    //get a list with commercialization rows completed (field Baseline__r.Farmer__c)
    for(List<CBL_Commercialization__c> commers : [SELECT Id, Baseline__c, Baseline__r.Farmer__c, bargainingPower__c, buysCoffee__c, coffeePlantedAreaNonRegisteredFarmsUnits__c, coffeePlantedAreaNonRegisteredFarms__c, enoughInformation__c, farmsNotRegisteredInCoop__c, lastHarvestPercCoffeeSoldToCoop__c, producedCoffeeDestiny__c, reasonNotAllCoffeeSoldToCoop__c, reasonsNonRegisteredCoopFarms__c, statusSoldCoffee__c, Submission__c
                                            FROM CBL_Commercialization__c WHERE Id IN :commer_Ids]){
        //get the farmers2 to update only the commercialization data
        for(List<CBL2_Farmer__c> farmers : [SELECT commer_bargainingPower__c, commer_buysCoffee__c, commer_coffeePlantedAreaNonRegFarmsUnit__c, commer_coffeePlantedAreaNonRegisteredFar__c, commer_enoughInformation__c, commer_farmsNotRegisteredInCoop__c, commer_lastHarvestPercCoffeeSoldToCoop__c, commer_producedCoffeeDestiny__c, commer_reasonNotAllCoffeeSoldToCoop__c, commer_reasonsNonRegisteredCoopFarms__c, commer_statusSoldCoffee__c, LAC_Farmer_Details__c, Submission_Comercializacion__c  
                                    FROM CBL2_Farmer__c WHERE LAC_Farmer_Details__c IN (SELECT Farmer__c FROM CBL_CoffeeBaseline__c WHERE Id IN: cbl_Ids)]){
            for(CBL_Commercialization__c commer: commers ){
                for(CBL2_Farmer__c farmer: farmers){
                    //update if the LAC_Farmer_Details are the same
                    if(farmer.LAC_Farmer_Details__c == commer.Baseline__r.Farmer__c){
                        farmer.commer_bargainingPower__c = commer.bargainingPower__c;
                        farmer.commer_buysCoffee__c= commer.buysCoffee__c;
                        farmer.commer_coffeePlantedAreaNonRegFarmsUnit__c = commer.coffeePlantedAreaNonRegisteredFarmsUnits__c;
                        farmer.commer_coffeePlantedAreaNonRegisteredFar__c = commer.coffeePlantedAreaNonRegisteredFarms__c;
                        farmer.commer_enoughInformation__c = commer.enoughInformation__c;
                        farmer.commer_farmsNotRegisteredInCoop__c = commer.farmsNotRegisteredInCoop__c;
                        farmer.commer_lastHarvestPercCoffeeSoldToCoop__c = commer.lastHarvestPercCoffeeSoldToCoop__c;
                        farmer.commer_producedCoffeeDestiny__c = commer.producedCoffeeDestiny__c;
                        farmer.commer_reasonNotAllCoffeeSoldToCoop__c = commer.reasonNotAllCoffeeSoldToCoop__c;
                        farmer.commer_reasonsNonRegisteredCoopFarms__c = commer.reasonsNonRegisteredCoopFarms__c;
                        farmer.commer_statusSoldCoffee__c = commer.statusSoldCoffee__c; 
                        farmer.Submission_Comercializacion__c= commer.Submission__c; 
                    }                                      
                }
            }
            //update all the farmers with new commercialization data
            try{
                update farmers;
            }
            catch(system.Exception e){
                system.debug (e);
            }
        }
    }
}