public with sharing class CampaignMessageDefController {

	private ApexPages.StandardController controller;
	public Campaign_Message_Def__c campaignMessage {get;set;}
	public MessageCampaign__c campaign {get;set;}
	
	public CampaignMessageDefController(ApexPages.StandardController controller) {
		this.campaignMessage = (Campaign_Message_Def__c)controller.getRecord();
		this.controller = controller;
		
		if(campaignMessage.Id != null) {
			campaignMessage = [
				SELECT 
					Name, 
					Format__c,
					Language__c,
					Message_Key__c,
					Date__c,
					Start_Time__c,
					Offset_Time__c,
					Repeat_Every__c,
					Cron__c,
					Repeat_On__c,
					Message_Campaign__r.Id,
					Message_Campaign__r.Name,
					Message_Campaign__r.Campaign_Type__c 
				FROM Campaign_Message_Def__c 
				WHERE Id =: campaignMessage.Id ];
			
			campaign = campaignMessage.Message_Campaign__r;
		} else {
			campaignMessage = new Campaign_Message_Def__c();
		}
	}
	
	/**
	 * saves the campaign message and returns the page reference to the message campaign in which the 
	 * campaign message belongs.
	 */
	public PageReference save() {
		try{
			upsert campaignMessage;		
			String ObjectPrefix = CKW__c.sObjectType.getDescribe().getKeyPrefix();
			PageReference p = new PageReference('/apex/MessageCampaign?id='+campaignMessage.Message_Campaign__c);
			p.setRedirect(true);
			
			return p;
		}catch(Exception ex) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
			return null;
		}
	}
	
	public PageReference saveAndNew() {
		try{
			upsert campaignMessage;		
			String ObjectPrefix = Campaign_Message_Def__c.sObjectType.getDescribe().getKeyPrefix();
			PageReference p = new PageReference('/'+ objectPrefix + '/e');
			p.setRedirect(true);
			
			return p;
		}catch(Exception ex) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
			return null;
		}
	}
	
	/**
	 * called when the user changes the message campaign from the user interface and it's used 
	 * to load the message campaign details from the data store.
	 */
	public void onChangeMessageCampaign() {
		if(campaignMessage.Message_Campaign__c != null) {
			campaign = [SELECT Id, Name, Campaign_Type__c FROM MessageCampaign__c WHERE Id =: campaignMessage.Message_Campaign__c];
		} else {
			campaignMessage.Message_Campaign__c = null;
			campaign = null;
		}
	}
	
	/**
	 * checks whether the campaign is an Absolute campaign
	 */
	public Boolean isAbsoluteCampaign() {
		return isCampaignType('Absolute');
	}
	
	/**
	 * checks whether the campaign is an offset campaign
	 */
	public Boolean isOffsetCampaign() {
		return isCampaignType('Offset');
	}
	
	/**
	 * checks whether the campaign is a Repeat Interval campaign
	 */
	public Boolean isRepeatIntervalCampaign() {
		return isCampaignType('Repeat Interval');
	}
	
	/**
	 * checks whether the campaign is a Cron campaign
	 */
	public Boolean isCronCampaign() {
		return isCampaignType('Cron');
	}
	
	/**
	 * checks whether the campaign is a Day of Week campaign
	 */
	public Boolean isDayOfWeekCampaign() {
		return isCampaignType('Day of Week');
	}
	
	/**
	 * checks whether the campaign is of a given type
	 */
	public Boolean isCampaignType(String campaignType) {
		if(campaign != null && campaign.Campaign_Type__c == campaignType) {
			return true;
		}
		
		return false;
	}
}