/**
 * This class contains unit tests for validating the behavior of the
 * LacFarmerDetailsController class.
 */
@isTest
private class LacFarmerDetailsControllerTest {
	
	public static testMethod void testLacPpi() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerDetailsController c = new LacFarmerDetailsController(sc);
		c.save();
		
		system.assertEquals(c.getPovertyProbabilityLessThanOneQuarter(), 81.1);
		system.assertEquals(c.getPovertyProbabilityLessThanTwoAndHalf(), 100);
		system.assertEquals(c.getPovertyProbabilityLessThanOneThreeAndThreeQuarter(), 100);
		system.assertEquals(c.getPovertyProbabilityLessThanOneFive(), 100);
	}
	
	public static testMethod void testRetreivingProfilePicture() {
		LAC_Farmer_Details__c farmerDetails = createLacFarmer();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerDetailsController c = new LacFarmerDetailsController(sc);
		c.getProfilePicture().Name = 'TestProfilePic';
    	c.getProfilePicture().Body = Blob.valueOf('Unit Test Attachment Body');
		c.save();
		
		Id attachmentId = farmerDetails.Contact__r.Picture_Attachment_Id__c;
		
		ApexPages.StandardController sc2 = new ApexPages.StandardController(farmerDetails);
		LacFarmerDetailsController c2 = new LacFarmerDetailsController(sc);
		
		
		system.assertEquals(attachmentId, c2.getProfilePicture().Id);
	}
	
	private static LAC_Farmer_Details__c createLacFarmer() {
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
    	
		LAC_Household__c household = new LAC_Household__c(Family_Size__c = 10);
		insert household;
		
		LAC_Farm__c farm = new LAC_Farm__c();
		farm.Name = 'LAC-Farm-222';
		farm.Area__c = 334;
		farm.Banana_area__c = 333;
		farm.LAC_Household__c = household.Id;
		insert farm;
		
		LAC_Farmer_Details__c farmerDetails = new LAC_Farmer_Details__c();
		farmerDetails.Person__c = person.Id;
		farmerDetails.Contact__c = contact.Id;
		farmerDetails.Contact__r = contact;
		farmerDetails.LAC_Household__c = household.Id;
		farmerDetails.OwnerId = user.Id;
		farmerDetails.PPI_Score__c = 2;
		
		return farmerDetails;
	}
	
		/**
	 * tests the change owner method of the LacFarmerDetailsController
	 */
	public static testMethod void testChangeOwner() {
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
    	
		LAC_Household__c household = new LAC_Household__c(Family_Size__c = 10);
		insert household;
		
		LAC_Farm__c farm = new LAC_Farm__c();
		farm.Name = 'LAC-Farm-222';
		farm.Area__c = 334;
		farm.Banana_area__c = 333;
		farm.LAC_Household__c = household.Id;
		insert farm;
		
		LAC_Farmer_Details__c farmerDetails = new LAC_Farmer_Details__c();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerDetailsController c = new LacFarmerDetailsController(sc);
		
		c.getProfilePicture().Name = 'TestProfilePic';
    	c.getProfilePicture().Body = Blob.valueOf('Unit Test Attachment Body');
		c.getFarmer().Person__c = person.Id;
		c.getFarmer().Contact__c = contact.Id;
		c.getFarmer().LAC_Household__c = household.Id;
		c.getFarmer().OwnerId = user.Id;
		c.getFarmer().Contact__r = contact;
		
		c.save();
		
		contact = [SELECT Id, OwnerId FROM Contact WHERE Id = :contact.Id];
		person = [SELECT Id, OwnerId FROM Person__c WHERE Id = :person.Id];
		household = [SELECT Id, OwnerId FROM LAC_Household__c WHERE Id = :household.Id];
		
		system.assertEquals(user.Id, contact.OwnerId);
		system.assertEquals(user.Id, person.OwnerId);
		system.assertEquals(user.Id, household.OwnerId);		
	}
	
	public static testMethod void test() {
		LAC_Farmer_Details__c obj = new LAC_Farmer_Details__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(obj);
		LacFarmerDetailsController c = new LacFarmerDetailsController(sc);

		System.assertEquals(0,c.getSearchesNum());
		System.assertEquals(0,c.getSubmissionsNum());
		System.assertEquals(0,c.getMessagesNum());

		Person__c person = new Person__c(
			First_Name__c = 'test'
		);
		insert person;

		LAC_Farmer_Details__c farmerDetails = new LAC_Farmer_Details__c(Person__c = person.Id);
		insert farmerDetails;

		Search_Log__c searchLog = new Search_Log__c(Interviewee__c = person.Id);
		insert searchLog;

		Submission_Meta_Data__c submission = new Submission_Meta_Data__c(
			Interviewee__c = person.Id,
			Handset_Submit_Time__c = DateTime.now(),
			Result_Hash__c = 'hash',
			Submission_Size__c = 10
		);
		Submission_Meta_Data__c submission2 = submission.clone();
		submission2.Result_Hash__c = 'hash2';
		insert new Submission_Meta_Data__c[]{submission, submission2};


		Message__c message = new Message__c(
			Recipient__c = person.Id,
			Subject__c = 'subject'
		);
		insert new Message__c[]{message,message.clone()};

		sc = new ApexPages.StandardController(farmerDetails);
		c = new LacFarmerDetailsController(sc);

		System.assertEquals(1,c.getSearchesNum());
		System.assertEquals(2,c.getSubmissionsNum());
		System.assertEquals(2,c.getMessagesNum());
	}
}