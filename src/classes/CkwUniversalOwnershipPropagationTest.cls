/**
 * This class contains unit tests for validating the behavior of 
 * CkwUniversalContactOwnershipPropagationTrigger, CkwUniversalGroupOwnershipPropagationTrigger,
 * CkwUniversalPersonOwnershipPropagationTrigger
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public with sharing class CkwUniversalOwnershipPropagationTest {

	/**
	 * tests the propagation of ownership from contact to person
	 */
	@IsTest
	static void testPropagationFromContactToPerson(){
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		system.assert(p != null);
		
		User user = new User(Alias = 'ckwtest', Email='ckwtest@testorg.com', 
	    	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	     	LocaleSidKey='en_US', ProfileId = p.Id, 
	     	TimeZoneSidKey='America/Los_Angeles', UserName='ckwtest@testorg.com');
		insert user;
		
		RecordType recordType = new RecordType();
    	recordType.Name='Business';
    	
    	Account account = new Account(Name='CKW', RecordType=recordType);
    	account.BillingState='CA';
    	insert account;
    	
    	Contact contact = new Contact();
    	contact.FirstName = 'Grameen';
    	contact.LastName = 'Foundation';
    	contact.AccountId = account.Id;
    	insert contact;
    	
    	Person__c person = new Person__c();
    	person.Last_Name__c = 'Foundation';
    	person.First_Name__c = 'Grameen';
    	person.Contact__c = contact.Id;
    	insert person;
    	
    	system.assertEquals(contact.OwnerId, person.OwnerId);
    	contact.OwnerId = user.Id;
    	update contact;
    	
    	person = [SELECT Id, OwnerId FROM Person__c WHERE Id = :person.Id];
    	
    	system.assertEquals(person.OwnerId, user.Id);
	}
	
	/**
	 * tests the propagation of ownership from person to contact
	 */
	@IsTest
	static void testPropagationFromPersonToContact() {
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		system.assert(p != null);
		
		User user = new User(Alias = 'ckwtest', Email='ckwtest@testorg.com', 
	    	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	     	LocaleSidKey='en_US', ProfileId = p.Id, 
	     	TimeZoneSidKey='America/Los_Angeles', UserName='ckwtest@testorg.com');
		insert user;
		
		RecordType recordType = new RecordType();
    	recordType.Name='Business';
    	
    	Account account = new Account(Name='CKW', RecordType=recordType);
    	account.BillingState='CA';
    	insert account;
    	
    	Contact contact = new Contact();
    	contact.FirstName = 'Grameen';
    	contact.LastName = 'Foundation';
    	contact.AccountId = account.Id;
    	insert contact;
    	
    	Person__c person = new Person__c();
    	person.Last_Name__c = 'Foundation';
    	person.First_Name__c = 'Grameen';
    	person.Contact__c = contact.Id;
    	insert person;
    	
    	system.assertEquals(contact.OwnerId, person.OwnerId);
    	person.OwnerId = user.Id;
    	update person;
    	
    	contact = [SELECT Id, OwnerId FROM Contact WHERE Id = :contact.Id];
    	
    	system.assertEquals(contact.OwnerId, user.Id);
	}
	
	/**
	 * tests the propagation from the Group__c record to the gfsurveys__ContactGroup__c
	 */
	@IsTest
	static void testPropagationFromGroupToGfSurveyGroup() {
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		system.assert(p != null);
		
		User user = new User(Alias = 'ckwtest', Email='ckwtest@testorg.com', 
	    	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	     	LocaleSidKey='en_US', ProfileId = p.Id, 
	     	TimeZoneSidKey='America/Los_Angeles', UserName='ckwtest@testorg.com');
		insert user;
		
		gfsurveys__ContactGroup__c gfGroup = new gfsurveys__ContactGroup__c();
    	gfGroup.Name = 'Testing';
    	gfGroup.gfsurveys__Description__c = 'Testing Trigger';
    	insert gfGroup;
    	
    	/*
    	 * record would have been created because of the 
    	 * GfSurveyContactGroupTrigger
    	 */
    	Group__c ckwGroup = [SELECT Id, Name, Active__c FROM Group__c WHERE Name=:gfGroup.Name];
    	ckwGroup.OwnerId = user.Id;
    	update ckwGroup;
    	
    	gfGroup = [SELECT Id, OwnerId FROM gfsurveys__ContactGroup__c WHERE Id = :gfGroup.Id];
    	
    	system.assertEquals(gfGroup.OwnerId, user.Id);
	}
}