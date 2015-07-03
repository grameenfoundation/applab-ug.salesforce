trigger CBL_Commercialization_UpdateDataCbl2 on CBL_Commercialization__c (after insert) {
    Set<Id> commer_Ids = new Set<Id>();
    Set<Id> cbl_Ids = new Set<Id>();
    
    //get a list with Baseline id related to commercialization rows inserted
    for (CBL_Commercialization__c newRow : Trigger.new) {
        commer_Ids.add(newRow.Id);
        cbl_Ids.add(newRow.Baseline__c);
    }

    //get a list with commercialization rows completed (field Baseline__r.Farmer__c)
    for(List<CBL_Commercialization__c> commers : [SELECT Id, Baseline__c, Baseline__r.Farmer__c, bargainingPower__c, buysCoffee__c, coffeePlantedAreaNonRegisteredFarmsUnits__c, coffeePlantedAreaNonRegisteredFarms__c, enoughInformation__c, farmsNotRegisteredInCoop__c, lastHarvestPercCoffeeSoldToCoop__c, producedCoffeeDestiny__c, reasonNotAllCoffeeSoldToCoop__c, reasonsNonRegisteredCoopFarms__c, statusSoldCoffee__c, Submission__c, buyMainProduct__c, relationWithBuyer__c, tripDurationPointOfSale__c, distancePointOfSale__c, comparePricesOfferedCustomers__c, contractOtherBuyers__c, debtToProduce__c, howLongIntendedMarketed__c, howLongTakesOrderWithAssociation__c, howManyCustomersVisitSellProduction__c, lackMoneyContinueWorking__c, lastHarvestPercMainProductSoldToAsso__c, negotiatesPricesWithCustomers__c, paymentFrequency__c, paymentFrequencyOther__c, paymentMethod__c, paymentMethodOther__c, planInvestInvestedOverpriced__c, producedMainProducDestiny__c, producedMainProducDestinyOther__c, reasonNotAllMainProductSoldToAsso__c, ThisYearSoldMainProductOverPrice__c
                                            FROM CBL_Commercialization__c WHERE Id IN :commer_Ids]){
        //get the farmers2 to update only the commercialization data
        for(List<CBL2_Farmer__c> farmers : [SELECT commer_bargainingPower__c, commer_buysCoffee__c, commer_coffeePlantedAreaNonRegFarmsUnit__c, commer_coffeePlantedAreaNonRegisteredFar__c, commer_enoughInformation__c, commer_farmsNotRegisteredInCoop__c, commer_lastHarvestPercCoffeeSoldToCoop__c, commer_producedCoffeeDestiny__c, commer_reasonNotAllCoffeeSoldToCoop__c, commer_reasonsNonRegisteredCoopFarms__c, commer_statusSoldCoffee__c, LAC_Farmer_Details__c, Submission_Comercializacion__c, buyMainProduct__c, relationWithBuyer__c, tripDurationPointOfSale__c, distancePointOfSale__c, comparePricesOfferedCustomers__c, contractOtherBuyers__c, debtToProduce__c, howLongIntendedMarketed__c, howLongTakesOrderWithAssociation__c, howManyCustomersVisitSellProduction__c, lackMoneyContinueWorking__c, lastHarvestPercMainProductSoldToAsso__c, negotiatesPricesWithCustomers__c, paymentFrequency__c, paymentFrequencyOther__c, paymentMethod__c, paymentMethodOther__c, planInvestInvestedOverpriced__c, producedMainProducDestiny__c, producedMainProducDestinyOther__c, reasonNotAllMainProductSoldToAsso__c, ThisYearSoldMainProductOverPrice__c
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
                        farmer.buyMainProduct__c= commer.buyMainProduct__c;
                        farmer.relationWithBuyer__c= commer.relationWithBuyer__c;
                        farmer.tripDurationPointOfSale__c= commer.tripDurationPointOfSale__c;
                        farmer.distancePointOfSale__c= commer.distancePointOfSale__c;
                        farmer.comparePricesOfferedCustomers__c= commer.comparePricesOfferedCustomers__c;
                        farmer.contractOtherBuyers__c= commer.contractOtherBuyers__c;
                        farmer.debtToProduce__c= commer.debtToProduce__c;
                        farmer.howLongIntendedMarketed__c= commer.howLongIntendedMarketed__c;
                        farmer.howLongTakesOrderWithAssociation__c= commer.howLongTakesOrderWithAssociation__c;
                        farmer.howManyCustomersVisitSellProduction__c= commer.howManyCustomersVisitSellProduction__c;
                        farmer.lackMoneyContinueWorking__c= commer.lackMoneyContinueWorking__c;
                        farmer.lastHarvestPercMainProductSoldToAsso__c= commer.lastHarvestPercMainProductSoldToAsso__c;
                        farmer.negotiatesPricesWithCustomers__c= commer.negotiatesPricesWithCustomers__c;
                        farmer.paymentFrequency__c= commer.paymentFrequency__c;
                        farmer.paymentFrequencyOther__c= commer.paymentFrequencyOther__c;
                        farmer.paymentMethod__c= commer.paymentMethod__c;
                        farmer.paymentMethodOther__c= commer.paymentMethodOther__c;
                        farmer.planInvestInvestedOverpriced__c= commer.planInvestInvestedOverpriced__c;
                        farmer.producedMainProducDestiny__c= commer.producedMainProducDestiny__c;
                        farmer.producedMainProducDestinyOther__c= commer.producedMainProducDestinyOther__c;
                        farmer.reasonNotAllMainProductSoldToAsso__c= commer.reasonNotAllMainProductSoldToAsso__c;
                        farmer.ThisYearSoldMainProductOverPrice__c= commer.ThisYearSoldMainProductOverPrice__c; 
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