/**
 * This trigger listens in on the after events of the gfsurveys__ContactGroup__c object and passes then on 
 * to a handler class GfSurveyContactGroupTriggerHandler
 * 
 * @author Charles Tumwebaze
 */
trigger GfSurveyContactGroupTrigger on gfsurveys__ContactGroup__c (after insert, after delete, after update) {
    GfSurveyContactGroupTriggerHandler triggerHandler = new GfSurveyContactGroupTriggerHandler();
    
    if(Trigger.isInsert){
        triggerHandler.OnAfterInsert(Trigger.new);
    }else if(Trigger.isUpdate){
        triggerHandler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }else if(Trigger.isDelete){
        triggerHandler.OnAfterDelete(Trigger.old);
    }
}