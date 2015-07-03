@isTest
private class FMP_CBLTriggersTest {
    
    @isTest static void cblTest() {
        //create contact
        Contact contact = new Contact();
        contact.LastName = 'Perez';
        insert contact;

        //create LAC Farmer Detail
        LAC_Farmer_Details__c lacFarmer = new LAC_Farmer_Details__c();
        lacFarmer.Contact__c = contact.Id;
        insert lacFarmer;

        //create cbl
        CBL_CoffeeBaseline__c cbl = new CBL_CoffeeBaseline__c();
        cbl.Farmer__c = lacFarmer.Id;
        insert cbl;

        //create attitude
        CBL_Attitude__c attitude = new CBL_Attitude__c();
        attitude.Baseline__c = cbl.Id;
        insert attitude;

        //create commercialization
        CBL_Commercialization__c commercialization = new CBL_Commercialization__c();
        commercialization.Baseline__c = cbl.Id;
        insert commercialization;

        //create foodsecurity
        CBL_FoodSecurity__c foodSecurity = new CBL_FoodSecurity__c();
        foodSecurity.Baseline__c = cbl.Id;
        insert foodSecurity;

        //create service
        CBL_Service__c service = new CBL_Service__c();
        service.Baseline__c = cbl.Id;
        insert service;

        //create socioeconomic
        CBL_SocioEconomic__c socioEconomic = new CBL_SocioEconomic__c();
        socioEconomic.Baseline__c = cbl.Id;
        insert socioEconomic;

        //create farm
        CBL_Farm__c farm = new CBL_Farm__c();
        farm.Baseline__c = cbl.Id;
        farm.farmName__c = 'la finquita';
        farm.Farmer__c = lacFarmer.Id;
        insert farm;

        //create seedbed
        CBL_Seedbed__c seedBed = new CBL_Seedbed__c();
        seedBed.Baseline__c = cbl.Id;
        seedBed.Farm__c = farm.Id;
        insert seedBed;

        //create wetmill
        CBL_WetMill__c wetMill = new CBL_WetMill__c();
        wetMill.Baseline__c = cbl.Id;
        wetMill.Farm__c = farm.Id;
        insert wetMill;

        //create lot
        CBL_Lot__c lot = new CBL_Lot__c();
        lot.Farm__c = farm.Id;
        insert lot;

    }

        @isTest static void fmpTargetTest() {

        //create contact
        Contact contact = new Contact();
        contact.LastName = 'Perez';
        insert contact;

        //create LAC Farmer Detail
        LAC_Farmer_Details__c lacFarmer = new LAC_Farmer_Details__c();
        lacFarmer.Contact__c = contact.Id;
        insert lacFarmer;

        //create farmer
        CBL2_Farmer__c farmer = new CBL2_Farmer__c();
        farmer.LAC_Farmer_Details__c = lacFarmer.Id;
        insert farmer;

        //create farm
        CBL2_Farm__c farm = new CBL2_Farm__c();
        farm.CBL2_Farms_Farmer__c = farmer.Id;
        farm.Farmer__c = lacFarmer.Id;
        insert farm;

        //create diagnostic
        FMP_Diagnostic__c diagnostic = new FMP_Diagnostic__c();
        diagnostic.PMF_Farm__c = farm.Id;
        insert diagnostic;


        FMP_Target__c target = new FMP_Target__c();
        target.FMP_Diagnostic__c = diagnostic.Id;
        target.adequateTransportation__c = 'Sí';
        insert target;

    } 

}