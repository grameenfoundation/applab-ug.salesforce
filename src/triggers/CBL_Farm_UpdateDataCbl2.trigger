trigger CBL_Farm_UpdateDataCbl2 on CBL_Farm__c (after insert) {
    List<CBL_Farm__c> cbls_farms = new List<CBL_Farm__c>();
    List<CBL2_Farm__c> farms2ToInsert = new List<CBL2_Farm__c>();
    Set<Id> LAC_FD_Ids = new Set<Id>();
    boolean farmExists = false;
    
    //get a list with farm rows inserted and other with only the LAC Farmer Details ids
    for (CBL_Farm__c newRow : Trigger.new) {
        cbls_farms.add(newRow);
        if(!LAC_FD_Ids.contains(newRow.Farmer__c))
            LAC_FD_Ids.add(newRow.Farmer__c);
    }

    //MAP <LAC_FD Id, CBL2_Farmer Id> to save the Farm2_Id to insert new farms based on LAC_Farmer_Details
    Map<Id, Id> Cbl2FarmerByLAC_FD = new Map<Id, Id>();
    for(List<CBL2_Farmer__c> farmers2 : [SELECT Id, LAC_Farmer_Details__c FROM CBL2_Farmer__c WHERE LAC_Farmer_Details__c IN : LAC_FD_Ids]){
        for(CBL2_Farmer__c farmer2: farmers2){
            if(!Cbl2FarmerByLAC_FD.containsKey(farmer2.LAC_Farmer_Details__c))
                Cbl2FarmerByLAC_FD.put(farmer2.LAC_Farmer_Details__c, farmer2.Id);
        }
    }
    
    //get the farms2 to uptade the farm data
    for(List<CBL2_Farm__c> farms2ToUpdate : [SELECT Id, Farmer__c, agrochemElimin100MtsAwayWater__c,agrochemOriginalContainerProperUse__c,altitudInMOSL__c,areaRenewedCoffee__c,areaRenewedCoffeeUnits__c,biologicalDiversityContrib__c,chemicalFertilizersUseLastYr__c,cleanTransportContainers__c,coffeCuttingPolicy__c,coffeeInvoicesRegistered__c,coffeePlantedArea__c,coffeePlantedAreaUnits__c,coffeeProcessingPlanDistance__c,coffeProcessingPlace__c,containersNotReused__c,contaminationProtectionMeasures__c,contaminationRiskZones__c,contaminationSources__c,CP_Calculation_Date__c,dangSubstancesManipulatorsTrained__c,discrimination__c,diseaseControlAgrochemicals__c,diseaseControlApplicationNumber__c,diseaseControlOrganicProducts__c,doesPlagues_DiseaseSampling__c,doesSoilSampling__c,doesSoilTreatmentCorrectPH__c,entranceProhibited48Hours__c,erosionRiskLevel__c,erosionRiskPercentage__c,erosionZonesIdentified__c,farmCertifications__c,farmCode__c,Farm_Code_Guat__c,farmCountry__c,farmDepartment__c,farmDistrict__c,farmLocation__c,farmManagmtDocuments__c,farmMgmtDocsComplete__c,farmMunicipality__c,farmName__c,farmOwnership__c,farmPermanentStaff__c,farmWaterBodies__c,fertAcordingSoilAnalysis__c,fertilizerApplicationsLastYr__c,fertilizerManufactureCriteria__c,foliarFertilizerUseLastYr__c,forcedLabor__c,forestArea__c,heightMainShadeColumn__c,highIncidenceDiseases__c,highIncidencePlagues__c,hires_RegistersTempStaff__c,hiresUnderAge__c,howDoesDiseaseControl__c,howDoesPlagueControl__c,identifiesHarvestedCoffee__c,Last_FMP_Year__c,lastSoilSampling__c,lastYearTemporaryWages__c,lotsWithCoffeePlanted__c,majorNonConformances__c,maxHeightShade__c,newPlantedArea__c,newPlantedAreaUnits__c,nonConformancePicURL__c,numberOfShadeSpecies__c,organicFertApplicationsLastYr__c,organicFertAreaThisYr__c,organicFertAreaThisYrUnits__c,organicFertilizerIngredients__c,organicFertilizersLastYr__c,organicStatus__c,otherActivitiesArea__c,otherActivitiesAreaUnits__c,otherChemicalFertilizers__c,otherDiseaseControl__c,otherDiseaseControlAgrochem__c,otherDiseaseControlOrganicProd__c,otherFoliarFertilizerLastYr__c,otherHighDisease__c,otherHighIncidencePlagues__c,otherOrganicFertIngredients__c,otherOrganizFertilizers__c,otherPlagueCtrlAgrochemicals__c,otherProdSoilTreatment__c,otherWeedsCtrlHerbicides__c,percentageShade__c,percErosionZoneRiskPrevention__c,percShadeDominantSpecie__c,percShadeFruitTrees__c,percShadeLeguminous__c,percShadeNativeSpecies__c,percWithoutShade__c,permWorkersMinimumMonthWage__c,physicalOralSexualAbuse__c,plague_DiseaseControlEquipmt__c,plagueControlAgroChemicals__c,plantedNewAreas__c,prodLastHarvestUnits__c,productionContaminationRisk__c,productionLastHarvest__c,productsSoilTreatment__c,promotesFloraAndFaunaPreservation__c,pruneAreaLastyear__c,pruneAreaLastYearUnits__c,pruneLastYear__c,pruneType__c,registersPlague_DiseaseCtrlSupplies__c,renewedCoffeeLastYear__c,safeStorageForSupplies__c,shadowLevelsNumber__c,signatureURL__c,soilConservAreaUnits__c,soilConservationArea__c,soilConservationPractices__c,Submission_Farm__c,tempWorkersMinimumDailyWage__c,totalFarmArea__c,totalFarmAreaUnits__c,turnedForestInCropArea__c,typeOfCoffeeLastHarvest__c,underagePregnantProtected__c,underAgeWorkConditions__c,unitForestArea__c,useOfProtApplicationDangSubstances__c,usesLeguminousNitrAbsort__c,wasteDisposedSafeWay__c,waterBodiesBufferZones__c,weedsControlHerbicides__c,weedsControlMethods__c 
                                    FROM CBL2_Farm__c WHERE Farmer__c IN :LAC_FD_Ids]){
        for(CBL_Farm__c farmInserted : cbls_farms){
            farmExists = false;
            //if the farm exits for the same LAC_FD the farm2 will be updated, if the farm doesn't exists the farm2 will be created
            for(CBL2_Farm__c farm2 : farms2ToUpdate){
                //if farmExists is true then update farm2
                if((farmInserted.Farmer__c == farm2.Farmer__c) && (farmInserted.farmName__c == farm2.farmName__c)){ 
                    farmExists = true;
                    farm2.agrochemElimin100MtsAwayWater__c = farmInserted.agrochemElimin100MtsAwayWater__c;
                    farm2.agrochemOriginalContainerProperUse__c = farmInserted.agrochemOriginalContainerProperUse__c;
                    farm2.altitudInMOSL__c = farmInserted.altitudInMOSL__c;
                    farm2.areaRenewedCoffee__c = farmInserted.areaRenewedCoffee__c;
                    farm2.areaRenewedCoffeeUnits__c = farmInserted.areaRenewedCoffeeUnits__c;
                    farm2.biologicalDiversityContrib__c = farmInserted.biologicalDiversityContrib__c;
                    farm2.chemicalFertilizersUseLastYr__c = farmInserted.chemicalFertilizersUseLastYr__c;
                    farm2.cleanTransportContainers__c = farmInserted.cleanTransportContainers__c;
                    farm2.coffeCuttingPolicy__c = farmInserted.coffeCuttingPolicy__c;
                    farm2.coffeeInvoicesRegistered__c = farmInserted.coffeeInvoicesRegistered__c;
                    farm2.coffeePlantedArea__c = farmInserted.coffeePlantedArea__c;
                    farm2.coffeePlantedAreaUnits__c = farmInserted.coffeePlantedAreaUnits__c;
                    farm2.coffeeProcessingPlanDistance__c = farmInserted.coffeeProcessingPlanDistance__c;
                    farm2.coffeProcessingPlace__c = farmInserted.coffeProcessingPlace__c;
                    farm2.containersNotReused__c = farmInserted.containersNotReused__c;
                    farm2.contaminationProtectionMeasures__c = farmInserted.contaminationProtectionMeasures__c;
                    farm2.contaminationRiskZones__c = farmInserted.contaminationRiskZones__c;
                    farm2.contaminationSources__c = farmInserted.contaminationSources__c;
                    farm2.CP_Calculation_Date__c = farmInserted.CP_Calculation_Date__c;
                    farm2.dangSubstancesManipulatorsTrained__c = farmInserted.dangSubstancesManipulatorsTrained__c;
                    farm2.discrimination__c = farmInserted.discrimination__c;
                    farm2.diseaseControlAgrochemicals__c = farmInserted.diseaseControlAgrochemicals__c;
                    farm2.diseaseControlApplicationNumber__c = farmInserted.diseaseControlApplicationNumber__c;
                    farm2.diseaseControlOrganicProducts__c = farmInserted.diseaseControlOrganicProducts__c;
                    farm2.doesPlagues_DiseaseSampling__c = farmInserted.doesPlagues_DiseaseSampling__c;
                    farm2.doesSoilSampling__c = farmInserted.doesSoilSampling__c;
                    farm2.doesSoilTreatmentCorrectPH__c = farmInserted.doesSoilTreatmentCorrectPH__c;
                    farm2.entranceProhibited48Hours__c = farmInserted.entranceProhibited48Hours__c;
                    farm2.erosionRiskLevel__c = farmInserted.erosionRiskLevel__c;
                    farm2.erosionRiskPercentage__c = farmInserted.erosionRiskPercentage__c;
                    farm2.erosionZonesIdentified__c = farmInserted.erosionZonesIdentified__c;
                    farm2.farmCertifications__c = farmInserted.farmCertifications__c;
                    farm2.farmCode__c = farmInserted.farmCode__c;
                    farm2.Farm_Code_Guat__c = farmInserted.Farm_Code_Guat__c;
                    farm2.farmCountry__c = farmInserted.farmCountry__c;
                    farm2.farmDepartment__c = farmInserted.farmDepartment__c;
                    farm2.farmDistrict__c = farmInserted.farmDistrict__c;
                    farm2.farmLocation__c = farmInserted.farmLocation__c;
                    farm2.farmManagmtDocuments__c = farmInserted.farmManagmtDocuments__c;
                    farm2.farmMgmtDocsComplete__c = farmInserted.farmMgmtDocsComplete__c;
                    farm2.farmMunicipality__c = farmInserted.farmMunicipality__c;
                    farm2.farmOwnership__c = farmInserted.farmOwnership__c;
                    farm2.farmPermanentStaff__c = farmInserted.farmPermanentStaff__c;
                    farm2.farmWaterBodies__c = farmInserted.farmWaterBodies__c;
                    farm2.fertAcordingSoilAnalysis__c = farmInserted.fertAcordingSoilAnalysis__c;
                    farm2.fertilizerApplicationsLastYr__c = farmInserted.fertilizerApplicationsLastYr__c;
                    farm2.fertilizerManufactureCriteria__c = farmInserted.fertilizerManufactureCriteria__c;
                    farm2.foliarFertilizerUseLastYr__c = farmInserted.foliarFertilizerUseLastYr__c;
                    farm2.forcedLabor__c = farmInserted.forcedLabor__c;
                    farm2.forestArea__c = farmInserted.forestArea__c;
                    farm2.heightMainShadeColumn__c = farmInserted.heightMainShadeColumn__c;
                    farm2.highIncidenceDiseases__c = farmInserted.highIncidenceDiseases__c;
                    farm2.highIncidencePlagues__c = farmInserted.highIncidencePlagues__c;
                    farm2.hires_RegistersTempStaff__c = farmInserted.hires_RegistersTempStaff__c;
                    farm2.hiresUnderAge__c = farmInserted.hiresUnderAge__c;
                    farm2.howDoesDiseaseControl__c = farmInserted.howDoesDiseaseControl__c;
                    farm2.howDoesPlagueControl__c = farmInserted.howDoesPlagueControl__c;
                    farm2.identifiesHarvestedCoffee__c = farmInserted.identifiesHarvestedCoffee__c;
                    farm2.Last_FMP_Year__c = farmInserted.Last_FMP_Year__c;
                    farm2.lastSoilSampling__c = farmInserted.lastSoilSampling__c;
                    farm2.lastYearTemporaryWages__c = farmInserted.lastYearTemporaryWages__c;
                    farm2.lotsWithCoffeePlanted__c = farmInserted.lotsWithCoffeePlanted__c;
                    farm2.majorNonConformances__c = farmInserted.majorNonConformances__c;
                    farm2.maxHeightShade__c = farmInserted.maxHeightShade__c;
                    farm2.newPlantedArea__c = farmInserted.newPlantedArea__c;
                    farm2.newPlantedAreaUnits__c = farmInserted.newPlantedAreaUnits__c;
                    farm2.nonConformancePicURL__c = farmInserted.nonConformancePicURL__c;
                    farm2.numberOfShadeSpecies__c = farmInserted.numberOfShadeSpecies__c;
                    farm2.organicFertApplicationsLastYr__c = farmInserted.organicFertApplicationsLastYr__c;
                    farm2.organicFertAreaThisYr__c = farmInserted.organicFertAreaThisYr__c;
                    farm2.organicFertAreaThisYrUnits__c = farmInserted.organicFertAreaThisYrUnits__c;
                    farm2.organicFertilizerIngredients__c = farmInserted.organicFertilizerIngredients__c;
                    farm2.organicFertilizersLastYr__c = farmInserted.organicFertilizersLastYr__c;
                    farm2.organicStatus__c = farmInserted.organicStatus__c;
                    farm2.otherActivitiesArea__c = farmInserted.otherActivitiesArea__c;
                    farm2.otherActivitiesAreaUnits__c = farmInserted.otherActivitiesAreaUnits__c;
                    farm2.otherChemicalFertilizers__c = farmInserted.otherChemicalFertilizers__c;
                    farm2.otherDiseaseControl__c = farmInserted.otherDiseaseControl__c;
                    farm2.otherDiseaseControlAgrochem__c = farmInserted.otherDiseaseControlAgrochem__c;
                    farm2.otherDiseaseControlOrganicProd__c = farmInserted.otherDiseaseControlOrganicProd__c;
                    farm2.otherFoliarFertilizerLastYr__c = farmInserted.otherFoliarFertilizerLastYr__c;
                    farm2.otherHighDisease__c = farmInserted.otherHighDisease__c;
                    farm2.otherHighIncidencePlagues__c = farmInserted.otherHighIncidencePlagues__c;
                    farm2.otherOrganicFertIngredients__c = farmInserted.otherOrganicFertIngredients__c;
                    farm2.otherOrganizFertilizers__c = farmInserted.otherOrganizFertilizers__c;
                    farm2.otherPlagueCtrlAgrochemicals__c = farmInserted.otherPlagueCtrlAgrochemicals__c;
                    farm2.otherProdSoilTreatment__c = farmInserted.otherProdSoilTreatment__c;
                    farm2.otherWeedsCtrlHerbicides__c = farmInserted.otherWeedsCtrlHerbicides__c;
                    farm2.percentageShade__c = farmInserted.percentageShade__c;
                    farm2.percErosionZoneRiskPrevention__c = farmInserted.percErosionZoneRiskPrevention__c;
                    farm2.percShadeDominantSpecie__c = farmInserted.percShadeDominantSpecie__c;
                    farm2.percShadeFruitTrees__c = farmInserted.percShadeFruitTrees__c;
                    farm2.percShadeLeguminous__c = farmInserted.percShadeLeguminous__c;
                    farm2.percShadeNativeSpecies__c = farmInserted.percShadeNativeSpecies__c;
                    farm2.percWithoutShade__c = farmInserted.percWithoutShade__c;
                    farm2.permWorkersMinimumMonthWage__c = farmInserted.permWorkersMinimumMonthWage__c;
                    farm2.physicalOralSexualAbuse__c = farmInserted.physicalOralSexualAbuse__c;
                    farm2.plague_DiseaseControlEquipmt__c = farmInserted.plague_DiseaseControlEquipmt__c;
                    farm2.plagueControlAgroChemicals__c = farmInserted.plagueControlAgroChemicals__c;
                    farm2.plantedNewAreas__c = farmInserted.plantedNewAreas__c;
                    farm2.prodLastHarvestUnits__c = farmInserted.prodLastHarvestUnits__c;
                    farm2.productionContaminationRisk__c = farmInserted.productionContaminationRisk__c;
                    farm2.productionLastHarvest__c = farmInserted.productionLastHarvest__c;
                    farm2.productsSoilTreatment__c = farmInserted.productsSoilTreatment__c;
                    farm2.promotesFloraAndFaunaPreservation__c = farmInserted.promotesFloraAndFaunaPreservation__c;
                    farm2.pruneAreaLastyear__c = farmInserted.pruneAreaLastyear__c;
                    farm2.pruneAreaLastYearUnits__c = farmInserted.pruneAreaLastYearUnits__c;
                    farm2.pruneLastYear__c = farmInserted.pruneLastYear__c;
                    farm2.pruneType__c = farmInserted.pruneType__c;
                    farm2.registersPlague_DiseaseCtrlSupplies__c = farmInserted.registersPlague_DiseaseCtrlSupplies__c;
                    farm2.renewedCoffeeLastYear__c = farmInserted.renewedCoffeeLastYear__c;
                    farm2.safeStorageForSupplies__c = farmInserted.safeStorageForSupplies__c;
                    farm2.shadowLevelsNumber__c = farmInserted.shadowLevelsNumber__c;
                    farm2.signatureURL__c = farmInserted.signatureURL__c;
                    farm2.soilConservAreaUnits__c = farmInserted.soilConservAreaUnits__c;
                    farm2.soilConservationArea__c = farmInserted.soilConservationArea__c;
                    farm2.soilConservationPractices__c = farmInserted.soilConservationPractices__c;
                    farm2.Submission_Farm__c = farmInserted.Submission__c;
                    farm2.tempWorkersMinimumDailyWage__c = farmInserted.tempWorkersMinimumDailyWage__c;
                    farm2.totalFarmArea__c = farmInserted.totalFarmArea__c;
                    farm2.totalFarmAreaUnits__c = farmInserted.totalFarmAreaUnits__c;
                    farm2.turnedForestInCropArea__c = farmInserted.turnedForestInCropArea__c;
                    farm2.typeOfCoffeeLastHarvest__c = farmInserted.typeOfCoffeeLastHarvest__c;
                    farm2.underagePregnantProtected__c = farmInserted.underagePregnantProtected__c;
                    farm2.underAgeWorkConditions__c = farmInserted.underAgeWorkConditions__c;
                    farm2.unitForestArea__c = farmInserted.unitForestArea__c;
                    farm2.useOfProtApplicationDangSubstances__c = farmInserted.useOfProtApplicationDangSubstances__c;
                    farm2.usesLeguminousNitrAbsort__c = farmInserted.usesLeguminousNitrAbsort__c;
                    farm2.wasteDisposedSafeWay__c = farmInserted.wasteDisposedSafeWay__c;
                    farm2.waterBodiesBufferZones__c = farmInserted.waterBodiesBufferZones__c;
                    farm2.weedsControlHerbicides__c = farmInserted.weedsControlHerbicides__c;
                    farm2.weedsControlMethods__c = farmInserted.weedsControlMethods__c;
                }
            }
            //if farmExists is false then create a new farm2 to insert
            if(!farmExists){
                CBL2_Farm__c newFarm = new CBL2_Farm__c();
                //newFarm.CBL2_Farms_Farmer__c = [SELECT Id FROM CBL2_Farmer__c WHERE LAC_Farmer_Details__c =: farmInserted.Farmer__c][0].Id;
                newFarm.CBL2_Farms_Farmer__c = Cbl2FarmerByLAC_FD.get(farmInserted.Farmer__c);
                newFarm.agrochemElimin100MtsAwayWater__c = farmInserted.agrochemElimin100MtsAwayWater__c;
                newFarm.agrochemOriginalContainerProperUse__c = farmInserted.agrochemOriginalContainerProperUse__c;
                newFarm.altitudInMOSL__c = farmInserted.altitudInMOSL__c;
                newFarm.areaRenewedCoffee__c = farmInserted.areaRenewedCoffee__c;
                newFarm.areaRenewedCoffeeUnits__c = farmInserted.areaRenewedCoffeeUnits__c;
                newFarm.biologicalDiversityContrib__c = farmInserted.biologicalDiversityContrib__c;
                newFarm.chemicalFertilizersUseLastYr__c = farmInserted.chemicalFertilizersUseLastYr__c;
                newFarm.cleanTransportContainers__c = farmInserted.cleanTransportContainers__c;
                newFarm.coffeCuttingPolicy__c = farmInserted.coffeCuttingPolicy__c;
                newFarm.coffeeInvoicesRegistered__c = farmInserted.coffeeInvoicesRegistered__c;
                newFarm.coffeePlantedArea__c = farmInserted.coffeePlantedArea__c;
                newFarm.coffeePlantedAreaUnits__c = farmInserted.coffeePlantedAreaUnits__c;
                newFarm.coffeeProcessingPlanDistance__c = farmInserted.coffeeProcessingPlanDistance__c;
                newFarm.coffeProcessingPlace__c = farmInserted.coffeProcessingPlace__c;
                newFarm.containersNotReused__c = farmInserted.containersNotReused__c;
                newFarm.contaminationProtectionMeasures__c = farmInserted.contaminationProtectionMeasures__c;
                newFarm.contaminationRiskZones__c = farmInserted.contaminationRiskZones__c;
                newFarm.contaminationSources__c = farmInserted.contaminationSources__c;
                newFarm.CP_Calculation_Date__c = farmInserted.CP_Calculation_Date__c;
                newFarm.dangSubstancesManipulatorsTrained__c = farmInserted.dangSubstancesManipulatorsTrained__c;
                newFarm.discrimination__c = farmInserted.discrimination__c;
                newFarm.diseaseControlAgrochemicals__c = farmInserted.diseaseControlAgrochemicals__c;
                newFarm.diseaseControlApplicationNumber__c = farmInserted.diseaseControlApplicationNumber__c;
                newFarm.diseaseControlOrganicProducts__c = farmInserted.diseaseControlOrganicProducts__c;
                newFarm.doesPlagues_DiseaseSampling__c = farmInserted.doesPlagues_DiseaseSampling__c;
                newFarm.doesSoilSampling__c = farmInserted.doesSoilSampling__c;
                newFarm.doesSoilTreatmentCorrectPH__c = farmInserted.doesSoilTreatmentCorrectPH__c;
                newFarm.entranceProhibited48Hours__c = farmInserted.entranceProhibited48Hours__c;
                newFarm.erosionRiskLevel__c = farmInserted.erosionRiskLevel__c;
                newFarm.erosionRiskPercentage__c = farmInserted.erosionRiskPercentage__c;
                newFarm.erosionZonesIdentified__c = farmInserted.erosionZonesIdentified__c;
                newFarm.farmCertifications__c = farmInserted.farmCertifications__c;
                newFarm.farmCode__c = farmInserted.farmCode__c;
                newFarm.Farm_Code_Guat__c = farmInserted.Farm_Code_Guat__c;
                newFarm.farmCountry__c = farmInserted.farmCountry__c;
                newFarm.farmDepartment__c = farmInserted.farmDepartment__c;
                newFarm.farmDistrict__c = farmInserted.farmDistrict__c;
                newFarm.Farmer__c = farmInserted.Farmer__c;
                newFarm.farmLocation__c = farmInserted.farmLocation__c;
                newFarm.farmManagmtDocuments__c = farmInserted.farmManagmtDocuments__c;
                newFarm.farmMgmtDocsComplete__c = farmInserted.farmMgmtDocsComplete__c;
                newFarm.farmMunicipality__c = farmInserted.farmMunicipality__c;
                newFarm.farmName__c = farmInserted.farmName__c;
                newFarm.farmOwnership__c = farmInserted.farmOwnership__c;
                newFarm.farmPermanentStaff__c = farmInserted.farmPermanentStaff__c;
                newFarm.farmWaterBodies__c = farmInserted.farmWaterBodies__c;
                newFarm.fertAcordingSoilAnalysis__c = farmInserted.fertAcordingSoilAnalysis__c;
                newFarm.fertilizerApplicationsLastYr__c = farmInserted.fertilizerApplicationsLastYr__c;
                newFarm.fertilizerManufactureCriteria__c = farmInserted.fertilizerManufactureCriteria__c;
                newFarm.foliarFertilizerUseLastYr__c = farmInserted.foliarFertilizerUseLastYr__c;
                newFarm.forcedLabor__c = farmInserted.forcedLabor__c;
                newFarm.forestArea__c = farmInserted.forestArea__c;
                newFarm.heightMainShadeColumn__c = farmInserted.heightMainShadeColumn__c;
                newFarm.highIncidenceDiseases__c = farmInserted.highIncidenceDiseases__c;
                newFarm.highIncidencePlagues__c = farmInserted.highIncidencePlagues__c;
                newFarm.hires_RegistersTempStaff__c = farmInserted.hires_RegistersTempStaff__c;
                newFarm.hiresUnderAge__c = farmInserted.hiresUnderAge__c;
                newFarm.howDoesDiseaseControl__c = farmInserted.howDoesDiseaseControl__c;
                newFarm.howDoesPlagueControl__c = farmInserted.howDoesPlagueControl__c;
                newFarm.identifiesHarvestedCoffee__c = farmInserted.identifiesHarvestedCoffee__c;
                newFarm.Last_FMP_Year__c = farmInserted.Last_FMP_Year__c;
                newFarm.lastSoilSampling__c = farmInserted.lastSoilSampling__c;
                newFarm.lastYearTemporaryWages__c = farmInserted.lastYearTemporaryWages__c;
                newFarm.lotsWithCoffeePlanted__c = farmInserted.lotsWithCoffeePlanted__c;
                newFarm.majorNonConformances__c = farmInserted.majorNonConformances__c;
                newFarm.maxHeightShade__c = farmInserted.maxHeightShade__c;
                newFarm.newPlantedArea__c = farmInserted.newPlantedArea__c;
                newFarm.newPlantedAreaUnits__c = farmInserted.newPlantedAreaUnits__c;
                newFarm.nonConformancePicURL__c = farmInserted.nonConformancePicURL__c;
                newFarm.numberOfShadeSpecies__c = farmInserted.numberOfShadeSpecies__c;
                newFarm.organicFertApplicationsLastYr__c = farmInserted.organicFertApplicationsLastYr__c;
                newFarm.organicFertAreaThisYr__c = farmInserted.organicFertAreaThisYr__c;
                newFarm.organicFertAreaThisYrUnits__c = farmInserted.organicFertAreaThisYrUnits__c;
                newFarm.organicFertilizerIngredients__c = farmInserted.organicFertilizerIngredients__c;
                newFarm.organicFertilizersLastYr__c = farmInserted.organicFertilizersLastYr__c;
                newFarm.organicStatus__c = farmInserted.organicStatus__c;
                newFarm.otherActivitiesArea__c = farmInserted.otherActivitiesArea__c;
                newFarm.otherActivitiesAreaUnits__c = farmInserted.otherActivitiesAreaUnits__c;
                newFarm.otherChemicalFertilizers__c = farmInserted.otherChemicalFertilizers__c;
                newFarm.otherDiseaseControl__c = farmInserted.otherDiseaseControl__c;
                newFarm.otherDiseaseControlAgrochem__c = farmInserted.otherDiseaseControlAgrochem__c;
                newFarm.otherDiseaseControlOrganicProd__c = farmInserted.otherDiseaseControlOrganicProd__c;
                newFarm.otherFoliarFertilizerLastYr__c = farmInserted.otherFoliarFertilizerLastYr__c;
                newFarm.otherHighDisease__c = farmInserted.otherHighDisease__c;
                newFarm.otherHighIncidencePlagues__c = farmInserted.otherHighIncidencePlagues__c;
                newFarm.otherOrganicFertIngredients__c = farmInserted.otherOrganicFertIngredients__c;
                newFarm.otherOrganizFertilizers__c = farmInserted.otherOrganizFertilizers__c;
                newFarm.otherPlagueCtrlAgrochemicals__c = farmInserted.otherPlagueCtrlAgrochemicals__c;
                newFarm.otherProdSoilTreatment__c = farmInserted.otherProdSoilTreatment__c;
                newFarm.otherWeedsCtrlHerbicides__c = farmInserted.otherWeedsCtrlHerbicides__c;
                newFarm.percentageShade__c = farmInserted.percentageShade__c;
                newFarm.percErosionZoneRiskPrevention__c = farmInserted.percErosionZoneRiskPrevention__c;
                newFarm.percShadeDominantSpecie__c = farmInserted.percShadeDominantSpecie__c;
                newFarm.percShadeFruitTrees__c = farmInserted.percShadeFruitTrees__c;
                newFarm.percShadeLeguminous__c = farmInserted.percShadeLeguminous__c;
                newFarm.percShadeNativeSpecies__c = farmInserted.percShadeNativeSpecies__c;
                newFarm.percWithoutShade__c = farmInserted.percWithoutShade__c;
                newFarm.permWorkersMinimumMonthWage__c = farmInserted.permWorkersMinimumMonthWage__c;
                newFarm.physicalOralSexualAbuse__c = farmInserted.physicalOralSexualAbuse__c;
                newFarm.plague_DiseaseControlEquipmt__c = farmInserted.plague_DiseaseControlEquipmt__c;
                newFarm.plagueControlAgroChemicals__c = farmInserted.plagueControlAgroChemicals__c;
                newFarm.plantedNewAreas__c = farmInserted.plantedNewAreas__c;
                newFarm.prodLastHarvestUnits__c = farmInserted.prodLastHarvestUnits__c;
                newFarm.productionContaminationRisk__c = farmInserted.productionContaminationRisk__c;
                newFarm.productionLastHarvest__c = farmInserted.productionLastHarvest__c;
                newFarm.productsSoilTreatment__c = farmInserted.productsSoilTreatment__c;
                newFarm.promotesFloraAndFaunaPreservation__c = farmInserted.promotesFloraAndFaunaPreservation__c;
                newFarm.pruneAreaLastyear__c = farmInserted.pruneAreaLastyear__c;
                newFarm.pruneAreaLastYearUnits__c = farmInserted.pruneAreaLastYearUnits__c;
                newFarm.pruneLastYear__c = farmInserted.pruneLastYear__c;
                newFarm.pruneType__c = farmInserted.pruneType__c;
                newFarm.registersPlague_DiseaseCtrlSupplies__c = farmInserted.registersPlague_DiseaseCtrlSupplies__c;
                newFarm.renewedCoffeeLastYear__c = farmInserted.renewedCoffeeLastYear__c;
                newFarm.safeStorageForSupplies__c = farmInserted.safeStorageForSupplies__c;
                newFarm.shadowLevelsNumber__c = farmInserted.shadowLevelsNumber__c;
                newFarm.signatureURL__c = farmInserted.signatureURL__c;
                newFarm.soilConservAreaUnits__c = farmInserted.soilConservAreaUnits__c;
                newFarm.soilConservationArea__c = farmInserted.soilConservationArea__c;
                newFarm.soilConservationPractices__c = farmInserted.soilConservationPractices__c;
                newFarm.Submission_Farm__c = farmInserted.Submission__c;
                newFarm.tempWorkersMinimumDailyWage__c = farmInserted.tempWorkersMinimumDailyWage__c;
                newFarm.totalFarmArea__c = farmInserted.totalFarmArea__c;
                newFarm.totalFarmAreaUnits__c = farmInserted.totalFarmAreaUnits__c;
                newFarm.turnedForestInCropArea__c = farmInserted.turnedForestInCropArea__c;
                newFarm.typeOfCoffeeLastHarvest__c = farmInserted.typeOfCoffeeLastHarvest__c;
                newFarm.underagePregnantProtected__c = farmInserted.underagePregnantProtected__c;
                newFarm.underAgeWorkConditions__c = farmInserted.underAgeWorkConditions__c;
                newFarm.unitForestArea__c = farmInserted.unitForestArea__c;
                newFarm.useOfProtApplicationDangSubstances__c = farmInserted.useOfProtApplicationDangSubstances__c;
                newFarm.usesLeguminousNitrAbsort__c = farmInserted.usesLeguminousNitrAbsort__c;
                newFarm.wasteDisposedSafeWay__c = farmInserted.wasteDisposedSafeWay__c;
                newFarm.waterBodiesBufferZones__c = farmInserted.waterBodiesBufferZones__c;
                newFarm.weedsControlHerbicides__c = farmInserted.weedsControlHerbicides__c;
                newFarm.weedsControlMethods__c = farmInserted.weedsControlMethods__c;            
                farms2ToInsert.add(newFarm);
            }
        }
        try{
            update farms2ToUpdate;
            insert farms2ToInsert;
        }
        catch(system.Exception e){
            system.debug (e);
        }
    }        
}