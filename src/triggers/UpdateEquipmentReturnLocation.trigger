trigger UpdateEquipmentReturnLocation on Equipment_Return_Line__c (after insert, after update) {

    EquipmentTrackingHelpers.updateReturnLineStatus(trigger.new);
}