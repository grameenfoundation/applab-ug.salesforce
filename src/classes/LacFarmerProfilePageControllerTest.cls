/**
	Test class for LacFarmerProfilePageController 
*/
@isTest
private class LacFarmerProfilePageControllerTest {

	private LAC_Farmer_Details__c farmerDetails = createLacFarmer();
	private ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
	private LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc);

	public static testMethod void testGetCoffeeVarieties() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc); 
		
		system.assertEquals(ctrl.getCoffeeVarieties(), ''); 
	}
	
	public static testMethod void testGetProductivity() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc); 
		
		system.assertEquals(ctrl.getProductivity(), 'N/A');	
	}

	public static testMethod void testGetProduction() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc); 
		
		system.assertEquals(ctrl.getProduction(), 0); 
	}
	public static testMethod void testGetCoffeePlantedArea() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc); 
		
		system.assertEquals(ctrl.getCoffeePlantedArea(), 0); 	
	}
	public static testMethod void testGetCertifications() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc); 
		
		system.assertEquals(ctrl.getCertifications(), ''); 
	}
	public static testMethod void testGetFMPCategoryResultsGroup() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc); 
		
		system.assertEquals(ctrl.getFMPCategoryResultsGroup().size(), 0);		
	}
	
	public static testMethod void testGetFamManagementPlansResults() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc); 
		
		system.assertEquals(ctrl.getFamManagementPlansResults().size(), 0);
	}
	
	public static testMethod void testGetFMPFarmScores() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc); 
		
		system.assertEquals(ctrl.getFMPFarmScores().size(), 0);
	}
	
	public static testMethod void testGetFoodSecs() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc); 
		
		system.assertEquals(ctrl.getFoodSecs().size(), 0);
	}
	
	public static testMethod void testGetCblLots() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc); 
		
		system.assertEquals(ctrl.getCblLots().size(), 0);
	}
	
	public static testMethod void testGetSignatureFarm() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc);
		system.assertEquals(ctrl.getSignatureFarm(), null);
	}	
	
	public static testMethod void testGetCblFarms() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc);
		system.assertEquals(ctrl.getCblFarms().size(), 0);
	}	

	public static testMethod void testGetCblCommercialization() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc);
		system.assertEquals(ctrl.getCblCommercialization(), null);
	}	
	
	public static testMethod void testGetSocioEconomic() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc);
		system.assertEquals(ctrl.getSocioEconomic(), null);
	}	
	
	public static testMethod void testGetCoffeeBaselines() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc);
		system.assertEquals(ctrl.getCoffeeBaselines().size(), 0);
	}
		
	private static LAC_Farmer_Details__c createLacFarmer() {
		//Person__c person = new Person__c();
		Contact contact = new Contact();
		User user = new User();
		
		LAC_Farmer_Details__c farmerDetails = new LAC_Farmer_Details__c();
		//farmerDetails.Person__c = person.Id;
		farmerDetails.Contact__c = contact.Id;
		farmerDetails.Contact__r = contact;
				
		return farmerDetails;
	}

}