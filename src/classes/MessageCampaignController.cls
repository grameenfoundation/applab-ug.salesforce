public with sharing class MessageCampaignController {
	private MessageCampaign__c messageCampaign;
	
	public MessageCampaignController(ApexPages.StandardController controller) {
		this.messageCampaign = (MessageCampaign__c)controller.getRecord();
	}
	
}