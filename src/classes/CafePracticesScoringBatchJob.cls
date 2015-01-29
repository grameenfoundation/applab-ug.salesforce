global class CafePracticesScoringBatchJob implements Database.Batchable<sObject>{

  global Database.QueryLocator start(Database.BatchableContext bc) {
      //String query = 'Select Id, waterBodiesBufferZones__c, wasteDisposedSafeWay__c, erosionZonesIdentified__c, Baseline__c, farm_Area_Ha__c, Forest_Area_Ha__c, permWorkersMinimumMonthWage__c, tempWorkersMinimumDailyWage__c, workersPaidRegularly__c, forcedLabor__c, hiresUnderAge__c, underAgeWorkConditions__c, discrimination__c, physicalOralSexualAbuse__c, useOfProtApplicationDangSubstances__c, dangSubstancesManipulatorsTrained__c, underagePregnantProtected__c, entranceProhibited48Hours__c from CBL_Farm__c where (CP_Calculation_Date__c = null) and Submission__c != null'; 
      String query = 'Select Id, percentageShade__c, Baseline__c, permWorkersMinimumMonthWage__c, tempWorkersMinimumDailyWage__c, workersPaidRegularly__c, forcedLabor__c, hiresUnderAge__c, underAgeWorkConditions__c, discrimination__c, physicalOralSexualAbuse__c, useOfProtApplicationDangSubstances__c, dangSubstancesManipulatorsTrained__c, underagePregnantProtected__c, entranceProhibited48Hours__c, waterBodiesBufferZones__c, wasteDisposedSafeWay__c, erosionZonesIdentified__c, farmManagmtDocuments__c, percErosionZoneRiskPrevention__c, weedsControlMethods__c, percShadeLeguminous__c, lastSoilSampling__c, fertAcordingSoilAnalysis__c, shadowLevelsNumber__c, numberOfShadeSpecies__c, promotesFloraAndFaunaPreservation__c, turnedForestInCropArea__c, farm_Area_Ha__c, Forest_Area_Ha__c, biologicalDiversityContrib__c, diseaseControlAgrochemicals__c, weedsControlHerbicides__c, plagueControlAgroChemicals__c, safeStorageForSupplies__c, agrochemOriginalContainerProperUse__c, registersPlague_DiseaseCtrlSupplies__c, containersNotReused__c from CBL_Farm__c where (CP_Calculation_Date__c = null) and Submission__c != null';
      return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext bc, List<CBL_Farm__c> farms) {
    for (CBL_Farm__c farm : farms) {
        CafePracticesScoringHandler handler = new CafePracticesScoringHandler(farm); 
        handler.handle();
    }
    update farms;
  }
  
  global void finish(Database.BatchableContext bc) {
    // Do nothing
  }

}