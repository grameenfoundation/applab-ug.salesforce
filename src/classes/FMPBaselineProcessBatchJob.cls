global class FMPBaselineProcessBatchJob implements Database.Batchable<sObject>{

	Integer year = Date.today().year();

  global Database.QueryLocator start(Database.BatchableContext bc) {
      String query = 'Select Id, hires_RegistersTempStaff__c, dangSubstancesManipulatorsTrained__c, registersPlague_DiseaseCtrlSupplies__c, Last_FMP_Year__c, farmManagmtDocuments__c, coffeeInvoicesRegistered__c, identifiesHarvestedCoffee__c, soilConservationPractices__c, erosionZonesIdentified__c, biologicalDiversityContrib__c, percShadeNativeSpecies__c, percentageShade__c, doesPlagues_DiseaseSampling__c, howDoesDiseaseControl__c, howDoesPlagueControl__c, weedsControlMethods__c, useOfProtApplicationDangSubstances__c, promotesFloraAndFaunaPreservation__c, cleanTransportContainers__c, Baseline__c from CBL_Farm__c where (Last_FMP_Year__c = null or Last_FMP_Year__c < :year) and Submission__c != null';
      return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext bc, List<CBL_Farm__c> farms) {
    for (CBL_Farm__c farm : farms) {
        FMPBaselineProcessHandler handler = new FMPBaselineProcessHandler(farm);
        handler.handle();
        farm.Last_FMP_Year__c = year;
    }
    update farms;
  }
  
  global void finish(Database.BatchableContext bc) {
    // Do nothing
  }

}