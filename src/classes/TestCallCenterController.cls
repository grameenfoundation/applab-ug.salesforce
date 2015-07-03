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
        controller.callerType = 'Farmer';
        String dummyPhoneNumber = '+256771234567';
        controller.setPhoneNumber(dummyPhoneNumber);       
        PageReference pageRef1 = controller.searchByPhoneNumber();
        //PageReference pageRef2 = controller.saveFarmerChanges();
        system.assert(pageRef1 == null);
        //system.assert(pageRef2 == null);
    }
    
    static testmethod void testCreateCases() {        
        CallCenterController controller = new CallCenterController();
        Farmer__c testFarmer = controller.createDefaultFarmer(); 
        Case farmerCase = controller.getCurrentCase();  
        
        System.assert(controller.saveCurrentCase(new Person__c()) == false);   
           
        boolean saved = controller.saveCurrentCase(testFarmer);
        system.assertEquals(saved , false);
        farmerCase.Subject = 'test';
        farmerCase.Category__c = 'Pulse';
        farmerCase.Status = 'New';
        saved = controller.saveCurrentCase(testFarmer);
        system.assertEquals(saved , true);
        
        Person__c person = new Person__c();
        person.First_Name__c = 'testName';
        insert person;
        controller.setChosenId(String.valueOf(person.Id));
        controller.setCkw(person);
        boolean psaved = controller.saveCurrentCase(person);
        system.assertEquals(psaved , true);        
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
        controller.callerType = 'Farmer';
        controller.setPhoneNumber('0791568666');
        controller.searchByPhoneNumber();
        Case currentCase = controller.getCurrentCase();
        currentCase.Status = 'Closed';
        controller.saveCase();
        controller.saveCaseAndClose();
        
        Person__c person = new Person__c();
        person.First_Name__c = 'testName';
        insert person;
        controller.setCkw(person);
        controller.savePersonChanges();//for existing person
        controller.setIsNewFarmer(true);
        controller.savePersonChanges();//for new person
        controller.finish();
        controller.changeFarmer();
        system.assert(currentCase != null);
    }

    // Testing getters and setters to increase code coverage
    static testmethod void testGettersAndSetters() {
        CallCenterController controller = new CallCenterController();
        controller.callerType = 'Farmer';
        String phoneNumber = '078000000';
        controller.setPhoneNumber(phoneNumber);               
        system.assert(controller.getPhoneNumber() == phoneNumber);       
        system.assert(controller.getFarmer() == null);
        system.assert(controller.getFarmers() == null);
        system.assert(controller.searchByPhoneNumber() ==  null);
        system.assert(controller.getIsNewFarmer() == false);
        system.assert(controller.getResponse() != 'response');
        controller.callerType = 'CKW';
        system.assert(controller.getPhoneNumber() == phoneNumber);  
        system.assert(controller.getCallBackRequired() == false);  
        system.assert(controller.getChosenId() == null); 
        system.assert(controller.getCkw() == null); 
        controller.setChosenId('');
    }
}