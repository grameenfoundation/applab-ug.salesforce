@isTest
private class LacFarmerProfilePageControllerTest {

    public LAC_Farmer_Details__c farmerDetails = createLacFarmer();
    public ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
    public LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc);

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
    
    public static testMethod void testGetFamManagementPlansResults() {
        LAC_Farmer_Details__c farmerDetails = createLacFarmer();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
        LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc); 
        
        system.assertEquals(ctrl.getFamManagementPlansResults().size(), 0);
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
    /*
    down here are the code coverage improvements by JG
    */
    public static testMethod void testmethods() {

        Contact contact = new Contact(LastName = 'Perez');
        insert contact;

        LAC_Farmer_Details__c lacFarmerDetail = new LAC_Farmer_Details__c();
        lacFarmerDetail.Contact__c = contact.Id;
        insert lacFarmerDetail;

        CBL_CoffeeBaseline__c baseline = new CBL_CoffeeBaseline__c();
        baseline.Farmer__c = lacFarmerDetail.Id;
        insert baseline;

        CBL_Attitude__c att = new CBL_Attitude__c();
        att.Baseline__c = baseline.Id;
        insert att;

        CBL_Commercialization__c commer= new CBL_Commercialization__c();
        commer.Baseline__c = baseline.Id;
        insert  commer;

        CBL_Farm__c farm = new CBL_Farm__c();
        farm.Baseline__c = baseline.Id;
        insert farm;

        CBL_FoodSecurity__c foods = new CBL_FoodSecurity__c();
        foods.Baseline__c = baseline.Id;
        insert foods;

        CBL_SocioEconomic__c socioe = new CBL_SocioEconomic__c();
        socioe.Baseline__c = baseline.Id;
        insert socioe;

        CBL_Service__c serv = new CBL_Service__c();
        serv.Baseline__c = baseline.Id;
        insert serv;

        CBL_WetMill__c wetm = new CBL_WetMill__c();
        wetm.Baseline__c = baseline.Id;
        wetm.Farm__c = farm.Id;
        insert wetm;

        ApexPages.StandardController sc = new ApexPages.StandardController(lacFarmerDetail);
        LacFarmerProfilePageController ctrl = new LacFarmerProfilePageController(sc);

        Double production = 0;
        Double area = 0;

        system.assert(ctrl.getPageLanguage()!= null);

        ctrl.getCertificationFarm();

        ctrl.getShowSignaturePage();

        ctrl.getCoffeeBaseline();
        system.assert(ctrl.coffeeBaseline != null);

        ctrl.getSocioEconomic();
        system.assert(ctrl.socioEconomic == null);

        ctrl.getCblCommercialization();
        system.assert(ctrl.cblCommercialization != null);

        ctrl.getCblFarms();
        system.assert(ctrl.cblFarms != null);

        ctrl.getSignatureFarm();
        system.assert(ctrl.signatureFarm != null);

        ctrl.getCblLots();
        system.assert(ctrl.cblLots != null);

        ctrl.getFoodSecs();
        system.assert(ctrl.foodSecs != null);

        ctrl.getCoffeeVarieties();
        system.assert(ctrl.coffeeVarieties != null);

        ctrl.getProductivity();
        system.assert(ctrl.getProduction() != null);

        ctrl.getCertifications();
        system.assert(ctrl.certifications != null);
        

        Test.startTest();


        Test.stopTest();
    }
}