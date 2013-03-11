/**
 * This trigger listens in on the after events of the gfsurveys__ContactGroupMember__c object 
 * and passes them on to a handler class GfSurveyContactGroupMemberTriggerHandler
 */
trigger GfSurveyContactGroupMemberTrigger on gfsurveys__ContactGroupMember__c (after delete, after insert) {

	GfSurveyContactGroupMemberTriggerHandler triggerHandler = new GfSurveyContactGroupMemberTriggerHandler();
	if (Trigger.isInsert) {
		triggerHandler.onAfterInsert(Trigger.new);
	} else if (Trigger.isDelete) {
		triggerHandler.onAfterDelete(Trigger.old);
	}
}