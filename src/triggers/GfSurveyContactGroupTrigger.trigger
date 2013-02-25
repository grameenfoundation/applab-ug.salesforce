trigger GfSurveyContactGroupTrigger on gfsurveys__ContactGroup__c (after insert, after delete, after update) {
    GfSurveyContactGroupTriggerHandler triggerHandler = new GfSurveyContactGroupTriggerHandler();
    
    if(Trigger.isInsert){
        triggerHandler.OnAfterInsert(Trigger.new);
    }else if(Trigger.isUpdate){
        triggerHandler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
    }else if(Trigger.isDelete){
        triggerHandler.OnAfterDelete(Trigger.old);
    }
}