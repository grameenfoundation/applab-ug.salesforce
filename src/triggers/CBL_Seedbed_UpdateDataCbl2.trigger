trigger CBL_Seedbed_UpdateDataCbl2 on CBL_Seedbed__c (after insert) {
    List<CBL2_Seedbed__c> seedbeds2ToInsert = new List<CBL2_Seedbed__c>();
    Set<Id> cbls_Ids = new Set<Id>();
    Set<Id> LAC_FD_Ids = new Set<Id>();
    boolean seedbedExists = false;
    
    //get a list with seedbed rows inserted and other with only the LAC Farmer Details ids
    for (CBL_Seedbed__c newRow : Trigger.new) {
        cbls_Ids.add(newRow.Id);
    }
    //get a list with seedbedrows completed (Baseline__r.Farmer__c)
    for(List<CBL_Seedbed__c> cbls_seedbeds : [SELECT Id, Farm__c, Farm__r.Farmer__c, Farm__r.farmName__c, adecquatePlantsSelection__c, agrochemicalsDiseasesControl__c, altitudeMetersOverSeaLevel__c, appliesChemicalFertilizers__c, appliesOrganicFertilizers__c, chemicalProductsPlagueControl__c, coffeeVarietiesProducedBought__c, community__c, country__c, department__c, diseasesPlagues__c, estimatedNumberPlantsToBuy__c, estimatedNumberPlantsToProduce__c, fertilizationPlan__c, MgmtPlanPestsDiseas__c, municipality__c, organicProductsDiseasesControl__c, plagueControl__c, seedbedCode__c, Seedbe_code_guat__c, seedbedLocation__c, seedbedSeedOrigin__c, seedbedUsage__c, Submission__c, thisYearBoughtMadeSeedbed__c
                FROM CBL_Seedbed__c WHERE Id IN: cbls_Ids]){

        //get a list with the LAC Farmer Details ids to search the seedbed2 in CBL2 model
        for(CBL_Seedbed__c cbl_seedbed : cbls_seedbeds){
            if(!LAC_FD_Ids.contains(cbl_seedbed.Farm__r.Farmer__c))
                LAC_FD_Ids.add(cbl_seedbed.Farm__r.Farmer__c);
        }
        
        //get the seedbed2 to uptade
        for(List<CBL2_Seedbed__c> seedbeds2ToUpdate : [SELECT Id, CBL2_Farm__c, CBL2_Farm__r.farmName__c, CBL2_Farm__r.Farmer__c, adecquatePlantsSelection__c, agrochemicalsDiseasesControl__c, altitudeMetersOverSeaLevel__c, appliesChemicalFertilizers__c, appliesOrganicFertilizers__c, chemicalProductsPlagueControl__c, coffeeVarietiesProducedBought__c, community__c, country__c, department__c, diseasesPlagues__c, estimatedNumberPlantsToBuy__c, estimatedNumberPlantsToProduce__c, fertilizationPlan__c, MgmtPlanPestsDiseas__c, municipality__c, organicProductsDiseasesControl__c, plagueControl__c, seedbedCode__c, Seedbed_code_guat__c, seedbedLocation__c, seedbedSeedOrigin__c, seedbedUsage__c, Submission__c, thisYearBoughtMadeSeedbed__c
                                        FROM CBL2_Seedbed__c WHERE CBL2_Farm__r.Farmer__c IN :LAC_FD_Ids]){
            //if the seedbed exits for the same LAC_FD the seedbed2 will be updated, if the seedbed doesn't exists the seedbed2 will be created
            for(CBL_Seedbed__c seedbedInserted : cbls_seedbeds ){
                seedbedExists = false;
                for(CBL2_Seedbed__c seedbed2 : seedbeds2ToUpdate){
                    //if seedbedExists is true then update lot2
                    if((seedbedInserted.Farm__r.Farmer__c == seedbed2.CBL2_Farm__r.Farmer__c) && (seedbedInserted.Farm__r.farmName__c == seedbed2.CBL2_Farm__r.farmName__c)){ 
                        seedbedExists = true;
                        seedbed2.adecquatePlantsSelection__c = seedbedInserted.adecquatePlantsSelection__c;
                        seedbed2.agrochemicalsDiseasesControl__c = seedbedInserted.agrochemicalsDiseasesControl__c;
                        seedbed2.altitudeMetersOverSeaLevel__c = seedbedInserted.altitudeMetersOverSeaLevel__c;
                        seedbed2.appliesChemicalFertilizers__c = seedbedInserted.appliesChemicalFertilizers__c;
                        seedbed2.appliesOrganicFertilizers__c = seedbedInserted.appliesOrganicFertilizers__c;
                        seedbed2.chemicalProductsPlagueControl__c = seedbedInserted.chemicalProductsPlagueControl__c;
                        seedbed2.coffeeVarietiesProducedBought__c = seedbedInserted.coffeeVarietiesProducedBought__c;
                        seedbed2.community__c = seedbedInserted.community__c;
                        seedbed2.country__c = seedbedInserted.country__c;
                        seedbed2.department__c = seedbedInserted.department__c;
                        seedbed2.diseasesPlagues__c = seedbedInserted.diseasesPlagues__c;
                        seedbed2.estimatedNumberPlantsToBuy__c = seedbedInserted.estimatedNumberPlantsToBuy__c;
                        seedbed2.estimatedNumberPlantsToProduce__c= seedbedInserted.estimatedNumberPlantsToProduce__c;
                        seedbed2.fertilizationPlan__c = seedbedInserted.fertilizationPlan__c;
                        seedbed2.MgmtPlanPestsDiseas__c = seedbedInserted.MgmtPlanPestsDiseas__c;
                        seedbed2.municipality__c = seedbedInserted.municipality__c;
                        seedbed2.organicProductsDiseasesControl__c = seedbedInserted.organicProductsDiseasesControl__c;
                        seedbed2.plagueControl__c = seedbedInserted.plagueControl__c;
                        seedbed2.seedbedCode__c = seedbedInserted.seedbedCode__c;
                        seedbed2.Seedbed_code_guat__c = seedbedInserted.Seedbe_code_guat__c;
                        seedbed2.seedbedLocation__c = seedbedInserted.seedbedLocation__c;
                        seedbed2.seedbedSeedOrigin__c = seedbedInserted.seedbedSeedOrigin__c;
                        seedbed2.seedbedUsage__c = seedbedInserted.seedbedUsage__c;
                        seedbed2.thisYearBoughtMadeSeedbed__c = seedbedInserted.thisYearBoughtMadeSeedbed__c;
                        seedbed2.Submission__c = seedbedInserted.Submission__c;
                    }            
                }
                //if seedbedExists is false then create a new seedbed2 to insert
                if(!seedbedExists){
                    CBL2_Seedbed__c newSeedbed = new CBL2_Seedbed__c();
                	newSeedbed.CBL2_Farm__c = [SELECT Id FROM CBL2_Farm__c WHERE Farmer__c =: seedbedInserted.Farm__r.Farmer__c AND farmName__c =: seedbedInserted.Farm__r.farmName__c][0].Id;
    				newSeedbed.adecquatePlantsSelection__c = seedbedInserted.adecquatePlantsSelection__c;
                    newSeedbed.agrochemicalsDiseasesControl__c = seedbedInserted.agrochemicalsDiseasesControl__c;
                    newSeedbed.altitudeMetersOverSeaLevel__c = seedbedInserted.altitudeMetersOverSeaLevel__c;
                    newSeedbed.appliesChemicalFertilizers__c = seedbedInserted.appliesChemicalFertilizers__c;
                    newSeedbed.appliesOrganicFertilizers__c = seedbedInserted.appliesOrganicFertilizers__c;
                    newSeedbed.chemicalProductsPlagueControl__c = seedbedInserted.chemicalProductsPlagueControl__c;
                    newSeedbed.coffeeVarietiesProducedBought__c = seedbedInserted.coffeeVarietiesProducedBought__c;
                    newSeedbed.community__c = seedbedInserted.community__c;
                    newSeedbed.country__c = seedbedInserted.country__c;
                    newSeedbed.department__c = seedbedInserted.department__c;
                    newSeedbed.diseasesPlagues__c = seedbedInserted.diseasesPlagues__c;
                    newSeedbed.estimatedNumberPlantsToBuy__c = seedbedInserted.estimatedNumberPlantsToBuy__c;
                    newSeedbed.estimatedNumberPlantsToProduce__c= seedbedInserted.estimatedNumberPlantsToProduce__c;
                    newSeedbed.fertilizationPlan__c = seedbedInserted.fertilizationPlan__c;
                    newSeedbed.MgmtPlanPestsDiseas__c = seedbedInserted.MgmtPlanPestsDiseas__c;
                    newSeedbed.municipality__c = seedbedInserted.municipality__c;
                    newSeedbed.organicProductsDiseasesControl__c = seedbedInserted.organicProductsDiseasesControl__c;
                    newSeedbed.plagueControl__c = seedbedInserted.plagueControl__c;
                    newSeedbed.seedbedCode__c = seedbedInserted.seedbedCode__c;
                    newSeedbed.Seedbed_code_guat__c = seedbedInserted.Seedbe_code_guat__c;
                    newSeedbed.seedbedLocation__c = seedbedInserted.seedbedLocation__c;
                    newSeedbed.seedbedSeedOrigin__c = seedbedInserted.seedbedSeedOrigin__c;
                    newSeedbed.seedbedUsage__c = seedbedInserted.seedbedUsage__c;
                    newSeedbed.thisYearBoughtMadeSeedbed__c = seedbedInserted.thisYearBoughtMadeSeedbed__c;
                    newSeedbed.Submission__c = seedbedInserted.Submission__c;
                    seedbeds2ToInsert.add(newSeedbed);
                }
            }
            
            try{
                update seedbeds2ToUpdate;
                insert seedbeds2ToInsert;
            }
            catch(system.Exception e){
                system.debug (e);
            } 
        }
    } 
}