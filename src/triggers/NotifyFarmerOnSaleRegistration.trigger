trigger NotifyFarmerOnSaleRegistration on Sale_Farmer_Association__c (after insert) {
    EwarehouseTriggerHandler triggerHandler = new EwarehouseTriggerHandler();
    triggerHandler.onAfterSaleRegistrationInsert(Trigger.new);
}