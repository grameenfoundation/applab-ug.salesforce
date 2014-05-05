@IsTest
public with sharing class FMPBaselineProcessHandlerTest {

	static CBL_Farm__c initialize() {
		Contact contact = new Contact();
		contact.LastName = 'test baseline process';
		insert contact;
		
		LAC_Farmer_Details__c farmer = new LAC_Farmer_Details__c();
		farmer.Contact__c = contact.Id;
		insert farmer;				
				
		CBL_CoffeeBaseline__c bl = new CBL_CoffeeBaseline__c();
		bl.Farmer__c = farmer.Id;
		insert bl;
		
		CBL_Farm__c farm = new CBL_Farm__c();
		farm.farmName__c = 'Test farm FMP process';
		farm.Baseline__c = bl.Id;
		insert farm;
		
		CBL_WetMill__c wetMill = new CBL_WetMill__c();
		wetMill.Baseline__c = bl.Id;
		
		return farm;
	}
	
	@IsTest
	static void testHandler() {
		CBL_Farm__c testFarm = initialize();
		System.debug('testFarm ' + testFarm.Id);
		FMPBaselineProcessHandler handler = new FMPBaselineProcessHandler(testFarm);
		handler.handle();
		CBL_Farm__c farm = [Select Id from CBL_Farm__c where Id = :testFarm.Id];
		Farm_Management_Plan__c fmp = [Select Id from Farm_Management_Plan__c where Farm__c = :farm.Id];
		PMF_Finca_Categoria_1__c cat1 = [Select Id, Nivel_categor_a__c from PMF_Finca_Categoria_1__c where Plan_de_Manejo_de_Finca__c = :fmp.Id];
		cat1.Nivel_categor_a__c = 'Bajo';
		System.assert(cat1.Nivel_categor_a__c == 'Bajo');
	}

}