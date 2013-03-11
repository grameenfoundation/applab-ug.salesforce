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

	public Decimal getMessagesNum() {
		return [SELECT COUNT() FROM Message__c WHERE Recipient__c = :this.obj.Person__c LIMIT 50000];
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