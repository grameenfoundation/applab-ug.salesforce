global with sharing class LACFarmerRegistrationHandler implements Database.Batchable<sObject> {
	public String query = 'Select Id, LAC_Farmer_Id_Temp__c from Person__c where LAC_Farmer_Id_Temp__c != NULL ORDER BY createdDate ASC';
	
	global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }
   
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		for(sObject s : scope) {
			Person__c person = (Person__c) s;
			
			String tempFarmerId = person.LAC_Farmer_Id_Temp__c;
			person.LAC_Farmer_Id_Temp__c = NULL;
			
			// Contact
			Contact[] contacts = [SELECT Id from Contact where gfsurveys__mobilesurveys_Id__c =: tempFarmerId];
			
			if(contacts.size() > 0) {
				// Take only the first one
				Contact contact = contacts[0];
				
				// Delete the rest
				for(Integer i = 1; i < contacts.size(); i ++) {
					delete contacts[i];
				}
				
				// LAC Farmer Details
				LAC_Farmer_Details__c[] farmerDetailsArray = [Select Id, LAC_Farmer_Id_Temp__c, Person__c, LAC_Household__c, Contact__c from LAC_Farmer_Details__c where LAC_Farmer_Id_Temp__c =: tempFarmerId];
				
				if (farmerDetailsArray.size() > 0) {
					
					// Take only the first one
					LAC_Farmer_Details__c farmerDetails = farmerDetailsArray[0];
				
					// Delete the rest
					for(Integer i = 1; i < farmerDetailsArray.size(); i ++) {
						delete farmerDetailsArray[i];
					}
						
					farmerDetails.Person__c = person.Id;
					farmerDetails.Contact__c = contact.Id;
					farmerDetails.LAC_Farmer_Id_Temp__c = NULL;
					
					// Households
					LAC_Household__c[] households = [Select Id, LAC_Farmer_Id_Temp__c, Other_Member_Id__c from LAC_Household__c where LAC_Farmer_Id_Temp__c =: tempFarmerId];
					
					LAC_Household__c householdToUse = NULL;
					Boolean skipThisPerson = false;
					
					for (LAC_Household__c household : households) {
						if(!skipThisPerson) {
							// Pick the first one that doesn't have the other member's household set
							if(householdToUse == NULL) {
								if(household.Other_Member_Id__c == NULL) {
									householdToUse = household;
								} else {
									LAC_Farmer_Details__c[] householdHeadDetailsArray = [Select Id, LAC_Household__c, LAC_Household__r.LAC_Farmer_Id_Temp__c, LAC_Household__r.Id from LAC_Farmer_Details__c where Contact__r.gfsurveys__mobilesurveys_Id__c =: household.Other_Member_Id__c limit 1];
									if(householdHeadDetailsArray.size() > 0 && householdHeadDetailsArray[0] != NULL && householdHeadDetailsArray[0].LAC_Household__c != NULL) {
										householdToUse = householdHeadDetailsArray[0].LAC_Household__r;
										delete household;
									} else {
										// It is possible that the household and farmer record hasn't yet been processed. So we abort here - we'll pick this up on the next loop
										skipThisPerson = true;
									}
								}
							} else {
								// Just delete the rest
								delete household;
							}
						}
					}
					
					if(!skipThisPerson) {
						if(householdToUse != NULL) {
							farmerDetails.LAC_Household__c = householdToUse.Id;
							householdToUse.LAC_Farmer_Id_Temp__c = NULL;
							Database.update(householdToUse);
						}
						
						Database.update(farmerDetails);
						
						
						// NOTE: if Other_Member_Name__c is set instead, we do nothing. We'll create a visual force page for trying to match the farmer names
						
						// LAC Farm
						LAC_Farm__c[] farms = [Select Id, LAC_Household__c, LAC_Farmer_Id_Temp__c from LAC_Farm__c where LAC_Farmer_Id_Temp__c =: tempFarmerId limit 1];
						
						for(LAC_Farm__c farm: farms) {
							farm.LAC_Household__c = farmerDetails.LAC_Household__c;
							farm.LAC_Farmer_Id_Temp__c = NULL;
							Database.update(farm);
						}
						
						// Save the person object
						Database.update(person);
					}
				}
			}
		}		
	}
	
	// Nothing to do in finish()
	global void finish(Database.BatchableContext BC){} 
	
	static testMethod void testHandler() {
		// Set up a test contact
		Contact contact = new Contact();
		contact.gfsurveys__mobilesurveys_Id__c = 'testmobileid';
		contact.LastName = 'Ky';
		contact.FirstName = 'L';
		Database.insert(contact);
		
		// Set up a test person
		Person__c person = new Person__c();
		person.LAC_Farmer_Id_Temp__c = contact.gfsurveys__mobilesurveys_Id__c;
		person.First_Name__c = contact.FirstName;
		person.Last_Name__c = contact.LastName;
		Database.insert(person);
		
		// Set up a test farmer details object
		LAC_Farmer_Details__c farmer = new LAC_Farmer_Details__c();
		farmer.LAC_Farmer_Id_Temp__c = contact.gfsurveys__mobilesurveys_Id__c;
		Database.insert(farmer);
		
		// Set up a test household
		LAC_Household__c household = new LAC_Household__c();
		household.LAC_Farmer_Id_Temp__c = contact.gfsurveys__mobilesurveys_Id__c;
		Database.insert(household);
		
		// Set up a test farm
		LAC_Farm__c farm = new LAC_Farm__c();
		farm.LAC_Farmer_Id_Temp__c = contact.gfsurveys__mobilesurveys_Id__c;
		Database.insert(farm);
		
		// Set up a new contact
		Contact contact2 = new Contact();
		contact2.gfsurveys__mobilesurveys_Id__c = 'testmobileid2';
		contact2.LastName = 'Ky2';
		contact2.FirstName = 'L2';
		Database.insert(contact2);
		
		// Set up a new test person
		Person__c person2 = new Person__c();
		person2.LAC_Farmer_Id_Temp__c = contact2.gfsurveys__mobilesurveys_Id__c;
		person2.First_Name__c = contact2.FirstName;
		person2.Last_Name__c = contact2.LastName;
		Database.insert(person2);
		
		// Set up a new test farmer details object
		LAC_Farmer_Details__c farmer2 = new LAC_Farmer_Details__c();
		farmer2.LAC_Farmer_Id_Temp__c = contact2.gfsurveys__mobilesurveys_Id__c;
		Database.insert(farmer2);
		
		// Set up a new test household but link to the first farmer
		LAC_Household__c household2 = new LAC_Household__c();
		household2.LAC_Farmer_Id_Temp__c = contact2.gfsurveys__mobilesurveys_Id__c;
		household2.Other_Member_Id__c = contact.gfsurveys__mobilesurveys_Id__c;
		Database.insert(household2);
		
		
		// Execute
		Test.StartTest();
		LACFarmerRegistrationHandler handler = new LACFarmerRegistrationHandler();
     	ID batchprocessid = Database.executeBatch(handler);
		Test.StopTest();
		
		// Test Farm
		farm = [Select Id, LAC_Farmer_Id_Temp__c, LAC_Household__c from LAC_Farm__c where Id =: farm.Id limit 1];
		System.assert(farm.LAC_Household__c == household.Id);
		System.assert(farm.LAC_Farmer_Id_Temp__c == NULL);
		
		// Test Person
		person = [Select Id, LAC_Farmer_Id_Temp__c from Person__c where Id =: person.Id];
		System.assert(person.LAC_Farmer_Id_Temp__c == NULL);
		
		// Test that the second person was added to the first household
		LAC_Farmer_Details__c[] peopleInHousehold = [Select Id from LAC_Farmer_Details__c where LAC_Household__c =: household.Id];
		System.assert(peopleInHousehold.size() == 2);
	}
}