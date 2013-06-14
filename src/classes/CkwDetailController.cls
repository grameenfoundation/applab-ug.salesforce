public with sharing class CkwDetailController {
	private CKW__c obj;
	private Decimal totalSearches = null;
	private Decimal totalSurveys = null;
	private Decimal totalFarmers = null;
	
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
	
	public String getTotalFarmers() {
		if(this.totalFarmers == null) {
			try {
				if(obj.Person__r.Contact__c != null) {
					this.totalFarmers = [SELECT COUNT() FROM LAC_Farmer_Details__c WHERE Registered_By__c =: obj.Person__r.Contact__c];
				} else {
					return 'N/A';
				}
			}catch (Exception e) {
				return 'ERROR';
			}
		}
		
		return String.valueOf(this.totalFarmers);
	}
	
	public String getTotalSearches() {
		if(this.totalSearches == null) {
			try {
				this.totalSearches = [SELECT COUNT() FROM Search_Log__c WHERE Interviewer__c =: obj.Person__c];
			} catch (Exception e) {
				return 'ERROR';
			}
		}
		return String.valueOf(this.totalSearches);
	}
	
	public String getTotalSurveys() {
		if(this.totalSurveys == null) {
			try {
				if(obj.Person__r.Contact__c != null) {
					this.totalSurveys = [SELECT COUNT() FROM gfsurveys__Submission__c WHERE gfsurveys__Surveyor__c =: obj.Person__r.Contact__c];
				} else {
					return 'N/A';
				}
			} catch (Exception e) {
				return 'ERROR';
			}
		}
		
		return String.valueOf(this.totalSurveys);
	}
	
	public String getCkwToFarmerRadius() {
		try {
			if(obj.Person__r.Contact__c != null && obj.Person__r.GPS_Location_E__c != null && obj.Person__r.GPS_Location_N__c != null) {
				// Get top 50000 farmers registered by this ckw, who have coordinates
				Decimal distance = 0;
				for(LAC_Farmer_Details__c[] farmers : [SELECT Person__r.GPS_Location_E__c, Person__r.GPS_Location_N__c FROM LAC_Farmer_Details__c WHERE Registered_By__c =: obj.Person__r.Contact__c AND Person__r.GPS_Location_E__c != null AND Person__r.GPS_Location_N__c != null]) {
					for (LAC_Farmer_Details__c farmer : farmers) {
						Decimal newDistance = Math.abs(utils.calcDistance(Decimal.valueOf(obj.Person__r.GPS_Location_N__c), Decimal.valueOf(obj.Person__r.GPS_Location_E__c), Decimal.valueOf(farmer.Person__r.GPS_Location_N__c), Decimal.valueOf(farmer.Person__r.GPS_Location_E__c)));
						if(newDistance > distance) {
							distance = newDistance;
						}
					}
				}
				return String.valueOf(distance);
			} else {
				return 'N/A';
			}
		} catch (Exception e) {
			return 'ERROR';
		}
	}
	
	public Decimal getInteractionsPerFarmerPerQuarter() {
		Decimal searches = null;
		try {
			searches = Decimal.valueOf(this.getTotalSearches());
		} catch (Exception e) {
			searches = 0;
		}
		
		Decimal surveys = null;
		try {
			surveys = Decimal.valueOf(this.getTotalSurveys());
		} catch (Exception e) {
			surveys = 0;
		}
		
		Decimal interactions = searches + surveys;
		
		Decimal farmers = null;
		try {
			farmers = Decimal.valueOf(this.getTotalFarmers());
		} catch (Exception e) {
			farmers = 0;
		} 
		
		Decimal interactionsPerFarmer = 0;
		if(farmers > 0) {
			interactionsPerFarmer = interactions / farmers;
		}
		
		// Quarters quarters since registration
		CKW__c ckw = [SELECT CreatedDate from CKW__c where id =: obj.id];
		Decimal quarters = ckw.CreatedDate.date().daysBetween(Date.today())/91;
		
		// InteractionsPerFarmerPerQuarter
		if(quarters > 0)
			return interactionsPerFarmer / quarters;
		
		return 0.0;
	}
	
	public static testMethod void test() {
		CKW__c obj = new CKW__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(obj);
		CkwDetailController c = new CkwDetailController(sc);
		
		system.assertEquals(Integer.valueOf(c.getTotalSearches()), 0);
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