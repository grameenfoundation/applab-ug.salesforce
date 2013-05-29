public with sharing class LacFarmerDetailsController {
	private LAC_Farmer_Details__c obj;
	private Document profilePicture;
	private ApexPages.StandardController stdController; 

	public LacFarmerDetailsController(ApexPages.StandardController controller) {
		this.stdController = controller;
		this.obj = (LAC_Farmer_Details__c)controller.getRecord();
		
		if (this.obj.Id == null) {
			this.obj.OwnerId = UserInfo.getUserId();
		}
		
		profilePicture = new Document();
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
	
	public Document getProfilePicture() {
		if (this.obj.Image_Document_Id__c != null) {
			List<Document> docs = [SELECT Id, Name, Body, FolderId FROM Document WHERE Id = :this.obj.Image_Document_Id__c ];
			if (!docs.isEmpty()) {
				this.profilePicture = docs.get(0);
			}
		}		
		return this.profilePicture;
	}

	public Decimal getMessagesNum() {
		return [SELECT COUNT() FROM Message__c WHERE Recipient__c = :this.obj.Person__c LIMIT 50000];
	}
	
	public PageReference save() {
		this.profilePicture.folderid = UserInfo.getUserId(); //this puts it in My Personal Documents
		upsert this.profilePicture;
		
		this.obj.Image_Document_Id__c = this.profilePicture.Id;
		upsert this.obj;
		
		changeOwner();
		
		PageReference pageReference = new PageReference('/apex/LacFarmerDetails?id='+obj.id);
        pageReference.setRedirect(true);
        
        return pageReference;
	}
	
	private void changeOwner(){
		List<Contact> contacts = [SELECT Id, OwnerId FROM Contact WHERE Id = :obj.Contact__c];
		if (!contacts.isEmpty()) {
			contacts.get(0).OwnerId = obj.OwnerId;
			update contacts;
		}
		
		List<Person__c> persons = [SELECT Id, OwnerId FROM Person__c WHERE Id = :obj.Person__c];
		if (!persons.isEmpty()) {
			persons.get(0).OwnerId = obj.OwnerId;
			update persons;
		}
		
		List<LAC_Household__c> households = [SELECT Id, OwnerId FROM LAC_Household__c WHERE Id = :obj.LAC_Household__c];
		if (!households.isEmpty()) {
			households.get(0).OwnerId = obj.OwnerId;
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
				LAC_Household__c IN (SELECT Id FROM LAC_Household__c WHERE LAC_Farmer_Id_Temp__c = :obj.Name)];
		
		if (!farms.isEmpty()) {
			for (LAC_Farm__c farm : farms) {
				farm.OwnerId = obj.OwnerId;
			}
			
			update farms;
		}
	}
}