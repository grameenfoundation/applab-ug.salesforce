trigger NotifyFarmerOnHarvestRegistration on Harvest__c (after insert) {
    EwarehouseTriggerHandler triggerHandler = new EwarehouseTriggerHandler();
    triggerHandler.onAfterHarvestInsert(Trigger.new);
}