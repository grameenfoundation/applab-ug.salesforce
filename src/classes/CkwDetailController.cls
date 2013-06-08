public with sharing class CkwDetailController {
	private CKW__c obj;
	
	private ApexPages.StandardController controller = null;
	public CkwDetailController(ApexPages.StandardController controller) {
		this.obj = (CKW__c)controller.getRecord();
		this.controller = controller;
	}
	
	/**
	 * removes the handset from the current CKW
	 *
	 * @return PageReference
	 */
	public PageReference removeHandset(){
		List<Person__c> persons = [SELECT Id, Handset__c FROM Person__c WHERE Id = :obj.Person__c];
		if (persons != null && !persons.isEmpty()) {
			persons.get(0).Handset__c = null;
			update persons.get(0);
		}
		
		if (ApexPages.currentPage() != null && ApexPages.currentPage().getUrl() != null) {
			PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
			pageRef.setRedirect(true);
			return pageRef;
		} else {
			return null;
		}
	}
	
	public static testMethod void test() {
		CKW__c obj = new CKW__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(obj);
		CkwDetailController c = new CkwDetailController(sc);
	}
	
	/**
	 * tests the remove handset method
	 */
	public static testMethod void testRemoveHandset(){
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		system.assert(p != null);
		
		User user = new User(Alias = 'ckwtest', Email='ckwtest@testorg.com', 
	    	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	     	LocaleSidKey='en_US', ProfileId = p.Id, 
	     	TimeZoneSidKey='America/Los_Angeles', UserName='ckwtest@testorg.com');
		insert user;
		
		Contact contact = new Contact(LastName='Charles', FirstName='Tumwebaze');
		insert contact;
		
		Phone__c handset = new Phone__c();
		handset.Serial_Number__c='90000000';
        handset.IMEI__c = '9989989893dkdkeid';
       	handset.Purchase_Value_USD__c = 450;
        handset.OS_Firmware_Version__c = '4.5';
        insert handset;
        
        Person__c person = new Person__c();
        person.First_Name__c = 'Charles';
        person.Last_Name__c = 'Tumwebaze';
        person.Handset__c = handset.Id;
        person.Contact__c = contact.Id;
        insert person;
        
        CKW__c ckw = new CKW__c();
        ckw.Person__c = person.Id;
        insert ckw;
        
        system.assert(person.Handset__c != null);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ckw);
		CkwDetailController c = new CkwDetailController(sc);
		c.removeHandset();
		
		person = [SELECT Id, Handset__c FROM Person__c WHERE Id = :person.Id];
		system.assert(person.Handset__c == null);
	}
}