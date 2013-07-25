@IsTest
public with sharing class CkwUniversalAddEditControllerTest {
	/**
     * tests the removal of the device from a CKW when their status 
     * changes to dropped.
     */
    @IsTest
    static void testCkwStatusChangetoDropped(){
    	CkwUniversalAddEditController controller = initTestController();
        controller.save();
        
        Person__c person = [SELECT Id, Handset__c FROM Person__c WHERE Id=:controller.person.Id];
        System.assertEquals(controller.person.Id, person.Id);
        System.assertEquals(controller.handset.Id, person.Handset__c);
        
        CKW__c ckw = [SELECT Id, Status__c FROM CKW__c WHERE Id = :controller.ckw.Id];
        System.assertEquals(controller.ckw.Id, ckw.Id);
        
       	controller.ckw.Status__c = 'Dropped';
       	controller.save();
       	
       	ckw = [SELECT Id, Status__c FROM CKW__c WHERE Id = :controller.ckw.Id];
       	System.assert(controller.person.Handset__c == null);
    }
    
    /**
     * tests the save action of this controller
     */
    @IsTest
    static void testSave(){
        CkwUniversalAddEditController controller = initTestController();
        controller.save();
        System.debug(ApexPages.getMessages());
        
        System.assertEquals(ApexPages.getMessages().size(), 0);
        
        Phone__c handset = [SELECT Id FROM Phone__c WHERE Id=:controller.handset.Id];
        System.assertEquals(controller.handset.Id, handset.Id);
        
        SIM__c simcard = [SELECT Id FROM SIM__c WHERE Id=:controller.simcard.Id];
        System.assertEquals(controller.simcard.Id, simcard.Id);
        
        Person__c person = [SELECT Id FROM Person__c WHERE Id=:controller.person.Id];
        System.assertEquals(controller.person.Id, person.Id);
        
        gfsurveys__Mobile_User__c mobileUser = [SELECT gfsurveys__Password__c, gfsurveys__Username__c from gfsurveys__Mobile_User__c where gfsurveys__Contact__c =: controller.contact.Id];
        System.assertEquals(mobileUser.gfsurveys__Password__c, 'mobilePass');
        System.assertEquals(mobileUser.gfsurveys__Username__c, 'mobileUsername');
    }
    
    /**
     * tests the SaveAndNew action of this controller
     */
    @IsTest
    static void testSaveAndNew(){
        CkwUniversalAddEditController controller = initTestController();
        PageReference pageRef = controller.saveAndNew();
        String url = pageRef.getUrl();
        String ObjectPrefix = CKW__c.sObjectType.getDescribe().getKeyPrefix();
        System.assertEquals(url, '/'+objectPrefix+'/e');
    }
    
    /**
     * initializes the CkwUniversalAddEditController used during the test.
     *
     * @return CkwUniversalAddEditController - the initialized controller to use 
     * during testing.
     */
    static CkwUniversalAddEditController initTestController(){
    	Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		system.assert(p != null);
		
		User user = new User(Alias = 'ckwtest', Email='ckwtest@testorg.com', 
	    	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	     	LocaleSidKey='en_US', ProfileId = p.Id, 
	     	TimeZoneSidKey='America/Los_Angeles', UserName='ckwtest@testorg.com');
		insert user;
		
        CkwUniversalAddEditController controller = new CkwUniversalAddEditController(new ApexPages.StandardController(new CKW__c()));
        controller.contact.LastName='Rambo';
        controller.contact.FirstName='John';
        controller.contact.OwnerId = user.Id;
        controller.handset.Serial_Number__c='90000000';
        controller.handset.IMEI__c = '9989989893dkdkeid';
        controller.handset.Purchase_Value_USD__c = 450;
        controller.handset.OS_Firmware_Version__c = '4.5';
        controller.simcard.SIM_Serial_Number__c = '5566552241';
        controller.simcard.Name ='839idkdiekd';
        controller.contact.gfsurveys__mobilesurveys_Id__c='89e3938493oe3oe';
        
        controller.mobileUser.gfsurveys__Username__c = 'mobileUsername';
        controller.mobileUser.gfsurveys__Password__c = 'mobilePass';
        
        return controller;
    }
    
     @IsTest
    static void testAttachmentSave() {
    	CkwUniversalAddEditController controller = initTestController();
    	controller.profilePicture.Body = Blob.valueOf('Unit Test Attachment Body'); 
        controller.save();
        System.debug(ApexPages.getMessages());
        
        System.assertEquals(ApexPages.getMessages().size(), 1); // Attachment uploaded successfully
        System.assertNotEquals(controller.contact.Picture_Attachment_Id__c, null);
        
        Contact contact = [SELECT Id, Picture_Attachment_Id__c FROM Contact WHERE Id=:controller.contact.Id];
        System.assertNotEquals(contact.Picture_Attachment_Id__c, null);
    }
}