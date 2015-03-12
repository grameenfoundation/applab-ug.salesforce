trigger CBL_WetMill_UpdateDataCbl2 on CBL_WetMill__c (after insert) {
    Set<Id> cbls_Ids = new Set<Id>();
    Set<Id> LAC_FD_Ids = new Set<Id>();
    
    //get a list with WetMill id rows inserted
    for (CBL_WetMill__c newRow : Trigger.new) {
        cbls_Ids.add(newRow.Id);
    }
    //get a list with WetMill rows completed (Baseline__r.Farmer__c)
    for(List<CBL_WetMill__c> cbls_wetMill : [SELECT Id, Farm__c, Farm__r.farmName__c, Baseline__c, Baseline__r.Farmer__c, wetMillAlreadyRegistered__c, baseUsedForStorage__c, canSeparateByLot__c, checksTransport__c, classifiesInputCoffeeQuality__c, cleanWaterResting__c, cleanWaterRestingTime__c, cleanWaterUsed__c, wetMillCode__c, Wetmill_code_guat__c, coffeeHarvestedMore6Hours__c, coffeWashMeans__c, contaminationRisk__c, wetMillCountry__c, wetMillDepartment__c, wetMillDistrict__c, documentationAndLabeling__c, drainageInfraStatus__c, drainageStatus__c, dryingStatus__c, dryIsolatedContamination__c, dryMeans__c, dryOver50Grades__c, enoughWater__c, fermentationProcess__c, fermentationTanksStatus__c, fermentationTime__c, fermTanksStatusBeforeProcess__c, fruitRecepBinStatusBeforeProc__c, fruitReceptionBinStatus__c, hasPestControl__c, hasWarehouseOnlyForCoffee__c, howClassifies__c, humidityRisk__c, immediateDry__c, isTheWetMillReadyOrCertified__c, lastWashWaterRecycled__c, wetMillLocation__c, majorNonCompliance__c, wetMillMunicipality__c, ownsWetMill__c, patioAndMecanicDryerStatus__c, processedCoffeeCertifications__c, processedCoffeeOrigin__c, processesWithDocumentation__c, protectsTransport__c, pulpingMachinesStatus__c, pulpingMachineWashedBeforeUse__c, pulpManagement__c, residualWaterDisposal__c, residualWaterDistOver40__c, riskOfContamWResidualWater__c, salesPurchasesDocumentation__c, separatedGrainsProcessedAppart__c, separationNetUsedToClasify__c, storageCleanlinessStatus__c, traceabilitySystem__c, transportWithChemicals__c, warehouseOtherUses__c, washInfraStatusBeforeProc__c, washInfrastructureStatus__c, washWaterSource__c, waterSeparation__c, Submission__c
                FROM CBL_WetMill__c WHERE Id IN :cbls_Ids]){
        //get a list with the LAC Farmer Details ids to search the farm2 in CBL2 model
        for(CBL_WetMill__c cbl_wetMill : cbls_wetMill){
            if(!LAC_FD_Ids.contains(cbl_wetMill.Baseline__r.Farmer__c))
                LAC_FD_Ids.add(cbl_wetMill.Baseline__r.Farmer__c);
        }

        //get the WetMill2 to uptade the WetMill data
        for(List<CBL2_Farm__c> WetMill2ToUpdate : [SELECT Id, farmName__c, Farmer__c, wetmill_AlreadyRegistered__c, wetmill_baseUsedForStorage__c, wetmill_canSeparateByLot__c, wetmill_checksTransport__c, wetmill_classifiesInputCoffeeQuality__c, wetmill_cleanWaterResting__c, wetmill_cleanWaterRestingTime__c, wetmill_cleanWaterUsed__c, wetmill_Code__c, wetmill_code_guat__c, wetmill_coffeeHarvestedMore6Hours__c, wetmill_coffeWashMeans__c, wetmill_contaminationRisk__c, wetmill_Country__c, wetmill_Department__c, wetmill_District__c, wetmill_documentationAndLabeling__c, wetmill_drainageInfraStatus__c, wetmill_drainageStatus__c, wetmill_dryingStatus__c, wetmill_dryIsolatedContamination__c, wetmill_dryMeans__c, wetmill_dryOver50Grades__c, wetmill_enoughWater__c, wetmill_fermentationProcess__c, wetmill_fermentationTanksStatus__c, wetmill_fermentationTime__c, wetmill_fermTanksStatusBeforeProcess__c, wetmill_fruitRecepBinStatusBeforeProc__c, wetmill_fruitReceptionBinStatus__c, wetmill_hasPestControl__c, wetmill_hasWarehouseOnlyForCoffee__c, wetmill_howClassifies__c, wetmill_humidityRisk__c, wetmill_immediateDry__c, wetmill_isTheWetMillReadyOrCertified__c, wetmill_lastWashWaterRecycled__c, wetmill_Location__c, wetmill_majorNonCompliance__c, wetmill_Municipality__c, wetmill_owns__c, wetmill_patioAndMecanicDryerStatus__c, wetmill_processedCoffeeCertifications__c, wetmill_processedCoffeeOrigin__c, wetmill_processesWithDocumentation__c, wetmill_protectsTransport__c, wetmill_pulpingMachinesStatus__c, wetmill_pulpingMachineWashedBeforeUse__c, wetmill_pulpManagement__c, wetmill_residualWaterDisposal__c, wetmill_residualWaterDistOver40__c, wetmill_riskOfContamWResidualWater__c, wetmill_salesPurchasesDocumentation__c, wetmill_separatedGrainsProcessedAppart__c, wetmill_separationNetUsedToClasify__c, wetmill_storageCleanlinessStatus__c, wetmill_traceabilitySystem__c, wetmill_transportWithChemicals__c, wetmill_warehouseOtherUses__c, wetmill_washInfraStatusBeforeProc__c, wetmill_washInfrastructureStatus__c, wetmill_washWaterSource__c, wetmill_waterSeparation__c, Submission_Wetmill__c 
    											FROM CBL2_Farm__c WHERE Farmer__c IN :LAC_FD_Ids]){
            //if the WetMill exits for the same LAC_FD the WetMill2 (CBL2_Farm) will be updated, if the WetMill doesn't exists the WetMill2 (CBL2_Farm) will be created
            for(CBL_WetMill__c WetMillInserted : cbls_wetMill){
                for(CBL2_Farm__c WetMill2 : WetMill2ToUpdate){
                    //if condition is true then update WetMill2 (CBL2_Farm)
                    if((WetMillInserted.Baseline__r.Farmer__c == WetMill2.Farmer__c) && (WetMillInserted.Farm__r.farmName__c == WetMill2.farmName__c)){ 
                        WetMill2.wetmill_AlreadyRegistered__c = WetMillInserted.wetMillAlreadyRegistered__c;
                        WetMill2.wetmill_baseUsedForStorage__c = WetMillInserted.baseUsedForStorage__c;
                        WetMill2.wetmill_canSeparateByLot__c = WetMillInserted.canSeparateByLot__c;
                        WetMill2.wetmill_checksTransport__c = WetMillInserted.checksTransport__c;
                        WetMill2.wetmill_classifiesInputCoffeeQuality__c = WetMillInserted.classifiesInputCoffeeQuality__c;
                        WetMill2.wetmill_cleanWaterResting__c = WetMillInserted.cleanWaterResting__c;
                        WetMill2.wetmill_cleanWaterRestingTime__c = WetMillInserted.cleanWaterRestingTime__c;
                        WetMill2.wetmill_cleanWaterUsed__c = WetMillInserted.cleanWaterUsed__c;
                        WetMill2.wetmill_Code__c = WetMillInserted.wetMillCode__c;
                        WetMill2.wetmill_code_guat__c = WetMillInserted.Wetmill_code_guat__c;
                        WetMill2.wetmill_coffeeHarvestedMore6Hours__c = WetMillInserted.coffeeHarvestedMore6Hours__c;
                        WetMill2.wetmill_coffeWashMeans__c = WetMillInserted.coffeWashMeans__c;
                        WetMill2.wetmill_contaminationRisk__c = WetMillInserted.contaminationRisk__c;
                        WetMill2.wetmill_Country__c = WetMillInserted.wetMillCountry__c;
                        WetMill2.wetmill_Department__c = WetMillInserted.wetMillDepartment__c;
                        WetMill2.wetmill_District__c = WetMillInserted.wetMillDistrict__c;
                        WetMill2.wetmill_documentationAndLabeling__c = WetMillInserted.documentationAndLabeling__c;
                        WetMill2.wetmill_drainageInfraStatus__c = WetMillInserted.drainageInfraStatus__c;
                        WetMill2.wetmill_drainageStatus__c = WetMillInserted.drainageStatus__c;
                        WetMill2.wetmill_dryingStatus__c = WetMillInserted.dryingStatus__c;
                        WetMill2.wetmill_dryIsolatedContamination__c = WetMillInserted.dryIsolatedContamination__c;
                        WetMill2.wetmill_dryMeans__c = WetMillInserted.dryMeans__c;
                        WetMill2.wetmill_dryOver50Grades__c = WetMillInserted.dryOver50Grades__c;
                        WetMill2.wetmill_enoughWater__c = WetMillInserted.enoughWater__c;
                        WetMill2.wetmill_fermentationProcess__c = WetMillInserted.fermentationProcess__c;
                        WetMill2.wetmill_fermentationTanksStatus__c = WetMillInserted.fermentationTanksStatus__c;
                        WetMill2.wetmill_fermentationTime__c = WetMillInserted.fermentationTime__c;
                        WetMill2.wetmill_fermTanksStatusBeforeProcess__c = WetMillInserted.fermTanksStatusBeforeProcess__c;
                        WetMill2.wetmill_fruitRecepBinStatusBeforeProc__c = WetMillInserted.fruitRecepBinStatusBeforeProc__c;
                        WetMill2.wetmill_fruitReceptionBinStatus__c = WetMillInserted.fruitReceptionBinStatus__c;
                        WetMill2.wetmill_hasPestControl__c = WetMillInserted.hasPestControl__c;
                        WetMill2.wetmill_hasWarehouseOnlyForCoffee__c = WetMillInserted.hasWarehouseOnlyForCoffee__c;
                        WetMill2.wetmill_howClassifies__c = WetMillInserted.howClassifies__c;
                        WetMill2.wetmill_humidityRisk__c = WetMillInserted.humidityRisk__c;
                        WetMill2.wetmill_immediateDry__c = WetMillInserted.immediateDry__c;
                        WetMill2.wetmill_isTheWetMillReadyOrCertified__c = WetMillInserted.isTheWetMillReadyOrCertified__c;
                        WetMill2.wetmill_lastWashWaterRecycled__c = WetMillInserted.lastWashWaterRecycled__c;
                        WetMill2.wetmill_Location__c = WetMillInserted.wetMillLocation__c;
                        WetMill2.wetmill_majorNonCompliance__c = WetMillInserted.majorNonCompliance__c;
                        WetMill2.wetmill_Municipality__c = WetMillInserted.wetMillMunicipality__c;
                        WetMill2.wetmill_owns__c = WetMillInserted.ownsWetMill__c;
                        WetMill2.wetmill_patioAndMecanicDryerStatus__c = WetMillInserted.patioAndMecanicDryerStatus__c;
                        WetMill2.wetmill_processedCoffeeCertifications__c = WetMillInserted.processedCoffeeCertifications__c;
                        WetMill2.wetmill_processedCoffeeOrigin__c = WetMillInserted.processedCoffeeOrigin__c;
                        WetMill2.wetmill_processesWithDocumentation__c = WetMillInserted.processesWithDocumentation__c;
                        WetMill2.wetmill_protectsTransport__c = WetMillInserted.protectsTransport__c;
                        WetMill2.wetmill_pulpingMachinesStatus__c = WetMillInserted.pulpingMachinesStatus__c;
                        WetMill2.wetmill_pulpingMachineWashedBeforeUse__c = WetMillInserted.pulpingMachineWashedBeforeUse__c;
                        WetMill2.wetmill_pulpManagement__c = WetMillInserted.pulpManagement__c;
                        WetMill2.wetmill_residualWaterDisposal__c = WetMillInserted.residualWaterDisposal__c;
                        WetMill2.wetmill_residualWaterDistOver40__c = WetMillInserted.residualWaterDistOver40__c;
                        WetMill2.wetmill_riskOfContamWResidualWater__c = WetMillInserted.riskOfContamWResidualWater__c;
                        WetMill2.wetmill_salesPurchasesDocumentation__c = WetMillInserted.salesPurchasesDocumentation__c;
                        WetMill2.wetmill_separatedGrainsProcessedAppart__c = WetMillInserted.separatedGrainsProcessedAppart__c;
                        WetMill2.wetmill_separationNetUsedToClasify__c = WetMillInserted.separationNetUsedToClasify__c;
                        WetMill2.wetmill_storageCleanlinessStatus__c = WetMillInserted.storageCleanlinessStatus__c;
                        WetMill2.wetmill_traceabilitySystem__c = WetMillInserted.traceabilitySystem__c;
                        WetMill2.wetmill_transportWithChemicals__c = WetMillInserted.transportWithChemicals__c;
                        WetMill2.wetmill_warehouseOtherUses__c = WetMillInserted.warehouseOtherUses__c;
                        WetMill2.wetmill_washInfraStatusBeforeProc__c = WetMillInserted.washInfraStatusBeforeProc__c;
                        WetMill2.wetmill_washInfrastructureStatus__c = WetMillInserted.washInfrastructureStatus__c;
                        WetMill2.wetmill_washWaterSource__c = WetMillInserted.washWaterSource__c;
                        WetMill2.wetmill_waterSeparation__c = WetMillInserted.waterSeparation__c;
                        WetMill2.Submission_Wetmill__c = WetMillInserted.Submission__c;
                    }
                }        
            }
            
            try{
                update WetMill2ToUpdate;
            }
            catch(system.Exception e){
                system.debug (e);
            } 
        }
    } 
}