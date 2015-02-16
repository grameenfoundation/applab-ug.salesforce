/**
 * Controller class for CkwDetailMiniStarts page
 * Tests in GumutindoDashboardTests.cls
 */
public with sharing class CkwDetailMiniStartsController {
	
	private CKW__c obj;
	private Decimal totalSearches = null;
	private Decimal totalSurveys = null;
	private Decimal totalFarmers = null;
	
	private ApexPages.StandardController controller = null;
	
	public CkwDetailMiniStartsController(ApexPages.StandardController controller) {
		this.obj = (CKW__c)controller.getRecord();
		this.controller = controller;
	}
	
	public String getTotalFarmers() {
		if(this.totalFarmers == null) {
			try {
				if(obj.Person__c != null) {
					this.totalFarmers = [SELECT COUNT() FROM Farmer__c WHERE Registered_By__c =: obj.Person__c];
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
	/*
	public String getTotalSurveys() {
		
		//TODO: callout and count survey submissions
		if(this.totalSurveys == null) {
			try {
				if(obj.Person__c != null) {
					//this.totalSurveys = [SELECT COUNT() FROM gfsurveys__Submission__c WHERE gfsurveys__Surveyor__c =: obj.Person__r.Contact__c];
					return 'N/A';
				} else {
					return 'N/A';
				}
			} catch (Exception e) {
				return 'ERROR';
			}
		}
		
		return String.valueOf(this.totalSurveys);
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
			return (interactionsPerFarmer / quarters).setScale(2);
		else 
			return interactionsPerFarmer.setScale(2);
	}*/
}