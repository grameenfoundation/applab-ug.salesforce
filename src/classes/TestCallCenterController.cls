@isTest
public class TestCallCenterController {

    static testmethod void testGetByPhoneNumber() {
        CallCenterController controller = new CallCenterController();
        String dummyPhoneNumber = '0749876342';
        controller.setPhoneNumber(dummyPhoneNumber);
        Farmer__c testFarmer = controller.createDefaultFarmer();  
        controller.setFarmer(testFarmer);      
        Farmer__c[] farmers = controller.getByPhoneNumber(dummyPhoneNumber);
        system.assert(!farmers.isEmpty());
        system.assert(farmers[0].Id == testfarmer.Id);
    }
    
    static testmethod void testSearchByPhoneNumber() {
        CallCenterController controller = new CallCenterController();
        String dummyPhoneNumber = '+256771234567';
        controller.setPhoneNumber(dummyPhoneNumber);       
        PageReference pageRef1 = controller.searchByPhoneNumber();
        PageReference pageRef2 = controller.saveFarmerChanges();
        system.assert(pageRef1 == null);
        system.assert(pageRef2 == null);
    }
    
    static testmethod void testCreateCases() {
        CallCenterController controller = new CallCenterController();
        Farmer__c testFarmer = controller.createDefaultFarmer(); 
        Case farmerCase = controller.getCurrentCase();        
        boolean saved = controller.saveCurrentCase(testFarmer);
        system.assertEquals(saved , false);
        farmerCase.Subject = 'test';
        farmerCase.Category__c = 'Pulse';
        farmerCase.Status = 'New';
        saved = controller.saveCurrentCase(testFarmer);
        system.assertEquals(saved , true);
        
    }
    
   static testmethod void testGetFarmerCases() {
        CallCenterController controller = new CallCenterController();
        Farmer__c testFarmer = null;
        Case[] cases1 = controller.getFarmerCases(testFarmer);
        testFarmer = controller.createDefaultFarmer(); 
        Case[] cases2 = controller.getFarmerCases(testFarmer);
        Case[] cases3 = controller.getCases();
        system.assert(cases1 ==null);
        //system.assert(!cases2.isEmpty());        
    }
    
    static testmethod void testPageReferences() {
        CallCenterController controller = new CallCenterController();
        controller.setPhoneNumber('0791568666');
        controller.searchByPhoneNumber();
        Case currentCase = controller.getCurrentCase();
        currentCase.Status = 'Closed';
        controller.saveCase();
        controller.saveCaseAndClose();
        system.assert(currentCase != null);
    }

    // Testing getters and setters to increase code coverage
    static testmethod void testGettersAndSetters() {
        CallCenterController controller = new CallCenterController();
        String phoneNumber = '078000000';
        controller.setPhoneNumber(phoneNumber);               
        system.assert(controller.getPhoneNumber() == phoneNumber);       
        system.assert(controller.getFarmer() == null);
        system.assert(controller.getFarmers() == null);
        system.assert(controller.searchByPhoneNumber() ==  null);
        system.assert(controller.getIsNewFarmer() == true);
        system.assert(controller.getResponse() != 'response');
    }
}