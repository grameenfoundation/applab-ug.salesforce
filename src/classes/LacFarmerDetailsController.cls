public with sharing class LacFarmerDetailsController {
	private LAC_Farmer_Details__c obj;

	public LacFarmerDetailsController(ApexPages.StandardController controller) {
		this.obj = (LAC_Farmer_Details__c)controller.getRecord();
	}

	public Decimal getSearchesNum() {
		return [SELECT COUNT() FROM Search_Log__c WHERE Interviewee__c = :this.obj.Person__c LIMIT 50000];
	}

	public Decimal getSubmissionsNum() {
		return [SELECT COUNT() FROM Submission_Meta_Data__c WHERE Interviewee__c = :this.obj.Person__c LIMIT 50000];
	}
	
	public LAC_Farmer_Details__c getFarmer(){ 
		return this.obj;
	}

	public Decimal getMessagesNum() {
		return [SELECT COUNT() FROM Message__c WHERE Recipient__c = :this.obj.Person__c LIMIT 50000];
	}
	
	public PageReference changeOwner(){
		update obj;
		
		//change ownership of the contact
		List<Contact> contacts = [SELECT Id, OwnerId FROM Contact WHERE Id = :obj.Contact__c];
		if(contacts != null && !contacts.isEmpty()){
			contacts.get(0).OwnerId = obj.OwnerId;
			update contacts;
		}
		
		//change ownership of the person
		List<Person__c> persons = [SELECT Id, OwnerId FROM Person__c WHERE Id = :obj.Person__c];
		if(persons != null && !persons.isEmpty()){
			persons.get(0).OwnerId = obj.OwnerId;
			update persons;
		}
		
		//change ownership of household
		List<LAC_Household__c> households = [SELECT Id, OwnerId FROM LAC_Household__c WHERE Id = :obj.LAC_Household__c];
		if(households != null && !households.isEmpty()){
			households.get(0).OwnerId = obj.OwnerId;
			update households;
		}
		
		//change ownership of Farms
		List<LAC_Farm__c> farms = 
			[SELECT 
				Id, 
				OwnerId, 
				LAC_Household__c 
			FROM 
				LAC_Farm__c 
			WHERE 
				LAC_Household__c IN (SELECT Id FROM LAC_Household__c WHERE LAC_Farmer_Id_Temp__c = :obj.Name)];
		
		if (farms != null && !farms.isEmpty()) {
			for (LAC_Farm__c farm : farms) {
				farm.OwnerId = obj.OwnerId;
			}
			
			update farms;
		}
				
        PageReference p = new PageReference('/apex/LacFarmerDetails?id='+obj.id);
        p.setRedirect(true);
        
        return p;
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
		
		LAC_Farmer_Details__c farmerDetails = new LAC_Farmer_Details__c();
		farmerDetails.Person__c = person.Id;
		farmerDetails.Contact__c = contact.Id;
		farmerDetails.LAC_Household__c = household.Id;
		insert farmerDetails;
		
		ApexPages.StandardController sc = new ApexPages.StandardController(farmerDetails);
		LacFarmerDetailsController c = new LacFarmerDetailsController(sc);
		
		c.getFarmer().OwnerId = user.Id;
		c.changeOwner();
		
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