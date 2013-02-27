/**
 * This class contains unit tests for validating the behavior of 
 * GfSurveyContactGroupTriggerHandler
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class GfSurveyContactGroupTriggerHandlerTest {

    /**
     * tests to make sure that a change to the name of a gfsurveys__ContactGroup__c group name 
     * is cascaded to the corresponding Group__c record.
     */
    @IsTest
    static void testGroupNameUpdate(){
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
    	
    	gfsurveys__ContactGroup__c gfGroup = new gfsurveys__ContactGroup__c();
    	gfGroup.Name = 'Testing';
    	gfGroup.gfsurveys__Description__c = 'Testing Trigger';
    	insert gfGroup;
    	
    	try{
    		Group__c ckwGroup = [SELECT Id, Name, Active__c FROM Group__c WHERE Name=:gfGroup.Name];
    		system.assert(ckwGroup != null);
    		
    		gfGroup.Name='Testing2';
    		update gfGroup;
    		
    		Group__c ckwGroup2 = [SELECT Id, Name, Active__c FROM Group__c WHERE Name=:gfGroup.Name];
    		system.assert(ckwGroup2 != null);
			system.assertEquals(ckwGroup.Id, ckwGroup2.Id);	
    	}catch(Exception ex){
    		system.debug(ex.getMessage());
    		system.assert(false);
    	}    	
    }
    
    /**
     * tests to ensure that a deletion of a gfsurveys__ContactGroup__c record deletes the corresponding 
     * Group__c record.
     */
    @IsTest
    static void testGroupDeletion(){
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
    	
    	gfsurveys__ContactGroup__c gfGroup = new gfsurveys__ContactGroup__c();
    	gfGroup.Name = 'Testing';
    	gfGroup.gfsurveys__Description__c = 'Testing Trigger';
    	insert gfGroup;
    	
    	try{
    		gfsurveys__ContactGroupMember__c member = new gfsurveys__ContactGroupMember__c();
    		member.gfsurveys__Contact__c = contact.Id;
    		member.gfsurveys__ContactGroup__c = gfGroup.Id;
    		insert member;
    		
    		Person_Group_Association__c pGroup = [SELECT Group__c, Person__c, Group__r.Name, Person__r.Id FROM Person_Group_Association__c 
				WHERE (Group__r.Name=:gfGroup.Name AND Person__r.Id=:person.Id)];
    		
    		system.assert(pGroup != null);

			delete gfGroup;
			
			Group__c ckwGroup = null;
			try{
				ckwGroup = [SELECT Id, Name, Active__c FROM Group__c WHERE Name=:gfGroup.Name];
			}catch(Exception ex){}
			
    		system.assert(ckwGroup == null);
    		
    		Person_Group_Association__c removedGroup = null;
    		try{
	    		removedGroup = [SELECT Group__c, Person__c, Group__r.Name, Person__r.Id FROM Person_Group_Association__c 
					WHERE (Group__r.Name=:gfGroup.Name AND Person__r.Id=:person.Id)];
    		}catch(Exception ex){}
    		
    		system.assert(removedGroup == null);
				
    	}catch(Exception ex){
    		system.debug(ex.getMessage());
    		system.assert(false);
    	}
    }
    
    /**
     * tests to make sure when a membership record is removed for the gfsurveys__ContactGroup__c group 
     * record, the corresponding Person_Group_Association__c record is also removed.
     */
    @IsTest
    static void testGroupMembershipRemoval(){
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
    	
    	gfsurveys__ContactGroup__c gfGroup = new gfsurveys__ContactGroup__c();
    	gfGroup.Name = 'Testing';
    	gfGroup.gfsurveys__Description__c = 'Testing Trigger';
    	insert gfGroup;
    	
    	try{
    		gfsurveys__ContactGroupMember__c member = new gfsurveys__ContactGroupMember__c();
    		member.gfsurveys__Contact__c = contact.Id;
    		member.gfsurveys__ContactGroup__c = gfGroup.Id;
    		insert member;
    		
    		Person_Group_Association__c pGroup = [SELECT Group__c, Person__c, Group__r.Name, Person__r.Id FROM Person_Group_Association__c 
				WHERE (Group__r.Name = :gfGroup.Name AND Person__r.Id = :person.Id)];
    		
    		system.assert(pGroup != null);
    		
    		delete member;
    		
    		Person_Group_Association__c removedGroup = null;
    		try{
	    		removedGroup = [SELECT Group__c, Person__c, Group__r.Name, Person__r.Id FROM Person_Group_Association__c 
					WHERE (Group__r.Name = :gfGroup.Name AND Person__r.Id = :person.Id)];
    		}catch(Exception ex){}
    		
    		if(removedGroup == null)
    			system.assert(true);
    		else
    			system.assert(false);
				
    	}catch(Exception ex){
    		system.debug(ex.getMessage());
    		system.assert(false);
    	}
    }
    
    /**
     * tests to make sure when a membership record is added for the gfsurveys__ContactGroup__c group 
     * record, the corresponding Person_Group_Association__c record is also added.
     */
    @IsTest
    static void testGroupMemberShipCreation(){
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
    	
    	gfsurveys__ContactGroup__c gfGroup = new gfsurveys__ContactGroup__c();
    	gfGroup.Name = 'Testing';
    	gfGroup.gfsurveys__Description__c = 'Testing Trigger';
    	insert gfGroup;
    	
    	try{
    		gfsurveys__ContactGroupMember__c member = new gfsurveys__ContactGroupMember__c();
    		member.gfsurveys__Contact__c = contact.Id;
    		member.gfsurveys__ContactGroup__c = gfGroup.Id;
    		insert member;
    		
    		Person_Group_Association__c pGroup = [SELECT Group__c, Person__c, Group__r.Name, Person__r.Id FROM Person_Group_Association__c 
				WHERE (Group__r.Name=:gfGroup.Name AND Person__r.Id=:person.Id)];
    		
    		system.assert(pGroup != null);
    	}catch(Exception ex){
    		system.debug(ex.getMessage());
    		system.assert(false);
    	}
    }
    
    /**
     * tests to make sure when a gfsurveys__ContactGroup__c record is created, a Group__c 
     * is also created.
     */
    @IsTest
    static void testGroupCreation(){
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
    	
    	gfsurveys__ContactGroup__c gfGroup = new gfsurveys__ContactGroup__c();
    	gfGroup.Name = 'Testing';
    	gfGroup.gfsurveys__Description__c = 'Testing Trigger';
    	insert gfGroup;
    	
    	try{
    		Group__c ckwGroup = [SELECT Id, Name, Active__c FROM Group__c WHERE Name=:gfGroup.Name];
    		system.assert(ckwGroup != null);
    	}catch(Exception ex){
    		system.debug(ex.getMessage());
    		system.assert(false);
    	}
    }
}