trigger CBL_Lot_UpdateDataCbl2 on CBL_Lot__c (after insert) {
    List<CBL2_Lot__c> lots2ToInsert = new List<CBL2_Lot__c>();
    Set<Id> cbl_Ids = new Set<Id>();
    Set<Id> LAC_FD_Ids = new Set<Id>();
    boolean lotExists = false;
    
    //get a list with lot Ids inserted
    for (CBL_Lot__c newRow : Trigger.new) {
        cbl_Ids.add(newRow.Id);
    }
    //get a list with lots rows completed (Baseline__r.Farmer__c)
    for(List<CBL_Lot__c> cbls_lots : [SELECT Id, Farm__c, Farm__r.Farmer__c, Farm__r.farmName__c, lotArea__c, lotAreaUnits__c, lotCode__c, Lot_Code_Guat__c, lotCoffeeVariety__c, lotName__c, lotNumberOfPlants__c, lotPlantingDate__c, Submission__c
                FROM CBL_Lot__c WHERE Id IN: cbl_Ids]){

        //get a list with the LAC Farmer Details ids to search the lots2 in CBL2 model
        for(CBL_Lot__c cbl_lots : cbls_lots){
            if(!LAC_FD_Ids.contains(cbl_lots.Farm__r.Farmer__c))
                LAC_FD_Ids.add(cbl_lots.Farm__r.Farmer__c);
        }
        
        //get the lots2 to uptade the lot data
        for(List<CBL2_Lot__c> lots2ToUpdate : [SELECT Id, Farm__c, Farm__r.Farmer__c, lotArea__c, lotAreaUnits__c, lotCode__c, Lot_Code_Guat__c, lotCoffeeVariety__c, lotName__c, lotNumberOfPlants__c, lotPlantingDate__c, Submission__c
                                            FROM CBL2_Lot__c WHERE Farm__r.Farmer__c IN :LAC_FD_Ids]){
            //if the lot exits for the same LAC_FD the lot2 will be updated, if the lot doesn't exists the lot2 will be created
            for(CBL_Lot__c lotInserted : cbls_lots){
                lotExists = false;
                for(CBL2_Lot__c lot2 : lots2ToUpdate){
                    //if lotExists is true then update lot2
                    if((lotInserted.Farm__r.Farmer__c == lot2.Farm__r.Farmer__c) && (lotInserted.Farm__r.farmName__c == lot2.Farm__r.farmName__c) && (lotInserted.lotName__c == lot2.lotName__c)){ 
                        lotExists = true;
                        lot2.lotArea__c = lotInserted.lotArea__c;
                        lot2.lotAreaUnits__c = lotInserted.lotAreaUnits__c;
                        lot2.lotCode__c = lotInserted.lotCode__c;
                        lot2.Lot_Code_Guat__c = lotInserted.Lot_Code_Guat__c;
                        lot2.lotCoffeeVariety__c = lotInserted.lotCoffeeVariety__c;
                        lot2.lotNumberOfPlants__c = lotInserted.lotNumberOfPlants__c;
                        lot2.lotPlantingDate__c = lotInserted.lotPlantingDate__c;
                        lot2.Submission__c = lotInserted.Submission__c;
                    }            
                }
                //if lotExists is false then create a new lot2 to insert
                if(!lotExists){
                    CBL2_Lot__c newlot = new CBL2_Lot__c();
                    newlot.Farm__c = [SELECT Id FROM CBL2_Farm__c WHERE Farmer__c =: lotInserted.Farm__r.Farmer__c AND farmName__c =: lotInserted.Farm__r.farmName__c][0].Id;
                    newlot.lotArea__c = lotInserted.lotArea__c;
                    newlot.lotAreaUnits__c = lotInserted.lotAreaUnits__c;
                    newlot.lotCode__c = lotInserted.lotCode__c;
                    newlot.Lot_Code_Guat__c = lotInserted.Lot_Code_Guat__c;
                    newlot.lotCoffeeVariety__c = lotInserted.lotCoffeeVariety__c;
                    newlot.lotName__c = lotInserted.lotName__c;
                    newlot.lotNumberOfPlants__c = lotInserted.lotNumberOfPlants__c;
                    newlot.lotPlantingDate__c = lotInserted.lotPlantingDate__c;
                    newlot.Submission__c = lotInserted.Submission__c;
                    lots2ToInsert.add(newlot);
                }
            }
            
            try{
                update lots2ToUpdate;
                insert lots2ToInsert;
            }
            catch(system.Exception e){
                system.debug (e);
            }  
        }
    }
}