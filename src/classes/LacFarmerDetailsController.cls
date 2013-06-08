public with sharing class LacFarmerDetailsController {
	private LAC_Farmer_Details__c obj;
	private Attachment profilePicture;
	private ApexPages.StandardController stdController; 

	public LacFarmerDetailsController(ApexPages.StandardController controller) {
		this.stdController = controller;
		this.obj = (LAC_Farmer_Details__c)controller.getRecord();

		if (this.obj.Id == null) {
			this.obj.OwnerId = UserInfo.getUserId();
		}
		
		profilePicture = new Attachment();
	}
	
	public CKW__c getAssociatedCkw() {
		List<Person__c> persons = [
			SELECT 
				Id 
			FROM 
				Person__c 
			WHERE Contact__c IN (SELECT Registered_By__c FROM LAC_Farmer_Details__c WHERE Id =: obj.Id)];
		
		if (!persons.isEmpty()) {
			List<CKW__c> ckws = [
			SELECT 
				Id,
				First_Name__c,
				Last_Name__c 
			FROM 
				CKW__c 
			WHERE 
				Person__c =: persons.get(0).Id];
				
			if (!ckws.isEmpty()) {
				return ckws.get(0);
			}	
		}
		
		
		return null;
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
	
	public Attachment getProfilePicture() {
		if (this.obj.Contact__r.Picture_Attachment_Id__c != null) {
			List<Attachment> attachments = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE Id = :this.obj.Contact__r.Picture_Attachment_Id__c ];
			if (!attachments.isEmpty()) {
				this.profilePicture = attachments.get(0);
			}
		}		
		return this.profilePicture;
	}

	public Decimal getMessagesNum() {
		return [SELECT COUNT() FROM Message__c WHERE Recipient__c = :this.obj.Person__c LIMIT 50000];
	}
	
	public PageReference save() {
		if(this.profilePicture != null) {
			this.profilePicture.OwnerId = UserInfo.getUserId(); 
			
			if(this.profilePicture.Id != null) {
			 	update this.profilePicture;
	    	} else {
	    		this.profilePicture.ParentId = this.obj.Contact__r.Id;
	    		this.profilePicture.IsPrivate = true;
	    		insert this.profilePicture;
	    	}
			
			this.obj.Contact__r.Picture_Attachment_Id__c = this.profilePicture.Id;
			upsert this.obj.Contact__r;
			upsert this.obj;
		}
		
		changeOwner();
		
		PageReference pageReference = new PageReference('/apex/LacFarmerDetails?id='+this.obj.id);
        pageReference.setRedirect(true);
        
        return pageReference;
	}
	
	private void changeOwner(){
		List<Contact> contacts = [SELECT Id, OwnerId FROM Contact WHERE Id = :this.obj.Contact__c];
		if (!contacts.isEmpty()) {
			contacts.get(0).OwnerId = obj.OwnerId;
			update contacts;
		}
		
		List<Person__c> persons = [SELECT Id, OwnerId FROM Person__c WHERE Id = :this.obj.Person__c];
		if (!persons.isEmpty()) {
			persons.get(0).OwnerId = this.obj.OwnerId;
			update persons;
		}
		
		List<LAC_Household__c> households = [SELECT Id, OwnerId FROM LAC_Household__c WHERE Id = :this.obj.LAC_Household__c];
		if (!households.isEmpty()) {
			households.get(0).OwnerId = this.obj.OwnerId;
			update households;
		}
		
		List<LAC_Farm__c> farms = 
			[SELECT 
				Id, 
				OwnerId, 
				LAC_Household__c 
			FROM 
				LAC_Farm__c 
			WHERE 
				LAC_Household__c IN (SELECT Id FROM LAC_Household__c WHERE LAC_Farmer_Id_Temp__c = :this.obj.Name)];
		
		if (!farms.isEmpty()) {
			for (LAC_Farm__c farm : farms) {
				farm.OwnerId = this.obj.OwnerId;
			}
			
			update farms;
		}
	}
}