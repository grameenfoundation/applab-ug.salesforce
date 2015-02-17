trigger CBLlot on CBL_Lot__C(after insert){
  for (CBL_Lot__C newLot : Trigger.new) {
    if (newLot.CBL2_Lot__c <> null) {
      for(CBL2_Lot__c cbl2lot : [SELECT lotArea__c, lotName__c, lotAreaUnits__c, lotCode__c, Lot_Code_Guat__c, lotCoffeeVariety__c, Lot_Latitude__c, Lot_Longitude__c, lotNumberOfPlants__c, lotPlantingDate__c, Submission__c FROM CBL2_Lot__c WHERE Id = :newLot.CBL2_Lot__c]){ 
        cbl2lot.lotArea__c = newLot.lotArea__c;
        cbl2lot.lotAreaUnits__c = newLot.lotAreaUnits__c;
        cbl2lot.lotCode__c = newLot.lotCode__c;
        cbl2lot.Lot_Code_Guat__c = newLot.Lot_Code_Guat__c;
        cbl2lot.lotCoffeeVariety__c = newLot.lotCoffeeVariety__c;
        cbl2lot.lotNumberOfPlants__c = newLot.lotNumberOfPlants__c;
        cbl2lot.lotPlantingDate__c = newLot.lotPlantingDate__c;
        cbl2lot.lotName__c = newLot.lotName__c;
        cbl2lot.Submission__c = newLot.Submission__c;
        update cbl2lot;
      }
    }
  }
}