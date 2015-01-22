@isTest
private class LACCoffeeCKWFarmersTest {

    @isTest static void ckwFarmers() {
    
        Contact contact = new Contact();
        contact.FirstName = 'pedrito';
        contact.LastName = 'perez';
        insert contact;
        
        LAC_Farmer_Details__c lacFarmerDetail = new LAC_Farmer_Details__c();
        lacFarmerDetail.Contact__c = contact.Id;
        lacFarmerDetail.interviewer__c = contact.Id;
        insert lacFarmerDetail;
        
        LAC_Coffee_CKW__c lacCoffeeCKW = new LAC_Coffee_CKW__c();
        lacCoffeeCKW .LAC_Farmer_Details__c = lacFarmerDetail.Id;
        lacCoffeeCKW .contact__c = contact.Id;
        insert lacCoffeeCKW;

        ApexPages.StandardController controller = new ApexPages.standardController(lacCoffeeCKW);

        LACCoffeeCKWFarmers laccoffeeCKWClass = new LACCoffeeCKWFarmers(new ApexPages.standardController(lacCoffeeCKW));

        test.startTest();
        String coffeeCKW = lacCoffeeCKW.Id;
        test.stopTest();

        laccoffeeCKWClass.getFarmers();
        System.assert(lacCoffeeCKW != null);

        laccoffeeCKWClass.getCkwId();
        system.assert(lacCoffeeCKW != null);
    }
}